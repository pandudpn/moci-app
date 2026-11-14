import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress_controller.dart';

import '../helpers/harness.dart';

String _path(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

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
}
