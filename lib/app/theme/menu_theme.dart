import 'package:flutter/widgets.dart';

/// Latar artboard dan warna bayangan tombol kembali per layar, dari prototipe.
enum MenuTheme {
  beranda(
    [Color(0xFF74C4FF), Color(0xFFB5E2FF), Color(0xFFDDF3FF)],
    Color(0xFF8EC5EE),
    stops: [0, 0.55, 1],
  ),
  sambutan(
    [Color(0xFF74C4FF), Color(0xFFB5E2FF), Color(0xFFDDF3FF)],
    Color(0xFF8EC5EE),
    stops: [0, 0.6, 1],
  ),
  huruf([Color(0xFFFFEDE6)], Color(0xFFF3C2B3)),
  ucapkan([Color(0xFFFFEDE6)], Color(0xFFF3C2B3)),
  berhitung([Color(0xFFE7F3FF)], Color(0xFFB7D7F7)),
  hewan(
    [Color(0xFFBFEBFF), Color(0xFFE3F7FF), Color(0xFFE3F7FF)],
    Color(0xFF9FD3A0),
    stops: [0, 0.52, 1],
  ),
  buahSayur([Color(0xFFFFEAF3)], Color(0xFFF5BCD3)),
  warna([Color(0xFFF3EEFF)], Color(0xFFD0BFFF)),
  bentuk([Color(0xFFEEF1FF)], Color(0xFFC5CEF7)),
  musik([Color(0xFFFFF0F6)], Color(0xFFF8C4D9)),
  membaca([Color(0xFFFFF1E6)], Color(0xFFF7C9A5)),
  mainYuk([Color(0xFFE3FAFA)], Color(0xFF9EDCDD)),
  cocokkan([Color(0xFFFDF0F6)], Color(0xFFF5BCD3)),
  memori([Color(0xFFEAF2FF)], Color(0xFFB7D0F7)),
  bayangan([Color(0xFFF3F0FF)], Color(0xFFD0BFFF)),
  puzzle([Color(0xFFFFF4E0)], Color(0xFFF2C57C)),
  balon(
    [Color(0xFF8FD3FF), Color(0xFFCDEBFF), Color(0xFFEAF6FF)],
    Color(0xFF8ECBEE),
    stops: [0, 0.6, 1],
  ),
  besarKecil([Color(0xFFEBFBEE)], Color(0xFFB2F2BB)),
  mewarnai([Color(0xFFFFF8E1)], Color(0xFFF2D27A)),
  karyaku([Color(0xFFFFF7E0)], Color(0xFFF2D27A)),
  hebat([Color(0xFFFFE58F)], Color(0xFFF2C94C)),
  istirahat(
    [Color(0xFF241D4A), Color(0xFF3E3180), Color(0xFF7C6BD6)],
    Color(0xFF1F1846),
    stops: [0, 0.55, 1],
    dark: true,
  ),
  gerbang([Color(0xFF3B3170)], Color(0xFF1F1846), dark: true),
  orangTua([Color(0xFFF1EEF9)], Color(0xFFDCD5EE));

  const MenuTheme(this.colors, this.shadow, {this.stops, this.dark = false});

  final List<Color> colors;
  final List<double>? stops;
  final Color shadow;
  final bool dark;

  BoxDecoration get decoration {
    if (colors.length > 1) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      );
    }
    return BoxDecoration(color: colors.first);
  }
}
