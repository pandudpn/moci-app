import 'package:flutter/services.dart';

import '../lang.dart';

/// TTS perangkat, dipakai di semua mode build selama rekaman narasi belum ada.
abstract interface class DeviceTts {
  Future<void> speak(String text, AppLang lang);
  Future<void> stop();
}

final class MethodChannelDeviceTts implements DeviceTts {
  const MethodChannelDeviceTts();

  static const _channel = MethodChannel('moci/tts');

  @override
  Future<void> speak(String text, AppLang lang) async {
    try {
      await _channel.invokeMethod<void>('speak', {
        'text': text,
        'lang': lang.name,
      });
    } on PlatformException {
      // TTS perangkat tidak tersedia; narasi lain tetap jalan.
    } on MissingPluginException {
      // Platform tanpa kanal, atau di tes.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Diabaikan.
    } on MissingPluginException {
      // Diabaikan.
    }
  }
}
