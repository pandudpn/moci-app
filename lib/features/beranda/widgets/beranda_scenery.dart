import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../app/motion/ambient_motion.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';

const _white = Color(0xFFFFFFFF);
const _logo = [
  ('M', MociColors.logoM),
  ('o', MociColors.logoO),
  ('c', MociColors.logoC),
  ('i', MociColors.logoI),
];

/// Latar Beranda: matahari, awan, kilau, dan bukit. Awan meluncur, matahari
/// berputar, dan kilau berkelip seperti `Main.dc.html` / `HP.dc.html`.
/// Tanpa gerak, gambarnya diam seperti versi diam prototipe.
/// Posisi dalam koordinat artboard tablet atau HP.
class BerandaScenery extends StatelessWidget {
  const BerandaScenery.tablet({super.key}) : _phone = false;
  const BerandaScenery.phone({super.key}) : _phone = true;

  final bool _phone;

  /// Rentang luncur awan (px artboard) di masing-masing artboard.
  static const _tabletDrift = (from: -300.0, to: 1500.0);
  static const _phoneDrift = (from: -200.0, to: 1000.0);

  @override
  Widget build(BuildContext context) {
    final width = _phone ? 844.0 : 1180.0;
    final height = _phone ? 390.0 : 820.0;
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        // Awan yang meluncur keluar panggung tidak boleh menimpa latar luar.
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: _phone ? _phoneItems : _tabletItems,
          ),
        ),
      ),
    );
  }

  List<Widget> get _tabletItems => [
    _sun(left: -50, top: -50, spokes: 12, face: true),
    _cloud(
      key: const ValueKey('beranda-cloud-1'),
      left: 20,
      top: 96,
      width: 190,
      height: 107,
      opacity: .95,
      period: 58,
      drift: _tabletDrift,
    ),
    _cloud(
      key: const ValueKey('beranda-cloud-2'),
      left: 4,
      top: 214,
      width: 140,
      height: 79,
      opacity: .8,
      period: 76,
      drift: _tabletDrift,
    ),
    _sparkle(
      key: const ValueKey('beranda-sparkle-1'),
      left: 716,
      top: 112,
      size: 24,
    ),
    _sparkle(
      key: const ValueKey('beranda-sparkle-2'),
      left: 520,
      top: 64,
      size: 18,
      delay: -1.2,
    ),
    Positioned(
      left: 0,
      bottom: 0,
      width: 1180,
      height: 300,
      child: CustomPaint(painter: _HillPainter(phone: false)),
    ),
  ];

  List<Widget> get _phoneItems => [
    _cloud(
      key: const ValueKey('beranda-cloud-1'),
      left: 8,
      top: 78,
      width: 120,
      height: 68,
      opacity: .9,
      period: 46,
      drift: _phoneDrift,
    ),
    _sparkle(
      key: const ValueKey('beranda-sparkle-1'),
      left: 236,
      top: 22,
      size: 16,
    ),
    Positioned(
      left: 0,
      bottom: 0,
      width: 844,
      height: 170,
      child: CustomPaint(painter: _HillPainter(phone: true)),
    ),
  ];

  /// mnSpin: 360° per 40 detik, poros tengah. Hanya sinarnya yang berputar.
  static Widget _sun({
    required double left,
    required double top,
    required int spokes,
    required bool face,
  }) {
    return Positioned(
      key: const ValueKey('beranda-sun'),
      left: left,
      top: top,
      width: 190,
      height: 190,
      child: Stack(
        children: [
          Positioned.fill(
            child: AmbientLayer(
              builder: (context, seconds, child) => Transform.rotate(
                angle: sunAngle(t: seconds, period: 40),
                child: child,
              ),
              child: CustomPaint(painter: _SunRaysPainter(spokes: spokes)),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _SunDiscPainter(face: face)),
          ),
        ],
      ),
    );
  }

  /// mnDrift: linear, berulang; awan mulai dari posisi diamnya.
  static Widget _cloud({
    required Key key,
    required double left,
    required double top,
    required double width,
    required double height,
    required double opacity,
    required double period,
    required ({double from, double to}) drift,
  }) {
    return Positioned(
      key: key,
      left: left,
      top: top,
      width: width,
      height: height,
      child: Opacity(
        opacity: opacity,
        child: AmbientLayer(
          builder: (context, seconds, child) => Transform.translate(
            offset: Offset(
              driftOffset(
                startX: left,
                from: drift.from,
                to: drift.to,
                period: period,
                t: seconds,
              ),
              0,
            ),
            child: child,
          ),
          child: const _Cloud(),
        ),
      ),
    );
  }

  /// mnTwinkle: 2,4 detik, opacity 0,35 → 1 dan skala 0,75 → 1,1.
  static Widget _sparkle({
    required Key key,
    required double left,
    required double top,
    required double size,
    double delay = 0,
  }) {
    return Positioned(
      key: key,
      left: left,
      top: top,
      width: size,
      height: size,
      child: AmbientLayer(
        builder: (context, seconds, child) {
          final t = twinkleAt(t: seconds, period: 2.4, delay: delay);
          return Opacity(
            opacity: t.opacity,
            child: Transform.scale(scale: t.scale, child: child),
          );
        },
        child: const _Sparkle(),
      ),
    );
  }
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

class _SunRaysPainter extends CustomPainter {
  const _SunRaysPainter({required this.spokes});

  final int spokes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 230);
    final ray = Paint()..color = const Color(0xFFFFE066);
    for (var i = 0; i < spokes; i++) {
      canvas.save();
      canvas.translate(115, 115);
      canvas.rotate(i * 2 * math.pi / spokes);
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
  }

  @override
  bool shouldRepaint(_SunRaysPainter old) => old.spokes != spokes;
}

class _SunDiscPainter extends CustomPainter {
  const _SunDiscPainter({required this.face});

  /// Matahari Beranda punya wajah; matahari Sambutan tidak.
  final bool face;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 230);
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
    if (!face) return;
    final ink = Paint()..color = const Color(0xFF7A4A2A);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(100, 112), width: 10, height: 14),
      ink,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(130, 112), width: 10, height: 14),
      ink,
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
  bool shouldRepaint(_SunDiscPainter old) => old.face != face;
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
