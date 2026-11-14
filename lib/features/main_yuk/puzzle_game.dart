import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/prefs/app_prefs.dart';

/// Ukuran papan puzzle di panggung tablet.
const puzzleSisi = 480.0;

/// Kisi menurut tingkat usia.
({int kolom, int baris}) puzzleKisi(AgeLevel usia) => switch (usia) {
  AgeLevel.pemula => (kolom: 2, baris: 2),
  AgeLevel.penjelajah => (kolom: 3, baris: 2),
  AgeLevel.pembaca => (kolom: 3, baris: 3),
};

/// Kategori gambar puzzle; sama dengan prototipe.
const _kategoriPuzzle = ['hewan', 'buah', 'kendaraan', 'benda'];

/// Hasil satu ketukan: memilih keping atau meletakkannya.
enum PuzzleStep { pilih, pas, salah, selesai }

/// Aturan main satu ronde: pilih keping di baki, lalu ketuk tempatnya di
/// papan. Slot dihitung dari kiri atas, sebaris demi sebaris.
final class PuzzleGame {
  PuzzleGame({
    required Katalog katalog,
    required AgeLevel usia,
    required Random random,
    String? hindari,
  }) : _kisi = puzzleKisi(usia) {
    _katalog = katalog;
    _random = random;
    _rondeBaru(hindari: hindari);
  }

  late final Katalog _katalog;
  late final Random _random;
  final ({int kolom, int baris}) _kisi;
  final Set<int> _terpasang = {};

  late String _gambar;
  late List<int> _urutan;
  int? _dipilih;

  /// Id ilustrasi yang sedang disusun.
  String get gambar => _gambar;
  int get kolom => _kisi.kolom;
  int get baris => _kisi.baris;
  int get jumlah => kolom * baris;

  /// Keping di baki, urut tampil; keping terpasang tidak lagi di sini.
  List<int> get urutan => List.unmodifiable(_urutan);
  Set<int> get terpasang => Set.unmodifiable(_terpasang);
  int? get dipilih => _dipilih;
  bool get selesai => _terpasang.length == jumlah;

  void _rondeBaru({String? hindari}) {
    final semua = [
      for (final kategori in _kategoriPuzzle) ..._katalog.byKategori(kategori),
    ];
    final kandidat = [
      for (final item in semua)
        if (item.id != hindari) item.id,
    ];
    _gambar = kandidat[_random.nextInt(kandidat.length)];
    _terpasang.clear();
    _dipilih = null;
    _urutan = [for (var i = 0; i < jumlah; i++) i]..shuffle(_random);
  }

  PuzzleStep pilih(int keping) {
    if (_terpasang.contains(keping)) return PuzzleStep.pilih;
    _dipilih = keping;
    return PuzzleStep.pilih;
  }

  PuzzleStep letak(int slot) {
    final keping = _dipilih;
    if (keping == null) return PuzzleStep.pilih;
    if (slot != keping) return PuzzleStep.salah;
    _terpasang.add(keping);
    _dipilih = null;
    _urutan.remove(keping);
    return selesai ? PuzzleStep.selesai : PuzzleStep.pas;
  }

  /// Ronde baru dengan gambar lain; keping terpasang dikosongkan.
  void ulang() => _rondeBaru(hindari: _gambar);
}
