import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/harness.dart';

String _path(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

void main() {
  testWidgets('pindah ke beranda tepat di 3600 ms', (t) async {
    final router = await pumpApp(t, initialLocation: '/splash');
    await t.pump(const Duration(milliseconds: 3599));
    expect(_path(router), '/splash');
    await t.pump(const Duration(milliseconds: 1));
    await t.pump();
    expect(_path(router), '/');
  });

  testWidgets('belum onboarding: lanjut ke sambutan', (t) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: false),
      initialLocation: '/splash',
    );
    await t.pump(const Duration(milliseconds: 3600));
    await t.pump();
    expect(_path(router), '/sambutan');
  });

  testWidgets('sasaran lewati punya label semantik', (t) async {
    await pumpApp(t, initialLocation: '/splash');
    expect(find.bySemanticsLabel('Lewati intro'), findsOneWidget);
  });

  testWidgets('ketukan langsung berpindah layar', (t) async {
    final router = await pumpApp(t, initialLocation: '/splash');
    await t.pump(const Duration(milliseconds: 200));
    await t.tapAt(const Offset(10, 10));
    await t.pump();
    await t.pump();
    expect(_path(router), '/');
  });

  testWidgets('layar HP juga tampil dan pindah', (t) async {
    final router = await pumpApp(
      t,
      size: phoneSize,
      initialLocation: '/splash',
    );
    await t.pump(const Duration(milliseconds: 3600));
    await t.pump();
    expect(_path(router), '/');
  });

  testWidgets('tidak bersuara', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/splash');
    await t.pump(const Duration(milliseconds: 3600));
    expect(env.audio.plays, isEmpty);
  });

  testWidgets('huruf tersembunyi sampai gilirannya', (t) async {
    await pumpApp(t, initialLocation: '/splash');
    double opacityOf(String c) => t
        .widget<Opacity>(
          find.ancestor(
            of: find.byKey(ValueKey('splash-letter-$c')),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;
    await t.pump(const Duration(milliseconds: 1000));
    expect(opacityOf('M'), 0);
    await t.pump(const Duration(milliseconds: 600));
    expect(opacityOf('M'), 1);
    expect(opacityOf('i'), lessThan(1));
  });

  group('gerak dikurangi', () {
    void still(WidgetTester t, bool on) =>
        t.platformDispatcher.accessibilityFeaturesTestValue = on
        ? const FakeAccessibilityFeatures(disableAnimations: true)
        : const FakeAccessibilityFeatures();

    double opacityOf(WidgetTester t, String c) => t
        .widget<Opacity>(
          find.ancestor(
            of: find.byKey(ValueKey('splash-letter-$c')),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;

    testWidgets('adegan diam memakai frame akhir', (t) async {
      still(t, true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpApp(t, initialLocation: '/splash');
      await t.pump(const Duration(milliseconds: 300));
      for (final c in ['M', 'o', 'c', 'i']) {
        expect(opacityOf(t, c), 1, reason: 'huruf $c');
      }
      await t.pump(const Duration(milliseconds: 300));
      expect(opacityOf(t, 'i'), 1, reason: 'tidak ada gerak');
    });

    testWidgets('gerak dinyalakan lagi: adegan lanjut, tidak beku', (t) async {
      await pumpApp(t, initialLocation: '/splash');
      await t.pump(const Duration(milliseconds: 200));
      still(t, true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await t.pump();
      expect(opacityOf(t, 'M'), 1, reason: 'frame diam');
      still(t, false);
      await t.pump();
      await t.pump(const Duration(milliseconds: 1500));
      expect(opacityOf(t, 'M'), 1, reason: 'animasi lanjut dari awal');
    });
  });
}
