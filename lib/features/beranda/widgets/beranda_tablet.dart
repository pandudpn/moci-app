import 'package:flutter/widgets.dart';

import '../../../app/motion/ambient_motion.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_metrics.dart';
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

/// Beranda di artboard tablet 1180 x 820 (`Main.dc.html`).
class BerandaTablet extends StatelessWidget {
  const BerandaTablet({super.key, required this.content});

  final BerandaContent content;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resume = content.resume;
    return SizedBox(
      width: 1180,
      height: 820,
      // Awan, matahari, dan kilau di latar ikut satu jam gerak.
      child: AmbientMotion(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const BerandaScenery.tablet(),
            Positioned(
              left: 160,
              top: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BerandaLogo(
                    fontSize: 64,
                    outline: 3,
                    drop: 7,
                    spacing: 2,
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      l10n.berandaTag,
                      style: MociText.label.copyWith(
                        fontSize: 18,
                        color: const Color(0xFF1B4A82),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              // Margin tepi kanan sama dengan bilah atas (32 pt).
              right: MociSize.edgeTablet,
              top: 26,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LangSwitch(
                    lang: content.lang,
                    label: l10n.berandaLangLabel,
                    onChanged: content.onLang,
                  ),
                  const SizedBox(width: 12),
                  StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
                  const SizedBox(width: 12),
                  ParentsButton(
                    key: const ValueKey('parents-button'),
                    label: l10n.berandaParents,
                    onTap: content.onParents,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 34,
              top: 124,
              width: 184,
              height: 184,
              child: Semantics(
                key: const ValueKey('beranda-moci'),
                button: true,
                label: l10n.berandaMociLabel,
                excludeSemantics: true,
                child: MociMascot(size: 184, onTap: content.onMoci),
              ),
            ),
            Positioned(
              left: 236,
              top: 150,
              width: 420,
              child: _Bubble(
                hi: l10n.berandaHi(content.name),
                ask: l10n.berandaAsk,
              ),
            ),
            const Positioned(
              left: 210,
              top: 196,
              child: TailShape(
                size: Size(30, 30),
                points: [Offset(30, 0), Offset(30, 30), Offset(0, 14)],
              ),
            ),
            if (resume != null)
              Positioned(
                left: 776,
                top: 140,
                child: ContinueCard(
                  menu: resume.menu,
                  heading: l10n.berandaContinue,
                  label: resume.label,
                  onTap: resume.onTap,
                ),
              ),
            Positioned(
              left: 0,
              top: 314,
              width: 1180,
              height: 482,
              child: MenuRail(
                cardWidth: 236,
                cardHeight: 214,
                gap: 22,
                padding: const EdgeInsets.fromLTRB(40, 6, 40, 26),
                itemBuilder: (context, menu) => MenuCard(
                  key: ValueKey('menu-${menu.name}'),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.hi, required this.ask});

  final String hi;
  final String ask;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: MociColors.neutralShadow, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hi, style: MociText.title.copyWith(fontSize: 34, height: 1.1)),
            const SizedBox(height: 4),
            Text(
              ask,
              style: MociText.title.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.25,
                color: const Color(0xFF3D3466),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
