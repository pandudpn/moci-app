import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/hewan/hewan_isi.dart';

import '../../helpers/katalog.dart';

void main() {
  final katalog = katalogUji();

  test('semua hewan berurutan dan kelompok menyaring', () {
    expect(hewanTampil(katalog).length, 42);
    expect(hewanTampil(katalog).first.id, 'kucing');
    expect(
      hewanTampil(
        katalog,
        kelompok: HewanKelompok.air,
      ).map((e) => e.id).toList(),
      ['ikan', 'lumba', 'paus', 'kepiting', 'gurita', 'ubur', 'pinguin'],
    );
    expect(hewanTampil(katalog, kelompok: HewanKelompok.reptil).length, 5);
  });

  test('id tidak dikenal kembali ke hewan pertama', () {
    expect(hewanById(katalog, 'tidak-ada')!.id, 'kucing');
    expect(hewanById(katalog, 'singa')!.id, 'singa');
  });

  test('path suara hewan dari id', () {
    expect(pathSuaraHewan('kucing'), 'assets/audio/hewan/kucing.m4a');
  });

  test('nama dan bunyi panjang mengecil', () {
    expect(ukuranNamaHewan('Kucing'), 52);
    expect(ukuranNamaHewan('Orangutan'), 44);
    expect(ukuranNamaHewan('Komodo Dragon'), 38);
    expect(ukuranBunyiHewan('Meong!'), 40);
    expect(ukuranBunyiHewan('Blub blub!'), 32);
    expect(ukuranBunyiHewan('Cock-a-doodle-doo!'), 26);
  });

  test('gambar setiap item sama dengan id', () {
    for (final item in katalog.item) {
      expect(item.gambar, 'illustrations/${item.id}.svg', reason: item.id);
    }
  });

  test('fakta dan bunyi mengikuti bahasa', () {
    final kucing = hewanById(katalog, 'kucing')!;
    expect(bunyiHewan(kucing, AppLang.id), 'Meong!');
    expect(bunyiHewan(kucing, AppLang.en), 'Meow!');
    expect(faktaHewan(kucing, AppLang.en), contains('Cats'));
  });
}
