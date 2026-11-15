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
  double? _jarakTinta;
  Offset? _jari;

  int get goresan => _goresan;
  int get titik => _titik;
  bool get selesai => _selesai;

  /// Goresan yang sudah bertinta penuh. Saat huruf selesai, goresan terakhir
  /// ikut dihitung supaya tintanya tidak hilang.
  int get goresanSelesai => _selesai ? guide.strokes.length : _goresan;

  /// 0 sampai 1 untuk goresan yang sedang dikerjakan.
  double get kemajuan {
    final s = _stroke;
    if (s == null || s.length <= 0) return 0;
    return s.points[_titik].jarak / s.length;
  }

  /// Ujung tinta di sepanjang goresan aktif; mengikuti jari, bukan sampel.
  double get jarakTinta {
    final s = _stroke;
    if (s == null || s.points.isEmpty) return 0;
    return (_jarakTinta ?? s.points[_titik].jarak).clamp(0, s.length);
  }

  /// Titik ujung tinta di jalur pandu.
  Offset get ujungTinta {
    final s = _stroke;
    if (s == null || s.points.isEmpty) return Offset.zero;
    return titikPadaJalur(s.points, jarakTinta);
  }

  /// Titik pandu yang sedang dituju jari.
  Offset get pandu => _stroke?.points[_titik].offset ?? Offset.zero;

  TraceStroke? get _stroke => guide.kosong ? null : guide.strokes[_goresan];

  /// Jari harus mulai di dekat titik pandu; selain itu goresan tidak jalan.
  bool mulai(Offset p) {
    final s = _stroke;
    if (s == null || s.points.isEmpty || _selesai) return false;
    _aktif = (pandu - p).distance <= radiusMulai;
    _jari = _aktif ? p : null;
    return _aktif;
  }

  TraceStep gerak(Offset p) {
    final s = _stroke;
    if (s == null || !_aktif || _selesai || s.points.isEmpty) {
      return TraceStep.tetap;
    }
    // Titik tujuan yang jauh dari jalur membatalkan seluruh gerakan, jadi
    // melompat ke sembarang tempat tidak bisa menembus sampel di tengah.
    if (_proyeksi(s, p).jauh > toleransiJalur) return TraceStep.tetap;

    final dari = _jari ?? s.points[_titik].offset;
    final vektor = p - dari;
    // Satu gerakan tidak boleh memajukan jalur lebih jauh daripada jarak
    // yang ditempuh jari; ini yang menahan potong sudut.
    final plafon = s.points[_titik].jarak + vektor.distance + toleransiJalur;
    final langkah = (vektor.distance / jarakSampelBawaan).ceil();
    var hasil = TraceStep.tetap;
    // Jari dipecah tiap [jarakSampelBawaan] supaya sapuan cepat tetap
    // dihitung bertahap dan tidak melompati koridor.
    for (var i = 1; i <= langkah; i++) {
      final maju = _coba(dari + vektor * (i / langkah), plafon);
      if (maju != TraceStep.tetap) hasil = maju;
      if (maju == TraceStep.goresanSelesai || maju == TraceStep.selesai) {
        break;
      }
    }
    _jari = p;
    // Tinta tetap mengikuti jari walau belum ada sampel baru yang diterima,
    // tapi tidak pernah melewati batas gerakan ini.
    _perbaruiTinta(p, plafon);
    return hasil;
  }

  /// Satu titik jari: maju sampai sampel yang sudah dilewati proyeksi jari.
  TraceStep _coba(Offset p, double plafon) {
    final s = _stroke;
    if (s == null) return TraceStep.tetap;
    final r = _proyeksi(s, p);
    if (r.jauh > toleransiJalur) return TraceStep.tetap;

    final dasar = s.points[_titik].jarak;
    var sampai = r.jarak;
    if (sampai > dasar + lompatanMaju) sampai = dasar + lompatanMaju;
    if (sampai > plafon) sampai = plafon;
    var pilih = _titik;
    while (pilih < s.terakhir && s.points[pilih + 1].jarak <= sampai + 0.01) {
      pilih++;
    }
    if (pilih == _titik) return TraceStep.tetap;

    _titik = pilih;
    if (kemajuan < selesaiPada) return TraceStep.maju;
    if (_goresan >= guide.strokes.length - 1) {
      _selesai = true;
      _aktif = false;
      _jarakTinta = null;
      _jari = null;
      return TraceStep.selesai;
    }
    _goresan++;
    _titik = 0;
    _aktif = false;
    _jarakTinta = null;
    _jari = null;
    return TraceStep.goresanSelesai;
  }

  /// Tinta mengikuti proyeksi jari, dibatasi kemajuan sekarang sampai batas
  /// penerimaan berikutnya.
  void _perbaruiTinta(Offset p, double plafon) {
    final s = _stroke;
    // Goresan berikutnya belum boleh bertinta sebelum jari mulai di titiknya.
    if (!_aktif || s == null || s.points.length < 2) return;
    final r = _proyeksi(s, p);
    if (r.jauh > toleransiJalur) return;
    final dasar = s.points[_titik].jarak;
    var batas = dasar + lompatanMaju < s.length
        ? dasar + lompatanMaju
        : s.length;
    if (batas > plafon) batas = plafon;
    if (batas < dasar) batas = dasar;
    _jarakTinta = r.jarak.clamp(dasar, batas).toDouble();
  }

  /// Proyeksi [p] ke jalur: jarak sepanjang jalur dan jarak lurus ke jalur.
  ({double jarak, double jauh}) _proyeksi(TraceStroke s, Offset p) {
    var dekat = 0;
    var jauh = double.infinity;
    for (var i = 0; i <= s.terakhir; i++) {
      final d = (s.points[i].offset - p).distance;
      if (d < jauh) {
        jauh = d;
        dekat = i;
      }
    }
    var jarak = s.points[dekat].jarak;
    for (var i = dekat - 1; i <= dekat; i++) {
      if (i < 0 || i + 1 > s.terakhir) continue;
      final a = s.points[i];
      final b = s.points[i + 1];
      final seg = b.offset - a.offset;
      final panjang2 = seg.dx * seg.dx + seg.dy * seg.dy;
      if (panjang2 <= 0) continue;
      final v = p - a.offset;
      final t = ((v.dx * seg.dx + v.dy * seg.dy) / panjang2)
          .clamp(0.0, 1.0)
          .toDouble();
      final kaki = a.offset + seg * t;
      final d = (p - kaki).distance;
      if (d < jauh) {
        jauh = d;
        jarak = a.jarak + (b.jarak - a.jarak) * t;
      }
    }
    return (jarak: jarak, jauh: jauh);
  }

  void ulang() {
    _goresan = 0;
    _titik = 0;
    _selesai = false;
    _aktif = false;
    _jarakTinta = null;
    _jari = null;
  }
}

/// Titik di jalur sampel pada jarak [jarak] dari awal goresan.
Offset titikPadaJalur(List<TracePoint> pts, double jarak) {
  if (pts.isEmpty) return Offset.zero;
  if (jarak <= 0 || pts.length == 1) return pts.first.offset;
  var rendah = 0;
  var tinggi = pts.length - 1;
  while (rendah < tinggi) {
    final tengah = (rendah + tinggi) ~/ 2;
    if (pts[tengah].jarak < jarak) {
      rendah = tengah + 1;
    } else {
      tinggi = tengah;
    }
  }
  final b = pts[rendah];
  if (rendah == 0) return b.offset;
  final a = pts[rendah - 1];
  final span = b.jarak - a.jarak;
  if (span <= 0) return b.offset;
  final t = (jarak - a.jarak) / span;
  return Offset(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
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
