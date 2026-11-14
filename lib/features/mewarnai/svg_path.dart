import 'dart:ui';

/// Satu derajat dalam radian, untuk rotasi busur `A`.
const _radianPerDerajat = 0.017453292519943295;

/// Token perintah atau angka pada atribut `d`.
final _token = RegExp(r'[A-Za-z]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

final _huruf = RegExp(r'^[A-Za-z]$');

const _didukung = {'M', 'L', 'H', 'V', 'C', 'Q', 'A', 'Z'};

/// Membaca atribut `d` absolut (`M L H V C Q A Z`) menjadi [Path].
///
/// Perintah relatif dan perintah lain melempar [FormatException]: halaman yang
/// setengah tergambar lebih sulit dilacak daripada halaman yang gagal.
Path svgPath(String d) {
  final token = [for (final m in _token.allMatches(d)) m[0]!];
  final path = Path();
  var i = 0;
  var cmd = '';
  var x = 0.0, y = 0.0;
  var awalX = 0.0, awalY = 0.0;

  double angka() {
    if (i >= token.length) throw FormatException('angka kurang', d);
    final nilai = double.tryParse(token[i]);
    if (nilai == null) throw FormatException('bukan angka: ${token[i]}', d);
    i++;
    return nilai;
  }

  bool adaAngka() => i < token.length && !_huruf.hasMatch(token[i]);

  while (i < token.length) {
    final t = token[i];
    if (_huruf.hasMatch(t)) {
      if (!_didukung.contains(t)) {
        throw FormatException('perintah tak didukung: $t', d);
      }
      cmd = t;
      i++;
    } else if (cmd.isEmpty || cmd == 'Z') {
      throw FormatException('parameter tanpa perintah', d);
    }

    switch (cmd) {
      case 'M':
        x = angka();
        y = angka();
        path.moveTo(x, y);
        awalX = x;
        awalY = y;
        // Pasangan berikutnya setelah M menjadi garis.
        while (adaAngka()) {
          x = angka();
          y = angka();
          path.lineTo(x, y);
        }
      case 'L':
        while (adaAngka()) {
          x = angka();
          y = angka();
          path.lineTo(x, y);
        }
      case 'H':
        while (adaAngka()) {
          x = angka();
          path.lineTo(x, y);
        }
      case 'V':
        while (adaAngka()) {
          y = angka();
          path.lineTo(x, y);
        }
      case 'C':
        while (adaAngka()) {
          final x1 = angka(), y1 = angka();
          final x2 = angka(), y2 = angka();
          final nx = angka(), ny = angka();
          _kubik(path, Offset(x, y), Offset(x1, y1), Offset(x2, y2), Offset(nx, ny));
          x = nx;
          y = ny;
        }
      case 'Q':
        while (adaAngka()) {
          final x1 = angka(), y1 = angka();
          final nx = angka(), ny = angka();
          _kuadrat(path, Offset(x, y), Offset(x1, y1), Offset(nx, ny));
          x = nx;
          y = ny;
        }
      case 'A':
        while (adaAngka()) {
          final rx = angka(), ry = angka(), rotasi = angka();
          final besar = angka(), putar = angka();
          x = angka();
          y = angka();
          path.arcToPoint(
            Offset(x, y),
            radius: Radius.elliptical(rx.abs(), ry.abs()),
            rotation: rotasi * _radianPerDerajat,
            largeArc: besar != 0,
            clockwise: putar != 0,
          );
        }
      case 'Z':
        path.close();
        x = awalX;
        y = awalY;
    }
  }
  return path;
}

/// Jarak maksimum kurva dari talinya sebelum dipecah lagi, dalam unit kanvas.
const _toleransiKurva = 0.5;

/// Batas pecah, penjaga kurva yang sangat melengkung.
const _kedalamanMaks = 12;

/// Kurva C digambar sebagai garis halus: `Path.getBounds` hanya tight untuk
/// garis, dan selisih 0,5 unit tidak terlihat pada kanvas 800 × 600.
void _kubik(
  Path path,
  Offset p0,
  Offset p1,
  Offset p2,
  Offset p3, [
  int dalam = 0,
]) {
  if (dalam >= _kedalamanMaks ||
      (_jarakGaris(p1, p0, p3) <= _toleransiKurva &&
          _jarakGaris(p2, p0, p3) <= _toleransiKurva)) {
    path.lineTo(p3.dx, p3.dy);
    return;
  }
  final p01 = (p0 + p1) / 2;
  final p12 = (p1 + p2) / 2;
  final p23 = (p2 + p3) / 2;
  final p012 = (p01 + p12) / 2;
  final p123 = (p12 + p23) / 2;
  final tengah = (p012 + p123) / 2;
  _kubik(path, p0, p01, p012, tengah, dalam + 1);
  _kubik(path, tengah, p123, p23, p3, dalam + 1);
}

void _kuadrat(
  Path path,
  Offset p0,
  Offset p1,
  Offset p2, [
  int dalam = 0,
]) {
  if (dalam >= _kedalamanMaks || _jarakGaris(p1, p0, p2) <= _toleransiKurva) {
    path.lineTo(p2.dx, p2.dy);
    return;
  }
  final p01 = (p0 + p1) / 2;
  final p12 = (p1 + p2) / 2;
  final tengah = (p01 + p12) / 2;
  _kuadrat(path, p0, p01, tengah, dalam + 1);
  _kuadrat(path, tengah, p12, p2, dalam + 1);
}

double _jarakGaris(Offset titik, Offset awal, Offset akhir) {
  final dx = akhir.dx - awal.dx;
  final dy = akhir.dy - awal.dy;
  final panjang = dx * dx + dy * dy;
  if (panjang == 0) return (titik - awal).distance;
  final proyeksi = ((titik.dx - awal.dx) * dx + (titik.dy - awal.dy) * dy) /
      panjang;
  final t = proyeksi.clamp(0.0, 1.0);
  return (titik - Offset(awal.dx + dx * t, awal.dy + dy * t)).distance;
}
