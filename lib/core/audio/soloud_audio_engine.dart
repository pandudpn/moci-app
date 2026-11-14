import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'audio_engine.dart';

/// Mesin audio produksi di atas flutter_soloud.
///
/// Selesainya suara dideteksi lewat `AudioSource.soundEvents`
/// (`handleIsNoMoreValid`), yang juga muncul saat suara dihentikan.
final class SoLoudAudioEngine implements AudioEngine {
  SoLoudAudioEngine({SoLoud? soloud}) : _soloud = soloud ?? SoLoud.instance;

  final SoLoud _soloud;
  final _sources = <String, Future<AudioSource?>>{};
  final _subs = <String, StreamSubscription<StreamSoundEvent>>{};
  final _finished = StreamController<SoundId>.broadcast();

  @override
  bool get isReady => _soloud.isInitialized;

  @override
  Future<void> init() async {
    if (_soloud.isInitialized) return;
    await _soloud.init();
  }

  Future<AudioSource?> _load(String asset) =>
      _sources.putIfAbsent(asset, () => _doLoad(asset));

  Future<AudioSource?> _doLoad(String asset) async {
    try {
      final source = await _soloud.loadAsset(asset);
      _subs[asset] = source.soundEvents.listen((e) {
        if (e.event == SoundEventType.handleIsNoMoreValid) {
          _finished.add(e.handle.id);
        }
      });
      return source;
    } catch (e) {
      debugPrint('Audio: gagal memuat $asset ($e)');
      _sources.remove(asset);
      return null;
    }
  }

  @override
  Future<void> preload(String asset) async {
    if (!isReady) return;
    await _load(asset);
  }

  @override
  Future<void> release(String asset) async {
    final pending = _sources.remove(asset);
    await _subs.remove(asset)?.cancel();
    final source = await pending;
    if (source == null || !isReady) return;
    try {
      await _soloud.disposeSource(source);
    } catch (e) {
      debugPrint('Audio: gagal melepas $asset ($e)');
    }
  }

  @override
  Future<SoundId?> play(
    String asset, {
    required double volume,
    bool loop = false,
  }) async {
    if (!isReady) return null;
    final source = await _load(asset);
    if (source == null) return null;
    try {
      final handle = _soloud.play(source, volume: volume, looping: loop);
      return handle.isError ? null : handle.id;
    } catch (e) {
      debugPrint('Audio: gagal memutar $asset ($e)');
      return null;
    }
  }

  @override
  Future<void> stop(SoundId id) async {
    if (!isReady) return;
    try {
      await _soloud.stop(SoundHandle(id));
    } catch (_) {
      // Handle sudah tidak berlaku.
    }
  }

  @override
  Future<void> setVolume(SoundId id, double volume) async {
    if (!isReady) return;
    try {
      _soloud.setVolume(SoundHandle(id), volume);
    } catch (_) {
      // Handle sudah tidak berlaku.
    }
  }

  @override
  Future<void> stopAll() async {
    if (!isReady) return;
    _soloud.stopAll();
  }

  @override
  Stream<SoundId> get onFinished => _finished.stream;
}
