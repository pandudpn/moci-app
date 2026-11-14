import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/buah_sayur/buah_game.dart';

import '../../helpers/katalog.dart';

void main() {
  final katalog = katalogUji();

  test('katalog memuat 21 buah dan 14 sayur', () {
    expect(katalog.byKategori('buah').length, 21);
    expect(katalog.byKategori('sayur').length, 14);
  });

  test('soal memuat target dan dua pengecoh berbeda', () {
    final soal = buatBuahSoal(katalog, random: Random(3));
    expect(soal.pilihan.length, 3);
    expect(soal.pilihan.map((e) => e.id), contains(soal.target.id));
    expect(soal.pilihan.map((e) => e.id).toSet().length, 3);
    expect(
      soal.pilihan.every((e) => e.kategori == 'buah' || e.kategori == 'sayur'),
      isTrue,
    );
  });

  test('kategori menyaring target dan pengecoh', () {
    for (var seed = 0; seed < 20; seed++) {
      final soal = buatBuahSoal(
        katalog,
        kategori: 'sayur',
        random: Random(seed),
      );
      expect(
        soal.pilihan.every((e) => e.kategori == 'sayur'),
        isTrue,
        reason: '$seed',
      );
    }
  });

  test('target dan hindari dihormati', () {
    final soal = buatBuahSoal(katalog, target: 'apel', random: Random(1));
    expect(soal.target.id, 'apel');
    for (var seed = 0; seed < 20; seed++) {
      expect(
        buatBuahSoal(
          katalog,
          hindari: 'pisang',
          random: Random(seed),
        ).target.id,
        isNot('pisang'),
      );
    }
  });

  test('jawaban hanya benar untuk target', () {
    final soal = buatBuahSoal(katalog, target: 'apel', random: Random(1));
    final salah = soal.pilihan.firstWhere((e) => e.id != 'apel');
    expect(jawabanBuah(soal.target, soal.target), isTrue);
    expect(jawabanBuah(soal.target, salah), isFalse);
  });

  test('ukuran soal mengecil untuk nama panjang', () {
    expect(ukuranSoalBuah('APEL'), 44);
    expect(ukuranSoalBuah('SEMANGKA'), 44);
    expect(ukuranSoalBuah('PERSIK PANJANG'), 36);
    expect(ukuranKartuBuah('Stroberi'), 22);
    expect(ukuranKartuBuah('Strawberry'), 22);
    expect(ukuranKartuBuah('Stroberi Besar'), 18);
  });
}
