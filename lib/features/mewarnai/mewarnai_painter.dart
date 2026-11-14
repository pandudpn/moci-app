import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../core/content/coloring.dart';
import 'mewarnai_model.dart';
import 'svg_path.dart';

/// Warna garis halaman.
const _tinta = Color(0xFF2B2350);

/// Tebal garis luar bagian.
const _tebalGaris = 6.0;

const _putih = Color(0xFFFFFFFF);

/// Gambar halaman mewarnai yang tidak bisa disentuh, dipakai Galeri dan
/// pratinjau karya.
class ColoringView extends StatelessWidget {
  const ColoringView({
    super.key,
    required this.halaman,
    required this.data,
    this.cap = const {},
    this.width = 800,
    this.height = 600,
    this.radius = 0,
  });

  final ColoringPage halaman;
  final KaryaData data;
  final Map<String, PictureInfo> cap;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          size: Size(width, height),
          painter: ColoringPainter(
            halaman: halaman,
            data: data,
            cap: cap,
            skala: width / kanvasHalaman.width,
          ),
        ),
      ),
    );
  }
}

/// Menggambar satu halaman: isian, coretan yang dipotong per bagian, garis
/// luar, detail, lalu stiker.
///
/// Dipakai dua kali dengan kode yang sama: `CustomPaint` di layar dan
/// `PictureRecorder` saat mengekspor PNG, supaya keduanya tidak mungkin beda.
class ColoringPainter extends CustomPainter {
  ColoringPainter({
    required this.halaman,
    required this.data,
    required this.cap,
    required this.skala,
    this.goresanAktif = const [],
    this.bagianAktif,
    this.warnaAktif = '#FFFFFF',
    this.lebarAktif = 26,
    super.repaint,
  });

  final ColoringPage halaman;
  final KaryaData data;
  final Map<String, PictureInfo> cap;
  final double skala;
  final List<Offset> goresanAktif;
  final int? bagianAktif;
  final String warnaAktif;
  final double lebarAktif;

  /// Jalur yang sudah di-parse; kunci [Coretan] memakai identitas.
  final Map<int, Path> _jalurBagian = {};
  final Map<String, Path> _jalurDetail = {};
  final Map<Coretan, Path> _jalurCoretan = {};

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(skala);
    final isi = Paint()..isAntiAlias = true;
    canvas.drawRect(Offset.zero & kanvasHalaman, isi..color = _putih);
    final kuas = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    for (var i = 0; i < halaman.bagian.length; i++) {
      final bagian = halaman.bagian[i];
      final jalur = _jalurBagian.putIfAbsent(i, () {
        final path = svgPath(bagian.d);
        path.fillType = bagian.evenOdd
            ? PathFillType.evenOdd
            : PathFillType.nonZero;
        return path;
      });
      canvas.drawPath(
        jalur,
        isi..color = warnaDariHex(data.isian[i] ?? '#FFFFFF'),
      );
      canvas.save();
      canvas.clipPath(jalur);
      for (final coretan in data.coretan[i] ?? const <Coretan>[]) {
        canvas.drawPath(
          _jalurCoretan.putIfAbsent(coretan, () => svgPath(coretan.d)),
          kuas
            ..strokeWidth = coretan.lebar
            ..color = warnaDariHex(coretan.warna),
        );
      }
      if (bagianAktif == i) {
        final aktif = _jalurGoresan();
        if (aktif != null) {
          canvas.drawPath(
            aktif,
            kuas
              ..strokeWidth = lebarAktif
              ..color = warnaDariHex(warnaAktif),
          );
        }
      }
      canvas.restore();
      canvas.drawPath(
        jalur,
        kuas
          ..strokeWidth = _tebalGaris
          ..color = _tinta,
      );
      for (final detail in bagian.detail) {
        canvas.drawPath(
          _jalurDetail.putIfAbsent(detail.d, () => svgPath(detail.d)),
          kuas
            ..strokeWidth = detail.w
            ..color = detail.fill.isEmpty ? _tinta : warnaDariHex(detail.fill),
        );
      }
    }
    _gambarCap(canvas);
    canvas.restore();
  }

  Path? _jalurGoresan() {
    if (goresanAktif.isEmpty) return null;
    final path = Path()..moveTo(goresanAktif.first.dx, goresanAktif.first.dy);
    for (var i = 1; i < goresanAktif.length; i++) {
      path.lineTo(goresanAktif[i].dx, goresanAktif[i].dy);
    }
    return path;
  }

  void _gambarCap(Canvas canvas) {
    for (final tempel in data.cap) {
      final info = cap[tempel.cap];
      if (info == null) continue;
      canvas.save();
      canvas.translate(tempel.x - ukuranCap / 2, tempel.y - ukuranCap / 2);
      canvas.scale(ukuranCap / info.size.width);
      canvas.drawPicture(info.picture);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ColoringPainter old) =>
      old.data != data ||
      old.skala != skala ||
      old.goresanAktif.length != goresanAktif.length ||
      old.bagianAktif != bagianAktif ||
      old.warnaAktif != warnaAktif ||
      old.lebarAktif != lebarAktif ||
      old.cap != cap ||
      old.halaman != halaman;
}

/// Mengekspor halaman menjadi PNG 300 × 225 untuk pratinjau Karyaku.
Future<Uint8List> renderKaryaPng({
  required ColoringPage halaman,
  required KaryaData data,
  Map<String, PictureInfo> cap = const {},
  int lebar = 300,
  int tinggi = 225,
}) async {
  final recorder = PictureRecorder();
  ColoringPainter(
    halaman: halaman,
    data: data,
    cap: cap,
    skala: lebar / kanvasHalaman.width,
  ).paint(Canvas(recorder), Size(lebar.toDouble(), tinggi.toDouble()));
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(lebar, tinggi);
    try {
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      return bytes!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}
