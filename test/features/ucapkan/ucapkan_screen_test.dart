import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/speech/speech_engine.dart';
import 'package:moci/features/ucapkan/ucapkan_screen.dart';

import '../../helpers/harness.dart';

/// Membuka layar lalu menuntaskan transisi rute supaya kontrol kanan sudah
/// di posisinya. Tanpa `pumpAndSettle` karena cincin mikrofon beranimasi.
Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/huruf/ucapkan',
}) async {
  final router = await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
  return router;
}

void main() {
  testWidgets('mic pertama membuka gerbang, bukan permintaan izin', (t) async {
    final env = TestEnv();
    final router = await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(find.text('Panggil Ayah atau Bunda'), findsOneWidget);
    await t.tap(find.text('Buka Gerbang'));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/gerbang',
    );
    expect(env.speech.prepareCount, 0);
    router.pop(true);
    await t.pump();
    await t.pump();
    expect(env.speech.prepareCount, 1);
  });

  testWidgets('judul gerbang mikrofon mengikuti panggilan tersimpan', (
    t,
  ) async {
    final env = TestEnv();
    await env.store.setString('moci.panggilan', 'papiMami');
    await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(find.text('Panggil Papi atau Mami'), findsOneWidget);
  });

  testWidgets('English memakai panggilan pilihan', (t) async {
    final env = TestEnv(lang: AppLang.en);
    await env.store.setString('moci.panggilan', 'daddyMommy');
    await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(find.text('Call Daddy or Mommy'), findsOneWidget);
  });

  testWidgets('kata cocok: pujian, bintang, dan kata berikutnya', (t) async {
    final env = TestEnv();
    env.speech.hasPermissionValue = true;
    env.speech.turn = const SpeechTurn(didengar: true, teks: 'apel');
    await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(find.text('Bagus sekali!'), findsOneWidget);
    expect(env.speech.targets.single, 'Apel');
    await t.tap(find.text('Kata berikutnya'));
    await t.pump();
    expect(find.text('BOLA'), findsOneWidget);
  });

  testWidgets('izin ditolak: layar tetap bisa dimainkan', (t) async {
    final env = TestEnv();
    env.speech.hasPermissionValue = true;
    env.speech.status = SpeechStatus.izinDitolak;
    await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(find.text('Dengar dan tiru'), findsOneWidget);
    expect(find.byKey(UcapkanScreen.micKey), findsNothing);
    expect(find.text('Kata berikutnya'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('pengenalan tidak tersedia: meter suara menentukan', (t) async {
    final env = TestEnv();
    env.speech.hasPermissionValue = true;
    env.speech.turn = null;
    env.meter.hasil = true;
    await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(env.meter.listenCount, 1);
    expect(find.text('Bagus sekali!'), findsOneWidget);
  });

  testWidgets(
    'dua percobaan gagal tetap memuji dan menawarkan kata berikutnya',
    (t) async {
      final env = TestEnv();
      env.speech.hasPermissionValue = true;
      env.speech.turn = const SpeechTurn(didengar: true, teks: 'buku');
      await _open(t, env: env);
      for (var i = 0; i < 2; i++) {
        await t.tap(find.byKey(UcapkanScreen.micKey));
        await t.pump();
        // Cooldown ketukan 400 ms: jam tes dimajukan supaya ketukan kedua
        // diterima, seperti anak yang menunggu jawaban.
        env.clock.advance(const Duration(milliseconds: 500));
      }
      expect(find.text('Ayo coba lagi!'), findsNothing);
      expect(find.text('Kata berikutnya'), findsOneWidget);
    },
  );

  testWidgets('lanjutkan membuka kata terakhir', (t) async {
    await _open(t, lokasi: '/huruf/ucapkan?kata=Bola');
    expect(find.text('BOLA'), findsOneWidget);
    expect(find.byKey(UcapkanScreen.syllableKey(0)), findsOneWidget);
  });

  testWidgets('meninggalkan layar saat mendengar mematikan mikrofon', (
    t,
  ) async {
    final env = TestEnv();
    env.speech.hasPermissionValue = true;
    env.speech.gate = Completer<void>();
    final router = await _open(t, env: env);
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
    expect(env.speech.listenCount, 1);
    // Anak keluar selagi giliran mendengar masih berjalan.
    router.go('/beranda');
    await t.pump();
    // Dua pump: yang pertama memulai transisi rute, kedua menuntaskannya.
    await t.pump(const Duration(milliseconds: 600));
    expect(env.speech.stopCount, 1);
    expect(env.meter.stopCount, 1);
    // Giliran yang tertinggal tidak boleh menyentuh state layar yang lepas.
    env.speech.gate!.complete();
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
