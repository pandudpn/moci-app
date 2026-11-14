import 'dart:io';

import 'package:flutter/services.dart';

abstract interface class BackupExclusion {
  Future<void> exclude(Directory dir);
}

final class MethodChannelBackupExclusion implements BackupExclusion {
  const MethodChannelBackupExclusion();

  static const _channel = MethodChannel('moci/backup');

  @override
  Future<void> exclude(Directory dir) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('exclude', {'path': dir.path});
    } on MissingPluginException {
      // kanal belum terpasang; abaikan
    }
  }
}
