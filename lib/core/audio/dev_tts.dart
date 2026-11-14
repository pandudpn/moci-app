import 'package:flutter/services.dart';

import '../lang.dart';

/// TTS perangkat. Hanya untuk build debug dan profile.
abstract interface class DevTts {
  Future<void> speak(String text, AppLang lang);
  Future<void> stop();
}

final class NoopDevTts implements DevTts {
  const NoopDevTts();

  @override
  Future<void> speak(String text, AppLang lang) async {}

  @override
  Future<void> stop() async {}
}

final class MethodChannelDevTts implements DevTts {
  const MethodChannelDevTts();

  static const _channel = MethodChannel('moci/tts');

  @override
  Future<void> speak(String text, AppLang lang) async {
    try {
      await _channel.invokeMethod<void>('speak', {
        'text': text,
        'lang': lang.name,
      });
    } on PlatformException {
      // TTS hanya alat bantu pengembangan.
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
