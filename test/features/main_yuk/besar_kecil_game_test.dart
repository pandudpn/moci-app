import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/besar_kecil_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogBesar() => Katalog(
  item: [
    for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
      for (var i = 0; i < 4; i++) _item('$k$i', k),
  ],
);

void main() {
  test('tiga ukuran, empat untuk pembaca', () {
    expect(ukuranBesarKecil(AgeLevel.pemula), [120, 200, 300]);
    expect(ukuranBesarKecil(AgeLevel.penjelajah), [120, 200, 300]);
    expect(ukuranBesarKecil(AgeLevel.pembaca), [150, 200, 250, 300]);
  });

  test('pertanyaan bergantian besar dan kecil', () {
    final g = BesarKecilGame(
      katalog: _katalogBesar(),
      usia: AgeLevel.pemula,
      random: Random(1),
    );
    final pertama = g.ronde.termuda;
    final kedua = buatBesarKecil(
      _katalogBesar(),
      usia: AgeLevel.pemula,
      tanyaSebelumnya: pertama,
      random: Random(2),
    );
    expect(kedua.termuda, isNot(pertama));
  });

  test('jawaban adalah ukuran terbesar atau terkecil', () {
    final g = BesarKecilGame(
      katalog: _katalogBesar(),
      usia: AgeLevel.pembaca,
      random: Random(3),
    );
    expect(g.ronde.jawaban, g.ronde.ukuran.reduce(g.ronde.termuda ? max : min));
  });

  test('enam jawaban benar menyelesaikan permainan', () {
    final g = BesarKecilGame(
      katalog: _katalogBesar(),
      usia: AgeLevel.pemula,
      random: Random(1),
    );
    for (var i = 0; i < 6; i++) {
      final idx = g.ronde.ukuran.indexOf(g.ronde.jawaban);
      expect(g.pilih(idx), isTrue);
      g.lanjut();
    }
    expect(g.skor, 6);
    expect(g.selesai, isTrue);
  });

  test('gambar baru tidak mengulang benda sebelumnya', () {
    final g = BesarKecilGame(
      katalog: _katalogBesar(),
      usia: AgeLevel.pemula,
      random: Random(6),
    );
    final lama = g.ronde.gambar;
    g.lanjut();
    expect(g.ronde.gambar, isNot(lama));
  });
}
