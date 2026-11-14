import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';

/// Satu kata yang bisa diketuk. Saat [sorot] aktif, kata naik 6 pt dan
/// berlatar kuning.
class KalimatWord extends StatelessWidget {
  const KalimatWord({
    super.key,
    required this.text,
    required this.sorot,
    required this.onTap,
  });

  final String text;
  final bool sorot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, sorot ? -6 : 0),
      child: MociPressable(
        onTap: onTap,
        color: sorot ? const Color(0xFFFFD43B) : const Color(0xFFFFF6EE),
        shadowColor: sorot ? const Color(0xFFF08C00) : const Color(0xFFF7C9A5),
        depth: 6,
        borderRadius: BorderRadius.circular(22),
        semanticLabel: text,
        minTouch: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 76,
            child: Center(
              child: Text(
                text,
                style: MociText.title.copyWith(
                  fontSize: 46,
                  color: MociColors.ink,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
