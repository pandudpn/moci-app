import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/membaca/kalimat/kalimat_game.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

void main() {
  test('id gambar diambil dari path', () {
    expect(itemDariGambar('illustrations/bola.svg'), 'bola');
  });
  test('tiga pilihan unik berisi jawaban dan dua pengganggu', () {
    final katalog = _katalog();
    final opsi = pilihanGambar(
      katalog: katalog,
      kalimat: katalog.kalimat.first,
      random: Random(7),
    );
    expect(opsi.length, 3);
    expect(opsi.toSet().length, 3);
    expect(opsi, contains('bola'));
  });
  test('setiap kalimat punya tiga pilihan dengan jawabannya', () {
    final katalog = _katalog();
    for (final kalimat in katalog.kalimat) {
      final opsi = pilihanGambar(
        katalog: katalog,
        kalimat: kalimat,
        random: Random(3),
      );
      expect(opsi, contains(itemDariGambar(kalimat.gambar)));
      expect(opsi.toSet().length, 3);
    }
  });
}
