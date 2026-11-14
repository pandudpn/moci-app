import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/membaca/kalimat/kalimat_timing.dart';

void main() {
  test('kata dipisah dan tanda baca ikut dihitung', () {
    expect(kataKalimat('Ini bola.'), ['Ini', 'bola.']);
    expect(kataKalimat('  Dua   spasi '), ['Dua', 'spasi']);
    expect(kataKalimat(''), isEmpty);
  });
  test('tanpa waktu rekaman, rumus 420 + 75 × panjang kata', () {
    final kata = kataKalimat('Ini bola.');
    final mulai = waktuMulaiKata(kata: kata);
    expect(mulai, [Duration.zero, const Duration(milliseconds: 645)]);
    expect(totalKata(kata, mulai), const Duration(milliseconds: 1440));
  });
  test('waktu rekaman dipakai kalau panjangnya cocok', () {
    expect(waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0, 0.5]), [
      Duration.zero,
      const Duration(milliseconds: 500),
    ]);
  });
  test('waktu rekaman yang tidak cocok diabaikan', () {
    final rumus = [Duration.zero, const Duration(milliseconds: 645)];
    expect(waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0]), rumus);
    expect(waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0.6, 0.5]), rumus);
  });
  test('indeks karaoke mengikuti waktu mulai', () {
    final mulai = [Duration.zero, const Duration(milliseconds: 645)];
    expect(indeksKata(mulai, Duration.zero), 0);
    expect(indeksKata(mulai, const Duration(milliseconds: 600)), 0);
    expect(indeksKata(mulai, const Duration(milliseconds: 645)), 1);
    expect(indeksKata(mulai, const Duration(seconds: 9)), 1);
    expect(indeksKata(const [], const Duration(seconds: 1)), -1);
  });
}
