import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/prefs/app_prefs.dart';
import 'main_yuk_game.dart';

/// Sisi papan Cocokkan.
enum CocokkanSisi { kiri, kanan }

/// Hasil satu ketukan pada papan.
enum CocokkanStep { abaikan, pilih, cocok, salah, selesai }

/// Jumlah pasangan menurut tingkat usia.
int cocokkanPasangan(AgeLevel usia) => switch (usia) {
  AgeLevel.pemula => 3,
  AgeLevel.penjelajah => 4,
  AgeLevel.pembaca => 5,
};

/// Satu ronde Cocokkan: id benda di kolom kiri dan kolom kanan yang sama
/// tetapi sudah diacak.
final class CocokkanRonde {
  const CocokkanRonde({
    required this.tema,
    required this.kiri,
    required this.kanan,
  });

  final MainYukTema tema;
  final List<String> kiri, kanan;

  int get jumlah => kiri.length;
}

/// Membuat ronde baru: benda diambil dari tema (atau tema acak selain
/// [sebelumnya]), lalu kolom kanan diacak dan tidak sama persis dengan kiri.
CocokkanRonde buatCocokkan(
  Katalog katalog, {
  required int pasangan,
  required MainYukTema tema,
  required Random random,
  MainYukTema? sebelumnya,
}) {
  final p = pilihTema(katalog, tema, random: random, hindari: sebelumnya);
  final benda = [...p.item]..shuffle(random);
  final kiri = [for (final item in benda.take(pasangan)) item.id];
  final kanan = [...kiri];
  if (kanan.length > 1) {
    for (var i = 0; i < 20 && _samaUrut(kanan, kiri); i++) {
      kanan.shuffle(random);
    }
  }
  return CocokkanRonde(tema: p.tema, kiri: kiri, kanan: kanan);
}

bool _samaUrut(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Aturan main satu ronde: pilihan, pasangan yang terkunci, dan selesai.
final class CocokkanSesi {
  CocokkanSesi(this.ronde);

  final CocokkanRonde ronde;

  /// Indeks kolom kiri -> indeks kolom kanan yang sudah cocok.
  final Map<int, int> cocok = {};

  CocokkanSisi? _sisi;
  int? _indeks;

  CocokkanSisi? get sisiDipilih => _sisi;
  int? get indeksDipilih => _indeks;

  bool get selesai => cocok.length == ronde.jumlah;

  bool terpasang(CocokkanSisi sisi, int indeks) => sisi == CocokkanSisi.kiri
      ? cocok.containsKey(indeks)
      : cocok.containsValue(indeks);

  CocokkanStep ketuk(CocokkanSisi sisi, int indeks) {
    if (terpasang(sisi, indeks)) return CocokkanStep.abaikan;
    final sisiAwal = _sisi;
    final indeksAwal = _indeks;
    if (sisiAwal == null) {
      _sisi = sisi;
      _indeks = indeks;
      return CocokkanStep.pilih;
    }
    if (sisiAwal == sisi) {
      _indeks = indeks;
      return CocokkanStep.pilih;
    }
    final idAwal = sisiAwal == CocokkanSisi.kiri
        ? ronde.kiri[indeksAwal!]
        : ronde.kanan[indeksAwal!];
    final idBaru = sisi == CocokkanSisi.kiri
        ? ronde.kiri[indeks]
        : ronde.kanan[indeks];
    _sisi = null;
    _indeks = null;
    if (idAwal != idBaru) return CocokkanStep.salah;
    final kiri = sisiAwal == CocokkanSisi.kiri ? indeksAwal : indeks;
    final kanan = sisiAwal == CocokkanSisi.kiri ? indeks : indeksAwal;
    cocok[kiri] = kanan;
    return selesai ? CocokkanStep.selesai : CocokkanStep.cocok;
  }

  void ulang() {
    cocok.clear();
    _sisi = null;
    _indeks = null;
  }
}
