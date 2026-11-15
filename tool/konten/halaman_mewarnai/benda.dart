/// Halaman kategori `benda`: rumah joglo, rumah pohon, tenda, sepeda, balon
/// udara.
library;

import 'package:moci/core/content/coloring.dart';

import 'bentuk.dart';

const _langit = '#CDEBFF';

const _tanah = 'M0 512C140 488 300 526 440 506C580 486 700 522 800 500V600H0Z';

/// Lima halaman benda dan rumah.
List<ColoringPage> halamanBenda() => [
  _joglo(),
  _rumahPohon(),
  _tenda(),
  _sepeda(),
  _balonUdara(),
];

ColoringPage _joglo() {
  final h = Halaman(
    id: 'rumah-joglo',
    kategori: 'benda',
    namaId: 'Rumah Joglo',
    namaEn: 'Joglo House',
    latar: _langit,
  );
  final surya = matahari(696, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(110, 112), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    kotak(250, 340, 300, 160),
    warna: krem,
    detail: [garis('M250 430H550', w: 4)],
  );
  h.tambah(
    poligon([
      const Titik(178, 344),
      const Titik(622, 344),
      const Titik(544, 256),
      const Titik(256, 256),
    ]),
    warna: merah,
    detail: [
      for (var x = 220; x < 500; x += 48) garis('M$x 344L${x + 20} 260', w: 3),
    ],
  );
  h.tambah(
    poligon([
      const Titik(298, 256),
      const Titik(502, 256),
      const Titik(452, 188),
      const Titik(348, 188),
    ]),
    warna: merahMuda,
  );

  for (final x in [262.0, 350.0, 430.0, 518.0]) {
    h.tambah(kotak(x, 344, 20, 156), warna: coklat);
  }
  h.tambah(
    kotakBulat(372, 396, 56, 104, 8),
    warna: coklat,
    detail: [blok(lingkaran(416, 452, 5))],
  );
  h.tambah(kotakBulat(290, 372, 40, 50, 6), warna: biruMuda);
  h.tambah(kotakBulat(470, 372, 40, 50, 6), warna: biruMuda);

  h.tambah(kotak(340, 500, 120, 14), warna: abu);
  h.tambah(kotak(322, 514, 156, 14), warna: abu);

  final kiri = pohon(110, 470, tinggi: 62, lebarTajuk: 140);
  h.tambah(kiri.batang, warna: coklat);
  h.tambah(kiri.tajuk, warna: hijau);
  final kanan = pohon(694, 470, tinggi: 62, lebarTajuk: 140);
  h.tambah(kanan.batang, warna: coklat);
  h.tambah(kanan.tajuk, warna: hijau);

  final kuntum = bunga(206, 546, r: 24);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _rumahPohon() {
  final h = Halaman(
    id: 'rumah-pohon',
    kategori: 'benda',
    namaId: 'Rumah Pohon',
    namaEn: 'Tree House',
    latar: _langit,
  );
  final surya = matahari(116, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(580, 112), warna: putih);

  h.tambah(
    lekuk([
      const Titik(400, 66),
      const Titik(560, 96),
      const Titik(640, 200),
      const Titik(586, 306),
      const Titik(400, 340),
      const Titik(214, 306),
      const Titik(160, 200),
      const Titik(240, 96),
    ]),
    warna: hijau,
  );
  h.tambah(
    lekuk([
      const Titik(212, 128),
      const Titik(326, 108),
      const Titik(360, 196),
      const Titik(288, 262),
      const Titik(178, 236),
    ]),
    warna: hijauMuda,
  );
  h.tambah(
    lekuk([
      const Titik(470, 120),
      const Titik(576, 148),
      const Titik(600, 234),
      const Titik(504, 262),
      const Titik(438, 194),
    ]),
    warna: hijauMuda,
  );

  h.tambah(
    kotakBulat(360, 288, 80, 312, 24),
    warna: coklat,
    detail: [
      garis('M372 340C388 356 404 348 414 366', w: 4),
      garis('M382 430C398 444 412 438 424 456', w: 4),
      garis('M370 520C386 534 402 528 414 542', w: 4),
    ],
  );
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(kotak(300, 250, 200, 132), warna: krem);
  h.tambah(
    poligon([
      const Titik(280, 250),
      const Titik(520, 250),
      const Titik(498, 194),
      const Titik(302, 194),
    ]),
    warna: merah,
  );
  h.tambah(
    kotakBulat(368, 296, 54, 86, 8),
    warna: coklat,
    detail: [blok(lingkaran(410, 344, 5))],
  );
  h.tambah(kotakBulat(312, 276, 42, 42, 6), warna: biruMuda);
  h.tambah(kotakBulat(440, 276, 42, 42, 6), warna: biruMuda);

  h.tambah(kotak(486, 374, 84, 14), warna: coklat);
  h.tambah(
    batang(const Titik(510, 382), const Titik(510, 548), 14),
    warna: coklat,
    detail: [
      for (final y in [416.0, 450.0, 484.0, 518.0])
        garis('M516 ${n(y)}H548', w: 4),
    ],
  );
  h.tambah(
    batang(const Titik(552, 382), const Titik(552, 548), 14),
    warna: coklat,
  );

  final semakKanan = semak(700, 530, 44);
  h.tambah(semakKanan.d, warna: hijauMuda, detail: semakKanan.detail);
  final kuntum = bunga(104, 540, r: 24);
  h.tambah(kuntum.kelopak, warna: merahMuda);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _tenda() {
  final h = Halaman(
    id: 'tenda',
    kategori: 'benda',
    namaId: 'Tenda',
    namaEn: 'Tent',
    latar: _langit,
  );
  final surya = matahari(688, 96, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(112, 116), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    poligon([
      const Titik(168, 500),
      const Titik(632, 500),
      const Titik(400, 186),
    ]),
    warna: hijauMuda,
    detail: [garis('M400 200L252 500', w: 4), garis('M400 200L548 500', w: 4)],
  );
  h.tambah(
    poligon([
      const Titik(400, 236),
      const Titik(342, 500),
      const Titik(458, 500),
    ]),
    warna: hijau,
  );
  h.tambah(kotak(396, 140, 8, 50), warna: abu);
  h.tambah(
    poligon([
      const Titik(404, 142),
      const Titik(468, 158),
      const Titik(404, 176),
    ]),
    warna: merah,
  );

  h.tambah(
    batang(const Titik(318, 500), const Titik(380, 520), 16),
    warna: coklat,
  );
  h.tambah(
    batang(const Titik(482, 500), const Titik(420, 520), 16),
    warna: coklat,
  );
  h.tambah(
    lekuk([
      const Titik(400, 452),
      const Titik(430, 484),
      const Titik(416, 520),
      const Titik(384, 520),
      const Titik(370, 484),
    ]),
    warna: oranye,
  );
  h.tambah(
    lekuk([
      const Titik(400, 480),
      const Titik(414, 500),
      const Titik(400, 518),
      const Titik(386, 500),
    ]),
    warna: kuning,
  );

  for (final pos in [
    const Titik(300, 534),
    const Titik(500, 538),
    const Titik(548, 516),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 16), warna: abu);
  }

  final tanam = pohon(688, 486, tinggi: 60, lebarTajuk: 116);
  h.tambah(tanam.batang, warna: coklat);
  h.tambah(tanam.tajuk, warna: hijau);

  final kuntum = bunga(112, 540, r: 24);
  h.tambah(kuntum.kelopak, warna: merahMuda);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _sepeda() {
  final h = Halaman(
    id: 'sepeda',
    kategori: 'benda',
    namaId: 'Sepeda',
    namaEn: 'Bicycle',
    latar: _langit,
  );
  final surya = matahari(700, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(104, 112), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  final belakang = roda(230, 424, 104);
  h.tambah(
    belakang.d,
    warna: abu,
    detail: [
      ...belakang.detail,
      for (var i = 0; i < 3; i++)
        garis(
          'M${n(230 + 90 * _cos(i))} ${n(424 + 90 * _sin(i))}'
          'L${n(230 - 90 * _cos(i))} ${n(424 - 90 * _sin(i))}',
          w: 3,
        ),
    ],
  );
  final depan = roda(570, 424, 104);
  h.tambah(
    depan.d,
    warna: abu,
    detail: [
      ...depan.detail,
      for (var i = 0; i < 3; i++)
        garis(
          'M${n(570 + 90 * _cos(i))} ${n(424 + 90 * _sin(i))}'
          'L${n(570 - 90 * _cos(i))} ${n(424 - 90 * _sin(i))}',
          w: 3,
        ),
    ],
  );

  final tabung = [
    (const Titik(330, 306), const Titik(400, 438)),
    (const Titik(330, 306), const Titik(498, 306)),
    (const Titik(400, 438), const Titik(498, 306)),
    (const Titik(330, 306), const Titik(232, 424)),
    (const Titik(400, 438), const Titik(232, 424)),
    (const Titik(498, 306), const Titik(570, 424)),
  ];
  for (final t in tabung) {
    h.tambah(batang(t.$1, t.$2, 18), warna: ungu);
  }

  h.tambah(kotakBulat(288, 278, 78, 26, 10), warna: coklat);
  h.tambah(
    batang(const Titik(498, 306), const Titik(516, 262), 14),
    warna: abu,
  );
  h.tambah(kotakBulat(486, 240, 76, 18, 8), warna: abu);

  h.tambah(
    lingkaran(400, 438, 34),
    warna: kuning,
    detail: [
      garis(lingkaran(400, 438, 20), w: 3),
      garis('M400 420L232 410', w: 3),
      garis('M400 456L232 438', w: 3),
    ],
  );
  h.tambah(
    batang(const Titik(400, 438), const Titik(366, 470), 12),
    warna: abu,
  );
  h.tambah(
    batang(const Titik(400, 438), const Titik(434, 418), 12),
    warna: abu,
  );
  h.tambah(kotakBulat(346, 462, 40, 16, 7), warna: tinta);
  h.tambah(kotakBulat(414, 404, 40, 16, 7), warna: tinta);

  final kuntum = bunga(112, 542, r: 24);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

double _cos(int i) => const [1.0, -0.5, -0.5][i];

double _sin(int i) => const [0.0, 0.866, -0.866][i];

ColoringPage _balonUdara() {
  final h = Halaman(
    id: 'balon-udara',
    kategori: 'benda',
    namaId: 'Balon Udara',
    namaEn: 'Hot Air Balloon',
    latar: _langit,
  );
  final surya = matahari(112, 88, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(596, 108), warna: putih);
  h.tambah(awan(206, 176, skala: 0.7), warna: putih);
  h.tambah(
    'M0 470C150 430 300 472 450 448C600 426 700 462 800 446V600H0Z',
    warna: hijauMuda,
  );

  final utama = _balon(400, 250, 1);
  h.tambah(utama.selubung, warna: merah, detail: utama.tali);
  h.tambah(
    utama.keranjang,
    warna: coklat,
    detail: [garis('M364 486H436', w: 4)],
  );
  h.tambah(
    lekuk([
      const Titik(400, 412),
      const Titik(420, 438),
      const Titik(400, 456),
      const Titik(380, 438),
    ]),
    warna: oranye,
  );

  final kiri = _balon(160, 300, 0.44);
  h.tambah(kiri.selubung, warna: kuning, detail: kiri.tali);
  h.tambah(kiri.keranjang, warna: coklat);
  final kanan = _balon(660, 330, 0.5);
  h.tambah(kanan.selubung, warna: unguMuda, detail: kanan.tali);
  h.tambah(kanan.keranjang, warna: coklat);
  final tengah = _balon(250, 470, 0.32);
  h.tambah(tengah.selubung, warna: toska, detail: tengah.tali);
  h.tambah(tengah.keranjang, warna: coklat);
  return h.selesai();
}

/// Balon udara: selubung, keranjang, dan empat tali.
({String selubung, String keranjang, List<Rincian> tali}) _balon(
  double cx,
  double cy,
  double s,
) {
  final selubung = lekuk([
    Titik(cx, cy - 112 * s),
    Titik(cx + 96 * s, cy - 84 * s),
    Titik(cx + 150 * s, cy + 8 * s),
    Titik(cx + 130 * s, cy + 96 * s),
    Titik(cx + 62 * s, cy + 152 * s),
    Titik(cx, cy + 164 * s),
    Titik(cx - 62 * s, cy + 152 * s),
    Titik(cx - 130 * s, cy + 96 * s),
    Titik(cx - 150 * s, cy + 8 * s),
    Titik(cx - 96 * s, cy - 84 * s),
  ]);
  final keranjang = kotakBulat(
    cx - 40 * s,
    cy + 200 * s,
    80 * s,
    62 * s,
    10 * s,
  );
  final tali = [
    for (final dx in [-34.0, -12.0, 12.0, 34.0])
      garis(
        garisPatah([
          Titik(cx + dx * s, cy + 160 * s),
          Titik(cx + dx * s * 0.9, cy + 200 * s),
        ]),
        w: 5,
      ),
    garis(
      lekuk([
        Titik(cx - 56 * s, cy - 86 * s),
        Titik(cx - 78 * s, cy + 30 * s),
        Titik(cx - 24 * s, cy + 140 * s),
      ], tutup: false),
      w: 4,
    ),
    garis(
      lekuk([
        Titik(cx + 56 * s, cy - 86 * s),
        Titik(cx + 78 * s, cy + 30 * s),
        Titik(cx + 24 * s, cy + 140 * s),
      ], tutup: false),
      w: 4,
    ),
  ];
  return (selubung: selubung, keranjang: keranjang, tali: tali);
}
