import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/router.dart';
import 'package:moci/features/orang_tua/gerbang_game.dart';
import 'package:moci/features/orang_tua/gerbang_screen.dart';
import 'package:moci/widgets/number_keypad.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

const _seed = 11;

/// Soal pertama dan kedua untuk [_seed], sama dengan yang dihasilkan layar.
(GateQuestion, GateQuestion) _questions() {
  final r = Random(_seed);
  final q1 = nextGateQuestion(r);
  return (q1, nextGateQuestion(r, previous: q1));
}

Finder _key(String digit) =>
    find.descendant(of: find.byType(NumberKeypad), matching: find.text(digit));

Future<void> _type(WidgetTester t, int number) async {
  for (final ch in '$number'.split('')) {
    await t.tap(_key(ch));
    await t.pump();
  }
}

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

TestEnv _env() => TestEnv(
  extraOverrides: [gateRandomProvider.overrideWithValue(Random(_seed))],
);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Router<Object>)));

String _topPath(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  Size size = tabletSize,
  String location = '/gerbang',
}) async {
  final router = await pumpApp(
    t,
    env: env ?? _env(),
    size: size,
    initialLocation: location,
  );
  await _settle(t);
  return router;
}

/// Membuka Beranda lalu mendorong `/gerbang`; hasil pop ada di future.
Future<(GoRouter, Future<bool?>)> _openPushed(WidgetTester t) async {
  final router = await _open(t, location: '/');
  final result = router.push<bool>('/gerbang');
  await _settle(t);
  return (router, result);
}

void main() {
  testWidgets('narasi pembuka dibacakan pertama', (t) async {
    final env = _env();
    await _open(t, env: env);
    expect(
      env.tts.spoken.first.$1,
      'Ini khusus orang tua. Panggil Ayah atau Bunda, ya!',
    );
  });

  testWidgets('soal tampil dengan isian kosong', (t) async {
    await _open(t);
    final (q, _) = _questions();
    expect(find.text('${q.a} × ${q.b} ='), findsOneWidget);
    expect(find.text('Ketuk angka di sebelah kanan.'), findsOneWidget);
    expect(find.text('Masuk'), findsNothing);
  });

  testWidgets('label aksesibilitas soal memakai gerbangTimes', (t) async {
    await _open(t);
    final (q, _) = _questions();
    expect(find.bySemanticsLabel('${q.a} kali ${q.b}'), findsOneWidget);
  });

  testWidgets('jawaban salah: pesan, lalu soal baru dengan pesan retry', (
    t,
  ) async {
    final env = _env();
    await _open(t, env: env);
    final (q1, q2) = _questions();
    await _type(t, q1.answer + 1);
    expect(find.text('Belum tepat.'), findsOneWidget);
    expect(find.text('${q1.a} × ${q1.b} ='), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1000));
    expect(find.text('${q2.a} × ${q2.b} ='), findsOneWidget);
    expect(find.text('Coba soal baru ini, ya.'), findsOneWidget);
    expect(find.text('Belum tepat.'), findsNothing);
    // Tanpa bunyi salah: hanya narasi pembuka.
    expect(env.tts.spoken, hasLength(1));
  });

  testWidgets('tanpa batas percobaan', (t) async {
    await _open(t);
    var (q, _) = _questions();
    for (var i = 0; i < 3; i++) {
      await _type(t, q.answer + 1);
      await t.pump(const Duration(milliseconds: 1000));
      expect(find.text('Coba soal baru ini, ya.'), findsOneWidget);
      final text = t.widget<Text>(find.textContaining(' × ')).data!;
      final parts = text.replaceAll(' =', '').split(' × ');
      q = GateQuestion(int.parse(parts[0]), int.parse(parts[1]));
    }
  });

  testWidgets('Ganti soal di jendela jawaban salah membatalkan soal retry', (
    t,
  ) async {
    await _open(t);
    final (q1, q2) = _questions();
    await _type(t, q1.answer + 1);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Ganti soal'));
    await t.pump();
    expect(find.text('${q2.a} × ${q2.b} ='), findsOneWidget);
    expect(find.text('Ketuk angka di sebelah kanan.'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1500));
    // Timer lama tidak boleh mengganti soal segar atau memunculkan retry.
    expect(find.text('${q2.a} × ${q2.b} ='), findsOneWidget);
    expect(find.text('Coba soal baru ini, ya.'), findsNothing);
    expect(find.text('Belum tepat.'), findsNothing);
  });

  testWidgets('meninggalkan layar di jendela salah membatalkan timer', (
    t,
  ) async {
    final (router, result) = await _openPushed(t);
    final (q1, _) = _questions();
    await _type(t, q1.answer + 1);
    await t.tap(find.text('Batal'));
    await _settle(t);
    expect(await result, false);
    await t.pump(const Duration(milliseconds: 1500));
    expect(t.takeException(), isNull);
    expect(_topPath(router), '/');
  });

  testWidgets('jawaban benar memunculkan Masuk; hapus mengunci lagi', (
    t,
  ) async {
    await _open(t);
    final (q, _) = _questions();
    await _type(t, q.answer);
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Benar! Silakan masuk.'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Hapus'));
    await t.pump();
    expect(find.text('Masuk'), findsNothing);
    expect(find.text('Benar! Silakan masuk.'), findsNothing);
  });

  testWidgets('Masuk dengan lanjut: izin diberikan dan membuka tujuan', (
    t,
  ) async {
    final router = await _open(
      t,
      location: Routes.gerbangLanjut(Routes.orangTua),
    );
    final (q, _) = _questions();
    expect(_container(t).read(parentAccessProvider), false);
    await _type(t, q.answer);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Masuk'));
    await _settle(t);
    expect(_container(t).read(parentAccessProvider), true);
    expect(_topPath(router), '/orang-tua');
  });

  testWidgets('Masuk tanpa lanjut: pop(true)', (t) async {
    final (router, result) = await _openPushed(t);
    final (q, _) = _questions();
    await _type(t, q.answer);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Masuk'));
    await _settle(t);
    expect(await result, true);
    expect(_container(t).read(parentAccessProvider), true);
    expect(_topPath(router), '/');
  });

  testWidgets('Masuk tanpa lanjut menjaga tumpukan push pemanggil', (t) async {
    final router = await _open(t, location: '/');
    router.push<void>('/hewan');
    await _settle(t);
    final result = router.push<bool>('/gerbang');
    await _settle(t);
    final (q, _) = _questions();
    await _type(t, q.answer);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Masuk'));
    await _settle(t);
    expect(await result, true);
    expect(_topPath(router), '/hewan');
    expect(router.canPop(), true);
    router.pop();
    await _settle(t);
    expect(_topPath(router), '/');
  });

  testWidgets('Masuk dengan lanjut dari rute dorong menjaga Beranda', (
    t,
  ) async {
    final router = await _open(t, location: '/');
    router.push<void>(Routes.gerbangLanjut(Routes.orangTua));
    await _settle(t);
    final (q, _) = _questions();
    await _type(t, q.answer);
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Masuk'));
    await _settle(t);
    expect(_topPath(router), '/orang-tua');
    expect(router.canPop(), true);
  });

  testWidgets('Batal tanpa layar untuk di-pop kembali ke Beranda', (t) async {
    final router = await _open(
      t,
      location: Routes.gerbangLanjut(Routes.orangTua),
    );
    await t.tap(find.text('Batal'));
    await _settle(t);
    expect(_topPath(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
  });

  testWidgets('Batal pada rute dorong: pop(false)', (t) async {
    final (router, result) = await _openPushed(t);
    await t.tap(find.text('Batal'));
    await _settle(t);
    expect(await result, false);
    expect(_topPath(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
  });

  testWidgets('back sistem sama dengan Batal (rute dorong)', (t) async {
    final (router, result) = await _openPushed(t);
    await t.binding.handlePopRoute();
    await _settle(t);
    expect(await result, false);
    expect(_topPath(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
  });

  testWidgets('back sistem tanpa layar untuk di-pop: ke Beranda', (t) async {
    final router = await _open(
      t,
      location: Routes.gerbangLanjut(Routes.orangTua),
    );
    await t.binding.handlePopRoute();
    await _settle(t);
    expect(_topPath(router), '/');
    expect(_container(t).read(parentAccessProvider), false);
  });

  testWidgets('semua tombol angka berukuran 96 × 84', (t) async {
    await _open(t);
    final keys = find.descendant(
      of: find.byType(NumberKeypad),
      matching: find.byType(MociPressable),
    );
    expect(keys, findsNWidgets(11)); // 0–9 dan hapus
    for (final e in keys.evaluate()) {
      expect(t.getSize(find.byWidget(e.widget)), const Size(96, 84));
    }
  });

  for (final (name, size, min) in [
    ('tablet', tabletSize, 64.0),
    ('HP', phoneSize, 56.0),
  ]) {
    testWidgets('area sentuh non-papan-angka minimal $min di $name', (t) async {
      await _open(t, size: size);
      final (q, _) = _questions();
      await _type(t, q.answer);
      await t.pump(const Duration(milliseconds: 600));
      final others = find.byWidgetPredicate(
        (w) => w is MociPressable,
        description: 'pressable',
      );
      var checked = 0;
      for (final e in others.evaluate()) {
        final inKeypad = find
            .descendant(
              of: find.byType(NumberKeypad),
              matching: find.byWidget(e.widget),
            )
            .evaluate()
            .isNotEmpty;
        if (inKeypad) continue;
        final r = t.getRect(find.byWidget(e.widget));
        expect(r.width, greaterThanOrEqualTo(min - 0.5));
        expect(r.height, greaterThanOrEqualTo(min - 0.5));
        checked++;
      }
      expect(checked, 4); // Batal, bantuan, Ganti soal, Masuk
    });
  }
}
