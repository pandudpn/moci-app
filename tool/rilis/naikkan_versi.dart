/// One owner for the version number.
///
/// `pubspec.yaml` holds `x.y.z+n`: the version Flutter stamps on a build and
/// the build number Android needs to grow with every upload. This tool is the
/// only place either number is written, so a tag cannot disagree with what was
/// built.
///
///   fvm dart run tool/rilis/naikkan_versi.dart show
///   fvm dart run tool/rilis/naikkan_versi.dart bump patch
///   fvm dart run tool/rilis/naikkan_versi.dart bump 2.0.0-rc.1
///   fvm dart run tool/rilis/naikkan_versi.dart check v1.0.1
///
/// `show` prints the version in the file. `bump` writes the next one and
/// prints it; the build number always goes up by one, and an explicit version
/// is written as given. `check` fails unless the tag names the same `x.y.z` as
/// the file. No Flutter import, so the release workflow runs it with the SDK's
/// plain `dart`.
library;

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

final _polaVersi = RegExp(
  r'^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+(\d+))?$',
);

/// A version read from a tag or from the pubspec.
final class Versi {
  const Versi(this.x, this.y, this.z, {this.pra = '', this.build = 0});

  final int x;
  final int y;
  final int z;

  /// The prerelease suffix, without the dash: `rc.1` in `1.2.3-rc.1`.
  final String pra;

  /// The build number after the `+`, and 0 when there is none.
  final int build;

  /// `x.y.z`, or `x.y.z-pre`.
  String get nomor => pra.isEmpty ? '$x.$y.$z' : '$x.$y.$z-$pra';

  /// `x.y.z+n`, the shape the pubspec holds.
  String get lengkap => '$nomor+$build';
}

/// Parses `1.2.3`, `1.2.3+4`, `1.2.3-rc.1`, and `1.2.3-rc.1+4`.
///
/// A leading `v` is not accepted, because that is a tag and not a version; [periksaTag]
/// strips it.
Versi uraiVersi(String teks) {
  final cocok = _polaVersi.firstMatch(teks.trim());
  if (cocok == null) {
    throw FormatException(
      'not a version: $teks (expected x.y.z[-pre][+build])',
    );
  }
  return Versi(
    int.parse(cocok.group(1)!),
    int.parse(cocok.group(2)!),
    int.parse(cocok.group(3)!),
    pra: cocok.group(4) ?? '',
    build: int.parse(cocok.group(5) ?? '0'),
  );
}

final _polaBarisVersi = RegExp(r'^version:[ \t]*\S+[ \t]*$', multiLine: true);

/// The `x.y.z+n` recorded in the pubspec [isi].
///
/// A file with zero or two `version:` lines is ambiguous and rejected; comments that
/// mention `version` do not match, because the line has to start with it.
String bacaVersiPubspec(String isi) {
  final cocok = _polaBarisVersi.allMatches(isi).toList();
  if (cocok.length != 1) {
    throw FormatException(
      'pubspec.yaml must have exactly one version: line, found ${cocok.length}',
    );
  }
  return cocok.single.group(0)!.substring('version:'.length).trim();
}

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

/// The next version after [dasar] according to [jenis].
///
/// [jenis] is `patch`, `minor`, `major`, or an explicit version such as `2.0.0-rc.1`.
/// The build number always goes up by one. A prerelease graduates by dropping its suffix
/// on a patch bump instead of moving the number: `1.4.0-rc.2` plus a patch is `1.4.0`.
String versiBerikutnya(String dasar, String jenis) {
  final versi = uraiVersi(dasar);
  final build = versi.build + 1;
  final naik = switch (jenis) {
    'patch' => Naik.patch,
    'minor' => Naik.minor,
    'major' => Naik.major,
    _ => null,
  };
  if (naik == null) {
    final diminta = uraiVersi(jenis);
    if (diminta.build != 0) {
      throw FormatException(
        'an explicit version must not carry a build number: $jenis',
      );
    }
    return '${diminta.nomor}+$build';
  }
  if (versi.pra.isNotEmpty && naik == Naik.patch) {
    return '${versi.x}.${versi.y}.${versi.z}+$build';
  }
  return switch (naik) {
    Naik.patch => '${versi.x}.${versi.y}.${versi.z + 1}+$build',
    Naik.minor => '${versi.x}.${versi.y + 1}.0+$build',
    Naik.major => '${versi.x + 1}.0.0+$build',
  };
}

/// The next version after [versi] according to [jenis].
///
/// Kept for the callers that already hold a [Naik]; [versiBerikutnya] does the work.
String naikkanVersi(String versi, Naik jenis) =>
    versiBerikutnya(versi, jenis.name);

/// Fails unless the tag [tag] names the same `x.y.z` as the pubspec [isi].
///
/// The build number is not part of a tag, so only the number is compared. The tag may
/// carry the `v` the repository uses.
String periksaTag(String tag, String isi) {
  final diTag = uraiVersi(tag.trim().replaceFirst(RegExp(r'^v'), ''));
  final diPubspec = bacaVersiPubspec(isi);
  if (uraiVersi(diPubspec).nomor != diTag.nomor) {
    throw FormatException('tag $tag does not match pubspec.yaml $diPubspec');
  }
  return diTag.nomor;
}

void _pemakaian() {
  stderr.writeln('usage: dart run tool/rilis/naikkan_versi.dart show');
  stderr.writeln(
    '       dart run tool/rilis/naikkan_versi.dart bump '
    '<patch|minor|major|x.y.z[-pre]>',
  );
  stderr.writeln('       dart run tool/rilis/naikkan_versi.dart check vX.Y.Z');
}

void main(List<String> argumen) {
  final pubspec = File('pubspec.yaml');
  if (argumen.isEmpty) {
    _pemakaian();
    exitCode = 64;
    return;
  }
  final perintah = argumen.first;
  final sisa = argumen.sublist(1);
  if ((perintah == 'bump' || perintah == 'check') && sisa.length != 1) {
    _pemakaian();
    exitCode = 64;
    return;
  }

  try {
    final isi = pubspec.readAsStringSync();
    switch (perintah) {
      case 'show':
        stdout.writeln(bacaVersiPubspec(isi));
      case 'bump':
        final baru = versiBerikutnya(bacaVersiPubspec(isi), sisa.single);
        uraiVersi(baru); // refuse to write something we cannot parse back
        pubspec.writeAsStringSync(gantiVersiPubspec(isi, baru));
        stdout.writeln(baru);
      case 'check':
        stdout.writeln(periksaTag(sisa.single, isi));
      default:
        _pemakaian();
        exitCode = 64;
    }
  } on FormatException catch (galat) {
    stderr.writeln('error: ${galat.message}');
    exitCode = perintah == 'check' ? 1 : 65;
  } on FileSystemException catch (galat) {
    stderr.writeln(galat.message);
    exitCode = 66;
  }
}
