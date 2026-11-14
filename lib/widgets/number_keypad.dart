import 'package:flutter/widgets.dart';

import '../app/theme/moci_text.dart';
import '../l10n/l10n.dart';
import 'pressable.dart';

const _keyColor = Color(0xFFF4F1FA);
const _keyShadow = Color(0xFFDCD5EE);
const _delColor = Color(0xFFFFE3DA);
const _delShadow = Color(0xFFF3C2B3);
const _delInk = Color(0xFFA61E33);

/// Papan angka 1–9, kosong, 0, hapus. Tombol 96 x 84 dengan jarak 14.
///
/// Orang tua mengetik cepat dan sering menekan hapus dua kali berturut-turut,
/// jadi tombolnya tanpa jeda ketuk (`cooldown: Duration.zero`).
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({
    super.key,
    required this.onDigit,
    required this.onDelete,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;

  static const keySize = Size(96, 84);
  static const gap = 14.0;

  Widget _digit(int d) => _Key(
    color: _keyColor,
    shadow: _keyShadow,
    onTap: () => onDigit(d),
    child: Text('$d', style: MociText.button.copyWith(fontSize: 40, height: 1)),
  );

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> keys) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: gap),
          keys[i],
        ],
      ],
    );
    final rows = [
      row([_digit(1), _digit(2), _digit(3)]),
      row([_digit(4), _digit(5), _digit(6)]),
      row([_digit(7), _digit(8), _digit(9)]),
      row([
        const SizedBox(width: 96, height: 84),
        _digit(0),
        _Key(
          color: _delColor,
          shadow: _delShadow,
          semanticLabel: context.l10n.gerbangDel,
          onTap: onDelete,
          child: const ExcludeSemantics(
            child: CustomPaint(size: Size(34, 34), painter: _DeletePainter()),
          ),
        ),
      ]),
    ];
    return Semantics(
      container: true,
      label: context.l10n.gerbangKeypad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: gap),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.color,
    required this.shadow,
    required this.onTap,
    required this.child,
    this.semanticLabel,
  });

  final Color color;
  final Color shadow;
  final VoidCallback onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      color: color,
      shadowColor: shadow,
      depth: 6,
      borderRadius: BorderRadius.circular(24),
      cooldown: Duration.zero,
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: SizedBox.fromSize(
        size: NumberKeypad.keySize,
        child: Center(child: child),
      ),
    );
  }
}

/// Ikon hapus `M9 5h10.5A1.5 1.5 0 0 1 21 6.5v11a1.5 1.5 0 0 1-1.5 1.5H9l-6-7z`
/// dengan silang `M12.5 9.5l5 5` `M17.5 9.5l-5 5` pada kanvas 24 x 24.
class _DeletePainter extends CustomPainter {
  const _DeletePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = _delInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final r = Radius.circular(1.5 * k);
    final body = Path()
      ..moveTo(9 * k, 5 * k)
      ..lineTo(19.5 * k, 5 * k)
      ..arcToPoint(Offset(21 * k, 6.5 * k), radius: r)
      ..lineTo(21 * k, 17.5 * k)
      ..arcToPoint(Offset(19.5 * k, 19 * k), radius: r)
      ..lineTo(9 * k, 19 * k)
      ..lineTo(3 * k, 12 * k)
      ..close();
    canvas.drawPath(body, paint);
    canvas.drawLine(
      Offset(12.5 * k, 9.5 * k),
      Offset(17.5 * k, 14.5 * k),
      paint,
    );
    canvas.drawLine(
      Offset(17.5 * k, 9.5 * k),
      Offset(12.5 * k, 14.5 * k),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DeletePainter old) => false;
}
