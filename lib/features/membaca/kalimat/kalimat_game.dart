import 'dart:math';

import '../../../core/content/katalog.dart';

/// Id ilustrasi dari kolom `gambar`: nama berkas tanpa folder dan `.svg`.
String itemDariGambar(String gambar) {
  final nama = gambar.split('/').last;
  return nama.endsWith('.svg') ? nama.substring(0, nama.length - 4) : nama;
}

/// Tiga id item unik untuk Tebak gambar: jawaban dan dua pengganggu.
List<String> pilihanGambar({
  required Katalog katalog,
  required KalimatEntry kalimat,
  required Random random,
}) {
  final jawaban = itemDariGambar(kalimat.gambar);
  final lain = [
    for (final item in katalog.item)
      if (item.id != jawaban) item.id,
  ]..shuffle(random);
  return [jawaban, ...lain.take(2)]..shuffle(random);
}
