import '../../core/content/katalog.dart';
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
