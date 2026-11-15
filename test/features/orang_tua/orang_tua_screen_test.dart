import 'dart:async';

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/config.dart';
import 'package:moci/app/play_timer/play_timer_controller.dart';
import 'package:moci/app/router.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:moci/features/orang_tua/gerbang_game.dart';
import 'package:moci/features/orang_tua/gerbang_screen.dart';
import 'package:moci/widgets/number_keypad.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

const _today = '2026-11-14';

Progress _progress({int play = 1080}) => Progress(
  harian: const {_today: DayStats(stars: 9, stickers: 1, karya: 1)},
  playSeconds: {_today: play},
);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Router<Object>)));

String _top(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

AppPrefs _prefs(WidgetTester t) => _container(t).read(prefsProvider);

Future<void> _pump(WidgetTester t, [int ms = 100]) async {
  await t.pump();
  await t.pump(Duration(milliseconds: ms));
}

/// Membuka Area Orang Tua di atas [from] dengan akses terbuka.
Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  String from = '/',
  Size size = tabletSize,
}) async {
  final router = await pumpApp(
    t,
    env: env ?? TestEnv(progress: _progress()),
    initialLocation: from,
    size: size,
  );
  // Seperti jalur nyata: Gerbang didorong lalu diganti Area Orang Tua.
  router.push(Routes.gerbangLanjut(Routes.orangTua));
  await _pump(t);
  _container(t).read(parentAccessProvider.notifier).grant();
  router.pushReplacement(Routes.orangTua);
  await _pump(t, 600);
  expect(_top(router), '/orang-tua');
  return router;
}

/// Kartu Pengaturan bergulir; kontrol paling bawah harus digulir dulu.
Future<void> _reveal(WidgetTester t, Finder f) async {
  await t.ensureVisible(f);
  await t.pump();
}

/// Ketukan berikutnya pada pressable yang sama harus melewati cooldown 400 ms.
Future<void> _tap(WidgetTester t, TestEnv env, Finder f) async {
  env.clock.advance(const Duration(seconds: 1));
  await t.tap(f);
  await _pump(t, 250);
}

Future<void> _seedFiles(TestEnv env) async {
  await env.json.write('progress.json', {'versi': 1, 'bintang': 5});
  await env.json.write('karya/a.json', {'versi': 1});
}

Future<bool> _filesGone(TestEnv env) async =>
    await env.json.read('progress.json') == null &&
    await env.json.read('karya/a.json') == null;

void main() {
  testWidgets('hari ini: 18 menit, sisa 12 menit, +9, +1, +1', (t) async {
    await _open(t);
    expect(find.text('Area Orang Tua'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Sisa 12 menit'), findsOneWidget);
    expect(find.text('dari 30 menit hari ini'), findsOneWidget);
    expect(find.text('+9'), findsOneWidget);
    expect(find.text('+1'), findsNWidgets(2));
    expect(find.text('Si kecil'), findsOneWidget);
    expect(find.text('Usia 2–3 tahun · Pemula'), findsOneWidget);
  });

  testWidgets('waktu habis: chip Waktu habis; tanpa batas: Bebas', (t) async {
    final env = TestEnv(progress: _progress(play: 1500));
    await _open(t, env: env);
    // 25 menit dari 30: masih sisa. Naikkan pemakaian lewat batas 15.
    await _tap(t, env, find.text('15 mnt'));
    expect(find.text('Waktu habis'), findsOneWidget);
    await _tap(t, env, find.text('Bebas'));
    expect(_prefs(t).dailyLimitMinutes, isNull);
    expect(find.text('Tanpa batas harian'), findsOneWidget);
    expect(find.text('Waktu habis'), findsNothing);
  });

  testWidgets('batas Bebas disimpan sebagai null', (t) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.text('Bebas'));
    expect(_prefs(t).dailyLimitMinutes, isNull);
    expect(find.text('Tanpa batas harian'), findsOneWidget);
  });

  testWidgets('saklar musik, efek, istirahat mengubah prefs dan diam', (
    t,
  ) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    final clicksBefore = env.audio.toString();
    await _tap(t, env, find.text('Musik latar'));
    expect(_prefs(t).music, false);
    await _reveal(t, find.text('Efek suara'));
    await _tap(t, env, find.text('Efek suara'));
    expect(_prefs(t).sfx, false);
    await _reveal(t, find.text('Pengingat istirahat'));
    await _tap(t, env, find.text('Pengingat istirahat'));
    expect(_prefs(t).restReminder, false);
    await _reveal(t, find.text('Musik latar'));
    await _tap(t, env, find.text('Musik latar'));
    expect(_prefs(t).music, true);
    expect(env.audio.toString(), clicksBefore);
  });

  testWidgets('bahasa, cara baca huruf, dan usia', (t) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.text('Nama huruf'));
    expect(_prefs(t).letterMode, LetterMode.nama);
    expect(find.text('B dibaca “be”, lalu “Bola!”'), findsOneWidget);
    await _tap(t, env, find.text('6–7 thn'));
    expect(_prefs(t).ageLevel, AgeLevel.pembaca);
    expect(find.text('Usia 6–7 tahun · Pembaca'), findsOneWidget);
    await _tap(t, env, find.text('English'));
    expect(_prefs(t).lang, AppLang.en);
    expect(find.text("Parents' Corner"), findsOneWidget);
    expect(find.text('Age 6–7 · Reader'), findsOneWidget);
    expect(find.text('Delete all data'), findsOneWidget);
  });

  testWidgets('panggilan pilihan tersimpan dan mengubah gerbang', (t) async {
    final env = TestEnv(progress: _progress());
    final router = await _open(t, env: env);
    await _tap(t, env, find.text('Papi / Mami'));
    expect(_prefs(t).panggilan, PanggilanOrtu.papiMami);
    expect(env.store.getString('moci.panggilan'), 'papiMami');
    router.go(Routes.beranda);
    await _pump(t, 600);
    router.push(Routes.gerbang);
    await _pump(t, 600);
    expect(find.text('Panggil Papi atau Mami, ya!'), findsOneWidget);
    expect(
      env.tts.spoken.last.$1,
      'Ini khusus orang tua. Panggil Papi atau Mami, ya!',
    );
  });

  testWidgets('panggilan bertahan di penyimpanan yang sama', (t) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.text('Daddy / Mommy'));
    expect(_prefs(t).panggilan, PanggilanOrtu.daddyMommy);
    await pumpApp(
      t,
      env: TestEnv(store: env.store, progress: _progress()),
      initialLocation: '/',
    );
    await _pump(t, 600);
    expect(_prefs(t).panggilan, PanggilanOrtu.daddyMommy);
  });

  testWidgets('English: pilihan panggilan tampil dalam bahasa Inggris', (
    t,
  ) async {
    final env = TestEnv(lang: AppLang.en, progress: _progress());
    await _open(t, env: env);
    expect(find.text('What the child calls you'), findsOneWidget);
    await _tap(t, env, find.text('Daddy or Mommy'));
    expect(_prefs(t).panggilan, PanggilanOrtu.daddyMommy);
  });

  testWidgets('ubah nama lewat dialog, maksimal 20 huruf', (t) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.bySemanticsLabel('Ubah nama anak'));
    await t.enterText(find.byType(EditableText), 'Budi Santoso Pratama Putra');
    await t.pump();
    await _tap(t, env, find.text('Simpan'));
    expect(_prefs(t).childName, 'Budi Santoso Pratama');
    expect(find.text('Budi Santoso Pratama'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Simpan'), findsNothing);
  });

  testWidgets('dialog nama: mengetuk di luar panel tidak menutupnya', (
    t,
  ) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.bySemanticsLabel('Ubah nama anak'));
    expect(find.text('Simpan'), findsOneWidget);
    await t.tapAt(const Offset(5, 5));
    await _pump(t, 300);
    expect(find.text('Simpan'), findsOneWidget);
    await _tap(t, env, find.text('Batal'));
    expect(find.text('Simpan'), findsNothing);
    expect(_prefs(t).childName, '');
  });

  testWidgets('minggu ini: baris dan saran dari progres 7 hari', (t) async {
    final env = TestEnv(
      progress: const Progress(
        harian: {
          _today: DayStats(
            items: {
              'huruf': ['A', 'B', 'C'],
              'angka': ['1'],
            },
          ),
        },
      ),
    );
    await _open(t, env: env);
    expect(find.text('3/26'), findsOneWidget);
    expect(find.text('1/50'), findsOneWidget);
    expect(find.text('0/42'), findsOneWidget);
    // 0/42 (hewan) adalah yang terendah paling awal di urutan enum.
    expect(
      find.text('Saran: coba Dunia Hewan bersama minggu ini.'),
      findsOneWidget,
    );
  });

  testWidgets('hapus semua data: ketukan pertama tidak menghapus', (t) async {
    final env = TestEnv(childName: 'Budi', progress: _progress());
    await _seedFiles(env);
    await _open(t, env: env);
    await _tap(t, env, find.text('Hapus semua data'));
    expect(find.text('Hapus semua data?'), findsOneWidget);
    // Tombol dialog tahap pertama.
    final dialogButton = find.bySemanticsLabel('Hapus semua data');
    expect(dialogButton, findsNWidgets(2));
    await t.tap(dialogButton.last);
    await _pump(t, 300);
    expect(find.text('Yakin hapus?'), findsOneWidget);
    expect(await _filesGone(env), isFalse);
    expect(_prefs(t).childName, 'Budi');
    expect(_prefs(t).onboarded, true);
  });

  testWidgets('hapus semua data: ketukan kedua menghapus dan ke Sambutan', (
    t,
  ) async {
    final env = TestEnv(childName: 'Budi', progress: _progress());
    await _seedFiles(env);
    final router = await _open(t, env: env);
    await _tap(t, env, find.text('Hapus semua data'));
    await _tap(t, env, find.bySemanticsLabel('Hapus semua data').last);
    await _tap(t, env, find.text('Yakin hapus?'));
    await _pump(t, 600);
    expect(await _filesGone(env), isTrue);
    expect(_prefs(t).onboarded, false);
    expect(_prefs(t).childName, '');
    expect(_container(t).read(progressProvider).harian, isEmpty);
    expect(_container(t).read(playTimerProvider).secondsToday, 0);
    expect(_container(t).read(parentAccessProvider), false);
    expect(_top(router), '/sambutan');
    // Tidak ada dialog yang tertinggal.
    expect(find.text('Yakin hapus?'), findsNothing);
    expect(find.text('Hapus semua data?'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('hapus semua data: ketukan beruntun hanya sekali jalan', (
    t,
  ) async {
    final env = TestEnv(childName: 'Budi', progress: _progress());
    await _seedFiles(env);
    final router = await _open(t, env: env);
    await _tap(t, env, find.text('Hapus semua data'));
    await _tap(t, env, find.bySemanticsLabel('Hapus semua data').last);
    final sure = find.text('Yakin hapus?');
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(sure);
    await t.tap(sure, warnIfMissed: false);
    await _pump(t, 600);
    expect(t.takeException(), isNull);
    expect(_top(router), '/sambutan');
    expect(await _filesGone(env), isTrue);
  });

  testWidgets('Batal di dialog hapus: tidak ada yang berubah', (t) async {
    final env = TestEnv(childName: 'Budi', progress: _progress());
    await _seedFiles(env);
    final router = await _open(t, env: env);
    await _tap(t, env, find.text('Hapus semua data'));
    await _tap(t, env, find.text('Batal'));
    expect(find.text('Hapus semua data?'), findsNothing);
    expect(await _filesGone(env), isFalse);
    expect(_top(router), '/orang-tua');
  });

  testWidgets('tombol kembali: ke beranda, terkunci lagi', (t) async {
    final env = TestEnv(progress: _progress());
    final router = await _open(t, env: env);
    await _tap(t, env, find.bySemanticsLabel('Kunci dan kembali ke beranda'));
    expect(_top(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
    router.go('/orang-tua');
    await _pump(t);
    expect(_top(router), '/gerbang');
  });

  testWidgets('back sistem sama dengan tombol kembali', (t) async {
    final router = await _open(t, from: '/');
    await t.binding.handlePopRoute();
    await _pump(t);
    expect(_top(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
    router.go('/orang-tua');
    await _pump(t);
    expect(_top(router), '/gerbang');
  });

  testWidgets('meninggalkan /orang-tua lewat rute apa pun mencabut akses', (
    t,
  ) async {
    final router = await _open(t);
    expect(_container(t).read(parentAccessProvider), true);
    router.go('/huruf');
    await _pump(t, 600);
    expect(_container(t).read(parentAccessProvider), false);
  });

  testWidgets('tautan kebijakan privasi tersembunyi bila URL null', (t) async {
    expect(AppConfig.privacyPolicyUrl, isNull);
    expect(AppConfig.supportEmail, isNull);
    await _open(t);
    expect(find.text('Kebijakan privasi'), findsNothing);
    expect(find.text('Hubungi kami'), findsNothing);
  });

  testWidgets('badge tampil dan tidak ada overflow di 1,3x tablet', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(t);
    expect(find.text('Data hanya di perangkat ini'), findsOneWidget);
    expect(find.text('Tentang suara'), findsOneWidget);
    expect(find.text('Hapus semua data'), findsOneWidget);
    // Pil suara tidak boleh menempel atau menimpa tombol hapus.
    expect(
      t.getRect(find.text('Tentang suara')).right,
      lessThan(t.getRect(find.text('Hapus semua data')).left),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('keterangan suara: pil ada dan dialognya bisa ditutup', (
    t,
  ) async {
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    expect(find.text('Tentang suara'), findsOneWidget);
    await _tap(t, env, find.text('Tentang suara'));
    expect(find.text('Tentang suara di Moci'), findsOneWidget);
    expect(find.textContaining('text-to-speech'), findsOneWidget);
    expect(find.textContaining('Freesound.org'), findsOneWidget);
    expect(find.textContaining('CC0 (domain publik)'), findsOneWidget);
    expect(find.textContaining('LICENSES.csv'), findsOneWidget);
    await t.ensureVisible(find.text('Tutup'));
    await _pump(t);
    await _tap(t, env, find.text('Tutup'));
    expect(find.text('Tentang suara di Moci'), findsNothing);
  });

  testWidgets('English: pil suara dan dialognya', (t) async {
    final env = TestEnv(lang: AppLang.en, progress: _progress());
    await _open(t, env: env);
    expect(find.text('About sounds'), findsOneWidget);
    await _tap(t, env, find.text('About sounds'));
    expect(find.text('About the sounds in Moci'), findsOneWidget);
    expect(find.textContaining('text-to-speech'), findsOneWidget);
    expect(find.textContaining('CC0 license'), findsOneWidget);
    await t.ensureVisible(find.text('Close'));
    await _pump(t);
    await _tap(t, env, find.text('Close'));
    expect(find.text('About the sounds in Moci'), findsNothing);
  });

  testWidgets('dialog suara muat di 1,3x tanpa luber', (t) async {
    t.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
    final env = TestEnv(progress: _progress());
    await _open(t, env: env);
    await _tap(t, env, find.text('Tentang suara'));
    expect(find.text('Tentang suara di Moci'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.ensureVisible(find.text('Tutup'));
    await _pump(t);
    await _tap(t, env, find.text('Tutup'));
    expect(find.text('Tentang suara di Moci'), findsNothing);
  });

  testWidgets('HP: tidak ada pengecualian', (t) async {
    await _open(t, size: phoneSize);
    expect(find.text('Area Orang Tua'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('area sentuh minimal 64 di tablet', (t) async {
    await _open(t);
    final small = <String>[];
    for (final e in find.byType(MociPressable).evaluate()) {
      final size = t.getSize(find.byElementPredicate((x) => x == e));
      if (size.width < 63.9 || size.height < 63.9) small.add('$size');
    }
    expect(small, isEmpty);
    for (final label in ['Musik latar', 'Efek suara', 'Pengingat istirahat']) {
      final row = find.ancestor(
        of: find.text(label),
        matching: find.byType(GestureDetector),
      );
      expect(
        t.getSize(row.first).height,
        greaterThanOrEqualTo(64),
        reason: label,
      );
    }
  });

  group('perubahan batas harian tidak mengusir orang tua', () {
    testWidgets('dari Beranda: batas 15 saat 1000 detik', (t) async {
      final env = TestEnv(progress: _progress(play: 1000));
      final router = await _open(t, env: env);
      await _tap(t, env, find.text('15 mnt'));
      await _pump(t, 600);
      expect(_container(t).read(limitReachedProvider), true);
      expect(_top(router), '/orang-tua');
      expect(find.text('Area Orang Tua'), findsOneWidget);
      expect(find.text('Waktu habis'), findsOneWidget);
      // Keluar: batas tercapai, jadi mendarat di Waktu Habis.
      await _tap(t, env, find.bySemanticsLabel('Kunci dan kembali ke beranda'));
      await _pump(t, 600);
      expect(_top(router), '/habis');
    });

    testWidgets('dari Waktu Habis: batas naik ke 30 lalu keluar ke /', (
      t,
    ) async {
      const seed = 11;
      final env = TestEnv(
        progress: _progress(play: 1700),
        extraOverrides: [gateRandomProvider.overrideWithValue(Random(seed))],
      );
      // Batas bawaan 30 menit (1800 detik): 1700 detik belum habis, jadi
      // turunkan dulu ke 15 untuk mencapai Waktu Habis.
      final router = await pumpApp(t, env: env, initialLocation: '/');
      await _container(t).read(prefsProvider.notifier).setDailyLimit(15);
      await _pump(t, 600);
      expect(_top(router), '/habis');

      await t.tap(find.text('Untuk orang tua'));
      await _pump(t, 600);
      expect(_top(router), '/gerbang');
      final q = nextGateQuestion(Random(seed));
      for (final ch in '${q.answer}'.split('')) {
        await t.tap(
          find.descendant(
            of: find.byType(NumberKeypad),
            matching: find.text(ch),
          ),
        );
        await t.pump();
      }
      await _pump(t, 600);
      await t.tap(find.text('Masuk'));
      await _pump(t, 600);
      expect(_top(router), '/orang-tua');

      await _tap(t, env, find.text('30 mnt'));
      await _pump(t, 800);
      expect(_container(t).read(limitReachedProvider), false);
      expect(_top(router), '/orang-tua');
      expect(find.text('Area Orang Tua'), findsOneWidget);

      await _tap(t, env, find.bySemanticsLabel('Kunci dan kembali ke beranda'));
      await _pump(t, 600);
      expect(_top(router), '/');
      expect(_container(t).read(parentAccessProvider), false);
    });
  });

  testWidgets('simpan nama: dialog menunggu penulisan selesai', (t) async {
    final gate = GatedKeyValueStore(MemoryKeyValueStore());
    final env = TestEnv(progress: _progress(), store: gate);
    await _open(t, env: env);
    await _tap(t, env, find.bySemanticsLabel('Ubah nama anak'));
    await t.enterText(find.byType(EditableText), 'Budi');
    await t.pump();
    final hold = Completer<void>();
    gate.gerbang = hold;
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(find.text('Simpan'));
    // Lewati durasi animasi tutup dialog: kalau dialog sudah dipanggil tutup,
    // teks Simpan hilang di sini.
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Simpan'), findsOneWidget, reason: 'dialog belum tutup');
    hold.complete();
    await _pump(t, 400);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('Simpan'), findsNothing);
    expect(_prefs(t).childName, 'Budi');
  });
}
