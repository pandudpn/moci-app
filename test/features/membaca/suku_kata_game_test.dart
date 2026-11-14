import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/membaca/suku_kata/suku_kata_game.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

void main() {
  final info = _katalog().sukuKata;

  test('kisi memuat 18 konsonan dan 5 vokal', () {
    expect(konsonanKisi(info).length, 18);
    expect(konsonanKisi(info).first, 'b');
    expect(vokalKisi(info), ['a', 'i', 'u', 'e', 'o']);
  });
  test('baris konsonan berisi lima suku berurutan', () {
    final baris = barisKonsonan(info, 'b', AppLang.id);
    expect(baris.map((e) => e.suku), ['ba', 'bi', 'bu', 'be', 'bo']);
    expect(baris.first.contoh?.kata, 'Badak');
    expect(baris.first.contoh?.item, 'badak');
  });
  test('contoh kata mengikuti bahasa', () {
    expect(contohSuku(info, AppLang.id, 'ba')?.kata, 'Badak');
    expect(contohSuku(info, AppLang.en, 'ba')?.kata, 'Ball');
  });
  test('suku tanpa contoh tidak punya contoh kata', () {
    expect(contohSuku(info, AppLang.id, 'zi'), isNull);
    expect(barisKonsonan(info, 'q', AppLang.id), isEmpty);
    expect(barisKonsonan(info, 'z', AppLang.id)[1].adaContoh, isFalse);
  });
  test('awalan contoh mengikuti suku kata di awal kata', () {
    expect(pecahContoh('Badak', 'ba'), (awalan: 'Ba', sisa: 'dak'));
    expect(pecahContoh('Bola', 'la'), (awalan: '', sisa: 'Bola'));
  });
}
