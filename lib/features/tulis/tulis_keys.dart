import 'package:flutter/widgets.dart';

/// Dua isi layar Tulis. Keduanya memakai papan dan aturan yang sama.
enum TulisMode { huruf, angka }

/// Kisi kunci dan ukurannya per mode, dari prototipe `Tulis.dc.html`.
final class TulisKeySpec {
  const TulisKeySpec({
    required this.keys,
    required this.columns,
    required this.keyHeight,
    required this.fontSize,
  });

  static TulisKeySpec of(TulisMode mode) => switch (mode) {
    TulisMode.huruf => const TulisKeySpec(
      keys: [
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      ],
      columns: 4,
      keyHeight: 50,
      fontSize: 26,
    ),
    TulisMode.angka => const TulisKeySpec(
      keys: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
      columns: 2,
      keyHeight: 74,
      fontSize: 40,
    ),
  };

  final List<String> keys;
  final int columns;
  final double keyHeight;
  final double fontSize;
}

/// Lima krayon dari prototipe, urut sesuai kisi warna.
const tulisCrayons = <Color>[
  Color(0xFFFF5C8A),
  Color(0xFF3BA4FF),
  Color(0xFF51CF66),
  Color(0xFFFFB020),
  Color(0xFF9775FA),
];
