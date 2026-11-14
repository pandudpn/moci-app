import 'package:flutter/widgets.dart';

/// Centang `M5 12.5l4.5 4.5L19 7.5` pada kanvas 24 x 24.
class CheckPainter extends CustomPainter {
  const CheckPainter({required this.color, required this.strokeWidth});

  final Color color;

  /// Dalam satuan kanvas 24 x 24.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(5 * k, 12.5 * k)
      ..lineTo(9.5 * k, 17 * k)
      ..lineTo(19 * k, 7.5 * k);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(CheckPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

/// Panah kanan `M5 12h13` + `M13 6l6 6-6 6` pada kanvas 24 x 24.
class ArrowPainter extends CustomPainter {
  const ArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(5 * k, 12 * k)
      ..lineTo(18 * k, 12 * k)
      ..moveTo(13 * k, 6 * k)
      ..lineTo(19 * k, 12 * k)
      ..lineTo(13 * k, 18 * k);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(ArrowPainter old) => old.color != color;
}
