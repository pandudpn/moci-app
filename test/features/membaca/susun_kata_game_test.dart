import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/membaca/susun_kata/susun_kata_game.dart';

const _kata = [
  KataEntry(item: 'bola', kata: 'Bola', suku: ['bo', 'la']),
  KataEntry(item: 'buku', kata: 'Buku', suku: ['bu', 'ku']),
  KataEntry(item: 'kereta', kata: 'Kereta', suku: ['ke', 're', 'ta']),
  KataEntry(item: 'sepatu', kata: 'Sepatu', suku: ['se', 'pa', 'tu']),
];

void _selesaikan(SusunKataGame g) {
  for (final suku in g.ronde.entry.suku) {
    if (!g.ronde.benar) g.ketuk(g.ronde.tiles.indexOf(suku));
  }
}

void main() {
  test('level 2: empat keping, dua di antaranya pengganggu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final r = g.ronde;
    expect(r.entry.level, 2);
    expect(r.tiles.length, 4);
    expect(r.tiles.toSet().length, 4);
    expect(r.tiles, containsAll(r.entry.suku));
    expect(r.slots.length, 2);
  });
  test('level 3: empat keping dengan satu pengganggu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7), level: 3);
    expect(g.ronde.entry.level, 3);
    expect(g.ronde.tiles.length, 4);
    expect(g.ronde.slots.length, 3);
  });
  test('mengetuk berurutan menyelesaikan kata', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    _selesaikan(g);
    expect(g.ronde.benar, isTrue);
    expect(g.ronde.tersusun, g.ronde.target);
  });
  test('keping terpakai tidak bisa dipakai lagi', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final i = g.ronde.tiles.indexOf(g.ronde.entry.suku.first);
    expect(g.ketuk(i), SusunKetuk.mengisi);
    expect(g.ketuk(i), SusunKetuk.dipakai);
  });
  test('keping salah mengisi lalu kosongkan', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final target = g.ronde.entry.suku.toSet();
    final salah = g.ronde.tiles.indexWhere((s) => !target.contains(s));
    expect(g.ketuk(salah), SusunKetuk.mengisi);
    expect(
      g.ketuk(g.ronde.tiles.indexOf(g.ronde.entry.suku.first)),
      SusunKetuk.salah,
    );
    expect(g.ronde.lengkap, isTrue);
    g.kosongkan();
    expect(g.ronde.slots, [null, null]);
    expect(g.ronde.entry.kata, isNotEmpty);
  });
  test('lima ronde berakhir dan kata tidak berulang berurutan', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final urutan = <String>[g.ronde.entry.kata];
    for (var i = 0; i < 4; i++) {
      _selesaikan(g);
      g.berikutnya();
      urutan.add(g.ronde.entry.kata);
    }
    expect(g.nomor, 5);
    expect(g.levelSelesai, isFalse);
    for (var i = 1; i < urutan.length; i++) {
      expect(urutan[i], isNot(urutan[i - 1]));
    }
    _selesaikan(g);
    g.berikutnya();
    expect(g.levelSelesai, isTrue);
    expect(g.nomor, 5);
  });
  test('ganti level memulai ulang dari ronde satu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    _selesaikan(g);
    g.berikutnya();
    expect(g.nomor, 2);
    g.gantiLevel(3);
    expect(g.nomor, 1);
    expect(g.ronde.entry.level, 3);
    expect(g.levelSelesai, isFalse);
  });
  test('kolam level kosong atau level asing ditolak', () {
    const duaSaja = [
      KataEntry(item: 'bola', kata: 'Bola', suku: ['bo', 'la']),
    ];
    expect(
      () => SusunKataGame(kata: duaSaja, random: Random(1), level: 3),
      throwsArgumentError,
    );
    expect(
      () => SusunKataGame(kata: _kata, random: Random(1), level: 4),
      throwsArgumentError,
    );
  });
}
