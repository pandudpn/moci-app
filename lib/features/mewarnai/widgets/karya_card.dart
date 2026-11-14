import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_text.dart';
import '../../../core/content/coloring.dart';
import '../../../widgets/pressable.dart';
import '../mewarnai_model.dart';
import '../mewarnai_painter.dart';

/// Warna pita kartu, bergiliran menurut urutan karya.
const _pita = [
  Color(0xFFFF8FB1),
  Color(0xFF74C0FC),
  Color(0xFF8CE99A),
  Color(0xFFFFD43B),
  Color(0xFFB197FC),
  Color(0xFFFFA94D),
];

/// Putaran kartu, juga bergiliran seperti di prototipe.
const _putaran = [-2.0, 1.5, -1.0, 2.0, -1.5, 1.0];

/// Kartu karya 330 × 290: pita kertas, pratinjau, dan nama halaman.
class KaryaCard extends StatelessWidget {
  const KaryaCard({
    super.key,
    required this.karya,
    required this.halaman,
    required this.nama,
    required this.onTap,
    this.index = 0,
    this.label,
  });

  final Karya karya;

  /// Halaman asal karya; null bila halaman sudah tidak ada di `pages.json`.
  final ColoringPage? halaman;
  final String nama;
  final VoidCallback onTap;
  final int index;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final page = halaman;
    return Transform.rotate(
      angle: _putaran[index % _putaran.length] * 3.1415926535897932 / 180,
      child: MociPressable(
        onTap: onTap,
        shadowColor: const Color(0xFFF2D27A),
        depth: 8,
        borderRadius: BorderRadius.circular(26),
        semanticLabel: label,
        child: SizedBox(
          width: 330,
          height: 290,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _pratinjau(page),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                        child: ExcludeSemantics(
                          child: Text(
                            nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: MociText.button.copyWith(fontSize: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 119,
                top: -14,
                child: Transform.rotate(
                  angle: -4 * 3.1415926535897932 / 180,
                  child: Opacity(
                    opacity: 0.85,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _pita[index % _pita.length],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const SizedBox(width: 92, height: 30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pratinjau(ColoringPage? page) {
    return SizedBox(
      width: 300,
      height: 225,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3EBD6), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: karya.png.isNotEmpty
              ? Image.memory(
                  karya.png,
                  width: 296,
                  height: 221,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, _, _) => _dariData(page),
                )
              : _dariData(page),
        ),
      ),
    );
  }

  /// Cadangan: gambar ulang dari data bila PNG kosong atau rusak, atau nama
  /// halaman bila halamannya sudah tidak ada di `pages.json`.
  Widget _dariData(ColoringPage? page) {
    if (page != null) {
      return ColoringView(
        halaman: page,
        data: karya.data,
        width: 296,
        height: 221,
        radius: 12,
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          nama,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: MociText.label.copyWith(fontSize: 20),
        ),
      ),
    );
  }
}
