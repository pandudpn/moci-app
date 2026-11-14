import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/audio/audio_engine.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/audio_service.dart';
import '../../core/prefs/prefs_controller.dart';
import 'instrumen.dart';

/// Pemutar nada Main Musik. Nada adalah efek: volumenya mengikuti
/// `AudioService.sfxVolume` dan sakelar Efek suara, tanpa menghentikan narasi.
final musikAudioProvider = Provider<MusikAudio>((ref) {
  final audio = MusikAudio(engine: ref.watch(audioEngineProvider));
  ref.listen(
    prefsProvider.select((p) => p.sfx),
    (_, aktif) => audio.aktif = aktif,
    fireImmediately: true,
  );
  ref.onDispose(audio.dispose);
  return audio;
});

final class MusikAudio {
  MusikAudio({required this.engine});

  final AudioEngine engine;

  /// Sakelar Efek suara; nada tidak diputar saat mati.
  bool aktif = true;

  final _hidup = <SoundId>{};
  int _gen = 0;
  bool _disposed = false;

  Future<void> preload() async {
    for (final nama in daftarInstrumen) {
      await engine.preload(pathInstrumen(nama));
    }
  }

  Future<void> bunyikan(String nama) async {
    if (!aktif || _disposed || !engine.isReady) return;
    final gen = _gen;
    final id = await engine.play(
      pathInstrumen(nama),
      volume: AudioService.sfxVolume,
    );
    if (id == null) return;
    // Ganti lagu/mode atau keluar layar selagi memuat: jangan tinggalkan nada.
    if (_disposed || gen != _gen) {
      await engine.stop(id);
      return;
    }
    _hidup.add(id);
  }

  Future<void> berhenti() async {
    _gen++;
    final ids = [..._hidup];
    _hidup.clear();
    for (final id in ids) {
      await engine.stop(id);
    }
  }

  void dispose() {
    _disposed = true;
    unawaited(berhenti());
  }
}
