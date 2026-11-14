import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/warna/warna_game.dart';

import '../../helpers/katalog.dart';

void main() {
  final katalog = katalogUji();

  test('katalog memuat 11 warna dan 81 item bertanda warna', () {
    expect(katalog.warna.length, 11);
    expect(katalog.item.where((i) => i.warna != null).length, 81);
  });

  test('set 12 kartu dengan 4–5 target', () {
    for (final warna in katalog.warna) {
      final set = buatWarnaSet(katalog, warna.id, Random(7));
      expect(set.kartu.length, 12, reason: warna.id);
      expect(set.kartu.map((k) => k.id).toSet().length, 12, reason: warna.id);
      expect(set.total, inInclusiveRange(4, 5), reason: warna.id);
      expect(set.kartu.where((k) => k.warna == warna.id).length, set.total);
      for (final kartu in set.kartu.where((k) => k.warna != warna.id)) {
        expect(kartu.warna, isNot(warna.id));
      }
    }
  });

  test('warna dengan sedikit gambar tetap punya empat target', () {
    final set = buatWarnaSet(katalog, 'hitam', Random(1));
    expect(set.total, inInclusiveRange(4, 5));
    expect(
      set.kartu.where((k) => k.bentuk != null && k.warna == 'hitam'),
      isNotEmpty,
    );
  });

  test('kartu gambar memakai id item yang warnanya cocok', () {
    final set = buatWarnaSet(katalog, 'merah', Random(9));
    for (final kartu in set.kartu.where((k) => k.gambarId != null)) {
      expect(katalog.byId(kartu.gambarId!)!.warna, kartu.warna);
    }
  });

  test('nama kartu mengikuti bahasa', () {
    final set = buatWarnaSet(katalog, 'merah', Random(9));
    final kartuGambar = set.kartu.firstWhere((k) => k.gambarId != null);
    final item = katalog.byId(kartuGambar.gambarId!)!;
    expect(namaKartu(kartuGambar, katalog, AppLang.id), item.nama.id);
    expect(namaKartu(kartuGambar, katalog, AppLang.en), item.nama.en);
    const bentuk = WarnaKartu(
      id: 'balon-merah',
      bentuk: WarnaBentuk.balon,
      warna: 'merah',
    );
    expect(namaKartu(bentuk, katalog, AppLang.id), '');
  });

  test('warna berikutnya berputar', () {
    expect(warnaBerikut(katalog, 'merah'), 'oranye');
    expect(warnaBerikut(katalog, 'abu'), 'merah');
  });
}
