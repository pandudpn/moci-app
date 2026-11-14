import 'package:flutter/widgets.dart';

import '../../core/content/katalog.dart';

/// Membaca atribut `d` SVG absolut: M, L, H, V, C, A, dan Z.
Path pathDariSvg(String d) {
  final path = Path();
  final token = RegExp(
    r'[A-Za-z]|-?\d*\.?\d+(?:[eE][-+]?\d+)?',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  var cmd = '';
  var cur = Offset.zero;

  double angka() => double.parse(token[i++]);

  while (i < token.length) {
    if (RegExp(r'^[A-Za-z]$').hasMatch(token[i])) {
      cmd = token[i++].toUpperCase();
      if (cmd == 'Z') {
        path.close();
        continue;
      }
    }
    switch (cmd) {
      case 'M':
        cur = Offset(angka(), angka());
        path.moveTo(cur.dx, cur.dy);
        // Pasangan sesudah M diperlakukan sebagai L, seperti SVG.
        cmd = 'L';
      case 'L':
        cur = Offset(angka(), angka());
        path.lineTo(cur.dx, cur.dy);
      case 'H':
        cur = Offset(angka(), cur.dy);
        path.lineTo(cur.dx, cur.dy);
      case 'V':
        cur = Offset(cur.dx, angka());
        path.lineTo(cur.dx, cur.dy);
      case 'C':
        final c1 = Offset(angka(), angka());
        final c2 = Offset(angka(), angka());
        final p = Offset(angka(), angka());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p.dx, p.dy);
        cur = p;
      case 'A':
        final rx = angka();
        final ry = angka();
        final rotation = angka();
        final large = angka() != 0;
        final sweep = angka() != 0;
        final p = Offset(angka(), angka());
        path.arcToPoint(
          p,
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: large,
          clockwise: sweep,
        );
        cur = p;
      default:
        throw FormatException('Perintah path tidak dikenal: $cmd');
    }
  }
  return path;
}

/// Bentuk katalog dengan bayangan, garis tebal, dan wajah Moci.
class BentukShape extends StatelessWidget {
  const BentukShape({
    super.key,
    required this.bentuk,
    required this.size,
    this.shadow = false,
  });

  final BentukEntry bentuk;
  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _BentukPainter(bentuk, shadow)),
  );
}

class _BentukPainter extends CustomPainter {
  const _BentukPainter(this.bentuk, this.shadow);

  final BentukEntry bentuk;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 200);
    final path = pathDariSvg(bentuk.path);
    final isi = _hex(bentuk.warna);
    final gelap = _hex(bentuk.gelap);
    if (shadow) {
      canvas.save();
      canvas.translate(0, 9);
      canvas.drawPath(path, Paint()..color = gelap);
      canvas.drawPath(
        path,
        Paint()
          ..color = gelap
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }
    canvas.drawPath(path, Paint()..color = isi);
    canvas.drawPath(
      path,
      Paint()
        ..color = isi
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.save();
    canvas.translate(bentuk.wajahX, bentuk.wajahY);
    canvas.scale(bentuk.wajahSkala);
    final mata = Paint()..color = const Color(0xFF2B2350);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-17, -6), width: 14, height: 18),
      mata,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(17, -6), width: 14, height: 18),
      mata,
    );
    final kilau = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(const Offset(-14.5, -9.5), 2.6, kilau);
    canvas.drawCircle(const Offset(19.5, -9.5), 2.6, kilau);
    final pipi = Paint()..color = const Color(0x80FFFFFF);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-28, 8), width: 14, height: 9),
      pipi,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(28, 8), width: 14, height: 9),
      pipi,
    );
    final senyum = Path()
      ..moveTo(-9, 8)
      ..quadraticBezierTo(0, 17, 9, 8);
    canvas.drawPath(
      senyum,
      Paint()
        ..color = const Color(0xFF2B2350)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BentukPainter old) =>
      old.bentuk != bentuk || old.shadow != shadow;
}

Color _hex(String value) =>
    Color(0xFF000000 | int.parse(value.replaceFirst('#', ''), radix: 16));
