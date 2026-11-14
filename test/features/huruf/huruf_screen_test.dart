import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/huruf/huruf_screen.dart';

import '../../helpers/harness.dart';

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Membuka layar lalu menuntaskan transisi rute; tanpa itu kontrol di sisi
/// kanan masih tergeser keluar layar. Tanpa `pumpAndSettle` karena maskot
/// dan cincin beranimasi terus.
Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/huruf',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('membuka layar: huruf A, kata Apel, dan narasi fonik', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.byKey(HurufScreen.letterKey), findsOneWidget);
    expect(find.text('Apel', findRichText: true), findsOneWidget);
    expect(find.text('1 / 26'), findsOneWidget);
    expect(find.text('Bunyi'), findsOneWidget);
    expect(find.text('Nama:'), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['a', 'Apel']);
  });

  testWidgets('ketukan huruf mengikuti cara baca orang tua', (t) async {
    final env = TestEnv(letterMode: LetterMode.nama);
    await _open(t, env: env);
    await t.tap(find.byKey(HurufScreen.nextKey));
    await t.pump();
    env.tts.spoken.clear();
    await t.tap(find.byKey(HurufScreen.letterKey));
    expect(env.tts.spoken.map((e) => e.$1), ['be']);
  });

  testWidgets('panah berikutnya: kata dan indeks ikut berganti', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(HurufScreen.nextKey));
    await t.pump();
    expect(find.text('Bola', findRichText: true), findsOneWidget);
    expect(find.text('2 / 26'), findsOneWidget);
    expect(_progress(t).perkembangan['huruf']!['dibaca'], ['A', 'B']);
  });

  testWidgets('kisi huruf: memilih Z', (t) async {
    await _open(t);
    await t.tap(find.byKey(HurufScreen.alphabetCellKey('Z')));
    await t.pump();
    expect(find.text('Zebra', findRichText: true), findsOneWidget);
  });

  testWidgets('ganti bahasa mengganti kata contoh', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(HurufScreen.nextKey));
    await t.pump();
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('Ball', findRichText: true), findsOneWidget);
    expect(env.tts.spoken.last.$2, AppLang.en);
  });

  testWidgets('lanjutkan membuka huruf terakhir', (t) async {
    await _open(t, lokasi: '/huruf?huruf=B');
    expect(find.text('2 / 26'), findsOneWidget);
    expect(find.text('Bola', findRichText: true), findsOneWidget);
  });
}
