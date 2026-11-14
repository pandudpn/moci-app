import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/moci_illustration.dart';
import '../ringkasan.dart';
import 'ot_card.dart';

/// Nama modul di baris perkembangan dan saran (sama dengan judul menu).
String modulName(AppLocalizations l10n, RingkasanModul m) => switch (m) {
  RingkasanModul.huruf => l10n.menuHurufTitle,
  RingkasanModul.angka => l10n.menuAngkaTitle,
  RingkasanModul.hewan => l10n.menuHewanTitle,
  RingkasanModul.buahSayur => l10n.menuBuahTitle,
  RingkasanModul.membaca => l10n.menuBacaTitle,
  RingkasanModul.mewarnai => l10n.menuWarnaiTitle,
};

/// Warna ikon, bayangan ikon, dan bilah per modul (prototipe).
const _style = {
  RingkasanModul.huruf: (
    Color(0xFFFF6B6B),
    Color(0xFFE04848),
    Color(0xFFE8384F),
  ),
  RingkasanModul.angka: (
    Color(0xFF4DA8FF),
    Color(0xFF2A84E0),
    Color(0xFF1C7ED6),
  ),
  RingkasanModul.hewan: (
    Color(0xFF5FD068),
    Color(0xFF3BAA45),
    Color(0xFF2F9E44),
  ),
  RingkasanModul.buahSayur: (
    Color(0xFFFF7EB6),
    Color(0xFFE0528F),
    Color(0xFFD6336C),
  ),
  RingkasanModul.membaca: (
    Color(0xFFFF8A3D),
    Color(0xFFE0661A),
    Color(0xFFE8590C),
  ),
  RingkasanModul.mewarnai: (
    Color(0xFFFFC233),
    Color(0xFFE0A100),
    Color(0xFFF08C00),
  ),
};

const _glyph = {RingkasanModul.huruf: 'Aa', RingkasanModul.angka: '12'};

const _illustration = {
  RingkasanModul.hewan: 'kucing',
  RingkasanModul.buahSayur: 'apel',
  RingkasanModul.membaca: 'buku',
  RingkasanModul.mewarnai: 'karyaku',
};

/// Perkembangan 7 hari terakhir per modul dan saran modul berikutnya.
class MingguIniCard extends StatelessWidget {
  const MingguIniCard({super.key, required this.rows});

  final List<WeeklyRow> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final suggestion = modulName(l10n, pickSuggestion(rows));
    return OtCard(
      label: l10n.orangTuaProgress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orangTuaProgress, style: otHeading()),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  l10n.orangTuaWeek,
                  textAlign: TextAlign.end,
                  style: otLabel(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _Row(row: rows[i], name: modulName(l10n, rows[i].modul)),
          ],
          const SizedBox(height: 16),
          _Tip(text: l10n.orangTuaTip(suggestion)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.row, required this.name});

  final WeeklyRow row;
  final String name;

  @override
  Widget build(BuildContext context) {
    final (bg, shadow, bar) = _style[row.modul]!;
    final glyph = _glyph[row.modul];
    final count = '${row.done}/${row.modul.total}';
    return Semantics(
      container: true,
      label: '$name $count',
      excludeSemantics: true,
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: shadow, offset: const Offset(0, 4)),
                ],
              ),
              child: SizedBox.square(
                dimension: 52,
                child: Center(
                  child: glyph != null
                      ? Text(
                          glyph,
                          style: MociText.title.copyWith(
                            fontSize: 22,
                            color: MociColors.white,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: MociIllustration(
                            _illustration[row.modul]!,
                            size: 42,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MociText.button.copyWith(fontSize: 19),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        count,
                        maxLines: 1,
                        style: MociText.title.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 12,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: ColoredBox(color: otTrack),
                          ),
                          FractionallySizedBox(
                            widthFactor: row.ratio.clamp(0.0, 1.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: bar,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExcludeSemantics(
              child: CustomPaint(
                size: Size.square(26),
                painter: _BulbPainter(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: MociText.label.copyWith(
                  fontSize: 15,
                  height: 1.35,
                  color: const Color(0xFF5C4200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulbPainter extends CustomPainter {
  const _BulbPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFB36B00)
      ..strokeWidth = 2.2 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final bulb = Path()
      ..moveTo(12 * k, 3 * k)
      ..cubicTo(8.7 * k, 3 * k, 6 * k, 5.7 * k, 6 * k, 9 * k)
      ..cubicTo(6 * k, 11.2 * k, 7.2 * k, 13.1 * k, 8.4 * k, 13.8 * k)
      ..cubicTo(9 * k, 14.3 * k, 9.4 * k, 15 * k, 9.4 * k, 15.8 * k)
      ..lineTo(9.4 * k, 16 * k)
      ..lineTo(14.6 * k, 16 * k)
      ..lineTo(14.6 * k, 15.8 * k)
      ..cubicTo(14.6 * k, 15 * k, 15 * k, 14.3 * k, 15.6 * k, 13.8 * k)
      ..cubicTo(16.8 * k, 13.1 * k, 18 * k, 11.2 * k, 18 * k, 9 * k)
      ..cubicTo(18 * k, 5.7 * k, 15.3 * k, 3 * k, 12 * k, 3 * k)
      ..close();
    canvas.drawPath(bulb, Paint()..color = const Color(0xFFFFE066));
    canvas.drawPath(bulb, stroke);
    canvas.drawLine(Offset(9 * k, 18 * k), Offset(15 * k, 18 * k), stroke);
    canvas.drawLine(Offset(10 * k, 21 * k), Offset(14 * k, 21 * k), stroke);
  }

  @override
  bool shouldRepaint(_BulbPainter old) => false;
}
