import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/audio/narrator.dart';
import '../../core/content/katalog.dart';
import '../../features/hadiah/hadiah_controller.dart';
import '../../l10n/l10n.dart';

/// Enam permainan Main Yuk beserta warna, bayangan, dan usia minimumnya.
enum MainYukGame {
  cocokkan(Routes.cocokkan, Color(0xFFFF7EB6), Color(0xFFE0528F), 2),
  memori(Routes.memori, Color(0xFF4DA8FF), Color(0xFF2A84E0), 3),
  bayangan(Routes.bayangan, Color(0xFF9775FA), Color(0xFF7048E8), 2),
  puzzle(Routes.puzzle, Color(0xFFFFB020), Color(0xFFE0870B), 3),
  balon(Routes.balon, Color(0xFF22C1C3), Color(0xFF129A9C), 4),
  besarKecil(Routes.besarKecil, Color(0xFF5FD068), Color(0xFF3BAA45), 2);

  const MainYukGame(this.route, this.color, this.shadow, this.usiaMinimum);

  final String route;
  final Color color;
  final Color shadow;
  final int usiaMinimum;

  /// Id permainan untuk `finishGame` dan awalan `roundId`.
  String get id => name;

  /// Kunci ARB judul kartu hub, sekaligus id narasinya.
  String get labelKey =>
      'mainYuk${name[0].toUpperCase()}${name.substring(1)}Hub';

  String labelHub(AppLocalizations l10n) => switch (this) {
    cocokkan => l10n.mainYukCocokkanHub,
    memori => l10n.mainYukMemoriHub,
    bayangan => l10n.mainYukBayanganHub,
    puzzle => l10n.mainYukPuzzleHub,
    balon => l10n.mainYukBalonHub,
    besarKecil => l10n.mainYukBesarKecilHub,
  };

  String labelUsia(AppLocalizations l10n) => switch (usiaMinimum) {
    2 => l10n.mainYukAge2,
    3 => l10n.mainYukAge3,
    _ => l10n.mainYukAge4,
  };
}

/// Tema isi permainan. `acak` memilih salah satu kategori katalog.
enum MainYukTema {
  acak(null),
  buah('buah'),
  hewan('hewan'),
  sayur('sayur'),
  kendaraan('kendaraan'),
  benda('benda');

  const MainYukTema(this.kategori);

  /// Kolom `kategori` di katalog; `null` untuk [acak].
  final String? kategori;

  static const pilihan = [acak, buah, hewan, sayur, kendaraan, benda];

  String label(AppLocalizations l10n) => switch (this) {
    acak => l10n.mainYukTemaAcak,
    buah => l10n.mainYukTemaBuah,
    hewan => l10n.mainYukTemaHewan,
    sayur => l10n.mainYukTemaSayur,
    kendaraan => l10n.mainYukTemaKendaraan,
    benda => l10n.mainYukTemaBenda,
  };
}

/// Ronde satu permainan: tema terpilih dan benda-bendanya.
///
/// [tema] `acak` memilih satu kategori selain [hindari] (tema ronde lalu).
({MainYukTema tema, List<Item> item}) pilihTema(
  Katalog katalog,
  MainYukTema tema, {
  required Random random,
  MainYukTema? hindari,
}) {
  var dipilih = tema;
  if (dipilih == MainYukTema.acak) {
    final kandidat = [
      for (final t in MainYukTema.pilihan)
        if (t != MainYukTema.acak && t != hindari) t,
    ];
    dipilih = kandidat[random.nextInt(kandidat.length)];
  }
  return (tema: dipilih, item: katalog.byKategori(dipilih.kategori!).toList());
}

NarrationLine barisUi(String id, String text) =>
    NarrationLine(jenis: 'ui', id: id, text: text);

NarrationLine barisNama(String id, String text) =>
    NarrationLine(jenis: 'nama', id: id, text: text);

NarrationLine barisHuruf(String huruf, String text) =>
    NarrationLine(jenis: 'huruf', id: huruf.toLowerCase(), text: text);

/// Sumber acak semua permainan; tes menggantinya dengan `Random(seed)`.
final gameRandomProvider = Provider<Random>((_) => Random());

/// Nomor ronde unik sepanjang sesi aplikasi.
///
/// Nomor milik layar mulai dari 1 lagi setiap layar dibangun ulang, sedangkan
/// `finishGame` menyimpan hasil per `gameId/roundId` dan akan menyajikan
/// hadiah lama tanpa menambah bintang.
final class MainYukRoundSeq extends Notifier<int> {
  @override
  int build() => 0;

  String next(String gameId) {
    state += 1;
    return '$gameId-$state';
  }
}

final mainYukRoundSeqProvider = NotifierProvider<MainYukRoundSeq, int>(
  MainYukRoundSeq.new,
);

/// Memberi hadiah satu ronde lalu membuka Hebat.
Future<void> selesaikanRonde(
  BuildContext context,
  WidgetRef ref, {
  required String gameId,
  required String roundId,
  required String replayRoute,
}) async {
  final award = await ref
      .read(hadiahProvider)
      .finishGame(gameId: gameId, roundId: roundId);
  if (!context.mounted) return;
  context.push(
    Routes.hebat,
    extra: HebatArgs(award: award, replayRoute: replayRoute),
  );
}
