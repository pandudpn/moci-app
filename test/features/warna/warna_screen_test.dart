import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/audio/sfx.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/warna/warna_game.dart';
import 'package:moci/features/warna/warna_screen.dart';

import '../../helpers/harness.dart';
import '../../helpers/katalog.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

WarnaSet _setMerah() => buatWarnaSet(katalogUji(), 'merah', Random(7));

TestEnv _env({bool suara = false}) => TestEnv(
  assets: suara ? {for (final s in Sfx.values) s.asset} : const {},
  extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))],
);

Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/warna',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

Color _warnaHex(String hex) =>
    Color(0xFF000000 | int.parse(hex.replaceFirst('#', ''), radix: 16));

WarnaEntry _entriWarna(String id) =>
    katalogUji().warna.firstWhere((w) => w.id == id);

/// Warna isi kartu bentuk yang sedang dilukis; null untuk kartu gambar.
Color? _lukisan(WidgetTester t, String id) {
  final cat = find.descendant(
    of: find.byKey(WarnaScreen.kartuKey(id)),
    matching: find.byType(CustomPaint),
  );
  for (final lukis in t.widgetList<CustomPaint>(cat)) {
    final painter = lukis.painter;
    if (painter == null) continue;
    try {
      final fill = (painter as dynamic).fill;
      if (fill is Color) return fill;
    } on NoSuchMethodError {
      continue;
    }
  }
  return null;
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

  testWidgets('kartu bentuk dilukis dengan warna kartunya sendiri', (t) async {
    final set = _setMerah();
    await _open(t, env: _env());
    final bentuk = set.kartu.where((k) => k.bentuk != null).toList();
    expect(bentuk, isNotEmpty);
    for (final kartu in bentuk) {
      expect(
        _lukisan(t, kartu.id),
        _warnaHex(_entriWarna(kartu.warna).hex),
        reason: kartu.id,
      );
    }
  });

  testWidgets('kartu yang tampak merah tidak pernah dianggap salah', (t) async {
    final set = _setMerah();
    final env = _env(suara: true);
    await _open(t, env: env);
    final merah = _warnaHex(_entriWarna('merah').hex);
    final tampakMerah = [
      for (final kartu in set.kartu)
        if (kartu.gambarId != null
            ? kartu.warna == 'merah'
            : _lukisan(t, kartu.id) == merah)
          kartu.id,
    ];
    expect(tampakMerah.length, set.total);
    for (final id in tampakMerah) {
      await t.tap(find.byKey(WarnaScreen.kartuKey(id)));
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
    }
    expect(
      env.audio.plays.where((p) => p.asset == Sfx.salahLembut.asset),
      isEmpty,
    );
    expect(find.text('${set.total} / ${set.total}'), findsOneWidget);
  });

  testWidgets('kartu bukan merah memutar efek salah lembut', (t) async {
    final set = _setMerah();
    final env = _env(suara: true);
    await _open(t, env: env);
    final lain = set.kartu.firstWhere((k) => k.warna != 'merah');
    expect(env.audio.preloaded, contains(Sfx.salahLembut.asset));
    await t.tap(find.byKey(WarnaScreen.kartuKey(lain.id)));
    await t.pump();
    expect(
      env.audio.plays.where((p) => p.asset == Sfx.salahLembut.asset).length,
      1,
    );
  });
}
