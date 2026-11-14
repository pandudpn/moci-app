import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';

const _ink = Color(0xFF2B2350);
const _inkShadow = Color(0xFF16112F);

/// Pil gelap "Orang Tua" bergembok. Pembukaannya lewat gerbang.
class ParentsButton extends StatelessWidget {
  const ParentsButton({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;

  /// Ukuran HP.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 48.0 : 64.0;
    return MociPressable(
      color: _ink,
      shadowColor: _inkShadow,
      depth: compact ? 5 : 6,
      minTouch: compact ? 56 : 64,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.only(
            left: compact ? 12 : 20,
            right: compact ? 16 : 20,
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: Size.square(compact ? 20 : 24),
                  painter: const _LockPainter(),
                ),
                SizedBox(width: compact ? 6 : 8),
                Text(
                  label,
                  style: MociText.label.copyWith(
                    fontSize: compact ? 15 : 18,
                    color: MociColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gembok `rect 4.5,10.5 15x10 rx2.5` + `M8 10.5V7.5a4 4 0 0 1 8 0v3`
/// pada kanvas 24 x 24.
class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = MociColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4.5 * k, 10.5 * k, 15 * k, 10 * k),
        Radius.circular(2.5 * k),
      ),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(8 * k, 10.5 * k)
        ..lineTo(8 * k, 7.5 * k)
        ..arcToPoint(Offset(16 * k, 7.5 * k), radius: Radius.circular(4 * k))
        ..lineTo(16 * k, 10.5 * k),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LockPainter old) => false;
}
