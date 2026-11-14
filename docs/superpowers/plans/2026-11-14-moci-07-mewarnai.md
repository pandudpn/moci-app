# Moci — Rencana 07: Mewarnai — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tiga layar mewarnai yang benar-benar bisa dimainkan anak — Galeri 14 halaman, Kanvas dengan kuas, isi, hapus, 8 stiker, 16 krayon, dan batal 30 langkah, serta Karyaku 12 karya — beserta mesin pewarnaan, draf otomatis, dan penyimpanan karya.

**Architecture:**
- Aturan pewarnaan ditulis sebagai Dart murni di `lib/features/mewarnai/` (`svg_path.dart`, `mewarnai_model.dart`, `mewarnai_engine.dart`): path halaman di-parse sekali, bagian dipilih dengan `Path.contains`, coretan dikunci ke bagian tempat jari mulai, dan riwayat batal menyimpan 30 langkah. Penggambaran ada di `mewarnai_painter.dart` yang dipakai dua kali: `CustomPaint` di layar dan `PictureRecorder` untuk PNG 300 × 225 saat Simpan.
- Galeri, Kanvas, dan Karyaku adalah `MociStage` tablet. Galeri memakai gambar contoh dari `pages.json`; Karyaku memakai PNG yang diekspor saat Simpan, dengan pratinjau dari data sebagai cadangan. Tidak ada berkas gambar tambahan yang diunduh atau dibuat selain PNG itu.
- `karyaProvider` membaca dan menulis lewat `KaryaRepository` di atas `JsonStore` yang sudah ada: `draf/<halaman>.json` satu per halaman dan `karya/<id>.json` maksimal 12. Thumbnail PNG disimpan sebagai base64 di dalam berkas karya, supaya satu tulisan atomik selalu memuat data dan gambarnya sekaligus.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart 3, `dart:ui` (`Path`, `PictureRecorder`, `Picture.toImage`), `vector_graphics` 1.3.1 (sudah terpasang) untuk stiker, Riverpod 3, `go_router` 18, gen-l10n, `CustomPainter` di dalam `RepaintBoundary`.

**Spec:**
- `docs/PRD.md` (baris Mewarnai: 14 gambar, kuas 3 ukuran, isi, hapus, stiker, batal, mulai lagi, simpan, 16 krayon, Karyaku 12 karya).
- `docs/TECH-SPEC.md` §Data dan penyimpanan lokal (`karya/`, `draf/`, 12 file, 200 KB) dan §Mewarnai butir 1–8.
- `docs/DESIGN-SYSTEM.md` (krayon 96 pt, target sentuh 64 pt, bayangan padat), `docs/CONTENT-ASSETS.md` (halaman mewarnai 800 × 600, bagian tertutup, garis detail terpisah).
- Prototipe: `docs/design/prototype/Mewarnai.dc.html` (objek `T` di baris 301 dan 303), `Galeri.dc.html`, `Karyaku.dc.html`. Teks UI disalin persis dari objek `T` tiap artboard.
- Data: `assets/coloring/pages.json` (14 halaman), `assets/coloring/cap.json` (8 stiker), `assets/coloring/krayon.json` (16 krayon), model di `lib/core/content/coloring.dart`, pemuat di `lib/core/content/content_repository.dart`.
- Peta rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md` (baris 07).

**Bergantung pada Rencana 01, 02, dan 03:**
- 01: `MociStage`, `MenuTheme` (`mewarnai`, `karyaku`), `MociTopBar`, `MociBackButton`, `MociPressable`, `MociButton`, `MociDialog` + `MociDialogButton`, `StarCounter`, `MociMascot`, `Narrator`, `AudioService`, `Sfx`, `prefsProvider`, `progressProvider` (`setLastActivity`, `markItem`, `recordKarya`), `JsonStore` + `jsonStoreProvider`, `AppFiles`, harness tes (`pumpApp`, `pumpScreen`, `TestEnv`).
- 02: `ColoringSet`, `ColoringPage`, `ColoringRegion`, `Cap`, `Krayon`, `Bilingual`, `ContentRepository.loadColoring/loadCap/loadKrayon`, aset `assets/coloring/`, ilustrasi `assets/illustrations/<id>.svg`, `tool/validate_content.dart`.
- 03: `Narrator` tanpa `allowTts` (TTS di semua mode build), `Sfx`, dan komponen `lib/widgets/game/`. Rencana ini tidak menambah komponen di sana: pil alat, krayon, dan kartu karya hanya dipakai menu Mewarnai, jadi tinggal di `lib/features/mewarnai/widgets/`.

## Global Constraints

- Flutter **3.50.0** lewat FVM. Semua perintah memakai `fvm flutter …` / `fvm dart …`.
- **Tidak ada paket baru.** Semua yang dibutuhkan sudah ada: `dart:ui`, `dart:convert`, `dart:typed_data`, `vector_graphics` 1.3.1, Riverpod 3, `go_router` 18, gen-l10n. Tidak ada paket gambar, berbagi berkas, pemilih berkas, analytics, atau crash reporting.
- Material diimpor dari `package:material_ui/material_ui.dart`; file yang hanya butuh lapisan widget memakai `package:flutter/widgets.dart`. Mesin, model, dan parser hanya boleh mengimpor `dart:ui`, `dart:convert`, `dart:typed_data`, dan `package:flutter/foundation.dart` (`ChangeNotifier`).
- **Layout:** setiap layar adalah `MociStage` dengan builder `tablet` berukuran 1180 × 820. HP memakai desain tablet yang diperkecil (D12) sampai Rencana 08; tidak ada builder `phone` di rencana ini.
- Target sentuh **64 pt** tablet, jarak **16 pt**, margin tepi **32 pt**. Kontras teks minimal **4,5 : 1**. Tekan: turun **5 pt**, skala **0,97**, **120 ms**. Muncul: **400–550 ms**, kurva `Cubic(0.3, 1.6, 0.5, 1)`. Saat `MediaQuery.disableAnimations` aktif, animasi hiasan (pita, Moci mengangguk, toast meluncur) berhenti, tetapi umpan balik alat tetap muncul.
- **Kanvas 60 fps:** halaman berukuran **800 × 600** dan digambar di layar **864 × 648** (skala **1,08**). Kanvas berada di dalam `RepaintBoundary`; jari yang bergerak hanya memicu `CustomPainter.repaint` lewat `ChangeNotifier`, bukan membangun ulang widget.
- **Angka mesin (dari TECH-SPEC §Mewarnai):** kuas **14 / 26 / 44** unit, hapus **+10** unit, stiker **90** unit kanvas, riwayat batal **30** langkah, penyederhanaan coretan **1** unit, thumbnail **300 × 225** px, krayon **16**, stiker **8**, karya tersimpan **12**, draf **1 per halaman**.
- **Penyimpanan:** folder aplikasi `<application support>/moci`; `draf/<halaman>.json` dan `karya/<id>.json`; `versi: 1`; tulisan atomik lewat `JsonStore` (tulis `.tmp` lalu rename); tanpa jaringan; tanpa cadangan OS. Thumbnail PNG **300 × 225** disimpan base64 di dalam berkas karya (`gambar`), bukan berkas terpisah, supaya data dan gambar selalu satu tulisan.
- **Dua bahasa setara:** semua teks UI lewat gen-l10n dan bisa berganti saat layar terbuka. Nama halaman diambil dari `pages.json` lewat `Bilingual.of(lang)`, bukan dari ARB. Kunci ARB baru memakai awalan `mewarnai…`; hanya kunci yang benar-benar dibacakan Moci diberi `"description": "narasi"`.
- Teks permainan tidak mengikuti ukuran teks sistem (`textScaleCap` 1,0, bawaan `MociStage`).
- **Narasi:** rekaman belum ada sampai Rencana 09, jadi TTS perangkat dipakai (Rencana 03 H1). Id baris narasi untuk kunci ARB adalah `ui_<kunciArb>`. Nama halaman **tidak** dibacakan Moci; ia dibaca pembaca layar lewat `Semantics`.
- **Progres:** modul `mewarnai` (14 item) dengan metrik `diwarnai`, id = id halaman. `setLastActivity` memakai path konkret `/mewarnai/<halaman>` supaya kartu Lanjutkan membuka kanvas yang sama; `markItem` dan `recordKarya` hanya dipanggil saat Simpan berhasil.
- Efek suara hanya dari enum `Sfx` (`klik`, `benar`, `salahLembut`, `sorak`, `bintang`). Tidak ada buzzer.
- Tidak ada `TODO`, placeholder, teks Inggris hardcoded di widget, atau jalur kode yang tidak dipakai.

## Review Focus

1. **Warna keluar garis atau masuk ke bagian yang salah.** Bagian yang dipilih harus bagian paling atas yang memuat titik, dan coretan harus tetap milik bagian tempat jari mulai walau jari menyeberang. Dipatok di Task 2 (`bagian paling atas yang memuat titik dipilih`, `coretan terkunci di bagian tempat jari mulai`) dan Task 4 (`ekspor PNG memotong coretan ke bagiannya`).
2. **Batal menghilangkan pekerjaan, bukan mengembalikannya.** Isi yang menimpa coretan, Mulai lagi, dan langkah ke-31 harus bisa dibatalkan persis seperti sebelumnya. Dipatok di Task 2 (`isi menghapus coretan bagian dan batal mengembalikannya`, `mulai lagi mengosongkan halaman dan batal memulihkannya`, `riwayat batal berhenti di 30 langkah`).
3. **Draf dan karya saling menimpa.** Draf satu halaman tidak boleh bocor ke halaman lain, membuka kanvas harus memuat draf halaman itu, dan hapus karya tidak boleh menghapus draf. Dipatok di Task 3 (`draf per halaman tidak saling menimpa`), Task 6 (`membuka lagi memuat draf halaman`), dan Task 8 (`hapus karya tidak menghapus draf`).
4. **Simpan dua kali atau menyimpan gambar yang basi.** Ketukan ganda saat menyimpan tidak boleh membuat dua karya, dan PNG harus memuat goresan terakhir. Dipatok di Task 7 (`menekan simpan dua kali hanya membuat satu karya`, `simpan menyertakan goresan terakhir`).
5. **Teks panjang dan jumlah besar.** "Kue Ulang Tahun" dan "Birthday Cake" di kartu 184 pt, "Benda & Alam" di pil saring, dan 12 karya di Karyaku tidak boleh overflow atau terpotong tanpa elipsis. Dipatok di Task 5 (`nama panjang tidak overflow`, `ganti bahasa mengganti nama halaman`) dan Task 8 (`dua belas karya dan hitungannya`).

## Keputusan rencana ini

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| M1 | Semua kode mewarnai tinggal di `lib/features/mewarnai/` (termasuk `widgets/`). Tidak ada komponen baru di `lib/widgets/game/` dan tidak ada perubahan `lib/main.dart` atau `test/helpers/harness.dart`. | Komponen 03 dipakai ulang apa adanya. Layar mewarnai cukup memakai provider yang sudah dioverride `runMoci` dan `TestEnv` (`jsonStoreProvider`), jadi tidak ada kabel baru di akar aplikasi. |
| M2 | `pages.json`, `cap.json`, dan `krayon.json` dimuat lewat `FutureProvider` di `mewarnai_providers.dart` dengan `rootBundle`. | `runMoci` tidak perlu diubah; `rootBundle` sudah terbukti terbaca di `flutter test` (`test/core/content/content_repository_test.dart`). |
| M3 | Parser path mendukung perintah absolut `M L H V C Q A Z` (yang dipakai `pages.json`) dan melempar `FormatException` untuk perintah lain. `A` memakai `Path.arcToPoint` sehingga radius, rotasi, bendera busur besar, dan arah putar mengikuti SVG. | Seluruh 14 halaman memakai 7 perintah itu (`A` 502 kali, `Q` 59 kali). Perintah tak dikenal harus gagal keras di tes, bukan digambar setengah benar. |
| M4 | Riwayat batal 30 langkah mencakup Isi, coretan kuas/hapus, stiker, dan Mulai lagi. Isi menghapus coretan bagian itu (seperti prototipe) tetapi menyimpannya di riwayat. | Anak harus bisa mengembalikan gambar yang tertimpa isi atau terhapus Mulai lagi. |
| M5 | Alat hapus adalah kuas putih selebar kuas + 10 di dalam bagian, bukan penghapus isian. | TECH-SPEC butir 5; isian tetap utuh sehingga anak tidak kehilangan warna dasar karena menggosok. |
| M6 | Stiker disimpan sebagai id `cap.json` (bukan indeks) dan digambar **90 unit** kanvas, di dalam painter yang sama dengan layar dan ekspor. | Id tahan terhadap urutan `cap.json` yang berubah. Satu painter berarti PNG tidak mungkin berbeda dari layar. |
| M7 | Thumbnail Karyaku adalah PNG **300 × 225** yang diekspor saat Simpan dan disimpan base64 di `karya/<id>.json` (`gambar`). Galeri memakai warna contoh dari data, tanpa berkas gambar. | Satu tulisan atomik memuat data + gambar (tidak ada PNG yatim saat karya dihapus), batas 12 berkas tetap berlaku, dan tidak perlu store biner baru di luar cakupan rencana. |
| M8 | Draf disimpan otomatis 600 ms setelah perubahan terakhir, dan sekali lagi saat layar ditinggalkan. Draf **tidak** dihapus saat Simpan. | Karya yang goyah karena aplikasi ditutup tetap utuh, dan anak bisa melanjutkan mewarnai halaman yang sudah disimpan. |
| M9 | Galeri tidak menampilkan lencana "BARU" dari prototipe; hanya "Lanjutkan" untuk halaman yang drafnya berisi. Kartu Karyaku menampilkan jumlah karya. | Daftar "baru" di prototipe ditulis tangan; aplikasi tidak punya sumber data untuk itu. |
| M10 | Pemilih halaman dan detail karya memakai dialog lebar sendiri (`showWideDialog`, maks 1020 pt) karena `MociDialog` dibatasi 560 pt. | Tata letak artboard butuh 1020 pt (5 kolom) dan 1008 pt (720 pratinjau + 210 panel). Tombolnya tetap `MociDialogButton`. |
| M11 | Hapus karya memakai dua ketukan di dialog ("Hapus" → "Yakin hapus?"), tanpa dialog sistem. | Prototipe `Karyaku.dc.html`; anak tidak bisa menghapus karya karena salah ketuk. |
| M12 | Galeri, Kanvas, dan Karyaku tidak membacakan nama halaman. Moci hanya membacakan petunjuk alat, "tersimpan", dan "mulai dari awal". | Nama halaman adalah isi (`pages.json`), bukan baris ARB; menambah 14 baris narasi untuk itu memperbesar naskah tanpa dipakai rutin. |
| M13 | Warna, alat, dan ukuran kuas adalah state layar (bawaan kuas `#74C0FC` ukuran sedang) dan tidak ikut tersimpan. | Prototipe juga tidak menyimpannya; yang perlu bertahan hanya gambar. |
| M14 | Kegagalan menulis berkas saat Simpan tidak menghentikan layar: toast tidak muncul, draf tetap ada, dan anak bisa menekan Simpan lagi. | Tidak ada jalur galat di desain anak; data yang sudah ada tidak boleh hilang karena kartu penyimpanan penuh. |

## Peta file

```
lib/features/mewarnai/svg_path.dart             # parser 7 perintah path (Dart murni, dart:ui)
lib/features/mewarnai/mewarnai_model.dart       # KaryaData, Coretan, CapTempel, Riwayat, konstanta
lib/features/mewarnai/mewarnai_engine.dart      # hit-test, isi, kuas, hapus, stiker, batal, mulai lagi
lib/features/mewarnai/karya_repository.dart     # draf/<halaman>.json, karya/<id>.json, batas 12
lib/features/mewarnai/mewarnai_providers.dart   # coloringProvider, krayonProvider, capProvider, capPictureProvider, karyaProvider
lib/features/mewarnai/mewarnai_painter.dart     # ColoringView + ColoringPainter + renderKaryaPng
lib/features/mewarnai/widgets/coloring_canvas.dart  # kanvas 864 × 648 + gestur
lib/features/mewarnai/widgets/page_thumbnail.dart   # gambar kecil halaman dari data
lib/features/mewarnai/widgets/crayon_button.dart    # krayon 96 pt + bentuk krayon
lib/features/mewarnai/widgets/alat_icon.dart        # ikon kuas, isi, hapus, stiker
lib/features/mewarnai/widgets/tool_bar.dart         # panel alat 248 × 648
lib/features/mewarnai/widgets/wide_dialog.dart      # dialog lebar 1020 pt
lib/features/mewarnai/widgets/page_picker.dart      # dialog pilih 14 gambar
lib/features/mewarnai/widgets/karya_card.dart       # kartu karya 330 × 290
lib/features/mewarnai/widgets/karya_detail_dialog.dart  # pratinjau 720 × 540 + hapus dua langkah
lib/features/mewarnai/galeri_screen.dart        # Galeri
lib/features/mewarnai/kanvas_screen.dart        # Kanvas
lib/features/mewarnai/karyaku_screen.dart       # Karyaku
l10n/app_id.arb · l10n/app_en.arb               # 43 kunci baru
lib/app/router.dart                             # tiga rute mewarnai menggantikan ComingSoonScreen
docs/TECH-SPEC.md · SYSTEM_DESIGN.md            # skema berkas, penyimpanan, mesin
integration_test/app_test.dart                  # skenario mewarnai → simpan → Karyaku
```

Kontrak untuk rencana berikutnya: nama tipe dan berkas di atas tidak boleh berubah tanpa memperbarui rencana yang memakainya. Rencana 08 hanya menambah builder `phone` di layar-layar ini.

---

### Task 1: Parser path, model karya, dan riwayat batal

**Files:**
- Create: `lib/features/mewarnai/svg_path.dart`, `lib/features/mewarnai/mewarnai_model.dart`
- Test: `test/features/mewarnai/svg_path_test.dart`, `test/features/mewarnai/mewarnai_model_test.dart`

**Interfaces:**
- Consumes: `dart:ui` (`Path`, `Offset`, `Rect`, `Color`), `dart:typed_data`, `dart:convert`.
- Produces (dipakai Task 2–8):
  - `Path svgPath(String d)` — mendukung `M L H V C Q A Z` absolut; `M x y …` berpasangan menjadi garis; `A rx ry rotasi besarPutar arah x y` memakai `Path.arcToPoint`; pemisah spasi, koma, dan tanda minus diterima; perintah lain melempar `FormatException`.
  - `const kanvasHalaman = Size(800, 600);` `const skalaLayar = 1.08;` `const lebarKuas = <double>[14, 26, 44];` `const tambahanLebarHapus = 10.0;` `const ukuranCap = 90.0;` `const toleransiCoretan = 1.0;` `const batasRiwayat = 30;` `const batasKarya = 12;` `const ukuranThumbnail = Size(300, 225);` `const ukuranKanvasLayar = Size(864, 648);`
  - `enum AlatMewarnai { kuas, isi, hapus, cap }`, `enum UkuranKuas { kecil, sedang, besar }` dengan `double get lebar` (14 / 26 / 44).
  - `Color warnaDariHex(String hex)` — `#RRGGBB`; nilai tidak dikenal menjadi putih.
  - `String coretanDariTitik(List<Offset> titik, {double toleransi = toleransiCoretan})` — buang titik yang jaraknya < 3 unit dari titik terakhir, sederhanakan dengan Ramer–Douglas–Peucker, tulis `M x yL x y…` dengan satu desimal tanpa `.0`.
  - `final class Coretan { const Coretan({required this.d, required this.warna, required this.lebar}); final String d, warna; final double lebar; Map<String, Object?> toJson(); static Coretan fromJson(Object? v); }`
  - `final class CapTempel { const CapTempel({required this.cap, required this.x, required this.y}); final String cap; final double x, y; }`
  - `final class KaryaData { const KaryaData({required this.halaman, this.isian = const {}, this.coretan = const {}, this.cap = const [], this.waktu}); static const versi = 1; factory KaryaData.kosong(String halaman, {DateTime? waktu}); factory KaryaData.fromJson(Object? v); final String halaman; final Map<int, String> isian; final Map<int, List<Coretan>> coretan; final List<CapTempel> cap; final DateTime? waktu; bool get adaIsi; KaryaData copyWith({Map<int, String>? isian, Map<int, List<Coretan>>? coretan, List<CapTempel>? cap, DateTime? waktu}); Map<String, Object?> toJson(); }`
  - `sealed class Langkah` dengan `LangkahIsi({bagian, sebelum, coretanDihapus})`, `LangkahCoretan(bagian)`, `LangkahCap()`, `LangkahMulaiLagi(sebelum)`; dan `final class Riwayat { Riwayat({this.batas = batasRiwayat}); void tambah(Langkah l); Langkah? ambilTerakhir(); bool get kosong; int get panjang; }` — langkah tertua dibuang saat melewati `batas`.
- Bentuk JSON: `{"versi":1,"halaman":"kupu","isian":{"1":"#FF4B4B"},"coretan":{"3":[{"d":"M10 20L40 20","warna":"#FF4B4B","lebar":26}]},"cap":[{"cap":"apel","x":640,"y":410}],"waktu":"2026-11-14T10:00:00.000"}`.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/mewarnai/svg_path_test.dart`:
```dart
test('perintah M L H V ditutup Z', () {
  final p = svgPath('M0 0L40 0H80V40Z');
  expect(p.getBounds(), const Rect.fromLTRB(0, 0, 80, 40));
  expect(p.contains(const Offset(40, 20)), isTrue);
});
test('banyak pasangan setelah M menjadi garis', () {
  final p = svgPath('M0 0 40,0 40 40');
  expect(p.getBounds(), const Rect.fromLTRB(0, 0, 40, 40));
  expect(p.contains(const Offset(35, 20)), isTrue);
  expect(p.contains(const Offset(10, 30)), isFalse);
});
test('kurva C dan Q dihaluskan', () {
  expect(svgPath('M0 0C0 60 100 60 100 0').getBounds().height, closeTo(45, 2));
  expect(svgPath('M0 0Q50 100 100 0').getBounds().height, closeTo(50, 2));
});
test('busur A membentuk lingkaran penuh', () {
  final p = svgPath('M34 80A46 46 0 1 0 126 80A46 46 0 1 0 34 80Z');
  expect(p.getBounds().width, closeTo(92, 1));
  expect(p.getBounds().height, closeTo(92, 1));
  expect(p.contains(const Offset(80, 80)), isTrue);
  expect(p.contains(const Offset(20, 80)), isFalse);
});
test('perintah tak dikenal ditolak', () {
  expect(() => svgPath('M0 0S10 10 20 0'), throwsFormatException);
});
```
`test/features/mewarnai/mewarnai_model_test.dart`:
```dart
test('karya kosong tidak punya isi', () {
  expect(KaryaData.kosong('kupu').adaIsi, isFalse);
  expect(KaryaData.kosong('kupu').copyWith(isian: {1: '#FF4B4B'}).adaIsi, isTrue);
});
test('karya bolak-balik JSON mempertahankan isian, coretan, dan cap', () {
  final asal = KaryaData(
    halaman: 'kupu',
    isian: const {1: '#FF4B4B'},
    coretan: const {3: [Coretan(d: 'M10 20L40 20', warna: '#1C7ED6', lebar: 26)]},
    cap: const [CapTempel(cap: 'apel', x: 640, y: 410)],
    waktu: DateTime(2026, 11, 14, 10),
  );
  final salinan = KaryaData.fromJson(asal.toJson());
  expect(salinan.toJson(), asal.toJson());
  expect(salinan.coretan[3]!.single.lebar, 26);
});
test('coretan disederhanakan dengan toleransi satu unit', () {
  final titik = [for (var x = 0; x <= 40; x++) Offset(x.toDouble(), x.isEven ? 0 : 0.6)];
  expect(coretanDariTitik(titik), 'M0 0L40 0');
});
test('tikungan tajam dan titik tunggal tetap tercatat', () {
  expect(
    coretanDariTitik(const [Offset(0, 0), Offset(40, 0), Offset(40, 40)]),
    'M0 0L40 0L40 40',
  );
  expect(coretanDariTitik(const [Offset(12.5, 7)]), 'M12.5 7L12.6 7');
});
test('warna hex dibaca, nilai aneh menjadi putih', () {
  expect(warnaDariHex('#FF4B4B'), const Color(0xFFFF4B4B));
  expect(warnaDariHex('bukan'), const Color(0xFFFFFFFF));
});
test('riwayat menyimpan paling banyak 30 langkah', () {
  final r = Riwayat();
  for (var i = 0; i < 31; i++) {
    r.tambah(LangkahCoretan(i));
  }
  expect(r.panjang, 30);
  expect((r.ambilTerakhir()! as LangkahCoretan).bagian, 30);
  expect(r.kosong, isFalse);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/svg_path_test.dart test/features/mewarnai/mewarnai_model_test.dart`. Expected: FAIL karena kedua berkas belum ada.
- [ ] **Step 3: Implementasikan parser, model, dan riwayat** sesuai Interfaces. Parser membaca token angka dengan `RegExp(r'[A-Za-z]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')`, lalu mengulang pasangan parameter selama perintah yang sama masih punya angka. `A` mengubah rotasi derajat ke radian dan meneruskan `largeArc`/`clockwise` apa adanya. `coretanDariTitik` menulis satu desimal lalu membuang akhiran `.0`. `KaryaData.fromJson` mengabaikan entri yang bentuknya salah (bukan melempar), dan `Riwayat.tambah` membuang elemen pertama saat `panjang > batas`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): parser path, model karya, dan riwayat 30 langkah`.

---

### Task 2: Mesin mewarnai

**Files:**
- Create: `lib/features/mewarnai/mewarnai_engine.dart`
- Test: `test/features/mewarnai/mewarnai_engine_test.dart`

**Interfaces:**
- Consumes: `svgPath`, `KaryaData`, `Coretan`, `CapTempel`, `Riwayat`, `Langkah*`, `AlatMewarnai`, `UkuranKuas`, `warnaDariHex`, `ColoringPage`, `ColoringRegion`.
- Produces (dipakai Task 4–8):
  - `final class MesinMewarnai extends ChangeNotifier { MesinMewarnai({required ColoringPage halaman, KaryaData? awal}); final ColoringPage halaman; final List<Path> jalur; KaryaData get data; AlatMewarnai get alat; UkuranKuas get ukuran; String get warna; String get cap; int? get bagianTerkunci; List<Offset> get goresanAktif; bool get bisaBatal; int get panjangRiwayat; void pilihAlat(AlatMewarnai a); void pilihWarna(String hex); void pilihUkuran(UkuranKuas u); void pilihCap(String id); int? bagianDi(Offset p); void mulai(Offset p); void geser(Offset p); void akhiri(); void batal(); void mulaiLagi(); }`
  - Bawaan: `alat = kuas`, `warna = '#74C0FC'`, `ukuran = sedang`, `cap = ''`.
  - `jalur` = satu `Path` per `bagian`, dengan `PathFillType.evenOdd` bila `region.evenOdd`; detail tidak ikut di-parse di sini.
  - Aturan: `bagianDi` mengembalikan indeks terbesar yang `contains(p)`; `mulai` dengan `isi` mengisi bagian itu; dengan `cap` menempel `cap` (diabaikan bila `p` di luar 800 × 600 atau `cap` kosong) dan menyimpan `x`/`y` dibulatkan ke satu desimal; dengan `kuas`/`hapus` mengunci bagian dan memulai goresan. `geser` menambah titik bila jarak dari titik terakhir ≥ 3 unit. `akhiri` menyimpan satu `Coretan` (warna putih dan lebar + 10 untuk hapus) di bagian terkunci, lalu menambah `LangkahCoretan`. `isi` menyimpan `LangkahIsi(bagian, sebelum, coretanDihapus)`, mengganti `isian[bagian]`, dan membuang coretan bagian itu; tidak menambah riwayat bila warna sama dan tidak ada coretan.
  - `batal` menerapkan kebalikan langkah terakhir (isi: kembalikan warna lama dan coretannya; coretan: buang coretan terakhir; cap: buang cap terakhir; mulai lagi: pulihkan seluruh `KaryaData`). `mulaiLagi` menambah `LangkahMulaiLagi(data)` lalu mengosongkan, dan tidak melakukan apa pun bila `data.adaIsi` sudah false. Setiap perubahan memanggil `notifyListeners`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
ColoringPage _halaman() => const ColoringPage(
  id: 'uji', kategori: 'benda', nama: Bilingual('Uji', 'Test'),
  bagian: [
    ColoringRegion(d: 'M0 0H100V100H0Z'),
    ColoringRegion(d: 'M40 40H60V60H40Z'),
  ],
);
test('bagian paling atas yang memuat titik dipilih', () {
  final m = MesinMewarnai(halaman: _halaman());
  expect(m.bagianDi(const Offset(50, 50)), 1);
  expect(m.bagianDi(const Offset(10, 10)), 0);
  expect(m.bagianDi(const Offset(150, 50)), isNull);
  expect(m.jalur.length, 2);
});
test('isi mengganti warna bagian dan bisa dibatalkan', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihWarna('#FF4B4B');
  m.pilihAlat(AlatMewarnai.isi);
  m.mulai(const Offset(10, 10));
  expect(m.data.isian[0], '#FF4B4B');
  expect(m.bisaBatal, isTrue);
  m.batal();
  expect(m.data.isian, isEmpty);
});
test('isi menghapus coretan bagian dan batal mengembalikannya', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihAlat(AlatMewarnai.kuas);
  m.mulai(const Offset(10, 10));
  m.geser(const Offset(30, 10));
  m.akhiri();
  expect(m.data.coretan[0]!.single.lebar, 26);
  m.pilihAlat(AlatMewarnai.isi);
  m.mulai(const Offset(10, 10));
  expect(m.data.coretan[0], isNull);
  m.batal();
  expect(m.data.coretan[0]!.single.lebar, 26);
  expect(m.data.isian[0], isNull);
});
test('coretan terkunci di bagian tempat jari mulai', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihAlat(AlatMewarnai.kuas);
  m.mulai(const Offset(10, 10));
  m.geser(const Offset(50, 50));
  expect(m.bagianTerkunci, 0);
  m.akhiri();
  expect(m.data.coretan.keys, [0]);
  expect(m.bagianTerkunci, isNull);
});
test('hapus memakai kuas putih sepuluh unit lebih lebar', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihAlat(AlatMewarnai.hapus);
  m.pilihUkuran(UkuranKuas.besar);
  m.mulai(const Offset(10, 10));
  m.geser(const Offset(30, 10));
  m.akhiri();
  final s = m.data.coretan[0]!.single;
  expect(s.warna, '#FFFFFF');
  expect(s.lebar, 54);
});
test('stiker ditempel di titik ketukan dan bisa dibatalkan', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihCap('bola');
  m.pilihAlat(AlatMewarnai.cap);
  m.mulai(const Offset(120, 90));
  expect(m.data.cap.single.cap, 'bola');
  expect(m.data.cap.single.x, 120);
  m.batal();
  expect(m.data.cap, isEmpty);
});
test('mulai lagi mengosongkan halaman dan batal memulihkannya', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihWarna('#FF4B4B');
  m.pilihAlat(AlatMewarnai.isi);
  m.mulai(const Offset(10, 10));
  m.mulaiLagi();
  expect(m.data.adaIsi, isFalse);
  m.batal();
  expect(m.data.isian[0], '#FF4B4B');
});
test('riwayat batal berhenti di 30 langkah', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihAlat(AlatMewarnai.isi);
  for (var i = 0; i < 31; i++) {
    m.pilihWarna('#${i.toRadixString(16).padLeft(6, '0')}');
    m.mulai(const Offset(10, 10));
  }
  var batal = 0;
  while (m.bisaBatal) {
    m.batal();
    batal++;
  }
  expect(batal, 30);
  expect(m.data.isian[0], '#000000');
});
test('isi dengan warna yang sama tidak menambah riwayat', () {
  final m = MesinMewarnai(halaman: _halaman());
  m.pilihWarna('#FF4B4B');
  m.pilihAlat(AlatMewarnai.isi);
  m.mulai(const Offset(10, 10));
  m.mulai(const Offset(10, 10));
  expect(m.panjangRiwayat, 1);
});
test('draf yang dibuka tidak punya riwayat', () {
  final m = MesinMewarnai(
    halaman: _halaman(),
    awal: const KaryaData(halaman: 'uji', isian: {0: '#1C7ED6'}),
  );
  expect(m.data.isian[0], '#1C7ED6');
  expect(m.bisaBatal, isFalse);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/mewarnai_engine_test.dart`. Expected: FAIL karena berkas belum ada.
- [ ] **Step 3: Implementasikan mesin** sesuai Interfaces. Simpan `_data`, `_alat`, `_ukuran`, `_warna`, `_cap`, `_terkunci`, `_aktif`, `_riwayat` sebagai field; setiap perubahan membangun `KaryaData` baru lewat `copyWith` (peta kecil, ≤ 28 entri) lalu `notifyListeners`. Titik jari di luar kanvas tetap dicatat; pemotongan dilakukan painter.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): mesin isi, kuas, hapus, stiker, dan batal 30 langkah`.

---

### Task 3: Penyimpanan karya dan draf

**Files:**
- Create: `lib/features/mewarnai/karya_repository.dart`, `lib/features/mewarnai/mewarnai_providers.dart`
- Test: `test/features/mewarnai/karya_repository_test.dart`

**Interfaces:**
- Consumes: `JsonStore` (`read`, `write`, `delete`, `list`), `jsonStoreProvider`, `KaryaData`, `batasKarya`, `base64Encode`/`base64Decode`, `Uint8List`.
- Produces (dipakai Task 4–8):
  - `final class KaryaRepository { KaryaRepository(JsonStore store, {DateTime Function()? now}); static const drafDir = 'draf'; static const karyaDir = 'karya'; Future<KaryaData?> bacaDraf(String halaman); Future<void> simpanDraf(KaryaData data); Future<void> hapusDraf(String halaman); Future<Map<String, KaryaData>> daftarDraf(); Future<Karya> simpanKarya(KaryaData data, Uint8List png, {String? id}); Future<List<Karya>> daftarKarya(); Future<void> hapusKarya(String id); @visibleForTesting Future<Map<String, Object?>?> bacaKaryaJson(String id); }`
  - `final class Karya { const Karya({required this.id, required this.data, required this.png}); final String id; final KaryaData data; final Uint8List png; }` (di `mewarnai_model.dart`, ditambahkan Task 3).
  - `simpanDraf` menulis `draf/<halaman>.json`; `simpanKarya` menulis `karya/<id>.json` dengan `id = 'k${now.millisecondsSinceEpoch}'` bila tidak diberikan, `waktu` = `now()`, dan `gambar` = `base64Encode(png)`. Bila `karya/<id>.json` sudah ada (dua simpan dalam milidetik yang sama), coba `<id>-1`, `<id>-2`, dan seterusnya sampai nama bebas, supaya tidak ada karya yang tertimpa. Setelah menulis, hapus karya tertua sampai tersisa `batasKarya`. `daftarKarya` mengurutkan `waktu` terbaru dulu dan melewati berkas yang tidak punya `halaman`. `bacaDraf` mengembalikan `null` untuk JSON rusak.
  - Provider (file `mewarnai_providers.dart`):
    - `final coloringProvider = FutureProvider<ColoringSet>((ref) => ContentRepository.loadColoring(rootBundle));`
    - `final krayonProvider = FutureProvider<List<Krayon>>((ref) => ContentRepository.loadKrayon(rootBundle));`
    - `final capProvider = FutureProvider<List<Cap>>((ref) => ContentRepository.loadCap(rootBundle));`
    - `final capPictureProvider = FutureProvider<Map<String, PictureInfo>>(...)` — `vg.loadPicture(AssetBytesLoader('assets/illustrations/<id>.svg'), null)` untuk tiap cap (Task 4 memakainya).
    - `final class KaryaState { const KaryaState({this.siap = false, this.karya = const [], this.draf = const {}}); final bool siap; final List<Karya> karya; final Map<String, KaryaData> draf; KaryaData? drafUntuk(String halaman); }`
    - `final class KaryaController extends Notifier<KaryaState> { @override KaryaState build() => const KaryaState(); Future<void> muat(); Future<Karya> simpanKarya(KaryaData data, Uint8List png); Future<void> simpanDraf(KaryaData data); Future<void> hapusKarya(String id); }` — `muat` idempoten (keluar cepat bila `state.siap`), mengisi `karya` + `draf`.
    - `final karyaProvider = NotifierProvider<KaryaController, KaryaState>(KaryaController.new);`

- [ ] **Step 1: Tulis tes yang gagal**

```dart
KaryaRepository _repo(MemoryJsonStore store, DateTime now) =>
    KaryaRepository(store, now: () => now);
const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A];
test('draf ditulis satu berkas per halaman', () async {
  final store = MemoryJsonStore();
  final repo = _repo(store, DateTime(2026, 11, 14, 10));
  await repo.simpanDraf(const KaryaData(halaman: 'kupu', isian: {1: '#FF4B4B'}));
  final json = await store.read('draf/kupu.json');
  expect(json!['versi'], 1);
  expect(json['halaman'], 'kupu');
  expect((await repo.bacaDraf('kupu'))!.isian[1], '#FF4B4B');
  expect(await store.list('draf'), ['kupu.json']);
});
test('draf per halaman tidak saling menimpa', () async {
  final repo = _repo(MemoryJsonStore(), DateTime(2026, 11, 14, 10));
  await repo.simpanDraf(const KaryaData(halaman: 'kupu', isian: {1: '#FF4B4B'}));
  await repo.simpanDraf(const KaryaData(halaman: 'ikan', isian: {2: '#1C7ED6'}));
  expect((await repo.bacaDraf('kupu'))!.isian[1], '#FF4B4B');
  expect((await repo.bacaDraf('ikan'))!.isian[2], '#1C7ED6');
  expect((await repo.daftarDraf()).keys.toList(), ['ikan', 'kupu']);
});
test('karya menyimpan PNG base64 dan waktu', () async {
  final repo = _repo(MemoryJsonStore(), DateTime(2026, 11, 14, 10));
  final karya = await repo.simpanKarya(
    const KaryaData(halaman: 'kupu'), Uint8List.fromList(_png),
  );
  expect(karya.id, startsWith('k'));
  final json = await repo.bacaKaryaJson(karya.id);
  expect(json!['id'], karya.id);
  expect(base64Decode(json['gambar'] as String), _png);
  expect(json['waktu'], startsWith('2026-11-14T10:00'));
  expect(karya.png, _png);
});
test('karya terbaru lebih dulu', () async {
  final store = MemoryJsonStore();
  final pagi = _repo(store, DateTime(2026, 11, 14, 8));
  final sore = _repo(store, DateTime(2026, 11, 14, 16));
  await pagi.simpanKarya(const KaryaData(halaman: 'kupu'), Uint8List(0));
  await sore.simpanKarya(const KaryaData(halaman: 'ikan'), Uint8List(0));
  expect((await sore.daftarKarya()).map((k) => k.data.halaman), ['ikan', 'kupu']);
});
test('karya ketiga belas menghapus yang tertua', () async {
  final store = MemoryJsonStore();
  final repo = _repo(store, DateTime(2026, 11, 14, 8));
  var hari = 1;
  for (var i = 0; i < 13; i++) {
    await KaryaRepository(store, now: () => DateTime(2026, 11, hari++)).simpanKarya(
      KaryaData(halaman: 'kupu', isian: {i: '#FF4B4B'}), Uint8List(0),
    );
  }
  final daftar = await repo.daftarKarya();
  expect(daftar.length, 12);
  expect(await store.list('karya'), hasLength(12));
  expect(daftar.last.data.isian[1], '#FF4B4B'); // simpanan kedua, yang pertama hilang
});
test('berkas rusak tidak membuat galat', () async {
  final store = MemoryJsonStore();
  await store.write('draf/kupu.json', {'versi': 1});
  await store.write('karya/x.json', {'versi': 1, 'halaman': 7});
  final repo = _repo(store, DateTime(2026, 11, 14, 10));
  expect(await repo.bacaDraf('kupu'), isNull);
  expect(await repo.daftarKarya(), isEmpty);
});
test('dua simpan pada milidetik yang sama tidak saling menimpa', () async {
  final store = MemoryJsonStore();
  final repo = _repo(store, DateTime(2026, 11, 14, 10));
  final satu = await repo.simpanKarya(const KaryaData(halaman: 'kupu'), Uint8List(0));
  final dua = await repo.simpanKarya(const KaryaData(halaman: 'ikan'), Uint8List(0));
  expect(dua.id, '${satu.id}-1');
  expect(await store.list('karya'), hasLength(2));
  expect((await repo.daftarKarya()).map((k) => k.data.halaman).toSet(), {'kupu', 'ikan'});
});

test('hapus karya menghapus berkasnya', () async {
  final store = MemoryJsonStore();
  final repo = _repo(store, DateTime(2026, 11, 14, 10));
  final k = await repo.simpanKarya(const KaryaData(halaman: 'kupu'), Uint8List(0));
  await repo.hapusKarya(k.id);
  expect(await store.list('karya'), isEmpty);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/karya_repository_test.dart`. Expected: FAIL karena reponya belum ada.
- [ ] **Step 3: Implementasikan repository dan provider.** Tambahkan `Karya` dan `Future<Map<String, Object?>?> bacaKaryaJson(String id)` di repository untuk tes (boleh `@visibleForTesting`). `daftarKarya` membaca nama dari `store.list('karya')`, melewati berkas yang `halaman`-nya bukan teks kosong, memakai `Uint8List(0)` bila `gambar` tidak bisa di-decode. `simpanKarya` memotong daftar setelah menulis. `KaryaController` membaca `jsonStoreProvider` lewat getter `KaryaRepository get _repo => KaryaRepository(ref.read(jsonStoreProvider));` dan memperbarui `state` setelah setiap tulisan. Jangan menyentuh `lib/main.dart`, `test/helpers/harness.dart`, atau provider akar lain.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): penyimpanan draf per halaman dan 12 karya dengan PNG`.

---

### Task 4: Painter halaman, kanvas sentuh, dan ekspor PNG

**Files:**
- Create: `lib/features/mewarnai/mewarnai_painter.dart`, `lib/features/mewarnai/widgets/coloring_canvas.dart`
- Test: `test/features/mewarnai/mewarnai_painter_test.dart`, `test/features/mewarnai/coloring_canvas_test.dart`

**Interfaces:**
- Consumes: `MesinMewarnai`, `KaryaData`, `ColoringPage`, `ColoringRegion`, `svgPath`, `warnaDariHex`, `ukuranCap`, `ukuranThumbnail`, `skalaLayar`, `PictureRecorder`/`Picture.toImage`/`ImageByteFormat.png`, `PictureInfo` (vector_graphics).
- Produces (dipakai Task 5–8):
  - `class ColoringView extends StatelessWidget { const ColoringView({super.key, required this.halaman, required this.data, this.cap = const {}, this.width = 800, this.height = 600, this.radius = 0}); }` — `CustomPaint` statis: latar putih, isian per bagian (bawaan putih), coretan dipotong per bagian, garis luar `#2B2350` 6 unit, detail di atasnya, lalu stiker `90` unit.
  - `class ColoringPainter extends CustomPainter { ColoringPainter({required this.halaman, required this.data, required this.cap, required this.skala, this.goresanAktif = const [], this.bagianAktif, this.warnaAktif = '#FFFFFF', this.lebarAktif = 26, Listenable? repaint}); }` — `shouldRepaint` membandingkan `data`, `skala`, panjang `goresanAktif`, `bagianAktif`, warna/lebar aktif.
  - `Future<Uint8List> renderKaryaPng({required ColoringPage halaman, required KaryaData data, Map<String, PictureInfo> cap = const {}, int lebar = 300, int tinggi = 225});` — merekam painter dengan `skala = lebar / 800`, `picture.toImage(lebar, tinggi)`, `toByteData(format: png)`.
  - `class ColoringCanvas extends StatelessWidget { const ColoringCanvas({super.key, required this.mesin, required this.cap, this.semanticLabel, this.skala = skalaLayar}); static const surfaceKey = ValueKey('coloring-surface'); }` — `SizedBox` 864 × 648, `Semantics`, `Listener` (`onPointerDown/Move/Up/Cancel`, `behavior: HitTestBehavior.opaque`) yang membagi posisi lokal dengan `skala`, lalu `RepaintBoundary` + `CustomPaint(painter: ColoringPainter(..., repaint: mesin))`.
- Catatan gambar: stiker digambar dengan `canvas.translate(x - 45, y - 45)`, `canvas.scale(ukuranCap / info.size.width)`, `canvas.drawPicture(info.picture)`; stiker tanpa `PictureInfo` dilewati (bukan galat).

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/mewarnai/coloring_canvas_test.dart`:
```dart
ColoringPage _duaBagian() => const ColoringPage(
  id: 'uji', kategori: 'benda', nama: Bilingual('Uji', 'Test'),
  bagian: [
    ColoringRegion(d: 'M0 0H100V100H0Z'),
    ColoringRegion(d: 'M200 0H400V100H200Z'),
  ],
);
Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft + Offset(x, y) * skalaLayar;
testWidgets('ketuk dengan alat isi mewarnai bagian', (t) async {
  final mesin = MesinMewarnai(halaman: _duaBagian())..pilihAlat(AlatMewarnai.isi);
  await pumpScreen(t, Center(child: SizedBox(width: 864, height: 648,
    child: ColoringCanvas(mesin: mesin, cap: const {}, semanticLabel: 'Gambar untuk diwarnai'))));
  expect(t.getSize(find.byKey(ColoringCanvas.surfaceKey)), const Size(864, 648));
  await t.tapAt(_kanvas(t, 10, 10));
  expect(mesin.data.isian[0], '#74C0FC');
  expect(mesin.data.isian[1], isNull);
});
testWidgets('geser kuas mencatat satu coretan', (t) async {
  final mesin = MesinMewarnai(halaman: _duaBagian());
  await pumpScreen(t, Center(child: SizedBox(width: 864, height: 648,
    child: ColoringCanvas(mesin: mesin, cap: const {}, semanticLabel: 'Kanvas'))));
  final g = await t.startGesture(_kanvas(t, 10, 10));
  for (var i = 1; i <= 8; i++) {
    await g.moveTo(_kanvas(t, 10 + i * 10, 10));
    await t.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await t.pump();
  expect(mesin.data.coretan[0], hasLength(1));
  expect(mesin.data.coretan[1], isNull);
});
```
`test/features/mewarnai/mewarnai_painter_test.dart`:
```dart
testWidgets('ekspor PNG 300 x 225 dengan tanda berkas PNG', (t) async {
  final bytes = await t.runAsync(() => renderKaryaPng(
    halaman: _duaBagian(),
    data: const KaryaData(halaman: 'uji', isian: {0: '#FF4B4B'}),
  ));
  expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  final img = await t.runAsync(() => decodeImageFromList(bytes));
  expect((img!.width, img.height), (300, 225));
});
testWidgets('ekspor PNG memotong coretan ke bagiannya', (t) async {
  final halaman = const ColoringPage(
    id: 'uji', kategori: 'benda', nama: Bilingual('Uji', 'Test'),
    bagian: [
      ColoringRegion(d: 'M0 0H400V600H0Z'),
      ColoringRegion(d: 'M400 0H800V600H400Z'),
    ],
  );
  final data = KaryaData(
    halaman: 'uji',
    isian: const {1: '#1C7ED6'},
    coretan: {
      0: [Coretan(d: 'M50 300L600 300', warna: '#FF4B4B', lebar: 26)],
    },
  );
  final bytes = await t.runAsync(() =>
      renderKaryaPng(halaman: halaman, data: data));
  final img = await t.runAsync(() => decodeImageFromList(bytes!));
  final raw = await t.runAsync(() =>
      img!.toByteData(format: ImageByteFormat.rawRgba));
  int merah(int x, int y) {
    final o = (y * 300 + x) * 4;
    return raw!.buffer.asUint8List()[o];
  }
  // Skala 300 / 800 = 0,375. Batas bagian 0/1 di x = 400 unit = 150 px.
  expect(merah(40, 112), greaterThan(200));   // bagian 0: coretan merah
  expect(merah(170, 112), lessThan(120));     // bagian 1: isian biru, bukan merah
  expect(raw!.buffer.asUint8List()[(112 * 300 + 170) * 4 + 2], greaterThan(180));
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/coloring_canvas_test.dart test/features/mewarnai/mewarnai_painter_test.dart`. Expected: FAIL karena kedua berkas belum ada.
- [ ] **Step 3: Implementasikan painter, `ColoringView`, `renderKaryaPng`, dan `ColoringCanvas`** sesuai Interfaces. Parse `jalur` sekali di `MesinMewarnai`; cache `Path` coretan di painter dengan `Map<Coretan, Path>` identitas supaya frame berikutnya tidak mengurai ulang. Urutan gambar per bagian: isian → `save/clipPath` → coretan (dan goresan aktif) → `restore` → garis luar → detail. `RepaintBoundary` membungkus `CustomPaint`; jangan memakai `StatefulWidget` untuk posisi jari.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): painter halaman, kanvas sentuh, dan ekspor PNG 300 x 225`.

---

### Task 5: Layar Galeri

**Files:**
- Create: `lib/features/mewarnai/galeri_screen.dart`, `lib/features/mewarnai/widgets/page_thumbnail.dart`
- Modify: `lib/app/router.dart` (ganti `_soon(Routes.mewarnai, …)`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/mewarnai/galeri_screen_test.dart`

**Interfaces:**
- Consumes: `coloringProvider`, `karyaProvider`, `ColoringView`, `KaryaData.kosong`, `Bilingual.of`, `MociStage(MenuTheme.mewarnai)`, `MociTopBar`, `MociBackButton`, `StarCounter`, `MociPressable`, `MociMascot`, `SizedBox`, `context.l10n`, `context.push`.
- Produces:
  - `class PageThumbnail extends StatelessWidget { const PageThumbnail({super.key, required this.halaman, required this.data, this.width = 184, this.height = 138}); }` — `ColoringView` dengan radius 14 dan `RepaintBoundary`; Galeri memakai `data = KaryaData.kosong(page.id).copyWith(isian: page.contoh)`.
  - `class GaleriScreen extends ConsumerStatefulWidget { const GaleriScreen({super.key}); static ValueKey<String> kartuKey(String id); static ValueKey<String> tabKey(String kategori); static const karyakuKey = ValueKey('galeri-karyaku'); }`
  - Tata letak `MociStage(theme: MenuTheme.mewarnai, tablet: …)`: bilah atas (`MociBackButton(onTap: context.go(Routes.beranda))` dengan label bawaan `commonBack`, judul `menuWarnaiTitle` 46, grup saring tinggi 56 dengan tiga pil, `StarCounter`), kisi 15 kartu 5 kolom di kiri 36 / atas 132 / lebar 1108 dengan jarak 26 × 22, lalu baris petunjuk di kiri 36 / bawah 26 (Moci 52 + `mewarnaiHintPick` 18 `#6B5F99`).
  - Kartu: `MociPressable` putih radius 24 depth 7, padding 10; pita 74 × 24 berputar `-4/3/-2/5/-5` bergiliran warna `#FF8FB1/#74C0FC/#8CE99A/#FFD43B/#B197FC`; `PageThumbnail` 184 × 138 dengan border 2 `#F1EAD8`; nama 20 Fredoka 600 `maxLines: 1` + elipsis; lencana `mewarnaiContinue` hijau `#26A03B` bila `karyaState.drafUntuk(id)?.adaIsi == true`.
  - Kartu terakhir = Karyaku: bayangan `#E0A100`, pita `#FFD43B`, gambar `karyaku` (MociIllustration) 184 × 138, label `mewarnaiKaryaku`, lencana jumlah karya ungu `#7048E8` bila `karya.length > 0`; ketukan → `context.push(Routes.karyaku)`.
  - Saring: `semua` (semua), `hewan`, `benda` menurut `page.kategori`; pil aktif berlatar `#FFC233`.
  - Ketukan kartu → `context.push('/mewarnai/${page.id}')`; `initState` memanggil `karyaProvider.notifier.muat()`.
  - ARB (ID / EN): `mewarnaiFilter` "Jenis gambar"/"Picture type"; `mewarnaiTabSemua` "Semua"/"All"; `mewarnaiTabHewan` "Hewan"/"Animals"; `mewarnaiTabBenda` "Benda & Alam"/"Things & Nature"; `mewarnaiHintPick` "Pilih gambar yang mau kamu warnai!"/"Pick a picture to color!"; `mewarnaiOpenPage` "Warnai gambar: {nama}"/"Color the picture: {nama}"; `mewarnaiContinue` "Lanjutkan"/"Continue"; `mewarnaiKaryaku` "Karyaku"/"My Artwork"; `mewarnaiKaryaCount` "{count, plural, =0{Belum ada karya} =1{1 karya} other{{count} karya}}"/"{count, plural, =0{No artwork yet} =1{1 artwork} other{{count} artworks}}"; `mewarnaiOpenKaryaku` "Buka Karyaku, {count} karya"/"Open My Artwork, {count} artworks".
- Rute: `GoRoute(path: Routes.mewarnai, builder: (_, _) => const GaleriScreen())` menggantikan `_soon`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('galeri: judul, 14 halaman, dan kartu Karyaku', (t) async {
  await pumpApp(t, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  expect(find.text('Mewarnai'), findsOneWidget);
  expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
  expect(find.byKey(GaleriScreen.kartuKey('eskrim')), findsOneWidget);
  expect(find.byKey(GaleriScreen.karyakuKey), findsOneWidget);
  expect(find.text('Kue Ulang Tahun'), findsOneWidget);
});
testWidgets('saring hewan menyisakan enam halaman', (t) async {
  await pumpApp(t, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(GaleriScreen.tabKey('hewan')));
  await t.pump();
  expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
  expect(find.byKey(GaleriScreen.kartuKey('hantu')), findsOneWidget);
  expect(find.byKey(GaleriScreen.kartuKey('rumah')), findsNothing);
});
testWidgets('mengetuk halaman membuka kanvas', (t) async {
  final router = await pumpApp(t, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(GaleriScreen.kartuKey('ikan')));
  await t.pump();
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/mewarnai/ikan');
});
testWidgets('draf berisi memberi lencana Lanjutkan', (t) async {
  final env = TestEnv();
  await env.json.write('draf/kupu.json', {
    'versi': 1, 'halaman': 'kupu', 'isian': {'1': '#FF4B4B'}, 'coretan': {}, 'cap': [],
  });
  await pumpApp(t, env: env, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  expect(find.text('Lanjutkan'), findsOneWidget);
});
testWidgets('ganti bahasa mengganti nama halaman', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Birthday Cake'), findsOneWidget);
  expect(find.text('Kue Ulang Tahun'), findsNothing);
  expect(find.text('Things & Nature'), findsOneWidget);
});
testWidgets('nama panjang tidak overflow', (t) async {
  await pumpApp(t, initialLocation: '/mewarnai');
  await t.pump();
  await t.pump();
  expect(find.text('Kue Ulang Tahun'), findsOneWidget);
  expect(find.text('Dinosaurus'), findsOneWidget);
  expect(t.takeException(), isNull);
});
```
`_container` membaca `ProviderScope.containerOf(t.element(find.byType(MociApp)))`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/galeri_screen_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`).
- [ ] **Step 3: Implementasikan layar, thumbnail, rute, dan kunci ARB.** Salin teks dari `Galeri.dc.html` objek `T`. Ukuran kartu dan jarak dari artboard. Tambahkan deskripsi pada setiap kunci ARB. Setiap kunci yang memuat `{nama}` mendeklarasikan `placeholders: {"nama": {"type": "String"}}`, dan `mewarnaiKaryaCount` memakai `placeholders: {"count": {"type": "int"}}`. Jalankan `fvm flutter gen-l10n` bila getter belum muncul.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): Galeri 14 halaman dengan saring, draf, dan kartu Karyaku`.

---

### Task 6: Layar Kanvas — alat, krayon, batal, dan draf otomatis

**Files:**
- Create: `lib/features/mewarnai/kanvas_screen.dart`, `lib/features/mewarnai/widgets/tool_bar.dart`, `lib/features/mewarnai/widgets/crayon_button.dart`, `lib/features/mewarnai/widgets/alat_icon.dart`
- Modify: `lib/app/router.dart` (ganti `_soon(Routes.mewarnaiHalaman, …)`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/mewarnai/kanvas_screen_test.dart`

**Interfaces:**
- Consumes: `coloringProvider`, `krayonProvider`, `capProvider`, `capPictureProvider`, `karyaProvider`, `MesinMewarnai`, `ColoringCanvas`, `MociStage(MenuTheme.mewarnai)`, `MociTopBar`, `MociBackButton`, `MociPressable`, `Narrator`, `Sfx`, `progressProvider`, `prefsProvider`, `AlatMewarnai`, `UkuranKuas`.
- Produces:
  - `class KanvasScreen extends ConsumerStatefulWidget { const KanvasScreen({super.key, required this.halaman}); static const canvasKey = ValueKey('kanvas-canvas'); static const toolbarKey = ValueKey('kanvas-toolbar'); static const undoKey = ValueKey('kanvas-undo'); static const clearKey = ValueKey('kanvas-clear'); static ValueKey<AlatMewarnai> toolKey(AlatMewarnai a); static ValueKey<UkuranKuas> sizeKey(UkuranKuas u); static ValueKey<String> crayonKey(String hex); static ValueKey<String> capKey(String id); }` — `canvasKey` dan `toolbarKey` mengukur kotak 864 × 648 dan 248 × 648; `undoKey` dan `clearKey` dipasang langsung di `MociPressable`, dengan `onTap: null` saat riwayat kosong / halaman kosong.
  - `MewarnaiToolBar({required alat, required ukuran, required warna, required krayon, required cap, required idCap, required onAlat, required onUkuran, required onWarna, required onCap})` — panel 248 × 648: kisi alat 2 × 2 (62 tinggi, radius 20, aktif `#FFD43B` / `#E0A100`, lain `#FFF8E1` / `#F2E2B0`), baris ukuran 3 × 48 (opasitas 0,4 dan `onTap: null` saat alat `isi`/`cap`), lalu kisi krayon 4 kolom × 4 baris (16 `CrayonButton` 96 tinggi) atau kisi stiker 2 × 4 (94 tinggi) saat alat `cap`.
  - `CrayonButton({required hex, required nama, required onTap, this.selected = false})` — bentuk krayon 38 × 88 (`M8 30L20 3L32 30Z` + badan 6..34 × 28..90, radius 6) dengan garis tinta 2,4; terpilih `translateY(-10)` dan skala 1,08.
  - `AlatIcon(AlatMewarnai alat, {double size = 30, Color warna = MociColors.ink})` — path dari `Mewarnai.dc.html` (kuas, ember isi, penghapus, bintang).
  - Tata letak: bilah atas (`MociBackButton(semanticLabel: l10n.mewarnaiBackGaleri, onTap: context.go(Routes.mewarnai))`, judul = `page.nama.of(lang)`, `Batal`, `Mulai lagi`), kanvas 864 × 648 di kiri 24 / atas 108, panel alat di kiri 908 / atas 108, baris petunjuk di kiri 24 / atas 772 (Moci 40 + petunjuk alat aktif). Tombol `Simpan` menyusul di Task 7.
  - Perilaku: `initState` memuat draf halaman (`karyaProvider.notifier.muat()` lalu `state.drafUntuk(id)`), membuat `MesinMewarnai(halaman: page, awal: draf)`, dan mencatat `setLastActivity('/mewarnai/$id')`. Setiap perubahan mesin menjadwalkan `simpanDraf` 600 ms kemudian; `dispose` membatalkan timer dan menulis draf sekali lagi lewat notifier yang disimpan di field. `Batal` memanggil `mesin.batal()`; `Mulai lagi` memanggil `mesin.mulaiLagi()` lalu membacakan `mewarnaiSayClear`; memilih alat membacakan petunjuknya; krayon yang dipilih saat alat `hapus`/`cap` mengembalikan alat ke `kuas`; memilih cap mengembalikan alat ke `cap`. Halaman tak dikenal → `context.go(Routes.mewarnai)` setelah frame pertama.
  - ARB: `mewarnaiBackGaleri` "Kembali ke galeri"/"Back to pictures"; `mewarnaiChangePage` "Gambar"/"Pictures"; `mewarnaiUndo` "Batal"/"Undo"; `mewarnaiClear` "Mulai lagi"/"Start over"; `mewarnaiSave` "Simpan"/"Save"; `mewarnaiTools` "Alat"/"Tools"; `mewarnaiToolBrush` "Kuas"/"Brush"; `mewarnaiToolFill` "Isi"/"Fill"; `mewarnaiToolErase` "Hapus"/"Eraser"; `mewarnaiToolCap` "Stiker"/"Sticker"; `mewarnaiBrushSize` "Ukuran kuas"/"Brush size"; `mewarnaiBrushSmall` "Kuas kecil"/"Small brush"; `mewarnaiBrushMedium` "Kuas sedang"/"Medium brush"; `mewarnaiBrushBig` "Kuas besar"/"Big brush"; `mewarnaiCrayons` "Krayon"/"Crayons"; `mewarnaiCaps` "Stiker"/"Stickers"; `mewarnaiHintBrush` (narasi); `mewarnaiHintFill` (narasi); `mewarnaiHintErase` (narasi); `mewarnaiHintCap` (narasi); `mewarnaiCanvasLabel` "Gambar untuk diwarnai: {nama}"/"Picture to color: {nama}"; `mewarnaiSayClear` (narasi) "Ayo mulai dari awal!"/"Let's start over!".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft + Offset(x, y) * skalaLayar;
Future<void> _buka(WidgetTester t, {TestEnv? env, String halaman = 'kupu'}) async {
  await pumpApp(t, env: env, initialLocation: '/mewarnai/$halaman');
  await t.pump();
  await t.pump();
}
bool _bisaBatal(WidgetTester t) =>
    t.widget<MociPressable>(find.byKey(KanvasScreen.undoKey)).onTap != null;
testWidgets('kanvas: judul, 864 x 648, 16 krayon, dan 4 alat', (t) async {
  await _buka(t);
  expect(find.text('Kupu-kupu'), findsOneWidget);
  expect(t.getSize(find.byKey(KanvasScreen.canvasKey)), const Size(864, 648));
  expect(t.getSize(find.byKey(KanvasScreen.toolbarKey)), const Size(248, 648));
  for (final hex in ['#FF4B4B', '#FF922B', '#FFD43B', '#FFFFFF']) {
    expect(find.byKey(KanvasScreen.crayonKey(hex)), findsOneWidget);
  }
  for (final a in AlatMewarnai.values) {
    expect(find.byKey(KanvasScreen.toolKey(a)), findsOneWidget);
  }
  expect(find.byKey(KanvasScreen.crayonKey('#123456')), findsNothing);
});
testWidgets('isi memakai warna krayon dan menulis draf', (t) async {
  final env = TestEnv();
  await _buka(t, env: env);
  await t.tap(find.byKey(KanvasScreen.crayonKey('#FF4B4B')));
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
  await t.pump();
  await t.tapAt(_kanvas(t, 400, 100));
  await t.pump(const Duration(milliseconds: 700));
  final json = await env.json.read('draf/kupu.json');
  expect(json, isNotNull);
  expect((json!['isian'] as Map).values, contains('#FF4B4B'));
});
testWidgets('batal mengembalikan isian dan mulai lagi bisa dibatalkan', (t) async {
  final env = TestEnv();
  await _buka(t, env: env);
  expect(_bisaBatal(t), isFalse); // draf baru: belum ada langkah
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
  await t.pump();
  await t.tapAt(_kanvas(t, 400, 100));
  await t.pump();
  expect(_bisaBatal(t), isTrue);
  await t.tap(find.byKey(KanvasScreen.undoKey));
  await t.pump(const Duration(milliseconds: 700));
  expect(((await env.json.read('draf/kupu.json'))!['isian'] as Map), isEmpty);
  await t.tapAt(_kanvas(t, 400, 100));
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.clearKey));
  await t.pump(const Duration(milliseconds: 700));
  expect(((await env.json.read('draf/kupu.json'))!['isian'] as Map), isEmpty);
  await t.tap(find.byKey(KanvasScreen.undoKey));
  await t.pump(const Duration(milliseconds: 700));
  expect(((await env.json.read('draf/kupu.json'))!['isian'] as Map), isNotEmpty);
  expect(find.text('Ayo mulai dari awal!'), findsNothing); // narasi lewat TTS, bukan teks layar
});
testWidgets('membuka lagi memuat draf halaman', (t) async {
  final env = TestEnv();
  await env.json.write('draf/ikan.json', {
    'versi': 1, 'halaman': 'ikan', 'isian': {'2': '#1C7ED6'}, 'coretan': {}, 'cap': [],
  });
  await _buka(t, env: env, halaman: 'ikan');
  expect(find.text('Ikan'), findsOneWidget);
  final mesin = t.widget<ColoringCanvas>(find.byType(ColoringCanvas)).mesin;
  expect(mesin.data.isian[2], '#1C7ED6');
  expect(_bisaBatal(t), isFalse);
});
testWidgets('ukuran kuas besar menulis coretan 44 unit', (t) async {
  final env = TestEnv();
  await _buka(t, env: env);
  await t.tap(find.byKey(KanvasScreen.sizeKey(UkuranKuas.besar)));
  await t.pump();
  final g = await t.startGesture(_kanvas(t, 10, 10));
  for (var i = 1; i <= 6; i++) {
    await g.moveTo(_kanvas(t, 10 + i * 8, 10));
    await t.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await t.pump(const Duration(milliseconds: 700));
  final json = await env.json.read('draf/kupu.json');
  final coretan = (json!['coretan'] as Map).values.first as List;
  expect((coretan.first as Map)['lebar'], 44);
});
testWidgets('hapus memakai kuas putih 54 unit', (t) async {
  final env = TestEnv();
  await _buka(t, env: env);
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.hapus)));
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.sizeKey(UkuranKuas.besar)));
  await t.pump();
  final g = await t.startGesture(_kanvas(t, 10, 10));
  await g.moveTo(_kanvas(t, 50, 10));
  await t.pump(const Duration(milliseconds: 16));
  await g.up();
  await t.pump(const Duration(milliseconds: 700));
  final json = await env.json.read('draf/kupu.json');
  final coretan = (json!['coretan'] as Map).values.first as List;
  expect((coretan.first as Map)['warna'], '#FFFFFF');
  expect((coretan.first as Map)['lebar'], 54);
});
testWidgets('stiker ditempel di kanvas dan tersimpan di draf', (t) async {
  final env = TestEnv();
  await _buka(t, env: env);
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.cap)));
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.capKey('moci-senang')));
  await t.pump();
  await t.tapAt(_kanvas(t, 640, 410));
  await t.pump(const Duration(milliseconds: 700));
  final json = await env.json.read('draf/kupu.json');
  expect((json!['cap'] as List).single, {'cap': 'moci-senang', 'x': 640.0, 'y': 410.0});
});
testWidgets('halaman tak dikenal kembali ke galeri', (t) async {
  final router = await pumpApp(t, initialLocation: '/mewarnai/entah');
  await t.pump();
  await t.pump();
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/mewarnai');
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/kanvas_screen_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`, `KanvasScreen` belum ada).
- [ ] **Step 3: Implementasikan layar, toolbar, krayon, ikon, rute, dan kunci ARB.** Pilih `page = coloringProvider.byId(halaman)`; bungkus kanvas dengan `ColoringCanvas(mesin: _mesin!, cap: capPictures, semanticLabel: l10n.mewarnaiCanvasLabel(nama))`. Simpan notifier `KaryaController` di field untuk penulisan draf saat `dispose`. Tampilkan petunjuk alat aktif di baris bawah, dan bacakan petunjuknya saat alat dipilih lewat `Narrator.sayAll([NarrationLine(jenis: 'ui', id: 'mewarnaiHintFill', text: l10n.mewarnaiHintFill)], prefs.lang)`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): Kanvas dengan alat, 16 krayon, batal, dan draf otomatis`.

---

### Task 7: Simpan karya dan pemilih gambar

**Files:**
- Create: `lib/features/mewarnai/widgets/wide_dialog.dart`, `lib/features/mewarnai/widgets/page_picker.dart`
- Modify: `lib/features/mewarnai/kanvas_screen.dart`, `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/mewarnai/kanvas_simpan_test.dart`

**Interfaces:**
- Consumes: `karyaProvider`, `renderKaryaPng`, `capPictureProvider`, `coloringProvider`, `MociPressable`, `MociDialogButton`, `MociIllustration`, `PageThumbnail`, `recordKarya`, `markItem`, `Narrator`, `Sfx`, `showGeneralDialog`.
- Produces:
  - `Future<T?> showWideDialog<T>(BuildContext context, {required WidgetBuilder builder, double maxWidth = 1020, double radius = 36});` — `showGeneralDialog`, scrim `rgba(43,35,80,.55)` 200 ms, panel putih, `PopScope(canPop: false)`, `SafeArea` + `SingleChildScrollView`, teks dibatasi 1,3× seperti `MociDialog`.
  - `class PagePickerDialog extends ConsumerWidget { const PagePickerDialog({super.key, required this.halamanAktif, required this.onPick}); }` — judul `mewarnaiPickPage` 34 + tombol tutup 60 (`mewarnaiClose`), kisi 5 kolom 14 kartu (thumbnail 172 × 129, nama 18, aktif berlatar `#FFF1D6`), lebar 968.
  - `KanvasScreen` mendapat tombol `Gambar` (`mewarnaiChangePage`) yang membuka `PagePickerDialog`; memilih halaman menulis draf halaman sekarang lebih dulu lalu `context.pushReplacement('/mewarnai/<id>')`.
  - Simpan: `static const saveKey = ValueKey('kanvas-save'); static const toastKey = ValueKey('kanvas-toast');` Tombol `Simpan` ditambahkan di kanan bilah atas (hijau, tinggi 58). Bila `_menyimpan` true, ketukan diabaikan. Alur: `mesin.akhiri()` → `renderKaryaPng(halaman: page, data: mesin.data, cap: capPictures)` → `karyaProvider.notifier.simpanKarya(mesin.data, png)` → `recordKarya()` sekali → `markItem('mewarnai', 'diwarnai', halaman)` → toast `mewarnaiSaved` 1800 ms → `Narrator.sayAll([mewarnaiSaySaved])` + `Sfx.bintang`. Galat tulis ditangkap: toast tidak muncul, draf tetap, `_menyimpan` kembali false.
  - ARB tambahan: `mewarnaiSaved` "Tersimpan di Karyaku!"/"Saved to My Artwork!"; `mewarnaiSaySaved` (narasi) "Tersimpan! Bagus sekali!"/"Saved! Beautiful work!"; `mewarnaiPickPage` "Pilih gambar"/"Pick a picture"; `mewarnaiClose` "Tutup"/"Close".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
Future<void> _buka(WidgetTester t, TestEnv env) async {
  await pumpApp(t, env: env, initialLocation: '/mewarnai/kupu');
  await t.pump();
  await t.pump();
}
Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft + Offset(x, y) * skalaLayar;
testWidgets('simpan menulis karya dengan PNG dan mencatat progres', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
  await t.pump();
  await t.tapAt(_kanvas(t, 400, 100));
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  final files = await env.json.list('karya');
  expect(files, hasLength(1));
  final json = await env.json.read('karya/${files.single}');
  expect(base64Decode(json!['gambar'] as String).sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  expect(json['halaman'], 'kupu');
  expect(find.byKey(KanvasScreen.toastKey), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), contains('Tersimpan! Bagus sekali!'));
  expect(_progress(t).perkembangan['mewarnai']!['diwarnai'], ['kupu']);
});
testWidgets('menekan simpan dua kali hanya membuat satu karya', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  expect(await env.json.list('karya'), hasLength(1));
});
testWidgets('simpan menyertakan goresan terakhir', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  final g = await t.startGesture(_kanvas(t, 10, 10));
  await g.moveTo(_kanvas(t, 60, 10));
  await t.pump(const Duration(milliseconds: 16));
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await g.up();
  await t.pump();
  await t.pump();
  final files = await env.json.list('karya');
  final json = await env.json.read('karya/${files.single}');
  expect((json!['coretan'] as Map).values, isNotEmpty);
});
testWidgets('toast hilang setelah 1800 ms', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  expect(find.byKey(KanvasScreen.toastKey), findsOneWidget);
  await t.pump(const Duration(milliseconds: 1800));
  expect(find.byKey(KanvasScreen.toastKey), findsNothing);
});
testWidgets('simpan tidak menghapus draf', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
  await t.pump();
  await t.tapAt(_kanvas(t, 400, 100));
  await t.pump(const Duration(milliseconds: 700));
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  expect(await env.json.read('draf/kupu.json'), isNotNull);
});
testWidgets('pemilih gambar berpindah halaman', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/mewarnai/kupu');
  await t.pump();
  await t.pump();
  await t.tap(find.text('Gambar'));
  await t.pump();
  expect(find.text('Pilih gambar'), findsOneWidget);
  await t.tap(find.text('Ikan'));
  await t.pump();
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/mewarnai/ikan');
});
testWidgets('simpan dua halaman menghasilkan dua karya', (t) async {
  final env = TestEnv();
  await _buka(t, env);
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  await t.tap(find.text('Gambar'));
  await t.pump();
  await t.tap(find.text('Ikan'));
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(KanvasScreen.saveKey));
  await t.pump();
  await t.pump();
  expect(await env.json.list('karya'), hasLength(2));
});
```
`_progress` membaca `progressProvider` lewat `ProviderScope.containerOf(t.element(find.byType(MociApp)))`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/kanvas_simpan_test.dart`. Expected: FAIL (`saveKey` belum ada).
- [ ] **Step 3: Implementasikan dialog lebar, pemilih halaman, dan alur Simpan.** `renderKaryaPng` dipanggil dengan `lebar/tinggi` bawaan; bungkus dalam `try/catch` untuk M14. Catat progres hanya setelah tulisan berhasil. Pastikan `mesin.akhiri()` dipanggil sebelum membaca `data` sehingga goresan yang masih aktif ikut tersimpan.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(mewarnai): simpan karya dengan PNG, toast, dan pemilih gambar`.

---

### Task 8: Layar Karyaku

**Files:**
- Create: `lib/features/mewarnai/karyaku_screen.dart`, `lib/features/mewarnai/widgets/karya_card.dart`, `lib/features/mewarnai/widgets/karya_detail_dialog.dart`
- Modify: `lib/app/router.dart` (ganti `_soon(Routes.karyaku, …)`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/mewarnai/karyaku_screen_test.dart`

**Interfaces:**
- Consumes: `karyaProvider`, `coloringProvider`, `showWideDialog`, `MociDialogButton`, `MociButton`, `ColoringView`, `ColoringPage.kategori`, `Bilingual.of`, `Routes.mewarnaiHalaman`, `Sfx`.
- Produces:
  - `class KaryaCard extends StatelessWidget { const KaryaCard({super.key, required this.karya, required this.halaman, required this.nama, required this.onTap, this.index = 0}); }` — kartu 330 × 290, pita 92 × 30 (`#FF8FB1/#74C0FC/#8CE99A/#FFD43B/#B197FC/#FFA94D`), pratinjau 300 × 225 (PNG via `Image.memory` dengan `errorBuilder`/`gambar` kosong → `ColoringView`), nama 22.
  - `class KaryaDetailDialog extends StatefulWidget { const KaryaDetailDialog({super.key, required this.karya, required this.halaman, required this.nama}); static Future<KaryaAksi?> show(...); }` dengan `enum KaryaAksi { warnaiLagi, hapus, tutup }`; panel: pratinjau 720 × 540 dari data, panel kanan 210 (judul 32, `Warnai lagi`, `Hapus`/`Yakin hapus?`, `Tutup`), radius 40.
  - `class KaryakuScreen extends ConsumerStatefulWidget { const KaryakuScreen({super.key}); static ValueKey<String> cardKey(String id); static const emptyKey = ValueKey('karyaku-empty'); }`
  - Tata letak `MociStage(theme: MenuTheme.karyaku)`: bilah atas (`MociBackButton(semanticLabel: l10n.mewarnaiBackGaleri, onTap: context.go(Routes.mewarnai))`, `mewarnaiKaryaku` 44, pil jumlah karya 58), petunjuk 19 `#8A6A1F` di kiri 70 / atas 116, kisi 3 kolom (jarak 34 × 40) di kiri 70 / atas 160 / lebar 1070 / tinggi 620 yang bisa digulir. Kosong: `MociMascot(size: 220)`, `mewarnaiKaryakuEmpty` 44, `mewarnaiKaryakuEmptyHint` 22, `MociButton(mewarnaiPickPage)` → `context.go(Routes.mewarnai)`.
  - Aksi: `warnaiLagi` → `karyaProvider.notifier.simpanDraf(karya.data)` lalu `context.push('/mewarnai/${karya.data.halaman}')`; `hapus` (dua ketukan di dialog) → `hapusKarya(id)` + `Sfx.klik`; `tutup` → kembali ke kisi. Halaman yang tidak ada di `pages.json` ditampilkan sebagai kartu tanpa pratinjau (nama = id) agar karya lama tidak hilang.
  - ARB tambahan: `mewarnaiKaryakuHint` "Ketuk gambar untuk melihatnya lebih besar."/"Tap a picture to see it bigger."; `mewarnaiKaryakuEmpty` "Belum ada karya"/"No artwork yet"; `mewarnaiKaryakuEmptyHint` "Yuk mewarnai dulu! Tekan Simpan, nanti gambarmu muncul di sini."/"Let's color something! Tap Save and your picture will show up here."; `mewarnaiColorAgain` "Warnai lagi"/"Color again"; `mewarnaiDelete` "Hapus"/"Delete"; `mewarnaiDeleteConfirm` "Yakin hapus?"/"Delete for sure?"; `mewarnaiViewArt` "Lihat karya: {nama}"/"See artwork: {nama}".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
Future<void> _tulisKarya(TestEnv env, String id, String halaman, {int hari = 14, String gambar = ''}) =>
    env.json.write('karya/$id.json', {
      'versi': 1, 'id': id, 'halaman': halaman,
      'isian': {'1': '#FF4B4B'}, 'coretan': {}, 'cap': [],
      'waktu': '2026-11-${hari.toString().padLeft(2, '0')}T10:00:00.000',
      'gambar': gambar,
    });
testWidgets('kosong: ajakan mewarnai', (t) async {
  await pumpApp(t, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  expect(find.text('Karyaku'), findsOneWidget);
  expect(find.byKey(KaryakuScreen.emptyKey), findsOneWidget);
  expect(find.text('Belum ada karya'), findsOneWidget);
});
testWidgets('tiga karya: hitungan, nama, dan urutan', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu', hari: 12);
  await _tulisKarya(env, 'k2', 'ikan', hari: 13);
  await _tulisKarya(env, 'k3', 'rumah', hari: 14);
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  expect(find.text('3 karya'), findsOneWidget);
  expect(find.byKey(KaryakuScreen.cardKey('k3')), findsOneWidget);
  expect(find.text('Rumah'), findsOneWidget);
});
testWidgets('buka karya: pratinjau besar dan tutup', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu');
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(KaryakuScreen.cardKey('k1')));
  await t.pump();
  expect(find.text('Warnai lagi'), findsOneWidget);
  await t.tap(find.text('Tutup'));
  await t.pump();
  expect(find.text('Warnai lagi'), findsNothing);
});
testWidgets('hapus dua langkah', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu');
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(KaryakuScreen.cardKey('k1')));
  await t.pump();
  await t.tap(find.text('Hapus'));
  await t.pump();
  expect(find.text('Yakin hapus?'), findsOneWidget);
  await t.tap(find.text('Yakin hapus?'));
  await t.pump();
  await t.pump();
  expect(await env.json.list('karya'), isEmpty);
  expect(find.byKey(KaryakuScreen.emptyKey), findsOneWidget);
});
testWidgets('warnai lagi menyalin karya ke draf lalu membuka kanvas', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu');
  final router = await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(KaryakuScreen.cardKey('k1')));
  await t.pump();
  await t.tap(find.text('Warnai lagi'));
  await t.pump();
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/mewarnai/kupu');
  final draf = await env.json.read('draf/kupu.json');
  expect((draf!['isian'] as Map)['1'], '#FF4B4B');
});
testWidgets('hapus karya tidak menghapus draf', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu');
  await env.json.write('draf/kupu.json', {
    'versi': 1, 'halaman': 'kupu', 'isian': {'2': '#1C7ED6'}, 'coretan': {}, 'cap': [],
  });
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  await t.tap(find.byKey(KaryakuScreen.cardKey('k1')));
  await t.pump();
  await t.tap(find.text('Hapus'));
  await t.pump();
  await t.tap(find.text('Yakin hapus?'));
  await t.pump();
  await t.pump();
  expect(await env.json.read('draf/kupu.json'), isNotNull);
});
testWidgets('dua belas karya dan hitungannya', (t) async {
  final env = TestEnv();
  for (var i = 0; i < 12; i++) {
    await _tulisKarya(env, 'k$i', 'kupu', hari: i + 1);
  }
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  expect(find.text('12 karya'), findsOneWidget);
  await t.drag(find.byType(GridView), const Offset(0, -600));
  await t.pump();
  expect(t.takeException(), isNull);
});
testWidgets('gambar rusak jatuh ke pratinjau dari data', (t) async {
  final env = TestEnv();
  await _tulisKarya(env, 'k1', 'kupu', gambar: 'bukan-png');
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  await t.pump();
  await t.pump();
  expect(find.byKey(KaryakuScreen.cardKey('k1')), findsOneWidget);
  expect(t.takeException(), isNull);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/mewarnai/karyaku_screen_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implementasikan layar, kartu, dialog, rute, dan kunci ARB.** Salin teks dari `Karyaku.dc.html` objek `T`. `GridBuilder` memakai `GridView.builder` dengan `controller` biasa dan `padding: EdgeInsets.zero`. Dialog detail memakai `showWideDialog` dengan `maxWidth: 1008`, `radius: 40`. Bila `karya.png` kosong, `KaryaCard` memakai `ColoringView` dari `karya.data`; bila halaman tidak ada di `coloringProvider`, tampilkan kotak putih berisi nama halaman sebagai ganti pratinjau.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/mewarnai`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(karyaku): layar 12 karya dengan hapus dua langkah dan warnai lagi`.

---

### Task 9: Dokumentasi, uji integrasi, dan pemeriksaan akhir

**Files:**
- Modify: `docs/TECH-SPEC.md`, `SYSTEM_DESIGN.md`, `integration_test/app_test.dart`
- Test: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: semua task sebelumnya.
- Produces: skema berkas tertulis, penyimpanan terdokumentasi, dan satu skenario perangkat.

Dokumentasi yang harus berubah:
- `docs/TECH-SPEC.md` §Data dan penyimpanan lokal: baris `Karya` menyebut `karya/<id>.json` berisi `gambar` (PNG 300 × 225 base64) dan tetap maksimal 12 berkas / 200 KB; tambahkan contoh JSON karya dan draf sesuai bentuk di Task 1; tambahkan aturan "thumbnail Karyaku memakai PNG yang diekspor saat Simpan, Galeri memakai warna contoh dari data".
- `docs/TECH-SPEC.md` §Mewarnai: ganti butir 8 dengan aturan PNG di atas, dan tambahkan angka yang dipakai kode: kuas 14/26/44, hapus +10, stiker 90 unit, riwayat 30, draf 600 ms, 16 krayon, 8 stiker, 12 karya.
- `SYSTEM_DESIGN.md`: §Data dan penyimpanan menyebut `karya/` dan `draf/` beserta PNG di dalam JSON, `karyaProvider`, batas 12; peta fitur menyebut `lib/features/mewarnai/` (galeri, kanvas, karyaku, mesin, painter); daftar rute menyebut `/mewarnai`, `/mewarnai/:halaman`, `/karyaku` tidak lagi `ComingSoonScreen`.
- `integration_test/app_test.dart`: tambah `testWidgets('mewarnai: isi, simpan, lalu karyaku', …)` — buka Beranda, ketuk kartu Mewarnai, pilih "Ikan", pilih alat Isi dan krayon pertama, ketuk tengah kanvas, tekan Simpan sampai toast muncul, kembali ke Galeri, buka Karyaku, dan pastikan satu kartu muncul. Tidak memakai `pumpAndSettle`; penantian lewat `_pumpUntil` yang sudah ada.

- [ ] **Step 1: Tulis uji integrasi** dengan langkah di atas memakai `_prepareDevice` dan `runMoci(overrides: _quietAudio(...))` yang sudah ada.
- [ ] **Step 2: Jalankan di perangkat.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS. Kegagalan di sini adalah bug integrasi (router, penyimpanan, raster PNG): perbaiki layarnya, bukan tesnya.
- [ ] **Step 3: Perbarui dokumentasi** sesuai daftar di atas. Jangan menyalin isi spec; tulis hanya yang berubah di kode.
- [ ] **Step 4: Jalankan uji integrasi lagi.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS.
- [ ] **Step 5: Pemeriksaan akhir.** Run:
```bash
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
fvm dart run tool/validate_content.dart
```
Expected: format dan analyze bersih; semua tes PASS; validator keluar dengan kode 0 dan hanya peringatan (`mewarnai_contoh`, `narasi_lengkap` untuk rekaman yang belum ada).
- [ ] **Step 6: Commit** dengan pesan `docs(mewarnai): skema karya, penyimpanan, dan uji integrasi`.
