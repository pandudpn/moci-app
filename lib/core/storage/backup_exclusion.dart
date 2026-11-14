import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class BackupExclusion {
  Future<void> exclude(Directory dir);
}

final class MethodChannelBackupExclusion implements BackupExclusion {
  const MethodChannelBackupExclusion();

  static const _channel = MethodChannel('moci/backup');

  @override
  Future<void> exclude(Directory dir) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod<void>('exclude', {'path': dir.path});
    } on PlatformException {
      // Atribut gagal ditulis: data tetap lokal, aplikasi tetap dibuka.
      if (kDebugMode) debugPrint('pengecualian backup gagal: ${dir.path}');
    } on MissingPluginException {
      // kanal belum terpasang; abaikan
    }
  }
}
