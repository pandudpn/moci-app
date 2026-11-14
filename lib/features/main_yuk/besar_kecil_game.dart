import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/prefs/app_prefs.dart';

/// Enam ronde menuntaskan satu permainan.
const besarKecilRonde = 6;

/// Ukuran gambar (pt) menurut tingkat usia.
List<double> ukuranBesarKecil(AgeLevel usia) => switch (usia) {
  AgeLevel.pemula || AgeLevel.penjelajah => [120, 200, 300],
  AgeLevel.pembaca => [150, 200, 250, 300],
};

/// Kategori gambar; sama dengan permainan lain di Main Yuk.
const _kategoriBesarKecil = ['hewan', 'buah', 'kendaraan', 'benda'];

/// Satu ronde Besar & Kecil: satu gambar dengan tiga atau empat ukuran.
final class BesarKecilRonde {
  const BesarKecilRonde({
    required this.gambar,
    required this.termuda,
    required this.ukuran,
  });

  final String gambar;

  /// `true` berarti ditanya yang paling besar.
  final bool termuda;
  final List<double> ukuran;

  double get jawaban => ukuran.reduce(termuda ? max : min);
}

/// Membuat ronde baru: pertanyaan bergantian dari [tanyaSebelumnya], gambar
/// selain [hindari], dan ukuran yang diacak.
BesarKecilRonde buatBesarKecil(
  Katalog katalog, {
  required AgeLevel usia,
  required bool? tanyaSebelumnya,
  required Random random,
  String? hindari,
}) {
  final semua = [
    for (final kategori in _kategoriBesarKecil) ...katalog.byKategori(kategori),
  ];
  final kandidat = [
    for (final item in semua)
      if (item.id != hindari) item.id,
  ];
  return BesarKecilRonde(
    gambar: kandidat[random.nextInt(kandidat.length)],
    termuda: !(tanyaSebelumnya ?? false),
    ukuran: ukuranBesarKecil(usia)..shuffle(random),
  );
}

/// Aturan main: ketuk gambar dengan ukuran terjawab, lalu lanjut.
final class BesarKecilGame {
  BesarKecilGame({
    required Katalog katalog,
    required AgeLevel usia,
    required Random random,
  }) : _katalog = katalog,
       _usia = usia,
       _random = random,
       _ronde = buatBesarKecil(
         katalog,
         usia: usia,
         tanyaSebelumnya: null,
         random: random,
       );

  final Katalog _katalog;
  final AgeLevel _usia;
  final Random _random;

  BesarKecilRonde _ronde;
  int _skor = 0;

  BesarKecilRonde get ronde => _ronde;
  int get skor => _skor;
  bool get selesai => _skor >= besarKecilRonde;

  /// `true` hanya untuk ukuran yang ditanyakan.
  bool pilih(int indeks) {
    if (indeks < 0 || indeks >= _ronde.ukuran.length) return false;
    return _ronde.ukuran[indeks] == _ronde.jawaban;
  }

  void lanjut() {
    _skor += 1;
    if (selesai) return;
    _ronde = buatBesarKecil(
      _katalog,
      usia: _usia,
      tanyaSebelumnya: _ronde.termuda,
      random: _random,
      hindari: _ronde.gambar,
    );
  }
}
