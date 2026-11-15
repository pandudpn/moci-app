// Bumps the `x.y.z+n` version in pubspec.yaml.
//
//   fvm dart run tool/rilis/naikkan_versi.dart patch
//
// Prints the new version, for example `1.0.1+2`. Used by the Release
// workflow; no Flutter import so it also runs with plain `dart` on a Linux
// runner.
import 'dart:io';

/// Version bump type.
enum Naik {
  patch,
  minor,
  major;

  /// Reads the bump type from a CLI argument.
  static Naik dari(String nama) => switch (nama) {
    'patch' => Naik.patch,
    'minor' => Naik.minor,
    'major' => Naik.major,
    _ => throw FormatException('unknown bump type: $nama'),
  };
}

final _polaVersi = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');

/// The next version after [versi] according to [jenis].
///
/// The build number always goes up by one. A malformed version throws
/// [FormatException].
String naikkanVersi(String versi, Naik jenis) {
  final cocok = _polaVersi.firstMatch(versi.trim());
  if (cocok == null) {
    throw FormatException('invalid version: $versi');
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

/// Replaces the `version:` line in the pubspec [isi] with [versiBaru].
///
/// Comments that mention `version` are left alone, because only a line that
/// starts with `version:` matches.
String gantiVersiPubspec(String isi, String versiBaru) {
  final cocok = _polaBarisVersi.allMatches(isi).toList();
  if (cocok.length != 1) {
    throw FormatException(
      'pubspec.yaml must have exactly one version: line, found ${cocok.length}',
    );
  }
  final baris = cocok.single;
  return isi.replaceRange(baris.start, baris.end, 'version: $versiBaru');
}

void main(List<String> argumen) {
  if (argumen.length != 1) {
    stderr.writeln(
      'usage: dart run tool/rilis/naikkan_versi.dart <patch|minor|major>',
    );
    exit(64);
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('pubspec.yaml not found; run this from the repo root');
    exit(66);
  }

  try {
    final jenis = Naik.dari(argumen.single);
    final isi = pubspec.readAsStringSync();
    final baris = _polaBarisVersi.firstMatch(isi);
    if (baris == null) {
      throw const FormatException('pubspec.yaml has no version: line');
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
