import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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

  group('.gitignore', tesGitignore);
}
