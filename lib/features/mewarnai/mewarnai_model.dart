import 'dart:ui';

/// Ukuran halaman mewarnai dalam unit kanvas.
const kanvasHalaman = Size(800, 600);

/// Skala gambar halaman di layar tablet (864 × 648).
const skalaLayar = 1.08;

/// Lebar kuas untuk [UkuranKuas.kecil], [UkuranKuas.sedang], dan
/// [UkuranKuas.besar].
const lebarKuas = <double>[14, 26, 44];

/// Tambahan lebar kuas saat alat hapus dipakai.
const tambahanLebarHapus = 10.0;

/// Sisi stiker yang ditempel di kanvas, dalam unit kanvas.
const ukuranCap = 90.0;

/// Jarak titik yang dibuang saat coretan disederhanakan.
const toleransiCoretan = 1.0;

/// Jarak minimal antar titik yang dicatat dari jari.
const jarakMinTitik = 3.0;

/// Langkah batal yang disimpan.
const batasRiwayat = 30;

/// Karya yang disimpan sebelum yang tertua dihapus.
const batasKarya = 12;

/// Ukuran PNG pratinjau karya.
const ukuranThumbnail = Size(300, 225);

/// Ukuran kanvas di layar tablet.
const ukuranKanvasLayar = Size(864, 648);

/// Alat yang dipilih di bar mewarnai.
enum AlatMewarnai { kuas, isi, hapus, cap }

/// Tiga ukuran kuas.
enum UkuranKuas {
  kecil(14),
  sedang(26),
  besar(44);

  const UkuranKuas(this.lebar);

  final double lebar;
}

/// Warna `#RRGGBB`; nilai yang tidak dikenal menjadi putih.
Color warnaDariHex(String hex) {
  final teks = hex.startsWith('#') ? hex.substring(1) : hex;
  if (teks.length != 6) return const Color(0xFFFFFFFF);
  final nilai = int.tryParse(teks, radix: 16);
  if (nilai == null) return const Color(0xFFFFFFFF);
  return Color(0xFF000000 | nilai);
}

/// Mengubah titik jari menjadi satu coretan `M …L …` dengan satu desimal.
///
/// Titik yang berdekatan dibuang, sisanya disederhanakan dengan
/// Ramer–Douglas–Peucker. Titik tunggal tetap jadi goresan 0,1 unit supaya
/// ketukan tidak menghilang.
String coretanDariTitik(
  List<Offset> titik, {
  double toleransi = toleransiCoretan,
}) {
  final rapat = <Offset>[];
  for (final t in titik) {
    if (rapat.isEmpty || (t - rapat.last).distance >= jarakMinTitik) {
      rapat.add(t);
    }
  }
  if (rapat.isEmpty) return '';
  // Ujung jari selalu ikut, walau jaraknya di bawah ambang.
  if (titik.last != rapat.last) rapat.add(titik.last);
  final sederhana = _sederhanakan(rapat, toleransi);
  if (sederhana.length == 1) {
    sederhana.add(sederhana.first + const Offset(0.1, 0));
  }
  final hasil = StringBuffer(
    'M${_desimal(sederhana.first.dx)} ${_desimal(sederhana.first.dy)}',
  );
  for (var i = 1; i < sederhana.length; i++) {
    hasil.write('L${_desimal(sederhana[i].dx)} ${_desimal(sederhana[i].dy)}');
  }
  return hasil.toString();
}

String _desimal(double nilai) {
  final teks = nilai.toStringAsFixed(1);
  return teks.endsWith('.0') ? teks.substring(0, teks.length - 2) : teks;
}

List<Offset> _sederhanakan(List<Offset> titik, double toleransi) {
  if (titik.length <= 2) return [...titik];
  final simpan = List<bool>.filled(titik.length, false)
    ..[0] = true
    ..[titik.length - 1] = true;
  final periksa = <(int, int)>[(0, titik.length - 1)];
  while (periksa.isNotEmpty) {
    final (awal, akhir) = periksa.removeLast();
    var terjauh = 0.0;
    var indeks = -1;
    for (var i = awal + 1; i < akhir; i++) {
      final jarak = _jarakKeGaris(titik[i], titik[awal], titik[akhir]);
      if (jarak > terjauh) {
        terjauh = jarak;
        indeks = i;
      }
    }
    if (indeks >= 0 && terjauh > toleransi) {
      simpan[indeks] = true;
      periksa
        ..add((awal, indeks))
        ..add((indeks, akhir));
    }
  }
  return [
    for (var i = 0; i < titik.length; i++)
      if (simpan[i]) titik[i],
  ];
}

double _jarakKeGaris(Offset titik, Offset awal, Offset akhir) {
  final dx = akhir.dx - awal.dx;
  final dy = akhir.dy - awal.dy;
  final panjang = dx * dx + dy * dy;
  if (panjang == 0) return (titik - awal).distance;
  final proyeksi =
      ((titik.dx - awal.dx) * dx + (titik.dy - awal.dy) * dy) / panjang;
  final t = proyeksi.clamp(0.0, 1.0);
  return (titik - Offset(awal.dx + dx * t, awal.dy + dy * t)).distance;
}

/// Satu goresan kuas atau hapus di satu bagian halaman.
final class Coretan {
  const Coretan({required this.d, required this.warna, required this.lebar});

  static Coretan fromJson(Object? value) {
    final map = _peta(value);
    return Coretan(
      d: _teks(map['d']),
      warna: _teks(map['warna']),
      lebar: _angka(map['lebar']),
    );
  }

  final String d;
  final String warna;
  final double lebar;

  Map<String, Object?> toJson() => {'d': d, 'warna': warna, 'lebar': lebar};
}

/// Satu stiker yang ditempel di kanvas.
final class CapTempel {
  const CapTempel({required this.cap, required this.x, required this.y});

  static CapTempel? fromJson(Object? value) {
    final map = _peta(value);
    final cap = _teks(map['cap']);
    if (cap.isEmpty) return null;
    return CapTempel(cap: cap, x: _angka(map['x']), y: _angka(map['y']));
  }

  final String cap;
  final double x;
  final double y;

  Map<String, Object?> toJson() => {'cap': cap, 'x': x, 'y': y};
}

/// Isi satu halaman: warna isian per bagian, coretan per bagian, dan stiker.
final class KaryaData {
  const KaryaData({
    required this.halaman,
    this.isian = const {},
    this.coretan = const {},
    this.cap = const [],
    this.waktu,
  });

  factory KaryaData.kosong(String halaman, {DateTime? waktu}) =>
      KaryaData(halaman: halaman, waktu: waktu);

  /// Membaca berkas yang mungkin rusak: entri salah dilewati, tidak melempar.
  factory KaryaData.fromJson(Object? value) {
    final map = _peta(value);
    final isian = <int, String>{};
    for (final e in _peta(map['isian']).entries) {
      final bagian = int.tryParse(e.key);
      final hex = _teks(e.value);
      if (bagian != null && bagian >= 0 && hex.isNotEmpty) {
        isian[bagian] = hex;
      }
    }
    final coretan = <int, List<Coretan>>{};
    for (final e in _peta(map['coretan']).entries) {
      final bagian = int.tryParse(e.key);
      if (bagian == null || bagian < 0) continue;
      final daftar = [
        for (final v in _daftar(e.value)) Coretan.fromJson(v),
      ].where((c) => c.d.isNotEmpty).toList();
      if (daftar.isNotEmpty) coretan[bagian] = daftar;
    }
    return KaryaData(
      halaman: _teks(map['halaman']),
      isian: isian,
      coretan: coretan,
      cap: [
        for (final v in _daftar(map['cap']))
          if (CapTempel.fromJson(v) case final cap?) cap,
      ],
      waktu: DateTime.tryParse(_teks(map['waktu'])),
    );
  }

  static const versi = 1;

  final String halaman;
  final Map<int, String> isian;
  final Map<int, List<Coretan>> coretan;
  final List<CapTempel> cap;
  final DateTime? waktu;

  /// Ada warna, coretan, atau stiker yang bisa disimpan.
  bool get adaIsi =>
      isian.isNotEmpty ||
      coretan.values.any((daftar) => daftar.isNotEmpty) ||
      cap.isNotEmpty;

  KaryaData copyWith({
    Map<int, String>? isian,
    Map<int, List<Coretan>>? coretan,
    List<CapTempel>? cap,
    DateTime? waktu,
  }) => KaryaData(
    halaman: halaman,
    isian: isian ?? this.isian,
    coretan: coretan ?? this.coretan,
    cap: cap ?? this.cap,
    waktu: waktu ?? this.waktu,
  );

  Map<String, Object?> toJson() => {
    'versi': versi,
    'halaman': halaman,
    'isian': {for (final e in isian.entries) '${e.key}': e.value},
    'coretan': {
      for (final e in coretan.entries)
        '${e.key}': [for (final c in e.value) c.toJson()],
    },
    'cap': [for (final c in cap) c.toJson()],
    if (waktu case final w?) 'waktu': w.toIso8601String(),
  };
}

/// Satu langkah yang bisa dibatalkan.
sealed class Langkah {
  const Langkah();
}

/// Isi bagian: warna lama dan coretan yang tertimpa.
final class LangkahIsi extends Langkah {
  const LangkahIsi({
    required this.bagian,
    required this.sebelum,
    this.coretanDihapus = const [],
  });

  final int bagian;
  final String? sebelum;
  final List<Coretan> coretanDihapus;
}

/// Satu coretan baru di [bagian].
final class LangkahCoretan extends Langkah {
  const LangkahCoretan(this.bagian);

  final int bagian;
}

/// Satu stiker baru di ujung daftar.
final class LangkahCap extends Langkah {
  const LangkahCap();
}

/// Mulai lagi: seluruh isi halaman sebelum dikosongkan.
final class LangkahMulaiLagi extends Langkah {
  const LangkahMulaiLagi(this.sebelum);

  final KaryaData sebelum;
}

/// Tumpukan langkah batal, paling banyak [batas] langkah.
final class Riwayat {
  Riwayat({this.batas = batasRiwayat});

  final int batas;
  final List<Langkah> _langkah = [];

  bool get kosong => _langkah.isEmpty;

  int get panjang => _langkah.length;

  void tambah(Langkah langkah) {
    _langkah.add(langkah);
    if (_langkah.length > batas) _langkah.removeAt(0);
  }

  Langkah? ambilTerakhir() => _langkah.isEmpty ? null : _langkah.removeLast();
}

String _teks(Object? value) => value is String ? value : '';

double _angka(Object? value) => value is num ? value.toDouble() : 0;

List<Object?> _daftar(Object? value) => value is List ? value : const [];

Map<String, Object?> _peta(Object? value) => value is Map
    ? {
        for (final e in value.entries)
          if (e.key is String) e.key as String: e.value,
      }
    : const {};
