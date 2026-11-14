import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../prefs/prefs_controller.dart';
import 'asset_catalog.dart';
import 'audio_engine.dart';
import 'audio_service.dart';
import 'audio_session.dart';
import 'device_tts.dart';
import 'narrator.dart';
import 'soloud_audio_engine.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) => SoLoudAudioEngine());

/// Diganti dengan katalog sungguhan di `runMoci`.
final assetCatalogProvider = Provider<AssetCatalog>(
  (ref) => const AssetCatalog({}),
);

final deviceTtsProvider = Provider<DeviceTts>(
  (ref) => const MethodChannelDeviceTts(),
);

final audioSessionProvider = Provider<AudioSessionConfigurator>(
  (ref) => const MethodChannelAudioSession(),
);

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(
    engine: ref.watch(audioEngineProvider),
    assets: ref.watch(assetCatalogProvider),
  );
  ref.listen(
    prefsProvider.select((p) => (music: p.music, sfx: p.sfx)),
    (_, s) => service.applySettings(music: s.music, sfx: s.sfx),
    fireImmediately: true,
  );
  ref.onDispose(service.dispose);
  return service;
});

final narratorProvider = Provider<Narrator>(
  (ref) => Narrator(
    audio: ref.watch(audioServiceProvider),
    assets: ref.watch(assetCatalogProvider),
    tts: ref.watch(deviceTtsProvider),
  ),
);

/// Dibaca setelah frame pertama; tidak pernah melempar.
final audioBootProvider = FutureProvider<void>((ref) async {
  try {
    await ref.read(audioSessionProvider).usePlayback();
    await ref.read(audioEngineProvider).init();
    await ref.read(audioServiceProvider).preloadSfx();
  } catch (e) {
    debugPrint('Audio: init gagal ($e)');
  }
});
