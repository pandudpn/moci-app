import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/speech/speech_engine.dart';

void main() {
  test('kata cocok setelah huruf kecil dan tanda baca', () {
    expect(kataCocok('Apel', 'apel!'), isTrue);
    expect(kataCocok('Apple', '  APPLE. '), isTrue);
    expect(kataCocok('Bola', 'buku'), isFalse);
  });

  test('selisih satu huruf hanya untuk empat huruf ke atas', () {
    expect(kataCocok('Bola', 'bala'), isTrue);
    expect(kataCocok('Apple', 'aple'), isTrue);
    expect(kataCocok('Api', 'ati'), isFalse);
  });

  test('kata berbeda tidak cocok', () {
    expect(kataCocok('Zebra', 'apple'), isFalse);
    expect(kataCocok('Yoyo', 'yoyo!'), isTrue);
  });

  test('spasi ganda dan tanda hubung dinormalkan', () {
    expect(kataCocok('Kue Mangkuk', '  kue   mangkuk '), isTrue);
    expect(kataCocok('Kupu-kupu', 'kupu kupu'), isTrue);
  });
}
