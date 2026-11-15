/// Halaman kategori `kota`: gedung, jalan, taman, toko, stasiun, menara.
library;

import 'package:moci/core/content/coloring.dart';

import 'bentuk.dart';

/// Enam halaman bertema kota.
List<ColoringPage> halamanKota() => [
  _gedung(),
  _jalan(),
  _taman(),
  _toko(),
  _stasiun(),
  _menara(),
];

ColoringPage _gedung() {
  final h = Halaman(
    id: 'kota-gedung',
    kategori: 'kota',
    namaId: 'Gedung Kota',
    namaEn: 'City Buildings',
    latar: biruAwan,
  );
  final surya = matahari(700, 92, 50);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(96, 118), warna: putih);

  // Gedung ungu dengan empat jendela dan satu pintu.
  h.tambah(kotak(60, 200, 150, 290), warna: unguMuda);
  h.tambah(kotakBulat(78, 228, 52, 64, 6), warna: biruMuda);
  h.tambah(kotakBulat(140, 228, 52, 64, 6), warna: biruMuda);
  h.tambah(kotakBulat(78, 318, 52, 64, 6), warna: biruMuda);
  h.tambah(kotakBulat(140, 318, 52, 64, 6), warna: biruMuda);
  h.tambah(
    kotakBulat(104, 414, 62, 76, 8),
    warna: coklat,
    detail: [blok(lingkaran(152, 456, 5))],
  );

  // Gedung hijau dengan tiga jendela.
  h.tambah(kotak(224, 260, 116, 230), warna: hijauMuda);
  h.tambah(kotakBulat(240, 286, 36, 56, 6), warna: biruMuda);
  h.tambah(kotakBulat(288, 286, 36, 56, 6), warna: biruMuda);
  h.tambah(kotakBulat(240, 366, 84, 70, 8), warna: biruMuda);

  // Gedung jingga yang paling tinggi.
  h.tambah(
    kotak(352, 130, 176, 360),
    warna: oranye,
    detail: [garis('M352 178H528', w: 6)],
  );
  h.tambah(kotakBulat(376, 206, 56, 76, 6), warna: biruMuda);
  h.tambah(kotakBulat(452, 206, 56, 76, 6), warna: biruMuda);
  h.tambah(kotakBulat(376, 306, 56, 76, 6), warna: biruMuda);
  h.tambah(kotakBulat(452, 306, 56, 76, 6), warna: biruMuda);
  h.tambah(
    kotakBulat(424, 414, 64, 76, 8),
    warna: coklat,
    detail: [blok(lingkaran(474, 456, 5))],
  );

  // Gedung merah muda di kanan.
  h.tambah(kotak(540, 230, 168, 260), warna: merahMuda);
  h.tambah(kotakBulat(560, 262, 52, 66, 6), warna: biruMuda);
  h.tambah(kotakBulat(622, 262, 52, 66, 6), warna: biruMuda);
  h.tambah(kotakBulat(560, 352, 52, 66, 6), warna: biruMuda);
  h.tambah(kotakBulat(622, 352, 52, 66, 6), warna: biruMuda);

  h.tambah(kotak(0, 490, 800, 26), warna: abuMuda);
  h.tambah(
    kotak(0, 516, 800, 84),
    warna: abu,
    detail: [
      for (var x = 50; x < 780; x += 120)
        blok(
          garisPatah([Titik(x.toDouble(), 558), Titik(x + 64, 558)]),
          isi: kuning,
          w: 10,
        ),
    ],
  );
  return h.selesai();
}

ColoringPage _jalan() {
  final h = Halaman(
    id: 'kota-jalan',
    kategori: 'kota',
    namaId: 'Jalan Raya',
    namaEn: 'City Road',
    latar: biruAwan,
  );
  final surya = matahari(110, 92, 48);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(430, 104), warna: putih);
  h.tambah(awan(620, 150, skala: 0.7), warna: putih);
  h.tambah(
    'M0 330C140 286 300 322 430 300C560 278 680 318 800 300V600H0Z',
    warna: hijauMuda,
    detail: [
      garis('M60 380C160 356 260 380 340 364', w: 4),
      garis('M520 366C600 350 700 372 780 356', w: 4),
    ],
  );

  h.tambah(
    kotak(0, 392, 800, 148),
    warna: abu,
    detail: [
      for (var x = 40; x < 700; x += 150)
        blok(
          garisPatah([Titik(x.toDouble(), 466), Titik(x + 80, 466)]),
          isi: kuning,
          w: 9,
        ),
    ],
  );

  // Mobil merah.
  h.tambah(kotakBulat(110, 414, 240, 92, 24), warna: merah);
  h.tambah(kotakBulat(160, 356, 146, 82, 28), warna: merah);
  h.tambah(
    kotakBulat(182, 374, 102, 48, 12),
    warna: biruMuda,
    detail: [garis('M234 374V422', w: 4)],
  );
  final rodaKiri = roda(168, 508, 30);
  h.tambah(rodaKiri.d, warna: abu, detail: rodaKiri.detail);
  final rodaKanan = roda(298, 508, 30);
  h.tambah(rodaKanan.d, warna: abu, detail: rodaKanan.detail);

  // Truk biru di lajur kanan.
  h.tambah(kotakBulat(500, 368, 84, 130, 18), warna: biru);
  h.tambah(kotakBulat(514, 386, 56, 46, 8), warna: biruLangit);
  h.tambah(
    kotak(572, 400, 156, 98),
    warna: oranye,
    detail: [garis('M572 438H728', w: 4), garis('M572 476H728', w: 4)],
  );
  final trukKiri = roda(540, 508, 28);
  h.tambah(trukKiri.d, warna: abu, detail: trukKiri.detail);
  final trukTengah = roda(632, 508, 28);
  h.tambah(trukTengah.d, warna: abu, detail: trukTengah.detail);
  final trukKanan = roda(696, 508, 28);
  h.tambah(trukKanan.d, warna: abu, detail: trukKanan.detail);

  final tanam = pohon(74, 372, tinggi: 70, lebarTajuk: 104);
  h.tambah(tanam.batang, warna: coklat);
  h.tambah(tanam.tajuk, warna: hijau);

  h.tambah(kotak(740, 296, 14, 116), warna: abu);
  h.tambah(
    kotakBulat(713, 236, 68, 68, 12),
    warna: merah,
    detail: [garis('M727 270H767', w: 10)],
  );

  final kuntum = bunga(400, 350, r: 26);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}

ColoringPage _taman() {
  final h = Halaman(
    id: 'kota-taman',
    kategori: 'kota',
    namaId: 'Taman Kota',
    namaEn: 'City Park',
    latar: biruAwan,
  );
  final surya = matahari(690, 92, 48);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(210, 116), warna: putih);
  h.tambah(
    'M0 400C140 372 300 408 450 390C600 372 700 402 800 386V600H0Z',
    warna: hijauMuda,
  );
  final tanam = pohon(132, 360, tinggi: 96, lebarTajuk: 150);
  h.tambah(tanam.batang, warna: coklat);
  h.tambah(tanam.tajuk, warna: hijau);

  h.tambah(kotakBulat(580, 300, 200, 26, 10), warna: coklat);
  h.tambah(kotakBulat(580, 356, 200, 28, 10), warna: coklat);
  h.tambah(kotak(600, 384, 20, 58), warna: abu);
  h.tambah(kotak(740, 384, 20, 58), warna: abu);

  h.tambah(
    elips(400, 512, 168, 66),
    warna: toska,
    detail: [
      garis('M310 500C340 484 380 484 410 500', w: 4),
      garis('M420 528C452 512 486 512 510 528', w: 4),
    ],
  );
  h.tambah(elips(330, 500, 40, 18), warna: hijau);
  final teratai = bunga(404, 490, r: 22);
  h.tambah(teratai.kelopak, warna: pink);
  h.tambah(teratai.tengah, warna: kuning);

  for (final pos in [
    const Titik(232, 470),
    const Titik(624, 540),
    const Titik(680, 470),
  ]) {
    final kuntum = bunga(pos.dx, pos.dy);
    h.tambah(kuntum.kelopak, warna: merahMuda);
    h.tambah(kuntum.tengah, warna: kuning);
  }

  h.tambah(
    lekuk([
      const Titik(60, 470),
      const Titik(40, 436),
      const Titik(64, 408),
      const Titik(92, 430),
      const Titik(96, 470),
      const Titik(78, 486),
    ]),
    warna: hijau,
  );

  h.tambah(kotak(244, 350, 12, 74), warna: abu);
  h.tambah(lingkaran(250, 330, 24), warna: kuning);
  return h.selesai();
}

ColoringPage _toko() {
  final h = Halaman(
    id: 'kota-toko',
    kategori: 'kota',
    namaId: 'Toko',
    namaEn: 'Shop',
    latar: biruAwan,
  );
  final surya = matahari(92, 84, 42);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(600, 108), warna: putih);
  h.tambah(kotak(0, 470, 800, 130), warna: hijauMuda);

  h.tambah(
    kotakBulat(292, 82, 216, 64, 14),
    warna: putih,
    detail: [garis('M320 114H480', w: 7)],
  );
  h.tambah(
    poligon([
      const Titik(150, 210),
      const Titik(650, 210),
      const Titik(618, 146),
      const Titik(182, 146),
    ]),
    warna: unguMuda,
  );
  h.tambah(kotak(170, 210, 460, 260), warna: krem);

  h.tambah(
    poligon([
      const Titik(170, 250),
      const Titik(630, 250),
      const Titik(612, 300),
      const Titik(188, 300),
    ]),
    warna: merah,
    detail: [
      for (var x = 216; x < 610; x += 74) garis('M$x 250L${x - 12} 300', w: 4),
    ],
  );

  h.tambah(
    kotakBulat(344, 352, 112, 118, 12),
    warna: biru,
    detail: [blok(lingkaran(436, 416, 6))],
  );
  h.tambah(
    kotakBulat(222, 340, 92, 92, 10),
    warna: biruMuda,
    detail: kaca(222, 340, 92, 92, kolom: 2, baris: 2),
  );
  h.tambah(
    kotakBulat(486, 340, 92, 92, 10),
    warna: biruMuda,
    detail: kaca(486, 340, 92, 92, kolom: 2, baris: 2),
  );

  h.tambah(
    poligon([
      const Titik(694, 418),
      const Titik(754, 418),
      const Titik(744, 474),
      const Titik(704, 474),
    ]),
    warna: oranye,
  );
  final kuntum = bunga(724, 390, r: 24);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);

  h.tambah(
    lekuk([
      const Titik(44, 470),
      const Titik(30, 442),
      const Titik(54, 420),
      const Titik(84, 440),
      const Titik(88, 470),
      const Titik(66, 484),
    ]),
    warna: hijau,
  );

  h.tambah(
    kotakBulat(96, 414, 68, 56, 8),
    warna: coklat,
    detail: [garis('M96 438H164', w: 4)],
  );

  const balon = [Titik(680, 296), Titik(720, 240), Titik(760, 296)];
  for (var i = 0; i < balon.length; i++) {
    final pos = balon[i];
    h.tambah(
      lingkaran(pos.dx, pos.dy, 26),
      warna: [merahMuda, kuning, unguMuda][i],
      detail: [
        garis(
          garisPatah([pos + const Titik(0, 26), const Titik(724, 358)]),
          w: 4,
        ),
      ],
    );
  }
  return h.selesai();
}

ColoringPage _stasiun() {
  final h = Halaman(
    id: 'kota-kereta',
    kategori: 'kota',
    namaId: 'Stasiun Kereta',
    namaEn: 'Train Station',
    latar: biruAwan,
  );
  h.tambah(awan(96, 128), warna: putih);
  final surya = matahari(690, 84, 42);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);

  // Bangunan stasiun di belakang.
  h.tambah(kotak(590, 262, 184, 210), warna: kuning);
  h.tambah(
    poligon([
      const Titik(570, 262),
      const Titik(790, 262),
      const Titik(770, 208),
      const Titik(590, 208),
    ]),
    warna: hijau,
  );
  h.tambah(
    lingkaran(682, 312, 36),
    warna: putih,
    detail: [garis('M682 312V288', w: 5), garis('M688 312H706', w: 5)],
  );
  h.tambah(kotakBulat(640, 376, 84, 96, 8), warna: coklat);

  h.tambah(kotak(0, 470, 800, 130), warna: abuMuda);
  h.tambah(kotak(0, 500, 800, 12), warna: abu);
  h.tambah(kotak(0, 524, 800, 12), warna: abu);
  h.tambah(
    kotak(0, 548, 800, 52),
    warna: abuMuda,
    detail: [for (var x = 40; x < 800; x += 110) garis('M$x 470V600', w: 4)],
  );

  // Lokomotif.
  h.tambah(kotakBulat(108, 344, 432, 62, 22), warna: merahMuda);
  h.tambah(kotakBulat(108, 348, 432, 132, 26), warna: merah);
  h.tambah(
    kotakBulat(152, 376, 104, 74, 10),
    warna: biruMuda,
    detail: kaca(152, 376, 104, 74, kolom: 2, baris: 1),
  );
  h.tambah(
    kotakBulat(272, 376, 104, 74, 10),
    warna: biruMuda,
    detail: kaca(272, 376, 104, 74, kolom: 2, baris: 1),
  );
  h.tambah(
    kotakBulat(392, 376, 104, 74, 10),
    warna: biruMuda,
    detail: kaca(392, 376, 104, 74, kolom: 2, baris: 1),
  );
  h.tambah(kotakBulat(424, 264, 58, 88, 14), warna: ungu);
  h.tambah(lingkaran(468, 214, 26), warna: putih);
  h.tambah(lingkaran(508, 172, 20), warna: putih);

  h.tambah(
    poligon([
      const Titik(108, 480),
      const Titik(150, 436),
      const Titik(150, 480),
    ]),
    warna: kuning,
  );
  final roda1 = roda(176, 496, 30);
  h.tambah(roda1.d, warna: abu, detail: roda1.detail);
  final roda2 = roda(300, 496, 30);
  h.tambah(roda2.d, warna: abu, detail: roda2.detail);
  final roda3 = roda(470, 496, 30);
  h.tambah(roda3.d, warna: abu, detail: roda3.detail);

  h.tambah(kotak(56, 348, 12, 122), warna: abu);
  h.tambah(lingkaran(62, 330, 20), warna: kuning);
  return h.selesai();
}

ColoringPage _menara() {
  final h = Halaman(
    id: 'kota-menara',
    kategori: 'kota',
    namaId: 'Menara Jam',
    namaEn: 'Clock Tower',
    latar: biruAwan,
  );
  final surya = matahari(122, 92, 46);
  h.tambah(surya.d, warna: kuning, detail: surya.detail);
  h.tambah(awan(560, 112), warna: putih);
  h.tambah(kotak(0, 500, 800, 100), warna: hijauMuda);

  h.tambah(
    kotak(300, 180, 200, 320),
    warna: krem,
    detail: [garis('M300 330H500', w: 5)],
  );
  h.tambah(
    poligon([
      const Titik(278, 180),
      const Titik(522, 180),
      const Titik(400, 74),
    ]),
    warna: merah,
  );
  h.tambah(kotak(396, 40, 8, 36), warna: abu);
  h.tambah(
    poligon([const Titik(404, 42), const Titik(472, 58), const Titik(404, 74)]),
    warna: kuning,
  );

  h.tambah(
    lingkaran(400, 244, 58),
    warna: putih,
    detail: [
      garis('M400 244V210', w: 6),
      garis('M400 244H428', w: 6),
      garis(lingkaran(400, 244, 58), w: 4),
    ],
  );

  h.tambah(kotakBulat(336, 322, 42, 62, 8), warna: biruMuda);
  h.tambah(kotakBulat(422, 322, 42, 62, 8), warna: biruMuda);
  h.tambah(kotakBulat(336, 410, 42, 26, 10), warna: unguMuda);
  h.tambah(kotakBulat(422, 410, 42, 26, 10), warna: unguMuda);
  h.tambah(kotakBulat(366, 434, 68, 66, 10), warna: coklat);

  final kiri = pohon(150, 460, tinggi: 60, lebarTajuk: 118);
  h.tambah(kiri.batang, warna: coklat);
  h.tambah(kiri.tajuk, warna: hijau);
  final kanan = pohon(650, 460, tinggi: 60, lebarTajuk: 118);
  h.tambah(kanan.batang, warna: coklat);
  h.tambah(kanan.tajuk, warna: hijau);

  final kuntum = bunga(232, 540, r: 24);
  h.tambah(kuntum.kelopak, warna: pink);
  h.tambah(kuntum.tengah, warna: kuning);
  return h.selesai();
}
