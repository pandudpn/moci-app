import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../app/theme/moci_colors.dart';

/// Ikon garis dari artboard prototipe. Semua digambar di kotak 24 × 24,
/// kecuali bintang yang aslinya 40 × 40 lalu diskalakan.
enum GameGlyphKind {
  eye,
  pencil,
  mic,
  count,
  listen,
  play,
  check,
  refresh,
  next,
  star,
}

class GameGlyph extends StatelessWidget {
  const GameGlyph(
    this.kind, {
    super.key,
    this.size = 26,
    this.color = MociColors.ink,
  });

  final GameGlyphKind kind;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(kind, color),
      ),
    );
  }
}

final class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.kind, this.color);

  final GameGlyphKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final box = kind == GameGlyphKind.star ? 40.0 : 24.0;
    canvas.scale(size.width / box);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = switch (kind) {
        GameGlyphKind.star => 2,
        GameGlyphKind.check => 3.2,
        _ => 2.4,
      }
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    switch (kind) {
      case GameGlyphKind.eye:
        final eye = Path()
          ..moveTo(2, 12)
          ..cubicTo(2, 12, 5.6, 5.5, 12, 5.5)
          ..cubicTo(18.4, 5.5, 22, 12, 22, 12)
          ..cubicTo(22, 12, 18.4, 18.5, 12, 18.5)
          ..cubicTo(5.6, 18.5, 2, 12, 2, 12)
          ..close();
        canvas
          ..drawPath(eye, stroke)
          ..drawPath(
            Path()..addOval(
              Rect.fromCircle(center: const Offset(12, 12), radius: 3),
            ),
            stroke,
          );
      case GameGlyphKind.pencil:
        canvas
          ..drawPath(
            Path()
              ..moveTo(4, 20)
              ..lineTo(8, 19)
              ..lineTo(19, 8)
              ..lineTo(16, 5)
              ..lineTo(5, 16)
              ..close(),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(14, 6)
              ..lineTo(17, 9),
            stroke,
          );
      case GameGlyphKind.mic:
        canvas
          ..drawPath(
            Path()..addRRect(
              RRect.fromRectAndRadius(
                const Rect.fromLTWH(9, 3, 6, 11),
                const Radius.circular(3),
              ),
            ),
            stroke,
          )
          ..drawPath(
            Path()..addArc(
              Rect.fromCircle(center: const Offset(12, 11), radius: 6.5),
              0,
              math.pi,
            ),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(12, 17.5)
              ..lineTo(12, 21),
            stroke,
          );
      case GameGlyphKind.count:
        for (final center in const [
          Offset(7, 7),
          Offset(17, 7),
          Offset(7, 17),
          Offset(17, 17),
        ]) {
          canvas.drawPath(
            Path()..addOval(Rect.fromCircle(center: center, radius: 3)),
            stroke,
          );
        }
      case GameGlyphKind.listen:
        canvas
          ..drawPath(
            Path()
              ..moveTo(4, 9.5)
              ..lineTo(7.5, 9.5)
              ..lineTo(12, 5.5)
              ..lineTo(12, 18.5)
              ..lineTo(7.5, 14)
              ..lineTo(4, 14)
              ..close(),
            fill,
          )
          ..drawPath(
            Path()
              ..moveTo(15.5, 9)
              ..arcToPoint(
                const Offset(15.5, 15),
                radius: const Radius.circular(4),
              ),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(18, 6.5)
              ..arcToPoint(
                const Offset(18, 17.5),
                radius: const Radius.circular(7.5),
              ),
            stroke,
          );
      case GameGlyphKind.play:
        canvas.drawPath(
          Path()
            ..moveTo(8, 5.5)
            ..lineTo(8, 18.5)
            ..lineTo(18.5, 12)
            ..close(),
          fill,
        );
      case GameGlyphKind.check:
        canvas.drawPath(
          Path()
            ..moveTo(5, 12.5)
            ..lineTo(9.5, 17)
            ..lineTo(19, 7.5),
          stroke,
        );
      case GameGlyphKind.refresh:
        canvas
          ..drawPath(
            Path()
              ..moveTo(4, 12)
              ..arcToPoint(
                const Offset(6.6, 6.1),
                radius: const Radius.circular(8),
                largeArc: true,
                clockwise: false,
              ),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(4, 4)
              ..lineTo(4, 9)
              ..lineTo(9, 9),
            stroke,
          );
      case GameGlyphKind.next:
        canvas.drawPath(
          Path()
            ..moveTo(9, 5)
            ..lineTo(16, 12)
            ..lineTo(9, 19),
          stroke,
        );
      case GameGlyphKind.star:
        canvas.drawPath(
          Path()
            ..moveTo(20, 3)
            ..lineTo(25.2, 13.6)
            ..lineTo(36.9, 15.3)
            ..lineTo(28.4, 23.5)
            ..lineTo(30.4, 35.1)
            ..lineTo(20, 29.6)
            ..lineTo(9.6, 35.1)
            ..lineTo(11.6, 23.5)
            ..lineTo(3.1, 15.3)
            ..lineTo(14.8, 13.6)
            ..close(),
          Paint()
            ..color = MociColors.starFill
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(20, 3)
            ..lineTo(25.2, 13.6)
            ..lineTo(36.9, 15.3)
            ..lineTo(28.4, 23.5)
            ..lineTo(30.4, 35.1)
            ..lineTo(20, 29.6)
            ..lineTo(9.6, 35.1)
            ..lineTo(11.6, 23.5)
            ..lineTo(3.1, 15.3)
            ..lineTo(14.8, 13.6)
            ..close(),
          Paint()
            ..color = MociColors.starStroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round,
        );
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.kind != kind || old.color != color;
}
