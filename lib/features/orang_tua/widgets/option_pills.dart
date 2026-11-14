import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';
import 'ot_card.dart';

/// Baris pil pilihan (satu terpilih): ungu saat terpilih, lembut saat tidak.
class OptionPills<T> extends StatelessWidget {
  const OptionPills({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.gap = 8,
    this.fontSize = 19,
  });

  /// Pasangan nilai dan teks pil.
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final double gap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final touch = otTouch(context);
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _pill(options[i], touch)),
        ],
      ],
    );
  }

  Widget _pill((T, String) o, double touch) {
    final on = o.$1 == selected;
    return Semantics(
      selected: on,
      inMutuallyExclusiveGroup: true,
      child: MociPressable(
        color: on ? otPurple : otSoftFill,
        shadowColor: on ? otPurpleShadow : otShadow,
        depth: 5,
        minTouch: touch,
        borderRadius: BorderRadius.circular(18),
        semanticLabel: o.$2,
        onTap: () => onSelected(o.$1),
        child: SizedBox(
          height: 52,
          child: Center(
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    o.$2,
                    maxLines: 1,
                    style: MociText.button.copyWith(
                      fontSize: fontSize,
                      color: on ? MociColors.white : MociColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
