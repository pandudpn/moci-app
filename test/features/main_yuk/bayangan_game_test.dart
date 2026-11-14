import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/bayangan_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogBayangan() => Katalog(
  item: [
    for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
      for (var i = 0; i < 8; i++) _item('$k$i', k),
  ],
);

void main() {
  test('pilihan mengikuti level usia', () {
    expect(bayanganPilihan(AgeLevel.pemula), 3);
    expect(bayanganPilihan(AgeLevel.penjelajah), 3);
    expect(bayanganPilihan(AgeLevel.pembaca), 4);
  });

  test('target selalu ada di pilihan dan tidak mengulang ronde sebelumnya', () {
    final k = _katalogBayangan();
    for (var seed = 0; seed < 6; seed++) {
      final r = buatBayangan(
        k,
        pilihan: 4,
        random: Random(seed),
        hindari: 'kucing',
      );
      expect(r.pilihan, contains(r.target));
      expect(r.target, isNot('kucing'));
      expect(r.pilihan.toSet(), hasLength(4));
    }
  });

  test('pilihan salah tidak menambah skor', () {
    final g = BayanganGame(
      katalog: _katalogBayangan(),
      usia: AgeLevel.pemula,
      random: Random(5),
    );
    final salah = g.ronde.pilihan.firstWhere((id) => id != g.ronde.target);
    expect(g.pilih(salah), isFalse);
    expect(g.salah, contains(salah));
    expect(g.skor, 0);
    expect(g.selesai, isFalse);
  });

  test('enam jawaban benar menyelesaikan permainan', () {
    final g = BayanganGame(
      katalog: _katalogBayangan(),
      usia: AgeLevel.pemula,
      random: Random(5),
    );
    for (var i = 0; i < 6; i++) {
      expect(g.pilih(g.ronde.target), isTrue);
      g.lanjut();
    }
    expect(g.skor, 6);
    expect(g.selesai, isTrue);
  });
}
