import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/konten/validasi/laporan.dart';
import '../../tool/konten/validasi/svg.dart';

/// Menjalankan aturan SVG atas berkas [berkas] (`id` → isi) di folder
/// sementara dan mengembalikan pesan galat aturan `svg_aturan` saja.
List<String> _galatSvg(Map<String, String> berkas) {
  final dir = Directory.systemTemp.createTempSync('svg-uji');
  addTearDown(() => dir.deleteSync(recursive: true));
  for (final e in berkas.entries) {
    File('${dir.path}/${e.key}.svg').writeAsStringSync(e.value);
  }
  final laporan = Laporan();
  validasiSvg(
    laporan,
    ilustrasi: dir,
    dipakai: berkas.keys.toSet(),
    batasByte: 1 << 20,
  );
  return [
    for (final c in laporan.galatList)
      if (c.aturan == 'svg_aturan') c.pesan,
  ];
}

void main() {
  test('class pada <svg> akar ditolak', () {
    final galat = _galatSvg({
      'kucing':
          '<svg viewBox="0 0 200 200" class="besar">'
          '<rect fill="#FFFFFF"/></svg>',
    });
    expect(galat, contains('kucing.svg memakai atribut class'));
  });

  test('style pada <svg> akar ditolak', () {
    final galat = _galatSvg({
      'kucing':
          '<svg viewBox="0 0 200 200" style="fill:#FFFFFF">'
          '<rect fill="#FFFFFF"/></svg>',
    });
    expect(galat, contains('kucing.svg memakai atribut style'));
  });

  test('class pada elemen di dalam tetap ditolak', () {
    final galat = _galatSvg({
      'kucing':
          '<svg viewBox="0 0 200 200">'
          '<rect class="mata" fill="#FFFFFF"/></svg>',
    });
    expect(galat, contains('kucing.svg memakai atribut class'));
  });

  test('SVG bersih lolos', () {
    final galat = _galatSvg({
      'kucing':
          '<svg viewBox="0 0 200 200">'
          '<rect fill="#FFFFFF"/><circle fill="#000000"/></svg>',
    });
    expect(galat, isEmpty);
  });
}
