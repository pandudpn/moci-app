import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mic_level_meter.dart';

/// Android dan iOS punya kanal native; platform lain memakai noop.
final micLevelMeterProvider = Provider<MicLevelMeter>((_) {
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return const MethodChannelMicLevelMeter();
  }
  return const NoopMicLevelMeter();
});

/// Level suara dari kanal `moci/mic_level`: 0..1 tiap [jedaLevel].
final class MethodChannelMicLevelMeter implements MicLevelMeter {
  const MethodChannelMicLevelMeter();

  static const _method = MethodChannel('moci/mic_level');
  static const _events = EventChannel('moci/mic_level_events');

  @override
  Future<bool> get available async {
    try {
      return await _method.invokeMethod<bool>('available') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> listen({required Duration batas}) async {
    await stop();
    final level = <double>[];
    final selesai = Completer<bool>();
    void tutup(bool hasil) {
      if (!selesai.isCompleted) selesai.complete(hasil);
    }

    final langganan = _events.receiveBroadcastStream().listen((e) {
      if (e is! num) return;
      level.add(e.toDouble());
      if (level.length > sampelBicara) level.removeAt(0);
      if (suaraCukup(level)) tutup(true);
    }, onError: (Object _) => tutup(false));
    final timer = Timer(batas, () => tutup(false));
    try {
      await _method.invokeMethod<void>('start');
    } on PlatformException {
      // `no_permission` dan galat kanal lain: tidak ada suara yang terbaca.
      tutup(false);
    } on MissingPluginException {
      tutup(false);
    }
    final hasil = await selesai.future;
    timer.cancel();
    await langganan.cancel();
    await stop();
    return hasil;
  }

  @override
  Future<void> stop() async {
    try {
      await _method.invokeMethod<void>('stop');
    } on PlatformException {
      // Kanal tidak siap.
    } on MissingPluginException {
      // Di tes.
    }
  }
}
