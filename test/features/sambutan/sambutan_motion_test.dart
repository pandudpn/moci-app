import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/sambutan/sambutan_screen.dart';

import '../../helpers/harness.dart';

/// Awan, matahari, gelembung, dan Moci di Sambutan ikut gerak prototipe.
void main() {
  Transform? byKey(WidgetTester t, String key) {
    final found = find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(Transform),
    );
    if (found.evaluate().isEmpty) return null;
    return t.widget<Transform>(found.first);
  }

  double angleOf(WidgetTester t, String key) {
    final m = byKey(t, key)!.transform.storage;
    return math.atan2(m[1], m[0]);
  }

  /// Membuka Sambutan lalu menunggu satu tick supaya jam gerak mulai di 0.
  Future<void> open(WidgetTester t) async {
    await pumpApp(
      t,
      env: TestEnv(onboarded: false),
      initialLocation: '/sambutan',
    );
    await t.pump();
    await t.pump();
  }

  testWidgets('awan Sambutan meluncur 1800 px tiap 62 detik', (t) async {
    await open(t);
    expect(find.byType(SambutanScreen), findsOneWidget);
    final before = byKey(t, 'sambutan-cloud-1')!.transform.getTranslation();
    expect(before.x, 0);
    await t.pump(const Duration(seconds: 5));
    final after = byKey(t, 'sambutan-cloud-1')!.transform.getTranslation();
    expect(after.x - before.x, closeTo(1800 * 5 / 62, 1e-6));
    expect(after.y, 0);
  });

  testWidgets('matahari berputar 360° tiap 40 detik', (t) async {
    await open(t);
    final before = angleOf(t, 'sambutan-sun');
    await t.pump(const Duration(seconds: 5));
    expect(angleOf(t, 'sambutan-sun') - before, closeTo(math.pi / 4, 1e-6));
  });

  testWidgets('gelembung bergoyang paling jauh 2°', (t) async {
    await open(t);
    expect(angleOf(t, 'sambutan-bubble'), 0);
    await t.pump(const Duration(milliseconds: 750));
    expect(angleOf(t, 'sambutan-bubble'), closeTo(2 * math.pi / 180, 1e-6));
    await t.pump(const Duration(milliseconds: 1500));
    expect(angleOf(t, 'sambutan-bubble'), closeTo(-2 * math.pi / 180, 1e-6));
  });

  testWidgets('Moci naik-turun 14 px tiap 3 detik', (t) async {
    await open(t);
    final start = byKey(t, 'sambutan-moci')!.transform.getTranslation();
    expect(start.x, 0);
    expect(start.y, 0);
    await t.pump(const Duration(milliseconds: 1500));
    final peak = byKey(t, 'sambutan-moci')!.transform.getTranslation();
    expect(peak.y, closeTo(-14, 1e-6));
    expect(peak.x, 0);
  });

  testWidgets('dengan gerak dimatikan tidak ada yang bergeser', (t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await open(t);
    await t.pump(const Duration(milliseconds: 500));
    expect(t.hasRunningAnimations, isFalse);
    expect(byKey(t, 'sambutan-cloud-1'), isNull);
    expect(byKey(t, 'sambutan-sun'), isNull);
    expect(byKey(t, 'sambutan-bubble'), isNull);
    // Moci tetap punya Transform miliknya sendiri, tapi diam di 0.
    final still = byKey(t, 'sambutan-moci')!.transform.getTranslation();
    expect(still.x, 0);
    expect(still.y, 0);

    final moci = t.getTopLeft(find.byKey(const ValueKey('sambutan-moci')));
    final bubble = t.getTopLeft(find.byKey(const ValueKey('sambutan-bubble')));
    await t.pump(const Duration(seconds: 5));
    await t.pump(const Duration(seconds: 5));
    expect(t.getTopLeft(find.byKey(const ValueKey('sambutan-moci'))), moci);
    expect(t.getTopLeft(find.byKey(const ValueKey('sambutan-bubble'))), bubble);
  });
}
