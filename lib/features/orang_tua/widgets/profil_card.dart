import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/prefs/app_prefs.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/pressable.dart';
import 'option_pills.dart';
import 'ot_card.dart';

const _ranges = {
  AgeLevel.pemula: '2–3',
  AgeLevel.penjelajah: '4–5',
  AgeLevel.pembaca: '6–7',
};

String levelName(AppLocalizations l10n, AgeLevel age) => switch (age) {
  AgeLevel.pemula => l10n.orangTuaLevelPemula,
  AgeLevel.penjelajah => l10n.orangTuaLevelPenjelajah,
  AgeLevel.pembaca => l10n.orangTuaLevelPembaca,
};

/// Profil anak: avatar, nama, usia dan level, pil usia, tombol ubah nama.
class ProfilCard extends ConsumerWidget {
  const ProfilCard({super.key, required this.onEditName});

  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(prefsProvider);
    final name = prefs.childName.trim();
    final hasName = name.isNotEmpty;
    return OtCard(
      label: l10n.orangTuaProfile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name : l10n.orangTuaChildFallback,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MociText.title.copyWith(
                        fontSize: 30,
                        height: 1.1,
                        color: hasName ? MociColors.ink : MociColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.orangTuaSub(
                        _ranges[prefs.ageLevel]!,
                        levelName(l10n, prefs.ageLevel),
                      ),
                      style: MociText.label.copyWith(
                        fontSize: 16,
                        color: MociColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MociPressable(
                color: otSoftFill,
                shadowColor: otShadow,
                depth: 5,
                minTouch: otTouch(context),
                borderRadius: BorderRadius.circular(18),
                semanticLabel: l10n.orangTuaEditName,
                onTap: onEditName,
                child: const SizedBox.square(
                  dimension: 52,
                  child: Center(
                    child: CustomPaint(
                      size: Size.square(24),
                      painter: _PencilPainter(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(l10n.orangTuaAgeLevel, style: otLabel()),
          OptionPills<AgeLevel>(
            gap: 10,
            options: [
              for (final a in AgeLevel.values)
                (a, l10n.orangTuaAgeChip(_ranges[a]!)),
            ],
            selected: prefs.ageLevel,
            onSelected: ref.read(prefsProvider.notifier).setAgeLevel,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFFFC233),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0xFFE0A100), offset: Offset(0, 5)),
          ],
        ),
        child: SizedBox.square(
          dimension: 84,
          child: ClipOval(
            child: name.isEmpty
                ? const Align(
                    alignment: Alignment(0, 0.45),
                    child: MociIllustration('moci', size: 74),
                  )
                : Center(
                    child: Text(
                      String.fromCharCode(name.runes.first).toUpperCase(),
                      style: MociText.title.copyWith(fontSize: 44, height: 1),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PencilPainter extends CustomPainter {
  const _PencilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = MociColors.ink
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final body = Path()
      ..moveTo(4 * k, 20 * k)
      ..lineTo(8 * k, 19 * k)
      ..lineTo(19 * k, 8 * k)
      ..lineTo(16 * k, 5 * k)
      ..lineTo(5 * k, 16 * k)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawLine(Offset(14 * k, 6 * k), Offset(17 * k, 9 * k), paint);
  }

  @override
  bool shouldRepaint(_PencilPainter old) => false;
}
