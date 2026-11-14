import 'package:moci/core/content/tracing.dart';

import 'laporan.dart';
import 'struktur.dart';

const _huruf = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const _angka = '0123456789';

/// Perintah path yang dimengerti sampler Rencana 03.
const perintahDidukung = {'M', 'L', 'H', 'V', 'C'};

/// Aturan panduan menulis: kelengkapan glyph dan perintah path yang didukung.
void validasiTracing(
  Laporan laporan, {
  required TracingSet huruf,
  required TracingSet angka,
}) {
  catat(laporan, 'tracing_lengkap', '26 huruf dan 10 angka', [
    ..._lengkapi('huruf', huruf, _huruf),
    ..._lengkapi('angka', angka, _angka),
  ]);

  catat(laporan, 'tracing_perintah_didukung', 'semua goresan M L H V C', [
    ..._perintah('huruf', huruf),
    ..._perintah('angka', angka),
  ]);
}

List<String> _lengkapi(String nama, TracingSet set, String diharapkan) {
  final punya = set.glyph.keys.toSet();
  final galat = <String>[];
  for (final kunci in diharapkan.split('')) {
    if (!punya.contains(kunci)) {
      galat.add('$nama.json tidak punya glyph "$kunci"');
    }
  }
  for (final kunci in punya) {
    if (!diharapkan.contains(kunci)) {
      galat.add('$nama.json punya glyph tak dikenal "$kunci"');
    }
  }
  return galat;
}

List<String> _perintah(String nama, TracingSet set) {
  final galat = <String>[];
  for (final entry in set.glyph.entries) {
    for (final path in entry.value) {
      for (final cocok in RegExp('[A-Za-z]').allMatches(path)) {
        final perintah = cocok[0]!;
        if (!perintahDidukung.contains(perintah)) {
          galat.add(
            '$nama.json ${entry.key}: perintah "$perintah" tidak didukung',
          );
        }
      }
      for (final cocok in RegExp(r'-?\d+(?:\.\d+)?').allMatches(path)) {
        final nilai = double.parse(cocok[0]!);
        if (nilai < 0 || nilai > set.kotak) {
          galat.add(
            '$nama.json ${entry.key}: koordinat ${cocok[0]} di luar '
            '0–${set.kotak}',
          );
        }
      }
    }
  }
  return galat;
}
