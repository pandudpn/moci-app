import 'package:flutter/widgets.dart';

import '../app/theme/moci_colors.dart';
import '../app/theme/moci_text.dart';
import 'pressable.dart';

enum MociButtonKind { primary, light, accent }

class MociButton extends StatelessWidget {
  const MociButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.kind = MociButtonKind.primary,
    this.height = 70,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final MociButtonKind kind;
  final double height;

  static const _accent = Color(0xFFFFB020);
  static const _accentShadow = Color(0xFFE0870B);

  @override
  Widget build(BuildContext context) {
    final (Color color, Color? shadow, Color text) = switch (kind) {
      MociButtonKind.primary => (
        MociColors.correct,
        MociColors.correctShadow,
        MociColors.white,
      ),
      MociButtonKind.light => (MociColors.white, null, MociColors.ink),
      MociButtonKind.accent => (_accent, _accentShadow, MociColors.ink),
    };
    return MociPressable(
      color: color,
      shadowColor: shadow,
      borderRadius: BorderRadius.circular(height / 2),
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 12)],
              Text(label, style: MociText.button.copyWith(color: text)),
            ],
          ),
        ),
      ),
    );
  }
}
