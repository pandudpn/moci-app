/// Jeda sebelum kata pertama saat narasi belum punya waktu rekaman.
const jedaAwalKata = 420;

/// Tambahan waktu per huruf pada rumus prototipe.
const tambahanPerHuruf = 75;

/// Kata dalam [teks]: pisah pada spasi beruntun, tanda baca ikut.
List<String> kataKalimat(String teks) => [
  for (final bagian in teks.split(RegExp(r'\s+')))
    if (bagian.isNotEmpty) bagian,
];

/// Perkiraan lama satu kata: `420 + 75 × panjang`, termasuk tanda baca.
Duration durasiKata(String kata) =>
    Duration(milliseconds: jedaAwalKata + tambahanPerHuruf * kata.length);

/// Waktu mulai tiap kata.
///
/// Memakai [waktu] rekaman (detik) hanya kalau panjangnya sama dengan jumlah
/// kata dan menaik ketat; selain itu rumus kumulatif prototipe.
List<Duration> waktuMulaiKata({required List<String> kata, List<double>? waktu}) {
  if (kata.isEmpty) return const [];
  if (waktu != null && _layak(waktu, kata.length)) {
    return [
      for (final detik in waktu)
        Duration(milliseconds: (detik * 1000).round()),
    ];
  }
  final mulai = <Duration>[Duration.zero];
  for (var i = 1; i < kata.length; i++) {
    mulai.add(mulai[i - 1] + durasiKata(kata[i - 1]));
  }
  return mulai;
}

bool _layak(List<double> waktu, int jumlahKata) {
  if (waktu.length != jumlahKata) return false;
  for (var i = 1; i < waktu.length; i++) {
    if (waktu[i] <= waktu[i - 1]) return false;
  }
  return true;
}

/// Selesai saat kata terakhir habis dibaca.
Duration totalKata(List<String> kata, List<Duration> mulai) {
  if (kata.isEmpty || mulai.isEmpty) return Duration.zero;
  return mulai.last + durasiKata(kata.last);
}

/// Indeks kata yang sedang dibaca; `-1` kalau tidak ada kata.
int indeksKata(List<Duration> mulai, Duration berlalu) {
  if (mulai.isEmpty) return -1;
  if (berlalu < mulai.first) return 0;
  for (var i = mulai.length - 1; i >= 0; i--) {
    if (mulai[i] <= berlalu) return i;
  }
  return 0;
}
