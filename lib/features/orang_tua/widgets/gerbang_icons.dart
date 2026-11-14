import 'package:flutter/widgets.dart';

/// Ikon garis pada kanvas 24 x 24 dari prototipe Gerbang. [build] menyusun
/// jalurnya; [fill] (opsional) digambar lebih dulu sebagai isian.
class GateIcon extends CustomPainter {
  const GateIcon._(
    this.kind, {
    required this.color,
    this.fill,
    this.strokeWidth = 2.4,
  });

  const GateIcon.back({required Color color})
    : this._(GateIconKind.back, color: color, strokeWidth: 3);
  const GateIcon.next({required Color color})
    : this._(GateIconKind.next, color: color, strokeWidth: 3);
  const GateIcon.refresh({required Color color})
    : this._(GateIconKind.refresh, color: color, strokeWidth: 2.6);
  const GateIcon.lockClosed()
    : this._(
        GateIconKind.lockClosed,
        color: const Color(0xFFB36B00),
        fill: const Color(0xFFFFC233),
      );
  const GateIcon.lockOpen()
    : this._(
        GateIconKind.lockOpen,
        color: const Color(0xFF157A28),
        fill: const Color(0xFF8CE99A),
      );
  const GateIcon.speaker({required Color color})
    : this._(GateIconKind.speaker, color: color, fill: color);

  final GateIconKind kind;
  final Color color;
  final Color? fill;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    Offset p(double x, double y) => Offset(x * k, y * k);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()..color = fill ?? color;
    RRect body() => RRect.fromRectAndRadius(
      Rect.fromLTWH(4.5 * k, 10.5 * k, 15 * k, 10 * k),
      Radius.circular(2.5 * k),
    );

    switch (kind) {
      case GateIconKind.back:
        canvas
          ..drawLine(p(19, 12), p(6, 12), stroke)
          ..drawPath(
            Path()
              ..moveTo(11 * k, 6 * k)
              ..lineTo(5 * k, 12 * k)
              ..lineTo(11 * k, 18 * k),
            stroke,
          );
      case GateIconKind.next:
        canvas
          ..drawLine(p(5, 12), p(18, 12), stroke)
          ..drawPath(
            Path()
              ..moveTo(13 * k, 6 * k)
              ..lineTo(19 * k, 12 * k)
              ..lineTo(13 * k, 18 * k),
            stroke,
          );
      case GateIconKind.refresh:
        // `M20 12a8 8 0 1 1-2.6-5.9` dan `M20 4v5h-5`.
        canvas
          ..drawArc(
            Rect.fromCircle(center: p(12, 12), radius: 8 * k),
            0,
            // Dari kanan (3 jam) searah jarum jam hingga sekitar 1 jam.
            5.46,
            false,
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(20 * k, 4 * k)
              ..lineTo(20 * k, 9 * k)
              ..lineTo(15 * k, 9 * k),
            stroke,
          );
      case GateIconKind.lockClosed:
        canvas
          ..drawRRect(body(), fillPaint)
          ..drawRRect(body(), stroke)
          ..drawPath(
            Path()
              ..moveTo(8 * k, 10.5 * k)
              ..lineTo(8 * k, 7.5 * k)
              ..arcToPoint(p(16, 7.5), radius: Radius.circular(4 * k))
              ..lineTo(16 * k, 10.5 * k),
            stroke,
          )
          ..drawLine(p(12, 14.5), p(12, 17), stroke);
      case GateIconKind.lockOpen:
        canvas
          ..drawRRect(body(), fillPaint)
          ..drawRRect(body(), stroke)
          ..drawPath(
            Path()
              ..moveTo(8 * k, 10.5 * k)
              ..lineTo(8 * k, 7.5 * k)
              ..arcToPoint(p(15.7, 5.9), radius: Radius.circular(4 * k)),
            stroke,
          )
          ..drawPath(
            Path()
              ..moveTo(9.5 * k, 15.5 * k)
              ..lineTo(11.3 * k, 17.3 * k)
              ..lineTo(14.7 * k, 13.7 * k),
            stroke,
          );
      case GateIconKind.speaker:
        final cone = Path()
          ..moveTo(4 * k, 9.5 * k)
          ..lineTo(7.5 * k, 9.5 * k)
          ..lineTo(12 * k, 5.5 * k)
          ..lineTo(12 * k, 18.5 * k)
          ..lineTo(7.5 * k, 14.5 * k)
          ..lineTo(4 * k, 14.5 * k)
          ..close();
        canvas
          ..drawPath(cone, fillPaint)
          ..drawPath(cone, stroke)
          ..drawArc(
            Rect.fromCircle(center: p(11.5, 12), radius: 4.2 * k),
            -0.9,
            1.8,
            false,
            stroke,
          )
          ..drawArc(
            Rect.fromCircle(center: p(11, 12), radius: 8 * k),
            -0.75,
            1.5,
            false,
            stroke,
          );
    }
  }

  @override
  bool shouldRepaint(GateIcon old) =>
      old.kind != kind || old.color != color || old.fill != fill;
}

enum GateIconKind { back, next, refresh, lockClosed, lockOpen, speaker }

/// Bintang berkelip latar (`M12 0l3 9 9 3-9 3-3 9-3-9-9-3 9-3z`).
class SparklePainter extends CustomPainter {
  const SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(12 * k, 0)
      ..lineTo(15 * k, 9 * k)
      ..lineTo(24 * k, 12 * k)
      ..lineTo(15 * k, 15 * k)
      ..lineTo(12 * k, 24 * k)
      ..lineTo(9 * k, 15 * k)
      ..lineTo(0, 12 * k)
      ..lineTo(9 * k, 9 * k)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.color != color;
}

/// Bintik putih tipis latar (radial-gradient 30 px, jari-jari 2 px).
class DotsPainter extends CustomPainter {
  const DotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x17FFFFFF);
    for (var y = 0.0; y < size.height; y += 30) {
      for (var x = 0.0; x < size.width; x += 30) {
        canvas.drawCircle(Offset(x + 15, y + 15), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotsPainter old) => false;
}

/// Ekor gelembung bantuan: bayangan gelap lalu putih (`viewBox 0 0 36 26`).
class BubbleTailPainter extends CustomPainter {
  const BubbleTailPainter({required this.fill, required this.shadow});

  final Color fill;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 36;
    Path tri(double dy, double tip) => Path()
      ..moveTo(4 * k, dy * k)
      ..lineTo(32 * k, dy * k)
      ..lineTo(18 * k, tip * k)
      ..close();
    canvas
      ..drawPath(tri(6, 26), Paint()..color = shadow)
      ..drawPath(tri(0, 20), Paint()..color = fill);
  }

  @override
  bool shouldRepaint(BubbleTailPainter old) =>
      old.fill != fill || old.shadow != shadow;
}
