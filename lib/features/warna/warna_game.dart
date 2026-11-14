import 'dart:math';

import '../../core/content/katalog.dart';
import '../../core/lang.dart';

/// Bentuk pengganti saat gambar satu warna tidak cukup banyak.
enum WarnaBentuk { balon, bintang, hati }

final class WarnaKartu {
  const WarnaKartu({
    required this.id,
    this.gambarId,
    this.bentuk,
    required this.warna,
  });

  final String id;
  final String? gambarId;
  final WarnaBentuk? bentuk;
  final String warna;
}

final class WarnaSet {
  const WarnaSet({required this.warna, required this.kartu});

  final String warna;
  final List<WarnaKartu> kartu;

  /// Jumlah kartu yang berwarna [warna], yaitu target yang harus diketuk.
  int get total => kartu.where((k) => k.warna == warna).length;
}

/// Dua belas kartu untuk satu warna: 4–5 target (gambar warna itu, sisanya
/// bentuk) dan sisanya warna lain.
WarnaSet buatWarnaSet(Katalog katalog, String warna, Random random) {
  final kartu = <WarnaKartu>[];
  final terpakai = <String>{};

  void tambah(String id, {String? gambarId, WarnaBentuk? bentuk, required String w}) {
    var unik = id;
    var n = 2;
    while (!terpakai.add(unik)) {
      unik = '$id-$n';
      n++;
    }
    kartu.add(
      WarnaKartu(id: unik, gambarId: gambarId, bentuk: bentuk, warna: w),
    );
  }

  final target = [
    for (final item in katalog.item)
      if (item.warna == warna) item,
  ]..shuffle(random);
  final jumlahTarget = 4 + random.nextInt(2);
  for (var i = 0; i < jumlahTarget; i++) {
    if (i < target.length) {
      tambah(target[i].id, gambarId: target[i].id, w: warna);
    } else {
      final bentuk = WarnaBentuk.values[(i - target.length) % 3];
      tambah('${bentuk.name}-$warna', bentuk: bentuk, w: warna);
    }
  }

  final warnaLain = [
    for (final w in katalog.warna)
      if (w.id != warna) w,
  ]..shuffle(random);
  final gambarLain = [
    for (final item in katalog.item)
      if (item.warna != null && item.warna != warna) item,
  ]..shuffle(random);
  final sisaGambar = 12 - jumlahTarget - 2;
  for (var i = 0; i < sisaGambar; i++) {
    final item = gambarLain[i];
    tambah(item.id, gambarId: item.id, w: item.warna!);
  }
  for (var i = 0; i < 2; i++) {
    final w = warnaLain[i].id;
    final bentuk = WarnaBentuk.values[i];
    tambah('${bentuk.name}-$w', bentuk: bentuk, w: w);
  }

  kartu.shuffle(random);
  return WarnaSet(warna: warna, kartu: kartu);
}

/// Warna berikutnya di katalog; warna terakhir berputar ke awal.
String warnaBerikut(Katalog katalog, String warna) {
  final daftar = katalog.warna;
  final i = daftar.indexWhere((w) => w.id == warna);
  return daftar[(i + 1) % daftar.length].id;
}

/// Nama kartu untuk dibacakan: nama benda, atau kosong untuk bentuk.
String namaKartu(WarnaKartu kartu, Katalog katalog, AppLang lang) {
  if (kartu.gambarId == null) return '';
  return katalog.byId(kartu.gambarId!)?.nama.of(lang) ?? '';
}
