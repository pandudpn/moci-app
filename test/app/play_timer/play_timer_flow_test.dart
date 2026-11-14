import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/play_timer/play_timer_controller.dart';
import 'package:moci/app/router.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';

import '../../helpers/harness.dart';

String _top(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

List<String> _stack(GoRouter r) => [
  for (final m in r.routerDelegate.currentConfiguration.matches)
    m.matchedLocation,
];

ProviderContainer _c(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Satu detik per tick: jam maju, tick dikirim, lalu satu pump.
Future<void> _tick(WidgetTester t, TestEnv env, int seconds) async {
  for (var i = 0; i < seconds; i++) {
    env.clock.advance(const Duration(seconds: 1));
    env.ticks.add(null);
    await t.pump();
  }
}

Future<GoRouter> _openHewan(WidgetTester t, TestEnv env) async {
  final router = await pumpApp(t, env: env, initialLocation: '/');
  router.push('/hewan');
  await t.pump(const Duration(milliseconds: 600));
  expect(_top(router), '/hewan');
  return router;
}

void main() {
  testWidgets('20 menit bermain membuka Istirahat di atas layar aktif, '
      'lalu kembali sendiri setelah 20 detik', (t) async {
    final env = TestEnv();
    final router = await _openHewan(t, env);

    await _tick(t, env, 1200);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/istirahat');
    expect(_stack(router), ['/', '/hewan', '/istirahat']);

    await t.pump(const Duration(seconds: 20));
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/hewan');
    expect(_stack(router), ['/', '/hewan']);
    expect(_c(t).read(playTimerProvider).secondsSinceRest, 0);
    expect(_c(t).read(playTimerProvider).restDue, isFalse);
  });

  testWidgets('batas tercapai membuka Waktu Habis dan back sistem diabaikan', (
    t,
  ) async {
    final env = TestEnv();
    final router = await _openHewan(t, env);
    await _c(t).read(prefsProvider.notifier).setDailyLimit(15);

    await _tick(t, env, 900);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/habis');

    await t.binding.handlePopRoute();
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/habis');
  });

  testWidgets('menaikkan batas langsung membuka blokir', (t) async {
    final env = TestEnv();
    final router = await _openHewan(t, env);
    await _c(t).read(prefsProvider.notifier).setDailyLimit(15);
    await _tick(t, env, 900);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/habis');

    await _c(t).read(prefsProvider.notifier).setDailyLimit(30);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/');
  });

  testWidgets('Waktu Habis menang atas Istirahat di tick yang sama', (t) async {
    final env = TestEnv(
      progress: const Progress(playSeconds: {'2026-11-14': 1500}),
    );
    final router = await _openHewan(t, env);
    await _c(t).read(prefsProvider.notifier).setDailyLimit(45);

    await _tick(t, env, 1200);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/habis');
    expect(_stack(router), isNot(contains('/istirahat')));
  });

  testWidgets(
    'Istirahat yang tertunda dibuka saat anak kembali dari orang tua',
    (t) async {
      final env = TestEnv();
      final router = await _openHewan(t, env);
      await _tick(t, env, 1190);
      router.go('/gerbang');
      await t.pump(const Duration(milliseconds: 600));
      // Di rute orang tua waktu tidak dihitung.
      await _tick(t, env, 30);
      expect(_c(t).read(playTimerProvider).secondsSinceRest, 1190);

      router.go('/hewan');
      await t.pump(const Duration(milliseconds: 600));
      await _tick(t, env, 10);
      await t.pump(const Duration(milliseconds: 600));
      expect(_top(router), '/istirahat');
    },
  );

  testWidgets('di Gerbang dan Area Orang Tua waktu tidak bertambah', (t) async {
    final env = TestEnv();
    final router = await pumpApp(t, env: env, initialLocation: '/gerbang');
    expect(_top(router), '/gerbang');
    await _tick(t, env, 30);
    expect(_c(t).read(playTimerProvider).secondsToday, 0);

    _c(t).read(parentAccessProvider.notifier).grant();
    router.go('/orang-tua');
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/orang-tua');
    await _tick(t, env, 30);
    expect(_c(t).read(playTimerProvider).secondsToday, 0);
  });

  testWidgets('disimpan tiap 30 detik terhitung', (t) async {
    final env = TestEnv();
    await _openHewan(t, env);
    await _tick(t, env, 29);
    expect(_c(t).read(progressProvider).playSeconds['2026-11-14'], isNull);
    await _tick(t, env, 1);
    expect(_c(t).read(progressProvider).playSeconds['2026-11-14'], 30);
  });

  testWidgets('disimpan saat aplikasi ke latar dan tidak dihitung di latar', (
    t,
  ) async {
    final env = TestEnv();
    await _openHewan(t, env);
    await _tick(t, env, 10);

    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await t.pump();
    expect(_c(t).read(progressProvider).playSeconds['2026-11-14'], 10);

    await _tick(t, env, 20);
    expect(_c(t).read(playTimerProvider).secondsToday, 10);

    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pump();
    await _tick(t, env, 5);
    expect(_c(t).read(playTimerProvider).secondsToday, 15);
  });

  testWidgets('aplikasi ditangguhkan tanpa event pause: loncatan jam dijepit', (
    t,
  ) async {
    final env = TestEnv();
    await _openHewan(t, env);
    await _tick(t, env, 10);
    env.clock.advance(const Duration(hours: 5));
    env.ticks.add(null);
    await t.pump();
    expect(_c(t).read(playTimerProvider).secondsToday, 12);
  });
}
