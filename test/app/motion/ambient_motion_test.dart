import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/motion/ambient_motion.dart';

/// Rumus gerak prototipe: awan 1800 px per periode, dsb.
void main() {
  group('driftOffset', () {
    test('mulai dari posisi diam', () {
      expect(
        driftOffset(startX: 20, from: -300, to: 1500, period: 58, t: 0),
        0,
      );
    });

    test('meluncur 1800 px tiap periode', () {
      expect(
        driftOffset(startX: 20, from: -300, to: 1500, period: 58, t: 5),
        closeTo(1800 * 5 / 58, 1e-9),
      );
      expect(
        driftOffset(startX: 20, from: -300, to: 1500, period: 58, t: 58),
        0,
      );
    });

    test('tepat di tepi kanan ia sudah kembali ke kiri', () {
      // Awan 190 px mulai di 20: 1500 tercapai setelah 1480 px.
      final t = 1480 / 1800 * 58;
      expect(
        driftOffset(startX: 20, from: -300, to: 1500, period: 58, t: t),
        closeTo(-320, 1e-6),
      );
    });
  });

  group('bobOffset', () {
    test('0 → -14 → 0 tiap 3 detik', () {
      expect(bobOffset(t: 0, amplitude: 14, period: 3), 0);
      expect(bobOffset(t: 1.5, amplitude: 14, period: 3), -14);
      expect(bobOffset(t: 3, amplitude: 14, period: 3), closeTo(0, 1e-9));
    });
  });

  group('twinkleAt', () {
    test('0,35/0,75 di lembah dan 1/1,1 di puncak', () {
      final low = twinkleAt(t: 0, period: 2.4);
      expect(low.opacity, closeTo(.35, 1e-9));
      expect(low.scale, closeTo(.75, 1e-9));
      final high = twinkleAt(t: 1.2, period: 2.4);
      expect(high.opacity, closeTo(1, 1e-9));
      expect(high.scale, closeTo(1.1, 1e-9));
    });
  });

  group('wobbleAngle', () {
    test('bingkai pertama 0°, puncak +2°, lembah -2°', () {
      expect(wobbleAngle(t: 0, period: 3), 0);
      expect(wobbleAngle(t: .75, period: 3), closeTo(2 * math.pi / 180, 1e-9));
      expect(
        wobbleAngle(t: 2.25, period: 3),
        closeTo(-2 * math.pi / 180, 1e-9),
      );
    });
  });

  group('sunAngle', () {
    test('satu putaran tiap 40 detik', () {
      expect(sunAngle(t: 0, period: 40), 0);
      expect(sunAngle(t: 10, period: 40), closeTo(math.pi / 2, 1e-9));
      expect(sunAngle(t: 20, period: 40), closeTo(math.pi, 1e-9));
    });
  });

  group('AmbientMotion', () {
    Widget host(Widget child, {bool disableAnimations = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AmbientMotion(child: child),
      ),
    );

    Widget layer({Key? key}) => AmbientLayer(
      key: key,
      builder: (context, seconds, child) =>
          Transform.translate(offset: Offset(seconds * 10, 0), child: child),
      child: const SizedBox.square(dimension: 20),
    );

    double? dx(WidgetTester t) {
      final found = find.descendant(
        of: find.byKey(const ValueKey('lapisan')),
        matching: find.byType(Transform),
      );
      if (found.evaluate().isEmpty) return null;
      return t.widget<Transform>(found).transform.getTranslation().x;
    }

    testWidgets('lapisan mengikuti detik berjalan', (t) async {
      await t.pumpWidget(host(layer(key: const ValueKey('lapisan'))));
      await t.pump();
      await t.pump();
      expect(dx(t), 0);
      await t.pump(const Duration(seconds: 2));
      expect(dx(t), closeTo(20, 1e-9));
    });

    testWidgets('tanpa gerak lapisan tampil apa adanya', (t) async {
      await t.pumpWidget(
        host(layer(key: const ValueKey('lapisan')), disableAnimations: true),
      );
      await t.pump();
      await t.pump();
      await t.pump(const Duration(seconds: 2));
      expect(dx(t), isNull);
      expect(t.hasRunningAnimations, isFalse);
    });

    testWidgets('ticker dilepas saat lapisan dibuang', (t) async {
      await t.pumpWidget(host(layer(key: const ValueKey('lapisan'))));
      await t.pump();
      expect(t.hasRunningAnimations, isTrue);
      await t.pumpWidget(const SizedBox.shrink());
      expect(t.takeException(), isNull);
      expect(t.binding.transientCallbackCount, 0);
    });
  });
}
