import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hewan/hewan_isi.dart';
import 'package:moci/features/hewan/hewan_screen.dart';

import '../../helpers/harness.dart';

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Membuka layar lalu menuntaskan transisi rute; tanpa itu kontrol di sisi
/// kanan masih tergeser keluar layar.
Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/hewan',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

Future<void> _pump(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 550));
}

void main() {
  testWidgets('membuka: kucing, fakta, 42 hewan, narasi nama', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.text('Dunia Hewan'), findsOneWidget);
    expect(find.text('Kucing'), findsOneWidget);
    expect(find.byKey(HewanScreen.factKey), findsOneWidget);
    expect(find.text('1 / 42'), findsOneWidget);
    expect(find.byKey(HewanScreen.tileKey('kucing')), findsOneWidget);
    expect(find.byKey(HewanScreen.tileKey('anjing')), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['Kucing']);
  });

  testWidgets('kelompok air menyaring dan mencatat', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(HewanScreen.groupKey(HewanKelompok.air)));
    await _pump(t);
    expect(find.text('1 / 7'), findsOneWidget);
    expect(find.text('Ikan'), findsOneWidget);
    expect(find.byKey(HewanScreen.tileKey('kucing')), findsNothing);
    expect(_progress(t).perkembangan['hewan']!['dilihat'], ['kucing', 'ikan']);
  });

  testWidgets('panah berikutnya mengganti nama dan bunyi', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(HewanScreen.nextKey));
    await _pump(t);
    expect(find.text('Anjing'), findsOneWidget);
    expect(find.text('Guk guk!'), findsOneWidget);
    expect(env.tts.spoken.last.$1, 'Anjing');
  });

  testWidgets('suara tanpa berkas memakai TTS', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    env.tts.spoken.clear();
    await t.tap(find.byKey(HewanScreen.hearSoundKey));
    await t.pump();
    expect(env.tts.spoken.single.$1, 'Meong!');
    expect(env.audio.live, isEmpty);
  });

  testWidgets('suara dengan berkas memutar m4a', (t) async {
    final env = TestEnv(assets: {'assets/audio/hewan/kucing.m4a'});
    await _open(t, env: env);
    env.tts.spoken.clear();
    await t.tap(find.byKey(HewanScreen.imageKey));
    await t.pump();
    expect(env.audio.live.values, contains('assets/audio/hewan/kucing.m4a'));
    expect(env.tts.spoken, isEmpty);
  });

  testWidgets('dengar nama dan dengar fakta membacakan baris katalog', (
    t,
  ) async {
    final env = TestEnv();
    await _open(t, env: env);
    env.tts.spoken.clear();
    await t.tap(find.byKey(HewanScreen.hearNameKey));
    await t.pump();
    expect(env.tts.spoken.single.$1, 'Kucing');
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.text('Dengar'));
    await t.pump();
    expect(env.tts.spoken.last.$1, contains('Kucing suka tidur'));
  });

  testWidgets('ganti bahasa mengganti nama, bunyi, dan fakta', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await _pump(t);
    expect(find.text('Cat'), findsOneWidget);
    expect(find.text('Meow!'), findsOneWidget);
    expect(find.text('Did you know?'), findsOneWidget);
    expect(env.tts.spoken.last.$2, AppLang.en);
  });

  testWidgets('lanjutkan membuka hewan terakhir', (t) async {
    await _open(t, lokasi: '/hewan?hewan=singa');
    expect(find.text('11 / 42'), findsOneWidget);
  });
}
