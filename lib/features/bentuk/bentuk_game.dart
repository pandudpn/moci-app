import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/app_prefs.dart';

const bentukRonde = 6;

/// Indeks bentuk katalog yang dipakai tiap tingkat usia.
List<int> bentukPool(AgeLevel level) => switch (level) {
  AgeLevel.pemula => const [0, 1, 2, 6, 7],
  AgeLevel.penjelajah => const [0, 1, 2, 3, 4, 5, 6, 7],
  AgeLevel.pembaca => const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
};

/// Jumlah pilihan di mode Cari: 3, 4, atau 6 mengikuti tingkat usia.
int bentukPilihan(AgeLevel level) => switch (level) {
  AgeLevel.pemula => 3,
  AgeLevel.penjelajah => 4,
  AgeLevel.pembaca => 6,
};

/// Satu ronde Cari: target, pilihan, dan warna tiap pilihan (indeks katalog).
final class BentukRonde {
  const BentukRonde({
    required this.target,
    required this.opsi,
    required this.warna,
  });

  final int target;
  final List<int> opsi;
  final List<({String warna, String gelap})> warna;
}

/// Ronde acak dari pool level usia; [target] memaksa target ronde pertama,
/// [hindari] mencegah bentuk yang baru saja ditanyakan terulang.
BentukRonde buatBentukRonde(
  Katalog katalog, {
  required AgeLevel level,
  required Random random,
  int? hindari,
  int? target,
}) {
  final pool = bentukPool(level);
  final jumlah = bentukPilihan(level);
  var dipilih = target != null && pool.contains(target) ? target : null;
  if (dipilih == null) {
    final calon = [
      for (final i in pool)
        if (i != hindari) i,
    ];
    final dari = calon.isEmpty ? pool : calon;
    dipilih = dari[random.nextInt(dari.length)];
  }
  final pengecoh = [
    for (final i in pool)
      if (i != dipilih) i,
  ]..shuffle(random);
  final opsi = [dipilih, ...pengecoh.take(jumlah - 1)]..shuffle(random);
  final warna = [
    for (final b in katalog.bentuk) (warna: b.warna, gelap: b.gelap),
  ]..shuffle(random);
  return BentukRonde(
    target: dipilih,
    opsi: opsi,
    warna: warna.take(opsi.length).toList(),
  );
}

/// Pertanyaan Cari dengan nama huruf kecil, seperti prototipe.
String pertanyaanBentuk(BentukEntry target, AppLang lang) {
  final nama = target.nama.of(lang).toLowerCase();
  return lang == AppLang.en ? 'Where is the $nama?' : 'Mana $nama?';
}

final class BentukChip {
  const BentukChip({required this.key, this.jumlah});

  /// Kunci ARB; layar yang menerjemahkan.
  final String key;
  final int? jumlah;
}

/// Chip sifat bentuk: sisi/sudut untuk poligon, ujung untuk bintang,
/// lambang sayang untuk hati, dan "tidak punya sudut" untuk bentuk bulat.
List<BentukChip> chipBentuk(BentukEntry bentuk) => switch (bentuk.jenis) {
  'poly' => [
    BentukChip(key: 'bentukSisi', jumlah: bentuk.sisi),
    BentukChip(key: 'bentukSudut', jumlah: bentuk.sudut),
  ],
  'star' => [BentukChip(key: 'bentukUjung', jumlah: bentuk.sudut)],
  'love' => const [BentukChip(key: 'bentukSayang')],
  _ => const [BentukChip(key: 'bentukTanpaSudut')],
};
