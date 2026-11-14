import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/angka_kata.dart';
import 'package:moci/core/lang.dart';

void main() {
  test('kata bilangan Indonesia', () {
    expect(angkaKata(0, AppLang.id), 'nol');
    expect(angkaKata(9, AppLang.id), 'sembilan');
    expect(angkaKata(10, AppLang.id), 'sepuluh');
    expect(angkaKata(11, AppLang.id), 'sebelas');
    expect(angkaKata(15, AppLang.id), 'lima belas');
    expect(angkaKata(21, AppLang.id), 'dua puluh satu');
    expect(angkaKata(50, AppLang.id), 'lima puluh');
    expect(angkaKata(59, AppLang.id), 'lima puluh sembilan');
  });

  test('kata bilangan Inggris', () {
    expect(angkaKata(0, AppLang.en), 'zero');
    expect(angkaKata(7, AppLang.en), 'seven');
    expect(angkaKata(13, AppLang.en), 'thirteen');
    expect(angkaKata(20, AppLang.en), 'twenty');
    expect(angkaKata(21, AppLang.en), 'twenty-one');
    expect(angkaKata(40, AppLang.en), 'forty');
    expect(angkaKata(59, AppLang.en), 'fifty-nine');
  });

  test('di luar 0-59 ditolak', () {
    expect(() => angkaKata(-1, AppLang.id), throwsArgumentError);
    expect(() => angkaKata(60, AppLang.en), throwsArgumentError);
  });
}
