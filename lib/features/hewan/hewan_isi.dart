import '../../core/content/katalog.dart';
import '../../core/lang.dart';

/// Kelompok hewan dari katalog. Urutan pil mengikuti artboard.
enum HewanKelompok {
  rumah('rumah', 'hewanGroupRumah'),
  liar('liar', 'hewanGroupLiar'),
  reptil('reptil', 'hewanGroupReptil'),
  air('air', 'hewanGroupAir'),
  kecil('kecil', 'hewanGroupKecil');

  const HewanKelompok(this.id, this.labelKey);

  final String id;
  final String labelKey;
}

/// Hewan berkategori `hewan`, urut seperti katalog; [kelompok] null = semua.
List<Item> hewanTampil(Katalog katalog, {HewanKelompok? kelompok}) => [
  for (final item in katalog.item)
    if (item.hewan != null &&
        (kelompok == null || item.hewan!.kelompok == kelompok.id))
      item,
];

/// Hewan dari [id]; null atau tidak dikenal jatuh ke hewan pertama.
Item? hewanById(Katalog katalog, String? id) {
  final semua = hewanTampil(katalog);
  if (semua.isEmpty) return null;
  if (id != null) {
    for (final item in semua) {
      if (item.id == id) return item;
    }
  }
  return semua.first;
}

String pathSuaraHewan(String id) => 'assets/audio/hewan/$id.m4a';

String bunyiHewan(Item item, AppLang lang) => item.hewan?.bunyi.of(lang) ?? '';

String faktaHewan(Item item, AppLang lang) => item.hewan?.fakta.of(lang) ?? '';

/// Papan nama menyusut untuk nama panjang seperti `Komodo Dragon`.
double ukuranNamaHewan(String nama) {
  if (nama.length > 11) return 38;
  if (nama.length > 8) return 44;
  return 52;
}

/// Gelembung bunyi menyusut untuk tiruan panjang seperti
/// `Cock-a-doodle-doo!`.
double ukuranBunyiHewan(String bunyi) {
  if (bunyi.length > 13) return 26;
  if (bunyi.length > 9) return 32;
  return 40;
}
