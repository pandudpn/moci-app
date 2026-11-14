import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  const res = 'android/app/src/main/res';
  const ios = 'ios/Runner/Assets.xcassets';

  test('file brand tujuan ada', () {
    final files = [
      '$ios/AppIcon.appiconset/Contents.json',
      '$ios/AppIcon.appiconset/moci-icon-1024.png',
      '$ios/AppIcon.appiconset/moci-icon-dark-1024.png',
      '$ios/AppIcon.appiconset/moci-icon-tinted-1024.png',
      '$ios/LaunchLogo.imageset/Contents.json',
      '$ios/LaunchLogo.imageset/splash-logo@3x.png',
      '$res/mipmap-anydpi-v26/ic_launcher.xml',
      for (final n in ['foreground', 'background', 'monochrome'])
        '$res/drawable-nodpi/ic_launcher_$n.png',
      for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'])
        '$res/mipmap-$d/ic_launcher.png',
      '$res/drawable-xxxhdpi/splash_logo.png',
      '$res/drawable-xxxhdpi/splash_icon.png',
      '$res/values-v31/styles.xml',
    ];
    for (final f in files) {
      expect(File(f).existsSync(), isTrue, reason: f);
    }
  });

  test('ikon adaptif memuat monochrome', () {
    expect(
      _read('$res/mipmap-anydpi-v26/ic_launcher.xml'),
      contains('<monochrome'),
    );
  });

  test('splash Android 12+ memakai ikon animasi', () {
    expect(
      _read('$res/values-v31/styles.xml'),
      contains('windowSplashScreenAnimatedIcon'),
    );
  });

  test('warna latar splash', () {
    expect(_read('$res/values/colors.xml'), contains('#74C4FF'));
  });

  test('ikon iOS punya varian gelap dan tinted', () {
    final json = _read('$ios/AppIcon.appiconset/Contents.json');
    expect(json, contains('"luminosity"'));
    expect(json, contains('"tinted"'));
  });
}
