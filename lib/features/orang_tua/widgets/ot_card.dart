import 'package:flutter/widgets.dart';

import '../../../app/layout/moci_stage.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';

const otShadow = Color(0xFFDCD5EE);
const otTrack = Color(0xFFF1EEF9);
const otPurple = Color(0xFF7048E8);
const otPurpleShadow = Color(0xFF5032B8);
const otSoftFill = Color(0xFFF4F1FA);

/// Area sentuh minimal dalam satuan panggung: 64 pt di tablet, 56 pt di HP,
/// dihitung dari skala panggung (HP memakai desain tablet yang diperkecil).
double otTouch(BuildContext context) {
  final scale = context.stageScale;
  return (scale >= 600 / 820 ? 64.0 : 56.0) / scale;
}

TextStyle otLabel() => MociText.label.copyWith(
  fontSize: 15,
  color: MociColors.inkSoft,
  letterSpacing: 0.3,
);

TextStyle otHeading() => MociText.title.copyWith(fontSize: 26, height: 1.2);

/// Kartu putih: bayangan padat 8 pt ditambah bayangan lembut yang menyebar.
class OtCard extends StatelessWidget {
  const OtCard({
    super.key,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final String label;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(color: otShadow, offset: Offset(0, 8)),
            BoxShadow(
              color: Color(0x142B2350),
              offset: Offset(0, 18),
              blurRadius: 30,
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          // Teks 1,3x atau layar HP: isi kartu bisa digulir, tidak meluap.
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}
