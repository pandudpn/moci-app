import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Satu keyframe: waktu 0..1, geser Y, skala X/Y, putar (derajat).
class MociKeyframe {
  const MociKeyframe(
    this.t, {
    this.dy = 0,
    this.sx = 1,
    this.sy = 1,
    this.rot = 0,
  });

  final double t;
  final double dy;
  final double sx;
  final double sy;
  final double rot;
}

/// Hasil interpolasi keyframe pada satu waktu.
class MociPose2D {
  const MociPose2D(this.dy, this.sx, this.sy, this.rot);
  static const identity = MociPose2D(0, 1, 1, 0);

  final double dy;
  final double sx;
  final double sy;
  final double rot;
}

/// Interpolasi keyframe ala CSS: kurva dipakai per interval.
MociPose2D sampleKeyframes(
  List<MociKeyframe> frames,
  double t, {
  Curve curve = Curves.easeInOut,
}) {
  for (var i = 0; i < frames.length - 1; i++) {
    final a = frames[i];
    final b = frames[i + 1];
    if (t >= a.t && t <= b.t) {
      final span = b.t - a.t;
      final u = span == 0 ? 1.0 : curve.transform((t - a.t) / span);
      double l(double x, double y) => x + (y - x) * u;
      return MociPose2D(
        l(a.dy, b.dy),
        l(a.sx, b.sx),
        l(a.sy, b.sy),
        l(a.rot, b.rot),
      );
    }
  }
  final last = frames.last;
  return MociPose2D(last.dy, last.sx, last.sy, last.rot);
}

const mociSquishFrames = [
  MociKeyframe(0),
  MociKeyframe(.30, sx: 1.05, sy: .95),
  MociKeyframe(.55, dy: -14, sx: .97, sy: 1.04),
  MociKeyframe(.80, sx: 1.02, sy: .98),
  MociKeyframe(1),
];

const mociBlinkFrames = [
  MociKeyframe(0),
  MociKeyframe(.90),
  MociKeyframe(.94, sy: .1),
  MociKeyframe(1),
];

const mociWaveFrames = [
  MociKeyframe(0),
  MociKeyframe(.5, rot: -22),
  MociKeyframe(1),
];

const mociLeafFrames = [
  MociKeyframe(0, rot: -6),
  MociKeyframe(.5, rot: 6),
  MociKeyframe(1, rot: -6),
];

const mociHopFrames = [
  MociKeyframe(0),
  MociKeyframe(.35, dy: -34, rot: -5),
  MociKeyframe(.70, sx: 1.08, sy: .92),
  MociKeyframe(1),
];

const mociJumpFrames = [
  MociKeyframe(0),
  MociKeyframe(.20, sx: 1.06, sy: .94),
  MociKeyframe(.50, dy: -40, sx: .97, sy: 1.04),
  MociKeyframe(.80, sx: 1.04, sy: .96),
  MociKeyframe(1),
];

/// Maskot Moci pose biasa, digambar dari SVG inline prototipe (viewBox 240).
/// Tiap bagian punya animasi sendiri; nilai 0..1 dari controller masing-masing.
class MociMascotPainter extends CustomPainter {
  MociMascotPainter({
    required this.squish,
    required this.blink,
    required this.wave,
    required this.leaf,
    required this.hop,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final Animation<double> squish;
  final Animation<double> blink;
  final Animation<double> wave;
  final Animation<double> leaf;

  /// 0..1 saat lompat diketuk; 0 = diam.
  final Animation<double> hop;

  static const _bodyShade = Color(0xFFF5B700);
  static const _body = Color(0xFFFFD43B);
  static const _belly = Color(0xFFFFF1B0);
  static const _ink = Color(0xFF2B2350);
  static const _orange = Color(0xFFFF8A3D);
  static const _cheek = Color(0xFFFF8FA3);

  static final Path _bodyPath = Path()
    ..moveTo(120, 52)
    ..cubicTo(178, 52, 212, 104, 212, 152)
    ..cubicTo(212, 196, 172, 218, 120, 218)
    ..cubicTo(68, 218, 28, 196, 28, 152)
    ..cubicTo(28, 104, 62, 52, 120, 52)
    ..close();

  static void _withTransform(
    Canvas canvas,
    MociPose2D p,
    Offset origin,
    VoidCallback body,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy + p.dy);
    canvas.rotate(p.rot * math.pi / 180);
    canvas.scale(p.sx, p.sy);
    canvas.translate(-origin.dx, -origin.dy);
    body();
    canvas.restore();
  }

  static void _ellipse(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    Color color, {
    double rotate = 0,
    double opacity = 1,
  }) {
    final paint = Paint()
      ..isAntiAlias = true
      ..color = color.withValues(alpha: opacity);
    canvas.save();
    if (rotate != 0) {
      canvas.translate(cx, cy);
      canvas.rotate(rotate * math.pi / 180);
      canvas.translate(-cx, -cy);
    }
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      paint,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 240, size.height / 240);

    // Lompat saat diketuk membungkus semuanya, termasuk bayangan tanah.
    final hopPose = hop.value == 0 || hop.value == 1
        ? MociPose2D.identity
        : sampleKeyframes(mociHopFrames, hop.value, curve: Curves.easeOut);
    _withTransform(canvas, hopPose, const Offset(120, 120), () {
      _ellipse(canvas, 120, 228, 64, 9, _ink, opacity: .14);
      final sq = sampleKeyframes(mociSquishFrames, squish.value);
      _withTransform(
        canvas,
        sq,
        const Offset(124, 223),
        () => _paintBody(canvas),
      );
    });
    canvas.restore();
  }

  void _paintBody(Canvas canvas) {
    final fill = Paint()..isAntiAlias = true;
    Paint stroke(Color c) => Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = c;

    // Tangan kiri.
    _ellipse(canvas, 36, 148, 16, 28, _bodyShade, rotate: 20);
    // Tangan kanan melambai, berputar di bahu.
    _withTransform(
      canvas,
      MociPose2D(0, 1, 1, sampleKeyframes(mociWaveFrames, wave.value).rot),
      const Offset(189, 128),
      () => _ellipse(canvas, 206, 104, 17, 34, _bodyShade, rotate: 35),
    );
    // Kaki.
    _ellipse(canvas, 96, 214, 18, 9, _orange);
    _ellipse(canvas, 144, 214, 18, 9, _orange);
    // Badan dan bayangan perut, dipotong ke bentuk badan.
    canvas.drawPath(_bodyPath, fill..color = _body);
    canvas.save();
    canvas.clipPath(_bodyPath);
    _ellipse(canvas, 160, 204, 112, 58, _bodyShade, opacity: .45);
    canvas.restore();
    _ellipse(canvas, 120, 174, 52, 36, _belly);
    _ellipse(
      canvas,
      78,
      92,
      16,
      9,
      const Color(0xFFFFFFFF),
      rotate: -35,
      opacity: .75,
    );

    // Daun bergoyang dari pangkal tangkai.
    _withTransform(
      canvas,
      MociPose2D(0, 1, 1, sampleKeyframes(mociLeafFrames, leaf.value).rot),
      const Offset(125, 56),
      () {
        canvas.drawPath(
          Path()
            ..moveTo(120, 54)
            ..cubicTo(120, 44, 122, 36, 126, 28),
          stroke(const Color(0xFF2F9E44)),
        );
        canvas.drawPath(
          Path()
            ..moveTo(124, 32)
            ..cubicTo(110, 14, 88, 14, 82, 22)
            ..cubicTo(92, 36, 112, 40, 124, 32)
            ..close(),
          fill..color = const Color(0xFF51CF66),
        );
        canvas.drawPath(
          Path()
            ..moveTo(126, 30)
            ..cubicTo(136, 10, 160, 6, 168, 14)
            ..cubicTo(160, 30, 140, 38, 126, 30)
            ..close(),
          fill..color = const Color(0xFF69DB7C),
        );
      },
    );

    // Mata berkedip (skala Y di tengah mata).
    final blinkPose = sampleKeyframes(mociBlinkFrames, blink.value);
    _withTransform(
      canvas,
      MociPose2D(0, 1, blinkPose.sy, 0),
      const Offset(120, 124),
      () {
        _ellipse(canvas, 94, 124, 10, 13, _ink);
        _ellipse(canvas, 146, 124, 10, 13, _ink);
        canvas.drawCircle(
          const Offset(97.5, 119),
          4,
          fill..color = const Color(0xFFFFFFFF),
        );
        canvas.drawCircle(
          const Offset(149.5, 119),
          4,
          fill..color = const Color(0xFFFFFFFF),
        );
      },
    );

    // Pipi dan paruh.
    _ellipse(canvas, 72, 148, 13, 8, _cheek, opacity: .8);
    _ellipse(canvas, 168, 148, 13, 8, _cheek, opacity: .8);
    canvas.drawPath(
      Path()
        ..moveTo(108, 142)
        ..cubicTo(114, 136, 126, 136, 132, 142)
        ..cubicTo(128, 152, 112, 152, 108, 142)
        ..close(),
      fill..color = _orange,
    );
  }

  @override
  bool shouldRepaint(MociMascotPainter old) =>
      old.squish != squish ||
      old.blink != blink ||
      old.wave != wave ||
      old.leaf != leaf ||
      old.hop != hop;
}
