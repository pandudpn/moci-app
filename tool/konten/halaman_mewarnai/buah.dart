/// Halaman kategori `buah`: apel, pisang, semangka, stroberi, nanas, wortel.
library;

import 'dart:math' as math;

import 'package:moci/core/content/coloring.dart';

import 'bentuk.dart';

const _langit = '#CDEBFF';

const _tanah = 'M0 512C140 488 300 526 440 506C580 486 700 522 800 500V600H0Z';

/// Enam halaman buah dan sayur.
List<ColoringPage> halamanBuah() => [
  _apel(),
  _pisang(),
  _semangka(),
  _stroberi(),
  _nanas(),
  _wortel(),
];

/// Apel bulat dengan lekuk kecil di pucuk.
String _bentukApel(double cx, double cy, double r) => lekuk([
  Titik(cx, cy - r * 0.86),
  Titik(cx + r * 0.46, cy - r * 0.96),
  Titik(cx + r * 0.96, cy - r * 0.46),
  Titik(cx + r, cy + r * 0.24),
  Titik(cx + r * 0.6, cy + r * 0.9),
  Titik(cx, cy + r),
  Titik(cx - r * 0.6, cy + r * 0.9),
  Titik(cx - r, cy + r * 0.24),
  Titik(cx - r * 0.96, cy - r * 0.46),
  Titik(cx - r * 0.46, cy - r * 0.96),
]);

/// Pisang melengkung dari [x], [y] sepanjang [panjang] menghadap kanan.
String _bentukPisang(
  double x,
  double y,
  double panjang,
  double lebar, {
  double putar = 0,
}) {
  final c = math.cos(putar);
  final s = math.sin(putar);
  Titik p(double dx, double dy) =>
      Titik(x + dx * c - dy * s, y + dx * s + dy * c);
  final akar = p(0, 0);
  final ujung = p(panjang, 0);
  final luar = p(panjang * 0.5, -lebar * 1.7);
  final dalam = p(panjang * 0.5, -lebar * 0.5);
  return 'M${n(akar.dx)} ${n(akar.dy)}'
      'Q${n(luar.dx)} ${n(luar.dy)} ${n(ujung.dx)} ${n(ujung.dy)}'
      'Q${n(dalam.dx)} ${n(dalam.dy)} ${n(akar.dx)} ${n(akar.dy)}Z';
}

String _bentukStroberi(double cx, double cy, double r) => lekuk([
  Titik(cx, cy + r),
  Titik(cx + r * 0.62, cy + r * 0.7),
  Titik(cx + r * 0.92, cy + r * 0.1),
  Titik(cx + r * 0.78, cy - r * 0.5),
  Titik(cx + r * 0.3, cy - r * 0.8),
  Titik(cx, cy - r * 0.66),
  Titik(cx - r * 0.3, cy - r * 0.8),
  Titik(cx - r * 0.78, cy - r * 0.5),
  Titik(cx - r * 0.92, cy + r * 0.1),
  Titik(cx - r * 0.62, cy + r * 0.7),
]);

String _bentukNanas(double cx, double cy, double r) => lekuk([
  Titik(cx, cy + r),
  Titik(cx - r * 0.62, cy + r * 0.72),
  Titik(cx - r * 0.82, cy + r * 0.05),
  Titik(cx - r * 0.6, cy - r * 0.6),
  Titik(cx - r * 0.24, cy - r * 0.9),
  Titik(cx + r * 0.24, cy - r * 0.9),
  Titik(cx + r * 0.6, cy - r * 0.6),
  Titik(cx + r * 0.82, cy + r * 0.05),
  Titik(cx + r * 0.62, cy + r * 0.72),
]);

ColoringPage _apel() {
  final h = Halaman(
    id: 'apel',
    kategori: 'buah',
    namaId: 'Apel',
    namaEn: 'Apple',
    latar: _langit,
  );
  final surya = matahari(690, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(110, 118), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    _bentukApel(400, 330, 172),
    warna: merah,
    detail: [
      ...mata(const Titik(340, 320), const Titik(460, 320), r: 18),
      garis(
        lekuk([
          const Titik(372, 378),
          const Titik(400, 396),
          const Titik(428, 378),
        ], tutup: false),
        w: 5,
      ),
      blok(
        lekuk([
          const Titik(300, 250),
          const Titik(330, 226),
          const Titik(342, 268),
        ]),
        isi: putih,
      ),
    ],
  );
  h.tambah(kotakBulat(388, 118, 24, 62, 10), warna: coklat);
  h.tambah(daun(410, 148, 128, 42, putar: -0.42), warna: hijau);
  h.tambah(daun(388, 132, 108, 36, putar: -2.72), warna: hijauMuda);

  for (final pos in [
    (const Titik(206, 470), 96.0),
    (const Titik(626, 462), 88.0),
  ]) {
    h.tambah(_bentukApel(pos.$1.dx, pos.$1.dy, pos.$2), warna: merahMuda);
    h.tambah(
      kotakBulat(pos.$1.dx - 9, pos.$1.dy - pos.$2 - 26, 18, 34, 8),
      warna: coklat,
    );
  }

  final semakX = semak(46, 548, 38);
  h.tambah(semakX.d, warna: hijau, detail: semakX.detail);
  return h.selesai();
}

ColoringPage _pisang() {
  final h = Halaman(
    id: 'pisang',
    kategori: 'buah',
    namaId: 'Pisang',
    namaEn: 'Bananas',
    latar: _langit,
  );
  final surya = matahari(120, 96, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(560, 106), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);
  h.tambah(elips(404, 470, 240, 56), warna: biruMuda);
  h.tambah(elips(404, 464, 196, 40), warna: biruLangit);

  for (var i = 0; i < 3; i++) {
    h.tambah(
      _bentukPisang(300, 432 - i * 34, 244, 62, putar: -0.1 - i * 0.05),
      warna: kuning,
    );
    h.tambah(kotakBulat(288, 424 - i * 34, 24, 22, 6), warna: hijau);
  }

  for (final pos in [const Titik(160, 522), const Titik(660, 520)]) {
    final kuntum = bunga(pos.dx, pos.dy, r: 24);
    h.tambah(kuntum.kelopak, warna: merahMuda);
    h.tambah(kuntum.tengah, warna: kuning);
  }
  return h.selesai();
}

ColoringPage _semangka() {
  final h = Halaman(
    id: 'semangka',
    kategori: 'buah',
    namaId: 'Semangka',
    namaEn: 'Watermelon',
    latar: _langit,
  );
  final surya = matahari(700, 88, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(96, 116), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah('M120 502A280 280 0 0 1 680 502Z', warna: hijau);
  h.tambah('M150 502A250 250 0 0 1 650 502Z', warna: putih);
  h.tambah(
    'M174 502A226 226 0 0 1 626 502Z',
    warna: merah,
    detail: [
      for (final pos in [
        const Titik(300, 436),
        const Titik(360, 386),
        const Titik(430, 356),
        const Titik(500, 392),
        const Titik(548, 446),
        const Titik(400, 448),
        const Titik(250, 470),
        const Titik(470, 464),
      ])
        blok(elips(pos.dx, pos.dy, 11, 17), isi: tinta),
    ],
  );

  h.tambah(
    elips(140, 480, 74, 74),
    warna: hijau,
    detail: [
      garis('M100 440C120 470 120 500 108 528', w: 4),
      garis('M140 410C152 450 152 490 146 528', w: 4),
      garis('M180 440C170 470 170 502 178 528', w: 4),
    ],
  );
  h.tambah(daun(112, 418, 92, 34, putar: -2.1), warna: hijauMuda);

  final semakX = semak(620, 546, 46);
  h.tambah(semakX.d, warna: hijauMuda, detail: semakX.detail);
  final kuntum = bunga(722, 528, r: 26);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _stroberi() {
  final h = Halaman(
    id: 'stroberi',
    kategori: 'buah',
    namaId: 'Stroberi',
    namaEn: 'Strawberry',
    latar: _langit,
  );
  final surya = matahari(140, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(600, 110), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    _bentukStroberi(400, 340, 180),
    warna: merah,
    detail: [
      for (final pos in [
        const Titik(330, 300),
        const Titik(400, 286),
        const Titik(470, 300),
        const Titik(362, 356),
        const Titik(440, 356),
        const Titik(400, 404),
        const Titik(310, 360),
        const Titik(490, 360),
        const Titik(360, 416),
        const Titik(442, 416),
      ])
        blok(elips(pos.dx, pos.dy, 10, 15), isi: krem),
      ...mata(const Titik(352, 258), const Titik(448, 258), r: 16),
      garis(
        lekuk([
          const Titik(376, 312),
          const Titik(400, 328),
          const Titik(424, 312),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  h.tambah(daun(400, 196, 120, 44, putar: -2.6), warna: hijau);
  h.tambah(daun(400, 196, 120, 44, putar: -0.5), warna: hijau);
  h.tambah(daun(400, 196, 92, 38, putar: -1.57), warna: hijauMuda);
  h.tambah(kotakBulat(392, 122, 18, 62, 8), warna: hijau);

  for (final pos in [
    (const Titik(180, 476), 92.0),
    (const Titik(640, 480), 84.0),
  ]) {
    h.tambah(_bentukStroberi(pos.$1.dx, pos.$1.dy, pos.$2), warna: merah);
    h.tambah(
      daun(pos.$1.dx, pos.$1.dy - pos.$2 * 0.7, 70, 26, putar: -1.57),
      warna: hijau,
    );
  }

  final semakX = semak(300, 552, 44);
  h.tambah(semakX.d, warna: hijauMuda, detail: semakX.detail);
  return h.selesai();
}

ColoringPage _nanas() {
  final h = Halaman(
    id: 'nanas',
    kategori: 'buah',
    namaId: 'Nanas',
    namaEn: 'Pineapple',
    latar: _langit,
  );
  final surya = matahari(690, 92, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(104, 112), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    _bentukNanas(400, 360, 178),
    warna: krem,
    detail: [
      garis('M292 420C340 448 460 448 508 420', w: 4),
      garis('M300 460C345 486 455 486 500 460', w: 4),
      garis('M330 500C365 518 435 518 470 500', w: 4),
      ...mata(const Titik(352, 356), const Titik(448, 356), r: 16),
      garis(
        lekuk([
          const Titik(376, 408),
          const Titik(400, 422),
          const Titik(424, 408),
        ], tutup: false),
        w: 4,
      ),
    ],
  );

  for (var i = 0; i < 5; i++) {
    final putar = -2.4 + i * 0.36;
    h.tambah(
      daun(400, 200, 118 - (i % 2) * 18, 34, putar: putar),
      warna: hijau,
    );
  }

  h.tambah(_bentukNanas(168, 512, 74), warna: krem);
  h.tambah(daun(168, 448, 62, 22, putar: -2.2), warna: hijau);
  h.tambah(daun(168, 448, 58, 20, putar: -1.2), warna: hijauMuda);
  final semakX = semak(690, 536, 46);
  h.tambah(semakX.d, warna: hijauMuda, detail: semakX.detail);
  return h.selesai();
}

ColoringPage _wortel() {
  final h = Halaman(
    id: 'wortel',
    kategori: 'buah',
    namaId: 'Wortel',
    namaEn: 'Carrot',
    latar: _langit,
  );
  final surya = matahari(130, 96, 44);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(620, 108), warna: putih);
  h.tambah(_tanah, warna: hijauMuda);

  h.tambah(
    lekuk([
      const Titik(324, 268),
      const Titik(476, 268),
      const Titik(452, 368),
      const Titik(400, 528),
      const Titik(348, 368),
    ]),
    warna: oranye,
    detail: [
      for (final y in [310.0, 352.0, 394.0, 436.0])
        if (y <= 368)
          garis(
            'M${n(400 - (76 - 0.24 * (y - 268)) * 0.8)} ${n(y)}'
            'H${n(400 + (76 - 0.24 * (y - 268)) * 0.8)}',
            w: 4,
          )
        else
          garis(
            'M${n(400 - (52 - 0.325 * (y - 368)) * 0.8)} ${n(y)}'
            'H${n(400 + (52 - 0.325 * (y - 368)) * 0.8)}',
            w: 4,
          ),
    ],
  );
  for (var i = 0; i < 4; i++) {
    h.tambah(
      daun(400, 272, 132 - (i % 2) * 22, 30, putar: -2.5 + i * 0.4),
      warna: i.isEven ? hijau : hijauMuda,
    );
  }

  h.tambah(
    lekuk([
      const Titik(160, 380),
      const Titik(224, 380),
      const Titik(210, 448),
      const Titik(174, 512),
      const Titik(146, 446),
    ]),
    warna: oranye,
  );
  h.tambah(daun(192, 382, 76, 22, putar: -2.2), warna: hijau);
  h.tambah(daun(192, 382, 70, 20, putar: -1.1), warna: hijauMuda);

  h.tambah(
    lekuk([
      const Titik(636, 392),
      const Titik(694, 392),
      const Titik(682, 452),
      const Titik(650, 506),
      const Titik(624, 450),
    ]),
    warna: oranye,
  );
  h.tambah(daun(664, 394, 70, 20, putar: -2.3), warna: hijauMuda);
  h.tambah(daun(664, 394, 64, 18, putar: -1.0), warna: hijau);

  final semakX = semak(313, 550, 46);
  h.tambah(semakX.d, warna: hijauMuda, detail: semakX.detail);
  return h.selesai();
}
