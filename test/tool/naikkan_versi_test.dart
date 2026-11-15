import 'package:flutter_test/flutter_test.dart';

import '../../tool/rilis/naikkan_versi.dart';

void main() {
  group('naikkanVersi', () {
    test('patch menaikkan z dan nomor build', () {
      expect(naikkanVersi('1.2.3+7', Naik.patch), '1.2.4+8');
    });

    test('minor menaikkan y, memulangkan z, dan nomor build', () {
      expect(naikkanVersi('1.2.3+7', Naik.minor), '1.3.0+8');
    });

    test('major menaikkan x, memulangkan y dan z, dan nomor build', () {
      expect(naikkanVersi('1.2.3+7', Naik.major), '2.0.0+8');
    });

    test('versi tanpa nomor build mulai dari 1', () {
      expect(naikkanVersi('3.4.5', Naik.patch), '3.4.6+1');
    });

    test('versi cacat ditolak', () {
      for (final cacat in ['1.2', 'a.b.c+1', '1.2.3.4', 'v1.2.3+1', '']) {
        expect(
          () => naikkanVersi(cacat, Naik.patch),
          throwsFormatException,
          reason: cacat,
        );
      }
    });
  });

  group('Naik.dari', () {
    test('mengenali ketiga jenis', () {
      expect(Naik.dari('patch'), Naik.patch);
      expect(Naik.dari('minor'), Naik.minor);
      expect(Naik.dari('major'), Naik.major);
    });

    test('menolak nama lain', () {
      expect(() => Naik.dari('mayor'), throwsFormatException);
    });
  });

  group('gantiVersiPubspec', () {
    const pubspec = '''
name: moci
version: 1.0.0+1

# version: komentar tidak diubah
dependency_overrides:
''';

    test('hanya mengganti baris version', () {
      final hasil = gantiVersiPubspec(pubspec, '1.0.1+2');
      expect(hasil, contains('\nversion: 1.0.1+2\n'));
      expect(hasil, contains('# version: komentar tidak diubah'));
      expect(hasil, isNot(contains('version: 1.0.0+1')));
    });

    test('pubspec tanpa baris version ditolak', () {
      expect(
        () => gantiVersiPubspec('name: moci\n', '1.0.1+2'),
        throwsFormatException,
      );
    });
  });
}
