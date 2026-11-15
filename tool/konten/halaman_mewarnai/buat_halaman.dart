/// Menambah halaman mewarnai baru ke `assets/coloring/pages.json`.
///
/// Jalankan `fvm dart run tool/konten/halaman_mewarnai/buat_halaman.dart` dari
/// akar repo. Halaman lama tidak diubah; halaman baru dengan id yang sama
/// ditimpa supaya skrip ini aman dijalankan ulang.
library;

import 'dart:convert';
import 'dart:io';

import 'package:moci/core/content/coloring.dart';

import 'benda.dart';
import 'buah.dart';
import 'hewan.dart';
import 'kota.dart';
import 'laut.dart';

Future<void> main() async {
  final berkas = File('assets/coloring/pages.json');
  final lama = ColoringSet.fromJson(
    jsonDecode(berkas.readAsStringSync()) as Object?,
  );
  final baru = <ColoringPage>[
    ...halamanKota(),
    ...halamanLaut(),
    ...halamanHewan(),
    ...halamanBuah(),
    ...halamanBenda(),
  ];
  final idBaru = {for (final page in baru) page.id};
  if (idBaru.length != baru.length) {
    stderr.writeln('id halaman baru ada yang dobel');
    exitCode = 1;
    return;
  }

  // Halaman yang id-nya dibuat ulang dilepas dulu supaya skrip aman diulang.
  final set = ColoringSet(
    versi: lama.versi,
    kanvas: lama.kanvas,
    halaman: [
      for (final page in lama.halaman)
        if (!idBaru.contains(page.id)) page,
      ...baru,
    ],
  );

  for (final page in baru) {
    if (page.bagian.length < 12 || page.bagian.length > 30) {
      stderr.writeln(
        '${page.id}: ${page.bagian.length} bagian, di luar 12 sampai 30',
      );
      exitCode = 1;
    }
  }
  berkas.writeAsStringSync(
    '${const JsonEncoder.withIndent(' ').convert(set.toJson())}\n',
  );
  final perKategori = <String, int>{};
  for (final page in set.halaman) {
    perKategori[page.kategori] = (perKategori[page.kategori] ?? 0) + 1;
  }
  stdout.writeln(
    '${set.halaman.length} halaman: '
    '${perKategori.entries.map((e) => '${e.key} ${e.value}').join(', ')}',
  );
}
