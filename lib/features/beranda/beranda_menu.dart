import 'package:flutter/widgets.dart';

import '../../app/routes.dart';
import '../../l10n/l10n.dart';

/// Sepuluh kartu menu Beranda, berurutan seperti di rail (dua baris, isi per
/// kolom). Warna dan bayangan dari prototipe `Main.dc.html`.
enum BerandaMenu {
  huruf(Routes.huruf, Color(0xFFFF6B6B), Color(0xFFE04848)),
  angka(Routes.angka, Color(0xFF4DA8FF), Color(0xFF2A84E0)),
  hewan(Routes.hewan, Color(0xFF5FD068), Color(0xFF3BAA45)),
  buah(Routes.buahSayur, Color(0xFFFF7EB6), Color(0xFFE0528F)),
  baca(Routes.sukuKata, Color(0xFFFF8A3D), Color(0xFFE0661A)),
  main(Routes.mainYuk, Color(0xFF22C1C3), Color(0xFF129A9C)),
  warnai(Routes.mewarnai, Color(0xFFFFC233), Color(0xFFE0A100)),
  warna(Routes.warna, Color(0xFF9775FA), Color(0xFF7048E8)),
  bentuk(Routes.bentuk, Color(0xFF5C7CFA), Color(0xFF3B5BDB)),
  musik(Routes.musik, Color(0xFFF06595), Color(0xFFC2255C));

  const BerandaMenu(this.route, this.color, this.shadow);

  final String route;
  final Color color;
  final Color shadow;

  /// Kunci ARB judul (`menu<Id>Title`), juga id berkas narasi.
  String get titleKey =>
      'menu${name[0].toUpperCase()}${name.substring(1)}Title';

  String title(AppLocalizations l10n) => switch (this) {
    huruf => l10n.menuHurufTitle,
    angka => l10n.menuAngkaTitle,
    hewan => l10n.menuHewanTitle,
    buah => l10n.menuBuahTitle,
    baca => l10n.menuBacaTitle,
    main => l10n.menuMainTitle,
    warnai => l10n.menuWarnaiTitle,
    warna => l10n.menuWarnaTitle,
    bentuk => l10n.menuBentukTitle,
    musik => l10n.menuMusikTitle,
  };

  String sub(AppLocalizations l10n) => switch (this) {
    huruf => l10n.menuHurufSub,
    angka => l10n.menuAngkaSub,
    hewan => l10n.menuHewanSub,
    buah => l10n.menuBuahSub,
    baca => l10n.menuBacaSub,
    main => l10n.menuMainSub,
    warnai => l10n.menuWarnaiSub,
    warna => l10n.menuWarnaSub,
    bentuk => l10n.menuBentukSub,
    musik => l10n.menuMusikSub,
  };

  /// Menu induk sebuah rute: menu yang segmen pertama rutenya sama, misalnya
  /// `/huruf/tulis` milik [huruf] dan `/membaca/kalimat` milik [baca].
  static BerandaMenu? parentOf(String route) {
    final head = _head(route);
    if (head.isEmpty) return null;
    for (final m in values) {
      if (_head(m.route) == head) return m;
    }
    return null;
  }

  static String _head(String route) {
    final segments = Uri.parse(route).pathSegments;
    return segments.isEmpty ? '' : segments.first;
  }
}
