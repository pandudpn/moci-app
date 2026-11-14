import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';

import '../../tool/konten/validasi/coloring.dart';
import '../../tool/konten/validasi/laporan.dart';

const _nama = Bilingual('Kucing', 'Cat');

ColoringSet _set(String d) => ColoringSet(
  halaman: [
    ColoringPage(
      id: 'kucing',
      kategori: 'hewan',
      nama: _nama,
      bagian: [ColoringRegion(d: d)],
      contoh: const {0: '#FFFFFF'},
    ),
  ],
);

List<String> _galat(String d) {
  final laporan = Laporan();
  validasiColoring(laporan, _set(d));
  return [for (final c in laporan.galatList) c.pesan];
}

void main() {
  test('bagian tertutup lolos', () {
    expect(_galat('M0 0 L10 0 L10 10 Z'), isEmpty);
  });

  test('bagian tidak tertutup dilaporkan', () {
    expect(_galat('M0 0 L10 0 L10 10'), ['kucing bagian 0 tidak diakhiri Z']);
  });

  test('bagian kosong dilaporkan sekali, bukan dua kali', () {
    expect(_galat(''), ['kucing bagian 0 kosong']);
    expect(_galat('   '), ['kucing bagian 0 kosong']);
  });
}
