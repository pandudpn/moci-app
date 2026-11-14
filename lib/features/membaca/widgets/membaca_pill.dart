import 'package:flutter/widgets.dart';

import '../../../app/layout/moci_stage.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_metrics.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';

const _accent = Color(0xFFE0661A);
const _accentShadow = Color(0xFFA9480D);

/// Pil pilihan level atau mode: 50 pt, radius penuh, terpilih oranye.
class MembacaPill extends StatelessWidget {
  const MembacaPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 50,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      onTap: onTap,
      color: selected ? _accent : MociColors.white,
      shadowColor: selected
          ? _accentShadow
          : MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow,
      depth: MociSize.pillShadow,
      borderRadius: BorderRadius.circular(height / 2),
      semanticLabel: label,
      minTouch: MociSize.minTouchTablet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: SizedBox(
          height: height,
          child: Center(
            child: Text(
              label,
              style: MociText.button.copyWith(
                fontSize: 19,
                color: selected ? MociColors.white : MociColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
