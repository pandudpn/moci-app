import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/puzzle_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogPuzzle() => Katalog(
  item: [
    for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
      for (var i = 0; i < 4; i++) _item('$k$i', k),
  ],
);

void main() {
  test('kisi mengikuti level usia', () {
    expect(puzzleKisi(AgeLevel.pemula), (kolom: 2, baris: 2));
    expect(puzzleKisi(AgeLevel.penjelajah), (kolom: 3, baris: 2));
    expect(puzzleKisi(AgeLevel.pembaca), (kolom: 3, baris: 3));
  });

  test('urutan berisi semua keping sekali', () {
    final g = PuzzleGame(
      katalog: _katalogPuzzle(),
      usia: AgeLevel.pembaca,
      random: Random(9),
    );
    expect(g.urutan, hasLength(9));
    expect(g.urutan.toSet(), hasLength(9));
  });

  test('keping yang salah tidak terpasang', () {
    final g = PuzzleGame(
      katalog: _katalogPuzzle(),
      usia: AgeLevel.pemula,
      random: Random(2),
    );
    final k = g.urutan.first;
    expect(g.pilih(k), PuzzleStep.pilih);
    expect(g.letak((k + 1) % g.jumlah), PuzzleStep.salah);
    expect(g.terpasang, isEmpty);
    expect(g.dipilih, k);
  });

  test('keping yang tepat terpasang dan selesai saat keping terakhir', () {
    final g = PuzzleGame(
      katalog: _katalogPuzzle(),
      usia: AgeLevel.pemula,
      random: Random(2),
    );
    for (var i = 0; i < 4; i++) {
      g.pilih(i);
      expect(g.letak(i), i == 3 ? PuzzleStep.selesai : PuzzleStep.pas);
    }
    expect(g.selesai, isTrue);
  });

  test('gambar baru tidak memakai gambar sebelumnya', () {
    final g = PuzzleGame(
      katalog: _katalogPuzzle(),
      usia: AgeLevel.pemula,
      random: Random(4),
    );
    final lama = g.gambar;
    g.ulang();
    expect(g.gambar, isNot(lama));
    expect(g.terpasang, isEmpty);
  });
}
