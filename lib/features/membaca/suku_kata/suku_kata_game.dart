import '../../../core/content/katalog.dart';
import '../../../core/lang.dart';

/// Satu contoh kata untuk sebuah suku kata.
final class SukuContoh {
  const SukuContoh({
    required this.suku,
    required this.item,
    required this.kata,
  });

  final String suku;

  /// Id ilustrasi di `assets/illustrations/`.
  final String item;
  final String kata;
}

/// Satu sel kisi suku kata: konsonan + vokal, dengan contoh kata opsional.
final class SukuKartu {
  const SukuKartu({
    required this.suku,
    required this.konsonan,
    required this.vokal,
    this.contoh,
  });

  final String suku;
  final String konsonan;
  final String vokal;
  final SukuContoh? contoh;

  bool get adaContoh => contoh != null;
}

/// Konsonan kisi: huruf kecil, urut katalog, tanpa duplikat.
List<String> konsonanKisi(SukuKataInfo info) {
  final hasil = <String>[];
  for (final huruf in info.konsonan.toLowerCase().split('')) {
    if (huruf.trim().isEmpty || hasil.contains(huruf)) continue;
    hasil.add(huruf);
  }
  return hasil;
}

/// Vokal kisi, urut seperti katalog.
List<String> vokalKisi(SukuKataInfo info) => List.unmodifiable(info.vokal);

/// Lima kartu untuk satu konsonan, urut vokal. Kosong kalau konsonan asing.
List<SukuKartu> barisKonsonan(
  SukuKataInfo info,
  String konsonan,
  AppLang bahasa,
) {
  final k = konsonan.toLowerCase();
  if (!konsonanKisi(info).contains(k)) return const [];
  return [
    for (final v in vokalKisi(info))
      SukuKartu(
        suku: '$k$v',
        konsonan: k,
        vokal: v,
        contoh: contohSuku(info, bahasa, '$k$v'),
      ),
  ];
}

/// Contoh kata untuk [suku] pada [bahasa], atau `null` kalau tidak ada.
SukuContoh? contohSuku(SukuKataInfo info, AppLang bahasa, String suku) {
  final contoh = info.contoh[bahasa.name]?[suku.toLowerCase()];
  if (contoh == null) return null;
  return SukuContoh(
    suku: suku.toLowerCase(),
    item: contoh.item,
    kata: contoh.kata,
  );
}

/// Potong [kata] di batas [suku] hanya kalau kata benar-benar diawali suku itu.
({String awalan, String sisa}) pecahContoh(String kata, String suku) {
  final rendah = kata.toLowerCase();
  final potong = suku.toLowerCase();
  if (potong.isEmpty ||
      !rendah.startsWith(potong) ||
      kata.length < potong.length) {
    return (awalan: '', sisa: kata);
  }
  return (
    awalan: kata.substring(0, potong.length),
    sisa: kata.substring(potong.length),
  );
}
