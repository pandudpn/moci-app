import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/moci_illustration.dart';

const _white = Color(0xFFFFFFFF);

/// Gelombang segitiga halus 0..1..0 dengan ease-in-out, seperti keyframes
/// `0%,100% -> 50%` di prototipe.
double hebatWave(Duration elapsed, int periodMs) {
  final p = (elapsed.inMicroseconds / 1000 % periodMs) / periodMs;
  return Curves.easeInOut.transform(p < .5 ? p * 2 : (1 - p) * 2);
}

/// Membangun ulang tiap frame dari [elapsed] (jam hiasan layar Hebat).
class HebatLoop extends StatelessWidget {
  const HebatLoop({super.key, required this.elapsed, required this.builder});

  final ValueListenable<Duration> elapsed;
  final Widget Function(BuildContext context, Duration elapsed) builder;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Duration>(
    valueListenable: elapsed,
    builder: (context, value, _) => builder(context, value),
  );
}

Path _starPath(Size size) {
  const pts = [
    (20.0, 3.0),
    (25.2, 13.6),
    (36.9, 15.3),
    (28.4, 23.5),
    (30.4, 35.1),
    (20.0, 29.6),
    (9.6, 35.1),
    (11.6, 23.5),
    (3.1, 15.3),
    (14.8, 13.6),
  ];
  final k = size.width / 40;
  final path = Path()..moveTo(pts[0].$1 * k, pts[0].$2 * k);
  for (final p in pts.skip(1)) {
    path.lineTo(p.$1 * k, p.$2 * k);
  }
  return path..close();
}

/// Bintang emas prototipe (kanvas 40 x 40) berukuran [size].
class HebatStarIcon extends StatelessWidget {
  const HebatStarIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _StarPainter());
}

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);
    canvas.drawPath(path, Paint()..color = MociColors.starFill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = MociColors.starStroke
        ..strokeWidth = 2 * size.width / 40
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

/// Sinar matahari berputar 70 detik per putaran dan konfeti jatuh. Dengan
/// [elapsed] `null` (gerak dikurangi) sinar diam dan konfeti tidak digambar.
class HebatBackdrop extends StatelessWidget {
  const HebatBackdrop({super.key, this.elapsed});

  final ValueListenable<Duration>? elapsed;

  @override
  Widget build(BuildContext context) {
    final e = elapsed;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(1180, 820),
          painter: _BackdropPainter(e),
        ),
      ),
    );
  }
}

/// (kiri, lebar, tinggi, warna, durasi detik, tunda detik) dari prototipe.
typedef _Confetti = (double, double, double, int, double, double);

const List<_Confetti> _confetti = [
  (40, 14, 22, 0xFFFF5C8A, 5.2, -1),
  (110, 16, 16, 0xFF3BA4FF, 6.4, -3),
  (170, 12, 24, 0xFF26A03B, 5.8, -4.6),
  (236, 18, 12, 0xFF9775FA, 7, -2.2),
  (300, 14, 14, 0xFFFF922B, 5.5, -.4),
  (358, 12, 22, 0xFFE8384F, 6.8, -5.2),
  (420, 16, 16, 0xFF22C1C3, 5.9, -2.8),
  (480, 14, 24, 0xFFFF5C8A, 7.4, -6.1),
  (540, 18, 12, 0xFF3BA4FF, 5.4, -1.7),
  (602, 14, 14, 0xFF26A03B, 6.2, -4),
  (660, 12, 22, 0xFF9775FA, 5.6, -3.4),
  (720, 16, 16, 0xFFFF922B, 7.2, -.9),
  (784, 14, 24, 0xFFE8384F, 6, -5.6),
  (846, 18, 12, 0xFF22C1C3, 5.3, -2.5),
  (906, 14, 14, 0xFFFF5C8A, 6.6, -4.3),
  (966, 12, 22, 0xFF3BA4FF, 5.7, -1.2),
  (1030, 16, 16, 0xFF26A03B, 7.1, -6.4),
  (1090, 14, 24, 0xFF9775FA, 6.1, -3.9),
  (1140, 18, 12, 0xFFFF922B, 5.5, -.2),
  (80, 12, 12, 0xFFFFFFFF, 6.9, -5),
  (640, 12, 12, 0xFFFFFFFF, 6.3, -2),
  (1000, 12, 12, 0xFFFFFFFF, 7.3, -4.8),
];

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.elapsed) : super(repaint: elapsed);

  final ValueListenable<Duration>? elapsed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = (elapsed?.value ?? Duration.zero).inMicroseconds / 1e6;

    // Sinar: 16 segitiga dari pusat (590, 410), satu putaran per 70 detik.
    canvas.save();
    canvas.translate(590, 410);
    canvas.rotate(t / 70 * 2 * math.pi);
    final ray = Path()
      ..moveTo(0, 0)
      ..lineTo(1000, -98)
      ..lineTo(1000, 98)
      ..close();
    final paint = Paint()..color = MociColors.mociYellow;
    for (var i = 0; i < 16; i++) {
      canvas.drawPath(ray, paint);
      canvas.rotate(math.pi / 8);
    }
    canvas.restore();

    if (elapsed == null) return;
    for (final (left, w, h, color, dur, delay) in _confetti) {
      final x = (t - delay) / dur;
      final p = x - x.floorToDouble();
      final y = -100 + 960 * p;
      canvas.save();
      canvas.translate(left + w / 2, y + h / 2);
      canvas.rotate(p * 4 * math.pi);
      final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(w == h ? w / 2 : 4)),
        Paint()..color = Color(color),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.elapsed != elapsed;
}

/// Pita judul "HEBAT!" (kanvas 520 x 110) dengan teks putih di atasnya.
class HebatRibbon extends StatelessWidget {
  const HebatRibbon({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      height: 110,
      child: Stack(
        children: [
          const CustomPaint(size: Size(520, 110), painter: _RibbonPainter()),
          Positioned(
            left: 40,
            right: 40,
            top: 14,
            height: 76,
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                style: MociText.title.copyWith(
                  fontSize: 52,
                  letterSpacing: 3,
                  color: _white,
                  shadows: const [
                    Shadow(color: Color(0xFFC2255C), offset: Offset(0, 3)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Path poly(List<(double, double)> pts) {
      final p = Path()..moveTo(pts.first.$1, pts.first.$2);
      for (final q in pts.skip(1)) {
        p.lineTo(q.$1, q.$2);
      }
      return p..close();
    }

    void fill(Path p, int color) =>
        canvas.drawPath(p, Paint()..color = Color(color));

    // Ekor kiri dan kanan, badan pita, lalu lipatan bawah.
    fill(poly([(0, 34), (70, 34), (70, 104), (0, 104), (22, 69)]), 0xFFC2255C);
    fill(
      poly([(520, 34), (450, 34), (450, 104), (520, 104), (498, 69)]),
      0xFFC2255C,
    );
    fill(poly([(40, 14), (480, 14), (480, 90), (40, 90)]), 0xFFF03E7C);
    fill(poly([(40, 90), (70, 104), (70, 90)]), 0xFF8F1D47);
    fill(poly([(480, 90), (450, 104), (450, 90)]), 0xFF8F1D47);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => false;
}

/// Ikon garis (kanvas 24 x 24) untuk gelembung dan tombol.
enum HebatGlyph { speaker, replay, arrow }

class HebatGlyphIcon extends StatelessWidget {
  const HebatGlyphIcon(this.glyph, {super.key, required this.size, this.color});

  final HebatGlyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(glyph, color ?? MociColors.ink),
    ),
  );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.glyph, this.color);

  final HebatGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    Paint line(double w) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (glyph) {
      case HebatGlyph.speaker:
        const red = MociColors.wrong;
        final body = Path()
          ..moveTo(4, 9.5)
          ..lineTo(7.5, 9.5)
          ..lineTo(12, 5.5)
          ..lineTo(12, 18.5)
          ..lineTo(7.5, 14.5)
          ..lineTo(4, 14.5)
          ..close();
        canvas
          ..drawPath(body, Paint()..color = red)
          ..drawPath(body, line(2.4)..color = red)
          ..drawPath(
            Path()
              ..moveTo(15.5, 9)
              ..arcToPoint(
                const Offset(15.5, 15),
                radius: const Radius.circular(4),
              ),
            line(2.4)..color = red,
          )
          ..drawPath(
            Path()
              ..moveTo(18.5, 6.5)
              ..arcToPoint(
                const Offset(18.5, 17.5),
                radius: const Radius.circular(7.5),
              ),
            line(2.4)..color = red,
          );
      case HebatGlyph.replay:
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
            line(2.6),
          )
          ..drawPath(
            Path()
              ..moveTo(4, 4)
              ..lineTo(4, 9)
              ..lineTo(9, 9),
            line(2.6),
          );
      case HebatGlyph.arrow:
        canvas
          ..drawPath(
            Path()
              ..moveTo(5, 12)
              ..lineTo(18, 12),
            line(3),
          )
          ..drawPath(
            Path()
              ..moveTo(13, 6)
              ..lineTo(19, 12)
              ..lineTo(13, 18),
            line(3),
          );
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}

/// Lingkaran putus-putus untuk sel album yang masih kosong.
class _DashedCircle extends StatelessWidget {
  const _DashedCircle();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(size: Size.square(60), painter: _DashedCirclePainter());
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.0;
    final r = (size.width - stroke) / 2;
    final circumference = 2 * math.pi * r;
    const dash = 6.0;
    final count = (circumference / (dash * 2)).round();
    final sweep = 2 * math.pi / count;
    final paint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => false;
}

/// Kartu ungu "Album stiker": hitungan, bilah kemajuan, dan enam sel stiker
/// terakhir. Sel [newId] diberi cincin kuning, label [newTag], dan denyut.
class HebatAlbum extends StatelessWidget {
  const HebatAlbum({
    super.key,
    required this.title,
    required this.owned,
    required this.total,
    required this.recent,
    required this.newTag,
    required this.elapsed,
    this.newId,
  });

  static const cells = 6;

  final String title;
  final int owned;
  final int total;

  /// Stiker terakhir yang dimiliki, paling lama ke paling baru (maksimal enam).
  final List<String> recent;
  final String? newId;
  final String newTag;

  /// `null` = gerak dikurangi: tanpa denyut.
  final ValueListenable<Duration>? elapsed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF7048E8),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          // Daftar bayangan Flutter dilukis dari depan ke belakang: yang lembut dulu.
          BoxShadow(
            color: Color(0x332B2350),
            offset: Offset(0, 20),
            blurRadius: 34,
          ),
          BoxShadow(color: Color(0xFF5032B8), offset: Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: MociText.label.copyWith(
                fontSize: 16,
                letterSpacing: .6,
                color: _white,
              ),
            ),
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                text: '$owned',
                children: [
                  TextSpan(
                    text: ' / $total',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              style: MociText.title.copyWith(
                fontSize: 38,
                height: 1,
                color: _white,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: ColoredBox(
                color: const Color(0x47FFFFFF),
                child: SizedBox(
                  height: 14,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: total == 0 ? 0 : owned / total,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MociColors.mociYellow,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const SizedBox(height: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(width: 208, height: 134, child: _grid()),
          ],
        ),
      ),
    );
  }

  Widget _grid() {
    Offset at(int i) => Offset((i % 3) * 74.0, (i ~/ 3) * 74.0);
    Widget? tag;
    final children = <Widget>[];
    for (var i = 0; i < cells; i++) {
      final id = i < recent.length ? recent[i] : null;
      final isNew = id != null && id == newId;
      final o = at(i);
      children.add(
        Positioned(
          left: o.dx,
          top: o.dy,
          width: 60,
          height: 60,
          child: id == null
              ? const _DashedCircle()
              : isNew
              ? _pulse(_cell(id, ring: true))
              : _cell(id),
        ),
      );
      if (isNew) {
        // Label di atas semua sel (di prototipe elemen berposisi).
        tag = Positioned(
          right: 208 - (o.dx + 60 + 16),
          top: o.dy - 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFC2255C),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                newTag,
                style: MociText.label.copyWith(
                  fontSize: 12,
                  letterSpacing: .4,
                  color: _white,
                ),
              ),
            ),
          ),
        );
      }
    }
    if (tag != null) children.add(tag);
    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _pulse(Widget child) {
    final e = elapsed;
    if (e == null) return child;
    return HebatLoop(
      elapsed: e,
      builder: (context, d) =>
          Transform.scale(scale: 1 + .12 * hebatWave(d, 1800), child: child),
    );
  }

  Widget _cell(String id, {bool ring = false}) => DecoratedBox(
    decoration: BoxDecoration(
      color: _white,
      shape: BoxShape.circle,
      boxShadow: [
        if (ring)
          const BoxShadow(color: MociColors.mociYellow, spreadRadius: 4),
      ],
    ),
    child: Center(child: MociIllustration(id, size: ring ? 46 : 48)),
  );
}
