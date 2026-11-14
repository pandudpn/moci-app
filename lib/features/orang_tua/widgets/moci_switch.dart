import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import 'ot_card.dart';

const _trackOff = Color(0xFFCFC8E8);

/// Saklar berlabel. Sengaja tanpa bunyi klik: efek suara sendiri bisa
/// dimatikan dari sini.
class MociSwitch extends StatelessWidget {
  const MociSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);
    return Semantics(
      toggled: value,
      label: label,
      onTap: () => onChanged(!value),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: otTouch(context)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: MociText.button.copyWith(fontSize: 20, height: 1.15),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: duration,
                width: 64,
                height: 38,
                decoration: BoxDecoration(
                  color: value ? MociColors.correct : _trackOff,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: duration,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: MociColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x402B2350),
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox.square(dimension: 30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
