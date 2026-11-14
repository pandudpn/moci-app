import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/lang.dart';

const _enBlue = Color(0xFF1C7ED6);
const _pillShadow = Color(0xFF8EC5EE);

/// Sakelar ID/EN. Tombol aktif berwarna (ID merah, EN biru) bertulisan putih.
class LangSwitch extends StatelessWidget {
  const LangSwitch({
    super.key,
    required this.lang,
    required this.label,
    required this.onChanged,
    this.compact = false,
  });

  final AppLang lang;

  /// Label semantik grup ("Bahasa").
  final String label;
  final ValueChanged<AppLang> onChanged;

  /// Ukuran HP.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 4.0 : 6.0;
    return Semantics(
      container: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(color: _pillShadow, offset: Offset(0, compact ? 5 : 6)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangButton(
                key: const ValueKey('lang-id'),
                text: 'ID',
                semanticLabel: 'Bahasa Indonesia',
                active: lang == AppLang.id,
                activeColor: MociColors.wrong,
                compact: compact,
                onTap: () => onChanged(AppLang.id),
              ),
              SizedBox(width: compact ? 4 : 4),
              _LangButton(
                key: const ValueKey('lang-en'),
                text: 'EN',
                semanticLabel: 'English',
                active: lang == AppLang.en,
                activeColor: _enBlue,
                compact: compact,
                onTap: () => onChanged(AppLang.en),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({
    super.key,
    required this.text,
    required this.semanticLabel,
    required this.active,
    required this.activeColor,
    required this.compact,
    required this.onTap,
  });

  final String text;
  final String semanticLabel;
  final bool active;
  final Color activeColor;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: active ? activeColor : MociColors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: compact ? 52 : 62,
              minHeight: compact ? 44 : 52,
            ),
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
                child: Text(
                  text,
                  style: MociText.title.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 18 : 22,
                    color: active ? MociColors.white : MociColors.ink,
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
