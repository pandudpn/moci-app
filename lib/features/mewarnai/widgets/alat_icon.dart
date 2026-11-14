import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../mewarnai_model.dart';

/// Ikon alat dari prototipe: digambar pada kanvas 24 × 24, stiker 40 × 40.
class AlatIcon extends StatelessWidget {
  const AlatIcon(
    this.alat, {
    super.key,
    this.size = 30,
    this.warna = MociColors.ink,
  });

  final AlatMewarnai alat;

  /// Warna isi ikon, biasanya warna krayon yang sedang dipakai.
  final Color warna;

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _AlatPainter(alat, warna));
}

class _AlatPainter extends CustomPainter {
  const _AlatPainter(this.alat, this.warna);

  final AlatMewarnai alat;
  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    switch (alat) {
      case AlatMewarnai.kuas:
        _kuas(canvas, size.width / 24);
      case AlatMewarnai.isi:
        _isi(canvas, size.width / 24);
      case AlatMewarnai.hapus:
        _hapus(canvas, size.width / 24);
      case AlatMewarnai.cap:
        _bintang(canvas, size.width / 40);
    }
  }

  Paint _garis(double k, double tebal) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = tebal * k
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = MociColors.ink
    ..isAntiAlias = true;

  Paint get _cat => Paint()
    ..style = PaintingStyle.fill
    ..color = warna
    ..isAntiAlias = true;

  void _kuas(Canvas canvas, double k) {
    final kepala = Path()
      ..moveTo(18 * k, 3 * k)
      ..lineTo(21 * k, 6 * k)
      ..lineTo(11.5 * k, 15.5 * k)
      ..lineTo(8 * k, 16.5 * k)
      ..lineTo(9 * k, 13 * k)
      ..close();
    canvas
      ..drawPath(kepala, _cat)
      ..drawPath(kepala, _garis(k, 2.2));
    final gagang = Path()
      ..moveTo(7.5 * k, 16.5 * k)
      ..cubicTo(5.3 * k, 16.5 * k, 4.2 * k, 18.1 * k, 4.2 * k, 19.7 * k)
      ..cubicTo(4.2 * k, 20.6 * k, 3.3 * k, 21 * k, 2.5 * k, 21 * k)
      ..cubicTo(4.1 * k, 22.2 * k, 8.8 * k, 22.4 * k, 9.5 * k, 18.7 * k);
    canvas.drawPath(gagang, _garis(k, 2.2));
  }

  void _isi(Canvas canvas, double k) {
    final wadah = Path()
      ..moveTo(4 * k, 11 * k)
      ..lineTo(11 * k, 4 * k)
      ..lineTo(18 * k, 11 * k)
      ..lineTo(11 * k, 18 * k)
      ..close();
    canvas
      ..drawPath(wadah, _cat)
      ..drawPath(wadah, _garis(k, 2.2));
    final tetes = Path()
      ..moveTo(20 * k, 13 * k)
      ..cubicTo(20 * k, 14.6 * k, 21.2 * k, 15.6 * k, 21.2 * k, 16.7 * k)
      ..arcToPoint(
        Offset(18.8 * k, 16.7 * k),
        radius: Radius.circular(1.2 * k),
        clockwise: true,
      )
      ..cubicTo(18.8 * k, 15.6 * k, 20 * k, 14.6 * k, 20 * k, 13 * k)
      ..close();
    canvas
      ..drawPath(tetes, _cat)
      ..drawPath(tetes, _garis(k, 2.2));
  }

  void _hapus(Canvas canvas, double k) {
    final badan = Path()
      ..moveTo(3.5 * k, 15.5 * k)
      ..lineTo(12.5 * k, 6.5 * k)
      ..lineTo(19.5 * k, 13.5 * k)
      ..lineTo(13.5 * k, 19.5 * k)
      ..lineTo(8 * k, 19.5 * k)
      ..close();
    canvas
      ..drawPath(badan, Paint()..color = const Color(0xFFFFC9D6))
      ..drawPath(badan, _garis(k, 2.2))
      ..drawLine(Offset(9 * k, 10 * k), Offset(16 * k, 17 * k), _garis(k, 2.2))
      ..drawLine(
        Offset(13 * k, 21 * k),
        Offset(21 * k, 21 * k),
        _garis(k, 2.2),
      );
  }

  void _bintang(Canvas canvas, double k) {
    const titik = [
      (20.0, 3.0),
      (25.2, 13.6),
      (36.9, 15.3),
      (28.4, 23.5),
      (30.4, 35.1),
      (20.0, 29.6),
      (9.6, 35.1),
      (11.6, 23.5),
      (3.1, 15.3),
      (14.8, 13.6),
    ];
    final bintang = Path()..moveTo(titik.first.$1 * k, titik.first.$2 * k);
    for (final t in titik.skip(1)) {
      bintang.lineTo(t.$1 * k, t.$2 * k);
    }
    bintang.close();
    canvas
      ..drawPath(bintang, Paint()..color = const Color(0xFFFFC21A))
      ..drawPath(
        bintang,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * k
          ..strokeJoin = StrokeJoin.round
          ..color = const Color(0xFFF08C00),
      );
  }

  @override
  bool shouldRepaint(_AlatPainter old) =>
      old.alat != alat || old.warna != warna;
}
