// Menaikkan versi `x.y.z+n` di pubspec.yaml.
//
//   fvm dart run tool/rilis/naikkan_versi.dart patch
//
// Mencetak versi baru, misalnya `1.0.1+2`. Dipakai workflow Rilis; tanpa
// impor Flutter supaya bisa jalan dengan `dart` biasa di runner Linux.
import 'dart:io';

/// Jenis kenaikan versi.
enum Naik {
  patch,
  minor,
  major;

  /// Membaca nama jenis dari argumen CLI.
  static Naik dari(String nama) => switch (nama) {
    'patch' => Naik.patch,
    'minor' => Naik.minor,
    'major' => Naik.major,
    _ => throw FormatException('jenis kenaikan tidak dikenal: $nama'),
  };
}

final _polaVersi = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');

/// Versi berikutnya dari [versi] menurut [jenis].
///
/// Nomor build selalu naik satu. Versi cacat melempar [FormatException].
String naikkanVersi(String versi, Naik jenis) {
  final cocok = _polaVersi.firstMatch(versi.trim());
  if (cocok == null) {
    throw FormatException('versi tidak sah: $versi');
  }
  final x = int.parse(cocok.group(1)!);
  final y = int.parse(cocok.group(2)!);
  final z = int.parse(cocok.group(3)!);
  final build = int.parse(cocok.group(4) ?? '0') + 1;
  return switch (jenis) {
    Naik.patch => '$x.$y.${z + 1}+$build',
    Naik.minor => '$x.${y + 1}.0+$build',
    Naik.major => '${x + 1}.0.0+$build',
  };
}

final _polaBarisVersi = RegExp(r'^version:[ \t]*\S+[ \t]*$', multiLine: true);

/// Mengganti baris `version:` di [isi] pubspec dengan [versiBaru].
///
/// Komentar yang menyebut kata `version` tidak tersentuh karena hanya baris
/// yang diawali `version:` yang cocok.
String gantiVersiPubspec(String isi, String versiBaru) {
  final cocok = _polaBarisVersi.allMatches(isi).toList();
  if (cocok.length != 1) {
    throw FormatException(
      'pubspec.yaml harus punya satu baris version:, ditemukan ${cocok.length}',
    );
  }
  final baris = cocok.single;
  return isi.replaceRange(baris.start, baris.end, 'version: $versiBaru');
}

void main(List<String> argumen) {
  if (argumen.length != 1) {
    stderr.writeln(
      'pakai: dart run tool/rilis/naikkan_versi.dart <patch|minor|major>',
    );
    exit(64);
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('pubspec.yaml tidak ditemukan; jalankan dari akar repo');
    exit(66);
  }

  try {
    final jenis = Naik.dari(argumen.single);
    final isi = pubspec.readAsStringSync();
    final baris = _polaBarisVersi.firstMatch(isi);
    if (baris == null) {
      throw const FormatException('pubspec.yaml tanpa baris version:');
    }
    final versiLama = baris.group(0)!.substring('version:'.length).trim();
    final versiBaru = naikkanVersi(versiLama, jenis);
    pubspec.writeAsStringSync(gantiVersiPubspec(isi, versiBaru));
    stdout.writeln(versiBaru);
  } on FormatException catch (galat) {
    stderr.writeln(galat.message);
    exit(65);
  }
}
