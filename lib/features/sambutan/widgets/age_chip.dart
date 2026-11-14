import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';

/// Chip rentang usia ("2–3 tahun").
class AgeChip extends StatelessWidget {
  const AgeChip({
    super.key,
    required this.range,
    required this.years,
    required this.selected,
    required this.onTap,
  });

  final String range;
  final String years;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: MociPressable(
        color: selected ? const Color(0xFFFFC233) : const Color(0xFFF4F1FA),
        shadowColor: selected
            ? const Color(0xFFE0A100)
            : const Color(0xFFE3DDF0),
        depth: 6,
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(range, style: MociText.title.copyWith(fontSize: 28)),
              const SizedBox(width: 6),
              Text(
                years,
                style: MociText.label.copyWith(
                  fontSize: 16,
                  color: MociColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
