import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/musik/musik_lagu.dart';
import 'package:moci/features/musik/musik_screen.dart';

import '../../helpers/harness.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/musik',
}) async {
  final router = await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
  return router;
}

void main() {
  testWidgets('membuka: 8 batang, preload 12 instrumen', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.text('Main Musik'), findsOneWidget);
    expect(find.byKey(MusikScreen.barKey(0)), findsOneWidget);
    expect(find.byKey(MusikScreen.barKey(7)), findsOneWidget);
    expect(
      env.audio.preloaded
          .where((p) => p.startsWith('assets/audio/instrumen/'))
          .length,
      12,
    );
  });

  testWidgets('ketuk batang memutar nada yang benar', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(MusikScreen.barKey(3)));
    await t.pump();
    expect(env.audio.plays.last.asset, 'assets/audio/instrumen/xilo-4.wav');
    expect(env.audio.plays.last.volume, AudioService.sfxVolume);
  });

  testWidgets('sakelar efek suara mematikan nada', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    _container(t).read(prefsProvider.notifier).setSfx(false);
    await t.pump();
    await t.tap(find.byKey(MusikScreen.barKey(0)));
    await t.pump();
    expect(env.audio.plays, isEmpty);
  });

  testWidgets('dengar memainkan seluruh lagu lalu berhenti', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(MusikScreen.listenKey));
    await t.pump(const Duration(milliseconds: 300));
    expect(
      env.audio.plays.map((p) => p.asset).first,
      'assets/audio/instrumen/xilo-1.wav',
    );
    expect(find.text('Berhenti'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 250));
    // Jam palsu tidak ikut maju oleh pump; cooldown tekan 400 ms butuh ini.
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(find.byKey(MusikScreen.listenKey));
    await t.pump(const Duration(milliseconds: 2000));
    final jumlah = env.audio.plays.length;
    await t.pump(const Duration(milliseconds: 2000));
    expect(env.audio.plays.length, jumlah);
  });

  testWidgets('ganti lagu membatalkan jadwal', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(MusikScreen.listenKey));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.byKey(MusikScreen.songKey('mary')));
    await t.pump();
    final jumlah = env.audio.plays.length;
    await t.pump(const Duration(seconds: 3));
    expect(env.audio.plays.length, jumlah);
  });

  testWidgets('ikuti menyelesaikan lagu dan memuji', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(MusikScreen.followKey));
    await t.pump();
    for (final nada in laguTwinkle.nada) {
      env.clock.advance(const Duration(seconds: 1));
      await t.tap(find.byKey(MusikScreen.barKey(nada)));
      await t.pump(const Duration(milliseconds: 450));
    }
    expect(find.text('Hebat! Kamu memainkan satu lagu!'), findsOneWidget);
    expect(env.tts.spoken.last.$1, 'Hebat! Kamu memainkan satu lagu!');
  });

  testWidgets('drum: empat pad dan irama berhenti sendiri', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/musik?alat=drum');
    expect(find.byKey(MusikScreen.padKey('drum-drum')), findsOneWidget);
    expect(find.byKey(MusikScreen.padKey('drum-kerincing')), findsOneWidget);
    await t.tap(find.byKey(MusikScreen.padKey('drum-tepuk')));
    await t.pump();
    expect(env.audio.plays.last.asset, 'assets/audio/instrumen/drum-tepuk.wav');
    await t.tap(find.byKey(MusikScreen.beatKey));
    await t.pump(const Duration(milliseconds: 400));
    expect(env.audio.plays.length, greaterThan(1));
    await t.pump(const Duration(milliseconds: 250));
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(find.byKey(MusikScreen.beatKey));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Mainkan irama'), findsOneWidget);
  });

  testWidgets('keluar layar menghentikan nada', (t) async {
    final env = TestEnv();
    final router = await _open(t, env: env);
    await t.tap(find.byKey(MusikScreen.listenKey));
    await t.pump(const Duration(milliseconds: 300));
    router.go('/');
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    await t.runAsync(() => Future<void>.delayed(Duration.zero));
    await t.pump();
    expect(
      env.audio.live.values.where((a) => a.startsWith('assets/audio/')),
      isEmpty,
    );
  });

  testWidgets('ganti bahasa mengganti label alat musik', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('Xylophone'), findsOneWidget);
    expect(find.text('Play along'), findsOneWidget);
  });
}
