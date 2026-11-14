import 'package:flutter/widgets.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../pressable.dart';

/// Satu tab di [GameModePill]. [icon] opsional dan tidak dibacakan.
final class GameModeTab {
  const GameModeTab({required this.label, this.icon});

  final String label;
  final Widget? icon;
}

/// Pil mode belajar: kontainer putih bulat, tab aktif berlatar [accent].
class GameModePill extends StatelessWidget {
  const GameModePill({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    required this.semanticLabel,
    required this.accent,
  });

  final List<GameModeTab> tabs;

  /// Indeks tab aktif; nilai di luar jangkauan berarti tidak ada yang aktif.
  final int selected;
  final ValueChanged<int> onSelected;
  final String semanticLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Semantics(
          container: true,
          label: semanticLabel,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                _tab(i),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int i) {
    final tab = tabs[i];
    final on = i == selected;
    return MociPressable(
      onTap: () => onSelected(i),
      color: on ? accent : const Color(0x00000000),
      shadowColor: const Color(0x00000000),
      depth: 0,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: tab.label,
      minTouch: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null) ...[
                ExcludeSemantics(child: tab.icon!),
                const SizedBox(width: 8),
              ],
              Text(
                tab.label,
                style: MociText.button.copyWith(
                  color: on ? MociColors.white : MociColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
