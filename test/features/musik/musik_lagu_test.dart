import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/musik/musik_lagu.dart';

void main() {
  test('jadwal lagu mulai 250 ms dan memakai panjang ketuk', () {
    final jadwal = jadwalLagu(laguTwinkle);
    expect(jadwal.length, laguTwinkle.nada.length);
    expect(jadwal.first, (ms: 250, nada: 0));
    expect(jadwal[1].ms, 670);
    expect(jadwal[6].ms, 250 + 420 * 6); // nada ke-7 berdurasi 2 ketuk
    expect(jadwal.last.ms, greaterThan(15000));
  });

  test('ikuti hanya menerima nada berikutnya', () {
    final ikuti = IkutiLagu(laguMary);
    expect(ikuti.berikut, 2);
    expect(ikuti.cocok(0), isFalse);
    expect(ikuti.posisi, 0);
    expect(ikuti.cocok(2), isTrue);
    expect(ikuti.posisi, 1);
    expect(ikuti.berikut, 1);
    for (var i = 1; i < laguMary.nada.length; i++) {
      expect(ikuti.cocok(laguMary.nada[i]), isTrue);
    }
    expect(ikuti.selesai, isTrue);
    expect(ikuti.berikut, -1);
    ikuti.ulang();
    expect(ikuti.posisi, 0);
  });

  test('irama drum 32 langkah 150 ms dengan instrumen prototipe', () {
    final irama = iramaDrum();
    expect(irama.length, 27);
    expect(irama.first.ms, 100);
    expect(irama.first.nama, 'drum-drum');
    expect(irama.where((k) => k.ms == 100).map((k) => k.nama), [
      'drum-drum',
      'drum-kerincing',
    ]);
    expect(irama.any((k) => k.ms == 4600 && k.nama == 'drum-simbal'), isTrue);
    expect(irama.last.ms, 4600);
  });
}
