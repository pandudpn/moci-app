// Sengaja tanpa impor Flutter: validator konten (Rencana 02) ikut membaca berkas ini.

/// Tema stiker, berurutan seperti di [stickerCatalog].
const List<String> stickerThemes = [
  'hewan',
  'buah',
  'sayur',
  'kendaraan',
  'benda',
];

/// Banyak stiker per tema.
const int stickersPerTheme = 6;

/// 30 stiker hadiah (D10): 6 per tema, urut per tema. Id sama dengan nama
/// berkas `assets/illustrations/<id>.svg` dan kunci ARB `stiker_<id>`.
const List<String> stickerCatalog = [
  // hewan
  'kucing', 'ikan', 'singa', 'gajah', 'panda', 'pinguin',
  // buah
  'apel', 'pisang', 'stroberi', 'semangka', 'nanas', 'buahnaga',
  // sayur
  'wortel', 'tomat', 'brokoli', 'jagung', 'labu', 'jamur',
  // kendaraan
  'mobil', 'bus', 'kereta', 'pesawat', 'kapal', 'roket',
  // benda
  'bola', 'balon', 'kado', 'eskrim', 'layang', 'payung',
];

/// Tema dari [id], atau `null` bila bukan stiker katalog.
String? stickerThemeOf(String id) {
  final i = stickerCatalog.indexOf(id);
  return i < 0 ? null : stickerThemes[i ~/ stickersPerTheme];
}
