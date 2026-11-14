import 'dart:math' as math;

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
            color: MenuThemeScope.of(context).shadow,
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

class _StarPainter extends CustomPainter {
  const _StarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2 - 2;
    final inner = outer * 0.5;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = MociColors.starFill);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = MociColors.starStroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}
