# Instruksi agen Moci

Dokumen ini satu-satunya sumber instruksi untuk agen. `CLAUDE.md` hanya merujuk ke sini.

## 1. Ringkasan proyek

Moci adalah aplikasi belajar dan bermain untuk anak 2–7 tahun: offline penuh, dua bahasa (Indonesia dan English), untuk iPad, iPhone, HP Android, dan tablet Android. Kodenya Flutter 3.50 yang dikunci FVM di `.fvmrc`.

## 2. Peta dokumentasi

| Dokumen | Isi |
| --- | --- |
| `docs/README.md` | Ringkasan, keputusan, pertanyaan terbuka, peta dokumentasi |
| `docs/PRD.md` | Apa yang dibangun untuk v1: pengguna, prinsip, alur, fitur |
| `docs/TECH-SPEC.md` | Arsitektur, data, audio, performa, pengujian |
| `docs/DESIGN-SYSTEM.md` | Warna, huruf, ukuran, gerak, komponen |
| `docs/CONTENT-ASSETS.md` | Ilustrasi, katalog JSON, narasi, audio, cara menambah isi |
| `docs/PRIVACY-RELEASE.md` | Privasi, izin, syarat store, checklist rilis |
| `CONTRIBUTING.md` | Alur kerja, gaya commit, checklist PR |
| `docs/superpowers/plans/` | Rencana implementasi dan roadmap |
| `docs/design/prototype/` | Snapshot beku prototipe interaktif |
| `docs/design/notes/inventaris-konten.md` | Inventaris isi hasil ekspor prototipe |
| `docs/audio/SUARA-HEWAN.md` | Sumber dan lisensi suara hewan |

## 3. Perintah

Semua perintah Flutter lewat FVM.

| Keperluan | Perintah |
| --- | --- |
| Ambil paket | `fvm flutter pub get` |
| Analyze | `fvm flutter analyze` |
| Cek format | `fvm dart format --output=none --set-exit-if-changed lib test tool integration_test` |
| Tes tanpa golden | `fvm flutter test --exclude-tags golden` |
| Tes golden (macOS) | `fvm flutter test --tags golden` |
| Perbarui golden (macOS) | `fvm flutter test --tags golden --update-goldens` |
| Validator isi | `fvm dart run tool/validate_content.dart` |
| Naskah narasi | `fvm dart run tool/validate_content.dart --naskah=build/naskah.csv` |
| Validator mode rilis | `fvm dart run tool/validate_content.dart --rilis` |
| Integration test | `fvm flutter test integration_test -d <perangkat>` |
| Jalankan aplikasi | `fvm flutter run -d <perangkat>` |

- `--naskah` hanya terbaca dalam bentuk `--naskah=<path>`; bentuk terpisah diabaikan tanpa pesan.
- `--rilis` keluar dengan kode 1 selama belum ada rekaman narasi. Itu keadaan yang diharapkan, bukan bug. Validator menyebut setiap baris yang belum direkam.
- Format memakai daftar folder, bukan titik: `fvm dart format .` ikut memindai `build/test/listener_0.dart` setelah integration test berjalan.
- Golden hanya untuk Beranda, Hebat, dan Area Orang Tua, dan hanya dijalankan atau diperbarui di macOS.

## 4. Aturan kode

- Import Material dari `package:material_ui/material_ui.dart`, bukan `package:flutter/material.dart` yang deprecated di Flutter 3.50. Kode yang cukup dengan lapisan widget memakai `package:flutter/widgets.dart`.
- Paket yang diizinkan: `go_router`, `flutter_riverpod`, `shared_preferences`, `flutter_soloud`, `vector_graphics`, `vector_graphics_compiler`, `path_provider`, `url_launcher`, `flutter_localizations`, `intl`, dan `speech_to_text` untuk Rencana 03. Paket baru hanya boleh kalau tidak mengirim data, tidak menambah izin, dan masih dirawat. Tidak ada `google_fonts`, SDK analytics, atau crash reporting.
- Tidak ada jaringan, izin tambahan, atau telemetri. Manifest rilis Android tidak berisi izin apa pun.
- Setiap layar dibungkus `MociStage` dari `lib/app/layout/moci_stage.dart`, dengan satu `MenuTheme`.
- Aturan permainan ditulis di `*_game.dart` sebagai Dart murni, tanpa widget, dengan `Random` yang bisa diberi seed lewat provider.
- Teks UI diambil dari ARB `l10n/app_id.arb` dan `l10n/app_en.arb`, dengan kunci `<layar><KunciT>`, dan disalin persis dari prototipe.
- Kalimat yang dibacakan ditandai `"description": "narasi"` di ARB. Rekaman narasi ada di `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a`.

## 5. Aturan tes

- TDD: tulis tes yang gagal dulu, lalu kode sampai lulus.
- Fake dan helper ada di `test/helpers/`: `TestEnv`, `pumpScreen`, dan `pumpApp`. `testWidgets` tidak boleh menyentuh berkas atau jaringan sungguhan.
- Golden hanya untuk Beranda, Hebat, dan Area Orang Tua, dijalankan di macOS.
- Integration test memakai `runMoci(overrides:)` dan tidak memakai `pumpAndSettle`, karena maskot beranimasi terus.

## 6. Konten

- Katalog JSON di `assets/content/katalog.json` adalah sumber kebenaran. Ekspor dari `docs/design/prototype/` hanya sekali, lalu JSON diedit langsung.
- Cara menambah isi, aturan SVG, tracing, dan halaman mewarnai ada di `docs/CONTENT-ASSETS.md`.
- Audio hanya dari Freesound CC0 atau rekaman sendiri (`Milik sendiri`), dicatat di `assets/audio/LICENSES.csv`. Pixabay dan CC BY tidak dipakai. Aturan ini lebih ketat daripada `docs/CONTENT-ASSETS.md`, yang masih menyebut Pixabay dan CC BY; aturan ketat yang berlaku. Validator menegakkannya lewat `lisensi_audio_lengkap`.
- Setiap teks narasi baru wajib masuk naskah. `--rilis` gagal selama masih ada teks tanpa rekaman.

## 7. Git

- Kerja di branch fitur, lalu buka PR ke `main`. Jangan push langsung ke `main`.
- Satu commit per task, gaya `feat(area): ringkasan` atau `docs: ringkasan`.
- Sebelum commit: format, analyze, tes, dan validator.

## 8. Jangan

- Menyentuh `docs/design/prototype/`. Itu snapshot beku.
- Meng-commit audio non-CC0, berkas rahasia signing, atau `.env`. `.gitignore` menolaknya.
- Menambah izin Android atau iOS tanpa memperbarui `docs/PRIVACY-RELEASE.md`.
