import 'dart:async';

import 'package:moci/core/audio/audio_engine.dart';
import 'package:moci/core/audio/dev_tts.dart';
import 'package:moci/core/lang.dart';

typedef PlayRecord = ({String asset, double volume, bool loop, SoundId id});

/// Mesin audio palsu: mencatat semua panggilan dan tidak memutar apa pun.
final class FakeAudioEngine implements AudioEngine {
  final plays = <PlayRecord>[];
  final stopped = <SoundId>[];
  final volumes = <SoundId, double>{};
  final preloaded = <String>[];
  final released = <String>[];
  int stopAllCount = 0;
  int initCount = 0;
  bool ready = true;

  /// Pemuatan aset yang tertahan sampai gerbangnya diselesaikan.
  final gates = <String, Completer<void>>{};

  /// Penghentian suara yang tertahan sampai gerbangnya diselesaikan.
  final stopGates = <SoundId, Completer<void>>{};

  /// Suara yang sedang hidup: id -> aset.
  final live = <SoundId, String>{};

  bool isLive(SoundId id) => live.containsKey(id);

  /// Aset yang sengaja gagal dimuat (play mengembalikan null).
  final failing = <String>{};

  /// play melempar galat, seperti mesin yang mati di tengah jalan.
  bool gagalPlay = false;

  int _next = 1;
  final _finished = StreamController<SoundId>.broadcast();

  @override
  bool get isReady => ready;

  @override
  Future<void> init() async {
    initCount++;
    ready = true;
  }

  @override
  Future<void> preload(String asset) async => preloaded.add(asset);

  @override
  Future<void> release(String asset) async {
    released.add(asset);
    // Seperti disposeSource: semua suara aset ini mati, tanpa event ke Dart.
    live.removeWhere((_, a) => a == asset);
  }

  @override
  Future<SoundId?> play(
    String asset, {
    required double volume,
    bool loop = false,
  }) async {
    final gate = gates[asset];
    if (gate != null) await gate.future;
    if (gagalPlay) throw StateError('mesin audio gagal');
    if (failing.contains(asset)) return null;
    final id = _next++;
    plays.add((asset: asset, volume: volume, loop: loop, id: id));
    volumes[id] = volume;
    live[id] = asset;
    return id;
  }

  @override
  Future<void> stop(SoundId id) async {
    stopped.add(id);
    final gate = stopGates[id];
    if (gate != null) await gate.future;
    // SoLoud mengirim event selesai juga saat suara dihentikan.
    if (live.remove(id) != null) _finished.add(id);
  }

  @override
  Future<void> setVolume(SoundId id, double volume) async =>
      volumes[id] = volume;

  @override
  Future<void> stopAll() async {
    stopAllCount++;
    final ids = live.keys.toList();
    live.clear();
    ids.forEach(_finished.add);
  }

  @override
  Stream<SoundId> get onFinished => _finished.stream;

  void finish(SoundId id) {
    live.remove(id);
    _finished.add(id);
  }
}

final class FakeDevTts implements DevTts {
  final spoken = <(String, AppLang)>[];
  int stopCount = 0;

  @override
  Future<void> speak(String text, AppLang lang) async =>
      spoken.add((text, lang));

  @override
  Future<void> stop() async => stopCount++;
}
