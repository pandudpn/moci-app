import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/warna/warna_game.dart';
import 'package:moci/features/warna/warna_screen.dart';

import '../../helpers/harness.dart';
import '../../helpers/katalog.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

WarnaSet _setMerah() => buatWarnaSet(katalogUji(), 'merah', Random(7));

TestEnv _env() =>
    TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);

Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/warna',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('membuka: instruksi, hitungan, 11 chip, 12 kartu', (t) async {
    final env = _env();
    await _open(t, env: env);
    expect(find.text('Warna'), findsOneWidget);
    expect(find.text('MERAH'), findsWidgets);
    expect(find.text('0 / ${_setMerah().total}'), findsOneWidget);
    expect(find.byKey(WarnaScreen.chipKey('merah')), findsOneWidget);
    expect(find.byKey(WarnaScreen.chipKey('abu')), findsOneWidget);
    expect(
      find.byKey(WarnaScreen.kartuKey(_setMerah().kartu.first.id)),
      findsOneWidget,
    );
    expect(env.tts.spoken.map((e) => e.$1), [
      'Sentuh semua yang berwarna',
      'merah',
    ]);
  });

  testWidgets('kartu target menambah hitungan dan mengabaikan ketukan kedua', (
    t,
  ) async {
    final env = _env();
    final set = _setMerah();
    final target = set.kartu.firstWhere((k) => k.warna == 'merah');
    await _open(t, env: env);
    await t.tap(find.byKey(WarnaScreen.kartuKey(target.id)));
    await t.pump();
    expect(find.text('1 / ${set.total}'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.byKey(WarnaScreen.kartuKey(target.id)));
    await t.pump();
    expect(find.text('1 / ${set.total}'), findsOneWidget);
  });

  testWidgets('kartu warna lain tidak menambah hitungan', (t) async {
    final env = _env();
    final set = _setMerah();
    final lain = set.kartu.firstWhere((k) => k.warna != 'merah');
    await _open(t, env: env);
    await t.tap(find.byKey(WarnaScreen.kartuKey(lain.id)));
    await t.pump();
    expect(find.text('0 / ${set.total}'), findsOneWidget);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Bukan yang ini. Cari yang', 'merah']),
    );
  });

  testWidgets('semua target ketemu menampilkan bilah dan warna lain', (
    t,
  ) async {
    final env = _env();
    final set = _setMerah();
    await _open(t, env: env);
    for (final kartu in set.kartu.where((k) => k.warna == 'merah')) {
      await t.tap(find.byKey(WarnaScreen.kartuKey(kartu.id)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Semua yang merah ketemu!'), findsOneWidget);
    expect(find.byKey(WarnaScreen.nextColorKey), findsOneWidget);
    await t.tap(find.byKey(WarnaScreen.nextColorKey));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('ORANYE'), findsWidgets);
    expect(find.textContaining('0 / '), findsOneWidget);
  });

  testWidgets('gambar baru mengosongkan hitungan tanpa ganti warna', (t) async {
    final env = _env();
    await _open(t, env: env);
    await t.tap(find.byKey(WarnaScreen.newSetKey));
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('MERAH'), findsWidgets);
    expect(find.textContaining('0 / '), findsOneWidget);
  });

  testWidgets('sebelas chip warna muat', (t) async {
    final env = _env();
    await _open(t, env: env);
    expect(t.takeException(), isNull);
    for (final warna in katalogUji().warna) {
      expect(
        find.byKey(WarnaScreen.chipKey(warna.id)),
        findsOneWidget,
        reason: warna.id,
      );
    }
  });

  testWidgets('ganti bahasa mengganti nama warna dan chip', (t) async {
    final env = _env();
    await _open(t, env: env);
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('RED'), findsWidgets);
    expect(find.text('Pick a color'), findsOneWidget);
    expect(find.byKey(WarnaScreen.chipKey('merah')), findsOneWidget);
  });
}
