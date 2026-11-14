import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/theme/moci_colors.dart';
import '../app/theme/moci_metrics.dart';
import '../l10n/l10n.dart';
import 'pressable.dart';

/// Tujuan "pulang" saat tidak ada rute untuk di-pop.
void _goHome(BuildContext context) => context.go(Routes.beranda);

/// Tombol kembali: selalu kiri atas, ukuran dan posisi sama di semua layar.
class MociBackButton extends StatelessWidget {
  const MociBackButton({super.key, this.onTap, this.semanticLabel});

  final VoidCallback? onTap;
  final String? semanticLabel;

  void _defaultAction(BuildContext context) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      _goHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      semanticLabel: semanticLabel ?? context.l10n.commonBack,
      depth: MociSize.backShadow,
      borderRadius: BorderRadius.circular(MociSize.backRadius),
      onTap: onTap ?? () => _defaultAction(context),
      child: const SizedBox(
        width: MociSize.backButton,
        height: MociSize.backButton,
        child: Center(
          child: CustomPaint(size: Size(38, 38), painter: _ChevronPainter()),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Path asal `M15 5l-7 7 7 7` pada kanvas 24 x 24.
    final k = size.width / 24;
    final path = Path()
      ..moveTo(15 * k, 5 * k)
      ..lineTo(8 * k, 12 * k)
      ..lineTo(15 * k, 19 * k);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = MociColors.ink
        ..strokeWidth = 3 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => false;
}
