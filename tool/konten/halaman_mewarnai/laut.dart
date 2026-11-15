/// Halaman kategori `laut`: ikan badut, gurita, penyu, paus, kapal selam,
/// terumbu karang, dan kepiting.
library;

import 'dart:math' as math;

import 'package:moci/core/content/coloring.dart';

import 'bentuk.dart';

const _air = '#BDE7FF';
const _pasir = '#F3DFA8';

/// Pasir bawah laut yang landai.
const _dasar = 'M0 512C130 492 260 528 400 508C540 488 680 526 800 504V600H0Z';

/// Rumput laut bergelombang yang tumbuh dari [dasar].
String _gulma(double x, double dasar) => lekuk([
  Titik(x - 18, dasar),
  Titik(x - 34, dasar - 60),
  Titik(x - 12, dasar - 110),
  Titik(x - 28, dasar - 158),
  Titik(x + 4, dasar - 188),
  Titik(x + 24, dasar - 150),
  Titik(x + 4, dasar - 100),
  Titik(x + 24, dasar - 50),
  Titik(x + 16, dasar),
]);

String _batu(double cx, double cy, double r) => lekuk([
  Titik(cx - r, cy),
  Titik(cx - r * 0.7, cy - r * 0.8),
  Titik(cx, cy - r),
  Titik(cx + r * 0.8, cy - r * 0.7),
  Titik(cx + r, cy),
  Titik(cx + r * 0.6, cy + r * 0.55),
  Titik(cx - r * 0.6, cy + r * 0.55),
]);

/// Enam halaman bertema laut.
List<ColoringPage> halamanLaut() => [
  _ikanBadut(),
  _gurita(),
  _penyu(),
  _paus(),
  _kapalSelam(),
  _karang(),
  _kepiting(),
];

ColoringPage _ikanBadut() {
  final h = Halaman(
    id: 'laut-ikan-badut',
    kategori: 'laut',
    namaId: 'Ikan Badut',
    namaEn: 'Clownfish',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_gulma(76, 540), warna: hijau);
  h.tambah(_gulma(742, 524), warna: hijauMuda);
  h.tambah(_batu(196, 528, 62), warna: abu);
  h.tambah(karang(664, 522, 76), warna: pink);

  h.tambah(
    elips(400, 300, 168, 120),
    warna: oranye,
    detail: [
      blok(
        lekuk([
          const Titik(306, 194),
          const Titik(330, 300),
          const Titik(306, 406),
        ], tutup: false),
        isi: putih,
        w: 28,
      ),
      blok(
        lekuk([
          const Titik(440, 198),
          const Titik(468, 300),
          const Titik(440, 402),
        ], tutup: false),
        isi: putih,
        w: 24,
      ),
      blok(
        lekuk([
          const Titik(524, 240),
          const Titik(548, 300),
          const Titik(524, 360),
        ], tutup: false),
        isi: putih,
        w: 18,
      ),
      ...mata(const Titik(340, 260), const Titik(400, 260), r: 16),
      garis(
        lekuk([
          const Titik(258, 330),
          const Titik(280, 344),
          const Titik(302, 332),
        ], tutup: false),
        w: 5,
      ),
    ],
  );
  h.tambah(
    poligon([
      const Titik(548, 300),
      const Titik(650, 222),
      const Titik(650, 378),
    ]),
    warna: oranye,
  );
  h.tambah(
    lekuk([
      const Titik(320, 190),
      const Titik(392, 150),
      const Titik(462, 188),
    ]),
    warna: oranye,
  );
  h.tambah(
    lekuk([
      const Titik(330, 410),
      const Titik(392, 452),
      const Titik(452, 408),
    ]),
    warna: oranye,
  );
  h.tambah(
    lekuk([
      const Titik(352, 318),
      const Titik(302, 356),
      const Titik(356, 372),
    ]),
    warna: merah,
  );
  h.tambah(elips(240, 322, 26, 20), warna: merahMuda);

  for (final pos in [
    const Titik(600, 138),
    const Titik(662, 86),
    const Titik(540, 84),
    const Titik(712, 172),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 18), warna: putih);
  }

  final kawan = ikan(140, 160, 48, 30);
  h.tambah(
    kawan.badan,
    warna: kuning,
    detail: [...mata(const Titik(120, 150), const Titik(150, 150), r: 7)],
  );
  h.tambah(kawan.ekor, warna: kuning);
  final kawan2 = ikan(596, 336, 42, 25);
  h.tambah(
    kawan2.badan,
    warna: unguMuda,
    detail: [...mata(const Titik(578, 328), const Titik(606, 328), r: 6)],
  );
  h.tambah(kawan2.ekor, warna: unguMuda);
  return h.selesai();
}

ColoringPage _gurita() {
  final h = Halaman(
    id: 'laut-gurita',
    kategori: 'laut',
    namaId: 'Gurita',
    namaEn: 'Octopus',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_gulma(60, 552), warna: hijau);
  h.tambah(_gulma(752, 540), warna: hijauMuda);
  h.tambah(_batu(716, 520, 58), warna: abu);

  for (var i = 0; i < 8; i++) {
    final kiri = i < 4;
    h.tambah(
      tentakel(
        Titik(300 + i * 28, 318),
        panjang: 198 + (i.isEven ? 0 : 16),
        lebar: 46,
        arah: 1.5708 + (i - 3.5) * 0.17,
        bengkok: kiri ? -0.24 : 0.24,
      ),
      warna: kiri ? unguMuda : merahMuda,
    );
  }

  h.tambah(
    lekuk([
      const Titik(278, 268),
      const Titik(300, 156),
      const Titik(400, 112),
      const Titik(500, 156),
      const Titik(522, 268),
      const Titik(462, 326),
      const Titik(338, 326),
    ]),
    warna: ungu,
    detail: [
      ...mata(const Titik(360, 238), const Titik(440, 238), r: 18),
      garis(
        lekuk([
          const Titik(372, 286),
          const Titik(400, 302),
          const Titik(428, 286),
        ], tutup: false),
        w: 5,
      ),
    ],
  );

  for (final pos in [
    const Titik(620, 150),
    const Titik(684, 96),
    const Titik(560, 96),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 18), warna: putih);
  }
  h.tambah(bintangLaut(150, 520, 44), warna: oranye);
  return h.selesai();
}

ColoringPage _penyu() {
  final h = Halaman(
    id: 'laut-penyu',
    kategori: 'laut',
    namaId: 'Penyu',
    namaEn: 'Sea Turtle',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_gulma(64, 546), warna: hijauMuda);
  h.tambah(_gulma(736, 534), warna: hijau);

  // Sirip dulu supaya pangkalnya tertutup perisai.
  h.tambah(
    lekuk([
      const Titik(310, 236),
      const Titik(216, 152),
      const Titik(142, 150),
      const Titik(194, 228),
      const Titik(262, 264),
    ]),
    warna: hijauMuda,
  );
  h.tambah(
    lekuk([
      const Titik(520, 224),
      const Titik(602, 142),
      const Titik(674, 140),
      const Titik(632, 216),
      const Titik(562, 260),
    ]),
    warna: hijauMuda,
  );
  h.tambah(
    lekuk([
      const Titik(330, 404),
      const Titik(268, 476),
      const Titik(218, 496),
      const Titik(292, 470),
      const Titik(352, 434),
    ]),
    warna: hijauMuda,
  );
  h.tambah(
    lekuk([
      const Titik(512, 404),
      const Titik(574, 476),
      const Titik(624, 496),
      const Titik(550, 470),
      const Titik(490, 434),
    ]),
    warna: hijauMuda,
  );
  h.tambah(
    poligon([
      const Titik(586, 316),
      const Titik(642, 300),
      const Titik(642, 334),
    ]),
    warna: hijauMuda,
  );

  h.tambah(
    lekuk([
      const Titik(252, 300),
      const Titik(238, 244),
      const Titik(196, 226),
      const Titik(154, 254),
      const Titik(166, 312),
      const Titik(216, 334),
    ]),
    warna: hijau,
    detail: [
      ...mata(const Titik(184, 272), const Titik(218, 272), r: 10),
      garis(
        lekuk([
          const Titik(172, 314),
          const Titik(196, 326),
          const Titik(220, 314),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  h.tambah(elips(410, 312, 182, 150), warna: hijau);
  for (final pelat in [
    (const Titik(410, 312), 48.0),
    (const Titik(410, 232), 34.0),
    (const Titik(326, 320), 34.0),
    (const Titik(494, 320), 34.0),
    (const Titik(410, 400), 34.0),
  ]) {
    h.tambah(_segienam(pelat.$1, pelat.$2), warna: hijauMuda);
  }

  for (final pos in [
    const Titik(140, 120),
    const Titik(200, 82),
    const Titik(88, 72),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 16), warna: putih);
  }
  h.tambah(bintangLaut(700, 528, 40), warna: pink);
  return h.selesai();
}

String _segienam(Titik pusat, double r) {
  final titik = <Titik>[];
  for (var i = 0; i < 6; i++) {
    final a = i * math.pi / 3 + math.pi / 6;
    titik.add(Titik(pusat.dx + r * math.cos(a), pusat.dy + r * math.sin(a)));
  }
  return poligon(titik);
}

ColoringPage _paus() {
  final h = Halaman(
    id: 'laut-paus',
    kategori: 'laut',
    namaId: 'Paus',
    namaEn: 'Whale',
    latar: _air,
  );
  h.tambah(
    'M0 0H800V92C700 124 600 68 500 96C400 124 300 64 200 92'
    'C120 114 60 84 0 100Z',
    warna: biruMuda,
    detail: [
      garis('M20 40C120 20 200 60 300 38', w: 4),
      garis('M420 34C520 16 600 54 700 30', w: 4),
    ],
  );
  h.tambah(
    lekuk([
      const Titik(198, 330),
      const Titik(246, 214),
      const Titik(400, 178),
      const Titik(562, 206),
      const Titik(628, 292),
      const Titik(574, 398),
      const Titik(400, 436),
      const Titik(252, 410),
    ]),
    warna: biru,
    detail: [
      blok(lingkaran(302, 300, 16)),
      blok(lingkaran(296, 294, 5), isi: putih),
      garis(
        lekuk([
          const Titik(206, 344),
          const Titik(260, 372),
          const Titik(330, 378),
        ], tutup: false),
        w: 5,
      ),
    ],
  );
  h.tambah(
    lekuk([
      const Titik(268, 382),
      const Titik(400, 430),
      const Titik(548, 390),
      const Titik(566, 424),
      const Titik(400, 456),
      const Titik(274, 414),
    ]),
    warna: biruAwan,
  );
  h.tambah(
    lekuk([
      const Titik(600, 300),
      const Titik(694, 236),
      const Titik(742, 266),
      const Titik(664, 332),
    ]),
    warna: biru,
  );
  h.tambah(
    lekuk([
      const Titik(600, 364),
      const Titik(694, 428),
      const Titik(742, 398),
      const Titik(664, 332),
    ]),
    warna: biru,
  );
  h.tambah(
    lekuk([
      const Titik(382, 386),
      const Titik(356, 456),
      const Titik(442, 428),
    ]),
    warna: biru,
  );

  h.tambah(lingkaran(330, 142, 26), warna: putih);
  h.tambah(lingkaran(378, 108, 18), warna: putih);

  // Ubur-ubur kecil di kanan.
  h.tambah(
    lekuk([
      const Titik(676, 300),
      const Titik(688, 254),
      const Titik(738, 254),
      const Titik(750, 300),
      const Titik(712, 310),
    ]),
    warna: pink,
  );
  for (var i = 0; i < 3; i++) {
    h.tambah(
      tentakel(
        Titik(166 + i * 22, 456),
        panjang: 60,
        lebar: 14,
        arah: 1.5708,
        bengkok: i.isEven ? 0.2 : -0.2,
      ),
      warna: pink,
    );
  }

  for (final pos in [const Titik(620, 186), const Titik(560, 150)]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 14), warna: putih);
  }

  final kawan = ikan(180, 190, 42, 26);
  h.tambah(
    kawan.badan,
    warna: kuning,
    detail: [...mata(const Titik(162, 182), const Titik(192, 182), r: 6)],
  );
  h.tambah(kawan.ekor, warna: kuning);
  final kawan2 = ikan(700, 470, 40, 24);
  h.tambah(
    kawan2.badan,
    warna: oranye,
    detail: [...mata(const Titik(684, 464), const Titik(712, 464), r: 6)],
  );
  h.tambah(kawan2.ekor, warna: oranye);
  return h.selesai();
}

ColoringPage _kapalSelam() {
  final h = Halaman(
    id: 'laut-kapal-selam',
    kategori: 'laut',
    namaId: 'Kapal Selam',
    namaEn: 'Submarine',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_gulma(66, 548), warna: hijau);
  h.tambah(_gulma(742, 534), warna: hijauMuda);
  h.tambah(_batu(180, 536, 56), warna: abu);
  h.tambah(karang(680, 540, 62), warna: oranye);

  h.tambah(
    kotakBulat(120, 258, 464, 158, 78),
    warna: kuning,
    detail: [garis('M140 300H560', w: 5), garis('M140 380H560', w: 5)],
  );
  h.tambah('M300 258A70 70 0 0 1 440 258Z', warna: biruMuda);
  h.tambah(kotak(340, 148, 18, 74), warna: abu);
  h.tambah(kotak(340, 148, 58, 18), warna: abu);

  for (final x in [208.0, 320.0, 432.0]) {
    h.tambah(lingkaran(x, 336, 28), warna: biruLangit);
  }

  h.tambah(lingkaran(602, 336, 20), warna: abu);
  h.tambah(elips(640, 292, 24, 52), warna: abu);
  h.tambah(elips(640, 380, 24, 52), warna: abu);

  for (final pos in [
    const Titik(560, 168),
    const Titik(614, 130),
    const Titik(500, 132),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 16), warna: putih);
  }

  final kawan = ikan(180, 180, 44, 28);
  h.tambah(
    kawan.badan,
    warna: merahMuda,
    detail: [...mata(const Titik(160, 170), const Titik(192, 170), r: 7)],
  );
  h.tambah(kawan.ekor, warna: merahMuda);
  final kawan2 = ikan(700, 180, 38, 24);
  h.tambah(
    kawan2.badan,
    warna: unguMuda,
    detail: [...mata(const Titik(684, 172), const Titik(712, 172), r: 6)],
  );
  h.tambah(kawan2.ekor, warna: unguMuda);

  h.tambah(bintangLaut(430, 546, 38), warna: pink);
  return h.selesai();
}

ColoringPage _karang() {
  final h = Halaman(
    id: 'laut-karang',
    kategori: 'laut',
    namaId: 'Terumbu Karang',
    namaEn: 'Coral Reef',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_batu(96, 542, 74), warna: abu);
  h.tambah(_batu(724, 534, 64), warna: abu);
  h.tambah(_gulma(170, 552), warna: hijau);
  h.tambah(_gulma(636, 544), warna: hijauMuda);
  h.tambah(karang(196, 540, 96), warna: pink);
  h.tambah(karang(320, 556, 70), warna: oranye);
  h.tambah(karang(472, 548, 104), warna: ungu);
  h.tambah(karang(596, 560, 62), warna: merahMuda);

  h.tambah(
    elips(690, 520, 48, 34),
    warna: krem,
    detail: [
      garis('M666 506C678 522 700 530 714 520', w: 4),
      garis('M674 494C688 508 704 512 716 504', w: 4),
    ],
  );

  for (final pos in [
    const Titik(120, 180),
    const Titik(180, 120),
    const Titik(90, 100),
  ]) {
    h.tambah(lingkaran(pos.dx, pos.dy, 16), warna: putih);
  }

  final satu = ikan(300, 250, 58, 36);
  h.tambah(
    satu.badan,
    warna: kuning,
    detail: [...mata(const Titik(276, 240), const Titik(312, 240), r: 8)],
  );
  h.tambah(satu.ekor, warna: kuning);
  final dua = ikan(560, 230, 50, 32);
  h.tambah(
    dua.badan,
    warna: merahMuda,
    detail: [...mata(const Titik(538, 222), const Titik(570, 222), r: 7)],
  );
  h.tambah(dua.ekor, warna: merahMuda);
  final tiga = ikan(430, 396, 44, 28);
  h.tambah(
    tiga.badan,
    warna: unguMuda,
    detail: [...mata(const Titik(412, 388), const Titik(440, 388), r: 6)],
  );
  h.tambah(tiga.ekor, warna: unguMuda);
  return h.selesai();
}

ColoringPage _kepiting() {
  final h = Halaman(
    id: 'laut-kepiting',
    kategori: 'laut',
    namaId: 'Kepiting',
    namaEn: 'Crab',
    latar: _air,
  );
  h.tambah(_dasar, warna: _pasir);
  h.tambah(_gulma(70, 546), warna: hijau);
  h.tambah(_gulma(742, 532), warna: hijauMuda);

  for (var i = 0; i < 3; i++) {
    for (final kiri in [true, false]) {
      final akar = Titik(kiri ? 268 : 532, 360 + i * 34);
      h.tambah(
        tentakel(
          akar,
          panjang: 118,
          lebar: 26,
          arah: kiri ? 2.5 + i * 0.16 : 0.64 - i * 0.16,
          bengkok: kiri ? -0.3 : 0.3,
        ),
        warna: merah,
      );
    }
  }

  // Capit: dua bagian per capit.
  for (final kiri in [true, false]) {
    final akar = kiri ? 262.0 : 538.0;
    final arah = kiri ? 3.5 : -0.36;
    final bengkok = kiri ? -0.26 : 0.26;
    h.tambah(
      tentakel(
        Titik(akar, 306),
        panjang: 152,
        lebar: 44,
        arah: arah,
        bengkok: bengkok,
      ),
      warna: merah,
    );
    h.tambah(
      tentakel(
        Titik(akar, 334),
        panjang: 140,
        lebar: 38,
        arah: arah + (kiri ? 0.34 : -0.34),
        bengkok: bengkok,
      ),
      warna: merahMuda,
    );
  }

  h.tambah(
    elips(400, 340, 188, 138),
    warna: merah,
    detail: [
      garis(
        lekuk([
          const Titik(340, 396),
          const Titik(400, 414),
          const Titik(460, 396),
        ], tutup: false),
        w: 5,
      ),
      for (final x in [352.0, 400.0, 448.0])
        garis(
          'M${n(x - 12)} 300C${n(x - 4)} 312 ${n(x + 4)} 312 ${n(x + 12)} 300',
          w: 4,
        ),
    ],
  );

  // Tangkai dan bola mata.
  h.tambah(kotakBulat(348, 214, 20, 52, 8), warna: merahMuda);
  h.tambah(kotakBulat(432, 214, 20, 52, 8), warna: merahMuda);
  h.tambah(
    lingkaran(358, 208, 30),
    warna: putih,
    detail: [
      blok(lingkaran(358, 208, 13)),
      blok(lingkaran(353, 203, 4), isi: putih),
    ],
  );
  h.tambah(
    lingkaran(442, 208, 30),
    warna: putih,
    detail: [
      blok(lingkaran(442, 208, 13)),
      blok(lingkaran(437, 203, 4), isi: putih),
    ],
  );

  h.tambah(bintangLaut(120, 528, 36), warna: oranye);
  h.tambah(
    elips(676, 512, 40, 28),
    warna: krem,
    detail: [
      garis('M650 502C664 514 688 516 702 504', w: 3),
      garis('M654 520C668 530 690 532 702 522', w: 3),
    ],
  );
  return h.selesai();
}
