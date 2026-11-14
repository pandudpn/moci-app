import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import 'sambutan_icons.dart';

const _white = Color(0xFFFFFFFF);
const _pillInk = Color(0xFF1B4A82);
const _logo = [
  ('M', MociColors.logoM),
  ('o', MociColors.logoO),
  ('c', MociColors.logoC),
  ('i', MociColors.logoI),
];

/// Matahari, awan, dan bukit di belakang Sambutan (diam, tanpa animasi).
class SambutanScenery extends StatelessWidget {
  const SambutanScenery({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Stack(
        children: [
          Positioned(
            left: 330,
            top: -40,
            width: 190,
            height: 190,
            child: CustomPaint(painter: _SunPainter()),
          ),
          Positioned(
            left: 760,
            top: 200,
            width: 190,
            height: 107,
            child: Opacity(
              opacity: .95,
              child: CustomPaint(painter: _CloudPainter()),
            ),
          ),
          Positioned(
            left: 250,
            top: 40,
            width: 130,
            height: 73,
            child: Opacity(
              opacity: .85,
              child: CustomPaint(painter: _CloudPainter()),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: 1180,
            height: 300,
            child: CustomPaint(painter: _HillPainter()),
          ),
        ],
      ),
    );
  }
}

/// Logo "Moci" berhuruf warna dengan tagline di bawahnya.
class SambutanLogo extends StatelessWidget {
  const SambutanLogo({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    Shadow w(double dx, double dy) =>
        Shadow(color: _white, offset: Offset(dx, dy));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (char, color) in _logo)
              Text(
                char,
                style: MociText.title.copyWith(
                  fontSize: 104,
                  height: 1,
                  letterSpacing: 3,
                  color: color,
                  shadows: [
                    w(4, 0),
                    w(-4, 0),
                    w(0, 4),
                    w(0, -4),
                    w(3, 3),
                    w(-3, 3),
                    w(3, -3),
                    w(-3, -3),
                    const Shadow(
                      color: Color(0x382B2350),
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            tag,
            style: MociText.label.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _pillInk,
            ),
          ),
        ),
      ],
    );
  }
}

/// Pil kecil bercentang ("Tanpa iklan").
class SambutanBadge extends StatelessWidget {
  const SambutanBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: MociColors.neutralShadow, offset: Offset(0, 4)),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomPaint(
                size: Size(20, 20),
                painter: CheckPainter(color: Color(0xFF1E8A31), strokeWidth: 3),
              ),
              const SizedBox(width: 6),
              Text(text, style: MociText.label.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  const _SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 230);
    final ray = Paint()..color = const Color(0xFFFFE066);
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.translate(115, 115);
      canvas.rotate(i * math.pi / 4);
      canvas.translate(-115, -115);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(109, 4, 12, 34),
          const Radius.circular(6),
        ),
        ray,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      const Offset(115, 115),
      64,
      Paint()..color = const Color(0xFFFFE88A),
    );
    canvas.drawCircle(
      const Offset(115, 115),
      56,
      Paint()..color = const Color(0xFFFFD43B),
    );
  }

  @override
  bool shouldRepaint(_SunPainter old) => false;
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 160, size.height / 90);
    final p = Path()
      ..moveTo(30, 80)
      ..cubicTo(12, 80, 10, 56, 28, 52)
      ..cubicTo(26, 30, 54, 22, 66, 36)
      ..cubicTo(74, 14, 112, 14, 118, 40)
      ..cubicTo(138, 36, 150, 58, 138, 70)
      ..cubicTo(136, 78, 128, 80, 122, 80)
      ..close();
    canvas.drawPath(p, Paint()..color = _white);
  }

  @override
  bool shouldRepaint(_CloudPainter old) => false;
}

class _HillPainter extends CustomPainter {
  const _HillPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, 120)
      ..cubicTo(160, 40, 330, 60, 470, 110)
      ..cubicTo(620, 160, 760, 70, 920, 70)
      ..cubicTo(1040, 70, 1120, 100, 1180, 120)
      ..lineTo(1180, 300)
      ..lineTo(0, 300)
      ..close();
    final front = Path()
      ..moveTo(0, 200)
      ..cubicTo(140, 150, 300, 160, 440, 190)
      ..cubicTo(600, 224, 760, 160, 920, 170)
      ..cubicTo(1040, 178, 1120, 200, 1180, 210)
      ..lineTo(1180, 300)
      ..lineTo(0, 300)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFFA6E38A));
    canvas.drawPath(front, Paint()..color = const Color(0xFF6FCF63));
  }

  @override
  bool shouldRepaint(_HillPainter old) => false;
}
