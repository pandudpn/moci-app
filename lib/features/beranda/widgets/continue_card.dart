import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/pressable.dart';
import '../beranda_menu.dart';

const _cardShadow = Color(0xFF8EC5EE);

/// Kartu "Lanjutkan": kegiatan terakhir anak. Ukuran tablet 364 x 132; ukuran
/// HP 176 x 92 tanpa tombol putar.
class ContinueCard extends StatelessWidget {
  const ContinueCard({
    super.key,
    required this.menu,
    required this.heading,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  /// Menu induk kegiatan; warna dan gambarnya dipakai ubin kiri.
  final BerandaMenu menu;
  final String heading;
  final String label;
  final VoidCallback onTap;

  /// Ukuran HP.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tile = compact ? 48.0 : 86.0;
    return MociPressable(
      shadowColor: _cardShadow,
      depth: compact ? 6 : 8,
      borderRadius: BorderRadius.circular(compact ? 22 : 32),
      semanticLabel: '$heading, $label',
      onTap: onTap,
      child: SizedBox(
        width: compact ? 176 : 364,
        height: compact ? 92 : 132,
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: ExcludeSemantics(
            child: Row(
              children: [
                _Tile(menu: menu, size: tile, compact: compact),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MociText.label.copyWith(
                          fontSize: compact ? 12 : 15,
                          letterSpacing: compact ? .5 : .6,
                          color: MociColors.inkSoft,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MociText.title.copyWith(
                          fontSize: compact ? 16 : 23,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!compact) ...[const SizedBox(width: 14), const _PlayDisc()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ubin berwarna menu dengan huruf atau ilustrasi yang mewakili menunya.
class _Tile extends StatelessWidget {
  const _Tile({required this.menu, required this.size, required this.compact});

  final BerandaMenu menu;
  final double size;
  final bool compact;

  static const _glyphs = {BerandaMenu.huruf: 'A', BerandaMenu.angka: '1'};
  static const _illustrations = {
    BerandaMenu.hewan: 'sapi',
    BerandaMenu.buah: 'apel',
    BerandaMenu.baca: 'buku',
    BerandaMenu.main: 'nanas',
    BerandaMenu.warnai: 'karyaku',
    BerandaMenu.warna: 'balon',
    BerandaMenu.bentuk: 'bola',
    BerandaMenu.musik: 'xilofon',
  };

  @override
  Widget build(BuildContext context) {
    final glyph = _glyphs[menu];
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: menu.color,
          borderRadius: BorderRadius.circular(compact ? 14 : 24),
          boxShadow: [
            BoxShadow(color: menu.shadow, offset: Offset(0, compact ? 4 : 6)),
          ],
        ),
        child: Center(
          child: glyph != null
              ? Text(
                  glyph,
                  style: MociText.title.copyWith(
                    fontSize: compact ? 30 : 54,
                    height: 1,
                    color: MociColors.white,
                  ),
                )
              : MociIllustration(_illustrations[menu]!, size: size * .72),
        ),
      ),
    );
  }
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.correct,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: MociColors.correctShadow, offset: Offset(0, 5)),
        ],
      ),
      child: SizedBox.square(
        dimension: 54,
        child: Center(
          child: CustomPaint(size: Size(26, 26), painter: _PlayPainter()),
        ),
      ),
    );
  }
}

/// Segitiga putar `M8 5.5v13l10.5-6.5z` (kanvas 24), isi dan garis putih 2.
class _PlayPainter extends CustomPainter {
  const _PlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(8 * k, 5.5 * k)
      ..lineTo(8 * k, 18.5 * k)
      ..lineTo(18.5 * k, 12 * k)
      ..close();
    canvas.drawPath(path, Paint()..color = MociColors.white);
    canvas.drawPath(
      path,
      Paint()
        ..color = MociColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * k
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PlayPainter old) => false;
}
