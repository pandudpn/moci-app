import 'dart:io';

import 'package:moci/core/content/katalog.dart';

import 'laporan.dart';
import 'struktur.dart';

/// Folder rekaman narasi sendiri; berkas di dalamnya tidak butuh baris lisensi.
const folderAudioSendiri = ['vo'];

/// Ekstensi berkas audio yang wajib punya baris lisensi.
const ekstensiAudio = {'.m4a', '.mp3', '.wav', '.ogg', '.aac', '.flac', '.caf'};

/// Lisensi yang boleh dipakai. Keputusan 14 November 2026: sumber suara
/// Freesound CC0 dan rekaman sendiri, tanpa Pixabay dan tanpa CC BY.
const lisensiSah = {'CC0', 'Milik sendiri'};

const headerLisensi = 'file,sumber,URL,lisensi,tanggal unduh,catatan';

/// Aturan audio: lisensi berkas luar, suara hewan, dan anggaran ukuran.
void validasiAudio(
  Laporan laporan, {
  required Directory audio,
  required Katalog katalog,
  required bool rilis,
  required int batasByte,
}) {
  _lisensi(laporan, audio);
  _suaraHewan(laporan, audio: audio, katalog: katalog, rilis: rilis);
  _anggaran(laporan, audio, batasByte);
}

/// Setiap berkas audio selain rekaman sendiri punya baris lisensi yang sah.
///
/// Aturan ini galat di semua mode: berkas yang lisensinya tidak jelas tidak
/// boleh ikut terpasang, sekalipun aplikasinya masih dalam pengembangan.
void _lisensi(Laporan laporan, Directory audio) {
  final berkas = <String>[
    if (audio.existsSync())
      for (final entri in audio.listSync(recursive: true))
        if (entri is File && _butuhLisensi(_relatif(audio, entri.path)))
          _relatif(audio, entri.path),
  ]..sort();
  final lisensi = _bacaLisensi(File('${audio.path}/LICENSES.csv'));

  final galat = [if (lisensi.galatHeader != null) lisensi.galatHeader!];
  for (final nama in berkas) {
    final baris = lisensi.peta[nama];
    if (baris == null) {
      galat.add('"$nama" belum punya baris di assets/audio/LICENSES.csv');
      continue;
    }
    for (final satu in baris) {
      if (!lisensiSah.contains(satu)) {
        galat.add(
          'lisensi "${satu.isEmpty ? '(kosong)' : satu}" untuk "$nama" '
          'tidak diterima; hanya CC0 atau Milik sendiri',
        );
      }
    }
  }
  catat(
    laporan,
    'lisensi_audio_lengkap',
    '${berkas.length} berkas audio eksternal berlisensi',
    galat,
  );
}

/// Nama berkas relatif terhadap folder audio, selalu dengan garis miring.
String _relatif(Directory audio, String path) {
  final awalan = audio.path.endsWith('/') ? audio.path : '${audio.path}/';
  final nama = path.startsWith(awalan) ? path.substring(awalan.length) : path;
  return nama.replaceAll(r'\', '/');
}

/// Berkas audio di luar folder rekaman sendiri wajib tercatat lisensinya.
bool _butuhLisensi(String relatif) {
  if (!ekstensiAudio.any(relatif.toLowerCase().endsWith)) return false;
  final bagian = relatif.split('/');
  return !(bagian.length > 1 && folderAudioSendiri.contains(bagian.first));
}

/// Peta nama berkas → daftar lisensi dari `LICENSES.csv`.
({Map<String, List<String>> peta, String? galatHeader}) _bacaLisensi(
  File berkas,
) {
  if (!berkas.existsSync()) {
    return (peta: const {}, galatHeader: null);
  }
  final baris = _bacaCsv(berkas.readAsStringSync());
  if (baris.isNotEmpty && baris.first.join(',') != headerLisensi) {
    return (
      peta: const {},
      galatHeader:
          'header assets/audio/LICENSES.csv harus "$headerLisensi", '
          'bukan "${baris.first.join(',')}"',
    );
  }
  final peta = <String, List<String>>{};
  for (final kolom in baris.skip(1)) {
    if (kolom.isEmpty || kolom.first.trim().isEmpty) continue;
    final nama = kolom.first.trim().replaceAll(r'\', '/');
    final lisensi = kolom.length > 3 ? kolom[3].trim() : '';
    peta.putIfAbsent(nama, () => []).add(lisensi);
  }
  return (peta: peta, galatHeader: null);
}

/// CSV sederhana: koma pemisah, kutip ganda untuk kolom berkoma.
List<List<String>> _bacaCsv(String isi) {
  final baris = <List<String>>[];
  var kolom = <String>[];
  final sel = StringBuffer();
  var dalamKutip = false;
  for (var i = 0; i < isi.length; i++) {
    final c = isi[i];
    if (dalamKutip) {
      if (c == '"') {
        if (i + 1 < isi.length && isi[i + 1] == '"') {
          sel.write('"');
          i++;
        } else {
          dalamKutip = false;
        }
      } else {
        sel.write(c);
      }
      continue;
    }
    if (c == '"') {
      dalamKutip = true;
    } else if (c == ',') {
      kolom.add(sel.toString());
      sel.clear();
    } else if (c == '\n') {
      kolom.add(sel.toString());
      sel.clear();
      baris.add(kolom);
      kolom = <String>[];
    } else if (c != '\r') {
      sel.write(c);
    }
  }
  if (sel.isNotEmpty || kolom.isNotEmpty) {
    kolom.add(sel.toString());
    baris.add(kolom);
  }
  return baris;
}

/// Setiap hewan punya rekaman suara di `assets/audio/hewan/<id>.m4a`.
void _suaraHewan(
  Laporan laporan, {
  required Directory audio,
  required Katalog katalog,
  required bool rilis,
}) {
  final hewan = [
    for (final item in katalog.item)
      if (item.hewan != null) item.id,
  ];
  final belum = [
    for (final id in hewan)
      if (!File('${audio.path}/hewan/$id.m4a').existsSync()) id,
  ];
  if (belum.isEmpty) {
    laporan.ok('suara_hewan_lengkap', '${hewan.length} suara hewan tersedia');
    return;
  }
  final pesan =
      '${belum.length} dari ${hewan.length} suara hewan belum ada: '
      '${ringkas([for (final id in belum) 'hewan/$id.m4a'])}';
  if (rilis) {
    laporan.galat('suara_hewan_lengkap', pesan);
  } else {
    laporan.peringatan('suara_hewan_lengkap', pesan);
  }
}

/// Total ukuran `assets/audio` tidak melebihi anggaran.
void _anggaran(Laporan laporan, Directory audio, int batasByte) {
  var total = 0;
  if (audio.existsSync()) {
    for (final entri in audio.listSync(recursive: true)) {
      if (entri is File) total += entri.lengthSync();
    }
  }
  if (total <= batasByte) {
    laporan.ok('anggaran_audio', 'audio ${_mb(total)} dari ${_mb(batasByte)}');
  } else {
    laporan.galat(
      'anggaran_audio',
      'audio ${_mb(total)} melebihi anggaran ${_mb(batasByte)}',
    );
  }
}

String _mb(int byte) => '${(byte / (1024 * 1024)).toStringAsFixed(2)} MB';
