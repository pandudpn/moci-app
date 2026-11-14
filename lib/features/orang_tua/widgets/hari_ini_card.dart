import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../l10n/l10n.dart';
import '../../hadiah/widgets/hebat_widgets.dart' show HebatStarIcon;
import '../../../widgets/moci_illustration.dart';
import '../ringkasan.dart';
import 'ot_card.dart';

const _ringFree = Color(0xFFCFC8E8);
const _ringLeft = Color(0xFF7048E8);
const _ringOver = Color(0xFFE8590C);

/// Hari ini: cincin waktu bermain terhadap batas harian, dan ubin hasil.
class HariIniCard extends StatelessWidget {
  const HariIniCard({super.key, required this.today});

  final TodaySummary today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final limit = today.limit;
    final left = today.minutesLeft;
    final Color ringColor;
    final double ratio;
    final String of;
    final String status;
    final Color chipBg;
    final Color chipFg;
    if (limit == null) {
      ringColor = _ringFree;
      ratio = 1;
      of = l10n.orangTuaNoLimit;
      status = l10n.orangTuaUnlimited;
      chipBg = otTrack;
      chipFg = MociColors.ink;
    } else {
      final remaining = left! > 0;
      ringColor = remaining ? _ringLeft : _ringOver;
      ratio = math.min(1, today.minutesPlayed / limit);
      of = l10n.orangTuaRingOf(limit);
      status = remaining ? l10n.orangTuaLeft(left) : l10n.orangTuaTimeUp;
      chipBg = remaining ? const Color(0xFFEEE8FF) : const Color(0xFFFFE8D9);
      chipFg = remaining ? const Color(0xFF4A2FB0) : const Color(0xFFA33A00);
    }
    return OtCard(
      label: l10n.orangTuaToday,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orangTuaToday, style: otHeading()),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  l10n.orangTuaPlayTime,
                  textAlign: TextAlign.end,
                  style: otLabel(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox.square(
                dimension: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(140),
                      painter: _RingPainter(ratio: ratio, color: ringColor),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${today.minutesPlayed}',
                          style: MociText.title.copyWith(
                            fontSize: 46,
                            height: 1,
                          ),
                        ),
                        Text(
                          l10n.orangTuaMin,
                          style: MociText.label.copyWith(
                            fontSize: 15,
                            color: MociColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      of,
                      style: MociText.label.copyWith(
                        fontSize: 16,
                        height: 1.3,
                        color: const Color(0xFF5B5480),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Text(
                          status,
                          style: MociText.button.copyWith(
                            fontSize: 18,
                            color: chipFg,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Tile(
                  bg: const Color(0xFFFFF8E1),
                  icon: const HebatStarIcon(size: 28),
                  value: '+${today.stars}',
                  label: l10n.orangTuaStars,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  bg: const Color(0xFFFFEEF3),
                  icon: const MociIllustration('apel', size: 30),
                  value: '+${today.stickers}',
                  label: l10n.orangTuaStickers,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Tile(
                  bg: const Color(0xFFE9F6FF),
                  icon: const CustomPaint(
                    size: Size.square(28),
                    painter: _PalettePainter(),
                  ),
                  value: '+${today.karya}',
                  label: l10n.orangTuaArt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.bg,
    required this.icon,
    required this.value,
    required this.label,
  });

  final Color bg;
  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: icon),
              const SizedBox(height: 2),
              Text(
                value,
                style: MociText.title.copyWith(fontSize: 22, height: 1.1),
              ),
              Text(
                label,
                maxLines: 1,
                style: MociText.label.copyWith(
                  fontSize: 13,
                  color: MociColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cincin 120 x 120 di prototipe (jari-jari 50, tebal 14), mulai dari atas.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.ratio, required this.color});

  final double ratio;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 120;
    final rect = Rect.fromCircle(
      center: Offset(60 * k, 60 * k),
      radius: 50 * k,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14 * k
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(rect.center, rect.width / 2, paint..color = otTrack);
    if (ratio <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      // Sapuan penuh tepat 2π menutup lingkaran; lebihnya jadi lingkaran utuh.
      2 * math.pi * ratio.clamp(0.0, 1.0),
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.color != color;
}

/// Palet cat (kanvas 24 x 24) untuk ubin karya.
class _PalettePainter extends CustomPainter {
  const _PalettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final body = Path()
      ..moveTo(12 * k, 3 * k)
      ..arcToPoint(
        Offset(12 * k, 21 * k),
        radius: Radius.circular(9 * k),
        clockwise: false,
      )
      ..cubicTo(13.4 * k, 21 * k, 14 * k, 20 * k, 14 * k, 19 * k)
      ..cubicTo(14 * k, 17.4 * k, 12.4 * k, 17.2 * k, 12.4 * k, 15.8 * k)
      ..cubicTo(12.4 * k, 14.8 * k, 13.2 * k, 14 * k, 14.2 * k, 14 * k)
      ..lineTo(17 * k, 14 * k)
      ..arcToPoint(
        Offset(21 * k, 10 * k),
        radius: Radius.circular(4 * k),
        clockwise: false,
      )
      ..cubicTo(21 * k, 6.1 * k, 17 * k, 3 * k, 12 * k, 3 * k)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF1C7ED6)
        ..strokeWidth = 2.2 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    void dot(double x, double y, Color c) =>
        canvas.drawCircle(Offset(x * k, y * k), 1.3 * k, Paint()..color = c);
    dot(7.5, 11, const Color(0xFFE8384F));
    dot(10, 7.2, const Color(0xFFFFC233));
    dot(14.6, 7.2, const Color(0xFF26A03B));
  }

  @override
  bool shouldRepaint(_PalettePainter old) => false;
}
