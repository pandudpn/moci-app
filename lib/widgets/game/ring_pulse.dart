import 'package:flutter/widgets.dart';

/// Cincin berdenyut di belakang tombol bulat; diam saat gerak dikurangi.
class RingPulse extends StatefulWidget {
  const RingPulse({
    super.key,
    required this.size,
    required this.color,
    required this.child,
  });

  final double size;
  final Color color;
  final Widget child;

  @override
  State<RingPulse> createState() => _RingPulseState();
}

class _RingPulseState extends State<RingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
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

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (!reduced)
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => IgnorePointer(
              child: Transform.scale(
                scale: 1 + 0.75 * _c.value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.5 * (1 - _c.value)),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: widget.size, height: widget.size),
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}
