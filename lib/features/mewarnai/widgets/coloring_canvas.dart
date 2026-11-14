import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../mewarnai_engine.dart';
import '../mewarnai_model.dart';
import '../mewarnai_painter.dart';

/// Kanvas sentuh 864 × 648: jari memindahkan titik ke unit halaman, painter
/// yang menggambar ulang lewat [MesinMewarnai].
class ColoringCanvas extends StatelessWidget {
  const ColoringCanvas({
    super.key,
    required this.mesin,
    required this.cap,
    this.semanticLabel,
    this.skala = skalaLayar,
  });

  final MesinMewarnai mesin;
  final Map<String, PictureInfo> cap;
  final String? semanticLabel;
  final double skala;

  static const surfaceKey = ValueKey('coloring-surface');

  @override
  Widget build(BuildContext context) {
    final hapus = mesin.alat == AlatMewarnai.hapus;
    return SizedBox(
      width: ukuranKanvasLayar.width,
      height: ukuranKanvasLayar.height,
      child: Semantics(
        label: semanticLabel,
        image: true,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) => mesin.mulai(event.localPosition / skala),
          onPointerMove: (event) => mesin.geser(event.localPosition / skala),
          onPointerUp: (event) => mesin.akhiri(),
          onPointerCancel: (event) => mesin.akhiri(),
          child: RepaintBoundary(
            key: surfaceKey,
            child: CustomPaint(
              size: ukuranKanvasLayar,
              painter: ColoringPainter(
                halaman: mesin.halaman,
                data: mesin.data,
                cap: cap,
                skala: skala,
                goresanAktif: mesin.goresanAktif,
                bagianAktif: mesin.bagianTerkunci,
                warnaAktif: hapus ? '#FFFFFF' : mesin.warna,
                lebarAktif: hapus
                    ? mesin.ukuran.lebar + tambahanLebarHapus
                    : mesin.ukuran.lebar,
                repaint: mesin,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
