import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/musik/instrumen.dart';

int _u16(Uint8List b, int i) => b[i] | (b[i + 1] << 8);
int _u32(Uint8List b, int i) =>
    b[i] | (b[i + 1] << 8) | (b[i + 2] << 16) | (b[i + 3] << 24);

const _detik = <String, double>{
  'xilo-1.wav': 1.2,
  'xilo-2.wav': 1.2,
  'xilo-3.wav': 1.2,
  'xilo-4.wav': 1.2,
  'xilo-5.wav': 1.2,
  'xilo-6.wav': 1.2,
  'xilo-7.wav': 1.2,
  'xilo-8.wav': 1.2,
  'drum-drum.wav': 0.5,
  'drum-tepuk.wav': 0.3,
  'drum-simbal.wav': 1.4,
  'drum-kerincing.wav': 0.2,
};

void main() {
  test('dua belas berkas WAV mono 16-bit 24 kHz dengan panjang tetap', () {
    expect(daftarInstrumen.length, 12);
    for (final nama in daftarInstrumen) {
      final b = File(pathInstrumen(nama)).readAsBytesSync();
      expect(String.fromCharCodes(b.sublist(0, 4)), 'RIFF', reason: nama);
      expect(String.fromCharCodes(b.sublist(8, 12)), 'WAVE', reason: nama);
      expect(_u16(b, 20), 1, reason: nama);
      expect(_u16(b, 22), 1, reason: nama);
      expect(_u32(b, 24), 24000, reason: nama);
      expect(_u32(b, 28), 48000, reason: nama);
      expect(_u16(b, 34), 16, reason: nama);
      expect(
        b.length,
        44 + (_detik['$nama.wav']! * 24000).round() * 2,
        reason: nama,
      );
    }
  });

  test('setiap berkas tercatat Milik sendiri', () {
    final baris = File('assets/audio/LICENSES.csv').readAsLinesSync().skip(1);
    final lisensi = {
      for (final b in baris)
        if (b.trim().isNotEmpty) b.split(',')[0]: b.split(',')[3],
    };
    for (final nama in daftarInstrumen) {
      expect(lisensi['instrumen/$nama.wav'], 'Milik sendiri', reason: nama);
    }
  });

  test('folder audio dideklarasikan di pubspec', () {
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- assets/audio/'),
    );
  });

  test('frekuensi nada mengikuti prototipe', () {
    expect(frekuensiXilo, [
      523.25,
      587.33,
      659.25,
      698.46,
      783.99,
      880.0,
      987.77,
      1046.5,
    ]);
  });
}
