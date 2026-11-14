import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/routes.dart';

void main() {
  group('tujuan lanjut gerbang', () {
    test('rute internal yang dikenal diterima', () {
      for (final path in [
        Routes.orangTua,
        Routes.huruf,
        Routes.angka,
        Routes.cocokkan,
        Routes.mewarnai,
        Routes.karyaku,
      ]) {
        expect(tujuanLanjut(path), path, reason: path);
      }
    });

    test('halaman mewarnai berpola diterima', () {
      expect(tujuanLanjut('${Routes.mewarnai}/3'), '${Routes.mewarnai}/3');
    });

    test('tujuan luar dan tak dikenal ditolak', () {
      for (final path in [
        null,
        '',
        'https://contoh.id/orang-tua',
        'http://contoh.id',
        '//contoh.id',
        'javascript:alert(1)',
        'orang-tua',
        '/tidak-ada',
        '/orang-tua?x=1',
        '/mewarnai/3/4',
        '/mewarnai/',
        Routes.splash,
        Routes.gerbang,
        Routes.gerbangLanjut(Routes.orangTua),
      ]) {
        expect(tujuanLanjut(path), isNull, reason: '$path');
      }
    });
  });
}
