import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/beranda/widgets/beranda_phone.dart';
import 'package:moci/features/beranda/widgets/beranda_tablet.dart';

import '../../helpers/harness.dart';

/// Awan, matahari, kilau, dan Moci di Beranda ikut gerak prototipe.
void main() {
  Transform? byKey(WidgetTester t, String key) {
    final found = find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(Transform),
    );
    if (found.evaluate().isEmpty) return null;
    return t.widget<Transform>(found.first);
  }

  double dxOf(WidgetTester t, String key) =>
      byKey(t, key)!.transform.getTranslation().x;

  double angleOf(WidgetTester t, String key) {
    final m = byKey(t, key)!.transform.storage;
    return math.atan2(m[1], m[0]);
  }

  double scaleOf(WidgetTester t, String key) =>
      byKey(t, key)!.transform.storage[0];

  double opacityOf(WidgetTester t, String key) {
    final found = find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(Opacity),
    );
    return found.evaluate().isEmpty ? 1 : t.widget<Opacity>(found).opacity;
  }

  /// Membuka Beranda lalu menunggu satu tick supaya jam gerak mulai di 0.
  Future<void> open(WidgetTester t, {Size size = tabletSize}) async {
    await pumpApp(t, size: size, initialLocation: '/');
    await t.pump();
    await t.pump();
  }

  testWidgets('awan tablet meluncur 1800 px tiap 58 detik', (t) async {
    await open(t);
    expect(find.byType(BerandaTablet), findsOneWidget);
    final before = dxOf(t, 'beranda-cloud-1');
    await t.pump(const Duration(seconds: 5));
    expect(dxOf(t, 'beranda-cloud-1') - before, closeTo(1800 * 5 / 58, 1e-6));
  });

  testWidgets('matahari berputar dan kilau berkelip', (t) async {
    await open(t);
    final sunBefore = angleOf(t, 'beranda-sun');
    final sparkleBefore = scaleOf(t, 'beranda-sparkle-1');
    final sparkleOpacityBefore = opacityOf(t, 'beranda-sparkle-1');

    await t.pump(const Duration(seconds: 5));

    // 360° tiap 40 detik.
    expect(angleOf(t, 'beranda-sun') - sunBefore, closeTo(math.pi / 4, 1e-6));
    // Kilau berkelip: skala dan opacity berubah.
    expect(
      scaleOf(t, 'beranda-sparkle-1'),
      isNot(closeTo(sparkleBefore, 1e-6)),
    );
    expect(
      opacityOf(t, 'beranda-sparkle-1'),
      isNot(closeTo(sparkleOpacityBefore, 1e-6)),
    );
  });

  testWidgets('Moci HP naik-turun 8 px tiap 3 detik', (t) async {
    await open(t, size: phoneSize);
    expect(find.byType(BerandaPhone), findsOneWidget);
    final start = byKey(t, 'beranda-moci')!.transform.getTranslation();
    expect(start.x, 0);
    expect(start.y, 0);
    // 1,5 detik = puncak (naik 8 px).
    await t.pump(const Duration(milliseconds: 1500));
    final m = byKey(t, 'beranda-moci')!.transform.getTranslation();
    expect(m.y, closeTo(-8, 1e-6));
    expect(m.x, 0);
  });

  testWidgets('awan HP meluncur lebih pendek: 1200 px tiap 46 detik', (
    t,
  ) async {
    await open(t, size: phoneSize);
    final before = dxOf(t, 'beranda-cloud-1');
    await t.pump(const Duration(seconds: 5));
    expect(dxOf(t, 'beranda-cloud-1') - before, closeTo(1200 * 5 / 46, 1e-6));
  });

  testWidgets('dengan gerak dimatikan tidak ada yang bergeser', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await open(t);
    await t.pump(const Duration(milliseconds: 500));
    expect(t.hasRunningAnimations, isFalse);

    // Tanpa gerak tidak ada transform suasana sama sekali.
    expect(byKey(t, 'beranda-cloud-1'), isNull);
    expect(byKey(t, 'beranda-sun'), isNull);
    expect(byKey(t, 'beranda-sparkle-1'), isNull);

    final cloudLeft = t.getTopLeft(
      find.byKey(const ValueKey('beranda-cloud-1')),
    );
    await t.pump(const Duration(seconds: 5));
    await t.pump(const Duration(seconds: 5));
    expect(
      t.getTopLeft(find.byKey(const ValueKey('beranda-cloud-1'))),
      cloudLeft,
    );
    expect(byKey(t, 'beranda-cloud-1'), isNull);
  });
}
