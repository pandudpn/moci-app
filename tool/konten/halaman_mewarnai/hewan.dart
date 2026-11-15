/// Halaman kategori `hewan`: singa, jerapah, panda, kelinci, sapi, bebek.
library;

import 'package:moci/core/content/coloring.dart';

import 'bentuk.dart';

const _langit = '#CDEBFF';

/// Tanah landai di bawah semua halaman hewan.
const _tanah = 'M0 512C140 488 300 526 440 506C580 486 700 522 800 500V600H0Z';

/// Enam halaman hewan baru.
List<ColoringPage> halamanHewan() => [
  _singa(),
  _jerapah(),
  _panda(),
  _kelinci(),
  _sapi(),
  _bebek(),
];

ColoringPage _singa() {
  final h = Halaman(
    id: 'singa',
    kategori: 'hewan',
    namaId: 'Singa',
    namaEn: 'Lion',
    latar: _langit,
  );
  final surya = matahari(700, 92, 46);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(76, 116), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(gerigi(400, 306, 206, gigi: 14, dalam: 0.84), warna: oranye);
  h.tambah(lingkaran(270, 196, 42), warna: oranye);
  h.tambah(lingkaran(530, 196, 42), warna: oranye);
  h.tambah(lingkaran(270, 196, 22), warna: krem);
  h.tambah(lingkaran(530, 196, 22), warna: krem);

  h.tambah(
    lekuk([
      const Titik(400, 190),
      const Titik(478, 212),
      const Titik(508, 300),
      const Titik(478, 388),
      const Titik(400, 420),
      const Titik(322, 388),
      const Titik(292, 300),
      const Titik(322, 212),
    ]),
    warna: krem,
    detail: [
      ...mata(const Titik(352, 296), const Titik(448, 296), r: 16),
      garis(
        lekuk([
          const Titik(352, 268),
          const Titik(372, 260),
          const Titik(390, 268),
        ], tutup: false),
        w: 4,
      ),
      garis(
        lekuk([
          const Titik(410, 268),
          const Titik(428, 260),
          const Titik(448, 268),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  h.tambah(
    elips(400, 354, 76, 50),
    warna: putih,
    detail: [
      garis(
        lekuk([
          const Titik(400, 354),
          const Titik(384, 380),
          const Titik(362, 374),
        ], tutup: false),
        w: 4,
      ),
      garis(
        lekuk([
          const Titik(400, 354),
          const Titik(416, 380),
          const Titik(438, 374),
        ], tutup: false),
        w: 4,
      ),
      for (final y in [340.0, 360.0]) garis('M324 ${n(y)}H260', w: 4),
      for (final y in [340.0, 360.0]) garis('M476 ${n(y)}H540', w: 4),
    ],
  );
  h.tambah(
    poligon([
      const Titik(372, 328),
      const Titik(428, 328),
      const Titik(400, 352),
    ]),
    warna: coklat,
  );
  h.tambah(lingkaran(318, 350, 20), warna: merahMuda);
  h.tambah(lingkaran(482, 350, 20), warna: merahMuda);

  for (final pos in [const Titik(150, 526), const Titik(654, 520)]) {
    final kuntum = bunga(pos.dx, pos.dy, r: 26);
    h.tambah(kuntum.kelopak, warna: pink);
    h.tambah(kuntum.tengah, warna: kuning);
  }
  final semakX = semak(69, 534, 50);
  h.tambah(semakX.d, warna: hijau, detail: semakX.detail);
  return h.selesai();
}

ColoringPage _jerapah() {
  final h = Halaman(
    id: 'jerapah',
    kategori: 'hewan',
    namaId: 'Jerapah',
    namaEn: 'Giraffe',
    latar: _langit,
  );
  final surya = matahari(120, 96, 46);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(560, 108), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    kotakBulat(338, 300, 124, 300, 46),
    warna: kuning,
    detail: [
      blok(elips(376, 372, 26, 34), isi: coklat),
      blok(elips(428, 442, 30, 26), isi: coklat),
      blok(elips(384, 506, 24, 30), isi: coklat),
    ],
  );
  h.tambah(
    lekuk([
      const Titik(400, 162),
      const Titik(500, 190),
      const Titik(526, 272),
      const Titik(470, 332),
      const Titik(330, 332),
      const Titik(274, 272),
      const Titik(300, 190),
    ]),
    warna: kuning,
    detail: [
      blok(elips(452, 214, 28, 22), isi: coklat),
      blok(elips(336, 248, 22, 18), isi: coklat),
      ...mata(const Titik(356, 246), const Titik(448, 246), r: 14),
    ],
  );

  h.tambah(
    lekuk([
      const Titik(302, 200),
      const Titik(238, 158),
      const Titik(226, 198),
      const Titik(276, 226),
    ]),
    warna: kuning,
  );
  h.tambah(
    lekuk([
      const Titik(498, 200),
      const Titik(562, 158),
      const Titik(574, 198),
      const Titik(524, 226),
    ]),
    warna: kuning,
  );

  h.tambah(kotakBulat(324, 132, 24, 60, 10), warna: kuning);
  h.tambah(kotakBulat(452, 132, 24, 60, 10), warna: kuning);
  h.tambah(lingkaran(336, 126, 18), warna: coklat);
  h.tambah(lingkaran(464, 126, 18), warna: coklat);

  h.tambah(
    elips(400, 306, 64, 46),
    warna: krem,
    detail: [
      blok(lingkaran(382, 296, 6)),
      blok(lingkaran(418, 296, 6)),
      garis(
        lekuk([
          const Titik(378, 316),
          const Titik(400, 328),
          const Titik(422, 316),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  final kuntum = bunga(686, 520, r: 26);
  h.tambah(kuntum.kelopak, warna: merahMuda);
  h.tambah(kuntum.tengah, warna: kuning);
  final semakX = semak(83, 526, 50);
  h.tambah(semakX.d, warna: hijau, detail: semakX.detail);
  return h.selesai();
}

ColoringPage _panda() {
  final h = Halaman(
    id: 'panda',
    kategori: 'hewan',
    namaId: 'Panda',
    namaEn: 'Panda',
    latar: _langit,
  );
  h.tambah(awan(90, 120), warna: putih);
  h.tambah(awan(590, 92, skala: 0.8), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  // Bambu di kedua sisi.
  for (final x in [96.0, 668.0]) {
    h.tambah(kotakBulat(x, 150, 26, 400, 12), warna: hijau);
    h.tambah(daun(x + 4, 230, 88, 30, putar: 3.6), warna: hijauMuda);
    h.tambah(daun(x + 22, 330, 84, 28, putar: 0.5), warna: hijauMuda);
  }

  h.tambah(lingkaran(282, 190, 54), warna: tinta);
  h.tambah(lingkaran(518, 190, 54), warna: tinta);
  h.tambah(
    lekuk([
      const Titik(296, 430),
      const Titik(504, 430),
      const Titik(528, 530),
      const Titik(400, 570),
      const Titik(272, 530),
    ]),
    warna: putih,
  );
  h.tambah(elips(400, 320, 170, 152), warna: putih);
  h.tambah(elips(336, 306, 54, 42), warna: tinta);
  h.tambah(elips(464, 306, 54, 42), warna: tinta);
  h.tambah(
    elips(400, 398, 68, 48),
    warna: putih,
    detail: [
      garis(
        lekuk([
          const Titik(400, 390),
          const Titik(388, 418),
          const Titik(366, 412),
        ], tutup: false),
        w: 4,
      ),
      garis(
        lekuk([
          const Titik(400, 390),
          const Titik(412, 418),
          const Titik(434, 412),
        ], tutup: false),
        w: 4,
      ),
    ],
  );
  h.tambah(elips(252, 480, 62, 46), warna: tinta);
  h.tambah(elips(548, 480, 62, 46), warna: tinta);
  h.tambah(
    poligon([
      const Titik(370, 372),
      const Titik(430, 372),
      const Titik(400, 400),
    ]),
    warna: tinta,
  );
  return h.selesai();
}

ColoringPage _kelinci() {
  final h = Halaman(
    id: 'kelinci',
    kategori: 'hewan',
    namaId: 'Kelinci',
    namaEn: 'Rabbit',
    latar: _langit,
  );
  final surya = matahari(690, 100, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(120, 116), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    lekuk([
      const Titik(300, 300),
      const Titik(292, 172),
      const Titik(330, 96),
      const Titik(374, 156),
      const Titik(372, 288),
    ]),
    warna: putih,
  );
  h.tambah(
    lekuk([
      const Titik(500, 300),
      const Titik(508, 172),
      const Titik(470, 96),
      const Titik(426, 156),
      const Titik(428, 288),
    ]),
    warna: putih,
  );
  h.tambah(elips(334, 190, 22, 74), warna: merahMuda);
  h.tambah(elips(466, 190, 22, 74), warna: merahMuda);

  h.tambah(
    lekuk([
      const Titik(292, 420),
      const Titik(508, 420),
      const Titik(536, 518),
      const Titik(400, 566),
      const Titik(264, 518),
    ]),
    warna: putih,
  );

  h.tambah(
    lekuk([
      const Titik(400, 196),
      const Titik(500, 226),
      const Titik(556, 320),
      const Titik(512, 420),
      const Titik(400, 456),
      const Titik(288, 420),
      const Titik(244, 320),
      const Titik(300, 226),
    ]),
    warna: putih,
    detail: [...mata(const Titik(348, 314), const Titik(452, 314), r: 16)],
  );

  h.tambah(lingkaran(364, 396, 42), warna: putih);
  h.tambah(lingkaran(436, 396, 42), warna: putih);
  h.tambah(
    poligon([
      const Titik(380, 360),
      const Titik(420, 360),
      const Titik(400, 386),
    ]),
    warna: merahMuda,
  );
  h.tambah(kotakBulat(384, 404, 15, 34, 5), warna: putih);
  h.tambah(kotakBulat(401, 404, 15, 34, 5), warna: putih);
  h.tambah(kotakBulat(390, 404, 20, 26, 6), warna: merahMuda);

  final semakX = semak(74, 534, 50);
  h.tambah(semakX.d, warna: hijau, detail: semakX.detail);
  final kuntum = bunga(660, 522, r: 26);
  h.tambah(kuntum.kelopak, warna: unguMuda);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _sapi() {
  final h = Halaman(
    id: 'sapi',
    kategori: 'hewan',
    namaId: 'Sapi',
    namaEn: 'Cow',
    latar: _langit,
  );
  final surya = matahari(150, 96, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(600, 108), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    lekuk([
      const Titik(316, 210),
      const Titik(270, 156),
      const Titik(232, 138),
      const Titik(246, 186),
      const Titik(300, 226),
    ]),
    warna: krem,
  );
  h.tambah(
    lekuk([
      const Titik(484, 210),
      const Titik(530, 156),
      const Titik(568, 138),
      const Titik(554, 186),
      const Titik(500, 226),
    ]),
    warna: krem,
  );
  h.tambah(elips(238, 262, 62, 38), warna: merahMuda);
  h.tambah(elips(562, 262, 62, 38), warna: merahMuda);

  h.tambah(
    lekuk([
      const Titik(302, 432),
      const Titik(498, 432),
      const Titik(522, 528),
      const Titik(400, 566),
      const Titik(278, 528),
    ]),
    warna: putih,
  );

  h.tambah(
    lekuk([
      const Titik(400, 194),
      const Titik(508, 224),
      const Titik(566, 320),
      const Titik(524, 430),
      const Titik(400, 462),
      const Titik(276, 430),
      const Titik(234, 320),
      const Titik(292, 224),
    ]),
    warna: putih,
    detail: [
      blok(
        lekuk([
          const Titik(322, 236),
          const Titik(376, 250),
          const Titik(360, 300),
          const Titik(300, 288),
        ]),
        isi: tinta,
      ),
      blok(
        lekuk([
          const Titik(452, 226),
          const Titik(494, 214),
          const Titik(488, 256),
          const Titik(446, 258),
        ]),
        isi: tinta,
      ),
      ...mata(const Titik(338, 322), const Titik(462, 322), r: 15),
    ],
  );

  h.tambah(
    elips(400, 396, 108, 62),
    warna: merahMuda,
    detail: [
      blok(lingkaran(366, 392, 9)),
      blok(lingkaran(434, 392, 9)),
      garis(
        lekuk([
          const Titik(378, 418),
          const Titik(400, 428),
          const Titik(422, 418),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  final kuntum = bunga(646, 300, r: 24);
  h.tambah(kuntum.kelopak, warna: merahMuda);
  h.tambah(kuntum.tengah, warna: kuning);

  final semakX = semak(91, 538, 50);
  h.tambah(semakX.d, warna: hijau, detail: semakX.detail);
  final semakKanan = semak(712, 542, 50);
  h.tambah(semakKanan.d, warna: hijauMuda, detail: semakKanan.detail);
  return h.selesai();
}

ColoringPage _bebek() {
  final h = Halaman(
    id: 'bebek',
    kategori: 'hewan',
    namaId: 'Bebek',
    namaEn: 'Duck',
    latar: _langit,
  );
  final surya = matahari(694, 84, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(116, 104), warna: putih);

  h.tambah(
    kotak(0, 418, 800, 182),
    warna: biruMuda,
    detail: [
      garis(
        lekuk([
          const Titik(40, 470),
          const Titik(160, 458),
          const Titik(280, 470),
        ], tutup: false),
        w: 4,
      ),
      garis(
        lekuk([
          const Titik(470, 540),
          const Titik(600, 528),
          const Titik(730, 540),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  // Anak bebek di belakang.
  h.tambah(lingkaran(642, 520, 44), warna: kuning);
  h.tambah(
    lingkaran(594, 472, 32),
    warna: kuning,
    detail: [blok(lingkaran(584, 464, 6))],
  );
  h.tambah(
    poligon([
      const Titik(562, 468),
      const Titik(524, 478),
      const Titik(562, 488),
    ]),
    warna: oranye,
  );
  h.tambah(lingkaran(736, 552, 34), warna: kuning);
  h.tambah(
    lingkaran(700, 514, 24),
    warna: kuning,
    detail: [blok(lingkaran(692, 508, 5))],
  );
  h.tambah(
    poligon([
      const Titik(676, 510),
      const Titik(648, 518),
      const Titik(676, 526),
    ]),
    warna: oranye,
  );

  h.tambah(
    lekuk([
      const Titik(410, 386),
      const Titik(536, 414),
      const Titik(566, 478),
      const Titik(500, 522),
      const Titik(340, 524),
      const Titik(268, 482),
      const Titik(292, 420),
    ]),
    warna: kuning,
  );
  h.tambah(
    lekuk([
      const Titik(468, 438),
      const Titik(528, 454),
      const Titik(520, 496),
      const Titik(452, 486),
    ]),
    warna: krem,
  );
  h.tambah(
    lingkaran(330, 352, 74),
    warna: kuning,
    detail: [
      blok(lingkaran(306, 338, 12)),
      blok(lingkaran(301, 333, 4), isi: putih),
    ],
  );
  h.tambah(
    poligon([
      const Titik(268, 342),
      const Titik(192, 358),
      const Titik(268, 378),
    ]),
    warna: oranye,
    detail: [garis('M268 360H206', w: 4)],
  );

  h.tambah(elips(160, 560, 62, 24), warna: hijau);
  final kuntum = bunga(160, 540, r: 24);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}
