import 'package:flutter_test/flutter_test.dart';

import '../../tool/konten/js_literal.dart';

void main() {
  Object? p(String s) => parseJsLiteral(s, 0).$1;
  test('array tuple kutip tunggal', () {
    expect(p("['A', 'Apple', 'apel', 'ah', '/a/', 'ay']"), [
      'A',
      'Apple',
      'apel',
      'ah',
      '/a/',
      'ay',
    ]);
  });
  test('objek kunci tanpa kutip, koma akhir, komentar', () {
    expect(p("{ apel: 'f3ad', /* c */ bola: \"b6ba\", // x\n }"), {
      'apel': 'f3ad',
      'bola': 'b6ba',
    });
  });
  test('angka, bersarang, bool, null', () {
    expect(p('[[28, 28], [172.5, -3], true, null]'), [
      [28, 28],
      [172.5, -3],
      true,
      null,
    ]);
  });
  test('escape', () => expect(p(r"'Can\'t ×'"), "Can't ×"));
  test('posisi akhir', () => expect(parseJsLiteral('x = [1, 2]; y', 4).$2, 10));
  test('menolak ekspresi', () {
    expect(() => p("{ img: B + 'f3ad' }"), throwsFormatException);
    expect(() => p('[foo()]'), throwsFormatException);
  });
}
