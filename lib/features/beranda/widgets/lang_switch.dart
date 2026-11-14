import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/lang.dart';

const _enBlue = Color(0xFF1C7ED6);
const _pillShadow = Color(0xFF8EC5EE);

/// Sakelar ID/EN. Tombol aktif berwarna (ID merah, EN biru) bertulisan putih.
///
/// Tampilan mengikuti prototipe (tombol 52 x 62 di tablet, 44 x 52 di HP),
/// tetapi area sentuh tiap tombol dilebarkan ke 64 x 64 (tablet) dan 56 x 56
/// (HP). Kedua area boleh bersentuhan; keduanya tetap di dalam kotak sakelar.
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
    final btnW = compact ? 52.0 : 62.0;
    final btnH = compact ? 44.0 : 52.0;
    final touch = compact ? 56.0 : 64.0;
    final pillW = 2 * btnW + 4 + 2 * pad;
    final pillH = btnH + 2 * pad;
    final entries = [
      ('lang-id', 'ID', 'Bahasa Indonesia', AppLang.id, MociColors.wrong),
      ('lang-en', 'EN', 'English', AppLang.en, _enBlue),
    ];
    return Semantics(
      container: true,
      label: label,
      child: SizedBox(
        width: pillW,
        height: touch,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MociColors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: _pillShadow,
                      offset: Offset(0, compact ? 5 : 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: pillW,
                  height: pillH,
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: Row(
                      children: [
                        for (final (i, e) in entries.indexed) ...[
                          if (i > 0) const SizedBox(width: 4),
                          _Visual(
                            text: e.$2,
                            width: btnW,
                            height: btnH,
                            active: lang == e.$4,
                            activeColor: e.$5,
                            compact: compact,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in entries)
                  Semantics(
                    button: true,
                    selected: lang == e.$4,
                    label: e.$3,
                    excludeSemantics: true,
                    child: GestureDetector(
                      key: ValueKey(e.$1),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(e.$4),
                      child: SizedBox(width: touch, height: touch),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Visual extends StatelessWidget {
  const _Visual({
    required this.text,
    required this.width,
    required this.height,
    required this.active,
    required this.activeColor,
    required this.compact,
  });

  final String text;
  final double width;
  final double height;
  final bool active;
  final Color activeColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? activeColor : MociColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            text,
            style: MociText.title.copyWith(
              fontSize: compact ? 18 : 22,
              color: active ? MociColors.white : MociColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
