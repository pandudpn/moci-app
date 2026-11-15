import 'package:flutter_test/flutter_test.dart';

import '../../tool/rilis/naikkan_versi.dart';

void main() {
  group('naikkanVersi', () {
    test('patch raises z and bumps the build number', () {
      expect(naikkanVersi('1.2.3+7', Naik.patch), '1.2.4+8');
    });

    test('minor raises y, resets z, bumps build number', () {
      expect(naikkanVersi('1.2.3+7', Naik.minor), '1.3.0+8');
    });

    test('major raises x, resets y and z, bumps build number', () {
      expect(naikkanVersi('1.2.3+7', Naik.major), '2.0.0+8');
    });

    test('a version without a build number starts at 1', () {
      expect(naikkanVersi('3.4.5', Naik.patch), '3.4.6+1');
    });

    test('malformed versions are rejected', () {
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
    test('recognises all three types', () {
      expect(Naik.dari('patch'), Naik.patch);
      expect(Naik.dari('minor'), Naik.minor);
      expect(Naik.dari('major'), Naik.major);
    });

    test('rejects any other name', () {
      expect(() => Naik.dari('mayor'), throwsFormatException);
    });
  });

  group('gantiVersiPubspec', () {
    const pubspec = '''
name: moci
version: 1.0.0+1

# version: this comment is not changed
dependency_overrides:
''';

    test('replaces only the version line', () {
      final hasil = gantiVersiPubspec(pubspec, '1.0.1+2');
      expect(hasil, contains('\nversion: 1.0.1+2\n'));
      expect(hasil, contains('# version: this comment is not changed'));
      expect(hasil, isNot(contains('version: 1.0.0+1')));
    });

    test('a pubspec without a version line is rejected', () {
      expect(
        () => gantiVersiPubspec('name: moci\n', '1.0.1+2'),
        throwsFormatException,
      );
    });
  });
}
