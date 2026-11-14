import 'dart:async';

import 'asset_catalog.dart';
import 'audio_engine.dart';
import 'sfx.dart';

/// Aturan prioritas dan volume: narasi > efek > musik.
final class AudioService {
  AudioService({required this._engine, required this._assets}) {
    _sub = _engine.onFinished.listen(_onFinished);
  }

  static const narrationVolume = 1.0;
  static const sfxVolume = 0.7;
  static const musicVolume = 0.25;
  static const musicDuckedVolume = 0.10;
  static const musicAsset = 'assets/audio/musik/latar.ogg';

  final AudioEngine _engine;
  final AssetCatalog _assets;
  late final StreamSubscription<SoundId> _sub;

  bool _musicOn = true;
  bool _sfxOn = true;
  bool _musicRequested = false;

  SoundId? _musicId;
  int _musicGen = 0;
  int? _musicStartingGen;
  bool _ducked = false;

  SoundId? _narrationId;
  String? _narrationAsset;
  Completer<void>? _narrationDone;
  int _narrationGen = 0;

  /// Jumlah panggilan [narrate] yang sedang memuat, per aset. Aset yang
  /// dipakai bersama tidak boleh dilepas selama masih ada yang memakainya.
  final _loading = <String, int>{};

  bool get _ready => _engine.isReady;

  /// Memuat semua efek sekali setelah mesin siap.
  Future<void> preloadSfx() async {
    if (!_ready) return;
    for (final s in Sfx.values) {
      if (_assets.has(s.asset)) await _engine.preload(s.asset);
    }
  }

  Future<SoundId?> narrate(String asset) async {
    // Token diambil sebelum menunggu: panggilan berikutnya selalu menang.
    final gen = ++_narrationGen;
    await _haltNarration();
    if (gen != _narrationGen) return null;
    if (!_ready || !_assets.has(asset)) return null;
    _duck(true);
    _loading.update(asset, (n) => n + 1, ifAbsent: () => 1);
    final SoundId? id;
    try {
      id = await _engine.play(asset, volume: narrationVolume);
    } finally {
      _loading.update(asset, (n) => n - 1);
    }
    if (gen != _narrationGen) {
      // Narasi lain mengambil alih selagi memuat. Hentikan hanya suara ini;
      // sumbernya mungkin dipakai narasi yang lebih baru.
      if (id != null) {
        await _engine.stop(id);
        await _releaseIfUnused(asset);
      }
      return null;
    }
    if (id == null) {
      _duck(false);
      await _releaseIfUnused(asset);
      return null;
    }
    _narrationId = id;
    _narrationAsset = asset;
    _narrationDone = Completer<void>();
    return id;
  }

  Future<void> _releaseIfUnused(String asset) {
    if ((_loading[asset] ?? 0) > 0 || _narrationAsset == asset) {
      return Future.value();
    }
    _loading.remove(asset);
    return _engine.release(asset);
  }

  /// Selesai saat narasi [id] selesai atau dihentikan.
  Future<void> narrationFinished(SoundId id) =>
      id == _narrationId ? _narrationDone!.future : Future.value();

  Future<void> stopNarration() async {
    _narrationGen++;
    await _haltNarration();
  }

  /// Menghentikan narasi yang sedang jalan tanpa menyentuh generasi.
  Future<void> _haltNarration() async {
    final id = _narrationId;
    final asset = _narrationAsset;
    _clearNarration();
    if (id != null) await _engine.stop(id);
    if (asset != null) await _releaseIfUnused(asset);
  }

  Future<void> playSfx(Sfx s) async {
    if (!_sfxOn || !_ready || !_assets.has(s.asset)) return;
    await _engine.play(s.asset, volume: sfxVolume);
  }

  Future<void> startMusic() async {
    _musicRequested = true;
    if (!_musicOn ||
        !_ready ||
        _musicId != null ||
        _musicStartingGen == _musicGen ||
        !_assets.has(musicAsset)) {
      return;
    }
    final gen = _musicGen;
    _musicStartingGen = gen;
    try {
      final id = await _engine.play(
        musicAsset,
        volume: _ducked ? musicDuckedVolume : musicVolume,
        loop: true,
      );
      if (id == null) return;
      if (gen != _musicGen || !_musicOn || !_musicRequested) {
        // Dihentikan selagi memuat (latar belakang, sakelar, stopMusic).
        await _engine.stop(id);
        return;
      }
      _musicId = id;
      // Status narasi bisa berubah selama memuat.
      await _engine.setVolume(id, _ducked ? musicDuckedVolume : musicVolume);
    } finally {
      if (_musicStartingGen == gen) _musicStartingGen = null;
    }
  }

  Future<void> stopMusic() async {
    _musicRequested = false;
    _musicGen++;
    final id = _musicId;
    _musicId = null;
    if (id != null) await _engine.stop(id);
  }

  void applySettings({required bool music, required bool sfx}) {
    final turnedOn = music && !_musicOn;
    _musicOn = music;
    _sfxOn = sfx;
    if (!music) {
      _musicGen++;
      final id = _musicId;
      _musicId = null;
      if (id != null) unawaited(_engine.stop(id));
    } else if (turnedOn && _musicRequested) {
      unawaited(startMusic());
    }
  }

  Future<void> stopAll() async {
    _narrationGen++;
    final asset = _narrationAsset;
    _clearNarration();
    _musicGen++;
    _musicId = null;
    await _engine.stopAll();
    if (asset != null) await _releaseIfUnused(asset);
  }

  Future<void> dispose() => _sub.cancel();

  void _clearNarration() {
    _narrationId = null;
    _narrationAsset = null;
    final done = _narrationDone;
    _narrationDone = null;
    if (done != null && !done.isCompleted) done.complete();
    _duck(false);
  }

  void _duck(bool ducked) {
    _ducked = ducked;
    final id = _musicId;
    if (id == null) return;
    unawaited(_engine.setVolume(id, ducked ? musicDuckedVolume : musicVolume));
  }

  void _onFinished(SoundId id) {
    if (id == _narrationId) {
      final asset = _narrationAsset;
      _clearNarration();
      if (asset != null) unawaited(_releaseIfUnused(asset));
    } else if (id == _musicId) {
      _musicId = null;
    }
  }
}
