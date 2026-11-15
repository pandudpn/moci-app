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
    this.rowGap = 6,
    this.fontSize = 19,
    this.perRow,
  });

  /// Pasangan nilai dan teks pil.
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final double gap;

  /// Jarak antarbaris kalau [perRow] memecah pilihan jadi beberapa baris.
  final double rowGap;
  final double fontSize;

  /// Jumlah pil per baris; `null` berarti semuanya dalam satu baris.
  final int? perRow;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final touch = otTouch(context);
    final diminta = perRow;
    final muat = diminta == null || diminta > options.length
        ? options.length
        : (diminta < 1 ? 1 : diminta);
    final baris = <Widget>[];
    for (var i = 0; i < options.length; i += muat) {
      final akhir = i + muat < options.length ? i + muat : options.length;
      if (baris.isNotEmpty) baris.add(SizedBox(height: rowGap));
      baris.add(_row(options.sublist(i, akhir), touch));
    }
    return baris.length == 1 ? baris.first : Column(children: baris);
  }

  Widget _row(List<(T, String)> isi, double touch) {
    return Row(
      children: [
        for (var i = 0; i < isi.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: _pill(isi[i], touch)),
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
