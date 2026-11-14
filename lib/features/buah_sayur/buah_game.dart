import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/lang.dart';

const buahRonde = 6;
const buahPilihan = 3;

final class BuahSoal {
  const BuahSoal({required this.target, required this.pilihan});

  final Item target;
  final List<Item> pilihan;
}

List<Item> _pool(Katalog katalog, String? kategori) => [
  for (final item in katalog.item)
    if ((item.kategori == 'buah' || item.kategori == 'sayur') &&
        (kategori == null || item.kategori == kategori))
      item,
];

/// Soal Tebak: target yang diminta (atau acak selain [hindari]) plus dua
/// pengecoh dari pool yang sama, lalu diacak.
BuahSoal buatBuahSoal(
  Katalog katalog, {
  String? kategori,
  String? target,
  String? hindari,
  required Random random,
}) {
  final pool = _pool(katalog, kategori);
  Item? dipilih;
  if (target != null) {
    for (final item in pool) {
      if (item.id == target) dipilih = item;
    }
  }
  if (dipilih == null) {
    final calon = [
      for (final item in pool)
        if (item.id != hindari) item,
    ];
    dipilih = calon[random.nextInt(calon.length)];
  }
  final pengecoh = [
    for (final item in pool)
      if (item.id != dipilih.id) item,
  ]..shuffle(random);
  return BuahSoal(
    target: dipilih,
    pilihan: [dipilih, ...pengecoh.take(buahPilihan - 1)]..shuffle(random),
  );
}

bool jawabanBuah(Item target, Item dipilih) => target.id == dipilih.id;

String namaBuah(Item item, AppLang lang) => item.nama.of(lang);

/// Nama panjang di kotak pertanyaan menyusut satu tingkat.
double ukuranSoalBuah(String nama) => nama.length > 10 ? 36 : 44;

/// Nama panjang di kartu Kenali menyusut satu tingkat.
double ukuranKartuBuah(String nama) => nama.length > 11 ? 18 : 22;
