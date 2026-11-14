import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/cocokkan_game.dart';
import 'package:moci/features/main_yuk/main_yuk_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogBuah([int n = 6]) =>
    Katalog(item: [for (var i = 0; i < n; i++) _item('b$i', 'buah')]);

CocokkanRonde _rondeTetap() => const CocokkanRonde(
  tema: MainYukTema.buah,
  kiri: ['a', 'b', 'c'],
  kanan: ['c', 'a', 'b'],
);

void main() {
  test('pasangan mengikuti level usia', () {
    expect(cocokkanPasangan(AgeLevel.pemula), 3);
    expect(cocokkanPasangan(AgeLevel.penjelajah), 4);
    expect(cocokkanPasangan(AgeLevel.pembaca), 5);
  });

  test('ronde berisi pasangan unik dan kolom kanan teracak', () {
    final r = buatCocokkan(
      _katalogBuah(),
      pasangan: 4,
      tema: MainYukTema.buah,
      random: Random(7),
    );
    expect(r.kiri, hasLength(4));
    expect(r.kanan.toSet(), r.kiri.toSet());
    expect(r.kanan, isNot(r.kiri));
  });

  test('ketuk dua kartu sama menjadi cocok', () {
    final s = CocokkanSesi(_rondeTetap());
    expect(s.ketuk(CocokkanSisi.kiri, 0), CocokkanStep.pilih);
    expect(s.ketuk(CocokkanSisi.kanan, 1), CocokkanStep.cocok);
    expect(s.cocok, {0: 1});
    expect(s.sisiDipilih, isNull);
  });

  test('kartu yang sudah cocok diabaikan', () {
    final s = CocokkanSesi(_rondeTetap())
      ..ketuk(CocokkanSisi.kiri, 0)
      ..ketuk(CocokkanSisi.kanan, 1);
    expect(s.ketuk(CocokkanSisi.kiri, 0), CocokkanStep.abaikan);
    expect(s.ketuk(CocokkanSisi.kanan, 1), CocokkanStep.abaikan);
  });

  test('pasangan salah mengosongkan pilihan', () {
    final s = CocokkanSesi(_rondeTetap());
    s
      ..ketuk(CocokkanSisi.kiri, 0)
      ..ketuk(CocokkanSisi.kanan, 0);
    expect(s.cocok, isEmpty);
    expect(s.sisiDipilih, isNull);
  });

  test('pasangan terakhir menyelesaikan sesi', () {
    final ronde = _rondeTetap();
    final s = CocokkanSesi(ronde);
    for (var i = 0; i < ronde.jumlah; i++) {
      final j = ronde.kanan.indexOf(ronde.kiri[i]);
      final step = s.ketuk(CocokkanSisi.kiri, i);
      final akhir = s.ketuk(CocokkanSisi.kanan, j);
      if (i < ronde.jumlah - 1) {
        expect(step, CocokkanStep.pilih);
        expect(akhir, CocokkanStep.cocok);
      } else {
        expect(akhir, CocokkanStep.selesai);
      }
    }
    expect(s.selesai, isTrue);
  });
}
