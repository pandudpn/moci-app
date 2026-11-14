import 'package:moci/core/content/coloring.dart';

import 'laporan.dart';
import 'struktur.dart';

/// Aturan halaman mewarnai: setiap bagian tertutup, dan contoh warna dilaporkan
/// sebagai peringatan selama belum semua halaman punya contoh (K8).
void validasiColoring(Laporan laporan, ColoringSet set) {
  final terbuka = <String>[];
  for (final page in set.halaman) {
    for (var i = 0; i < page.bagian.length; i++) {
      final d = page.bagian[i].d.trim();
      if (!d.endsWith('Z') && !d.endsWith('z')) {
        terbuka.add('${page.id} bagian $i tidak diakhiri Z');
      }
      if (d.isEmpty) {
        terbuka.add('${page.id} bagian $i kosong');
      }
    }
  }
  catat(
    laporan,
    'mewarnai_tertutup',
    '${set.halaman.length} halaman tertutup',
    terbuka,
  );

  final tanpaContoh = [
    for (final page in set.halaman)
      if (page.contoh.isEmpty) page.id,
  ];
  if (tanpaContoh.isEmpty) {
    laporan.ok('mewarnai_contoh', 'semua halaman punya contoh warna');
  } else {
    laporan.peringatan(
      'mewarnai_contoh',
      '${tanpaContoh.length} halaman belum punya contoh warna: '
          '${tanpaContoh.join(', ')}',
    );
  }
}
