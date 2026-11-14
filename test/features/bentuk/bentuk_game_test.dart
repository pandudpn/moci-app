import 'dart:math';

import 'package:moci/core/content/katalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/bentuk/bentuk_game.dart';

import '../../helpers/katalog.dart';

void main() {
  final katalog = katalogUji();

  test('katalog memuat sepuluh bentuk', () {
    expect(katalog.bentuk.length, 10);
  });

  test('pool dan jumlah pilihan per level usia', () {
    expect(bentukPool(AgeLevel.pemula), [0, 1, 2, 6, 7]);
    expect(bentukPool(AgeLevel.penjelajah), [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(bentukPool(AgeLevel.pembaca), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(bentukPilihan(AgeLevel.pemula), 3);
    expect(bentukPilihan(AgeLevel.penjelajah), 4);
    expect(bentukPilihan(AgeLevel.pembaca), 6);
  });

  test('chip mengikuti jenis bentuk', () {
    BentukEntry cari(String id) => katalog.bentuk.firstWhere((b) => b.id == id);
    expect(chipBentuk(cari('persegi')).map((c) => (c.key, c.jumlah)), [
      ('bentukSisi', 4),
      ('bentukSudut', 4),
    ]);
    expect(chipBentuk(cari('bintang')).single.jumlah, 5);
    expect(chipBentuk(cari('bintang')).single.key, 'bentukUjung');
    expect(chipBentuk(cari('hati')).single.key, 'bentukSayang');
    expect(chipBentuk(cari('lingkaran')).single.key, 'bentukTanpaSudut');
  });

  test('ronde memuat target dan pilihan sesuai level', () {
    for (final level in AgeLevel.values) {
      final ronde = buatBentukRonde(katalog, level: level, random: Random(5));
      expect(ronde.opsi.length, bentukPilihan(level), reason: level.name);
      expect(ronde.opsi.toSet().length, ronde.opsi.length);
      expect(ronde.opsi, contains(ronde.target));
      expect(ronde.warna.length, ronde.opsi.length);
      expect(ronde.warna.map((w) => w.warna).toSet().length, ronde.opsi.length);
      expect(ronde.opsi.every(bentukPool(level).contains), isTrue);
    }
  });

  test('target sebelumnya tidak dipilih lagi', () {
    for (var seed = 0; seed < 50; seed++) {
      final ronde = buatBentukRonde(
        katalog,
        level: AgeLevel.pemula,
        random: Random(seed),
        hindari: 2,
      );
      expect(ronde.target, isNot(2), reason: '$seed');
    }
  });

  test('pertanyaan memakai nama huruf kecil', () {
    final persegi = katalog.bentuk[1];
    expect(pertanyaanBentuk(persegi, AppLang.id), 'Mana persegi?');
    expect(pertanyaanBentuk(persegi, AppLang.en), 'Where is the square?');
  });
}
