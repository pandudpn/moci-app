import '../lang.dart';
import 'angka_kata.dart';
import 'katalog.dart';

/// Akar berkas audio di bundel, dipakai path narasi dan kolom naskah.
const akarAudio = 'assets/audio/';

/// Path rekaman narasi di bundel aset, misalnya
/// `assets/audio/vo/id/nama_kucing.m4a`.
///
/// Harus sama dengan `Narrator.pathFor`; berkas ini tidak boleh mengimpor
/// `core/audio` karena validator berjalan tanpa Flutter.
String pathNarasi(AppLang bahasa, String jenis, String id) =>
    '${akarAudio}vo/${bahasa.name}/${jenis}_$id.m4a';

/// Satu baris rekaman yang diharapkan ada di `assets/audio/vo/`.
final class BarisNarasi {
  const BarisNarasi({
    required this.bahasa,
    required this.jenis,
    required this.id,
    required this.teks,
    this.catatan,
  });

  final AppLang bahasa;

  /// Awalan nama berkas, misalnya `nama`, `huruf`, atau `ui`.
  final String jenis;
  final String id;

  /// Teks yang harus dibacakan perekam.
  final String teks;

  /// Catatan pelafalan untuk perekam; `null` kalau tidak ada.
  final String? catatan;

  String get path => pathNarasi(bahasa, jenis, id);

  /// Path relatif terhadap `assets/audio/`, dipakai kolom `file` naskah.
  String get namaBerkas => path.substring(akarAudio.length);

  @override
  String toString() => '$path ($bahasa): $teks';
}

/// Catatan pelafalan tetap per jenis.
const catatanFonik = "bunyi pendek tanpa vokal tambahan, mis. /b/ bukan 'be'";
const catatanHuruf = 'nama huruf';
const catatanSuku = 'baca sebagai satu suku kata';
const catatanKalimat =
    'tempo pelan; waktu mulai tiap kata dicatat untuk karaoke';

/// Peta teks dan daftar kunci ARB yang bertanda `"description": "narasi"`.
///
/// Kunci yang isinya bukan teks dilewati, jadi ARB rusak tidak membuat
/// validator melempar.
({Map<String, String> teks, Set<String> kunci}) bacaArbNarasi(Object? isi) {
  if (isi is! Map) return (teks: const {}, kunci: const {});
  final teks = <String, String>{};
  final kunci = <String>{};
  for (final entri in isi.entries) {
    final nama = entri.key;
    if (nama is! String || !nama.startsWith('@') || nama.startsWith('@@')) {
      continue;
    }
    final meta = entri.value;
    if (meta is! Map || meta['description'] != 'narasi') continue;
    final kunciArb = nama.substring(1);
    final nilai = isi[kunciArb];
    if (nilai is! String) continue;
    kunci.add(kunciArb);
    teks[kunciArb] = nilai;
  }
  return (teks: teks, kunci: kunci);
}

/// Semua baris narasi yang diharapkan, urut per bahasa lalu per jenis.
///
/// [arbId] dan [arbEn] berisi teks ARB; [kunciNarasi] berisi kunci ARB yang
/// harus dibacakan. Baris untuk kunci yang teksnya tidak ada dilewati.
List<BarisNarasi> narasiDiharapkan(
  Katalog katalog, {
  required Map<String, String> arbId,
  required Map<String, String> arbEn,
  required Set<String> kunciNarasi,
}) {
  final kunciArb = kunciNarasi.toList()..sort();
  final hasil = <BarisNarasi>[];
  for (final bahasa in AppLang.values) {
    final arb = bahasa == AppLang.en ? arbEn : arbId;
    void tambah(String jenis, String id, String teks, [String? catatan]) {
      if (teks.trim().isEmpty) return;
      hasil.add(
        BarisNarasi(
          bahasa: bahasa,
          jenis: jenis,
          id: id,
          teks: teks,
          catatan: catatan,
        ),
      );
    }

    for (final item in katalog.item) {
      tambah('nama', item.id, item.nama.of(bahasa));
    }
    for (final item in katalog.item) {
      final hewan = item.hewan;
      if (hewan != null) tambah('fakta', item.id, hewan.fakta.of(bahasa));
    }
    for (final bentuk in katalog.bentuk) {
      tambah('fakta', bentuk.id, bentuk.fakta.of(bahasa));
    }
    for (final huruf in katalog.huruf) {
      final satu = huruf.of(bahasa);
      tambah('fonik', huruf.huruf.toLowerCase(), satu.bunyi, catatanFonik);
    }
    for (final huruf in katalog.huruf) {
      tambah(
        'huruf',
        huruf.huruf.toLowerCase(),
        huruf.of(bahasa).nama,
        catatanHuruf,
      );
    }
    for (final huruf in katalog.huruf) {
      tambah('contoh', huruf.huruf.toLowerCase(), huruf.of(bahasa).kata);
    }
    for (var n = 0; n <= katalog.angka.maks; n++) {
      tambah('angka', '$n', angkaKata(n, bahasa));
    }
    for (final warna in katalog.warna) {
      tambah('warna', warna.id, warna.nama.of(bahasa));
    }
    for (final bentuk in katalog.bentuk) {
      tambah('bentuk', bentuk.id, bentuk.nama.of(bahasa));
    }
    for (final suku in _sukuUnik(katalog, bahasa)) {
      tambah('suku', suku, suku, catatanSuku);
    }
    for (final kata in _kata(katalog, bahasa)) {
      tambah('kata', kata.item, kata.kata);
    }
    for (final kalimat in katalog.kalimat) {
      tambah('kalimat', kalimat.id, kalimat.teks.of(bahasa), catatanKalimat);
    }
    for (final kunci in kunciArb) {
      final teks = arb[kunci];
      if (teks != null) tambah('ui', kunci, teks);
    }
  }
  return hasil;
}

List<KataEntry> _kata(Katalog katalog, AppLang bahasa) =>
    bahasa == AppLang.en ? katalog.kata.en : katalog.kata.id;

List<UcapkanEntry> _ucapkan(Katalog katalog, AppLang bahasa) =>
    bahasa == AppLang.en ? katalog.ucapkan.en : katalog.ucapkan.id;

/// Suku kata unik huruf kecil: kisi 90, pemenggalan kata, dan suku Ucapkan.
List<String> _sukuUnik(Katalog katalog, AppLang bahasa) {
  final suku = <String>{
    for (final s in katalog.sukuKata.semua) s.toLowerCase(),
    for (final kata in _kata(katalog, bahasa))
      for (final s in kata.suku) s.toLowerCase(),
    for (final kata in _ucapkan(katalog, bahasa))
      for (final s in kata.suku) s.toLowerCase(),
  }.toList()..sort();
  return suku;
}
