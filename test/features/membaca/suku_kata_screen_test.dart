import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:moci/app/routes.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/membaca/suku_kata/suku_kata_screen.dart';

import '../../helpers/harness.dart';
import '../../helpers/harness.dart' as harness;

/// Aplikasi utuh, lalu tunggu transisi rute selesai sebelum mengetuk.
Future<GoRouter> pumpApp(
  WidgetTester t, {
  TestEnv? env,
  String? initialLocation,
}) async {
  final router = await harness.pumpApp(
    t,
    env: env,
    initialLocation: initialLocation,
  );
  await t.pump(const Duration(milliseconds: 600));
  return router;
}

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('membuka: konsonan b, lima suku, contoh Badak', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    expect(find.text('Ayo Membaca'), findsOneWidget);
    expect(find.text('Pilih huruf'), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('ba')), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('bo')), findsOneWidget);
    expect(find.text('Badak', findRichText: true), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), [
      'Ketuk suku kata untuk mendengarnya!',
    ]);
  });
  testWidgets('memilih konsonan mengganti baris dan membacakan lima suku', (
    t,
  ) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    env.tts.spoken.clear();
    await t.tap(find.byKey(SukuKataScreen.konsonanKey('k')));
    await t.pump();
    await t.pump();
    expect(find.text('Kado', findRichText: true), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['ka', 'ki', 'ku', 'ke', 'ko']);
  });
  testWidgets('mengetuk suku kata mencatat progres membaca', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    await t.tap(find.byKey(SukuKataScreen.sukuKey('bi')));
    await t.pump();
    expect(env.tts.spoken.last.$1, 'bi');
    expect(_progress(t).perkembangan['membaca']!['dibaca'], ['bi']);
  });
  testWidgets('suku tanpa contoh menampilkan ajakan ucapkan', (t) async {
    await pumpApp(t, initialLocation: Routes.sukuKata);
    await t.tap(find.byKey(SukuKataScreen.konsonanKey('z')));
    await t.pump();
    expect(find.text('Ayo ucapkan!'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('baca semua membacakan lima suku berurutan', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    env.tts.spoken.clear();
    await t.tap(find.byKey(SukuKataScreen.readAllKey));
    await t.pump();
    await t.pump();
    expect(env.tts.spoken.map((e) => e.$1), ['ba', 'bi', 'bu', 'be', 'bo']);
  });
  testWidgets('ganti bahasa mengganti contoh kata', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text('Ball', findRichText: true), findsOneWidget);
    expect(find.text('Badak', findRichText: true), findsNothing);
  });
  testWidgets('lanjutkan membuka konsonan terakhir', (t) async {
    await pumpApp(t, initialLocation: '${Routes.sukuKata}?huruf=k');
    expect(find.text('Kado', findRichText: true), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('ko')), findsOneWidget);
  });
  testWidgets('kueri konsonan tidak dikenal kembali ke b', (t) async {
    await pumpApp(t, initialLocation: '${Routes.sukuKata}?huruf=q');
    expect(find.text('Badak', findRichText: true), findsOneWidget);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.sukuKata);
    await t.tap(find.text('Susun Kata'));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      Routes.susunKata,
    );
  });
}
