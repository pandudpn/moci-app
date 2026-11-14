// Uji integrasi tiga skenario Spesifikasi Teknis, dijalankan di perangkat.
//
//   fvm flutter test integration_test -d "iPad (A16)"
//   fvm flutter test integration_test -d emulator-5554
//
// Aplikasi selalu dinyalakan lewat `runMoci(overrides:)`, jadi jalur
// penyimpanan, progres, katalog aset, dan pengatur waktu di `main.dart` ikut
// teruji. Provider yang sudah diisi `runMoci` (key value, json, progres awal,
// katalog aset) tidak boleh dioverride lagi: riverpod melempar galat untuk
// override ganda. Keadaan awal karena itu ditulis ke penyimpanan perangkat.
// Yang dioverride hanya jam, detak pengatur waktu, mesin audio, TTS, dan
// sumber acak gerbang.
//
// Tidak ada `pumpAndSettle`: maskot beranimasi terus. Semua penantian memakai
// `_pumpUntil` dengan batas waktu.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/play_timer/play_timer_controller.dart';
import 'package:moci/app/router.dart';
import 'package:moci/core/audio/audio_providers.dart';
import 'package:moci/core/audio/audio_session.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/features/huruf/huruf_screen.dart';
import 'package:moci/features/orang_tua/gerbang_screen.dart';
import 'package:moci/features/tulis/tracing_board.dart';
import 'package:moci/main.dart' as moci;
import 'package:moci/widgets/moci_back_button.dart';
import 'package:moci/widgets/number_keypad.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/helpers/fake_audio.dart';
import '../test/helpers/fake_clock.dart';

/// Kategori sesi audio tidak dipanggil di tes.
final class _SilentSession implements AudioSessionConfigurator {
  const _SilentSession();

  @override
  Future<void> usePlayback() async {}
}

/// Teks kartu bahasa, sama di kedua bahasa.
const _langCardHint = 'Pilih bahasa · Choose a language';

/// Override mesin audio dan TTS: tes tidak memutar suara.
List<Override> _quietAudio(FakeAudioEngine audio, FakeDeviceTts tts) => [
  audioEngineProvider.overrideWithValue(audio),
  deviceTtsProvider.overrideWithValue(tts),
  audioSessionProvider.overrideWithValue(const _SilentSession()),
];

/// Menghapus pengaturan dan berkas aplikasi, lalu menulis keadaan awal yang
/// diminta. Setiap tes mulai dari keadaan yang sama.
Future<void> _prepareDevice({
  AppLang? lang,
  String? childName,
  bool onboarded = false,
  int? limitMinutes,
}) async {
  final prefs = SharedPreferencesAsync();
  await prefs.clear();
  if (lang != null) await prefs.setString('moci.bahasa', lang.name);
  if (childName != null) await prefs.setString('moci.nama', childName);
  await prefs.setBool('moci.sambutanSelesai', onboarded);
  if (limitMinutes != null) await prefs.setInt('moci.batasMenit', limitMinutes);

  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}/moci');
  if (dir.existsSync()) await dir.delete(recursive: true);
}

/// Satu peluncuran: jam palsu, detak manual, audio dan TTS palsu.
final class _Launch {
  _Launch({DateTime? now})
    : clock = FakeClock(now ?? DateTime(2026, 11, 14, 10));

  final FakeClock clock;
  final audio = FakeAudioEngine();
  final tts = FakeDeviceTts();
  final ticks = StreamController<void>.broadcast();

  Future<void> run(WidgetTester t, {List<Override> extra = const []}) async {
    await moci.runMoci(
      overrides: [
        clockProvider.overrideWithValue(clock),
        playTimerTicksProvider.overrideWithValue(ticks.stream),
        ..._quietAudio(audio, tts),
        ...extra,
      ],
    );
    await t.pump();
  }

  /// Satu detak per detik, seperti `Stream.periodic` yang digantikan.
  Future<void> tick(WidgetTester t, int seconds) async {
    for (var i = 0; i < seconds; i++) {
      clock.advance(const Duration(seconds: 1));
      ticks.add(null);
      // Detak sampai ke pendengar di mikro-tugas; jam berikutnya baru boleh
      // maju setelah detak ini diproses.
      await Future<void>.delayed(Duration.zero);
      if (i % 60 == 59) await t.pump();
    }
    await t.pump();
  }

  Future<void> dispose() => ticks.close();
}

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

GoRouter _router(WidgetTester t) => _container(t).read(routerProvider);

RouteMatchList _config(WidgetTester t) =>
    _router(t).routerDelegate.currentConfiguration;

/// Rute yang benar-benar tampil, termasuk hasil push.
String _lastPath(WidgetTester t) => _config(t).last.matchedLocation;

List<String> _stack(WidgetTester t) => [
  for (final m in _config(t).matches) m.matchedLocation,
];

/// Menunggu [finder] muncul, tanpa `pumpAndSettle` (animasi tidak pernah diam).
Future<void> _pumpUntil(
  WidgetTester t,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await t.pump(const Duration(milliseconds: 50));
  }
  fail(
    'Tidak muncul dalam ${timeout.inSeconds} dtk: '
    '${finder.describeMatch(Plurality.many)} (rute: ${_debugRoute(t)})',
  );
}

/// Rute saat gagal, untuk pesan galat.
String _debugRoute(WidgetTester t) {
  try {
    return _stack(t).join(' ');
  } on Object {
    return '(aplikasi belum terpasang)';
  }
}

/// Layar baru muncul, sudah diberi waktu transisi rutenya selesai.
Future<void> _screen(WidgetTester t, Finder finder) async {
  await _pumpUntil(t, finder);
  await t.pump(const Duration(milliseconds: 600));
}

/// Ketukan pada [finder]. Rute yang baru masuk masih bergeser selama sekitar
/// 400 ms, dan ketukan di tengah transisi bisa meleset ke luar layar; jadi
/// tunggu sampai titik pusatnya berada di dalam layar.
Future<void> _tap(WidgetTester t, Finder finder) async {
  final screen = Offset.zero & (t.view.physicalSize / t.view.devicePixelRatio);
  for (var i = 0; i < 40 && !screen.contains(t.getRect(finder).center); i++) {
    await t.pump(const Duration(milliseconds: 50));
  }
  final center = t.getRect(finder).center;
  if (!screen.contains(center)) {
    fail(
      'Titik ketuk $center di luar layar $screen untuk '
      '${finder.describeMatch(Plurality.many)}',
    );
  }
  await t.tap(finder);
}

/// Mengetik nama anak. Kanal teks palsu tidak terpasang di tes integrasi
/// (`registerTestTextInput` dimatikan), jadi teks ditulis ke pengendali kolom,
/// jalur yang sama dengan ketikan pengguna.
Future<void> _typeName(WidgetTester t, String name) async {
  t.widget<EditableText>(find.byType(EditableText)).controller.text = name;
  await t.pump();
}

/// Jawaban soal gerbang yang sedang tampil, dibaca dari layarnya.
int _answerOnScreen(WidgetTester t) {
  final text = t.widget<Text>(find.textContaining(' × ')).data!;
  final parts = text.replaceAll(' =', '').split(' × ');
  return int.parse(parts[0]) * int.parse(parts[1]);
}

Future<void> _type(WidgetTester t, int number) async {
  for (final digit in '$number'.split('')) {
    await _tap(
      t,
      find.descendant(
        of: find.byType(NumberKeypad),
        matching: find.text(digit),
      ),
    );
    await t.pump();
  }
}

/// Gerbang dibuka: jawab soalnya lalu tekan "Enter".
Future<void> _passGate(WidgetTester t) async {
  await _screen(t, find.byType(NumberKeypad));
  await _type(t, _answerOnScreen(t));
  await _screen(t, find.text('Enter'));
  await _tap(t, find.text('Enter'));
}

/// Menggores satu garis lurus di papan tracing, memakai koordinat dasar 520.
Future<void> _traceOn(WidgetTester t, Offset a, Offset b) async {
  final r = t.getRect(find.byKey(TracingBoard.surfaceKey));
  Offset p(Offset v) =>
      Offset(r.left + v.dx * r.width / 520, r.top + v.dy * r.height / 520);
  final g = await t.startGesture(p(a));
  for (var i = 1; i <= 24; i++) {
    await g.moveTo(p(Offset.lerp(a, b, i / 24)!));
    await t.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await t.pump(const Duration(milliseconds: 120));
}

/// Tiga goresan huruf A, sama dengan jalur di aset tracing.
Future<void> _traceA(WidgetTester t) async {
  await _traceOn(t, const Offset(260, 70), const Offset(130, 450));
  await _traceOn(t, const Offset(260, 70), const Offset(390, 450));
  await _traceOn(t, const Offset(176, 315), const Offset(344, 315));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'pertama kali: Sambutan sekali, nama tersimpan, dibuka lagi langsung '
    'Beranda',
    (t) async {
      await _prepareDevice();
      final app = _Launch();
      addTearDown(app.dispose);

      // Peluncuran pertama, penyimpanan sungguhan di perangkat.
      await app.run(t);
      await _pumpUntil(t, find.byKey(const ValueKey('splash-letter-M')));
      expect(_lastPath(t), '/splash');

      await _screen(t, find.text(_langCardHint));
      expect(_lastPath(t), '/sambutan');

      await _tap(t, find.text('English'));
      await _typeName(t, 'Raka');
      await _tap(t, find.textContaining('4–5'));
      await _tap(t, find.text("Let's Go!"));
      await _pumpUntil(t, find.text('Hi, Raka!'));
      expect(_stack(t), ['/']);

      // Back sistem di Beranda diabaikan (D7): dimakan, rute tetap '/'.
      expect(await t.binding.handlePopRoute(), isTrue);
      await t.pump(const Duration(milliseconds: 300));
      expect(_stack(t), ['/']);

      // Sebelum pohon dibongkar: tulisannya sudah ada di penyimpanan
      // perangkat, bukan hanya di state provider. `completeOnboarding`
      // menulis empat kunci berurutan lewat platform channel setelah state
      // berganti, jadi di Android tulisan terakhir bisa belum sampai saat
      // Beranda tampil. Tunggu sampai bendera tertulis, dengan batas waktu.
      final disk = SharedPreferencesAsync();
      await t.runAsync(() async {
        final deadline = DateTime.now().add(const Duration(seconds: 5));
        while (await disk.getBool('moci.sambutanSelesai') != true &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      });
      expect(await disk.getBool('moci.sambutanSelesai'), isTrue);
      expect(await disk.getString('moci.nama'), 'Raka');
      expect(await disk.getString('moci.bahasa'), AppLang.en.name);

      // "Tutup dan buka lagi": pohon widget dibongkar sehingga seluruh
      // provider dibuang, lalu `runMoci` dijalankan lagi. Prefs dan
      // progress.json dibaca ulang dari disk, jadi yang terbukti adalah
      // penyimpanan nyata, bukan state di memori.
      await t.pumpWidget(const SizedBox.shrink());
      await t.pump();
      final again = _Launch();
      addTearDown(again.dispose);
      await again.run(t);

      // Nilai yang sama masih ada di perangkat saat aplikasi dibuka lagi.
      final reread = SharedPreferencesAsync();
      expect(await reread.getBool('moci.sambutanSelesai'), isTrue);
      expect(await reread.getString('moci.nama'), 'Raka');

      await _pumpUntil(t, find.text('Hi, Raka!'));
      expect(_stack(t), ['/']);

      // Sama setelah dibuka lagi.
      expect(await t.binding.handlePopRoute(), isTrue);
      await t.pump(const Duration(milliseconds: 300));
      expect(_stack(t), ['/']);
      expect(find.text(_langCardHint), findsNothing);
      final prefs = _container(t).read(prefsProvider);
      expect(prefs.lang, AppLang.en);
      expect(prefs.childName, 'Raka');
      expect(prefs.ageLevel, AgeLevel.penjelajah);
      expect(prefs.onboarded, isTrue);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets('gerbang: salah, benar, masuk, keluar, lalu diminta lagi', (
    t,
  ) async {
    await _prepareDevice(lang: AppLang.en, childName: 'Raka', onboarded: true);
    final app = _Launch();
    addTearDown(app.dispose);
    await app.run(t, extra: [gateRandomProvider.overrideWithValue(Random(11))]);
    await _screen(t, find.text('Hi, Raka!'));
    expect(_stack(t), ['/']);

    // Beranda ke Gerbang: didorong untuk Area Orang Tua.
    await _tap(t, find.bySemanticsLabel('Parents'));
    await _screen(t, find.byType(NumberKeypad));
    expect(_stack(t), ['/', '/gerbang']);
    // Tujuan `lanjut` dibuktikan oleh perilaku: "Masuk" nanti mendarat di
    // Area Orang Tua, bukan kembali ke Beranda.

    // Jawaban salah: pesan salah, lalu soal baru.
    await _type(t, _answerOnScreen(t) + 1);
    expect(find.text('Not quite.'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1100));
    expect(find.text('Try this new one.'), findsOneWidget);

    // Jawaban benar: Masuk, lalu Area Orang Tua menggantikan Gerbang.
    await _type(t, _answerOnScreen(t));
    await _screen(t, find.text('Enter'));
    await _tap(t, find.text('Enter'));
    await _screen(t, find.text("Parents' Corner"));
    expect(_stack(t), ['/', '/orang-tua']);
    expect(_container(t).read(parentAccessProvider), isTrue);

    // Kunci dan kembali ke Beranda: akses dicabut, tumpukan tinggal Beranda.
    await _tap(t, find.bySemanticsLabel('Lock and go back home'));
    await _screen(t, find.text('Hi, Raka!'));
    expect(_stack(t), ['/']);
    expect(_container(t).read(parentAccessProvider), isFalse);

    // Membuka Area Orang Tua lagi diarahkan ke Gerbang.
    _router(t).go('/orang-tua');
    await _screen(t, find.byType(NumberKeypad));
    expect(_lastPath(t), '/gerbang');
    expect(find.text("Parents' Corner"), findsNothing);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets(
    'batas waktu: 15 menit jadi Waktu Habis, dinaikkan ke 30 menit lewat '
    'Gerbang',
    (t) async {
      await _prepareDevice(
        lang: AppLang.en,
        childName: 'Raka',
        onboarded: true,
        limitMinutes: 15,
      );
      final app = _Launch();
      addTearDown(app.dispose);
      await app.run(
        t,
        extra: [gateRandomProvider.overrideWithValue(Random(11))],
      );
      await _screen(t, find.text('Hi, Raka!'));
      expect(_stack(t), ['/']);

      // Sepuluh detik pertama memastikan waktu benar-benar dihitung di
      // Beranda (D14), bukan hanya di rute bermain lain.
      await app.tick(t, 10);
      expect(_container(t).read(playTimerProvider).secondsToday, 10);

      // 15 menit = 900 detik. Refresh router meruntuhkan tumpukan push, jadi
      // yang tersisa hanya Waktu Habis (perilaku go_router yang diterima).
      await app.tick(t, 890);
      await _screen(t, find.text('Playtime is over for today'));
      expect(_lastPath(t), '/habis');
      expect(_stack(t), ['/habis']);

      // Back sistem dikunci di Waktu Habis.
      expect(await t.binding.handlePopRoute(), isTrue);
      await t.pump(const Duration(milliseconds: 300));
      expect(_lastPath(t), '/habis');

      // Pil "Untuk orang tua": Gerbang, lalu Area Orang Tua.
      await _tap(t, find.bySemanticsLabel('For grown-ups'));
      await _passGate(t);
      await _screen(t, find.text("Parents' Corner"));
      expect(_stack(t), ['/habis', '/orang-tua']);

      // Batas dinaikkan saat akses orang tua terbuka: router tidak
      // me-refresh, jadi Area Orang Tua tetap terbuka.
      await _tap(t, find.text('30 min'));
      await t.pump(const Duration(milliseconds: 600));
      expect(_lastPath(t), '/orang-tua');
      expect(_stack(t), ['/habis', '/orang-tua']);
      expect(_container(t).read(playTimerProvider).limitReached, isFalse);

      // Kunci dan kembali: `go('/')` membawa redirect dengan batas terbaru.
      await _tap(t, find.bySemanticsLabel('Lock and go back home'));
      await _pumpUntil(t, find.text('Hi, Raka!'));
      expect(_stack(t), ['/']);
      final timer = _container(t).read(playTimerProvider);
      expect(timer.secondsToday, 900);
      expect(timer.limitReached, isFalse);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets('huruf: kenal, tulis A, lalu lanjutkan', (t) async {
    await _prepareDevice(lang: AppLang.id, childName: 'Raka', onboarded: true);
    final app = _Launch();
    addTearDown(app.dispose);
    await app.run(t);
    await _screen(t, find.text('Hai, Raka!'));
    expect(_stack(t), ['/']);

    // Beranda → Kenal Huruf.
    await _tap(t, find.byKey(const ValueKey('menu-huruf')));
    await _screen(t, find.byKey(HurufScreen.letterKey));
    expect(_stack(t), ['/', '/huruf']);

    // Pil Tulis menggantikan Kenal Huruf; tumpukan tidak menumpuk mode.
    await _tap(t, find.text('Tulis'));
    await _screen(t, find.byType(TracingBoard));
    expect(_stack(t), ['/', '/huruf/tulis']);

    // Gores A sampai bilah selesai muncul.
    await _traceA(t);
    await _pumpUntil(t, find.text('Hebat!'));
    expect(find.text('Lanjut'), findsOneWidget);

    // Kembali ke Beranda: kartu Lanjutkan menunjuk tulisan terakhir.
    await _tap(t, find.byType(MociBackButton));
    await _screen(t, find.text('Hai, Raka!'));
    expect(_stack(t), ['/']);
    expect(find.text('Tulis huruf A'), findsOneWidget);

    // Kartu Lanjutkan membuka lagi layar yang sama dengan huruf tersimpan.
    await _tap(t, find.text('Tulis huruf A'));
    await _screen(t, find.byType(TracingBoard));
    expect(_lastPath(t), '/huruf/tulis');
    expect(find.text('Tulis A'), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('permainan: puzzle, hadiah, lalu kembali ke Beranda', (t) async {
    await _prepareDevice(lang: AppLang.en, childName: 'Raka', onboarded: true);
    final app = _Launch();
    addTearDown(app.dispose);
    await app.run(t);
    await _screen(t, find.text('Hi, Raka!'));
    expect(_stack(t), ['/']);

    // Beranda → hub.
    await _tap(t, find.text("Let's Play!"));
    await _screen(t, find.text('Pick a game'));
    expect(_lastPath(t), '/main');

    // Hub → Puzzle (papan 2 × 2 untuk pemula).
    await _tap(t, find.text('Jigsaw Puzzle'));
    await _screen(t, find.text('Puzzle'));
    expect(_lastPath(t), '/main/puzzle');
    expect(find.text('0 / 4 pieces'), findsOneWidget);

    // Empat keping: ketuk keping, lalu tempatnya.
    for (var i = 1; i <= 4; i++) {
      await _tap(t, find.bySemanticsLabel('Puzzle piece $i'));
      await t.pump(const Duration(milliseconds: 450));
      await _tap(t, find.bySemanticsLabel('Spot $i'));
      await t.pump(const Duration(milliseconds: 450));
    }

    // Ronde selesai: hadiah disimpan sebelum Hebat tampil. Pita Hebat
    // menampilkan judul dalam huruf besar.
    await _screen(t, find.text('GREAT JOB!'));
    expect(_lastPath(t), '/hebat');
    expect(_container(t).read(progressProvider).stars, 3);
    expect(_container(t).read(progressProvider).stickers, hasLength(1));

    // Tombol Lanjut kembali ke Beranda, bukan ke papan yang sudah selesai.
    await _tap(t, find.text('Continue'));
    await _pumpUntil(t, find.text('Hi, Raka!'));
    expect(_stack(t), ['/']);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
