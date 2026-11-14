import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';

void main() {
  test('karya kosong tidak punya isi', () {
    expect(KaryaData.kosong('kupu').adaIsi, isFalse);
    expect(
      KaryaData.kosong('kupu').copyWith(isian: {1: '#FF4B4B'}).adaIsi,
      isTrue,
    );
  });

  test('karya bolak-balik JSON mempertahankan isian, coretan, dan cap', () {
    final asal = KaryaData(
      halaman: 'kupu',
      isian: const {1: '#FF4B4B'},
      coretan: const {
        3: [Coretan(d: 'M10 20L40 20', warna: '#1C7ED6', lebar: 26)],
      },
      cap: const [CapTempel(cap: 'apel', x: 640, y: 410)],
      waktu: DateTime(2026, 11, 14, 10),
    );
    final salinan = KaryaData.fromJson(asal.toJson());
    expect(salinan.toJson(), asal.toJson());
    expect(salinan.coretan[3]!.single.lebar, 26);
  });

  test('coretan disederhanakan dengan toleransi satu unit', () {
    final titik = [
      for (var x = 0; x <= 40; x++) Offset(x.toDouble(), x.isEven ? 0 : 0.6),
    ];
    expect(coretanDariTitik(titik), 'M0 0L40 0');
  });

  test('tikungan tajam dan titik tunggal tetap tercatat', () {
    expect(
      coretanDariTitik(const [Offset(0, 0), Offset(40, 0), Offset(40, 40)]),
      'M0 0L40 0L40 40',
    );
    expect(coretanDariTitik(const [Offset(12.5, 7)]), 'M12.5 7L12.6 7');
  });

  test('warna hex dibaca, nilai aneh menjadi putih', () {
    expect(warnaDariHex('#FF4B4B'), const Color(0xFFFF4B4B));
    expect(warnaDariHex('bukan'), const Color(0xFFFFFFFF));
  });

  test('riwayat menyimpan paling banyak 30 langkah', () {
    final r = Riwayat();
    for (var i = 0; i < 31; i++) {
      r.tambah(LangkahCoretan(i));
    }
    expect(r.panjang, 30);
    expect((r.ambilTerakhir()! as LangkahCoretan).bagian, 30);
    expect(r.kosong, isFalse);
  });
}
