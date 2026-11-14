import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/prefs/app_prefs.dart';
import 'main_yuk_game.dart';

/// Jumlah pasangan menurut tingkat usia.
int memoriPasangan(AgeLevel usia) => switch (usia) {
  AgeLevel.pemula => 4,
  AgeLevel.penjelajah => 6,
  AgeLevel.pembaca => 8,
};

/// Satu ronde Kartu Memori: id benda teracak, setiap id muncul dua kali.
final class MemoriRonde {
  const MemoriRonde({required this.tema, required this.deck});

  final MainYukTema tema;
  final List<String> deck;

  int get pasangan => deck.length ~/ 2;
}

/// Membuat ronde baru dari [tema] (atau tema acak selain [sebelumnya]) lalu
/// menggandakan setiap id dan mengacaknya.
MemoriRonde buatMemori(
  Katalog katalog, {
  required int pasangan,
  required MainYukTema tema,
  required Random random,
  MainYukTema? sebelumnya,
}) {
  final pilih = pilihTema(katalog, tema, random: random, hindari: sebelumnya);
  final id = [for (final item in pilih.item) item.id];
  // Kategori bisa kurang dari jumlah pasangan; lengkapi dari isi lain.
  for (final item in katalog.item) {
    if (id.length >= pasangan) break;
    if (!id.contains(item.id)) id.add(item.id);
  }
  final dipilih = (id..shuffle(random)).take(pasangan).toList();
  return MemoriRonde(
    tema: pilih.tema,
    deck: [...dipilih, ...dipilih]..shuffle(random),
  );
}

/// Hasil satu ketukan pada kartu.
enum MemoriStep { abaikan, terbuka, sepasang, salah, selesai }

/// Aturan main satu ronde: paling banyak dua kartu terbuka, langkah dihitung
/// sekali per percobaan, dan pasangan yang sudah ketemu menetap terbuka.
final class MemoriSesi {
  MemoriSesi(this.ronde);

  final MemoriRonde ronde;

  final List<int> _terbuka = [];
  final Set<String> _ketemu = {};
  int _langkah = 0;

  List<int> get terbuka => List.unmodifiable(_terbuka);
  Set<String> get ketemu => Set.unmodifiable(_ketemu);
  int get langkah => _langkah;
  bool get selesai => _ketemu.length == ronde.pasangan;

  MemoriStep buka(int indeks) {
    if (indeks < 0 || indeks >= ronde.deck.length) return MemoriStep.abaikan;
    final id = ronde.deck[indeks];
    if (_ketemu.contains(id) ||
        _terbuka.contains(indeks) ||
        _terbuka.length == 2) {
      return MemoriStep.abaikan;
    }
    _terbuka.add(indeks);
    if (_terbuka.length == 1) return MemoriStep.terbuka;

    _langkah += 1;
    if (ronde.deck[_terbuka.first] != id) return MemoriStep.salah;
    _ketemu.add(id);
    _terbuka.clear();
    return selesai ? MemoriStep.selesai : MemoriStep.sepasang;
  }

  /// Menutup lagi dua kartu yang salah.
  void tutup() {
    if (_terbuka.length == 2) _terbuka.clear();
  }

  void ulang() {
    _terbuka.clear();
    _ketemu.clear();
    _langkah = 0;
  }
}
