import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Folder akar yang membuat token di backtick dianggap path repo.
const _akarRepo = [
  'lib/',
  'test/',
  'tool/',
  'assets/',
  'docs/',
  'l10n/',
  'integration_test/',
  'ios/',
  'android/',
  '.github/',
];

/// Path yang disebut dokumen tetapi memang tidak boleh ada di repo.
const _sengajaTidakAda = {'android/key.properties'};

/// Path repo yang disebut [markdown].
///
/// Sumbernya dua: tautan relatif `[..](path)` dan token di dalam backtick yang
/// diawali salah satu [_akarRepo]. URL, anchor, pola glob, dan placeholder
/// (`*`, `<`, `>`) dilewati.
List<String> pathRepoDi(String markdown) {
  bool kandidat(String p) =>
      _akarRepo.any(p.startsWith) &&
      !p.contains('*') &&
      !p.contains('<') &&
      !p.contains('>');

  final hasil = <String>{};
  for (final m in RegExp(r'\]\(([^)\s]+)\)').allMatches(markdown)) {
    final p = m.group(1)!.split('#').first;
    if (kandidat(p)) hasil.add(p);
  }
  for (final m in RegExp(r'`([^`\n]+)`').allMatches(markdown)) {
    final p = m.group(1)!.trim();
    if (kandidat(p)) hasil.add(p);
  }
  return [
    for (final p in hasil) p.endsWith('/') ? p.substring(0, p.length - 1) : p,
  ]..sort();
}

/// Dokumen root yang setiap path-nya harus ada di repo.
const _dokumenRoot = ['AGENTS.md', 'CONTRIBUTING.md'];

void tesPathDokumenRoot() {
  for (final dokumen in _dokumenRoot) {
    test('path yang disebut $dokumen ada', () {
      final paths = pathRepoDi(File(dokumen).readAsStringSync());
      expect(paths, isNotEmpty, reason: '$dokumen tidak menyebut path repo');
      for (final p in paths) {
        if (_sengajaTidakAda.contains(p)) continue;
        expect(
          FileSystemEntity.typeSync(p) != FileSystemEntityType.notFound,
          isTrue,
          reason: '$dokumen: $p',
        );
      }
    });
  }
}

/// Path yang wajib ditolak `.gitignore`.
const _ditolak = [
  '.fvm/flutter_sdk',
  '.superpowers/sdd/x',
  'build/x',
  '.dart_tool/x',
  'ios/Pods/x',
  'android/key.properties',
  'android/app/upload.jks',
  'release.keystore',
  'cert.p12',
  '.env',
  '.DS_Store',
  'coverage/lcov.info',
  '.idea/x',
];

/// Path yang harus tetap bisa di-commit.
const _diizinkan = ['.fvmrc', 'pubspec.lock', 'assets/audio/LICENSES.csv'];

int _cekIgnore(String path) =>
    Process.runSync('git', ['check-ignore', '-q', path]).exitCode;

/// Aturan `.gitignore` dites terpisah supaya dokumen lain bisa menambah grup
/// sendiri di `main`.
void tesGitignore() {
  test('menolak rahasia signing dan artefak build', () {
    for (final path in _ditolak) {
      expect(_cekIgnore(path), 0, reason: path);
    }
  });

  test('membiarkan berkas konfigurasi yang di-commit', () {
    for (final path in _diizinkan) {
      expect(_cekIgnore(path), 1, reason: path);
    }
  });
}

void main() {
  group('LICENSE', () {
    test('diawali pernyataan hak cipta pemilik', () {
      final s = File('LICENSE').readAsStringSync();
      expect(s.startsWith('Hak cipta (c) 2026'), isTrue);
      expect(s, contains('Open Font License'));
    });
  });

  group('CONTRIBUTING.md', () {
    test('memuat perintah tes dan pencatatan lisensi audio', () {
      final s = File('CONTRIBUTING.md').readAsStringSync();
      expect(s, contains('fvm flutter test'));
      expect(s, contains('LICENSES.csv'));
    });
  });

  group('AGENTS.md', () {
    test('memuat perintah inti', () {
      final s = File('AGENTS.md').readAsStringSync();
      for (final cmd in [
        'fvm flutter test',
        'fvm flutter analyze',
        'fvm dart run tool/validate_content.dart',
        'material_ui',
      ]) {
        expect(s, contains(cmd));
      }
    });

    test('menyebut aturan audio yang lebih ketat', () {
      final s = File('AGENTS.md').readAsStringSync();
      expect(s, contains('CC0'));
      expect(s, contains('Milik sendiri'));
      expect(s, contains('lisensi_audio_lengkap'));
    });
  });

  group('CLAUDE.md', () {
    test('hanya merujuk AGENTS.md', () {
      final lines = File('CLAUDE.md')
          .readAsLinesSync()
          .where((l) => l.trim().isNotEmpty)
          .toList();
      expect(lines, contains('@AGENTS.md'));
      expect(lines.length, lessThanOrEqualTo(2));
    });
  });

  group('path dokumen root', tesPathDokumenRoot);

  group('.gitignore', tesGitignore);
}
