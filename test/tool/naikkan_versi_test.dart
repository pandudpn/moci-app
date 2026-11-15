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
  group('uraiVersi', () {
    test('reads a bare version, a pubspec version and a prerelease', () {
      expect(uraiVersi('1.2.3').nomor, '1.2.3');
      expect(uraiVersi('1.2.3+7').lengkap, '1.2.3+7');
      expect(uraiVersi('1.2.3-rc.1').nomor, '1.2.3-rc.1');
      expect(uraiVersi('1.2.3-rc.1+9').lengkap, '1.2.3-rc.1+9');
      expect(uraiVersi(' 1.2.3+7 ').lengkap, '1.2.3+7');
    });

    test('rejects anything it cannot parse back', () {
      for (final cacat in [
        '1.2',
        'a.b.c',
        '1.2.3.4',
        '1.2.3+',
        '1.2.3-',
        '1.2.3-rc 1',
        'v1.2.3',
        '',
      ]) {
        expect(() => uraiVersi(cacat), throwsFormatException, reason: cacat);
      }
    });
  });

  group('bacaVersiPubspec', () {
    test('reads the version line', () {
      expect(
        bacaVersiPubspec('name: moci\nversion: 1.2.3+7\ndependencies:\n'),
        '1.2.3+7',
      );
    });

    test('a pubspec with no version line is rejected', () {
      expect(() => bacaVersiPubspec('name: moci\n'), throwsFormatException);
    });

    test('two version lines are ambiguous and rejected', () {
      expect(
        () => bacaVersiPubspec('version: 1.0.0+1\nversion: 1.0.1+2\n'),
        throwsFormatException,
      );
    });
  });

  group('versiBerikutnya', () {
    test('an explicit version is written with the next build number', () {
      expect(versiBerikutnya('1.2.3+7', '2.0.0'), '2.0.0+8');
    });

    test('an explicit prerelease keeps its suffix', () {
      expect(versiBerikutnya('1.2.3+7', '1.3.0-rc.1'), '1.3.0-rc.1+8');
    });

    test('an explicit version bearing a build number is refused', () {
      expect(
        () => versiBerikutnya('1.2.3+7', '2.0.0+1'),
        throwsFormatException,
      );
    });

    test('a prerelease graduates on a patch bump instead of moving', () {
      expect(versiBerikutnya('1.4.0-rc.2+3', 'patch'), '1.4.0+4');
      expect(versiBerikutnya('1.4.0-rc.2+3', 'minor'), '1.5.0+4');
    });

    test('an unknown bump name is refused', () {
      expect(() => versiBerikutnya('1.2.3+7', 'mayor'), throwsFormatException);
    });
  });

  group('periksaTag', () {
    test('accepts a tag that names the pubspec version', () {
      expect(periksaTag('v1.0.1', 'name: moci\nversion: 1.0.1+2\n'), '1.0.1');
    });

    test('a tag without the v prefix is still read', () {
      expect(periksaTag('1.0.1', 'version: 1.0.1+2\n'), '1.0.1');
    });

    test('accepts a prerelease tag that matches', () {
      expect(
        periksaTag('v1.1.0-rc.1', 'version: 1.1.0-rc.1+5\n'),
        '1.1.0-rc.1',
      );
    });

    test('names both numbers when they disagree', () {
      expect(
        () => periksaTag('v1.0.2', 'version: 1.0.1+2\n'),
        throwsA(
          isA<FormatException>().having(
            (galat) => galat.message,
            'message',
            allOf(contains('v1.0.2'), contains('1.0.1+2')),
          ),
        ),
      );
    });

    test('a tag with a build number only has to match x.y.z', () {
      expect(periksaTag('v1.0.1+9', 'version: 1.0.1+2\n'), '1.0.1');
    });
  });
}
