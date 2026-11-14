abstract final class Routes {
  static const splash = '/splash';
  static const sambutan = '/sambutan';
  static const beranda = '/';
  static const huruf = '/huruf';
  static const hurufTulis = '/huruf/tulis';
  static const hurufUcapkan = '/huruf/ucapkan';
  static const angka = '/angka';
  static const angkaTulis = '/angka/tulis';
  static const hewan = '/hewan';
  static const buahSayur = '/buah-sayur';
  static const warna = '/warna';
  static const bentuk = '/bentuk';
  static const musik = '/musik';
  static const sukuKata = '/membaca/suku-kata';
  static const susunKata = '/membaca/susun-kata';
  static const kalimat = '/membaca/kalimat';
  static const mainYuk = '/main';
  static const cocokkan = '/main/cocokkan';
  static const memori = '/main/memori';
  static const bayangan = '/main/bayangan';
  static const puzzle = '/main/puzzle';
  static const balon = '/main/balon';
  static const besarKecil = '/main/besar-kecil';
  static const mewarnai = '/mewarnai';
  static const mewarnaiHalaman = '/mewarnai/:halaman';
  static const karyaku = '/karyaku';
  static const hebat = '/hebat';
  static const istirahat = '/istirahat';
  static const habis = '/habis';
  static const gerbang = '/gerbang';
  static const orangTua = '/orang-tua';

  /// Gerbang Orang Tua dengan tujuan lanjutan.
  static String gerbangLanjut(String target) =>
      '$gerbang?lanjut=${Uri.encodeComponent(target)}';
}

/// Rute yang boleh menjadi tujuan `lanjut` gerbang.
///
/// Sengaja rute konten saja: tanpa Splash dan Sambutan (buntu/intro), tanpa
/// Gerbang sendiri (lingkar), tanpa Waktu Habis dan Istirahat (layar
/// pengatur waktu), dan tanpa `/hebat` (butuh `extra`).
const _ruteLanjut = {
  Routes.beranda,
  Routes.huruf,
  Routes.hurufTulis,
  Routes.hurufUcapkan,
  Routes.angka,
  Routes.angkaTulis,
  Routes.hewan,
  Routes.buahSayur,
  Routes.warna,
  Routes.bentuk,
  Routes.musik,
  Routes.sukuKata,
  Routes.susunKata,
  Routes.kalimat,
  Routes.mainYuk,
  Routes.cocokkan,
  Routes.memori,
  Routes.bayangan,
  Routes.puzzle,
  Routes.balon,
  Routes.besarKecil,
  Routes.mewarnai,
  Routes.karyaku,
  Routes.orangTua,
};

/// Tujuan setelah gerbang: [lanjut] kalau rute internal yang dikenal, selain
/// itu `null` (pemanggil kembali ke Beranda).
String? tujuanLanjut(String? lanjut) {
  if (lanjut == null) return null;
  if (_ruteLanjut.contains(lanjut)) return lanjut;
  // Halaman mewarnai memakai segmen: `/mewarnai/3`.
  const awalan = '${Routes.mewarnai}/';
  if (!lanjut.startsWith(awalan)) return null;
  final halaman = lanjut.substring(awalan.length);
  return halaman.isEmpty || halaman.contains('/') ? null : lanjut;
}

enum RouteKind { intro, play, parent, timer }

/// Jenis rute (D14): menentukan apakah waktu bermain dihitung.
RouteKind routeKindOf(String path) => switch (path) {
  Routes.splash || Routes.sambutan => RouteKind.intro,
  Routes.gerbang || Routes.orangTua => RouteKind.parent,
  Routes.istirahat || Routes.habis => RouteKind.timer,
  _ => RouteKind.play,
};
