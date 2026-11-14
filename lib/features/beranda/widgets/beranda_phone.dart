import 'package:flutter/widgets.dart';

import '../../../app/motion/ambient_motion.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/moci_mascot.dart';
import '../../../widgets/star_counter.dart';
import 'beranda_actions.dart';
import 'beranda_scenery.dart';
import 'continue_card.dart';
import 'lang_switch.dart';
import 'menu_card.dart';
import 'menu_rail.dart';
import 'parents_button.dart';

/// Beranda di artboard HP 844 x 390 (`HP.dc.html`).
class BerandaPhone extends StatelessWidget {
  const BerandaPhone({super.key, required this.content});

  final BerandaContent content;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resume = content.resume;
    return SizedBox(
      width: 844,
      height: 390,
      // Awan, kilau, dan Moci di layar ini ikut satu jam gerak.
      child: AmbientMotion(
        child: Stack(
          children: [
            const BerandaScenery.phone(),
            Positioned(
              left: 44,
              right: 44,
              top: 8,
              height: 56,
              child: Row(
                children: [
                  const BerandaLogo(
                    fontSize: 36,
                    outline: 2,
                    drop: 4,
                    spacing: 1,
                  ),
                  const Spacer(),
                  LangSwitch(
                    compact: true,
                    lang: content.lang,
                    label: l10n.berandaLangLabel,
                    onChanged: content.onLang,
                  ),
                  const SizedBox(width: 10),
                  StarCounter(
                    compact: true,
                    semanticLabelOf: l10n.berandaStarsLabel,
                  ),
                  const SizedBox(width: 10),
                  ParentsButton(
                    key: const ValueKey('parents-button'),
                    compact: true,
                    label: l10n.berandaParents,
                    onTap: content.onParents,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 44,
              bottom: 262,
              width: 176,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: MociColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: MociColors.neutralShadow,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
                        child: Text(
                          l10n.berandaHi(content.name),
                          style: MociText.title.copyWith(
                            fontSize: 19,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 74,
                    bottom: -14,
                    child: TailShape(
                      size: Size(28, 16),
                      points: [Offset(2, 0), Offset(26, 0), Offset(14, 16)],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 80,
              top: 140,
              width: 104,
              height: 104,
              child: AmbientLayer(
                key: const ValueKey('beranda-moci'),
                // bob: naik 8 px tiap 3 detik.
                builder: (context, seconds, child) => Transform.translate(
                  offset: Offset(
                    0,
                    bobOffset(t: seconds, amplitude: 8, period: 3),
                  ),
                  child: child,
                ),
                child: Semantics(
                  button: true,
                  label: l10n.berandaMociLabel,
                  excludeSemantics: true,
                  child: MociMascot(size: 104, onTap: content.onMoci),
                ),
              ),
            ),
            if (resume != null)
              Positioned(
                left: 44,
                top: 258,
                child: ContinueCard(
                  compact: true,
                  menu: resume.menu,
                  heading: l10n.berandaContinue,
                  label: resume.label,
                  onTap: resume.onTap,
                ),
              ),
            Positioned(
              left: 228,
              top: 64,
              right: 0,
              height: 326,
              child: MenuRail(
                cardWidth: 156,
                cardHeight: 142,
                gap: 12,
                padding: const EdgeInsets.fromLTRB(6, 8, 44, 22),
                itemBuilder: (context, menu) => MenuCard(
                  key: ValueKey('menu-${menu.name}'),
                  compact: true,
                  menu: menu,
                  title: menu.title(l10n),
                  sub: menu.sub(l10n),
                  onTap: () => content.onMenu(menu),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
