# Moci — Rencana Dokumentasi Repo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repo punya dokumentasi untuk manusia dan agen:
- `AGENTS.md` sebagai sumber kanonis instruksi agen, dan `CLAUDE.md` yang merujuk ke sana.
- `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, `DESIGN.md`, `CONTRIBUTING.md`, dan `LICENSE`.
- `.gitignore` yang lengkap, `README.md` yang mutakhir, dan salinan spec Claude Docs di `docs/`.

**Architecture:** Dijalankan setelah Rencana 01 dan 02, supaya dokumen menggambarkan kode yang benar-benar ada.
- **Dokumen root** menjelaskan sistem seperti yang dibangun, dan menautkan ke spec asli.
- **`docs/`** menyimpan salinan spec (PRD, spesifikasi teknis, sistem desain, konten, privasi) sebagai sumber kebenaran produk.
- **Tes `test/docs/dokumen_test.dart`** menjaga semua path dan tautan di dokumen tetap valid.

**Tech Stack:** Markdown, dan Dart (`dart:io`) untuk tes dokumen.

**Spec:**
- Permintaan pemilik repo per 14 November 2026: tambahkan `.gitignore`, `LICENSE`, `CONTRIBUTING`, `AGENTS.md`, `CLAUDE.md` (wajib merujuk `AGENTS.md`), `DESIGN.md`, `SYSTEM_DESIGN.md`, `ARCHITECTURE.md`, dan dokumen lain yang dibutuhkan agen. Perbarui juga `README.md`, dan tinjau file yang sudah di-commit.
- Tab Ringkasan di [Dokumentasi Moci](https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H), yang menetapkan nama file ekspor spec.
- `docs/superpowers/plans/2026-11-14-moci-roadmap.md`.

## Global Constraints

- **Bahasa:** dokumen ditulis dalam Bahasa Indonesia, kecuali istilah teknis dan identifier kode. Kalimat pendek dan spesifik. Tanpa emoji.
- **`AGENTS.md` adalah satu-satunya sumber instruksi agen.** `CLAUDE.md` hanya berisi rujukan `@AGENTS.md` ditambah satu kalimat pengantar. Isi instruksi tidak boleh disalin ke `CLAUDE.md`.
- **Nama file salinan spec mengikuti tab Ringkasan:** `docs/PRD.md`, `docs/TECH-SPEC.md`, `docs/DESIGN-SYSTEM.md`, `docs/CONTENT-ASSETS.md`, dan `docs/PRIVACY-RELEASE.md`. Isi tab Ringkasan sendiri masuk ke `docs/README.md`.
- **Path dan perintah harus nyata.** Setiap path repo yang disebut di dokumen root harus ada, dan setiap perintah yang ditulis harus berhasil dijalankan di repo ini.
- **Lisensi:** pemilik belum memilih lisensi terbuka (pertanyaan terbuka di spec). `LICENSE` menyatakan "seluruh hak dilindungi" sesuai README saat ini, dan mencantumkan lisensi pihak ketiga (font OFL, audio CC0, paket Dart/Flutter).
- **Audio:** sumber suara adalah Freesound CC0, atau rekaman sendiri (`Milik sendiri`). Pixabay dan CC BY tidak dipakai.
- **File lama tidak dihapus.** `docs/brand/` adalah sumber ikon dan splash, dan `docs/screenshots/` dipakai README. Keduanya tetap ada.

## Review Focus

1. **Agen baru yang hanya membaca `AGENTS.md`** harus bisa menjalankan tes, validator, dan golden tanpa membaca rencana. Dipatok di Task 2: setiap perintah di `AGENTS.md` dijalankan saat task.
2. **Dokumen yang basi setelah kode berubah**, misalnya file dipindah. Tes path di `dokumen_test.dart` gagal kalau path yang disebut sudah tidak ada. Dipatok di Task 2 dan Task 3.
3. **Rahasia signing ikut ter-commit** (`key.properties`, `*.jks`, `*.keystore`, `*.p12`, `.env`). `.gitignore` menolaknya. Dipatok di Task 4.
4. **Salinan spec yang menyimpang dari Claude Docs:** angka, daftar, atau tabel yang hilang saat disalin. Dipatok di Task 1: setiap judul bagian dan setiap tabel dicocokkan.
5. **`CLAUDE.md` yang menyimpan instruksi sendiri**, sehingga isinya bisa berbeda dengan `AGENTS.md`. Dipatok di Task 2.

---

### Task 1: Salin spec Claude Docs ke `docs/`

**Files:**
- Create: `docs/README.md` (indeks dokumen + isi tab Ringkasan), `docs/PRD.md`, `docs/TECH-SPEC.md`, `docs/DESIGN-SYSTEM.md`, `docs/CONTENT-ASSETS.md`, `docs/PRIVACY-RELEASE.md`

**Interfaces:**
- Produces: enam file yang dirujuk oleh `AGENTS.md`, `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, `DESIGN.md`, dan `README.md` di task berikutnya.

Sumber: dokumen Claude Docs berid `e54bf4be-8b5b-483e-aed8-64d6d6bca7aa`.

| Tab | Id node | File |
| --- | --- | --- |
| Ringkasan | `f6d3e016-8efc` | `docs/README.md` |
| PRD | `fa83e526-fe38` | `docs/PRD.md` |
| Spesifikasi Teknis | `1de39c71-a0a3` | `docs/TECH-SPEC.md` |
| Sistem Desain | `752d6c89-9ad6` | `docs/DESIGN-SYSTEM.md` |
| Konten & Aset | `4d0c5ffa-9ed8` | `docs/CONTENT-ASSETS.md` |
| Privasi & Rilis | `f59bbfbb-9b7b` | `docs/PRIVACY-RELEASE.md` |

Cara baca:
1. Muat tool Claude Docs lewat ToolSearch (`select:mcp__claude_ai_Claude_Docs__read`).
2. Panggil `read(ref = {"object":"node","id":"<id node>"}, engine = "prose", container = {"kind":"project","id":"e54bf4be-8b5b-483e-aed8-64d6d6bca7aa"}, payload = {"kind":"view"})`.
3. Kalau hasilnya disimpan ke file karena terlalu besar, baca file itu.

Aturan menyalin:
- Isi disalin **apa adanya**: semua judul, paragraf, daftar, tabel (sebagai tabel pipe), blok kode, dan tautan.
- Chip tanggal ditulis sebagai teks `2026-11-14`.
- Chip dropdown ditulis sebagai teks pilihannya, misalnya `Diputuskan`.
- Embed diagram atau grafik diganti satu baris: `> Diagram: <caption> — lihat dokumen asli di Claude Docs.`
- Setiap file diawali baris `> Salinan dari Claude Docs "Dokumentasi Moci", tab <nama>, per 2026-11-14. Sumber kebenaran: <link dokumen>.`
- `docs/README.md` menambahkan bagian "Peta dokumentasi" di bawah isi Ringkasan, berisi tautan ke kelima file spec, `docs/superpowers/plans/`, `docs/design/`, dan `docs/audio/SUARA-HEWAN.md`.

- [ ] **Step 1: Baca setiap tab, lalu tulis file-nya** sesuai aturan di atas.
- [ ] **Step 2: Cocokkan isinya**

Untuk setiap tab:
1. Daftar judul (`heading`) di hasil `read` harus sama dan berurutan dengan judul Markdown di file.
2. Jumlah `<table>` di hasil `read` harus sama dengan jumlah tabel Markdown.

Catat hasil pencocokan di laporan task. Expected: semua cocok.

- [ ] **Step 3: Commit** dengan pesan `docs: salinan spec Claude Docs (PRD, teknis, desain, konten, privasi)`.

---

### Task 2: `AGENTS.md`, `CLAUDE.md`, dan tes dokumen

**Files:**
- Create: `AGENTS.md`, `CLAUDE.md`, `test/docs/dokumen_test.dart`

**Interfaces:**
- Consumes: kode dan tooling hasil Rencana 01 dan 02, plus `docs/*.md` dari Task 1.
- Produces:
  - `dokumen_test.dart`, yang di task ini memeriksa `AGENTS.md` dan `CLAUDE.md`, lalu diperluas di Task 3–5 untuk dokumen lain.
  - Fungsi bantu di file tes yang sama: `List<String> pathRepoDi(String markdown)`. Fungsi ini mengambil tautan relatif `[..](path)` dan path dalam backtick yang diawali `lib/`, `test/`, `tool/`, `assets/`, `docs/`, `l10n/`, `integration_test/`, `ios/`, `android/`, atau `.github/`, tanpa glob (`*`, `<`, `>`).

Isi `AGENTS.md`. Setiap bagian ditulis singkat, berupa daftar atau tabel:
1. **Ringkasan proyek:** Moci, anak 2–7 tahun, offline, dua bahasa, iPad, iPhone, Android.
2. **Peta dokumentasi:** `docs/README.md`, kelima spec, `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, `DESIGN.md`, `CONTRIBUTING.md`, rencana di `docs/superpowers/plans/`, prototipe di `docs/design/prototype/`, inventaris konten, dan panduan suara hewan.
3. **Perintah:** semuanya lewat FVM.
   - `fvm flutter pub get`, `fvm flutter analyze`, `fvm dart format .`
   - `fvm flutter test --exclude-tags golden`, `fvm flutter test --tags golden`, plus `--update-goldens`
   - `fvm dart run tool/validate_content.dart`, `--naskah`, `--rilis`
   - `fvm flutter test integration_test -d <perangkat>`
   - `fvm flutter run`
4. **Aturan kode:**
   - Import `material_ui`, bukan `package:flutter/material.dart`.
   - Paket yang diizinkan, dan aturan menambah paket.
   - Tidak ada jaringan, izin, analytics, atau `google_fonts`.
   - Layar dibungkus `MociStage`.
   - Aturan permainan ditulis di `*_game.dart` sebagai Dart murni dengan `Random` yang bisa diberi seed.
   - Teks diambil dari ARB dengan kunci `<layar><KunciT>`, disalin persis dari prototipe.
   - Narasi di `assets/audio/vo/<lang>/<jenis>_<id>.m4a`, dan kalimat yang dibacakan ditandai `"description": "narasi"`.
5. **Aturan tes:**
   - TDD.
   - Fake di `test/helpers/` (`TestEnv`, `pumpScreen`, `pumpApp`), tanpa I/O nyata di `testWidgets`.
   - Golden hanya untuk Beranda, Hebat, dan Area Orang Tua, dijalankan di macOS.
6. **Konten:** katalog JSON adalah sumber kebenaran (ekspor prototipe hanya sekali). Cara menambah isi mengikuti `docs/CONTENT-ASSETS.md`. Audio hanya CC0 atau `Milik sendiri`, dicatat di `assets/audio/LICENSES.csv`.
7. **Git:**
   - Kerja di branch fitur, lalu PR ke `main`. Jangan push langsung ke `main`.
   - Satu commit per task, gaya `feat(area): …`.
   - Jalankan format, analyze, test, dan validator sebelum commit.
8. **Jangan:**
   - Menyentuh `docs/design/prototype/` (snapshot beku).
   - Meng-commit audio non-CC0 atau rahasia signing.
   - Menambah izin Android atau iOS tanpa memperbarui `docs/PRIVACY-RELEASE.md`.

Isi `CLAUDE.md` persis dua baris:
```
Instruksi untuk agen ada di AGENTS.md dan berlaku penuh di sini.
@AGENTS.md
```

- [ ] **Step 1: Tulis tes yang gagal**

```dart
void main() {
  test('CLAUDE.md hanya merujuk AGENTS.md', () {
    final lines = File('CLAUDE.md').readAsLinesSync().where((l) => l.trim().isNotEmpty).toList();
    expect(lines, contains('@AGENTS.md'));
    expect(lines.length, lessThanOrEqualTo(2));
  });
  test('path yang disebut AGENTS.md ada', () {
    for (final p in pathRepoDi(File('AGENTS.md').readAsStringSync())) {
      expect(FileSystemEntity.typeSync(p) != FileSystemEntityType.notFound, isTrue, reason: p);
    }
  });
  test('AGENTS.md memuat perintah inti', () {
    final s = File('AGENTS.md').readAsStringSync();
    for (final cmd in ['fvm flutter test', 'fvm flutter analyze', 'fvm dart run tool/validate_content.dart', 'material_ui']) {
      expect(s, contains(cmd));
    }
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/docs`. Expected: FAIL (file belum ada).
- [ ] **Step 3: Tulis `AGENTS.md` dan `CLAUDE.md`.**
- [ ] **Step 4: Jalankan setiap perintah yang ditulis di bagian "Perintah"** (kecuali `flutter run` dan integration test di perangkat), lalu catat hasilnya di laporan. Expected: semua berhasil.
- [ ] **Step 5: Jalankan tes.** Run: `fvm flutter test test/docs`. Expected: PASS.
- [ ] **Step 6: Commit** dengan pesan `docs: AGENTS.md kanonis dan CLAUDE.md yang merujuknya`.

---

### Task 3: `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, dan `DESIGN.md`

**Files:**
- Create: `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, `DESIGN.md`
- Modify: `test/docs/dokumen_test.dart` (path ketiga file harus valid)

**Interfaces:**
- Consumes: kode di `lib/`, `tool/`, `assets/`, rencana 01 dan 02 (termasuk tabel keputusan D1–D14 dan K1–K11), serta `docs/*.md`.

Pembagian isi, supaya ketiga dokumen tidak saling mengulang:

| File | Isi | Tidak berisi |
| --- | --- | --- |
| `ARCHITECTURE.md` | Struktur kode yang dibangun: diagram 5 lapisan dalam teks atau mermaid, peta folder dengan file nyata, daftar provider dan pemiliknya, tabel rute dan redirect, aliran state, harness tes dan fake, cara menambah layar atau menu baru (langkah-langkah) | Nilai visual dan alasan produk |
| `SYSTEM_DESIGN.md` | Perilaku sistem saat berjalan: batas privasi dan offline, data tersimpan (prefs, `progress.json`, `karya/`, `draf/`, beserta skema), pengatur waktu bermain, pipeline audio dan sesi iOS, rencana mikrofon (Rencana 03), pipeline konten dan validator, konfigurasi platform (orientasi, backup, izin), anggaran performa dan ukuran, CI dan rilis | Detail kelas per file |
| `DESIGN.md` | Sistem desain seperti diterapkan di kode: token (`MociColors`, `MenuTheme`, `MociText`, `MociSize`, `MociMotion`) dengan nilainya, komponen di `lib/widgets/` dan kapan dipakai, panggung tablet dan HP termasuk aturan HP sementara (D12), gerak dan reduced motion, umpan balik suara, aksesibilitas, cara membaca artboard prototipe, tabel keputusan desain D1–D14 | Arsitektur kode |

Setiap dokumen diawali satu paragraf yang menjelaskan isinya, lalu menautkan sumbernya di `docs/`.

- [ ] **Step 1: Perluas tes yang gagal.** Tambahkan ketiga file ke daftar dokumen yang path-nya diperiksa, dan pastikan setiap file memuat tautan ke minimal satu file `docs/*.md`.
- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/docs`. Expected: FAIL.
- [ ] **Step 3: Tulis ketiga dokumen** dari kode yang ada. Setiap nama kelas, provider, dan path harus dicek ke repo.
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `docs: ARCHITECTURE, SYSTEM_DESIGN, dan DESIGN sesuai kode`.

---

### Task 4: `CONTRIBUTING.md`, `LICENSE`, dan audit `.gitignore`

**Files:**
- Create: `CONTRIBUTING.md`, `LICENSE`
- Modify: `.gitignore`, `test/docs/dokumen_test.dart`

Isi `CONTRIBUTING.md`:
1. **Persiapan:** FVM, Flutter 3.50.0, Xcode 26 atau lebih baru, Android SDK 36, Python 3 (khusus `tool/fonts/build_fonts.sh`).
2. **Alur kerja:** branch fitur, lalu PR ke `main`, dengan CI hijau (analyze, format, test, golden, validator).
3. **Gaya commit.**
4. **TDD dan tes yang wajib lulus.**
5. **Memperbarui golden:** jalankan di macOS, lalu periksa diff gambarnya.
6. **Mengubah atau menambah isi:** edit JSON, jalankan validator, lalu buat naskah.
7. **Audio:** hanya CC0 dari Freesound atau rekaman sendiri, dicatat di `assets/audio/LICENSES.csv`, mengikuti `docs/audio/SUARA-HEWAN.md`.
8. **Checklist PR.**

Isi `LICENSE`:
- Baris pertama: `Hak cipta (c) 2026 Pandu dwi Putra. Seluruh hak dilindungi.`
- Paragraf bahwa kode, ilustrasi, dan aset brand tidak boleh dipakai, disalin, atau disebarkan tanpa izin tertulis.
- Bagian "Komponen pihak ketiga":
  - Font Fredoka dan Nunito di bawah SIL Open Font License 1.1 (`assets/fonts/OFL-*.txt`).
  - Audio CC0 sesuai `assets/audio/LICENSES.csv`.
  - Paket Dart dan Flutter dengan lisensinya masing-masing.

`.gitignore` harus menolak path berikut. Setiap path di bawah diuji dengan `git check-ignore`:
- `.fvm/flutter_sdk`
- `.superpowers/sdd/x`
- `build/x`
- `.dart_tool/x`
- `ios/Pods/x`
- `android/key.properties`
- `android/app/upload.jks`
- `release.keystore`
- `cert.p12`
- `.env`
- `.DS_Store`
- `coverage/lcov.info`
- `.idea/x`

`.gitignore` tidak boleh menolak `.fvmrc`, `pubspec.lock`, dan `assets/audio/LICENSES.csv`.

- [ ] **Step 1: Perluas tes yang gagal**

Tambahkan tes berikut ke `dokumen_test.dart`:
1. `LICENSE` diawali "Hak cipta (c) 2026" dan memuat "Open Font License".
2. `CONTRIBUTING.md` memuat `fvm flutter test` dan `LICENSES.csv`.
3. Untuk setiap path di daftar ditolak, `Process.runSync('git', ['check-ignore', '-q', path]).exitCode == 0`.
4. Untuk ketiga path yang tidak boleh ditolak, kode keluarnya `1`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/docs`. Expected: FAIL.
- [ ] **Step 3: Tulis kedua file, lalu lengkapi `.gitignore`.** Pertahankan entri template Flutter yang sudah ada.
- [ ] **Step 4: Jalankan tes.** Expected: PASS. Lalu jalankan `git status --short`, yang tidak boleh menunjukkan file yang seharusnya diabaikan.
- [ ] **Step 5: Commit** dengan pesan `docs: CONTRIBUTING, LICENSE, dan .gitignore yang menolak rahasia signing`.

---

### Task 5: Perbarui `README.md` dan status roadmap

**Files:**
- Modify: `README.md`, `docs/superpowers/plans/2026-11-14-moci-roadmap.md`, `test/docs/dokumen_test.dart`

Perubahan `README.md`. Bagian dan gambar yang sudah ada dipertahankan:
1. **Ringkasan dan English summary:** ganti "Flutter app in development" dengan status nyata, yaitu fondasi dan konten selesai, menu dibangun bertahap.
2. **Teknologi:** sesuaikan dengan kode, yaitu Flutter 3.50 dengan FVM, `material_ui`, `go_router`, Riverpod, `flutter_soloud`, `vector_graphics`, dan gen-l10n. Hapus `flutter_svg` dan `just_audio`, karena keduanya tidak dipakai.
3. **Struktur repo:** ganti struktur rencana dengan struktur nyata.
4. **Menjalankan aplikasi:** perintah FVM yang benar. Hapus catatan "Kode Flutter belum ada".
5. **Dokumentasi (bagian baru):** tautan ke `AGENTS.md`, `ARCHITECTURE.md`, `SYSTEM_DESIGN.md`, `DESIGN.md`, `CONTRIBUTING.md`, `docs/README.md`, dan rencana.
6. **Roadmap:** centang "Aplikasi Flutter: shell, navigasi, penyimpanan lokal". Ubah butir suara hewan menjadi "Suara hewan asli (CC0 dari Freesound atau rekaman sendiri)".
7. **Lisensi:** rujuk ke `LICENSE`.
8. **Tangkapan layar:** tambahkan satu kalimat bahwa tangkapan layar diambil dari prototipe interaktif.

Perubahan roadmap: Rencana 01 dan 02 diberi status "selesai (lihat git log branch feat/moci-v1)", dan ditambahkan satu baris tentang rencana dokumentasi ini.

- [ ] **Step 1: Perluas tes yang gagal.** `README.md` masuk daftar dokumen yang path-nya diperiksa, harus memuat `AGENTS.md` dan `LICENSE`, dan tidak lagi memuat "Kode Flutter belum ada".
- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/docs`. Expected: FAIL.
- [ ] **Step 3: Perbarui `README.md` dan roadmap.**
- [ ] **Step 4: Jalankan tes, lalu seluruh suite.** Run: `fvm flutter test test/docs && fvm flutter test --exclude-tags golden`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `docs: README dan roadmap sesuai kondisi repo`.
