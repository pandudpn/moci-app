/// Validator isi: diperiksa di CI dan sebelum rilis.
///
/// `fvm dart run tool/validate_content.dart` memeriksa struktur isi, aturan
/// SVG, panduan menulis, halaman mewarnai, dan (lewat `--rilis`) narasi yang
/// belum direkam. Keluar dengan kode 1 kalau ada galat.
library;

import 'dart:convert';
import 'dart:io';

import 'package:moci/core/content/coloring.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/tracing.dart';

import 'konten/validasi/coloring.dart';
import 'konten/validasi/laporan.dart';
import 'konten/validasi/struktur.dart';
import 'konten/validasi/svg.dart';
import 'konten/validasi/tracing.dart';

Future<void> main(List<String> args) async {
  final rilis = args.contains('--rilis');
  File? naskah;
  for (final arg in args) {
    if (arg == '--naskah') {
      naskah = File('build/naskah.csv');
    } else if (arg.startsWith('--naskah=')) {
      naskah = File(arg.substring('--naskah='.length));
    }
  }
  final laporan = await validasiKonten(
    root: Directory.current,
    rilis: rilis,
    naskahKeluar: naskah,
  );
  stdout.writeln(laporan.ringkasan());
  if (laporan.adaGalat) {
    exitCode = 1;
  }
}

/// Memeriksa seluruh isi di [root] (akar repo, tempat `assets/` berada).
Future<Laporan> validasiKonten({
  required Directory root,
  bool rilis = false,
  File? naskahKeluar,
  int batasIlustrasiByte = 4 * 1024 * 1024,
  int batasAudioByte = 12 * 1024 * 1024,
}) async {
  final laporan = Laporan();
  final aset = Directory('${root.path}/assets');

  final katalog = _muatPeta(
    laporan,
    root,
    'assets/content/katalog.json',
    Katalog.fromJson,
  );
  final huruf = _muatPeta(
    laporan,
    root,
    'assets/tracing/huruf.json',
    TracingSet.fromJson,
  );
  final angka = _muatPeta(
    laporan,
    root,
    'assets/tracing/angka.json',
    TracingSet.fromJson,
  );
  final pages = _muatPeta(
    laporan,
    root,
    'assets/coloring/pages.json',
    ColoringSet.fromJson,
  );
  final cap = _muatDaftar(
    laporan,
    root,
    'assets/coloring/cap.json',
    Cap.fromJson,
  );
  final krayon = _muatDaftar(
    laporan,
    root,
    'assets/coloring/krayon.json',
    Krayon.fromJson,
  );
  if (laporan.adaGalat) return laporan;

  final katalogAman = katalog!;
  final hurufAman = huruf!;
  final angkaAman = angka!;
  final pagesAman = pages!;
  final ilustrasi = Directory('${aset.path}/illustrations');

  validasiStruktur(
    laporan,
    katalog: katalogAman,
    cap: cap!,
    krayon: krayon!,
    ilustrasi: ilustrasi,
  );
  final dipakai = rujukanGambar(katalogAman, cap).keys.toSet();
  validasiSvg(
    laporan,
    ilustrasi: ilustrasi,
    dipakai: dipakai,
    batasByte: batasIlustrasiByte,
  );
  validasiTracing(laporan, huruf: hurufAman, angka: angkaAman);
  validasiColoring(laporan, pagesAman);

  // Aturan narasi dan audio memakai `rilis`, `naskahKeluar`, dan
  // `batasAudioByte`; tanda tangannya sudah tetap supaya pemanggil stabil.
  return laporan;
}

/// Membaca satu berkas JSON yang isinya objek. Galat bentuk atau sintaks
/// dilaporkan sebagai `json_valid` dan hasilnya `null`.
T? _muatPeta<T>(
  Laporan laporan,
  Directory root,
  String jalur,
  T Function(Object?) baca,
) {
  final nilai = _bacaJson(laporan, root, jalur);
  if (nilai == null) return null;
  if (nilai is! Map) {
    laporan.galat('json_valid', '$jalur bukan objek JSON');
    return null;
  }
  return baca(nilai);
}

/// Membaca satu berkas JSON yang isinya daftar.
List<T>? _muatDaftar<T>(
  Laporan laporan,
  Directory root,
  String jalur,
  T Function(Object?) baca,
) {
  final nilai = _bacaJson(laporan, root, jalur);
  if (nilai == null) return null;
  if (nilai is! List) {
    laporan.galat('json_valid', '$jalur bukan daftar JSON');
    return null;
  }
  return [for (final e in nilai) baca(e)];
}

Object? _bacaJson(Laporan laporan, Directory root, String jalur) {
  final file = File('${root.path}/$jalur');
  if (!file.existsSync()) {
    laporan.galat('json_valid', '$jalur tidak ada');
    return null;
  }
  try {
    return jsonDecode(file.readAsStringSync()) as Object?;
  } on FormatException catch (e) {
    laporan.galat(
      'json_valid',
      '$jalur tidak bisa dibaca: ${e.message} di ${e.offset}',
    );
    return null;
  }
}
