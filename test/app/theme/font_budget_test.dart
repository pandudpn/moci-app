import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const files = [
    'Fredoka-Regular',
    'Fredoka-Medium',
    'Fredoka-SemiBold',
    'Fredoka-Bold',
    'Nunito-SemiBold',
    'Nunito-Bold',
    'Nunito-ExtraBold',
    'Nunito-Black',
  ];

  test('delapan berkas font dan dua lisensi OFL ada', () {
    for (final f in files) {
      expect(File('assets/fonts/$f.ttf').existsSync(), isTrue, reason: f);
    }
    expect(File('assets/fonts/OFL-Fredoka.txt').existsSync(), isTrue);
    expect(File('assets/fonts/OFL-Nunito.txt').existsSync(), isTrue);
  });

  test('total ukuran font < 1 MB', () {
    final dir = Directory('assets/fonts');
    expect(dir.existsSync(), isTrue);
    final total = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.ttf'))
        .fold<int>(0, (s, f) => s + f.lengthSync());
    expect(total, lessThan(1000000));
  });
}
