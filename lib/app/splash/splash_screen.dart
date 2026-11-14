import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../widgets/moci_mascot.dart';
import '../layout/moci_stage.dart';
import '../routes.dart';
import '../theme/menu_theme.dart';
import '../theme/moci_text.dart';

/// Semua waktu splash intro (ms), dalam satu tempat.
abstract final class SplashTimeline {
  static const total = 5000;
  static const navigateAt = 3600;

  // Moci jatuh, squash, memantul, diam.
  static const dropEnd = 700.0;
  static const bounceTop = 1000.0;
  static const settle = 1300.0;
  static const bobPeriod = 2400.0;

  // Huruf M, o, c, i.
  static const letterStart = 1100.0;
  static const letterStagger = 100.0;
  static const letterPeak = 400.0; // 1100 -> 1500
  static const letterUnder = 700.0; // 1800
  static const letterEnd = 900.0; // 2000

  // Pil tagline.
  static const tagStart = 1900.0;
  static const tagEnd = 2300.0;

  // Tiga titik.
  static const dotPeriod = 1000.0;
  static const dotStagger = 150.0;
}

/// Nilai ukuran per perangkat (tablet 1180 x 820, HP 844 x 390).
class _Spec {
  const _Spec({
    required this.mociLeft,
    required this.mociTop,
    required this.mociSize,
    required this.fall,
    required this.bounce,
    required this.sway,
    required this.letterSize,
    required this.letterSpacing,
    required this.letterGap,
    required this.outline,
    required this.outlineDiag,
    required this.letterShadow,
    required this.titleTop,
    required this.titleLeft,
    required this.pillTop,
    required this.pillLeft,
    required this.pillPad,
    required this.pillFont,
    required this.pillShadow,
    required this.rise,
    required this.dotsTop,
    required this.dotSize,
    required this.dotGap,
    required this.dotLift,
    required this.sunLeft,
    required this.sunTop,
    required this.sunSize,
    required this.hillHeight,
    required this.clouds,
    required this.cloudFrom,
    required this.cloudTo,
  });

  final double mociLeft, mociTop, mociSize;
  final double fall, bounce, sway;
  final double letterSize, letterSpacing, letterGap;
  final double outline, outlineDiag, letterShadow;
  final double titleTop;

  /// null = tengah horizontal.
  final double? titleLeft;
  final double pillTop;
  final double? pillLeft;
  final EdgeInsets pillPad;
  final double pillFont, pillShadow, rise;
  final double dotsTop, dotSize, dotGap, dotLift;
  final double sunLeft, sunTop, sunSize;
  final double hillHeight;
  final List<_Cloud> clouds;
  final double cloudFrom, cloudTo;

  static const tablet = _Spec(
    mociLeft: 455,
    mociTop: 92,
    mociSize: 270,
    fall: 560,
    bounce: 34,
    sway: 10,
    letterSize: 136,
    letterSpacing: 4,
    letterGap: 2,
    outline: 5,
    outlineDiag: 4,
    letterShadow: 12,
    titleTop: 360,
    titleLeft: null,
    pillTop: 560,
    pillLeft: null,
    pillPad: EdgeInsets.fromLTRB(28, 10, 28, 12),
    pillFont: 30,
    pillShadow: 6,
    rise: 16,
    dotsTop: 712,
    dotSize: 16,
    dotGap: 16,
    dotLift: 12,
    sunLeft: 940,
    sunTop: 40,
    sunSize: 180,
    hillHeight: 260,
    clouds: [
      _Cloud(top: 150, width: 190, seconds: 60, delay: -18),
      _Cloud(top: 40, width: 130, seconds: 75, delay: -50),
      _Cloud(top: 270, width: 110, seconds: 68, delay: -5),
    ],
    cloudFrom: -300,
    cloudTo: 1500,
  );

  static const phone = _Spec(
    mociLeft: 220,
    mociTop: 60,
    mociSize: 170,
    fall: 320,
    bounce: 20,
    sway: 6,
    letterSize: 92,
    letterSpacing: 3,
    letterGap: 1,
    outline: 4,
    outlineDiag: 3,
    letterShadow: 8,
    titleTop: 82,
    titleLeft: 410,
    pillTop: 208,
    pillLeft: 416,
    pillPad: EdgeInsets.fromLTRB(18, 7, 18, 8),
    pillFont: 21,
    pillShadow: 4,
    rise: 10,
    dotsTop: 330,
    dotSize: 12,
    dotGap: 12,
    dotLift: 8,
    sunLeft: 712,
    sunTop: 18,
    sunSize: 100,
    hillHeight: 120,
    clouds: [
      _Cloud(top: 70, width: 110, seconds: 50, delay: -12),
      _Cloud(top: 20, width: 80, seconds: 64, delay: -40),
    ],
    cloudFrom: -200,
    cloudTo: 1050,
  );
}

class _Cloud {
  const _Cloud({
    required this.top,
    required this.width,
    required this.seconds,
    required this.delay,
  });

  final double top, width, seconds, delay;
}

const _white = Color(0xFFFFFFFF);
const _pillInk = Color(0xFF1B4A82);
const _shadowInk = Color(0x382B2350); // rgba(43,35,80,.22)
const _letters = [
  ('M', Color(0xFFF03E7C)),
  ('o', Color(0xFFFF9F1C)),
  ('c', Color(0xFF1C8CF0)),
  ('i', Color(0xFF26A03B)),
];

/// Interpolasi antar kunci (ms, nilai) dengan easeOut; di luar rentang
/// nilainya bertahan.
double _kf(double t, List<(double, double)> keys) {
  if (t <= keys.first.$1) return keys.first.$2;
  for (var i = 1; i < keys.length; i++) {
    if (t <= keys[i].$1) {
      final (t0, v0) = keys[i - 1];
      final (t1, v1) = keys[i];
      final f = Curves.easeOut.transform((t - t0) / (t1 - t0));
      return v0 + (v1 - v0) * f;
    }
  }
  return keys.last.$2;
}

/// Splash intro 3,6 detik. Pindah ke Beranda (redirect memilih Sambutan bila
/// belum onboarding) saat waktu habis atau layar diketuk.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: SplashTimeline.total),
  );
  Timer? _timer;
  bool _gone = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: SplashTimeline.navigateAt),
      _next,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _controller.stop();
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    _timer?.cancel();
    context.go(Routes.beranda);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _next,
      child: MociStage(
        theme: MenuTheme.beranda,
        tablet: (_) => _SplashScene(
          spec: _Spec.tablet,
          animation: _controller,
          still: still,
        ),
        phone: (_) => _SplashScene(
          spec: _Spec.phone,
          animation: _controller,
          still: still,
        ),
      ),
    );
  }
}

class _SplashScene extends StatelessWidget {
  const _SplashScene({
    required this.spec,
    required this.animation,
    required this.still,
  });

  final _Spec spec;
  final Animation<double> animation;
  final bool still;

  /// Waktu (ms) pada controller; frame akhir yang diam bila gerak dikurangi.
  double get _t => still
      ? SplashTimeline.navigateAt.toDouble()
      : animation.value * SplashTimeline.total;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => _frame(context, _t),
    );
  }

  Widget _frame(BuildContext context, double t) {
    final s = spec;
    final tagText = context.l10n.berandaTag;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        for (final c in s.clouds) _cloud(c, t),
        Positioned(
          left: s.sunLeft,
          top: s.sunTop,
          width: s.sunSize,
          height: s.sunSize,
          child: CustomPaint(
            painter: _SunPainter(angle: still ? 0 : t / 40000 * 2 * math.pi),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: s.hillHeight,
          child: const CustomPaint(painter: _HillPainter()),
        ),
        _moci(t),
        _title(t),
        _tagline(tagText, t),
        _dots(t),
      ],
    );
  }

  Widget _cloud(_Cloud c, double t) {
    final seconds = still ? 0.0 : t / 1000;
    final phase = (((seconds - c.delay) / c.seconds) % 1 + 1) % 1;
    final x = spec.cloudFrom + (spec.cloudTo - spec.cloudFrom) * phase;
    return Positioned(
      left: x,
      top: c.top,
      width: c.width,
      height: c.width * 90 / 160,
      child: const Opacity(
        opacity: .95,
        child: CustomPaint(painter: _CloudPainter()),
      ),
    );
  }

  Widget _moci(double t) {
    final s = spec;
    final y = _kf(t, [
      (0, -s.fall),
      (SplashTimeline.dropEnd, 0),
      (SplashTimeline.bounceTop, -s.bounce),
      (SplashTimeline.settle, 0),
    ]);
    final sx = _kf(t, [
      (0, 1),
      (SplashTimeline.dropEnd, 1.08),
      (SplashTimeline.bounceTop, .97),
      (SplashTimeline.settle, 1),
    ]);
    final sy = _kf(t, [
      (0, 1),
      (SplashTimeline.dropEnd, .9),
      (SplashTimeline.bounceTop, 1.04),
      (SplashTimeline.settle, 1),
    ]);
    final swayPhase = still
        ? 0.0
        : (t % SplashTimeline.bobPeriod) / SplashTimeline.bobPeriod;
    final sway = -s.sway * (0.5 - 0.5 * math.cos(2 * math.pi * swayPhase));
    return Positioned(
      left: s.mociLeft,
      top: s.mociTop,
      width: s.mociSize,
      height: s.mociSize,
      child: Transform.translate(
        offset: Offset(0, y),
        child: Transform.scale(
          scaleX: sx,
          scaleY: sy,
          alignment: Alignment.bottomCenter,
          child: Transform.translate(
            offset: Offset(0, sway),
            child: MociMascot(pose: MociPose.senang, size: s.mociSize),
          ),
        ),
      ),
    );
  }

  Widget _title(double t) {
    final s = spec;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _letters.length; i++) ...[
          if (i > 0) SizedBox(width: s.letterGap),
          _letter(i, t),
        ],
      ],
    );
    if (s.titleLeft == null) {
      return Positioned(
        left: 0,
        right: 0,
        top: s.titleTop,
        child: Center(child: row),
      );
    }
    return Positioned(left: s.titleLeft, top: s.titleTop, child: row);
  }

  Widget _letter(int i, double t) {
    final s = spec;
    final (char, color) = _letters[i];
    final start = SplashTimeline.letterStart + i * SplashTimeline.letterStagger;
    final scale = _kf(t, [
      (start, 0),
      (start + SplashTimeline.letterPeak, 1.22),
      (start + SplashTimeline.letterUnder, .95),
      (start + SplashTimeline.letterEnd, 1),
    ]);
    final opacity = _kf(t, [
      (start, 0),
      (start + SplashTimeline.letterPeak, 1),
    ]);
    final o = s.outline, d = s.outlineDiag;
    Shadow w(double dx, double dy) =>
        Shadow(color: _white, offset: Offset(dx, dy));
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Text(
          char,
          key: ValueKey('splash-letter-$char'),
          style: MociText.title.copyWith(
            fontSize: s.letterSize,
            height: 1.1,
            letterSpacing: s.letterSpacing,
            color: color,
            shadows: [
              w(o, 0),
              w(-o, 0),
              w(0, o),
              w(0, -o),
              w(d, d),
              w(-d, d),
              w(d, -d),
              w(-d, -d),
              Shadow(color: _shadowInk, offset: Offset(0, s.letterShadow)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagline(String text, double t) {
    final s = spec;
    final f = _kf(t, [
      (SplashTimeline.tagStart, 0),
      (SplashTimeline.tagEnd, 1),
    ]);
    final pill = Opacity(
      opacity: f,
      child: Transform.translate(
        offset: Offset(0, s.rise * (1 - f)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1F2B2350), // rgba(43,35,80,.12)
                offset: Offset(0, s.pillShadow),
              ),
            ],
          ),
          child: Padding(
            padding: s.pillPad,
            child: Text(
              text,
              style: MociText.label.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: s.pillFont,
                color: _pillInk,
              ),
            ),
          ),
        ),
      ),
    );
    if (s.pillLeft == null) {
      return Positioned(
        left: 0,
        right: 0,
        top: s.pillTop,
        child: Center(child: pill),
      );
    }
    return Positioned(left: s.pillLeft, top: s.pillTop, child: pill);
  }

  Widget _dots(double t) {
    final s = spec;
    return Positioned(
      left: 0,
      right: 0,
      top: s.dotsTop,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(width: s.dotGap),
            _dot(i, t),
          ],
        ],
      ),
    );
  }

  Widget _dot(int i, double t) {
    final s = spec;
    final local = still ? 0.0 : t - i * SplashTimeline.dotStagger;
    final p = local <= 0
        ? 0.0
        : (local % SplashTimeline.dotPeriod) / SplashTimeline.dotPeriod;
    // 0, 60%, 100%: diam; 30%: naik dan terang.
    final up = p < .3
        ? Curves.easeInOut.transform(p / .3)
        : p < .6
        ? 1 - Curves.easeInOut.transform((p - .3) / .3)
        : 0.0;
    return Opacity(
      opacity: .55 + .45 * up,
      child: Transform.translate(
        offset: Offset(0, -s.dotLift * up),
        child: Container(
          width: s.dotSize,
          height: s.dotSize,
          decoration: const BoxDecoration(
            color: _white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SunPainter extends CustomPainter {
  const _SunPainter({required this.angle});

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 230;
    canvas.save();
    canvas.scale(k);
    canvas.save();
    canvas.translate(115, 115);
    canvas.rotate(angle);
    canvas.translate(-115, -115);
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
    canvas.restore();
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SunPainter old) => old.angle != angle;
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
    canvas.scale(size.width / 1180, size.height / 300);
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
