import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class AudioSessionConfigurator {
  Future<void> usePlayback();
}

/// iOS: kategori playback supaya suara tetap terdengar saat sakelar senyap
/// menyala. Android tidak butuh apa pun.
final class MethodChannelAudioSession implements AudioSessionConfigurator {
  const MethodChannelAudioSession();

  static const _channel = MethodChannel('moci/audio_session');

  @override
  Future<void> usePlayback() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      await _channel.invokeMethod<void>('playback');
    } on PlatformException {
      // Suara tetap jalan dengan kategori bawaan.
    } on MissingPluginException {
      // Di tes.
    }
  }
}
