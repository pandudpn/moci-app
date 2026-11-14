import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';

const _white = Color(0xFFFFFFFF);
const _logo = [
  ('M', MociColors.logoM),
  ('o', MociColors.logoO),
  ('c', MociColors.logoC),
  ('i', MociColors.logoI),
];

/// Latar Beranda: matahari, awan, kilau, dan bukit. Diam (tanpa animasi).
/// Posisi dalam koordinat artboard tablet atau HP.
class BerandaScenery extends StatelessWidget {
  const BerandaScenery.tablet({super.key}) : _phone = false;
  const BerandaScenery.phone({super.key}) : _phone = true;

  final bool _phone;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: _phone ? _phoneItems : _tabletItems,
      ),
    );
  }

  static const _tabletItems = [
    Positioned(
      left: -50,
      top: -50,
      width: 190,
      height: 190,
      child: CustomPaint(painter: _SunPainter()),
    ),
    Positioned(
      left: 20,
      top: 96,
      width: 190,
      height: 107,
      child: Opacity(opacity: .95, child: _Cloud()),
    ),
    Positioned(
      left: 4,
      top: 214,
      width: 140,
      height: 79,
      child: Opacity(opacity: .8, child: _Cloud()),
    ),
    Positioned(left: 716, top: 112, width: 24, height: 24, child: _Sparkle()),
    Positioned(left: 520, top: 64, width: 18, height: 18, child: _Sparkle()),
    Positioned(
      left: 0,
      bottom: 0,
      width: 1180,
      height: 300,
      child: CustomPaint(painter: _HillPainter(phone: false)),
    ),
  ];

  static const _phoneItems = [
    Positioned(
      left: 8,
      top: 78,
      width: 120,
      height: 68,
      child: Opacity(opacity: .9, child: _Cloud()),
    ),
    Positioned(left: 236, top: 22, width: 16, height: 16, child: _Sparkle()),
    Positioned(
      left: 0,
      bottom: 0,
      width: 844,
      height: 170,
      child: CustomPaint(painter: _HillPainter(phone: true)),
    ),
  ];
}

/// Logo "Moci" berhuruf warna berkontur putih.
class BerandaLogo extends StatelessWidget {
  const BerandaLogo({
    super.key,
    required this.fontSize,
    required this.outline,
    required this.drop,
    required this.spacing,
  });

  final double fontSize;

  /// Tebal kontur putih.
  final double outline;

  /// Jarak bayangan jatuh di bawah huruf.
  final double drop;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final d = outline * .75;
    Shadow w(double dx, double dy) =>
        Shadow(color: _white, offset: Offset(dx, dy));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (char, color) in _logo)
          Text(
            char,
            style: MociText.title.copyWith(
              fontSize: fontSize,
              height: 1,
              letterSpacing: spacing,
              color: color,
              shadows: [
                w(outline, 0),
                w(-outline, 0),
                w(0, outline),
                w(0, -outline),
                w(d, d),
                w(-d, d),
                w(d, -d),
                w(-d, -d),
                Shadow(color: const Color(0x382B2350), offset: Offset(0, drop)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Segitiga ekor gelembung, titik-titiknya dalam koordinat [size].
class TailShape extends StatelessWidget {
  const TailShape({super.key, required this.size, required this.points});

  final Size size;
  final List<Offset> points;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(size: size, painter: _TailPainter(points)),
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = _white);
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.points != points;
}

class _Sparkle extends StatelessWidget {
  const _Sparkle();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _SparklePainter(_white));
}

/// Bintang empat sudut `M12 0l3 9 9 3-9 3-3 9-3-9-9-3 9-3z` (kanvas 24).
class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    const pts = [
      Offset(12, 0),
      Offset(15, 9),
      Offset(24, 12),
      Offset(15, 15),
      Offset(12, 24),
      Offset(9, 15),
      Offset(0, 12),
      Offset(9, 9),
    ];
    canvas.drawPath(
      Path()..addPolygon([for (final p in pts) p * k], true),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

/// Bintang empat sudut berwarna, dipakai kartu Main Yuk.
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SparklePainter(color));
}

class _Cloud extends StatelessWidget {
  const _Cloud();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _CloudPainter());
}

class _SunPainter extends CustomPainter {
  const _SunPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 230);
    final ray = Paint()..color = const Color(0xFFFFE066);
    for (var i = 0; i < 12; i++) {
      canvas.save();
      canvas.translate(115, 115);
      canvas.rotate(i * math.pi / 6);
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
    final face = Paint()..color = const Color(0xFF7A4A2A);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 112), width: 10, height: 14),
      face,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(130, 112), width: 10, height: 14),
      face,
    );
    canvas.drawPath(
      Path()
        ..moveTo(102, 128)
        ..quadraticBezierTo(115, 138, 128, 128),
      Paint()
        ..color = const Color(0xFF7A4A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
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
  const _HillPainter({required this.phone});

  final bool phone;

  @override
  void paint(Canvas canvas, Size size) {
    final Path back;
    final Path front;
    if (phone) {
      back = Path()
        ..moveTo(0, 70)
        ..cubicTo(110, 22, 236, 34, 336, 62)
        ..cubicTo(446, 94, 544, 40, 658, 40)
        ..cubicTo(744, 40, 800, 56, 844, 68)
        ..lineTo(844, 170)
        ..lineTo(0, 170)
        ..close();
      front = Path()
        ..moveTo(0, 116)
        ..cubicTo(100, 88, 214, 92, 314, 110)
        ..cubicTo(430, 130, 544, 92, 658, 98)
        ..cubicTo(744, 102, 800, 114, 844, 120)
        ..lineTo(844, 170)
        ..lineTo(0, 170)
        ..close();
    } else {
      back = Path()
        ..moveTo(0, 120)
        ..cubicTo(160, 40, 330, 60, 470, 110)
        ..cubicTo(620, 160, 760, 70, 920, 70)
        ..cubicTo(1040, 70, 1120, 100, 1180, 120)
        ..lineTo(1180, 300)
        ..lineTo(0, 300)
        ..close();
      front = Path()
        ..moveTo(0, 200)
        ..cubicTo(140, 150, 300, 160, 440, 190)
        ..cubicTo(600, 224, 760, 160, 920, 170)
        ..cubicTo(1040, 178, 1120, 200, 1180, 210)
        ..lineTo(1180, 300)
        ..lineTo(0, 300)
        ..close();
    }
    canvas.drawPath(back, Paint()..color = const Color(0xFFA6E38A));
    canvas.drawPath(front, Paint()..color = const Color(0xFF6FCF63));
  }

  @override
  bool shouldRepaint(_HillPainter old) => old.phone != phone;
}
