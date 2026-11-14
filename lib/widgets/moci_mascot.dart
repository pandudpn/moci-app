import 'package:flutter/widgets.dart';

import 'moci_illustration.dart';
import 'moci_mascot_painter.dart';

enum MociPose { biasa, senang, tidur }

/// Maskot Moci. `biasa` digambar dengan CustomPainter dan tiap bagiannya
/// beranimasi; `senang` dan `tidur` adalah gambar utuh yang bergerak.
/// Dengan gerak dikurangi (disableAnimations) tidak ada animasi, tetapi
/// [onTap] tetap terpanggil.
class MociMascot extends StatefulWidget {
  const MociMascot({
    super.key,
    this.size = 184,
    this.pose = MociPose.biasa,
    this.onTap,
    this.idle = true,
  });

  final double size;
  final MociPose pose;
  final VoidCallback? onTap;
  final bool idle;

  @override
  State<MociMascot> createState() => _MociMascotState();
}

class _MociMascotState extends State<MociMascot> with TickerProviderStateMixin {
  // Ukuran gambar utuh di prototipe (px) tempat gerak senang/tidur dirancang.
  static const _happyRefSize = 250.0;
  static const _sleepRefSize = 300.0;

  late final _squish = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4400),
  );
  late final _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final _leaf = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  late final _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final _jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5000),
  );

  late final _repaint = Listenable.merge([_squish, _blink, _wave, _leaf, _hop]);

  List<AnimationController> get _all => [
    _squish,
    _blink,
    _wave,
    _leaf,
    _hop,
    _jump,
    _float,
  ];

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MociMascot old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.idle && !_reduced;
    final active = <AnimationController>[
      if (run)
        ...switch (widget.pose) {
          MociPose.biasa => [_squish, _blink, _wave, _leaf],
          MociPose.senang => [_jump],
          MociPose.tidur => [_float],
        },
    ];
    for (final c in _all) {
      if (c == _hop) continue;
      if (active.contains(c)) {
        if (!c.isAnimating) c.repeat();
      } else {
        c.stop();
      }
    }
    if (!run || widget.pose != MociPose.biasa) {
      _hop.stop();
      _hop.value = 0;
    }
  }

  void _handleTap() {
    widget.onTap?.call();
    if (widget.pose == MociPose.biasa && !_reduced) {
      _hop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _body() {
    final size = widget.size;
    switch (widget.pose) {
      case MociPose.biasa:
        return CustomPaint(
          size: Size.square(size),
          painter: MociMascotPainter(
            squish: _squish,
            blink: _blink,
            wave: _wave,
            leaf: _leaf,
            hop: _hop,
            repaint: _repaint,
          ),
        );
      case MociPose.senang:
        final k = size / _happyRefSize;
        return AnimatedBuilder(
          animation: _jump,
          child: MociIllustration('moci-senang', size: size),
          builder: (context, child) {
            final p = sampleKeyframes(mociJumpFrames, _jump.value);
            return Transform.translate(
              offset: Offset(0, p.dy * k),
              child: Transform.scale(
                scaleX: p.sx,
                scaleY: p.sy,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );
          },
        );
      case MociPose.tidur:
        final k = size / _sleepRefSize;
        return AnimatedBuilder(
          animation: _float,
          child: MociIllustration('moci-tidur', size: size),
          builder: (context, child) {
            final p = Curves.easeInOut.transform(
              _float.value < .5 ? _float.value * 2 : (1 - _float.value) * 2,
            );
            return Transform.translate(
              offset: Offset(0, -10 * k * p),
              child: child,
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final art = SizedBox.square(dimension: widget.size, child: _body());
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      // Pose `biasa` digambar ulang tiap frame, jadi ia butuh lapisan sendiri
      // supaya layar di sekitarnya tidak ikut. Pose lain hanya menggeser
      // ilustrasi diam di dalam Transform; lapisan di situ akan diraster dulu
      // lalu diskalakan ulang (tepi ilustrasi jadi kabur).
      child: widget.pose == MociPose.biasa ? RepaintBoundary(child: art) : art,
    );
  }
}
