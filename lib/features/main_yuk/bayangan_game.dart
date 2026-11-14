import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/prefs/app_prefs.dart';

/// Jumlah pilihan menurut tingkat usia.
int bayanganPilihan(AgeLevel usia) => switch (usia) {
  AgeLevel.pemula || AgeLevel.penjelajah => 3,
  AgeLevel.pembaca => 4,
};

/// Ronde satu permainan; enam ronde menuntaskan satu permainan.
const bayanganRonde = 6;

/// Kategori yang dipakai prototipe; sayur tidak dipakai.
const _kategoriBayangan = ['hewan', 'buah', 'kendaraan', 'benda'];

/// Satu ronde Tebak Bayangan: satu target dan pilihan yang memuatnya.
final class BayanganRonde {
  const BayanganRonde({required this.target, required this.pilihan});

  final String target;
  final List<String> pilihan;
}

/// Membuat ronde baru: target acak selain [hindari], lalu pengganggu diambil
/// dari kategori yang sama lebih dulu supaya pilihannya menantang.
BayanganRonde buatBayangan(
  Katalog katalog, {
  required int pilihan,
  required Random random,
  String? hindari,
}) {
  final semua = [
    for (final kategori in _kategoriBayangan) ...katalog.byKategori(kategori),
  ];
  final kandidat = [
    for (final item in semua)
      if (item.id != hindari) item.id,
  ];
  final target = kandidat[random.nextInt(kandidat.length)];
  final kategoriTarget = katalog.byId(target)!.kategori;
  final sekategori = [
    for (final item in semua)
      if (item.id != target && item.kategori == kategoriTarget) item.id,
  ]..shuffle(random);
  final lain = [
    for (final item in semua)
      if (item.id != target && item.kategori != kategoriTarget) item.id,
  ]..shuffle(random);
  final pengganggu = [...sekategori, ...lain].take(pilihan - 1).toList();
  return BayanganRonde(
    target: target,
    pilihan: [target, ...pengganggu]..shuffle(random),
  );
}

/// Aturan main: pilihan salah menandai kartu, pilihan benar membuka ronde,
/// lalu [lanjut] menaikkan skor dan menyiapkan ronde berikutnya.
final class BayanganGame {
  BayanganGame({
    required Katalog katalog,
    required AgeLevel usia,
    required Random random,
  }) : _katalog = katalog,
       _random = random,
       _pilihan = bayanganPilihan(usia),
       _ronde = buatBayangan(
         katalog,
         pilihan: bayanganPilihan(usia),
         random: random,
       );

  final Katalog _katalog;
  final Random _random;
  final int _pilihan;

  final Set<String> _salah = {};
  BayanganRonde _ronde;
  int _skor = 0;
  bool _terbuka = false;

  BayanganRonde get ronde => _ronde;
  int get skor => _skor;
  bool get selesai => _skor >= bayanganRonde;
  bool get terbuka => _terbuka;
  Set<String> get salah => Set.unmodifiable(_salah);

  /// `true` hanya untuk target; pilihan salah ditandai tanpa menutup ronde.
  bool pilih(String id) {
    if (_terbuka) return false;
    if (id != _ronde.target) {
      _salah.add(id);
      return false;
    }
    _terbuka = true;
    return true;
  }

  void lanjut() {
    if (!_terbuka) return;
    _skor += 1;
    _terbuka = false;
    _salah.clear();
    if (selesai) return;
    _ronde = buatBayangan(
      _katalog,
      pilihan: _pilihan,
      random: _random,
      hindari: _ronde.target,
    );
  }
}
