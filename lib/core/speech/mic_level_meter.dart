/// Level suara 0..1 yang dianggap ada suara.
const ambangSuara = 0.12;

/// Jumlah sampel berurutan di atas [ambangSuara] yang menandakan bicara.
const sampelBicara = 6;

/// Jarak antar level dari kanal native.
const jedaLevel = Duration(milliseconds: 50);

/// Benar kalau ada [sampelBicara] nilai berurutan yang mencapai
/// [ambangSuara]; sampel terpisah tidak dijumlahkan.
bool suaraCukup(List<double> level) {
  var urut = 0;
  for (final l in level) {
    if (l >= ambangSuara) {
      urut++;
      if (urut >= sampelBicara) return true;
    } else {
      urut = 0;
    }
  }
  return false;
}

/// Pengukur level suara: cadangan Ucapkan kalau pengenalan luring tidak
/// tersedia. Hanya level yang dibaca, tidak ada rekaman yang disimpan.
abstract interface class MicLevelMeter {
  Future<bool> get available;

  /// Mendengar paling lama [batas]; benar kalau [suaraCukup] tercapai.
  Future<bool> listen({required Duration batas});

  Future<void> stop();
}

/// Platform tanpa kanal level suara: selalu tidak tersedia.
final class NoopMicLevelMeter implements MicLevelMeter {
  const NoopMicLevelMeter();

  @override
  Future<bool> get available async => false;

  @override
  Future<bool> listen({required Duration batas}) async => false;

  @override
  Future<void> stop() async {}
}
