import 'package:flutter/widgets.dart';

import '../../app/theme/moci_colors.dart';
import '../pressable.dart';
import 'game_glyphs.dart';

enum MicPhase { idle, listening, good, off }

/// Tombol mikrofon 180 pt. Saat mendengar, dua cincin berdenyut di belakang;
/// saat berhasil, centang putih di latar hijau.
class MicButton extends StatelessWidget {
  const MicButton({
    super.key,
    required this.phase,
    required this.onTap,
    required this.semanticLabel,
    this.size = 180,
  });

  static const ringsKey = ValueKey('mic-rings');

  final MicPhase phase;
  final VoidCallback? onTap;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final good = phase == MicPhase.good;
    final off = phase == MicPhase.off;
    final background = off
        ? const Color(0xFFB9B3CC)
        : good
        ? MociColors.correct
        : const Color(0xFFF03E7C);
    final shadow = off
        ? const Color(0xFF8E88A8)
        : good
        ? MociColors.correctShadow
        : const Color(0xFFC2255C);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (phase == MicPhase.listening) _MicRings(size: size),
          MociPressable(
            onTap: off ? null : onTap,
            color: background,
            shadowColor: shadow,
            depth: 12,
            borderRadius: BorderRadius.all(Radius.circular(size / 2)),
            semanticLabel: semanticLabel,
            minTouch: size,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: GameGlyph(
                  good ? GameGlyphKind.check : GameGlyphKind.mic,
                  size: size * 0.48,
                  color: MociColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dua cincin yang membesar lalu memudar bergantian.
final class _MicRings extends StatefulWidget {
  const _MicRings({required this.size});

  final double size;

  @override
  State<_MicRings> createState() => _MicRingsState();
}

final class _MicRingsState extends State<_MicRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            for (var i = 0; i < 2; i++)
              Positioned.fill(
                child: Center(child: _ring(i, still: still)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _ring(int i, {required bool still}) {
    final t = still ? 0.3 + i * 0.3 : (_pulse.value + i * 0.5) % 1;
    return Transform.scale(
      scale: 1 + t * 0.35,
      child: Opacity(
        opacity: (1 - t) * 0.35,
        child: DecoratedBox(
          key: MicButton.ringsKey,
          decoration: const BoxDecoration(
            color: Color(0xFFF03E7C),
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: widget.size, height: widget.size),
        ),
      ),
    );
  }
}
