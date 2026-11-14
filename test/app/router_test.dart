import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/router.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';

import '../helpers/harness.dart';

String _path(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

List<String> _stack(GoRouter r) => [
  for (final m in r.routerDelegate.currentConfiguration.matches)
    m.matchedLocation,
];

ProviderContainer _c(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

void main() {
  testWidgets('belum onboarded: / dialihkan ke Sambutan', (t) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: false),
      initialLocation: '/',
    );
    expect(_path(router), '/sambutan');
  });

  testWidgets('/orang-tua tanpa izin dialihkan ke Gerbang', (t) async {
    final router = await pumpApp(t, env: TestEnv(onboarded: true));
    router.go('/orang-tua');
    await t.pump();
    await t.pump();
    final uri = router.routerDelegate.currentConfiguration.uri;
    expect(uri.path, '/gerbang');
    expect(uri.queryParameters['lanjut'], '/orang-tua');
  });

  testWidgets('path tak dikenal kembali ke Beranda, bukan halaman galat', (
    t,
  ) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: true),
      initialLocation: '/tidak-ada',
    );
    await t.pump(const Duration(milliseconds: 600));
    expect(_path(router), '/');
    expect(_stack(router), ['/']);
    expect(find.text('Page Not Found'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('back sistem: menu kembali ke /, di / tetap di /', (t) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: true),
      initialLocation: '/',
    );
    expect(_path(router), '/');
    router.push('/hewan');
    await t.pump(const Duration(milliseconds: 600));
    expect(_path(router), '/hewan');
    await t.binding.handlePopRoute();
    await t.pump(const Duration(milliseconds: 600));
    expect(_path(router), '/');
    await t.binding.handlePopRoute();
    await t.pump(const Duration(milliseconds: 600));
    expect(_path(router), '/');
  });

  testWidgets('ComingSoonScreen mencatat kegiatan terakhir', (t) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: true),
      initialLocation: '/',
    );
    router.push('/hewan');
    await t.pump(const Duration(milliseconds: 600));
    final c = ProviderScope.containerOf(t.element(find.byType(MociApp)));
    expect(c.read(progressProvider).lastActivity!.route, '/hewan');
  });

  testWidgets('onboarded menjadi true: Sambutan hilang dari tumpukan', (
    t,
  ) async {
    final env = TestEnv(onboarded: false);
    final router = await pumpApp(t, env: env, initialLocation: '/');
    expect(_stack(router), ['/sambutan']);
    await _c(t)
        .read(prefsProvider.notifier)
        .completeOnboarding(
          lang: AppLang.id,
          childName: 'Ayu',
          age: AgeLevel.penjelajah,
        );
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(_stack(router), ['/']);
  });

  testWidgets('batas tercapai: tumpukan dorong dibuang ke Waktu Habis', (
    t,
  ) async {
    final env = TestEnv(
      progress: const Progress(playSeconds: {'2026-11-14': 1700}),
    );
    final router = await pumpApp(t, env: env, initialLocation: '/');
    router.push('/hewan');
    await t.pump(const Duration(milliseconds: 600));
    expect(_stack(router), ['/', '/hewan']);

    await _c(t).read(prefsProvider.notifier).setDailyLimit(15);
    await t.pump(const Duration(milliseconds: 600));
    expect(_stack(router), ['/habis']);
  });

  testWidgets('akses orang tua tidak menjatuhkan tumpukan; revoke menutup', (
    t,
  ) async {
    final router = await pumpApp(
      t,
      env: TestEnv(onboarded: true),
      initialLocation: '/',
    );
    final c = _c(t);
    router.push('/gerbang');
    await t.pump(const Duration(milliseconds: 600));
    expect(_stack(router), ['/', '/gerbang']);

    c.read(parentAccessProvider.notifier).grant();
    await t.pump(const Duration(milliseconds: 600));
    expect(_stack(router), ['/', '/gerbang']);
    expect(c.read(parentAccessProvider), isTrue);

    c.read(parentAccessProvider.notifier).revoke();
    router.go('/orang-tua');
    await t.pump(const Duration(milliseconds: 600));
    expect(router.routerDelegate.currentConfiguration.uri.path, '/gerbang');
    expect(c.read(parentAccessProvider), isFalse);
  });
}
