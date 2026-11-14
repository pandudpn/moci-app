import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/content_repository.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/ucapkan/ucapkan_kata.dart';

Katalog _katalogUji() => Katalog.fromJson(
  jsonDecode(File(ContentRepository.katalogPath).readAsStringSync()) as Object?,
);

void main() {
  test('id benda diambil dari path gambar', () {
    expect(itemIdDariGambar('illustrations/apel.svg'), 'apel');
    expect(itemIdDariGambar('illustrations/kuekecil.svg'), 'kuekecil');
  });

  test('lima kata per bahasa dengan suku kata', () {
    final k = _katalogUji();
    expect(ucapkanKata(k, AppLang.id).map((e) => e.kata), [
      'Apel',
      'Bola',
      'Ikan',
      'Sapi',
      'Topi',
    ]);
    expect(ucapkanKata(k, AppLang.en).first.itemId, 'apel');
    expect(ucapkanKata(k, AppLang.id).first.suku, ['A', 'PEL']);
  });
}
