import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/progress/progress_controller.dart';
import 'stiker.dart';

/// Hasil satu ronde: bintang dan (kalau masih ada yang belum dimiliki) satu stiker.
final class AwardResult {
  const AwardResult({required this.stars, this.sticker});

  final int stars;
  final String? sticker;
}

/// Data rute `/hebat`, dikirim lewat `state.extra`.
final class HebatArgs {
  const HebatArgs({required this.award, required this.replayRoute});

  final AwardResult award;

  /// Rute permainan untuk "Main lagi".
  final String replayRoute;
}

/// Sumber acak pemilih stiker; tes menggantinya dengan yang tetap.
final hadiahRandomProvider = Provider<Random>((ref) => Random());

final hadiahProvider = Provider<HadiahController>(HadiahController.new);

/// Memberi hadiah ronde: 3 bintang dan satu stiker baru acak (D10).
class HadiahController {
  HadiahController(this._ref);

  /// Bintang per ronde.
  static const starsPerRound = 3;

  final Ref _ref;

  /// Hasil per ronde, di memori: ronde yang sama tidak diberi hadiah dua kali.
  final _results = <String, AwardResult>{};

  /// Dipanggil sekali saat ronde selesai. Panggilan ulang dengan [roundId]
  /// yang sama mengembalikan hasil yang sama dan tidak mengubah apa pun.
  Future<AwardResult> finishGame({
    required String gameId,
    required String roundId,
  }) async {
    final prior = _results[roundId];
    if (prior != null) return prior;

    final progress = _ref.read(progressProvider.notifier);
    final owned = _ref.read(progressProvider).stickers;
    final fresh = [
      for (final id in stickerCatalog)
        if (!owned.contains(id)) id,
    ];
    final sticker = fresh.isEmpty
        ? null
        : fresh[_ref.read(hadiahRandomProvider).nextInt(fresh.length)];
    final result = AwardResult(stars: starsPerRound, sticker: sticker);
    // Dicatat sebelum menunggu penyimpanan: state sudah berubah serempak
    // di sini, jadi panggilan berikutnya tidak boleh memberi hadiah lagi.
    _results[roundId] = result;

    final saves = [
      progress.addStars(starsPerRound),
      if (sticker != null) progress.addSticker(sticker),
    ];
    for (final save in saves) {
      try {
        await save;
      } on Object {
        // Gagal menulis ke disk tidak boleh menahan hadiah anak; state di memori sudah benar.
      }
    }
    return result;
  }
}
