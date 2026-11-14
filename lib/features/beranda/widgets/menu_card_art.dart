import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/moci_illustration.dart';
import '../beranda_menu.dart';
import 'beranda_scenery.dart' show Sparkle;

/// Ukuran dasar gambar kartu (px artboard tablet). HP memakainya diskalakan.
const menuArtSize = Size(236, 130);

/// Gambar bagian atas kartu menu, digambar di Flutter atau dari ilustrasi.
class MenuCardArt extends StatelessWidget {
  const MenuCardArt(this.menu, {super.key});

  final BerandaMenu menu;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: menuArtSize,
        child: switch (menu) {
          BerandaMenu.huruf => const _Bob(delay: 0, child: _Letters()),
          BerandaMenu.angka => const _Bob(delay: .5, child: _Numbers()),
          BerandaMenu.hewan => const _Bob(
            delay: 1,
            child: _Pair(
              back: ('sapi', Rect.fromLTWH(104, 14, 112, 112)),
              front: ('kucing', Rect.fromLTWH(22, 10, 116, 116)),
            ),
          ),
          BerandaMenu.buah => const _Bob(
            delay: 1.5,
            child: _Pair(
              back: ('wortel', Rect.fromLTWH(112, 10, 108, 108)),
              front: ('apel', Rect.fromLTWH(26, 16, 106, 106)),
            ),
          ),
          BerandaMenu.baca => const _Bob(delay: 2, child: _Reading()),
          BerandaMenu.main => const _Games(),
          BerandaMenu.warnai => const _Coloring(),
          BerandaMenu.warna => const _Bob(delay: .8, child: _Rainbow()),
          BerandaMenu.bentuk => const _Bob(delay: 1.3, child: _Shapes()),
          BerandaMenu.musik => const _Music(),
        },
      ),
    );
  }
}

/// Mengambang naik-turun 8 px selama 3 detik. Diam bila gerak dikurangi.
class _Bob extends StatefulWidget {
  const _Bob({required this.delay, required this.child});

  /// Detik awal (bawaan prototipe memakai delay negatif).
  final double delay;
  final Widget child;

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
    value: (widget.delay / 3) % 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gerak hanya menggeser gambar: lapisan sendiri supaya sisa kartu diam.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final t = _c.value < .5 ? _c.value * 2 : (1 - _c.value) * 2;
          return Transform.translate(
            offset: Offset(0, -8 * Curves.easeInOut.transform(t)),
            child: child,
          );
        },
      ),
    );
  }
}

/// Kotak bergambar: [size] persegi, sudut [radius], bayangan padat [depth].
class _Chip extends StatelessWidget {
  const _Chip({
    required this.left,
    required this.top,
    required this.size,
    required this.color,
    required this.shadow,
    required this.radius,
    required this.text,
    required this.textColor,
    required this.fontSize,
    this.angle = 0,
  });

  final double left, top, size, radius, fontSize, angle;
  final Color color, shadow, textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: Text(
              text,
              style: MociText.title.copyWith(
                fontSize: fontSize,
                height: 1,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Letters extends StatelessWidget {
  const _Letters();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _Chip(
          left: 30,
          top: 46,
          size: 62,
          color: Color(0xFFEE3E78),
          shadow: Color(0xFFB8255A),
          radius: 18,
          text: 'A',
          textColor: MociColors.white,
          fontSize: 40,
          angle: -8,
        ),
        _Chip(
          left: 87,
          top: 24,
          size: 62,
          color: Color(0xFF1C8CF0),
          shadow: Color(0xFF1265B5),
          radius: 18,
          text: 'B',
          textColor: MociColors.white,
          fontSize: 40,
          angle: 4,
        ),
        _Chip(
          left: 144,
          top: 48,
          size: 62,
          color: Color(0xFF7048E8),
          shadow: Color(0xFF5032B8),
          radius: 18,
          text: 'C',
          textColor: MociColors.white,
          fontSize: 40,
          angle: 9,
        ),
      ],
    );
  }
}

class _Numbers extends StatelessWidget {
  const _Numbers();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _Chip(
          left: 28,
          top: 40,
          size: 62,
          color: Color(0xFFFFC233),
          shadow: Color(0xFFE0A100),
          radius: 31,
          text: '1',
          textColor: MociColors.ink,
          fontSize: 38,
        ),
        _Chip(
          left: 87,
          top: 22,
          size: 62,
          color: Color(0xFF1E8A31),
          shadow: Color(0xFF146B24),
          radius: 31,
          text: '2',
          textColor: MociColors.white,
          fontSize: 38,
        ),
        _Chip(
          left: 146,
          top: 44,
          size: 62,
          color: Color(0xFFEE3E78),
          shadow: Color(0xFFB8255A),
          radius: 31,
          text: '3',
          textColor: MociColors.white,
          fontSize: 38,
        ),
      ],
    );
  }
}

/// Dua ilustrasi bersebelahan; [back] digambar lebih dulu.
class _Pair extends StatelessWidget {
  const _Pair({required this.back, required this.front});

  final (String, Rect) back;
  final (String, Rect) front;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final (id, r) in [back, front])
          Positioned.fromRect(
            rect: r,
            child: MociIllustration(id, size: r.width),
          ),
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading();

  @override
  Widget build(BuildContext context) {
    Widget bubble(double left, double top, double size, String text, Color c) =>
        Positioned(
          left: left,
          top: top,
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: MociColors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Color(0xFFE0661A), offset: Offset(0, 5)),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: MociText.title.copyWith(
                  fontSize: 26,
                  height: 1,
                  color: c,
                ),
              ),
            ),
          ),
        );
    return Stack(
      children: [
        const Positioned(
          left: 16,
          top: 8,
          width: 118,
          height: 118,
          child: MociIllustration('buku', size: 118),
        ),
        bubble(134, 14, 54, 'ba', const Color(0xFFC2255C)),
        bubble(168, 66, 52, 'bu', const Color(0xFF1265B5)),
      ],
    );
  }
}

class _Games extends StatelessWidget {
  const _Games();

  @override
  Widget build(BuildContext context) {
    Widget card(double left, double top, double angle) => Positioned(
      left: left,
      top: top,
      width: 76,
      height: 90,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: MociColors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Color(0xFF129A9C), offset: Offset(0, 5)),
            ],
          ),
          child: Center(child: MociIllustration('nanas', size: 64)),
        ),
      ),
    );
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _DotsPainter())),
        card(22, 18, -7),
        card(140, 22, 6),
        const Positioned(
          left: 106,
          top: 88,
          child: Sparkle(size: 26, color: Color(0xFFFFE066)),
        ),
      ],
    );
  }
}

/// Garis titik `M98 64C116 30 128 98 146 62` (garis 6, putus 1/12, bulat).
class _DotsPainter extends CustomPainter {
  const _DotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(98, 64)
      ..cubicTo(116, 30, 128, 98, 146, 62);
    final paint = Paint()..color = MociColors.white;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d <= m.length; d += 13) {
        canvas.drawCircle(m.getTangentForOffset(d)!.position, 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => false;
}

class _Coloring extends StatelessWidget {
  const _Coloring();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 22,
          top: 12,
          width: 108,
          height: 108,
          child: Transform.rotate(
            angle: -5 * math.pi / 180,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                boxShadow: [
                  BoxShadow(color: Color(0xFFE0A100), offset: Offset(0, 5)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                child: MociIllustration('karyaku', size: 108),
              ),
            ),
          ),
        ),
        Positioned(
          left: 150,
          top: 16,
          width: 28,
          height: 98,
          child: Transform.rotate(
            angle: -12 * math.pi / 180,
            child: const CustomPaint(
              painter: _CrayonPainter(Color(0xFFFF4B4B), Color(0xFFB5172F)),
            ),
          ),
        ),
        Positioned(
          left: 182,
          top: 20,
          width: 28,
          height: 98,
          child: Transform.rotate(
            angle: 10 * math.pi / 180,
            child: const CustomPaint(
              painter: _CrayonPainter(Color(0xFF3BA4FF), Color(0xFF1265B5)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Krayon pada kanvas 40 x 140.
class _CrayonPainter extends CustomPainter {
  const _CrayonPainter(this.body, this.tip);

  final Color body;
  final Color tip;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 140);
    canvas.drawPath(
      Path()..addPolygon(const [
        Offset(8, 40),
        Offset(20, 4),
        Offset(32, 40),
      ], true),
      Paint()..color = body,
    );
    canvas.drawPath(
      Path()..addPolygon(const [
        Offset(15, 18),
        Offset(20, 4),
        Offset(25, 18),
      ], true),
      Paint()..color = tip,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 38, 24, 98),
        const Radius.circular(6),
      ),
      Paint()..color = body,
    );
    final band = Paint()..color = const Color(0x99FFFFFF);
    canvas.drawRect(const Rect.fromLTWH(8, 58, 24, 12), band);
    canvas.drawRect(const Rect.fromLTWH(8, 106, 24, 12), band);
  }

  @override
  bool shouldRepaint(_CrayonPainter old) => old.body != body || old.tip != tip;
}

class _Rainbow extends StatelessWidget {
  const _Rainbow();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 34,
          top: 8,
          width: 168,
          height: 116,
          child: CustomPaint(painter: _RainbowPainter()),
        ),
      ],
    );
  }
}

/// Pelangi pada kanvas 160 x 110.
class _RainbowPainter extends CustomPainter {
  const _RainbowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 160, size.height / 110);
    const arcs = [
      (60.0, Color(0xFFFF4B4B)),
      (48.0, Color(0xFFFF922B)),
      (36.0, Color(0xFFFFD43B)),
      (24.0, Color(0xFF51CF66)),
      (12.0, Color(0xFF3BA4FF)),
    ];
    for (final (r, color) in arcs) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(80, 92), radius: r),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round,
      );
    }
    final white = Paint()..color = MociColors.white;
    canvas.drawCircle(const Offset(18, 96), 12, white);
    canvas.drawCircle(const Offset(33, 99), 10, white);
    canvas.drawCircle(const Offset(142, 96), 12, white);
    canvas.drawCircle(const Offset(127, 99), 10, white);
  }

  @override
  bool shouldRepaint(_RainbowPainter old) => false;
}

class _Shapes extends StatelessWidget {
  const _Shapes();

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(size: menuArtSize, painter: _ShapesPainter());
}

/// Lingkaran, segitiga, persegi, dan bintang pada kanvas 236 x 130.
class _ShapesPainter extends CustomPainter {
  const _ShapesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      const Offset(56, 70),
      30,
      Paint()..color = const Color(0xFFFF6B6B),
    );
    final green = const Color(0xFF51CF66);
    final tri = Path()
      ..addPolygon(const [
        Offset(118, 34),
        Offset(152, 96),
        Offset(84, 96),
      ], true);
    canvas.drawPath(tri, Paint()..color = green);
    canvas.drawPath(
      tri,
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.save();
    canvas.translate(187, 71);
    canvas.rotate(-8 * math.pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-25, -25, 50, 50),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFFFD43B),
    );
    canvas.restore();
    // M118 100l4 9 10 1-7 7 2 10-9-5-9 5 2-10-7-7 10-1z, naik 6.
    const star = [
      Offset(118, 94),
      Offset(122, 103),
      Offset(132, 104),
      Offset(125, 111),
      Offset(127, 121),
      Offset(118, 116),
      Offset(109, 121),
      Offset(111, 111),
      Offset(104, 104),
      Offset(114, 103),
    ];
    canvas.drawPath(
      Path()..addPolygon(star, true),
      Paint()..color = MociColors.white,
    );
  }

  @override
  bool shouldRepaint(_ShapesPainter old) => false;
}

class _Music extends StatelessWidget {
  const _Music();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 14,
          top: 4,
          width: 126,
          height: 126,
          child: MociIllustration('xilofon', size: 126),
        ),
        Positioned(
          left: 150,
          top: 18,
          width: 38,
          height: 48,
          child: _Bob(
            delay: 0,
            child: CustomPaint(painter: _NotePainter(MociColors.white)),
          ),
        ),
        Positioned(
          left: 190,
          top: 56,
          width: 30,
          height: 38,
          child: _Bob(
            delay: 1,
            child: CustomPaint(painter: _NotePainter(Color(0xFFFFE066))),
          ),
        ),
      ],
    );
  }
}

/// Not musik pada kanvas 40 x 50.
class _NotePainter extends CustomPainter {
  const _NotePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 50);
    final fill = Paint()..color = color;
    canvas.save();
    canvas.translate(12, 40);
    canvas.rotate(-20 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 16),
      fill,
    );
    canvas.restore();
    final flag = Path()
      ..moveTo(20, 38)
      ..lineTo(20, 6)
      ..lineTo(36, 12)
      ..lineTo(36, 20)
      ..lineTo(20, 15);
    canvas.drawPath(flag, fill);
    canvas.drawPath(
      flag,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_NotePainter old) => old.color != color;
}
