import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/storage/backup_exclusion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kanal = MethodChannel('moci/backup');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(kanal, null);
  });

  test('galat kanal iOS tidak membatalkan startup', () async {
    final dipanggil = <String>[];
    messenger.setMockMethodCallHandler(kanal, (panggilan) async {
      dipanggil.add(panggilan.method);
      throw PlatformException(code: 'exclude_failed');
    });

    await const MethodChannelBackupExclusion().exclude(Directory.systemTemp);

    expect(dipanggil, ['exclude']);
  });
}
