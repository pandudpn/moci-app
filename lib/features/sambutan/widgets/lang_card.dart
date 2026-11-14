import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';
import 'sambutan_icons.dart';

const _onFill = Color(0xFFEAF4FF);
const _onBorder = Color(0xFF1C7ED6);
const _offBorder = Color(0xFFEEE9F7);
const _soft = Color(0xFF5B5480);

/// Kartu pilihan bahasa. Judul kartu tetap dalam bahasanya sendiri.
class LangCard extends StatelessWidget {
  const LangCard({
    super.key,
    required this.code,
    required this.badgeColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final Color badgeColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: MociPressable(
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        depth: 0,
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: selected ? _onFill : MociColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? _onBorder : _offBorder,
              width: 5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExcludeSemantics(
                  child: Text(
                    code,
                    style: MociText.button.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: MociText.title.copyWith(fontSize: 28, height: 1.1),
                    ),
                    Text(
                      subtitle,
                      style: MociText.label.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _soft,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected) const _PopCheck(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centang yang membesar memantul 400 ms saat kartu terpilih.
class _PopCheck extends StatelessWidget {
  const _PopCheck();

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: still ? 1 : 0, end: 1),
        duration: still ? Duration.zero : const Duration(milliseconds: 400),
        curve: const Cubic(0.3, 1.6, 0.5, 1),
        builder: (context, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _onBorder,
            shape: BoxShape.circle,
          ),
          child: const CustomPaint(
            size: Size(26, 26),
            painter: CheckPainter(color: MociColors.white, strokeWidth: 3.4),
          ),
        ),
      ),
    );
  }
}
