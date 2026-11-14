typedef SoundId = int;

/// Pembungkus mesin audio. Diganti `FakeAudioEngine` di tes.
abstract interface class AudioEngine {
  /// `true` setelah [init] selesai dan mesin siap memutar.
  bool get isReady;

  Future<void> init();
  Future<void> preload(String asset);
  Future<void> release(String asset);

  /// Memuat aset kalau belum dimuat. Mengembalikan null kalau aset gagal dimuat.
  Future<SoundId?> play(
    String asset, {
    required double volume,
    bool loop = false,
  });

  Future<void> stop(SoundId id);
  Future<void> setVolume(SoundId id, double volume);
  Future<void> stopAll();

  /// Muncul saat suara selesai, termasuk saat dihentikan.
  Stream<SoundId> get onFinished;
}
