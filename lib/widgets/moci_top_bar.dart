import 'package:flutter/widgets.dart';

import '../app/theme/moci_metrics.dart';
import '../app/theme/moci_text.dart';

/// Bilah atas: tombol kiri, judul, lalu elemen kanan. Margin tepi 32 dan
/// jarak atas 22 sudah termasuk.
class MociTopBar extends StatelessWidget {
  const MociTopBar({
    super.key,
    this.leading,
    required this.title,
    this.trailing = const [],
  });

  final Widget? leading;
  final String title;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: MociSize.edgeTablet,
        right: MociSize.edgeTablet,
        top: MociSize.topBarTop,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 18)],
          Expanded(child: Text(title, style: MociText.title, maxLines: 1)),
          for (final w in trailing) ...[const SizedBox(width: 18), w],
        ],
      ),
    );
  }
}
