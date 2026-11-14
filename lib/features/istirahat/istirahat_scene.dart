import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../app/theme/moci_text.dart';
import '../../widgets/moci_mascot.dart';

/// Latar bersama Istirahat dan Waktu Habis (varian prototipe `Istirahat`):
/// bulan, bintang berkelip, awan, dan Moci tidur dengan "Zzz".
///
/// Satu pengendali 78 detik (kelipatan persekutuan 2,6 s kelip, 3 s Zzz) menggerakkan
/// semuanya. Dengan gerak dikurangi (disableAnimations) semuanya diam.
class IstirahatScene extends StatefulWidget {
  const IstirahatScene({super.key});

  @override
  State<IstirahatScene> createState() => _IstirahatSceneState();
}

class _IstirahatSceneState extends State<IstirahatScene>
    with SingleTickerProviderStateMixin {
  static const _cycle = 78.0;

  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 78),
  );

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Detik animasi berjalan, dengan jeda negatif nol (jeda positif = mulai nanti).
  double _seconds(double delay) => _c.value * _cycle - delay;

  Widget _star(double x, double y, double size, Color color, double delay) {
    return Positioned(
      left: x,
      top: y,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            if (_still) return child!;
            final s = _seconds(delay);
            // isTw: 0% dan 100% = 0,3 / 0,75; 50% = 1 / 1,1.
            final phase = s < 0 ? 0.0 : (s / 2.6) % 1;
            final w = (1 - cos(phase * 2 * pi)) / 2;
            return Opacity(
              opacity: 0.3 + 0.7 * w,
              child: Transform.scale(scale: 0.75 + 0.35 * w, child: child),
            );
          },
          child: CustomPaint(
            size: Size.square(size),
            painter: _StarPainter(color),
          ),
        ),
      ),
    );
  }

  Widget _z(String text, double x, double size, double delay) {
    return Positioned(
      left: x,
      top: 40,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            if (_still) return child!;
            final s = _seconds(delay);
            if (s < 0) return const SizedBox.shrink();
            // isZ 3 s: bergeser (26, -90), membesar 0,6 -> 1,15; opacity 0 -> 1 (25%) -> 0.
            final p = (s / 3) % 1;
            final opacity = p < 0.25 ? p / 0.25 : 1 - (p - 0.25) / 0.75;
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(26 * p, -90 * p),
                child: Transform.scale(scale: 0.6 + 0.55 * p, child: child),
              ),
            );
          },
          child: Text(
            text,
            style: MociText.title.copyWith(
              fontSize: size,
              color: const Color(0xFFFFFFFF),
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFE066);
    const white = Color(0xFFFFFFFF);
    return SizedBox(
      width: 1180,
      height: 820,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 70,
            top: 50,
            child: ExcludeSemantics(
              child: CustomPaint(
                size: Size.square(120),
                painter: _MoonPainter(),
              ),
            ),
          ),
          _star(270, 70, 24, gold, 0),
          _star(420, 150, 16, white, 0.7),
          _star(180, 230, 14, white, 1.4),
          _star(520, 60, 20, white, 2),
          _star(1080, 120, 12, white, 0.4),
          _star(980, 700, 18, gold, 1.1),
          const Positioned(
            left: 60,
            top: 540,
            child: ExcludeSemantics(
              child: CustomPaint(
                size: Size(520, 220),
                painter: _CloudPainter(),
              ),
            ),
          ),
          Positioned(
            left: 170,
            top: 306,
            child: const MociMascot(size: 300, pose: MociPose.tidur),
          ),
          Positioned(
            left: 60,
            top: 300,
            width: 520,
            height: 460,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _z('Z', 360, 40, 0),
                _z('z', 380, 32, 1),
                _z('z', 400, 26, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  const _MoonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 120;
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(
        Rect.fromCircle(center: Offset(56 * k, 62 * k), radius: 46 * k),
      ),
      Path()..addOval(
        Rect.fromCircle(center: Offset(80 * k, 44 * k), radius: 42 * k),
      ),
    );
    canvas.drawPath(moon, Paint()..color = const Color(0xFFFFE88A));
  }

  @override
  bool shouldRepaint(_MoonPainter old) => false;
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    const pts = [
      (12.0, 0.0),
      (15.0, 9.0),
      (24.0, 12.0),
      (15.0, 15.0),
      (12.0, 24.0),
      (9.0, 15.0),
      (0.0, 12.0),
      (9.0, 9.0),
    ];
    final path = Path()..moveTo(pts[0].$1 * k, pts[0].$2 * k);
    for (final p in pts.skip(1)) {
      path.lineTo(p.$1 * k, p.$2 * k);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}

class _CloudPainter extends CustomPainter {
  const _CloudPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..moveTo(92, 210)
      ..cubicTo(40, 210, 22, 160, 62, 140)
      ..cubicTo(52, 92, 108, 66, 150, 88)
      ..cubicTo(166, 40, 238, 30, 266, 76)
      ..cubicTo(296, 44, 360, 52, 372, 100)
      ..cubicTo(420, 86, 466, 118, 458, 160)
      ..cubicTo(500, 166, 506, 210, 470, 210)
      ..close();
    final shade = Path()
      ..moveTo(92, 210)
      ..cubicTo(40, 210, 22, 160, 62, 140)
      ..cubicTo(70, 168, 110, 180, 150, 176)
      ..cubicTo(200, 196, 300, 196, 360, 178)
      ..cubicTo(410, 186, 450, 176, 458, 160)
      ..cubicTo(500, 166, 506, 210, 470, 210)
      ..close();
    canvas
      ..drawPath(body, Paint()..color = const Color(0xFFFFFFFF))
      ..drawPath(shade, Paint()..color = const Color(0xFFE6E0FF));
  }

  @override
  bool shouldRepaint(_CloudPainter old) => false;
}

/// Ikon garis pada kanvas 24 x 24: mata, kedip, dan regang.
enum StepIconKind { look, blink, stretch }

class StepIcon extends CustomPainter {
  const StepIcon(this.kind, this.color);

  final StepIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.scale(k);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (kind) {
      case StepIconKind.look:
        canvas
          ..drawPath(
            Path()
              ..moveTo(2, 12)
              ..cubicTo(2, 12, 5.5, 6, 12, 6)
              ..cubicTo(18.5, 6, 22, 12, 22, 12)
              ..cubicTo(22, 12, 18.5, 18, 12, 18)
              ..cubicTo(5.5, 18, 2, 12, 2, 12)
              ..close(),
            p,
          )
          ..drawCircle(const Offset(12, 12), 3, p);
      case StepIconKind.blink:
        canvas.drawPath(
          Path()
            ..moveTo(3, 11)
            ..cubicTo(5.5, 14, 8.5, 15.5, 12, 15.5)
            ..cubicTo(15.5, 15.5, 18.5, 14, 21, 11)
            ..moveTo(7, 15)
            ..lineTo(5.5, 17)
            ..moveTo(12, 16.5)
            ..lineTo(12, 19)
            ..moveTo(17, 15)
            ..lineTo(18.5, 17),
          p,
        );
      case StepIconKind.stretch:
        canvas
          ..drawCircle(const Offset(12, 5), 2, p)
          ..drawPath(
            Path()
              ..moveTo(6, 3)
              ..lineTo(9, 9)
              ..lineTo(15, 9)
              ..lineTo(18, 3)
              ..moveTo(9, 9)
              ..lineTo(9, 14)
              ..lineTo(7, 21)
              ..moveTo(15, 9)
              ..lineTo(15, 14)
              ..lineTo(17, 21)
              ..moveTo(9, 14)
              ..lineTo(15, 14),
            p,
          );
    }
  }

  @override
  bool shouldRepaint(StepIcon old) => old.kind != kind || old.color != color;
}
