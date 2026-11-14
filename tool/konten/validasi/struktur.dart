import 'dart:io';

import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/hadiah/stiker.dart';

import 'laporan.dart';

/// Pola id isi (K3).
final polaId = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

/// Aturan isi yang tidak menyentuh berkas SVG: id, dua bahasa, rujukan, kata.
void validasiStruktur(
  Laporan laporan, {
  required Katalog katalog,
  required List<Cap> cap,
  required List<Krayon> krayon,
  required Directory ilustrasi,
}) {
  _idUnik(laporan, katalog);
  _duaBahasa(laporan, katalog: katalog, cap: cap, krayon: krayon);
  _rujukanGambar(laporan, katalog: katalog, cap: cap, ilustrasi: ilustrasi);
  _rujukanWarna(laporan, katalog);
  _kataUtuh(laporan, katalog);
}

/// Mencatat satu aturan: lolos kalau [galat] kosong, selain itu setiap pesan
/// menjadi galat.
void catat(
  Laporan laporan,
  String aturan,
  String pesanLolos,
  List<String> galat,
) {
  if (galat.isEmpty) {
    laporan.ok(aturan, pesanLolos);
    return;
  }
  for (final pesan in galat) {
    laporan.galat(aturan, pesan);
  }
}

void _idUnik(Laporan laporan, Katalog katalog) {
  final galat = <String>[];
  final terlihat = <String>{};
  for (final item in katalog.item) {
    if (!polaId.hasMatch(item.id)) {
      galat.add('id "${item.id}" tidak cocok pola');
    }
    if (!terlihat.add(item.id)) {
      galat.add('id "${item.id}" dipakai lebih dari satu item');
    }
  }
  catat(laporan, 'id_unik', '${katalog.item.length} id unik', galat);
}

void _duaBahasa(
  Laporan laporan, {
  required Katalog katalog,
  required List<Cap> cap,
  required List<Krayon> krayon,
}) {
  final galat = <String>[];
  void cek(Bilingual teks, String asal) {
    if (teks.id.trim().isEmpty) galat.add('$asal kosong dalam bahasa id');
    if (teks.en.trim().isEmpty) galat.add('$asal kosong dalam bahasa en');
  }

  for (final item in katalog.item) {
    cek(item.nama, 'nama "${item.id}"');
    final hewan = item.hewan;
    if (hewan != null) {
      cek(hewan.bunyi, 'bunyi "${item.id}"');
      cek(hewan.fakta, 'fakta "${item.id}"');
    }
  }
  for (final warna in katalog.warna) {
    cek(warna.nama, 'nama warna "${warna.id}"');
  }
  for (final bentuk in katalog.bentuk) {
    cek(bentuk.nama, 'nama bentuk "${bentuk.id}"');
    cek(bentuk.fakta, 'fakta bentuk "${bentuk.id}"');
  }
  for (final kalimat in katalog.kalimat) {
    cek(kalimat.teks, 'teks kalimat "${kalimat.id}"');
  }
  for (final entri in cap) {
    cek(entri.nama, 'nama cap "${entri.id}"');
  }
  for (final entri in krayon) {
    cek(entri.nama, 'nama krayon "${entri.hex}"');
  }
  catat(laporan, 'nama_dua_bahasa', 'nama terisi dua bahasa', galat);
}

/// Semua gambar yang dirujuk isi: id gambar → asal pertama yang merujuknya.
Map<String, String> rujukanGambar(Katalog katalog, List<Cap> cap) {
  final rujukan = <String, String>{};
  void cek(String id, String asal) => rujukan.putIfAbsent(id, () => asal);

  String dariPath(String path) {
    const awalan = 'illustrations/';
    if (!path.startsWith(awalan) || !path.endsWith('.svg')) return path;
    return path.substring(awalan.length, path.length - '.svg'.length);
  }

  for (final item in katalog.item) {
    cek(dariPath(item.gambar), 'item "${item.id}"');
  }
  for (final huruf in katalog.huruf) {
    cek(huruf.id.gambar, 'huruf ${huruf.huruf} (id)');
    cek(huruf.en.gambar, 'huruf ${huruf.huruf} (en)');
  }
  for (final id in katalog.angka.benda) {
    cek(id, 'benda hitung');
  }
  for (final contoh in katalog.sukuKata.contoh.values) {
    for (final suku in contoh.values) {
      cek(suku.item, 'contoh suku kata');
    }
  }
  for (final kata in [...katalog.kata.id, ...katalog.kata.en]) {
    cek(kata.item, 'kata "${kata.kata}"');
  }
  for (final kalimat in katalog.kalimat) {
    cek(dariPath(kalimat.gambar), 'kalimat "${kalimat.id}"');
  }
  for (final ucapkan in [...katalog.ucapkan.id, ...katalog.ucapkan.en]) {
    cek(dariPath(ucapkan.gambar), 'ucapkan "${ucapkan.kata}"');
  }
  for (final entri in cap) {
    cek(entri.id, 'cap "${entri.nama.id}"');
  }
  for (final id in stickerCatalog) {
    cek(id, 'stiker hadiah');
  }
  return rujukan;
}

void _rujukanGambar(
  Laporan laporan, {
  required Katalog katalog,
  required List<Cap> cap,
  required Directory ilustrasi,
}) {
  final galat = <String>[];
  final rujukan = rujukanGambar(katalog, cap);
  for (final entry in rujukan.entries) {
    if (entry.key.isEmpty) {
      galat.add('${entry.value} merujuk gambar tanpa id');
      continue;
    }
    if (!File('${ilustrasi.path}/${entry.key}.svg').existsSync()) {
      galat.add('${entry.value} merujuk gambar "${entry.key}" yang tidak ada');
    }
  }
  catat(laporan, 'referensi_gambar_ada', '${rujukan.length} gambar ada', galat);
}

void _rujukanWarna(Laporan laporan, Katalog katalog) {
  final galat = <String>[];
  final dikenal = {for (final warna in katalog.warna) warna.id};
  for (final item in katalog.item) {
    final warna = item.warna;
    if (warna != null && !dikenal.contains(warna)) {
      galat.add('item "${item.id}" memakai warna "$warna" yang tidak ada');
    }
  }
  catat(
    laporan,
    'referensi_warna_ada',
    '${dikenal.length} warna dipakai',
    galat,
  );
}

void _kataUtuh(Laporan laporan, Katalog katalog) {
  final galat = <String>[];
  String normal(String teks) =>
      teks.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');

  for (final kata in [...katalog.kata.id, ...katalog.kata.en]) {
    final gabung = kata.suku.map(normal).join();
    if (gabung != normal(kata.kata)) {
      galat.add(
        'kata "${kata.kata}" tidak tersusun dari suku ${kata.suku.join("-")}',
      );
    }
  }
  final jumlah = katalog.kata.id.length + katalog.kata.en.length;
  catat(laporan, 'kata_utuh', '$jumlah kata tersusun utuh', galat);
}
