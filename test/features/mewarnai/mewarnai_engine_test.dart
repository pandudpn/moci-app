import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/features/mewarnai/mewarnai_engine.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';

ColoringPage _halaman() => const ColoringPage(
  id: 'uji',
  kategori: 'benda',
  nama: Bilingual('Uji', 'Test'),
  bagian: [
    ColoringRegion(d: 'M0 0H100V100H0Z'),
    ColoringRegion(d: 'M40 40H60V60H40Z'),
  ],
);

void main() {
  test('bagian paling atas yang memuat titik dipilih', () {
    final m = MesinMewarnai(halaman: _halaman());
    expect(m.bagianDi(const Offset(50, 50)), 1);
    expect(m.bagianDi(const Offset(10, 10)), 0);
    expect(m.bagianDi(const Offset(150, 50)), isNull);
    expect(m.jalur.length, 2);
  });

  test('isi mengganti warna bagian dan bisa dibatalkan', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihWarna('#FF4B4B');
    m.pilihAlat(AlatMewarnai.isi);
    m.mulai(const Offset(10, 10));
    expect(m.data.isian[0], '#FF4B4B');
    expect(m.bisaBatal, isTrue);
    m.batal();
    expect(m.data.isian, isEmpty);
  });

  test('isi menghapus coretan bagian dan batal mengembalikannya', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihAlat(AlatMewarnai.kuas);
    m.mulai(const Offset(10, 10));
    m.geser(const Offset(30, 10));
    m.akhiri();
    expect(m.data.coretan[0]!.single.lebar, 26);
    m.pilihAlat(AlatMewarnai.isi);
    m.mulai(const Offset(10, 10));
    expect(m.data.coretan[0], isNull);
    m.batal();
    expect(m.data.coretan[0]!.single.lebar, 26);
    expect(m.data.isian[0], isNull);
  });

  test('coretan terkunci di bagian tempat jari mulai', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihAlat(AlatMewarnai.kuas);
    m.mulai(const Offset(10, 10));
    m.geser(const Offset(50, 50));
    expect(m.bagianTerkunci, 0);
    m.akhiri();
    expect(m.data.coretan.keys, [0]);
    expect(m.bagianTerkunci, isNull);
  });

  test('hapus memakai kuas putih sepuluh unit lebih lebar', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihAlat(AlatMewarnai.hapus);
    m.pilihUkuran(UkuranKuas.besar);
    m.mulai(const Offset(10, 10));
    m.geser(const Offset(30, 10));
    m.akhiri();
    final s = m.data.coretan[0]!.single;
    expect(s.warna, '#FFFFFF');
    expect(s.lebar, 54);
  });

  test('stiker ditempel di titik ketukan dan bisa dibatalkan', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihCap('bola');
    m.pilihAlat(AlatMewarnai.cap);
    m.mulai(const Offset(120, 90));
    expect(m.data.cap.single.cap, 'bola');
    expect(m.data.cap.single.x, 120);
    m.batal();
    expect(m.data.cap, isEmpty);
  });

  test('mulai lagi mengosongkan halaman dan batal memulihkannya', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihWarna('#FF4B4B');
    m.pilihAlat(AlatMewarnai.isi);
    m.mulai(const Offset(10, 10));
    m.mulaiLagi();
    expect(m.data.adaIsi, isFalse);
    m.batal();
    expect(m.data.isian[0], '#FF4B4B');
  });

  test('riwayat batal berhenti di 30 langkah', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihAlat(AlatMewarnai.isi);
    for (var i = 0; i < 31; i++) {
      m.pilihWarna('#${i.toRadixString(16).padLeft(6, '0')}');
      m.mulai(const Offset(10, 10));
    }
    var batal = 0;
    while (m.bisaBatal) {
      m.batal();
      batal++;
    }
    expect(batal, 30);
    expect(m.data.isian[0], '#000000');
  });

  test('isi dengan warna yang sama tidak menambah riwayat', () {
    final m = MesinMewarnai(halaman: _halaman());
    m.pilihWarna('#FF4B4B');
    m.pilihAlat(AlatMewarnai.isi);
    m.mulai(const Offset(10, 10));
    m.mulai(const Offset(10, 10));
    expect(m.panjangRiwayat, 1);
  });

  test('draf yang dibuka tidak punya riwayat', () {
    final m = MesinMewarnai(
      halaman: _halaman(),
      awal: const KaryaData(halaman: 'uji', isian: {0: '#1C7ED6'}),
    );
    expect(m.data.isian[0], '#1C7ED6');
    expect(m.bisaBatal, isFalse);
  });
}
