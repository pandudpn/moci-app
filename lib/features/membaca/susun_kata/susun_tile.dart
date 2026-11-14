import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';

/// Warna keping dan bayangannya, bergiliran menurut indeks.
const _warna = [
  (Color(0xFFFF8A3D), Color(0xFFE0661A)),
  (Color(0xFF1C8CF0), Color(0xFF1265B5)),
  (Color(0xFF7048E8), Color(0xFF5032B8)),
  (Color(0xFF26A03B), Color(0xFF1E8A31)),
  (Color(0xFFE8384F), Color(0xFFB82A3E)),
];

Color susunTileColor(int index) => _warna[index % _warna.length].$1;

Color susunTileShadow(int index) => _warna[index % _warna.length].$2;

/// Keping suku kata 168 × 116. Keping terpakai meredup dan tidak bisa diketuk.
class SusunTile extends StatelessWidget {
  const SusunTile({
    super.key,
    required this.index,
    required this.suku,
    required this.used,
    required this.onTap,
  });

  final int index;
  final String suku;
  final bool used;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // MociPressable sudah meredupkan tombol mati sampai 0,5.
      opacity: used ? 0.5 : 1,
      child: MociPressable(
        onTap: used ? null : onTap,
        color: susunTileColor(index),
        shadowColor: susunTileShadow(index),
        depth: 10,
        borderRadius: BorderRadius.circular(30),
        semanticLabel: suku,
        minTouch: 116,
        child: SizedBox(
          width: 168,
          height: 116,
          child: Center(
            child: Text(
              suku,
              style: MociText.title.copyWith(
                fontSize: 54,
                color: MociColors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
