import 'package:flutter/widgets.dart';

import '../../app/theme/moci_colors.dart';

/// Titik kemajuan: yang sudah lewat hijau, yang aktif lebih lebar.
class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.count,
    required this.current,
    required this.semanticLabel,
    this.dotSize = 12,
    this.activeWidth = 30,
    this.activeColor = MociColors.ink,
  });

  static ValueKey<String> dotKey(int i) => ValueKey('progress-dot-$i');

  final int count;

  /// Indeks 0-based; titik setelah [current] masih menunggu.
  final int current;
  final String semanticLabel;
  final double dotSize;
  final double activeWidth;
  final Color activeColor;

  static const _waiting = Color(0xFFF3C2B3);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            SizedBox(
              width: i == current ? activeWidth : dotSize,
              height: dotSize,
              child: DecoratedBox(
                key: dotKey(i),
                decoration: BoxDecoration(
                  color: i < current
                      ? MociColors.correct
                      : i == current
                      ? activeColor
                      : _waiting,
                  borderRadius: BorderRadius.circular(dotSize / 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
