import 'dart:io';

import 'package:xml/xml.dart';

import 'laporan.dart';
import 'struktur.dart';

/// Gambar UI yang bukan ilustrasi isi. Ukurannya boleh berbeda dari 200×200.
///
/// `moci`, `moci-senang`, dan `karyaku` berasal dari ekspor; `moci-tidur`
/// digambar dari SVG inline `Istirahat.dc.html` pada Rencana 01.
const gambarUi = {'moci', 'moci-senang', 'karyaku', 'moci-tidur'};

/// Elemen dan atribut yang dilarang di ilustrasi isi.
const _terlarang = {
  'style',
  'image',
  'text',
  'filter',
  'mask',
  'lineargradient',
  'radialgradient',
};

/// Aturan SVG ilustrasi, sisa pemakai, dan anggaran ukuran.
void validasiSvg(
  Laporan laporan, {
  required Directory ilustrasi,
  required Set<String> dipakai,
  required int batasByte,
}) {
  final berkas = ilustrasi.existsSync()
      ? ilustrasi
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.svg'))
            .toList()
      : <File>[];

  final galat = <String>[];
  var totalByte = 0;
  for (final file in berkas) {
    totalByte += file.lengthSync();
    galat.addAll(_periksaSvg(file));
  }
  catat(laporan, 'svg_aturan', '${berkas.length} SVG sesuai aturan', galat);

  final tanpaPemakai = <String>[];
  for (final file in berkas) {
    final id = _idBerkas(file);
    if (!dipakai.contains(id) && !gambarUi.contains(id)) {
      tanpaPemakai.add(id);
    }
  }
  if (tanpaPemakai.isEmpty) {
    laporan.ok('svg_tanpa_pemakai', 'semua SVG punya pemakai');
  } else {
    laporan.peringatan(
      'svg_tanpa_pemakai',
      'tidak dirujuk: ${tanpaPemakai.join(', ')}',
    );
  }

  if (totalByte <= batasByte) {
    laporan.ok(
      'anggaran_ilustrasi',
      '$totalByte byte dari batas $batasByte byte',
    );
  } else {
    laporan.galat(
      'anggaran_ilustrasi',
      'ilustrasi $totalByte byte melebihi batas $batasByte byte',
    );
  }
}

String _idBerkas(File file) {
  final nama = file.uri.pathSegments.last;
  return nama.endsWith('.svg') ? nama.substring(0, nama.length - 4) : nama;
}

/// Galat untuk satu berkas SVG; kosong kalau berkasnya sesuai aturan.
List<String> _periksaSvg(File file) {
  final id = _idBerkas(file);
  final galat = <String>[];
  void tolak(String pesan) => galat.add('$id.svg $pesan');

  final XmlDocument dokumen;
  try {
    dokumen = XmlDocument.parse(file.readAsStringSync());
  } on XmlException catch (e) {
    return ['$id.svg bukan XML yang sah: ${e.message}'];
  }

  if (!gambarUi.contains(id)) {
    final kotak = dokumen.rootElement.getAttribute('viewBox');
    if (kotak != '0 0 200 200') {
      tolak('viewBox "$kotak", seharusnya "0 0 200 200"');
    }
  }

  final warnaIsian = <String>{};
  for (final elemen in dokumen.descendantElements) {
    final nama = elemen.name.local.toLowerCase();
    if (_terlarang.contains(nama)) {
      tolak('memakai <${elemen.name.local}>');
      continue;
    }
    for (final atribut in elemen.attributes) {
      final kunci = atribut.name.local.toLowerCase();
      final nilai = atribut.value;
      if (kunci == 'class' || kunci == 'style') {
        tolak('memakai atribut $kunci');
        continue;
      }
      if (kunci != 'fill' && kunci != 'stroke') continue;
      if (nilai.contains('url(')) {
        tolak('memakai paint url() pada $kunci');
        continue;
      }
      if (nilai == 'none' || nilai == 'currentColor') continue;
      if (!RegExp(r'^#[0-9A-Fa-f]{3,8}$').hasMatch(nilai)) {
        tolak('warna $kunci "$nilai" bukan hex');
        continue;
      }
      if (kunci == 'fill') warnaIsian.add(nilai.toUpperCase());
    }
  }
  if (warnaIsian.length > 12) {
    tolak('memakai ${warnaIsian.length} warna isian, maksimal 12');
  }
  return galat;
}
