import 'dart:convert';
import 'dart:io';

import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/narasi.dart';

import 'laporan.dart';

/// Aturan narasi: rekaman yang sudah ada, dan naskah bagi yang belum.
///
/// Mode pengembangan hanya memperingatkan baris yang belum direkam; mode rilis
/// menggagalkannya. Naskah ditulis ke [naskahKeluar] kalau diminta.
void validasiNarasi(
  Laporan laporan, {
  required Directory root,
  required Katalog katalog,
  required bool rilis,
  required File? naskahKeluar,
}) {
  final arbId = muatArbNarasi(File('${root.path}/l10n/app_id.arb'));
  final arbEn = muatArbNarasi(File('${root.path}/l10n/app_en.arb'));
  final baris = narasiDiharapkan(
    katalog,
    arbId: arbId.teks,
    arbEn: arbEn.teks,
    kunciNarasi: {...arbId.kunci, ...arbEn.kunci},
  );
  final belum = [
    for (final satu in baris)
      if (!File('${root.path}/${satu.path}').existsSync()) satu,
  ];

  if (belum.isEmpty) {
    laporan.ok('narasi_lengkap', '${baris.length} baris narasi sudah direkam');
  } else {
    final pesan =
        '${belum.length} dari ${baris.length} baris narasi belum direkam: '
        '${ringkas([for (final satu in belum) satu.namaBerkas])}'
        '${naskahKeluar == null ? '' : ' (naskah: ${naskahKeluar.path})'}';
    if (rilis) {
      laporan.galat('narasi_lengkap', pesan);
    } else {
      laporan.peringatan('narasi_lengkap', pesan);
    }
  }

  if (naskahKeluar != null) _tulisNaskah(naskahKeluar, belum);
}

/// Teks dan kunci narasi dari satu berkas ARB. Berkas yang tidak ada atau
/// rusak dianggap kosong, karena `gen-l10n` yang menangkap ARB rusak.
({Map<String, String> teks, Set<String> kunci}) muatArbNarasi(File berkas) {
  if (!berkas.existsSync()) return (teks: const {}, kunci: const {});
  try {
    return bacaArbNarasi(jsonDecode(berkas.readAsStringSync()));
  } on FormatException {
    return (teks: const {}, kunci: const {});
  }
}

/// Menulis naskah CSV untuk [baris], urut per bahasa lalu nama berkas.
void _tulisNaskah(File keluar, List<BarisNarasi> baris) {
  final urut = [...baris]
    ..sort((a, b) {
      final bahasa = a.bahasa.index.compareTo(b.bahasa.index);
      return bahasa != 0 ? bahasa : a.namaBerkas.compareTo(b.namaBerkas);
    });
  final isi = StringBuffer('file,bahasa,teks,catatan\n');
  for (final satu in urut) {
    isi.writeln(
      [
        satu.namaBerkas,
        satu.bahasa.name,
        satu.teks,
        satu.catatan ?? '',
      ].map(_kutip).join(','),
    );
  }
  keluar.parent.createSync(recursive: true);
  keluar.writeAsStringSync(isi.toString());
}

/// Kutip satu kolom CSV kalau memuat koma, kutip, atau baris baru.
String _kutip(String nilai) {
  if (!nilai.contains(RegExp('[,"\r\n]'))) return nilai;
  return '"${nilai.replaceAll('"', '""')}"';
}
