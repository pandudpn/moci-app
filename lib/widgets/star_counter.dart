import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layout/moci_stage.dart';
import '../app/theme/moci_colors.dart';
import '../app/theme/moci_metrics.dart';
import '../app/theme/moci_text.dart';
import '../core/progress/progress_controller.dart';

/// Pil putih berisi bintang dan jumlah bintang yang sudah dikumpulkan.
class StarCounter extends ConsumerWidget {
  const StarCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(progressProvider.select((p) => p.stars));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(MociSize.topPillHeight / 2),
        boxShadow: [
          BoxShadow(
            color:
                MenuThemeScope.maybeOf(context)?.shadow ??
                MociColors.neutralShadow,
            offset: const Offset(0, MociSize.topShadow),
            blurRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        height: MociSize.topPillHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomPaint(size: Size(38, 38), painter: _StarPainter()),
              const SizedBox(width: 10),
              Text('$stars', style: MociText.title.copyWith(fontSize: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Path bintang prototipe (viewBox 40 x 40) diskalakan ke [size].
@visibleForTesting
Path starPath(Size size) {
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

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = starPath(size);
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
