import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

void main() {
  group('Android', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final gradle = _read('android/app/build.gradle.kts');
    test('landscape terkunci dan opt-out resizability', () {
      expect(manifest, contains('android:screenOrientation="sensorLandscape"'));
      expect(
        manifest,
        contains(
          'android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY',
        ),
      );
    });
    test('tanpa backup, tanpa izin, berlabel Moci', () {
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, isNot(contains('uses-permission')));
      expect(manifest, contains('android:label="Moci"'));
    });
    test('queries TTS untuk build rilis, tanpa INTERNET', () {
      expect(manifest, contains('android.intent.action.TTS_SERVICE'));
      expect(manifest, isNot(contains('android.permission.INTERNET')));
    });
    test('manifest debug dan profile tidak lagi mendeklarasikan TTS', () {
      for (final f in [
        'android/app/src/debug/AndroidManifest.xml',
        'android/app/src/profile/AndroidManifest.xml',
      ]) {
        expect(_read(f), isNot(contains('TTS_SERVICE')));
      }
    });
    test('level SDK dan application id', () {
      expect(gradle, contains('minSdk = 24'));
      expect(gradle, contains('targetSdk = 36'));
      expect(gradle, contains('applicationId = "id.pandudpn.moci"'));
    });
  });

  group('iOS', () {
    final plist = _read('ios/Runner/Info.plist');
    final pbx = _read('ios/Runner.xcodeproj/project.pbxproj');
    test('landscape saja di iPhone dan iPad, layar penuh', () {
      for (final key in [
        'UISupportedInterfaceOrientations',
        'UISupportedInterfaceOrientations~ipad',
      ]) {
        final block = RegExp(
          '<key>$key</key>\\s*<array>(.*?)</array>',
          dotAll: true,
        ).firstMatch(plist)!.group(1)!;
        expect(block, contains('UIInterfaceOrientationLandscapeLeft'));
        expect(block, contains('UIInterfaceOrientationLandscapeRight'));
        expect(block, isNot(contains('Portrait')));
      }
      expect(
        plist,
        matches(RegExp(r'<key>UIRequiresFullScreen</key>\s*<true/>')),
      );
      expect(
        plist,
        matches(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>Moci</string>'),
        ),
      );
    });
    test('deployment target 15.0 di semua konfigurasi', () {
      final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);')
          .allMatches(pbx)
          .map((m) => m.group(1))
          .toSet();
      expect(targets, {'15.0'});
    });
  });
}
