import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../mewarnai_model.dart';

/// Satu krayon di palet: bentuk 38 × 88 di dalam kotak sentuh 96 tinggi.
class CrayonButton extends StatelessWidget {
  const CrayonButton({
    super.key,
    required this.hex,
    required this.nama,
    required this.onTap,
    this.selected = false,
  });

  final String hex;
  final String nama;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final krayon = Transform.translate(
      offset: selected ? const Offset(0, -10) : Offset.zero,
      child: Transform.scale(
        scale: selected ? 1.08 : 1,
        child: CustomPaint(
          size: const Size(38, 88),
          painter: _CrayonPainter(warnaDariHex(hex)),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: nama,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(height: 96, child: Center(child: krayon)),
      ),
    );
  }
}

class _CrayonPainter extends CustomPainter {
  const _CrayonPainter(this.warna);

  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    // Bentuk prototipe: viewBox 40 × 92.
    final k = size.width / 40;
    canvas.scale(k, k);
    final isi = Paint()
      ..color = warna
      ..isAntiAlias = true;
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..color = MociColors.ink
      ..isAntiAlias = true;
    final ujung = Path()
      ..moveTo(8, 30)
      ..lineTo(20, 3)
      ..lineTo(32, 30)
      ..close();
    final badan = RRect.fromLTRBR(6, 28, 34, 90, const Radius.circular(6));
    canvas
      ..drawRRect(badan, isi)
      ..drawPath(ujung, isi)
      ..drawRRect(badan, garis)
      ..drawPath(ujung, garis);
    final kilap = Paint()..color = const Color(0x8CFFFFFF);
    canvas
      ..drawRect(const Rect.fromLTWH(7.5, 44, 25, 12), kilap)
      ..drawRect(const Rect.fromLTWH(7.5, 70, 25, 7), kilap);
  }

  @override
  bool shouldRepaint(_CrayonPainter old) => old.warna != warna;
}
