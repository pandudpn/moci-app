import 'dart:ui';

/// Jarak antar titik sampel di sepanjang jalur pandu.
const jarakSampelBawaan = 4.0;

/// Koridor jari: titik yang lebih jauh dari ini dari jari tidak dihitung.
const toleransiJalur = 44.0;

/// Lompatan maju maksimal per gerakan, supaya kemajuan tidak melesat.
const lompatanMaju = 40.0;

/// Radius dari titik pandu tempat goresan boleh dimulai.
const radiusMulai = 74.0;

/// Bagian jalur yang harus dilewati sebelum goresan dianggap selesai.
const selesaiPada = 0.97;

/// Satu titik sampel di jalur pandu. [jarak] adalah jarak kumulatif dari
/// awal goresan.
final class TracePoint {
  const TracePoint({required this.x, required this.y, required this.jarak});

  final double x;
  final double y;
  final double jarak;

  Offset get offset => Offset(x, y);
}

/// Satu goresan yang harus diikuti, disampel tiap [jarakSampelBawaan] unit.
final class TraceStroke {
  const TraceStroke({
    required this.path,
    required this.points,
    required this.length,
  });

  /// Membaca perintah `M L H V C` absolut, persis yang diloloskan validator.
  factory TraceStroke.fromSvgPath(String d) {
    final metric = _buildPath(d).computeMetrics().firstOrNull;
    if (metric == null) {
      return TraceStroke(path: d, points: const [], length: 0);
    }
    final points = <TracePoint>[];
    for (var jarak = 0.0; jarak < metric.length; jarak += jarakSampelBawaan) {
      _sampel(points, metric, jarak);
    }
    // Titik akhir selalu ikut, kecuali sampel terakhir sudah tepat di ujung.
    if (points.isEmpty || metric.length - points.last.jarak > 0.01) {
      _sampel(points, metric, metric.length);
    }
    return TraceStroke(
      path: d,
      points: List.unmodifiable(points),
      length: metric.length,
    );
  }

  final String path;
  final List<TracePoint> points;
  final double length;

  int get terakhir => points.length - 1;

  static void _sampel(
    List<TracePoint> points,
    PathMetric metric,
    double jarak,
  ) {
    final tangent = metric.getTangentForOffset(jarak);
    if (tangent == null) return;
    points.add(
      TracePoint(x: tangent.position.dx, y: tangent.position.dy, jarak: jarak),
    );
  }
}

/// Semua goresan satu huruf atau angka.
final class TraceGuide {
  const TraceGuide(this.strokes);

  factory TraceGuide.fromPaths(List<String> paths) => TraceGuide([
    for (final p in paths)
      if (p.trim().isNotEmpty) TraceStroke.fromSvgPath(p),
  ]);

  final List<TraceStroke> strokes;

  bool get kosong => strokes.isEmpty;
}

enum TraceStep { tetap, maju, goresanSelesai, selesai }

/// Keadaan satu sesi menulis: goresan aktif, titik aktif, dan kemajuannya.
/// Kemajuan hanya bisa maju; gerakan mundur atau di luar koridor diabaikan.
final class TracingSession {
  TracingSession(this.guide);

  final TraceGuide guide;

  int _goresan = 0;
  int _titik = 0;
  bool _selesai = false;
  bool _aktif = false;

  int get goresan => _goresan;
  int get titik => _titik;
  bool get selesai => _selesai;

  /// 0 sampai 1 untuk goresan yang sedang dikerjakan.
  double get kemajuan {
    final s = _stroke;
    if (s == null || s.length <= 0) return 0;
    return s.points[_titik].jarak / s.length;
  }

  /// Titik pandu yang sedang dituju jari.
  Offset get pandu => _stroke?.points[_titik].offset ?? Offset.zero;

  TraceStroke? get _stroke => guide.kosong ? null : guide.strokes[_goresan];

  /// Jari harus mulai di dekat titik pandu; selain itu goresan tidak jalan.
  bool mulai(Offset p) {
    final s = _stroke;
    if (s == null || s.points.isEmpty || _selesai) return false;
    _aktif = (s.points.first.offset - p).distance <= radiusMulai;
    return _aktif;
  }

  TraceStep gerak(Offset p) {
    final s = _stroke;
    if (s == null || !_aktif || _selesai || s.points.isEmpty) {
      return TraceStep.tetap;
    }
    // Titik terdekat ke jari harus benar-benar di depan titik sekarang,
    // jadi menggeser ke belakang atau ke samping tidak memajukan goresan.
    var dekat = _titik;
    var dekatJarak = double.infinity;
    for (var i = 0; i <= s.terakhir; i++) {
      final d = (s.points[i].offset - p).distance;
      if (d < dekatJarak) {
        dekatJarak = d;
        dekat = i;
      }
    }
    if (dekat <= _titik) return TraceStep.tetap;

    final batas = s.points[_titik].jarak + lompatanMaju;
    var pilih = -1;
    for (var i = _titik + 1; i <= s.terakhir; i++) {
      final titik = s.points[i];
      if (titik.jarak > batas) break;
      if ((titik.offset - p).distance <= toleransiJalur) pilih = i;
    }
    if (pilih < 0) return TraceStep.tetap;

    _titik = pilih;
    if (kemajuan < selesaiPada) return TraceStep.maju;
    if (_goresan >= guide.strokes.length - 1) {
      _selesai = true;
      _aktif = false;
      return TraceStep.selesai;
    }
    _goresan++;
    _titik = 0;
    _aktif = false;
    return TraceStep.goresanSelesai;
  }

  void ulang() {
    _goresan = 0;
    _titik = 0;
    _selesai = false;
    _aktif = false;
  }
}

/// Membaca perintah path absolut `M L H V C` tanpa Flutter.
Path _buildPath(String d) {
  final path = Path();
  final perintah = RegExp(r'([MLHVC])([^MLHVC]*)');
  var sekarang = Offset.zero;
  for (final cocok in perintah.allMatches(d.toUpperCase())) {
    final angka = RegExp(r'-?\d*\.?\d+(?:e[-+]?\d+)?')
        .allMatches(cocok.group(2) ?? '')
        .map((m) => double.parse(m.group(0)!))
        .toList();
    switch (cocok.group(1)) {
      case 'M':
        if (angka.length < 2) break;
        sekarang = Offset(angka[0], angka[1]);
        path.moveTo(sekarang.dx, sekarang.dy);
        // Pasangan berikutnya setelah M adalah garis.
        for (var i = 2; i + 1 < angka.length; i += 2) {
          sekarang = Offset(angka[i], angka[i + 1]);
          path.lineTo(sekarang.dx, sekarang.dy);
        }
      case 'L':
        for (var i = 0; i + 1 < angka.length; i += 2) {
          sekarang = Offset(angka[i], angka[i + 1]);
          path.lineTo(sekarang.dx, sekarang.dy);
        }
      case 'H':
        for (final x in angka) {
          sekarang = Offset(x, sekarang.dy);
          path.lineTo(sekarang.dx, sekarang.dy);
        }
      case 'V':
        for (final y in angka) {
          sekarang = Offset(sekarang.dx, y);
          path.lineTo(sekarang.dx, sekarang.dy);
        }
      case 'C':
        for (var i = 0; i + 5 < angka.length; i += 6) {
          path.cubicTo(
            angka[i],
            angka[i + 1],
            angka[i + 2],
            angka[i + 3],
            angka[i + 4],
            angka[i + 5],
          );
          sekarang = Offset(angka[i + 4], angka[i + 5]);
        }
    }
  }
  return path;
}
