import '../../core/content/katalog.dart';
import '../../core/lang.dart';

/// Satu kata Ucapkan siap tampil: kata, suku kata, dan id benda.
final class UcapkanKata {
  const UcapkanKata({
    required this.kata,
    required this.suku,
    required this.itemId,
  });

  final String kata;
  final List<String> suku;

  /// Id benda dari nama berkas gambar, misalnya `apel`; dipakai narasi
  /// `nama_apel`.
  final String itemId;

  /// Path gambar di bundel aset.
  String get gambar => 'illustrations/$itemId.svg';
}

/// `illustrations/apel.svg` → `apel`.
String itemIdDariGambar(String gambar) {
  final nama = gambar.split('/').last;
  return nama.endsWith('.svg')
      ? nama.substring(0, nama.length - '.svg'.length)
      : nama;
}

/// Lima kata Ucapkan untuk [lang].
List<UcapkanKata> ucapkanKata(Katalog katalog, AppLang lang) => [
  for (final e in lang == AppLang.en ? katalog.ucapkan.en : katalog.ucapkan.id)
    UcapkanKata(kata: e.kata, suku: e.suku, itemId: itemIdDariGambar(e.gambar)),
];
