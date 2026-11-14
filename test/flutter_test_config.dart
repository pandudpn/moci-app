import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Berkas font bundel per keluarga, sesuai `pubspec.yaml`.
const _fonts = {
  'Fredoka': [
    'Fredoka-Regular',
    'Fredoka-Medium',
    'Fredoka-SemiBold',
    'Fredoka-Bold',
  ],
  'Nunito': [
    'Nunito-SemiBold',
    'Nunito-Bold',
    'Nunito-ExtraBold',
    'Nunito-Black',
  ],
};

/// Memuat Fredoka dan Nunito untuk semua tes. Tanpa ini tes memakai Ahem:
/// golden tidak mirip aslinya dan tata letak yang rapat tidak teruji.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final MapEntry(key: family, value: names) in _fonts.entries) {
    final loader = FontLoader(family);
    for (final n in names) {
      loader.addFont(rootBundle.load('assets/fonts/$n.ttf'));
    }
    await loader.load();
  }
  await testMain();
}
