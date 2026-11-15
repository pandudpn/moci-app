/// Bentuk dasar untuk menyusun halaman mewarnai baru.
///
/// Semua jalur memakai perintah absolut `M H V L A C Z` yang didukung
/// `svg_path.dart`, dan semuanya tertutup kecuali garis detail.
library;

import 'dart:math' as math;

import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';

/// Titik 2D. Generator memakai tipe sendiri supaya bisa dijalankan dengan
/// `dart run` tanpa `dart:ui`.
final class Titik {
  const Titik(this.dx, this.dy);

  final double dx;
  final double dy;

  Titik operator +(Titik lain) => Titik(dx + lain.dx, dy + lain.dy);

  @override
  bool operator ==(Object lain) =>
      lain is Titik && lain.dx == dx && lain.dy == dy;

  @override
  int get hashCode => Object.hash(dx, dy);
}

/// Warna tinta garis halaman, sama dengan painter.
const tinta = '#2B2350';

const putih = '#FFFFFF';
const merah = '#FF4B4B';
const merahMuda = '#FF8FB1';
const kuning = '#FFD43B';
const oranye = '#FF922B';
const hijau = '#2FB344';
const hijauMuda = '#8CE99A';
const biru = '#1C7ED6';
const biruMuda = '#74C0FC';
const biruLangit = '#A5D8FF';
const biruAwan = '#D0EBFF';
const ungu = '#9775FA';
const unguMuda = '#B197FC';
const toska = '#22C1C3';
const coklat = '#B07A4F';
const pink = '#E64980';
const krem = '#F2D27A';
const abu = '#CED4DA';
const abuMuda = '#E9ECEF';

/// Satu garis detail: jalur, warna isi (kosong berarti tinta), dan tebal.
typedef Rincian = ({String d, String fill, double w});

/// Angka jalur: paling banyak satu desimal, tanpa `.0`.
String n(num nilai) {
  final teks = nilai.toStringAsFixed(1);
  return teks.endsWith('.0') ? teks.substring(0, teks.length - 2) : teks;
}

String kotak(num x, num y, num lebar, num tinggi) =>
    'M${n(x)} ${n(y)}H${n(x + lebar)}V${n(y + tinggi)}H${n(x)}Z';

String kotakBulat(num x, num y, num lebar, num tinggi, num r) {
  final rr = n(r);
  return 'M${n(x + r)} ${n(y)}H${n(x + lebar - r)}'
      'A$rr $rr 0 0 1 ${n(x + lebar)} ${n(y + r)}'
      'V${n(y + tinggi - r)}'
      'A$rr $rr 0 0 1 ${n(x + lebar - r)} ${n(y + tinggi)}'
      'H${n(x + r)}'
      'A$rr $rr 0 0 1 ${n(x)} ${n(y + tinggi - r)}'
      'V${n(y + r)}'
      'A$rr $rr 0 0 1 ${n(x + r)} ${n(y)}Z';
}

String lingkaran(num cx, num cy, num r) => elips(cx, cy, r, r);

String elips(num cx, num cy, num rx, num ry) =>
    'M${n(cx - rx)} ${n(cy)}'
    'A${n(rx)} ${n(ry)} 0 1 0 ${n(cx + rx)} ${n(cy)}'
    'A${n(rx)} ${n(ry)} 0 1 0 ${n(cx - rx)} ${n(cy)}Z';

String poligon(List<Titik> titik) {
  final buf = StringBuffer('M${n(titik.first.dx)} ${n(titik.first.dy)}');
  for (final t in titik.skip(1)) {
    buf.write('L${n(t.dx)} ${n(t.dy)}');
  }
  buf.write('Z');
  return buf.toString();
}

/// Kurva halus (Catmull-Rom jadi `C`) lewat [titik]; tertutup kalau [tutup].
String lekuk(List<Titik> titik, {bool tutup = true}) {
  if (titik.isEmpty) return '';
  final buf = StringBuffer('M${n(titik.first.dx)} ${n(titik.first.dy)}');
  final jumlah = titik.length;
  Titik ambil(int i) => tutup
      ? titik[(i % jumlah + jumlah) % jumlah]
      : titik[i.clamp(0, jumlah - 1)];
  final akhir = tutup ? jumlah : jumlah - 1;
  for (var i = 0; i < akhir; i++) {
    final a = ambil(i - 1);
    final b = ambil(i);
    final c = ambil(i + 1);
    final d = ambil(i + 2);
    buf.write(
      'C${n(b.dx + (c.dx - a.dx) / 6)} ${n(b.dy + (c.dy - a.dy) / 6)} '
      '${n(c.dx - (d.dx - b.dx) / 6)} ${n(c.dy - (d.dy - b.dy) / 6)} '
      '${n(c.dx)} ${n(c.dy)}',
    );
  }
  if (tutup) buf.write('Z');
  return buf.toString();
}

/// Garis patah tanpa tutup, untuk detail.
String garisPatah(List<Titik> titik) {
  final buf = StringBuffer('M${n(titik.first.dx)} ${n(titik.first.dy)}');
  for (final t in titik.skip(1)) {
    buf.write('L${n(t.dx)} ${n(t.dy)}');
  }
  return buf.toString();
}

/// Garis detail bertinta.
Rincian garis(String d, {double w = 5}) => (d: d, fill: '', w: w);

/// Awan empuk: gundukan di atas alas datar.
String awan(double x, double y, {double skala = 1}) {
  final s = skala;
  final gunduk = <Titik>[
    Titik(x, y),
    Titik(x + 34 * s, y - 6 * s),
    Titik(x + 56 * s, y - 34 * s),
    Titik(x + 96 * s, y - 46 * s),
    Titik(x + 138 * s, y - 26 * s),
    Titik(x + 168 * s, y + 4 * s),
    Titik(x + 150 * s, y + 22 * s),
    Titik(x + 20 * s, y + 22 * s),
  ];
  return lekuk(gunduk);
}

/// Pohon: batang dan tajuk bergerombol sebagai dua bagian terpisah.
({String batang, String tajuk}) pohon(
  double x,
  double y, {
  double tinggi = 110,
  double lebarTajuk = 130,
}) {
  final tajuk = lekuk([
    Titik(x - 10, y + 10),
    Titik(x - lebarTajuk * 0.5, y - 10),
    Titik(x - lebarTajuk * 0.36, y - 55),
    Titik(x, y - 78),
    Titik(x + lebarTajuk * 0.36, y - 55),
    Titik(x + lebarTajuk * 0.5, y - 10),
    Titik(x + 10, y + 10),
  ]);
  return (batang: kotak(x - 12, y, 24, tinggi), tajuk: tajuk);
}

/// Bunga lima kelopak: satu jalur kelopak dan satu lingkaran tengah.
({String kelopak, String tengah}) bunga(num cx, num cy, {num r = 22}) {
  final titik = <Titik>[];
  for (var i = 0; i < 10; i++) {
    final sudut = i * math.pi / 5;
    final jari = i.isEven ? r : r * 0.52;
    titik.add(Titik(cx + jari * math.cos(sudut), cy + jari * math.sin(sudut)));
  }
  return (kelopak: lekuk(titik), tengah: lingkaran(cx, cy, r * 0.42));
}

/// Daun: dua lengkung bertemu di ujung.
String daun(num x, num y, num panjang, num lebar, {num putar = 0}) {
  final d = math.cos(putar);
  final s = math.sin(putar);
  Titik putarTitik(num dx, num dy) =>
      Titik(x + dx * d - dy * s, y + dx * s + dy * d);
  final ujung = putarTitik(panjang, 0);
  final atas = putarTitik(panjang * 0.45, -lebar);
  final bawah = putarTitik(panjang * 0.45, lebar);
  return 'M${n(x)} ${n(y)}'
      'Q${n(atas.dx)} ${n(atas.dy)} ${n(ujung.dx)} ${n(ujung.dy)}'
      'Q${n(bawah.dx)} ${n(bawah.dy)} ${n(x)} ${n(y)}Z';
}

/// Lengkung meruncing seperti tentakel atau kaki: makin ke ujung makin kecil.
String tentakel(
  Titik akar, {
  required double panjang,
  double lebar = 40,
  double arah = 1.5708,
  double bengkok = 0.28,
}) {
  const langkah = 12;
  var x = akar.dx;
  var y = akar.dy;
  var sudut = arah;
  final kiri = <Titik>[];
  final kanan = <Titik>[];
  for (var i = 0; i <= langkah; i++) {
    final t = i / langkah;
    final w = lebar * (1 - 0.7 * t) / 2;
    final nx = math.cos(sudut);
    final ny = math.sin(sudut);
    kiri.add(Titik(x - ny * w, y + nx * w));
    kanan.add(Titik(x + ny * w, y - nx * w));
    x += nx * panjang / langkah;
    y += ny * panjang / langkah;
    sudut += bengkok;
  }
  return lekuk([...kiri, ...kanan.reversed]);
}

/// Karang kipas: jari-jari membulat di atas alas.
String karang(double cx, double cy, double r, {int jari = 5}) {
  final titik = <Titik>[];
  for (var i = 0; i < jari; i++) {
    final a = math.pi * (0.08 + 0.84 * i / (jari - 1));
    titik.add(Titik(cx + math.cos(a) * r, cy - math.sin(a) * r));
    if (i < jari - 1) {
      final a2 = math.pi * (0.08 + 0.84 * (i + 0.5) / (jari - 1));
      titik.add(
        Titik(cx + math.cos(a2) * r * 0.46, cy - math.sin(a2) * r * 0.46),
      );
    }
  }
  titik
    ..add(Titik(cx + r * 0.52, cy + r * 0.18))
    ..add(Titik(cx - r * 0.52, cy + r * 0.18));
  return lekuk(titik);
}

/// Ikan sederhana: badan bulat telur dan ekor segitiga di kanan.
({String badan, String ekor}) ikan(
  double cx,
  double cy,
  double rx,
  double ry,
) => (
  badan: elips(cx, cy, rx, ry),
  ekor: poligon([
    Titik(cx + rx * 0.78, cy),
    Titik(cx + rx * 1.7, cy - ry * 0.85),
    Titik(cx + rx * 1.7, cy + ry * 0.85),
  ]),
);

/// Bintang laut berujung lima yang membulat.
String bintangLaut(double cx, double cy, double r) {
  final titik = <Titik>[];
  for (var i = 0; i < 10; i++) {
    final a = -math.pi / 2 + i * math.pi / 5;
    final jari = i.isEven ? r : r * 0.46;
    titik.add(Titik(cx + jari * math.cos(a), cy + jari * math.sin(a)));
  }
  return lekuk(titik);
}

/// Semak bergerombol dengan alas rata, ditambah beberapa helai rumput.
({String d, List<Rincian> detail}) semak(double cx, double cy, double r) => (
  d: lekuk([
    Titik(cx - r, cy),
    Titik(cx - r * 0.86, cy - r * 0.6),
    Titik(cx - r * 0.4, cy - r * 0.9),
    Titik(cx + r * 0.06, cy - r * 0.72),
    Titik(cx + r * 0.58, cy - r * 0.92),
    Titik(cx + r * 0.92, cy - r * 0.44),
    Titik(cx + r, cy),
    Titik(cx + r * 0.5, cy + r * 0.06),
    Titik(cx - r * 0.5, cy + r * 0.06),
  ]),
  detail: [
    garis('M${n(cx - r * 0.4)} ${n(cy - r * 0.2)}V${n(cy - r * 0.5)}', w: 3),
    garis('M${n(cx)} ${n(cy - r * 0.24)}V${n(cy - r * 0.62)}', w: 3),
    garis('M${n(cx + r * 0.42)} ${n(cy - r * 0.2)}V${n(cy - r * 0.56)}', w: 3),
  ],
);

/// Lingkaran bergerigi halus: surai singa, matahari, atau kelopak besar.
String gerigi(
  double cx,
  double cy,
  double r, {
  int gigi = 14,
  double dalam = 0.8,
}) {
  final titik = <Titik>[];
  for (var i = 0; i < gigi * 2; i++) {
    final a = i * math.pi / gigi - math.pi / 2;
    final jari = i.isEven ? r : r * dalam;
    titik.add(Titik(cx + jari * math.cos(a), cy + jari * math.sin(a)));
  }
  return lekuk(titik);
}

/// Batang lurus selebar [lebar] dari [a] ke [b], untuk rangka sepeda atau
/// tiang tenda.
String batang(Titik a, Titik b, double lebar) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final panjang = math.sqrt(dx * dx + dy * dy);
  if (panjang == 0) return lingkaran(a.dx, a.dy, lebar / 2);
  final nx = -dy / panjang * lebar / 2;
  final ny = dx / panjang * lebar / 2;
  return poligon([
    Titik(a.dx + nx, a.dy + ny),
    Titik(b.dx + nx, b.dy + ny),
    Titik(b.dx - nx, b.dy - ny),
    Titik(a.dx - nx, a.dy - ny),
  ]);
}

/// Roda: lingkaran luar ditambah pelek sebagai detail.
({String d, List<Rincian> detail}) roda(num cx, num cy, num r) => (
  d: lingkaran(cx, cy, r),
  detail: [garis(lingkaran(cx, cy, r * 0.45), w: 4)],
);

/// Detail berwarna: bintik, mata, atau lubang hidung. Detail selalu digambar
/// sebagai garis, jadi [w] harus cukup tebal untuk terlihat.
Rincian blok(String d, {String isi = tinta, double w = 3}) =>
    (d: d, fill: isi, w: w);

/// Sepasang mata bulat.
List<Rincian> mata(Titik kiri, Titik kanan, {double r = 12}) => [
  blok(lingkaran(kiri.dx, kiri.dy, r), w: 3),
  blok(lingkaran(kanan.dx, kanan.dy, r), w: 3),
];

/// Garis kaca: [kolom] × [baris] kotak di dalam persegi.
List<Rincian> kaca(
  num x,
  num y,
  num lebar,
  num tinggi, {
  int kolom = 2,
  int baris = 2,
  double w = 4,
}) {
  final hasil = <Rincian>[];
  for (var i = 1; i < kolom; i++) {
    final px = x + lebar * i / kolom;
    hasil.add(garis('M${n(px)} ${n(y)}V${n(y + tinggi)}', w: w));
  }
  for (var i = 1; i < baris; i++) {
    final py = y + tinggi * i / baris;
    hasil.add(garis('M${n(x)} ${n(py)}H${n(x + lebar)}', w: w));
  }
  return hasil;
}

/// Matahari bulat dengan delapan sinar.
({String d, List<Rincian> detail}) matahari(
  num cx,
  num cy,
  num r, {
  String warna = kuning,
}) {
  final sinar = <Rincian>[];
  for (var i = 0; i < 8; i++) {
    final sudut = i * math.pi / 4;
    final dx = math.cos(sudut);
    final dy = math.sin(sudut);
    final dalam = r + 16;
    final luar = r + 42;
    sinar.add(
      garis(
        'M${n(cx + dx * dalam)} ${n(cy + dy * dalam)}'
        'L${n(cx + dx * luar)} ${n(cy + dy * luar)}',
        w: 7,
      ),
    );
  }
  return (d: lingkaran(cx, cy, r), detail: sinar);
}

/// Penyusun satu halaman: latar penuh, lalu bagian-bagian yang ditambahkan.
final class Halaman {
  Halaman({
    required this.id,
    required this.kategori,
    required this.namaId,
    required this.namaEn,
    required this.latar,
  }) {
    bagian.add(const ColoringRegion(d: 'M0 0H800V600H0Z'));
    contoh[0] = latar;
  }

  final String id;
  final String kategori;
  final String namaId;
  final String namaEn;
  final String latar;

  final List<ColoringRegion> bagian = [];
  final Map<int, String> contoh = {};

  /// Menambah satu bagian tertutup; [warna] mengisi contoh warnanya.
  int tambah(String d, {String? warna, List<Rincian> detail = const []}) {
    bagian.add(ColoringRegion(d: d, detail: detail));
    final i = bagian.length - 1;
    if (warna != null) contoh[i] = warna;
    return i;
  }

  ColoringPage selesai() => ColoringPage(
    id: id,
    kategori: kategori,
    nama: Bilingual(namaId, namaEn),
    bagian: bagian,
    contoh: contoh,
  );
}
