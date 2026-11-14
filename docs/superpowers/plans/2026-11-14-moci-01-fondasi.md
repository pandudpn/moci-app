# Moci — Rencana 01: Fondasi Aplikasi — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplikasi Flutter Moci yang bisa dijalankan di iPad, iPhone, dan Android, berisi splash, Sambutan, Beranda (tablet dan HP), Gerbang dan Area Orang Tua, pengatur waktu (Istirahat dan Waktu Habis), dan layar Hebat. Fondasinya juga lengkap: tema, audio, penyimpanan lokal, dua bahasa, dan CI, siap ditempati menu-menu di rencana berikutnya.

**Architecture:** Satu aplikasi Flutter offline dengan lima lapisan seperti diagram di Spesifikasi Teknis: Layar → Shell → State → Layanan inti → Perangkat. `go_router` memegang semua rute dan redirect (Sambutan, Waktu Habis, Area Orang Tua). Riverpod 3 memegang state (`prefsProvider`, `progressProvider`, `playTimerProvider`). Setiap layar digambar di "panggung" berukuran desain (1180 × 820 tablet, 844 × 390 HP) yang diskalakan ke layar nyata. Aturan yang bisa dites (redirect, pengatur waktu, soal gerbang, hadiah, ringkasan) ditulis sebagai Dart murni.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart, `material_ui`, `go_router` 18, `flutter_riverpod` 3, `shared_preferences`, `path_provider`, `flutter_soloud` 5, `vector_graphics` + `vector_graphics_compiler`, `url_launcher`, gen-l10n.

**Spec:** Dokumentasi Moci di Claude Docs, https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H (tab PRD, Spesifikasi Teknis, Sistem Desain, Konten & Aset, Privasi & Rilis). Desain: snapshot canvas https://claude.ai/artifact/SaDuEPgwdFp5WSfoAhvum8 di `docs/design/prototype/*.dc.html` (40 artboard, 14 November 2026), asetnya di `docs/design/prototype/assets/<blob>.svg`, dan tangkapan layar di `docs/screenshots/`. Peta semua rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md`.

## Global Constraints

- Flutter **3.50.0** dikunci dengan FVM (`.fvmrc`). iOS dan iPadOS minimal **15**, Android minimal **7.0 (API 24)**, target **API 36**.
- Paket pihak ketiga hanya `go_router`, `flutter_riverpod`, `shared_preferences`, `flutter_soloud`, `speech_to_text` (Rencana 03), dan `vector_graphics`/`vector_graphics_compiler`. Paket first-party flutter.dev yang ditambahkan rencana ini: `material_ui`, `path_provider`, `url_launcher`, `flutter_localizations`, `intl`. Paket lain hanya boleh masuk kalau tidak mengirim data, tidak butuh izin tambahan, dan masih aktif dirawat. Tidak ada SDK analytics atau crash, dan tidak ada `google_fonts`.
- Material diimpor dari `package:material_ui/material_ui.dart`, bukan dari `package:flutter/material.dart` yang deprecated di 3.50. Kode yang cukup dengan lapisan widget memakai `package:flutter/widgets.dart`.
- Manifest Android utama (rilis) tidak berisi izin apa pun di rencana ini, termasuk INTERNET. Pakai `android:allowBackup="false"`, dan tandai folder data iOS agar tidak ikut backup.
- Orientasi landscape saja (kiri dan kanan) di semua perangkat:
  - `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])`.
  - iOS: `UISupportedInterfaceOrientations` dan `UISupportedInterfaceOrientations~ipad` hanya berisi landscape, ditambah `UIRequiresFullScreen` = true.
  - Android: `android:screenOrientation="sensorLandscape"` di activity, plus `<property android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY" android:value="true"/>` di `<application>`.
- Ukuran dasar: tablet **1180 × 820**, HP **844 × 390** (pt). Layout tablet dipakai kalau sisi terpendek layar ≥ **600 dp**. Isi diskalakan proporsional ke area aman, dan sisa ruang diisi latar menu.
- Target sentuh minimal **64 pt** di tablet dan **56 pt** di HP. Jarak antar target minimal **16 pt**, margin tepi **32 pt** di tablet.
- Gerak:
  - Tombol ditekan: turun **5 pt** dan mengecil ke **97%** selama **120 ms**, disertai klik halus.
  - Elemen muncul: membesar memantul **400–550 ms** dengan kurva `Cubic(0.3, 1.6, 0.5, 1)`.
  - Jawaban salah: goyang **450 ms** dan merah sekejap.
  - Maskot diam: satu putaran **2,4–3 detik**.
  - Setiap ketukan dijawab dalam waktu kurang dari **100 ms**.
- Bayangan selalu padat tanpa blur, bergeser lurus ke bawah, dan warnanya versi gelap dari warna latar atau elemen menu. Sudut membulat di mana-mana.
- Kalau `MediaQuery.disableAnimations` aktif, animasi hiasan (mengintip, bergoyang, awan, bintang berkelip) dimatikan. Umpan balik benar dan salah tetap muncul, tetapi tanpa pantulan.
- Font Fredoka (judul, angka, tombol) dan Nunito (isi, label) dibundel di `assets/fonts`, subset Latin, total di bawah **1 MB**.
- Kontras teks minimal **4,5 : 1**. Di layar permainan, ukuran teks tidak ikut pengaturan sistem. Di Area Orang Tua, teks ikut pengaturan sistem sampai **1,3×**.
- Dua bahasa setara:
  - Semua teks UI lewat gen-l10n (`l10n/app_id.arb`, `l10n/app_en.arb`).
  - Bahasa bisa diganti kapan saja tanpa memulai ulang aplikasi.
  - Bawaannya Bahasa Indonesia untuk perangkat berbahasa Indonesia, English untuk lainnya.
  - Nama anak kosong → disapa "Adik" (EN: "little one").
- Audio:
  - Satu mesin, `flutter_soloud`. Prioritas narasi > efek > musik.
  - Volume narasi **100%**, efek **70%**, musik **25%** (turun ke **10%** saat narasi bicara).
  - Satu narasi pada satu waktu; narasi baru menghentikan yang lama.
  - Semua suara berhenti saat aplikasi ke latar belakang.
  - Efek paling lama **0,6 s**, dan tidak ada bunyi gagal yang keras, sedih, atau buzzer.
  - Sesi audio iOS memakai kategori playback.
  - TTS perangkat hanya untuk build debug dan profile.
- Penyimpanan:
  - Pengaturan di `shared_preferences`; `progress.json`, `karya/`, dan `draf/` di folder aplikasi.
  - Penulisan atomik: tulis ke file sementara, lalu rename.
  - Setiap file punya `versi`.
- Pengatur waktu:
  - Dihitung hanya saat aplikasi terbuka di depan dan anak berada di rute bermain.
  - Disimpan per tanggal untuk **7 hari**, dan direset setiap tengah malam waktu perangkat.
  - Kalau pengingat aktif, istirahat muncul setiap **20 menit** bermain. Layarnya **20 detik**, lalu kembali ke layar tadi.
  - Batas harian **15/30/45 menit** atau tanpa batas, bawaan **30**.
- Gerbang Orang Tua: soal perkalian, angka pertama **6–9**, angka kedua **3–9**. Gerbang ini melindungi pengaturan, semua tautan keluar, dan permintaan izin mikrofon.
- Prinsip PRD:
  - Suara dulu, teks kedua.
  - Salah tidak dihukum: tanpa nyawa, hitung mundur, atau skor yang berkurang.
  - Gerakan hanya ketuk satu jari atau geser satu jari; tidak ada ketuk dua kali, tekan lama, atau dua jari.
  - Tombol kembali selalu di kiri atas, dengan ukuran dan posisi yang sama.
  - Urusan orang dewasa ada di balik gerbang.
  - Aplikasi berjalan offline.
  - Dua bahasa setara.
  - Kesulitan mengikuti usia.
- Teks antarmuka disalin persis dari objek `T` di artboard prototipe, dalam ID dan EN.

## Review Focus

1. **Anak menekan tombol bertubi-tubi.** Tidak boleh ada rute yang terbuka dua kali, bintang yang diberikan dua kali, atau narasi yang menumpuk. Dipatok di Task 9 (jeda tombol) dan Task 17 (hadiah idempoten per ronde).
2. **Jam atau zona waktu perangkat berubah, atau aplikasi ditangguhkan lama tanpa event pause.** Waktu bermain tidak boleh berkurang, melonjak, atau reset selain di tengah malam. Dipatok di Task 16.
3. **`progress.json` rusak atau terpotong**, misalnya baterai habis saat menulis. Aplikasi tetap terbuka dengan data bawaan, dan file lama disimpan untuk diperiksa. Dipatok di Task 4 dan Task 6.
4. **Layar yang tidak pas dengan desain:** HP dengan notch, Dynamic Island, atau kamera berlubang di kedua arah landscape, serta iPad 4:3 dan tablet 16:10. Tombol kembali dan isi tidak boleh terpotong atau tertutup. Dipatok di Task 3.
5. **iPhone dengan sakelar senyap aktif.** Narasi tetap terdengar, dan narasi tidak bocor setelah aplikasi ke latar belakang. Dipatok di Task 8 (tes siklus hidup dan langkah cek manual).

## Keputusan rencana ini

Spec dan prototipe tidak memutuskan hal-hal berikut, atau keduanya berbeda. Setiap task merujuk kode D-nya.

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| D1 | Material diimpor dari `material_ui`. | Flutter 3.50 men-deprecate `package:flutter/material.dart` ([breaking change](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)). |
| D2 | Paket first-party tambahan: `material_ui`, `path_provider` (folder aplikasi), `url_launcher` (tautan di balik gerbang), `flutter_localizations`, `intl`. SVG dirender dengan `vector_graphics`, tanpa `flutter_svg`. | Dibutuhkan spec tetapi tidak ada di tabel paket. |
| D3 | Bundle id dan application id `id.pandudpn.moci`. | Belum ada di spec. Ganti sebelum unggahan pertama kalau perlu. |
| D4 | Sambutan muncul sekali (flag `moci.sambutanSelesai`). Bahasa bawaan mengikuti perangkat. | Sesuai spec. Prototipe selalu menampilkan Sambutan dan selalu memakai `id`. |
| D5 | Narasi rekaman tidak menyebut nama anak. Kalimat yang memuat nama dibacakan dalam varian tanpa nama, sementara teks di layar tetap memakai nama. | Nama bebas tidak bisa direkam, dan TTS tidak dipakai di rilis. |
| D6 | Kartu "Lanjutkan" disembunyikan sampai ada kegiatan terakhir. | Prototipe statis ("Tulis huruf A"). |
| D7 | Menu dibuka dengan `push`, jadi back sistem = tombol kembali. Beranda, Splash, Sambutan, Istirahat, dan Waktu Habis mengabaikan back sistem. | Spec: back sistem sama dengan tombol kembali. Beranda tidak punya tombol kembali. |
| D8 | Istirahat dibuka di atas layar aktif, jadi state permainan tetap. Setiap langkah dibacakan, dan aplikasi kembali otomatis setelah 20 detik. Tombol "Lanjut main" dari prototipe tidak dipakai. | Spec: kembali setelah 20 detik. Prinsip "suara dulu". |
| D9 | Gerbang dibuka dengan soal acak dan isian kosong. Narasi "Ini khusus orang tua. Panggil Ayah atau Bunda, ya!" diputar saat gerbang dibuka. "Batal" kembali ke layar pembuka. Tombol angka 96 × 84, radius 24 (ukuran prototipe). | Spec meminta narasi saat dibuka; teksnya dari prototipe. Angka 88 pt di dokumen adalah ukuran ubin gembok, bukan tombol angka. |
| D10 | Hadiah diberikan saat permainan selesai, bukan saat "Ambil hadiah". Di Hebat, "Main lagi" kembali ke permainan tadi dan "Lanjut" ke Beranda. Katalog 30 stiker (6 per tema, tabel di Task 10). Stiker baru dipilih acak dari yang belum dimiliki; kalau semua sudah dimiliki, anak hanya mendapat bintang. | Prototipe tidak punya katalog stiker ("8 / 30"), dan "Main lagi" di prototipe selalu ke hub. |
| D11 | Area Orang Tua: (a) nama diubah lewat dialog di Area Orang Tua, bukan dengan membuka Sambutan; (b) "Minggu ini" = jumlah item berbeda yang dibuka dalam 7 hari terakhir per modul, dibagi total isi modul; (c) saran = modul dengan cakupan terendah, dengan teks baru yang perlu ditinjau; (d) "Hapus semua data" ada di baris badge bawah, memakai dialog dua langkah, dan menghapus semua pengaturan serta file. | Prototipe memakai angka palsu dan tidak punya "Hapus semua data". |
| D12 | Layar yang belum punya desain HP (semua kecuali Splash dan Beranda) sementara menampilkan desain tablet yang diperkecil di HP. | PRD: layar HP didesain dulu sebelum dibangun (Rencana 08). |
| D13 | Pil "Untuk orang tua" hanya ada di Waktu Habis, tidak di Istirahat. | Supaya istirahat tidak bisa dilewati. |
| D14 | Waktu bermain dihitung di Beranda, semua menu, dan Hebat. Tidak dihitung di Splash, Sambutan, Gerbang, Area Orang Tua, Istirahat, dan Waktu Habis. | Spec ditambah perilaku prototipe. |

## Peta file

```
.fvmrc · pubspec.yaml · analysis_options.yaml · dart_test.yaml · l10n.yaml
.github/workflows/ci.yml                 # analyze, format, test, golden
l10n/app_id.arb · l10n/app_en.arb        # teks UI dua bahasa
tool/fonts/build_fonts.sh                # unduh + instance + subset font OFL
assets/fonts/                            # Fredoka 400–700, Nunito 600–900, OFL-*.txt
assets/illustrations/<id>.svg            # dikompilasi vector_graphics_compiler
lib/main.dart                            # runMoci(): bootstrap + ProviderScope
lib/app/moci_app.dart                    # MaterialApp.router, tema, bahasa, siklus hidup
lib/app/routes.dart · redirect.dart · router.dart · config.dart
lib/app/theme/                           # moci_colors, menu_theme, moci_text, moci_metrics, moci_motion, moci_theme
lib/app/layout/                          # device_layout (hitungan), moci_stage (widget)
lib/app/play_timer/                      # play_timer (aturan murni), play_timer_controller
lib/app/splash/splash_screen.dart
lib/core/clock.dart · lib/core/providers.dart
lib/core/storage/                        # key_value_store, json_store, app_files, backup_exclusion
lib/core/prefs/                          # app_prefs, prefs_controller
lib/core/progress/                       # progress, progress_repository, progress_controller
lib/core/audio/                          # audio_engine, soloud_audio_engine, audio_service, sfx, asset_catalog, narrator, dev_tts, audio_session
lib/l10n/                                # hasil gen-l10n + l10n.dart (extension context.l10n)
lib/widgets/                             # pressable, moci_button, moci_back_button, moci_top_bar, star_counter, moci_mascot, moci_illustration, moci_dialog, number_keypad
lib/features/sambutan/sambutan_screen.dart
lib/features/beranda/                    # beranda_screen, beranda_menu, continue_labels, widgets/
lib/features/orang_tua/                  # gerbang_game, gerbang_screen, ringkasan, orang_tua_screen, widgets/
lib/features/istirahat/                  # istirahat_screen, habis_screen
lib/features/hadiah/                     # stiker, hadiah_controller, hebat_screen
lib/features/segera/coming_soon_screen.dart   # pengganti menu yang belum dibangun
ios/Runner/MociChannels.swift            # kanal moci/backup, moci/audio_session, moci/tts
android/app/src/main/kotlin/.../MainActivity.kt  # kanal moci/tts
test/…                                   # cermin lib/, helpers/ berisi fake dan harness
integration_test/app_test.dart
```

## Konvensi

- Semua perintah dijalankan dari root repo lewat FVM: `fvm flutter …` dan `fvm dart …`.
- Kunci ARB berbentuk `<layar><KunciT>`. Contoh: `T.hi` di `Main.dc.html` menjadi `berandaHi`. Teksnya disalin persis dari `T` (ID ke `app_id.arb`, EN ke `app_en.arb`). Kalimat yang dibacakan diberi metadata `"description": "narasi"`.
- Path narasi: `assets/audio/vo/<id|en>/<jenis>_<id>.m4a`. Kalimat UI, termasuk judul menu, memakai jenis `ui` dengan id = kunci ARB. Contoh: `vo/id/ui_berandaSay.m4a` dan `vo/id/ui_menuHurufTitle.m4a`. Daftar jenis lain (`nama`, `fakta`, `fonik`, dan seterusnya) ditetapkan di Rencana 02 Task 6.
- Tata letak, ukuran, warna, dan teks setiap layar mengikuti artboard yang disebut di task-nya. Task hanya mencatat perilaku, data, dan hal yang berbeda dari artboard.
- Tes widget memakai fake: `MemoryKeyValueStore`, `MemoryJsonStore`, `FakeAudioEngine`, `FakeDevTts`, `FakeClock`, dan aliran tick manual. Jangan ada I/O file nyata di dalam `testWidgets`.
- Satu commit per task (`feat(...)`, `test(...)`, `chore(...)`). Jalankan `fvm dart format .` sebelum commit.

---

### Task 1: Kerangka proyek, kunci platform, dan CI

**Files:**
- Create: `.fvmrc`, `pubspec.yaml`, `analysis_options.yaml`, `dart_test.yaml`, `lib/main.dart`, `lib/app/moci_app.dart`, `ios/**`, `android/**` (dari `flutter create`), `test/platform_config_test.dart`, `.github/workflows/ci.yml`
- Modify: `.gitignore`, `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Podfile` (kalau dibuat template), `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- Delete: `test/widget_test.dart`

**Interfaces:**
- Produces: `Future<void> main()` di `lib/main.dart`. `class MociApp extends StatelessWidget` di `lib/app/moci_app.dart` (sementara `MaterialApp(title: 'Moci', debugShowCheckedModeBanner: false, home: SizedBox.shrink())`).

- [ ] **Step 1: Pasang dan kunci Flutter 3.50.0**

```bash
fvm install 3.50.0 && fvm use 3.50.0 --force && fvm flutter --version
```
Expected: `Flutter 3.50.0 • channel stable`, dan `.fvmrc` berisi `"flutter": "3.50.0"`.

- [ ] **Step 2: Buat proyek Flutter di folder repo**

```bash
fvm flutter create --project-name moci --org id.pandudpn --platforms ios,android --description "Moci — Main & Belajar" .
git status --short README.md docs
```
Expected: `lib/`, `ios/`, `android/`, dan `test/` terbentuk. Perintah `git status` untuk `README.md` dan `docs` tidak mencetak apa pun.

- [ ] **Step 3: Pindah ke `material_ui` (D1)**

```bash
fvm flutter pub add material_ui
fvm dart fix --apply --code=migrate_design_widgets
grep -rn "package:flutter/material.dart" lib test || echo bersih
```
Expected: `bersih`.

- [ ] **Step 4: Tulis tes konfigurasi platform yang gagal**

`test/platform_config_test.dart`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

String _read(String p) => File(p).readAsStringSync();

void main() {
  group('Android', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final gradle = _read('android/app/build.gradle.kts');
    test('landscape terkunci dan opt-out resizability', () {
      expect(manifest, contains('android:screenOrientation="sensorLandscape"'));
      expect(manifest, contains('android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY'));
    });
    test('tanpa backup, tanpa izin, berlabel Moci', () {
      expect(manifest, contains('android:allowBackup="false"'));
      expect(manifest, isNot(contains('uses-permission')));
      expect(manifest, contains('android:label="Moci"'));
    });
    test('level SDK dan application id', () {
      expect(gradle, contains('minSdk = 24'));
      expect(gradle, contains('targetSdk = 36'));
      expect(gradle, contains('applicationId = "id.pandudpn.moci"'));
    });
  });

  group('iOS', () {
    final plist = _read('ios/Runner/Info.plist');
    final pbx = _read('ios/Runner.xcodeproj/project.pbxproj');
    test('landscape saja di iPhone dan iPad, layar penuh', () {
      for (final key in ['UISupportedInterfaceOrientations', 'UISupportedInterfaceOrientations~ipad']) {
        final block = RegExp('<key>$key</key>\\s*<array>(.*?)</array>', dotAll: true)
            .firstMatch(plist)!
            .group(1)!;
        expect(block, contains('UIInterfaceOrientationLandscapeLeft'));
        expect(block, contains('UIInterfaceOrientationLandscapeRight'));
        expect(block, isNot(contains('Portrait')));
      }
      expect(plist, matches(RegExp(r'<key>UIRequiresFullScreen</key>\s*<true/>')));
      expect(plist, matches(RegExp(r'<key>CFBundleDisplayName</key>\s*<string>Moci</string>')));
    });
    test('deployment target 15.0 di semua konfigurasi', () {
      final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+);')
          .allMatches(pbx)
          .map((m) => m.group(1))
          .toSet();
      expect(targets, {'15.0'});
    });
  });
}
```

- [ ] **Step 5: Pastikan tesnya gagal**

Run: `fvm flutter test test/platform_config_test.dart`
Expected: FAIL. Template masih memuat orientasi `Portrait` dan belum punya `android:allowBackup`.

- [ ] **Step 6: Ubah konfigurasi platform**

- `ios/Runner/Info.plist`:
  - Isi kedua kunci orientasi hanya dengan `UIInterfaceOrientationLandscapeLeft` dan `UIInterfaceOrientationLandscapeRight`.
  - Tambahkan `UIRequiresFullScreen` = `<true/>`.
  - Isi `CFBundleDisplayName` dengan `Moci`.
  - Tambahkan `CFBundleLocalizations` berisi `id` dan `en`, supaya dialog sistem tampil sesuai bahasa perangkat.
- `ios/Runner.xcodeproj/project.pbxproj`: set `IPHONEOS_DEPLOYMENT_TARGET = 15.0;` di semua konfigurasi. Kalau `ios/Podfile` ada, isi `platform :ios, '15.0'`.
- `android/app/build.gradle.kts`: `applicationId = "id.pandudpn.moci"` (D3), `minSdk = 24`, `targetSdk = 36`, dan `compileSdk` minimal 36.
- `android/app/src/main/AndroidManifest.xml`:
  - Di `<application>`: `android:label="Moci"`, `android:allowBackup="false"`, dan elemen `<property>` resizability dari Global Constraints.
  - Di activity utama: `android:screenOrientation="sensorLandscape"`.
  - Jangan menambah `uses-permission`. Izin INTERNET untuk hot reload sudah ada di manifest `debug/` dan `profile/` bawaan template, dan biarkan tetap di sana.
- `.gitignore`: tambahkan `.fvm/`.

- [ ] **Step 7: Ganti aplikasi template**

- `lib/main.dart`: `main()` memanggil `WidgetsFlutterBinding.ensureInitialized()`, lalu `await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])`, lalu `runApp(const MociApp())`.
- `lib/app/moci_app.dart`: sesuai bagian Interfaces di atas.
- Hapus `test/widget_test.dart`.
- `analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml`, ditambah `analyzer: language: {strict-casts: true, strict-raw-types: true}`.
- `dart_test.yaml`: `tags: {golden: {}}`.

- [ ] **Step 8: Jalankan tes dan analisis**

Run: `fvm flutter test && fvm flutter analyze`
Expected: semua tes PASS, dan `No issues found!`.

- [ ] **Step 9: Tambahkan CI**

`.github/workflows/ci.yml` dipicu oleh `pull_request` dan `push` ke `main`, dengan dua job:
- **`test`** (`ubuntu-latest`):
  1. `actions/checkout`.
  2. `subosito/flutter-action@v2` dengan `flutter-version: 3.50.0`, `channel: stable`, `cache: true`.
  3. Cek `.fvmrc`: `grep -q '"flutter": "3.50.0"' .fvmrc`.
  4. `flutter pub get`.
  5. `dart format --output=none --set-exit-if-changed .`
  6. `flutter analyze`
  7. `flutter test --exclude-tags golden`
- **`golden`** (`macos-latest`; runner macOS gratis untuk repo publik): langkah setup yang sama, lalu `flutter test --tags golden`.

- [ ] **Step 10: Commit**

```bash
git add -A ':!docs/design' ':!docs/audio' ':!docs/superpowers'
git commit -m "chore: kerangka proyek Flutter 3.50, kunci landscape, CI"
```

---

### Task 2: Font dan token tema

**Files:**
- Create: `tool/fonts/build_fonts.sh`, `assets/fonts/{Fredoka-Regular,Fredoka-Medium,Fredoka-SemiBold,Fredoka-Bold,Nunito-SemiBold,Nunito-Bold,Nunito-ExtraBold,Nunito-Black}.ttf`, `assets/fonts/OFL-Fredoka.txt`, `assets/fonts/OFL-Nunito.txt`, `lib/app/theme/{moci_colors,menu_theme,moci_text,moci_metrics,moci_motion,moci_theme}.dart`, `test/helpers/contrast.dart`, `test/app/theme/contrast_test.dart`, `test/app/theme/font_budget_test.dart`
- Modify: `pubspec.yaml` (bagian `fonts`), `lib/main.dart` (daftar lisensi OFL), `lib/app/moci_app.dart` (`theme: mociTheme()`)

**Interfaces:**
- Produces:
  - `abstract final class MociColors` berisi `ink #2B2350`, `inkSoft #6B5F99`, `mociYellow #FFD43B`, `sky #74C4FF`, `correct #26A03B`, `correctShadow #1E8A31`, `wrong #E8384F`, `logoM #F03E7C`, `logoO #FF9F1C`, `logoC #1C8CF0`, `logoI #26A03B`, `white #FFFFFF`, `starFill #FFC21A`, `starStroke #F08C00`.
  - `enum MenuTheme` dengan field `List<Color> colors`, `List<double>? stops`, `Color shadow`, `bool dark`, dan getter `BoxDecoration get decoration` (gradien vertikal kalau `colors.length > 1`).
  - `abstract final class MociFonts { static const fredoka = 'Fredoka'; static const nunito = 'Nunito'; }`
  - `abstract final class MociText` berisi `title` (Fredoka 700, 46), `button` (Fredoka 600, 24), `body` (Nunito 800, 23), `label` (Nunito 800, 17), dan `bigNumber` (Fredoka 700, 240). Semua berwarna `MociColors.ink`.
  - `abstract final class MociSize` berisi:
    - `backButton 76`, `backRadius 26`, `backShadow 7`
    - `topPillHeight 64`, `topShadow 6`, `pillHeight 50`, `pillShadow 5`
    - `menuCardTablet Size(236, 214)`, `menuCardPhone Size(156, 142)`, `menuRadiusTablet 34`, `menuRadiusPhone 26`, `menuShadow 10`
    - `panelRadius 44`, `panelShadow 12`
    - `minTouchTablet 64`, `minTouchPhone 56`, `targetGap 16`, `edgeTablet 32`, `topBarTop 22`
  - `abstract final class MociMotion` berisi `press 120 ms`, `pressDepth 5.0`, `pressScale 0.97`, `popIn 450 ms`, `popCurve Cubic(0.3, 1.6, 0.5, 1)`, `shake 450 ms`, `tapCooldown 400 ms`.
  - `ThemeData mociTheme()`.

Nilai `MenuTheme` diambil dari prototipe (warna latar artboard dan bayangan tombol kembali). Nilai ini lebih tepat daripada tabel di Sistem Desain, yang tidak mencatat titik tengah gradien:

| Nilai | Latar | Bayangan |
| --- | --- | --- |
| `beranda` | gradien `#74C4FF` 0 → `#B5E2FF` .55 → `#DDF3FF` 1 | `#8EC5EE` |
| `sambutan` | `#DDF3FF` | `#8EC5EE` |
| `huruf`, `ucapkan` | `#FFEDE6` | `#F3C2B3` |
| `berhitung` | `#E7F3FF` | `#B7D7F7` |
| `hewan` | gradien `#BFEBFF` 0 → `#E3F7FF` .52 → `#E3F7FF` 1 | `#9FD3A0` |
| `buahSayur` | `#FFEAF3` | `#F5BCD3` |
| `warna` | `#F3EEFF` | `#D0BFFF` |
| `bentuk` | `#EEF1FF` | `#C5CEF7` |
| `musik` | `#FFF0F6` | `#F8C4D9` |
| `membaca` | `#FFF1E6` | `#F7C9A5` |
| `mainYuk` | `#E3FAFA` | `#9EDCDD` |
| `cocokkan` | `#FDF0F6` | `#F5BCD3` |
| `memori` | `#EAF2FF` | `#B7D0F7` |
| `bayangan` | `#F3F0FF` | `#D0BFFF` |
| `puzzle` | `#FFF4E0` | `#F2C57C` |
| `balon` | gradien `#8FD3FF` 0 → `#CDEBFF` .6 → `#EAF6FF` 1 | `#8ECBEE` |
| `besarKecil` | `#EBFBEE` | `#B2F2BB` |
| `mewarnai` | `#FFF8E1` | `#F2D27A` |
| `karyaku` | `#FFF7E0` | `#F2D27A` |
| `hebat` | `#FFE58F` | `#F2C94C` |
| `istirahat` (dark) | gradien `#241D4A` 0 → `#3E3180` .55 → `#7C6BD6` 1 | `#1F1846` |
| `gerbang` (dark) | `#3B3170` | `#1F1846` |
| `orangTua` | `#F1EEF9` | `#DCD5EE` |

- [ ] **Step 1: Tulis tes kontras dan anggaran font yang gagal**

`test/helpers/contrast.dart` (rumus luminans WCAG 2.x):
```dart
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

double contrastRatio(Color a, Color b) {
  double lin(double c) => c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double lum(Color c) => 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  final l1 = lum(a), l2 = lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}
```

`test/app/theme/contrast_test.dart`:
```dart
void main() {
  test('tinta di atas semua latar terang ≥ 4,5:1', () {
    for (final t in MenuTheme.values.where((t) => !t.dark)) {
      for (final c in t.colors) {
        expect(contrastRatio(MociColors.ink, c), greaterThanOrEqualTo(4.5), reason: '$t $c');
      }
    }
  });
  test('tinta lembut di atas putih ≥ 4,5:1', () {
    expect(contrastRatio(MociColors.inkSoft, MociColors.white), greaterThanOrEqualTo(4.5));
  });
  test('teks putih di layar gelap', () {
    expect(contrastRatio(MociColors.white, const Color(0xFF3B3170)), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(MociColors.white, const Color(0xFF241D4A)), greaterThanOrEqualTo(4.5));
    expect(contrastRatio(MociColors.white, const Color(0xFF3E3180)), greaterThanOrEqualTo(4.5));
    // Ujung bawah gradien Istirahat hanya boleh memuat teks besar (≥ 24 pt tebal).
    expect(contrastRatio(MociColors.white, const Color(0xFF7C6BD6)), greaterThanOrEqualTo(3.0));
  });
}
```

`test/app/theme/font_budget_test.dart`: total ukuran `assets/fonts/*.ttf` `< 1000000` byte. Delapan nama file di bagian Files harus ada, dan kedua file `OFL-*.txt` juga ada.

- [ ] **Step 2: Pastikan tesnya gagal**

Run: `fvm flutter test test/app/theme`
Expected: FAIL (`MenuTheme` belum ada, folder font belum ada).

- [ ] **Step 3: Buat skrip font dan jalankan**

`tool/fonts/build_fonts.sh` (bash, `set -euo pipefail`):
1. Unduh `https://github.com/google/fonts/raw/main/ofl/fredoka/Fredoka%5Bwdth,wght%5D.ttf`, `https://github.com/google/fonts/raw/main/ofl/nunito/Nunito%5Bwght%5D.ttf`, dan `OFL.txt` dari kedua folder ke `build/fonts/`.
2. Buat venv `build/fonts/venv`, lalu `pip install fonttools`.
3. Untuk setiap bobot, buat instance statis: `fonttools varLib.instancer <var.ttf> wght=<w> [wdth=100] -o <tmp>`. Bobotnya Fredoka 400, 500, 600, 700 dan Nunito 600, 700, 800, 900.
4. Subset setiap instance: `pyftsubset <tmp> --unicodes="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD" --layout-features='*' --output-file=assets/fonts/<Nama>.ttf`.
5. Salin `OFL.txt` menjadi `OFL-Fredoka.txt` dan `OFL-Nunito.txt`.

Run: `bash tool/fonts/build_fonts.sh && du -ch assets/fonts/*.ttf | tail -1`
Expected: total jauh di bawah 1 MB.

- [ ] **Step 4: Daftarkan font dan buat token**

- `pubspec.yaml`: family `Fredoka` (400 Regular, 500 Medium, 600 SemiBold, 700 Bold) dan `Nunito` (600 SemiBold, 700 Bold, 800 ExtraBold, 900 Black).
- `lib/main.dart`: `LicenseRegistry.addLicense` untuk kedua file OFL.
- `lib/app/theme/*` sesuai bagian Interfaces.
- `mociTheme()`: `useMaterial3: true`, `fontFamily: MociFonts.nunito`, `scaffoldBackgroundColor: Colors.transparent`, `colorScheme: ColorScheme.fromSeed(seedColor: MociColors.sky)`, dan `splashFactory: NoSplash.splashFactory`. Efek ripple Material tidak dipakai karena umpan balik tekan memakai `MociPressable`.

- [ ] **Step 5: Jalankan tes**

Run: `fvm flutter test test/app/theme`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add tool/fonts assets/fonts lib/app/theme lib/main.dart lib/app/moci_app.dart pubspec.yaml test/helpers test/app/theme
git commit -m "feat(tema): font Fredoka/Nunito subset dan token warna, ukuran, gerak"
```

---

### Task 3: Panggung layout tablet dan HP

**Files:**
- Create: `lib/app/layout/device_layout.dart`, `lib/app/layout/moci_stage.dart`, `test/app/layout/device_layout_test.dart`, `test/app/layout/moci_stage_test.dart`

**Interfaces:**
- Consumes: `MenuTheme` (Task 2).
- Produces:
  - `enum LayoutKind { tablet, phone }`, `const Size kTabletBase = Size(1180, 820)`, `const Size kPhoneBase = Size(844, 390)`.
  - `LayoutKind layoutKindFor(Size screen)`: tablet kalau `screen.shortestSide >= 600`.
  - `class StageFit { final double scale; final Offset origin; final Size size; }`
  - `StageFit fitStage({required Size screen, required EdgeInsets safe, required Size base})`.
  - `class MociStage extends StatelessWidget` dengan konstruktor `MociStage({required MenuTheme theme, required WidgetBuilder tablet, WidgetBuilder? phone, double textScaleCap = 1.0})`.
  - `class MociLayoutScope extends InheritedWidget`, berisi `LayoutKind kind` dan `double scale`, dibaca lewat `context.layoutKind` dan `context.stageScale`.
  - `class MenuThemeScope extends InheritedWidget`, dibaca lewat `MenuThemeScope.of(context)`.

Algoritma `fitStage`:
- `avail = screen − safe` (kiri+kanan dan atas+bawah).
- `scale = min(avail.w / base.w, avail.h / base.h)`.
- `size = base × scale`.
- `origin = (safe.left, safe.top) + (avail − size) / 2`.

`MociStage` bekerja begini:
1. Latar `theme.decoration` dilukis penuh layar, termasuk area di luar desain.
2. Isi dibangun di `SizedBox(base)` dan dipasang di `origin` dengan `FittedBox(fit: BoxFit.contain)`.
3. Di dalam panggung, `MediaQuery` dioverride: `size: base`, `padding` dan `viewPadding` nol, dan `textScaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: textScaleCap)`. Untuk layar permainan, `textScaleCap` = 1.0, jadi teks tidak membesar. `viewInsets` (keyboard) dibiarkan dalam satuan layar asli; Sambutan membaginya dengan `context.stageScale`.
4. Kalau layout HP dan `phone == null`, pakai builder tablet dengan base tablet (D12), lalu `debugPrint('Layout HP belum didesain: …')` sekali per layar.
5. Kedua scope dipasang di dalam panggung.

- [ ] **Step 1: Tulis tes hitungan yang gagal**

`test/app/layout/device_layout_test.dart`:
```dart
void main() {
  test('jenis layout dari sisi terpendek', () {
    expect(layoutKindFor(const Size(1180, 820)), LayoutKind.tablet);
    expect(layoutKindFor(const Size(960, 600)), LayoutKind.tablet);
    expect(layoutKindFor(const Size(844, 390)), LayoutKind.phone);
    expect(layoutKindFor(const Size(915, 412)), LayoutKind.phone);
  });

  void check(Size screen, EdgeInsets safe, Size base, double scale, Offset origin) {
    final f = fitStage(screen: screen, safe: safe, base: base);
    expect(f.scale, closeTo(scale, 1e-3));
    expect(f.origin.dx, closeTo(origin.dx, 0.1));
    expect(f.origin.dy, closeTo(origin.dy, 0.1));
  }

  test('iPad 11 inci pas', () => check(const Size(1180, 820), EdgeInsets.zero, kTabletBase, 1.0, Offset.zero));
  test('iPad 4:3: pita atas-bawah', () => check(const Size(1024, 768), EdgeInsets.zero, kTabletBase, 0.8678, const Offset(0, 28.2)));
  test('tablet 16:10: pita kiri-kanan', () => check(const Size(1280, 800), EdgeInsets.zero, kTabletBase, 0.9756, const Offset(64.4, 0)));
  test('iPhone dengan notch kiri-kanan', () => check(const Size(844, 390), const EdgeInsets.symmetric(horizontal: 47), kPhoneBase, 0.8886, const Offset(47, 21.7)));
}
```

`test/app/layout/moci_stage_test.dart`. Atur layar dengan `tester.view.physicalSize`, `devicePixelRatio = 1`, dan `tester.view.padding = FakeViewPadding(...)`, lalu `addTearDown(tester.view.reset)`. Lalu uji:
- **1024 × 768:** anak melihat `MediaQuery.sizeOf == kTabletBase`, pojok kiri-atas anak di layar ada di `(0, 28.2)` ±0,5, dan `DecoratedBox` latar berukuran 1024 × 768.
- **844 × 390, `phone == null`:** anak melihat `kTabletBase` (D12).
- **844 × 390, `phone` diisi:** anak melihat `kPhoneBase`, dan `context.layoutKind == LayoutKind.phone`.
- **Padding kiri 47 (notch):** pojok kiri isi berada di x ≥ 47.
- **Skala teks sistem 2.0:** dengan `textScaleCap: 1.3`, `MediaQuery.textScalerOf(child).scale(10) == 13`; dengan cap bawaan, hasilnya 10.

- [ ] **Step 2: Pastikan tesnya gagal**

Run: `fvm flutter test test/app/layout`
Expected: FAIL (simbol belum ada).

- [ ] **Step 3: Implementasikan `device_layout.dart` dan `moci_stage.dart`** sesuai bagian Interfaces dan algoritma di atas.

- [ ] **Step 4: Jalankan tes**

Run: `fvm flutter test test/app/layout`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/app/layout test/app/layout
git commit -m "feat(layout): panggung 1180×820/844×390 yang diskalakan ke area aman"
```

---

### Task 4: Jam, penyimpanan kunci-nilai, file JSON atomik, dan backup iOS

**Files:**
- Create:
  - `lib/core/clock.dart`, `lib/core/providers.dart`
  - `lib/core/storage/key_value_store.dart`, `lib/core/storage/json_store.dart`, `lib/core/storage/app_files.dart`, `lib/core/storage/backup_exclusion.dart`
  - `ios/Runner/MociChannels.swift`
  - `test/helpers/fake_clock.dart`, `test/core/storage/json_store_test.dart`, `test/core/storage/key_value_store_test.dart`
- Modify: `ios/Runner/AppDelegate.swift` (daftarkan kanal), `lib/main.dart` (`runMoci`), `pubspec.yaml` (`flutter_riverpod`, `shared_preferences`, `path_provider`)

**Interfaces:**
- Produces:
  - `abstract interface class Clock { DateTime now(); }` dan `final class SystemClock implements Clock`.
  - `abstract interface class KeyValueStore`:
    - baca: `String? getString(String key)`, `int? getInt(String key)`, `bool? getBool(String key)`
    - tulis: `Future<void> setString(String key, String value)`, `setInt`, `setBool`
    - hapus: `Future<void> remove(String key)`, `Future<void> clear()`
  - `final class MemoryKeyValueStore implements KeyValueStore`.
  - `final class SharedPrefsKeyValueStore implements KeyValueStore` dengan `static Future<SharedPrefsKeyValueStore> open()`. Memakai `SharedPreferencesWithCache`, dan semua kunci berawalan `moci.`.
  - `abstract interface class JsonStore`:
    - `Future<Map<String, Object?>?> read(String path)`
    - `Future<void> write(String path, Map<String, Object?> json)`
    - `Future<void> delete(String path)`
    - `Future<List<String>> list(String dir)`
    - `Future<void> deleteAll()`
  - `final class FileJsonStore implements JsonStore` dengan konstruktor `FileJsonStore(Directory root)`, dan `final class MemoryJsonStore implements JsonStore`.
  - `final class AppFiles` dengan `static Future<Directory> open(BackupExclusion exclusion)`. Fungsi ini membuat `getApplicationSupportDirectory()/moci` dan menandainya tidak ikut backup.
  - `abstract interface class BackupExclusion { Future<void> exclude(Directory dir); }` dan `final class MethodChannelBackupExclusion`. Di iOS memakai kanal `moci/backup` dengan metode `exclude(path)`; di Android tidak melakukan apa pun.
  - Provider di `lib/core/providers.dart`:
    - `clockProvider` (`SystemClock`)
    - `keyValueStoreProvider` dan `jsonStoreProvider` (keduanya melempar `UnimplementedError` kalau belum dioverride)
  - `Future<void> runMoci({List<Override> overrides = const []})` di `lib/main.dart`. `main()` memanggil `runMoci()`, membuka penyimpanan nyata, lalu menjalankan `runApp(ProviderScope(overrides: [...], child: const MociApp()))`.

Aturan `FileJsonStore`:
- **Tulis atomik:** tulis `<path>.tmp`, lalu `rename` ke `<path>`. Buat folder induknya kalau belum ada.
- **Baca:**
  - File tidak ada → `null`.
  - JSON rusak, atau isinya bukan objek → rename ke `<path>.rusak-<epochMillis>`, lalu kembalikan `null`.
  - Abaikan file `.tmp` sisa.

- [ ] **Step 1: Tulis tes yang gagal**

`test/core/storage/json_store_test.dart` (memakai `test()` biasa, folder temp nyata):
```dart
void main() {
  late Directory dir;
  late FileJsonStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('moci');
    store = FileJsonStore(dir);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('tulis lalu baca', () async {
    await store.write('progress.json', {'versi': 1, 'bintang': 3});
    expect(await store.read('progress.json'), {'versi': 1, 'bintang': 3});
    expect(File('${dir.path}/progress.json.tmp').existsSync(), isFalse);
  });
  test('file .tmp sisa crash diabaikan', () async {
    await store.write('progress.json', {'versi': 1, 'bintang': 5});
    File('${dir.path}/progress.json.tmp').writeAsStringSync('{"versi": 1, "bin');
    expect((await store.read('progress.json'))!['bintang'], 5);
  });
  test('file rusak dipindah, lalu tulis ulang berhasil', () async {
    File('${dir.path}/progress.json').writeAsStringSync('{"versi": 1, "bintang": 2');
    expect(await store.read('progress.json'), isNull);
    expect(dir.listSync().map((e) => e.path).any((p) => p.contains('progress.json.rusak-')), isTrue);
    await store.write('progress.json', {'versi': 1});
    expect(await store.read('progress.json'), {'versi': 1});
  });
  test('list dan deleteAll', () async {
    await store.write('karya/b.json', {});
    await store.write('karya/a.json', {});
    expect(await store.list('karya'), ['a.json', 'b.json']);
    await store.deleteAll();
    expect(dir.listSync(), isEmpty);
  });
}
```

`test/core/storage/key_value_store_test.dart`: uji `MemoryKeyValueStore` (simpan dan baca ketiga tipe, `remove`, `clear`). Uji juga `MemoryJsonStore` dengan kasus yang sama dengan `FileJsonStore`, kecuali kasus file rusak.

`test/helpers/fake_clock.dart`: `class FakeClock implements Clock { FakeClock(this.current); DateTime current; void advance(Duration d); @override DateTime now() => current; }`.

- [ ] **Step 2: Pastikan tesnya gagal**

Run: `fvm flutter test test/core/storage`
Expected: FAIL.

- [ ] **Step 3: Implementasikan**

Jalankan `fvm flutter pub add flutter_riverpod shared_preferences path_provider`, lalu buat file sesuai bagian Interfaces.

`ios/Runner/MociChannels.swift` mendaftarkan `FlutterMethodChannel(name: "moci/backup")`. Metode `exclude` mengambil `path`, mengisi `URLResourceValues.isExcludedFromBackup = true` pada URL folder itu, lalu membalas `nil`. Daftarkan kanal di hook registrasi engine yang dipakai template `AppDelegate.swift` Flutter 3.50.

- [ ] **Step 4: Jalankan tes**

Run: `fvm flutter test test/core/storage`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core lib/main.dart ios/Runner pubspec.yaml pubspec.lock test/core test/helpers
git commit -m "feat(penyimpanan): kunci-nilai, JSON atomik, jam, backup iOS dimatikan"
```

---

### Task 5: Pengaturan (prefs)

**Files:**
- Create: `lib/core/lang.dart`, `lib/core/prefs/app_prefs.dart`, `lib/core/prefs/prefs_controller.dart`, `test/core/prefs/prefs_controller_test.dart`

**Interfaces:**
- Consumes: `KeyValueStore`, `keyValueStoreProvider` (Task 4).
- Produces:
  - `enum AppLang { id, en }` di `lib/core/lang.dart`, tanpa import Flutter, karena tool di Rencana 02 ikut memakainya. `enum AgeLevel { pemula, penjelajah, pembaca }` (2–3, 4–5, 6–7) dan `enum LetterMode { fonik, nama }` di `app_prefs.dart`.
  - `@immutable final class AppPrefs` dengan field `AppLang lang`, `String childName`, `AgeLevel ageLevel`, `LetterMode letterMode`, `int? dailyLimitMinutes`, `bool music`, `bool sfx`, `bool restReminder`, `bool onboarded`, plus `copyWith` dan `==`.
  - `AppLang defaultLangFor(Locale device)`: `id` kalau `languageCode == 'id'`, selain itu `en`.
  - `final deviceLocaleProvider = Provider<Locale>((_) => PlatformDispatcher.instance.locale);`
  - `final prefsProvider = NotifierProvider<PrefsController, AppPrefs>(PrefsController.new);`
  - Metode `PrefsController`:
    - setter: `setLang`, `setChildName` (dipangkas, maks. 20 karakter), `setAgeLevel`, `setLetterMode`, `setMusic`, `setSfx`, `setRestReminder`
    - `setDailyLimit(int? minutes)`: hanya menerima 15, 30, 45, atau null; nilai lain melempar `ArgumentError`
    - `completeOnboarding({required AppLang lang, required String childName, required AgeLevel age})`
    - `resetAll()`

Kunci dan nilai bawaan. Bawaan untuk cara baca huruf, musik, efek, dan istirahat diambil dari prototipe `OrangTua.dc.html`.

| Field | Kunci | Nilai tersimpan | Bawaan |
| --- | --- | --- | --- |
| lang | `moci.bahasa` | `id` / `en` | `defaultLangFor(deviceLocale)` |
| childName | `moci.nama` | teks | `''` |
| ageLevel | `moci.usia` | `2-3` / `4-5` / `6-7` | `pemula` |
| letterMode | `moci.caraBaca` | `fonik` / `nama` | `fonik` |
| dailyLimitMinutes | `moci.batasMenit` | 15 / 30 / 45, 0 = tanpa batas | 30 |
| music, sfx, restReminder | `moci.musik`, `moci.efek`, `moci.istirahat` | bool | true |
| onboarded | `moci.sambutanSelesai` | bool | false |

- [ ] **Step 1: Tulis tes yang gagal**

```dart
ProviderContainer make(MemoryKeyValueStore s, Locale l) {
  final c = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(s),
    deviceLocaleProvider.overrideWithValue(l),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('bawaan ikut bahasa perangkat', () {
    expect(make(MemoryKeyValueStore(), const Locale('id', 'ID')).read(prefsProvider).lang, AppLang.id);
    expect(make(MemoryKeyValueStore(), const Locale('en', 'US')).read(prefsProvider).lang, AppLang.en);
    expect(make(MemoryKeyValueStore(), const Locale('ms', 'MY')).read(prefsProvider).lang, AppLang.en);
  });
  test('nilai bawaan lain', () {
    final p = make(MemoryKeyValueStore(), const Locale('id')).read(prefsProvider);
    expect(p.dailyLimitMinutes, 30);
    expect([p.music, p.sfx, p.restReminder, p.onboarded], [true, true, true, false]);
    expect(p.letterMode, LetterMode.fonik);
    expect(p.ageLevel, AgeLevel.pemula);
  });
  test('tersimpan dan terbaca ulang, termasuk tanpa batas', () async {
    final s = MemoryKeyValueStore();
    final c = make(s, const Locale('id'));
    await c.read(prefsProvider.notifier).completeOnboarding(
        lang: AppLang.en, childName: '  Raka  ', age: AgeLevel.pembaca);
    await c.read(prefsProvider.notifier).setDailyLimit(null);
    final again = make(s, const Locale('id')).read(prefsProvider);
    expect(again.lang, AppLang.en);
    expect(again.childName, 'Raka');
    expect(again.ageLevel, AgeLevel.pembaca);
    expect(again.onboarded, isTrue);
    expect(again.dailyLimitMinutes, isNull);
  });
  test('nama dipotong 20 karakter', () async {
    final c = make(MemoryKeyValueStore(), const Locale('id'));
    await c.read(prefsProvider.notifier).setChildName('A' * 30);
    expect(c.read(prefsProvider).childName.length, 20);
  });
  test('batas di luar 15/30/45/null ditolak', () {
    final c = make(MemoryKeyValueStore(), const Locale('id'));
    expect(() => c.read(prefsProvider.notifier).setDailyLimit(20), throwsArgumentError);
  });
  test('resetAll kembali ke bawaan', () async {
    final s = MemoryKeyValueStore();
    final c = make(s, const Locale('en'));
    await c.read(prefsProvider.notifier).completeOnboarding(lang: AppLang.id, childName: 'Ana', age: AgeLevel.penjelajah);
    await c.read(prefsProvider.notifier).resetAll();
    expect(c.read(prefsProvider).onboarded, isFalse);
    expect(c.read(prefsProvider).childName, '');
    expect(s.getString('moci.nama'), isNull);
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/prefs`. Expected: FAIL.
- [ ] **Step 3: Implementasikan `app_prefs.dart` dan `prefs_controller.dart`.** `build()` membaca dari store secara sinkron. Setiap setter langsung mengubah state lalu menulis ke store.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/core/prefs`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(prefs): pengaturan dengan bawaan bahasa perangkat`.

---

### Task 6: Kemajuan (`progress.json`)

**Files:**
- Create: `lib/core/progress/progress.dart`, `lib/core/progress/progress_repository.dart`, `lib/core/progress/progress_controller.dart`, `test/core/progress/progress_test.dart`, `test/core/progress/progress_controller_test.dart`
- Modify: `lib/main.dart` (muat `progress.json` sebelum `runApp`)

**Interfaces:**
- Consumes: `JsonStore`, `jsonStoreProvider`, `clockProvider` (Task 4).
- Produces:
  - `String dateKey(DateTime local)`: format `yyyy-MM-dd`, diisi nol di depan.
  - `final class LastActivity { const LastActivity(this.route, [this.params = const {}]); final String route; final Map<String, String> params; }`
  - `final class DayStats { const DayStats({this.stars = 0, this.stickers = 0, this.karya = 0, this.items = const {}}); final int stars, stickers, karya; final Map<String, List<String>> items; }`
  - `final class Progress` dengan konstruktor `const Progress({int stars = 0, List<String> stickers = const [], LastActivity? lastActivity, Map<String, int> playSeconds = const {}, Map<String, Map<String, List<String>>> perkembangan = const {}, Map<String, DayStats> harian = const {}})`, `static const int versi = 1`, `factory Progress.fromJson(Map<String, Object?> json)`, `Map<String, Object?> toJson()`, dan `copyWith`.
  - `final class ProgressRepository { ProgressRepository(JsonStore store); static const path = 'progress.json'; Future<Progress> load(); Future<void> save(Progress p); Future<void> delete(); }`
  - `final initialProgressProvider = Provider<Progress>((_) => const Progress());`, yang dioverride di `runMoci` dengan hasil `load()`.
  - `final progressProvider = NotifierProvider<ProgressController, Progress>(ProgressController.new);`
  - Metode `ProgressController`:
    - `setLastActivity(String route, [Map<String, String> params])`
    - `addStars(int n)`, `addSticker(String id)`, `recordKarya()`
    - `markItem(String modul, String metric, String itemId)`
    - `setPlaySeconds(String date, int seconds)`
    - `reset()`
    - Semuanya `Future<void>`, dan setiap perubahan disimpan berurutan lewat satu antrean `Future`.

Bentuk JSON v1 mengikuti contoh di spec, ditambah `harian` untuk ringkasan Area Orang Tua (D11):
```json
{
  "versi": 1,
  "bintang": 27,
  "stiker": ["apel", "moci-senang"],
  "kegiatanTerakhir": { "rute": "/huruf/tulis", "param": { "huruf": "A" } },
  "waktuBermain": { "2026-11-14": 1260 },
  "perkembangan": { "huruf": { "dilihat": ["A", "B"], "ditulis": ["A"] } },
  "harian": { "2026-11-14": { "bintang": 9, "stiker": 1, "karya": 1, "item": { "huruf": ["A", "B"] } } }
}
```

Aturan:
- Field yang hilang atau bertipe salah diganti nilai bawaan field itu, tanpa error.
- `waktuBermain` dan `harian` hanya menyimpan 7 tanggal terakhir. Batasnya `dateKey(clock.now() − 6 hari)`, dan tanggal yang lebih tua dibuang setiap kali disimpan.
- `addStars` dan `addSticker` juga menambah hitungan `harian` hari ini. `addSticker` mengabaikan stiker yang sudah dimiliki.
- `markItem` menambahkan `itemId` ke `perkembangan[modul][metric]` dan ke `harian[hari ini].item[modul]`, tanpa duplikat.
- `reset()` menghapus file lalu mengembalikan state ke `const Progress()`.

- [ ] **Step 1: Tulis tes yang gagal**

Tes di `progress_test.dart`:
- `Progress.fromJson(<contoh spec tanpa harian>)` menghasilkan: `stars == 27`, `stickers == ['apel', 'moci-senang']`, `lastActivity!.route == '/huruf/tulis'`, `lastActivity!.params == {'huruf': 'A'}`, `playSeconds == {'2026-11-14': 1260}`, `perkembangan['huruf']!['dilihat'] == ['A', 'B']`.
- `toJson()` memuat `'versi': 1`. Membaca ulang hasil `toJson()` lalu `toJson()` lagi menghasilkan map yang sama.
- `Progress.fromJson({})` dan `Progress.fromJson({'versi': 1, 'bintang': 'banyak'})` menghasilkan `stars == 0` tanpa melempar error.

Tes di `progress_controller_test.dart` (`MemoryJsonStore`, dan `FakeClock` di `DateTime(2026, 11, 14, 9)`):
- `addStars(3)` → `stars == 3`, `harian['2026-11-14']!.stars == 3`, dan `ProgressRepository(store).load()` sama dengan state.
- `addSticker('apel')` dua kali → `stickers == ['apel']`.
- `markItem('huruf', 'dilihat', 'A')` dua kali → tetap satu entri di `perkembangan` dan di `harian`.
- `setPlaySeconds` untuk 9 tanggal berturut-turut, 6 sampai 14 November, dengan jam di 14 November → `playSeconds.keys` adalah 8 sampai 14 November (7 kunci).
- `reset()` → `store.read('progress.json') == null` dan `state.stars == 0`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/progress`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** `runMoci` memuat `ProgressRepository(FileJsonStore(dir)).load()` lalu mengoverride `initialProgressProvider`.
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(kemajuan): progress.json v1 dengan statistik harian 7 hari`.

---

### Task 7: Dua bahasa (gen-l10n)

**Files:**
- Create: `l10n.yaml`, `l10n/app_id.arb`, `l10n/app_en.arb`, `lib/l10n/l10n.dart`, `test/l10n/arb_parity_test.dart`, `test/l10n/language_switch_test.dart`
- Modify: `pubspec.yaml` (`flutter_localizations`, `intl`, `flutter: generate: true`), `lib/app/moci_app.dart`

**Interfaces:**
- Consumes: `prefsProvider` (Task 5).
- Produces:
  - `AppLocalizations` hasil generate di `lib/l10n/`.
  - `extension L10nX on BuildContext { AppLocalizations get l10n; }`
  - `MociApp` menjadi `ConsumerWidget` dengan `locale: Locale(prefs.lang.name)`, `supportedLocales: AppLocalizations.supportedLocales`, dan `localizationsDelegates: AppLocalizations.localizationsDelegates`.
  - Kunci bersama awal: `appTitle` (Moci), `commonBack` ("Kembali ke beranda" / "Back to home"), `commonListen` ("Dengar" / "Listen"), `langNameId` ("Bahasa Indonesia", sama di kedua file), `langNameEn` ("English", sama di kedua file), `childFallbackName` ("Adik" / "little one").

Isi `l10n.yaml`: `arb-dir: l10n`, `template-arb-file: app_id.arb`, `output-dir: lib/l10n`, `output-localization-file: app_localizations.dart`, `nullable-getter: false`. File hasil generate di-commit.

- [ ] **Step 1: Tulis tes yang gagal**

`test/l10n/arb_parity_test.dart` membaca kedua ARB dengan `dart:convert`, lalu memeriksa:
- himpunan kunci tanpa awalan `@` sama persis;
- untuk setiap kunci, himpunan `placeholders` di `@kunci` sama;
- tidak ada nilai kosong;
- setiap kunci yang punya `"description": "narasi"` di satu file juga ditandai sama di file lainnya.

`test/l10n/language_switch_test.dart`:
1. Pompa `ProviderScope` (store memori, `moci.bahasa = id`) dengan `Consumer` yang membangun `MaterialApp(locale: Locale(ref.watch(prefsProvider).lang.name), …delegates…, home: Builder(builder: (c) => Text(c.l10n.commonBack)))`.
2. Expect `find.text('Kembali ke beranda')`.
3. Panggil `setLang(AppLang.en)`, lalu `pump`.
4. Expect `find.text('Back to home')`, tanpa membangun ulang aplikasi.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/l10n`. Expected: FAIL.
- [ ] **Step 3: Implementasikan konfigurasi, ARB awal, ekstensi, dan locale di `MociApp`.**
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter gen-l10n && fvm flutter test test/l10n`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(l10n): gen-l10n ID/EN, bahasa ikut prefs tanpa restart`.

---

### Task 8: Audio: mesin, layanan, narasi, dan kanal native

**Files:**
- Create:
  - `lib/core/audio/audio_engine.dart`, `lib/core/audio/soloud_audio_engine.dart`, `lib/core/audio/audio_service.dart`, `lib/core/audio/sfx.dart`, `lib/core/audio/asset_catalog.dart`, `lib/core/audio/narrator.dart`, `lib/core/audio/dev_tts.dart`, `lib/core/audio/audio_session.dart`
  - `android/app/src/debug/AndroidManifest.xml` (blok `<queries>` TTS), `android/app/src/profile/AndroidManifest.xml` (sama)
  - `test/helpers/fake_audio.dart`, `test/core/audio/audio_service_test.dart`, `test/core/audio/narrator_test.dart`
- Modify: `ios/Runner/MociChannels.swift`, `android/app/src/main/kotlin/id/pandudpn/moci/MainActivity.kt`, `lib/main.dart`, `lib/app/moci_app.dart` (siklus hidup), `pubspec.yaml` (`flutter_soloud`)

**Interfaces:**
- Consumes: `prefsProvider` (`music`, `sfx`, `lang`), `AppLang` (Task 5).
- Produces:
  - `typedef SoundId = int;`
  - `abstract interface class AudioEngine`:
    - `Future<void> init()`
    - `Future<void> preload(String asset)`, `Future<void> release(String asset)`
    - `Future<SoundId?> play(String asset, {required double volume, bool loop = false})`: memuat aset kalau belum dimuat; mengembalikan null kalau aset gagal dimuat
    - `Future<void> stop(SoundId id)`, `Future<void> setVolume(SoundId id, double volume)`, `Future<void> stopAll()`
    - `Stream<SoundId> get onFinished`
  - `final class SoLoudAudioEngine implements AudioEngine`: menyimpan `AudioSource` yang sedang dimuat per aset, dan melepasnya lewat `release`.
  - `enum Sfx { klik, benar, salahLembut, sorak, bintang }` dengan `String get asset => 'assets/audio/sfx/$name.wav'`.
  - `final class AssetCatalog`: konstruktor `AssetCatalog(Set<String> paths)`, `static Future<AssetCatalog> load(AssetBundle bundle)` (via `AssetManifest`), dan `bool has(String path)`.
  - `final class AudioService`:
    - konstruktor: `AudioService({required AudioEngine engine, required AssetCatalog assets})`
    - konstanta: `narrationVolume = 1.0`, `sfxVolume = 0.7`, `musicVolume = 0.25`, `musicDuckedVolume = 0.10`, `musicAsset = 'assets/audio/musik/latar.ogg'`
    - metode: `narrate(String asset)` (mengembalikan `Future<SoundId?>`), `stopNarration()`, `playSfx(Sfx s)`, `startMusic()`, `stopMusic()`, `applySettings({required bool music, required bool sfx})`, `stopAll()`
  - `abstract interface class DevTts { Future<void> speak(String text, AppLang lang); Future<void> stop(); }`, dengan `MethodChannelDevTts` (kanal `moci/tts`) dan `NoopDevTts`.
  - `abstract interface class AudioSessionConfigurator { Future<void> usePlayback(); }`. Di iOS memakai kanal `moci/audio_session` dengan metode `playback`; di Android tidak melakukan apa pun.
  - `final class NarrationLine { const NarrationLine({required this.jenis, required this.id, required this.text}); }`
  - `final class Narrator`:
    - konstruktor: `Narrator({required AudioService audio, required AssetCatalog assets, required DevTts tts, required bool allowTts})`
    - `Future<void> say(NarrationLine line, AppLang lang)`
    - `Future<void> sayAll(List<NarrationLine> lines, AppLang lang)`: berurutan; klip berikutnya menunggu `onFinished` klip sebelumnya
    - `Future<void> stop()`
  - Provider: `audioEngineProvider`, `assetCatalogProvider`, `devTtsProvider`, `audioServiceProvider` (memanggil `applySettings` setiap `prefs.music`/`prefs.sfx` berubah), `narratorProvider` (`allowTts: !kReleaseMode`).

Aturan `AudioService`:
- `narrate` menghentikan narasi yang sedang jalan, lalu memutar dengan volume 1.0. Selama narasi berjalan, musik diturunkan ke 0.10, dan dikembalikan ke 0.25 saat `onFinished(narasi)`.
- `playSfx` tidak melakukan apa pun kalau efek mati atau asetnya tidak ada.
- `applySettings(music: false)` menghentikan musik.
- `stopAll` menghentikan semuanya dan membersihkan status ducking.
- Aset yang tidak ada di `AssetCatalog` tidak diputar dan tidak memunculkan error.
- Pemuatan mengikuti tabel audio di spec:
  - Narasi dimuat saat diputar, lalu di-`release` setelah `onFinished` atau saat dihentikan, supaya memori tidak menumpuk.
  - Semua `Sfx` di-`preload` sekali setelah engine siap.
  - Musik dimuat saat `startMusic`.

Aturan `Narrator`:
- Path narasi: `assets/audio/vo/${lang.name}/${jenis}_$id.m4a`.
- Kalau path itu tidak ada di katalog dan `allowTts` true, panggil `tts.speak(text, lang)`. Kalau tidak, diam saja.

Aturan siklus hidup di `MociApp`:
- `AppLifecycleListener` memanggil `audioService.stopAll()` dan `narrator.stop()` pada `onHide` dan `onPause`. Mulai iOS, panggilan telepon masuk memicu `inactive` → `hidden`.
- `onResume` memanggil `startMusic()` kalau musik aktif.

Inisialisasi:
- `SoLoudAudioEngine.init()` dan `AudioSessionConfigurator.usePlayback()` dijalankan setelah frame pertama (`addPostFrameCallback`, tanpa `await` di jalur `runApp`), supaya splash muncul dalam waktu kurang dari 1,5 detik.
- Sebelum engine siap, `AudioService` mengabaikan permintaan putar.

Kanal native:
- **`moci/audio_session` (iOS):** `AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)` lalu `setActive(true)`.
- **`moci/tts` (iOS):** `AVSpeechSynthesizer`, suara `id-ID` atau `en-US`, rate 0,45.
- **`moci/tts` (Android):** `TextToSpeech` dengan `Locale("id", "ID")` atau `Locale.US`, di `MainActivity.kt`.
- Blok `<queries><intent><action android:name="android.intent.action.TTS_SERVICE"/></intent></queries>` hanya ada di manifest `debug` dan `profile`, jadi manifest rilis tetap bersih.

- [ ] **Step 1: Tulis tes yang gagal**

`test/helpers/fake_audio.dart`:
- `FakeAudioEngine` mencatat `plays` (berisi `asset`, `volume`, `loop`, `id`), `stopped`, `volumes` (map id → volume terakhir), dan `stopAllCount`.
- `FakeAudioEngine` punya `void finish(SoundId id)` untuk memicu `onFinished`.
- `FakeDevTts` mencatat `spoken` (berisi `text` dan `lang`).

`test/core/audio/audio_service_test.dart` (katalog berisi `music`, `sfx/klik.wav`, `vo/id/ui_a.m4a`, `vo/id/ui_b.m4a`):
```dart
test('narasi baru menghentikan narasi lama', () async {
  final a = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
  await svc.narrate('assets/audio/vo/id/ui_b.m4a');
  expect(engine.stopped, contains(a));
  expect(engine.plays.last.volume, 1.0);
});
test('musik turun ke 0,10 saat narasi lalu kembali 0,25', () async {
  await svc.startMusic();
  final music = engine.plays.single;
  expect((music.volume, music.loop), (0.25, true));
  final n = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
  expect(engine.volumes[music.id], 0.10);
  engine.finish(n!);
  await pumpEventQueue();
  expect(engine.volumes[music.id], 0.25);
});
test('efek 0,7 dan bisa dimatikan', () async {
  await svc.playSfx(Sfx.klik);
  expect(engine.plays.single.volume, 0.7);
  svc.applySettings(music: true, sfx: false);
  await svc.playSfx(Sfx.klik);
  expect(engine.plays, hasLength(1));
});
test('musik dimatikan menghentikan musik', () async {
  await svc.startMusic();
  svc.applySettings(music: false, sfx: true);
  expect(engine.stopped, contains(engine.plays.single.id));
});
test('aset tidak ada tidak diputar', () async {
  expect(await svc.narrate('assets/audio/vo/id/ui_tidak_ada.m4a'), isNull);
  expect(engine.plays, isEmpty);
});
test('stopAll saat ke latar belakang', () async {
  await svc.startMusic();
  await svc.stopAll();
  expect(engine.stopAllCount, 1);
});
test('narasi dilepas setelah selesai', () async {
  final n = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
  engine.finish(n!);
  await pumpEventQueue();
  expect(engine.released, contains('assets/audio/vo/id/ui_a.m4a'));
});
```
`FakeAudioEngine` juga mencatat `preloaded` dan `released`.

`test/core/audio/narrator_test.dart`:
- Kalau ada `assets/audio/vo/en/nama_kucing.m4a`, `say(NarrationLine(jenis: 'nama', id: 'kucing', text: 'Cat'), AppLang.en)` memutar path itu dan tidak memanggil TTS.
- Kalau path tidak ada dan `allowTts: true`, `tts.spoken == [('Cat', AppLang.en)]`.
- Kalau `allowTts: false`, tidak ada yang diputar.
- `sayAll([a, b])` baru memutar `b` setelah `engine.finish(idA)`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/audio`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Jalankan `fvm flutter pub add flutter_soloud`, lalu buat kelas, provider, kanal Swift dan Kotlin, dan manifest debug/profile.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/core/audio`. Expected: PASS. Lalu jalankan `fvm flutter test test/platform_config_test.dart` untuk memastikan manifest utama tetap tanpa `uses-permission` dan tanpa `<queries>` TTS.
- [ ] **Step 5: Cek manual sakelar senyap (Review Focus 5)**

1. Jalankan `fvm flutter run --profile` di iPhone fisik.
2. Nyalakan sakelar senyap, lalu ketuk Moci di Beranda (setelah Task 14). Sapaan harus terdengar lewat TTS dev.
3. Tekan tombol Home sewaktu narasi berjalan. Suara harus berhenti.

Catat hasilnya di deskripsi PR.

- [ ] **Step 6: Commit** dengan pesan `feat(audio): mesin soloud, narasi/efek/musik dengan ducking, TTS dev, sesi playback iOS`.

---

### Task 9: Komponen dasar dan harness tes

**Files:**
- Create: `lib/widgets/pressable.dart`, `lib/widgets/moci_button.dart`, `lib/widgets/moci_back_button.dart`, `lib/widgets/moci_top_bar.dart`, `lib/widgets/star_counter.dart`, `test/helpers/harness.dart`, `test/widgets/pressable_test.dart`, `test/widgets/moci_back_button_test.dart`, `test/widgets/star_counter_test.dart`

**Interfaces:**
- Consumes: token tema (Task 2), `MenuThemeScope` (Task 3), `audioServiceProvider` dan `Sfx` (Task 8), `context.l10n` (Task 7).
- Produces:
  - `class MociPressable extends ConsumerStatefulWidget` dengan parameter:
    - `required Widget child`, `required VoidCallback? onTap`
    - `Color color = MociColors.white`, `Color? shadowColor` (bawaan `MenuThemeScope.of(context).shadow`)
    - `double depth = 7`, `BorderRadius borderRadius = BorderRadius.all(Radius.circular(26))`
    - `String? semanticLabel`, `bool clickSound = true`, `Duration cooldown = MociMotion.tapCooldown`
  - `enum MociButtonKind { primary, light, accent }`, dengan warna primary `#26A03B`/`#1E8A31` dan teks putih, light putih dengan bayangan menu, dan accent `#FFB020`/`#E0870B` dengan teks tinta.
  - `class MociButton extends StatelessWidget` dengan konstruktor `MociButton({required String label, Widget? icon, required VoidCallback? onTap, MociButtonKind kind = MociButtonKind.primary, double height = 70})`.
  - `class MociBackButton extends StatelessWidget` dengan konstruktor `MociBackButton({VoidCallback? onTap, String? semanticLabel})`: 76 × 76, radius 26, bayangan 7, chevron 38 dengan path `M15 5l-7 7 7 7` (stroke tinta 3, ujung bulat). Aksi bawaannya `context.canPop() ? context.pop() : context.go(Routes.beranda)`.
  - `class MociTopBar extends StatelessWidget` dengan konstruktor `MociTopBar({Widget? leading, required String title, List<Widget> trailing = const []})`: diposisikan kiri/kanan 32 dan atas 22, jarak 18, judul `MociText.title`.
  - `class StarCounter extends ConsumerWidget`: pil putih setinggi 64, ikon bintang 38 (isi `#FFC21A`, garis `#F08C00`), Fredoka 700 28, dan angka dari `progressProvider.stars`.
  - Harness di `test/helpers/harness.dart`:
    - `const tabletSize = Size(1180, 820)`, `const phoneSize = Size(844, 390)`
    - `void useScreen(WidgetTester t, Size s, {EdgeInsets padding = EdgeInsets.zero})`
    - `class TestEnv` dengan konstruktor `TestEnv({AppLang lang = AppLang.id, String childName = '', bool onboarded = true, Progress progress = const Progress(), DateTime? now})`. Field: `store`, `json`, `audio` (`FakeAudioEngine`), `tts`, `clock`, `ticks` (`StreamController<void>`), dan `List<Override> get overrides`. Katalog aset kosong.
    - `Future<void> pumpScreen(WidgetTester t, Widget screen, {TestEnv? env, Size size = tabletSize})`: `ProviderScope` + `MaterialApp` (tema, l10n, `locale` dari prefs) dengan `home: screen`.

`Routes` baru ada di Task 11. Sampai saat itu, `MociBackButton` memakai `'/'` sebagai literal sementara. Task 11 menggantinya dengan `Routes.beranda`.

Perilaku `MociPressable`:
- Saat jari menyentuh: animasi 120 ms ke `translateY(+5)` dan `scale(0.97)`. Bayangan memendek sejauh 5, jadi tombol tampak tertekan.
- Saat jari diangkat: kembali, lalu `onTap` dipanggil sekali dan `Sfx.klik` diputar kalau `clickSound` true.
- Ketukan dalam rentang `cooldown` sejak ketukan yang diterima terakhir diabaikan (Review Focus 1).
- Kalau `onTap == null`, tombol diredupkan ke opasitas 0,5 dan tidak bereaksi.
- Pembungkusnya `Semantics(button: true, label: semanticLabel)`.

- [ ] **Step 1: Tulis tes yang gagal**

`test/widgets/pressable_test.dart`:
- Satu ketukan → `onTap` terpanggil sekali dan `env.audio.plays` memuat `Sfx.klik.asset`. Katalog tes diisi path itu untuk kasus ini.
- Saat `tester.startGesture` (sebelum dilepas), `Transform` di dalam pressable punya translasi y = 5 setelah `pump(120 ms)`.
- Dua ketukan berjarak 100 ms → `onTap` 1 kali. Dua ketukan berjarak 500 ms → `onTap` 2 kali.
- `onTap == null` → mengetuk tidak memanggil apa pun.

`test/widgets/moci_back_button_test.dart`:
- Ukuran `tester.getSize(find.byType(MociBackButton)) == Size(76, 83)` (76 ditambah bayangan 7).
- Label semantik `Kembali ke beranda`.

`test/widgets/star_counter_test.dart`: `TestEnv(progress: Progress(stars: 27))` → `find.text('27')`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/widgets`. Expected: FAIL.
- [ ] **Step 3: Implementasikan komponen dan harness.**
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(widget): pressable bayangan padat, tombol, tombol kembali, bilah atas, penghitung bintang`.

---

### Task 10: Maskot Moci dan ilustrasi

**Files:**
- Create: `lib/widgets/moci_mascot.dart`, `lib/widgets/moci_illustration.dart`, `assets/illustrations/*.svg` (41 file, tabel di bawah), `test/widgets/moci_mascot_test.dart`, `test/widgets/moci_illustration_test.dart`
- Modify: `pubspec.yaml` (`vector_graphics`, dev `vector_graphics_compiler`, aset `assets/illustrations/` dengan transformer)

**Interfaces:**
- Produces:
  - `enum MociPose { biasa, senang, tidur }`.
  - `class MociMascot extends StatefulWidget` dengan konstruktor `MociMascot({double size = 184, MociPose pose = MociPose.biasa, VoidCallback? onTap, bool idle = true})`.
  - `class MociIllustration extends StatelessWidget` dengan konstruktor `MociIllustration(String id, {double size = 120, bool silhouette = false, String? semanticLabel})`. Widget ini merender `VectorGraphic(loader: AssetBytesLoader('assets/illustrations/$id.svg'))`. Kalau `silhouette` true, pakai `ColorFilter.mode(Color(0xFF2B2350), BlendMode.srcIn)`. Nilai ini dipakai Tebak Bayangan di Rencana 06.

Pose maskot:
- **`biasa`:** `CustomPainter` dari SVG inline `Main.dc.html:110-137` (viewBox 240 × 240) yang dianimasikan per bagian:

  | Bagian | Durasi | Gerak | Titik putar (unit viewBox) |
  | --- | --- | --- | --- |
  | squish (badan) | 2,6 s | 30%: skala 1,05 × 0,95; 55%: naik 14, skala 0,97 × 1,04; 80%: 1,02 × 0,98 | sekitar (124, 223) |
  | kedip (mata) | 4,4 s | skala Y 1 sampai 90%, 0,1 di 94%, lalu 1 | tengah mata, y ≈ 124 |
  | lambai (lengan kanan) | 1,4 s | putar 0 → −22° → 0 | (189, 128) |
  | daun | 3 s | putar −6° ↔ 6° | (125, 56) |
  | lompat (saat diketuk) | 0,8 s ease-out | 35%: naik 34 dan putar −5°; 70%: turun, skala 1,08 × 0,92 | — |

- **`senang`:** aset `moci-senang.svg`, satu gambar utuh yang hanya melompat. Untuk Hebat: 1,3 s, squash 1,06 × 0,94, naik 40, lalu 1,04 × 0,96 saat mendarat.
- **`tidur`:** aset `moci-tidur.svg`. Bentuknya diambil dari SVG inline `Istirahat.dc.html:47-63` (tanpa awan, yang ada di baris 46), lalu disimpan sebagai file. Animasinya hanya melayang ±10 px selama 5 s.
- Kalau `MediaQuery.disableAnimations` aktif, tidak ada animasi berulang atau lompatan, tetapi `onTap` tetap terpanggil.

Salin SVG dari snapshot: `cp docs/design/prototype/assets/<blob>.svg assets/illustrations/<id>.svg` untuk setiap baris tabel. Tabel ini memuat 30 stiker (D10), 7 gambar kartu Beranda, `moci`, `moci-senang`, dan sampul Karyaku. Ditambah `moci-tidur` dari SVG inline, jumlahnya 41 file. Rencana 02 mengekspor sisanya dengan nama yang sama.

| id | Pakai | blob |
| --- | --- | --- |
| `kucing` | stiker, Beranda | `6de067c8bd1b21524d7d6e6b6f4c199a` |
| `ikan` | stiker | `ce8b6885ad970a4e66e036e133810b2b` |
| `singa` | stiker | `dd80b453f8b3c290ec0572401fe88fe7` |
| `gajah` | stiker | `8cb65c6477727354f6b9ad662449edba` |
| `panda` | stiker | `2aca45982f4d73d88f787d45ec03d315` |
| `pinguin` | stiker | `2d6f65aa46663557cff33fa1ac230978` |
| `apel` | stiker, Beranda | `f3ad85e8656c762498e18346c0834e64` |
| `pisang` | stiker | `c75dbf0ae357afaddcf97c42d58a1160` |
| `stroberi` | stiker | `09d4664bec1323b432b1b9c812474c22` |
| `semangka` | stiker | `b573b73d242c8297b108f60d1a04c80d` |
| `nanas` | stiker, Beranda | `c5b26a2b99c1d84e15e9b08ad81a2811` |
| `buahnaga` | stiker | `ab38e88101d413a3d63b42752d453205` |
| `wortel` | stiker, Beranda | `bd07cd5b5330a2434002468d23961755` |
| `tomat` | stiker | `af7684512ef48e45fd48313f41839ba0` |
| `brokoli` | stiker | `112a01a0bb2ec54bcc9c5d82c4483374` |
| `jagung` | stiker | `e08be0e2320e04d93c135ec839e948c3` |
| `labu` | stiker | `515d2976a430bbde0badf4b3ffcb74a5` |
| `jamur` | stiker | `165cb51bf0986707ffbfb2d921d0e176` |
| `mobil` | stiker | `9a4b52d03d573cb2bb9e7fc33aa00ad6` |
| `bus` | stiker | `5fa24324963167da186e12222fc34b6a` |
| `kereta` | stiker | `c0044435766474df6769a38a15b41072` |
| `pesawat` | stiker | `cf3cbdb44abff66623a1b8886c6334a8` |
| `kapal` | stiker | `c13e9fd9b35f81a1e2e7c8270df7810b` |
| `roket` | stiker | `65a1f0b3aa312fc93fd888b8a105ce98` |
| `bola` | stiker | `b6ba1bc1e8f26eb3aa05f31a41e7bb31` |
| `balon` | stiker | `92d5ae7160761db50ac2050b7ab1a4d5` |
| `kado` | stiker | `89f1eaa66e0150028701c8f5c32dab8c` |
| `eskrim` | stiker | `1c9d89ce71c86ba2d59b5b3b05b5733a` |
| `layang` | stiker | `b318984ee6d49e39029e199e88367107` |
| `payung` | stiker | `f80f0f94891ce851b0295abb6cdfc6b3` |
| `sapi` | Beranda | `eb1bebc96da8f6f1ffc1494e0fc98f3f` |
| `buku` | Beranda | `40764645d095695dc89e65d699f811f8` |
| `xilofon` | Beranda | `01c5c505a58f253f0e264c90f0a261fd` |
| `karyaku` | Beranda (kartu Mewarnai), Galeri | `4061ab5bce10e62e630528c89ad08553` |
| `moci` | Gerbang, avatar Area Orang Tua | `0b224341bbd230f2dd731c560e41d4cb` |
| `moci-senang` | Hebat, panel selesai permainan, Sambutan, Splash | `c6f764abf556b8252c9552e7fa94a90d` |

- [ ] **Step 1: Tulis tes yang gagal**

`test/widgets/moci_mascot_test.dart`:
- Pose `biasa` di ukuran 64 dan 184 tampil tanpa exception.
- Mengetuk memanggil `onTap` sekali.
- Dengan `MediaQuery(data: …copyWith(disableAnimations: true))`, setelah `pump()` → `tester.hasRunningAnimations` false. Tanpa flag itu → true.

`test/widgets/moci_illustration_test.dart`:
- Untuk setiap id di tabel, `File('assets/illustrations/$id.svg').existsSync()`.
- Render `MociIllustration('apel')`, lalu muat dengan `await tester.runAsync(() => vg.loadPicture(const AssetBytesLoader('assets/illustrations/apel.svg'), null))` dan `pump`. Hasilnya tanpa exception. Ini membuktikan transformer berjalan, karena SVG mentah gagal di-decode `AssetBytesLoader`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/widgets/moci_mascot_test.dart test/widgets/moci_illustration_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan**

1. Jalankan `fvm flutter pub add vector_graphics` dan `fvm flutter pub add dev:vector_graphics_compiler`.
2. Deklarasikan aset `- path: assets/illustrations/` dengan `transformers: [{package: vector_graphics_compiler}]`.
3. Kalau tes ilustrasi menunjukkan transformer tidak berjalan untuk deklarasi folder, ganti dengan deklarasi per file. Catat pilihan itu di komentar pubspec.
4. Salin SVG sesuai tabel.
5. Tulis `CustomPainter` maskot dengan path dari baris prototipe yang disebut di atas.

- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(maskot): Moci biasa beranimasi, senang, tidur; ilustrasi vector_graphics`.

---

### Task 11: Router, redirect, dan layar sementara

**Files:**
- Create: `lib/app/routes.dart`, `lib/app/redirect.dart`, `lib/app/router.dart`, `lib/features/segera/coming_soon_screen.dart`, `test/app/redirect_test.dart`, `test/app/router_test.dart`
- Modify: `lib/app/moci_app.dart` (`MaterialApp.router`), `lib/widgets/moci_back_button.dart` (pakai `Routes.beranda`), `test/helpers/harness.dart` (`pumpApp`), `pubspec.yaml` (`go_router`)

**Interfaces:**
- Consumes: `prefsProvider` (`onboarded`), `MenuTheme`, `MociStage`, `MociTopBar`, `progressProvider.setLastActivity`.
- Produces:
  - `abstract final class Routes`: `splash '/splash'`, `sambutan '/sambutan'`, `beranda '/'`, `huruf '/huruf'`, `hurufTulis '/huruf/tulis'`, `hurufUcapkan '/huruf/ucapkan'`, `angka '/angka'`, `angkaTulis '/angka/tulis'`, `hewan '/hewan'`, `buahSayur '/buah-sayur'`, `warna '/warna'`, `bentuk '/bentuk'`, `musik '/musik'`, `sukuKata '/membaca/suku-kata'`, `susunKata '/membaca/susun-kata'`, `kalimat '/membaca/kalimat'`, `mainYuk '/main'`, `cocokkan '/main/cocokkan'`, `memori '/main/memori'`, `bayangan '/main/bayangan'`, `puzzle '/main/puzzle'`, `balon '/main/balon'`, `besarKecil '/main/besar-kecil'`, `mewarnai '/mewarnai'`, `mewarnaiHalaman '/mewarnai/:halaman'`, `karyaku '/karyaku'`, `hebat '/hebat'`, `istirahat '/istirahat'`, `habis '/habis'`, `gerbang '/gerbang'`, `orangTua '/orang-tua'`. Ditambah `static String gerbangLanjut(String target)`, yang menghasilkan `'/gerbang?lanjut=<target ter-encode>'`.
  - `enum RouteKind { intro, play, parent, timer }` dan `RouteKind routeKindOf(String path)`: intro = `/splash` dan `/sambutan`; parent = `/gerbang` dan `/orang-tua`; timer = `/istirahat` dan `/habis`; selain itu play (D14).
  - `String? resolveRedirect({required String path, required bool onboarded, required bool limitReached, required bool parentUnlocked})`.
  - `final parentAccessProvider = NotifierProvider<ParentAccess, bool>(ParentAccess.new)` dengan metode `grant()` dan `revoke()`.
  - `final limitReachedProvider = Provider<bool>((_) => false)`. Task 16 menggantinya agar membaca pengatur waktu.
  - `final routerProvider = Provider<GoRouter>(...)`. `initialLocation: Routes.splash`; `redirect` memanggil `resolveRedirect` dengan `state.uri.path`; `refreshListenable` di-notify setiap kali `prefsProvider.onboarded`, `limitReachedProvider`, atau `parentAccessProvider` berubah.
  - `final currentPathProvider = NotifierProvider<CurrentPath, String>(...)`: diperbarui dari listener `router.routerDelegate` (`currentConfiguration.uri.path`). Task 16 membacanya.
  - `class ComingSoonScreen extends ConsumerStatefulWidget` dengan konstruktor `ComingSoonScreen({required String title, required MenuTheme theme, required String route})`. Layar ini berisi bilah atas dan Moci, dan memanggil `setLastActivity(route)` saat dibuka. Semua rute menu dan permainan memakai layar ini sampai rencananya selesai.
  - Harness: `Future<GoRouter> pumpApp(WidgetTester t, {TestEnv? env, Size size = tabletSize, String? initialLocation})`.

Urutan aturan redirect (kembalikan `null` kalau tidak ada yang cocok):
1. `/splash` → `null`.
2. Belum `onboarded` dan path bukan `/sambutan` → `/sambutan`.
3. Sudah `onboarded` dan path `/sambutan` → `/`.
4. Path `/orang-tua` tanpa `parentUnlocked` → `Routes.gerbangLanjut('/orang-tua')`.
5. `limitReached` dan path bukan `/habis`, `/gerbang`, atau `/orang-tua` → `/habis`.
6. Path `/habis` tanpa `limitReached` → `/`.

Navigasi (D7):
- Beranda membuka menu dengan `context.push`.
- `PopScope(canPop: false)` dipasang di Beranda, Splash, Sambutan, Istirahat, dan Waktu Habis.
- Gerbang memanggil `pop(false)` saat back.

- [ ] **Step 1: Tulis tes redirect berbasis tabel yang gagal**

```dart
void main() {
  final cases = <(String, bool, bool, bool, String?)>[
    // path, onboarded, limitReached, parentUnlocked, expected
    ('/splash', false, false, false, null),
    ('/', false, false, false, '/sambutan'),
    ('/hewan', false, true, false, '/sambutan'),
    ('/sambutan', false, false, false, null),
    ('/sambutan', true, false, false, '/'),
    ('/', true, false, false, null),
    ('/orang-tua', true, false, false, '/gerbang?lanjut=%2Forang-tua'),
    ('/orang-tua', true, false, true, null),
    ('/hewan', true, true, false, '/habis'),
    ('/istirahat', true, true, false, '/habis'),
    ('/habis', true, true, false, null),
    ('/gerbang', true, true, false, null),
    ('/orang-tua', true, true, true, null),
    ('/orang-tua', true, true, false, '/gerbang?lanjut=%2Forang-tua'),
    ('/habis', true, false, false, '/'),
  ];
  for (final (path, onb, lim, par, exp) in cases) {
    test('$path onboarded=$onb limit=$lim parent=$par → $exp', () {
      expect(resolveRedirect(path: path, onboarded: onb, limitReached: lim, parentUnlocked: par), exp);
    });
  }
  test('jenis rute', () {
    expect(routeKindOf('/'), RouteKind.play);
    expect(routeKindOf('/hebat'), RouteKind.play);
    expect(routeKindOf('/gerbang'), RouteKind.parent);
    expect(routeKindOf('/istirahat'), RouteKind.timer);
    expect(routeKindOf('/sambutan'), RouteKind.intro);
  });
}
```

`test/app/router_test.dart` memakai `pumpApp`:
- `TestEnv(onboarded: false)`, `initialLocation: '/'` → layar Sambutan (untuk sementara cukup cek path `router.routerDelegate.currentConfiguration.uri.path == '/sambutan'`).
- `TestEnv(onboarded: true)`, `router.go('/orang-tua')` → path `/gerbang`, dengan `queryParameters['lanjut'] == '/orang-tua'`.
- Dari `/`, `router.push('/hewan')`, lalu `await tester.binding.handlePopRoute()` → kembali ke `/`. Memanggil `handlePopRoute()` lagi di `/` → tetap di `/`.
- `ComingSoonScreen` untuk `/hewan` → `progress.lastActivity!.route == '/hewan'`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/app/redirect_test.dart test/app/router_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Jalankan `fvm flutter pub add go_router`, lalu buat file sesuai bagian Interfaces. Semua rute memakai `ComingSoonScreen`, kecuali yang diganti di task-task berikutnya.
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(router): semua rute v1, redirect Sambutan/Waktu Habis/Area Orang Tua, back sistem`.

---

### Task 12: Ikon aplikasi, splash bawaan OS, dan splash intro

**Files:**
- Create:
  - `lib/app/splash/splash_screen.dart`, `test/app/splash/splash_screen_test.dart`, `test/platform_brand_test.dart`
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`, `ios/Runner/Assets.xcassets/LaunchLogo.imageset/*`
  - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`, `android/app/src/main/res/drawable-nodpi/ic_launcher_{foreground,background,monochrome}.png`, `android/app/src/main/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png`
  - `android/app/src/main/res/drawable-xxxhdpi/splash_logo.png`, `android/app/src/main/res/drawable-xxxhdpi/splash_icon.png`, `android/app/src/main/res/values-v31/styles.xml`
- Modify: `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `android/app/src/main/res/drawable/launch_background.xml`, `android/app/src/main/res/drawable-v21/launch_background.xml`, `android/app/src/main/res/values/colors.xml`, `lib/app/router.dart` (rute `/splash`)

**Interfaces:**
- Consumes: `MociStage`, `MociMascot(pose: senang)` (pose ini yang dipakai di splash prototipe), `Routes`.
- Produces: `class SplashScreen extends StatefulWidget`, terpasang di `Routes.splash`. Layar ini memanggil `context.go(Routes.beranda)` setelah 3600 ms atau saat diketuk; redirect yang memilih Sambutan atau Beranda.

Aset brand (semua ada di `docs/brand`):

| Kebutuhan | Sumber | Tujuan |
| --- | --- | --- |
| Ikon iOS: terang, gelap, tinted | `icon/ios/moci-icon-1024.png`, `moci-icon-dark-1024.png`, `moci-icon-tinted-1024.png` | `AppIcon.appiconset` dengan satu ukuran 1024. `Contents.json` memakai tiga entri `"platform": "ios"`, `"size": "1024x1024"`, dan `appearances` luminosity `dark` serta `tinted`. |
| Ikon adaptif Android | `icon/android/ic_launcher_{foreground,background,monochrome}-1024.png` | `drawable-nodpi/ic_launcher_*.png`, plus `mipmap-anydpi-v26/ic_launcher.xml` (`<adaptive-icon>` dengan background, foreground, monochrome) |
| Ikon lama Android | `icon/android/ic_launcher-legacy-512.png` | `mipmap-*/ic_launcher.png` 48/72/96/144/192 px, dibuat dengan `sips -Z <px>` |
| Splash iOS dan Android lama | `splash/splash-logo.png` (685 × 900) | `LaunchLogo.imageset` (@3x), `drawable-xxxhdpi/splash_logo.png` |
| Splash Android 12+ | `splash/splash-icon-android12.png` (1152 × 1152) | `drawable-xxxhdpi/splash_icon.png` |

Splash bawaan OS memakai warna latar `#74C4FF`, sama dengan warna awal gradien intro, jadi perpindahannya mulus:
- **iOS** (`LaunchScreen.storyboard`): latar `#74C4FF`, `UIImageView` `LaunchLogo` di tengah dengan aspect fit, tinggi 60% dari tinggi safe area.
- **Android lama** (`launch_background.xml`): `layer-list` berisi warna `@color/splash_bg` (`#74C4FF`) dan bitmap `@drawable/splash_logo` di tengah.
- **Android 12+** (`values-v31/styles.xml`): `windowSplashScreenBackground` = `@color/splash_bg`, `windowSplashScreenAnimatedIcon` = `@drawable/splash_icon`.

Splash intro mengikuti `SplashTablet.dc.html` (tablet) dan `SplashHP.dc.html` (HP), tema terang. Satu `AnimationController` berdurasi 5000 ms dijalankan sekali, dan pindah layar di 3600 ms.

| t (ms) | Kejadian |
| --- | --- |
| 0 → 700 | Moci jatuh dari y −560 (HP −320) ke 0, lalu squash 1,08 × 0,9 di dasar. Moci juga bergoyang terus ±10 px (HP ±6), satu putaran 2400 ms. |
| 700 → 1000 → 1300 | Memantul ke −34 (HP −20) dengan skala 0,97 × 1,04, lalu diam di skala 1. |
| 1100 → 1500 → 1800 → 2000 | Huruf M: skala 0 → 1,22 → 0,95 → 1 (opasitas penuh di 1500). Huruf o, c, i menyusul dengan jeda +100, +200, dan +300 ms. Huruf disembunyikan sampai gilirannya; jangan tiru kedip di prototipe. |
| 1900 → 2300 | Pil tagline (`berandaTag`: "Main & Belajar" / "Play & Learn") muncul dan naik dari +16 (HP +10). |
| terus-menerus | Tiga titik: putaran 1000 ms, jeda 0/150/300 ms, naik −12 (HP −8). |
| 3600 | `context.go(Routes.beranda)`. |

Detail lain:
- Mengetuk di mana saja langsung berpindah layar.
- Kalau `disableAnimations` aktif, tampilkan frame akhir yang diam, dan tetap pindah di 3600 ms.
- Warna huruf M `#F03E7C`, o `#FF9F1C`, c `#1C8CF0`, i `#26A03B`, dengan garis putih 5/4 (HP 4/3) dan bayangan `0 12` (HP `0 8`) warna `rgba(43,35,80,.22)`.
- Layar ini tidak bersuara.

- [ ] **Step 1: Tulis tes yang gagal**

`test/platform_brand_test.dart`:
- File-file tujuan di tabel ada.
- `ic_launcher.xml` memuat `<monochrome`.
- `values-v31/styles.xml` memuat `windowSplashScreenAnimatedIcon`.
- `colors.xml` memuat `#74C4FF`.
- `AppIcon.appiconset/Contents.json` memuat `"luminosity"` dan `"tinted"`.

`test/app/splash/splash_screen_test.dart` memakai `pumpApp` dengan `initialLocation: '/splash'`:
- Setelah `pump(3599 ms)` path masih `/splash`; setelah `pump(1 ms)` path `/`.
- Dengan `TestEnv(onboarded: false)`, `pump(3600 ms)` → path `/sambutan`.
- Ketukan di `(10, 10)` pada `pump(200 ms)` → path `/` tanpa menunggu 3600 ms.
- Tidak ada `plays` di `FakeAudioEngine`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/app/splash test/platform_brand_test.dart`. Expected: FAIL.
- [ ] **Step 3: Pasang aset brand dan buat `SplashScreen`.**
- [ ] **Step 4: Jalankan tes.** Expected: PASS. Lalu jalankan `fvm flutter run` di simulator iPad dan emulator Android 14. Splash bawaan berwarna biru langit harus langsung berganti ke intro tanpa kilatan putih.
- [ ] **Step 5: Commit** dengan pesan `feat(splash): ikon, splash bawaan iOS/Android, intro Moci 3,6 detik`.

---

### Task 13: Sambutan

**Files:**
- Create: `lib/features/sambutan/sambutan_screen.dart`, `lib/features/sambutan/widgets/` (kartu bahasa, kolom nama, chip usia), `test/features/sambutan/sambutan_screen_test.dart`
- Modify: `l10n/app_*.arb` (kunci `sambutan*`), `lib/app/router.dart`

**Interfaces:**
- Consumes: `prefsProvider` (`setLang`, `completeOnboarding`), `narratorProvider`, `MociMascot(pose: senang)`, `MociStage(theme: MenuTheme.sambutan)`.
- Produces: `class SambutanScreen extends ConsumerStatefulWidget`, terpasang di `Routes.sambutan`.

Tata letak dan teks mengikuti `Sambutan.dc.html`. Kunci ARB diambil dari `T`: `sambutanTag`, `sambutanHi`, `sambutanSub`, `sambutanNameLabel`, `sambutanNamePh`, `sambutanAge`, `sambutanYears`, `sambutanNote`, `sambutanStart`, `sambutanSkip`, `sambutanHello`, `sambutanFriend`, `sambutanSay`, dan `sambutanBadge1`–`sambutanBadge3`. Ditambah `sambutanHalo` ("Halo! Aku Moci." / "Hi! I'm Moci."), varian tanpa nama dari `sambutanSay` (D5). Teks "Pilih bahasa · Choose a language" dan judul kartu bahasa tetap dwibahasa, tidak diterjemahkan.

Perilaku:
1. **Pilihan bahasa:**
   - Mengetuk kartu bahasa langsung memanggil `setLang`, sehingga semua teks Sambutan langsung berganti.
   - Narasi `langNameId` diputar dengan suara `id`, atau `langNameEn` dengan suara `en`.
   - Kartu yang terpilih punya isi `#EAF4FF`, border `#1C7ED6` setebal 5, dan centang dengan animasi pop 400 ms.
2. **Kolom nama:**
   - Maksimal 20 karakter (`maxLength`).
   - Saat keyboard terbuka di HP, isi panggung digeser ke atas sejauh tinggi keyboard dibagi skala panggung, supaya kolom tetap terlihat.
3. **Chip usia:** 2–3, 4–5, dan 6–7, dengan pilihan bawaan 2–3.
4. **Gelembung Moci:** `"${sambutanHello}, ${nama atau sambutanFriend}!"`, contohnya "Hai, teman!" / "Hi, friend!".
5. **Mengetuk Moci:** kalau nama kosong, narasikan `sambutanSay`; kalau ada nama, narasikan `sambutanHalo` (D5).
6. **CTA "Ayo Mulai!":**
   - Narasi `sambutanStart`.
   - `completeOnboarding(lang, childName, age)`.
   - `context.go(Routes.beranda)`.
   - CTA selalu aktif.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('alur lengkap menyimpan prefs dan membuka Beranda', (t) async {
  final env = TestEnv(onboarded: false);
  final router = await pumpApp(t, env: env, initialLocation: '/sambutan');
  await t.tap(find.text('English'));
  await t.pump();
  expect(find.text("Let's Go!"), findsOneWidget); // copy EN dari Sambutan.dc.html
  await t.enterText(find.byType(TextField), '  Raka  ');
  await t.tap(find.textContaining('6–7'));
  await t.tap(find.text("Let's Go!"));
  await t.pumpAndSettle();
  final c = ProviderScope.containerOf(t.element(find.byType(Router<Object>)));
  final p = c.read(prefsProvider);
  expect((p.lang, p.childName, p.ageLevel, p.onboarded), (AppLang.en, 'Raka', AgeLevel.pembaca, true));
  expect(router.routerDelegate.currentConfiguration.uri.path, '/');
});
```

Tes tambahan:
- Nama 25 karakter → yang tersimpan 20 karakter.
- Mengetuk Moci saat nama kosong → narasi `ui_sambutanSay`. Saat nama terisi → `ui_sambutanHalo`. Cek lewat `env.tts.spoken`, karena katalog tes kosong.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/sambutan`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.**
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(sambutan): pilih bahasa, nama, usia; sekali saat pertama dibuka`.

---

### Task 14: Beranda (tablet dan HP)

**Files:**
- Create: `lib/features/beranda/beranda_screen.dart`, `lib/features/beranda/beranda_menu.dart`, `lib/features/beranda/continue_labels.dart`, `lib/features/beranda/widgets/{menu_card,continue_card,lang_switch,beranda_tablet,beranda_phone}.dart`, `test/flutter_test_config.dart`, `test/features/beranda/beranda_screen_test.dart`, `test/features/beranda/beranda_golden_test.dart`
- Modify: `l10n/app_*.arb` (kunci `beranda*` dan `menu*`), `lib/app/router.dart`

**Interfaces:**
- Consumes: `prefsProvider`, `progressProvider` (`stars`, `lastActivity`), `narratorProvider`, `MociMascot`, `MociIllustration`, `StarCounter`, `Routes`, `MenuTheme.beranda`.
- Produces:
  - `enum BerandaMenu { huruf, angka, hewan, buah, baca, main, warnai, warna, bentuk, musik }`, dengan field `String route`, `Color color`, dan `Color shadow`.
  - `typedef ContinueLabelBuilder = String Function(AppLocalizations l10n, Map<String, String> params);`
  - `final Map<String, ContinueLabelBuilder> continueLabels`. Di rencana ini isinya judul menu untuk setiap rute menu. Rencana fitur menambahkan entri yang lebih spesifik, misalnya "Tulis huruf {huruf}".
  - `class BerandaScreen extends ConsumerWidget`, terpasang di `Routes.beranda`.

Kartu menu, dengan teks di `Main.dc.html:377-391`. Kunci ARB: `menu<Id>Title` dan `menu<Id>Sub`, contoh `menuHurufTitle` = "Kenal Huruf" / "Letters".

| Menu | Rute | Warna | Bayangan | Gambar kartu |
| --- | --- | --- | --- | --- |
| huruf | `/huruf` | `#FF6B6B` | `#E04848` | ubin A/B/C digambar di Flutter |
| angka | `/angka` | `#4DA8FF` | `#2A84E0` | lingkaran 1/2/3 |
| hewan | `/hewan` | `#5FD068` | `#3BAA45` | `sapi`, `kucing` |
| buah | `/buah-sayur` | `#FF7EB6` | `#E0528F` | `wortel`, `apel` |
| baca | `/membaca/suku-kata` | `#FF8A3D` | `#E0661A` | `buku` + gelembung "ba" dan "bu" |
| main | `/main` | `#22C1C3` | `#129A9C` | dua kartu `nanas` + bintang |
| warnai | `/mewarnai` | `#FFC233` | `#E0A100` | `karyaku` + dua krayon |
| warna | `/warna` | `#9775FA` | `#7048E8` | pelangi |
| bentuk | `/bentuk` | `#5C7CFA` | `#3B5BDB` | lingkaran, segitiga, persegi |
| musik | `/musik` | `#F06595` | `#C2255C` | `xilofon` + not musik |

Perilaku:
1. **Sapaan:** `berandaHi` dengan placeholder `name`, berisi `prefs.childName` atau `childFallbackName`. Baris tanya: `berandaAsk`.
2. **Mengetuk Moci:** lompat, lalu narasikan `berandaSay` ("Hai! Aku Moci. Mau main apa hari ini?"), varian tanpa nama (D5).
3. **Mengetuk kartu:** narasikan judul menu (`NarrationLine(jenis: 'ui', id: 'menu<Id>Title', text: <judul dari l10n>)`; kunci `menu*Title` diberi description `narasi`), lalu `context.push(route)` di frame yang sama. Narasi tetap berbunyi di layar berikutnya.
4. **Kartu Lanjutkan:**
   - Tampil hanya kalau `progress.lastActivity != null` (D6).
   - Subjudulnya `continueLabels[route]`; kalau tidak ada, pakai judul menu dari rute induk.
   - Mengetuk kartu memanggil `context.push(route)`, dengan `params` sebagai query.
5. **Tombol ID/EN:** `setLang`, lalu narasikan nama bahasa dalam bahasa itu. Tombol aktif berwarna ID `#E8384F` dan EN `#1C7ED6` dengan teks putih.
6. **Tombol Orang Tua:** `context.push(Routes.gerbangLanjut(Routes.orangTua))`.
7. **Bintang:** `StarCounter`, dengan label semantik `berandaStarsLabel`. Format EN memakai plural: `{count, plural, =1{1 star} other{{count} stars}}`.
8. **Rail menu:** dua baris, diisi per kolom: (huruf, angka), (hewan, buah), (baca, main), (warnai, warna), (bentuk, musik). Hanya bisa digulir horizontal, tanpa scrollbar.
9. **Layout HP:** mengikuti `HP.dc.html`: kolom kiri selebar 176 berisi gelembung, Moci 104, dan Lanjutkan 176 × 92; rail di kanan dengan kartu 156 × 142.
10. **Layout tablet:** mengikuti `Main.dc.html`.
11. Semua angka posisi dan ukuran mengikuti kedua artboard.
12. Pasang `PopScope(canPop: false)`.

`test/flutter_test_config.dart` memuat Fredoka dan Nunito dari `assets/fonts` dengan `FontLoader` sebelum semua tes, supaya golden memakai font asli.

- [ ] **Step 1: Tulis tes yang gagal**

`beranda_screen_test.dart`:
- Untuk setiap `BerandaMenu`, mengetuk kartu → path router sama dengan `menu.route`, dan `env.tts.spoken.last.$1` sama dengan judul menu. Uji di layout tablet dan HP; kartu yang tersembunyi di rail digulir dulu dengan `scrollUntilVisible`.
- `childName ''` → `find.text('Hai, Adik!')`. `childName 'Raka'` dan EN → `find.text('Hi, Raka!')`.
- Tanpa `lastActivity` → kartu Lanjutkan tidak ada. Dengan `LastActivity('/hewan')` → kartu tampil dengan "Dunia Hewan", dan mengetuknya membuka `/hewan`.
- Mengetuk EN → `prefs.lang == AppLang.en` dan `find.text('Letters')`.
- Mengetuk Orang Tua → path `/gerbang` dengan `lanjut=/orang-tua`.

`beranda_golden_test.dart` (`@Tags(['golden'])`) membuat tiga golden: `beranda_tablet_id.png` (anak "Raka", 24 bintang, `lastActivity` `/hewan`), `beranda_tablet_en.png`, dan `beranda_hp_id.png`. Animasi dimatikan lewat `disableAnimations`, dan ilustrasi dimuat dulu lewat `runAsync`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/beranda --exclude-tags golden`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.**
- [ ] **Step 4: Jalankan tes dan buat golden.** Run: `fvm flutter test test/features/beranda --exclude-tags golden`, lalu `fvm flutter test test/features/beranda --tags golden --update-goldens`. Expected: PASS. Bandingkan ketiga golden secara visual dengan `docs/screenshots/03-beranda.png` dan `31-beranda-hp.png`.
- [ ] **Step 5: Commit** dengan pesan `feat(beranda): 10 menu, sapaan, Lanjutkan, ID/EN, bintang; tablet dan HP`.

---

### Task 15: Gerbang Orang Tua

**Files:**
- Create: `lib/features/orang_tua/gerbang_game.dart`, `lib/features/orang_tua/gerbang_screen.dart`, `lib/widgets/number_keypad.dart`, `test/features/orang_tua/gerbang_game_test.dart`, `test/features/orang_tua/gerbang_screen_test.dart`
- Modify: `l10n/app_*.arb` (kunci `gerbang*`), `lib/app/router.dart`

**Interfaces:**
- Consumes: `parentAccessProvider`, `narratorProvider`, `MociIllustration('moci')`, `MenuTheme.gerbang`.
- Produces:
  - `final class GateQuestion { const GateQuestion(this.a, this.b); final int a, b; int get answer => a * b; }`
  - `GateQuestion nextGateQuestion(Random rng, {GateQuestion? previous})`: a = 6 + `rng.nextInt(4)`, b = 3 + `rng.nextInt(7)`. Kalau hasilnya sama dengan `previous`, ulang sampai 20 kali.
  - `enum GateStatus { idle, ok, bad, retry }`.
  - `final class GateState { final GateQuestion q; final String input; final GateStatus status; }`.
  - Fungsi murni:
    - `GateState gateDigit(GateState s, int digit)`: input maksimal 2 digit; digit kedua langsung dinilai (`ok` atau `bad`); diabaikan kalau status `ok` atau `bad`.
    - `GateState gateDelete(GateState s)`: menghapus satu digit dan mengembalikan status ke `idle`; diabaikan kalau status `bad`.
    - `GateState gateNewQuestion(GateState s, Random rng)`.
  - `class NumberKeypad extends StatelessWidget` dengan konstruktor `NumberKeypad({required ValueChanged<int> onDigit, required VoidCallback onDelete})`. Susunannya 1–9, kosong, 0, ⌫. Tombol 96 × 84, radius 24, warna `#F4F1FA` dengan bayangan `#DCD5EE` setebal 6, Fredoka 40/600. Tombol ⌫ berwarna `#FFE3DA` dengan bayangan `#F3C2B3` dan ikon `#A61E33` (D9).
  - `class GerbangScreen extends ConsumerStatefulWidget`, terpasang di `Routes.gerbang`, dengan query opsional `lanjut`.

Perilaku layar, dengan tata letak, teks, dan warna status dari `Gate.dc.html`:
1. **Saat dibuka:** soal acak dengan isian kosong, lalu narasi `gerbangHelpSay` ("Ini khusus orang tua. Panggil Ayah atau Bunda, ya!") (D9).
2. **Jawaban salah:**
   - Baris jawaban bergoyang 450 ms dan status `bad` ("Belum tepat.").
   - Setelah 1000 ms muncul soal baru dengan isian kosong dan status `retry` ("Coba soal baru ini, ya.").
   - Tidak ada batas percobaan dan tidak ada bunyi salah.
3. **Jawaban benar:** status `ok` ("Benar! Silakan masuk."), dan tombol "Masuk" muncul dengan animasi pop. Menghapus digit setelah benar mengunci gerbang kembali.
4. **Tombol "Masuk":**
   - `parentAccess.grant()`.
   - Kalau ada `lanjut`: `context.pushReplacement(lanjut)`.
   - Kalau tidak: `context.pop(true)`. Pola ini nanti dipakai untuk izin mikrofon di Rencana 03 dan tautan keluar.
5. **Tombol "Batal" dan back sistem:** `context.pop(false)`, atau `context.go(Routes.beranda)` kalau tidak ada layar untuk di-pop.
6. **Tombol "Ganti soal":** ganti soal kapan saja, tanpa pesan `retry`.
7. **Label aksesibilitas soal:** `gerbangTimes` ("{a} kali {b}" / "{a} times {b}").

- [ ] **Step 1: Tulis tes yang gagal**

```dart
test('rentang soal 6–9 × 3–9 di 2000 seed', () {
  for (var seed = 0; seed < 2000; seed++) {
    final q = nextGateQuestion(Random(seed));
    expect(q.a, inInclusiveRange(6, 9));
    expect(q.b, inInclusiveRange(3, 9));
    expect(q.answer, inInclusiveRange(18, 81));
  }
});
test('soal berikutnya tidak sama persis', () {
  const prev = GateQuestion(7, 6);
  for (var seed = 0; seed < 200; seed++) {
    final q = nextGateQuestion(Random(seed), previous: prev);
    expect((q.a, q.b), isNot((7, 6)));
  }
});
test('dua digit menilai jawaban', () {
  var s = const GateState(GateQuestion(7, 6), '', GateStatus.idle);
  s = gateDigit(gateDigit(s, 4), 2);
  expect(s.status, GateStatus.ok);
  expect(gateDigit(s, 1).input, '42'); // diabaikan setelah ok
  expect(gateDelete(s).status, GateStatus.idle); // terkunci lagi
  final bad = gateDigit(gateDigit(const GateState(GateQuestion(7, 6), '', GateStatus.idle), 4), 3);
  expect(bad.status, GateStatus.bad);
});
```

`gerbang_screen_test.dart` (soal disuntik lewat `Random` dengan seed tetap, misalnya provider `gateRandomProvider`):
- Saat dibuka, `env.tts.spoken.first.$1 == 'Ini khusus orang tua. Panggil Ayah atau Bunda, ya!'`.
- Jawaban salah → setelah `pump(1000 ms)` soal berganti dan teks "Coba soal baru ini, ya." tampil.
- Jawaban benar, lalu ketuk "Masuk" → `parentAccessProvider == true` dan path `/orang-tua` (dibuka dari `/gerbang?lanjut=/orang-tua`).
- "Batal" → kembali ke `/`, dan `parentAccessProvider == false`.
- Semua tombol angka berukuran 96 × 90 (84 ditambah bayangan 6).

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/orang_tua/gerbang_*`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.**
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(gerbang): soal perkalian 6–9 × 3–9, papan angka, lanjut atau kembali dengan hasil`.

---

### Task 16: Pengatur waktu bermain, Istirahat, dan Waktu Habis

**Files:**
- Create: `lib/app/play_timer/play_timer.dart`, `lib/app/play_timer/play_timer_controller.dart`, `lib/features/istirahat/istirahat_screen.dart`, `lib/features/istirahat/habis_screen.dart`, `test/app/play_timer/play_timer_test.dart`, `test/app/play_timer/play_timer_flow_test.dart`, `test/features/istirahat/istirahat_screen_test.dart`
- Modify: `lib/app/router.dart` (`limitReachedProvider` membaca pengatur waktu), `lib/app/moci_app.dart` (membuka Istirahat saat waktunya), `l10n/app_*.arb` (kunci `istirahat*` dan `habis*`), `test/helpers/harness.dart` (`TestEnv.overrides` ditambah `playTimerTicksProvider.overrideWithValue(ticks.stream)`)

**Interfaces:**
- Consumes: `clockProvider`, `prefsProvider` (`dailyLimitMinutes`, `restReminder`), `progressProvider.setPlaySeconds`, `progressProvider` awal (`playSeconds[hari ini]`), `currentPathProvider`, `routeKindOf`.
- Produces:
  - `@immutable final class PlayTimerState { final String date; final int secondsToday; final int secondsSinceRest; final bool restDue; final bool limitReached; }`
  - `PlayTimerState tickPlayTimer(PlayTimerState s, {required DateTime now, required Duration elapsed, required bool counting, required int? limitMinutes, required bool restReminder, required int Function(String date) storedSecondsFor})`
  - `final playTimerTicksProvider = Provider<Stream<void>>((_) => Stream.periodic(const Duration(seconds: 1)));`
  - `final playTimerProvider = NotifierProvider<PlayTimerController, PlayTimerState>(...)`, dengan metode `restTaken()`.
  - `limitReachedProvider` diganti dengan `Provider((ref) => ref.watch(playTimerProvider.select((s) => s.limitReached)))`.
  - `class IstirahatScreen` (`Routes.istirahat`) dan `class HabisScreen` (`Routes.habis`).

Aturan `tickPlayTimer` (murni, diuji tanpa UI):
1. Kalau `dateKey(now) != s.date`: pindah tanggal. `secondsToday` diisi `storedSecondsFor(tanggal baru)` (biasanya 0), dan `secondsSinceRest` direset ke 0.
2. Kalau `counting`: tambah `elapsed` setelah di-clamp ke rentang 0–2 detik. Ini menangani jam yang mundur, jam yang loncat, dan aplikasi yang ditangguhkan tanpa event pause (Review Focus 2).
3. `restDue = restReminder && secondsSinceRest >= 1200`.
4. `limitReached = limitMinutes != null && secondsToday >= limitMinutes * 60`.

Aturan controller:
- Setiap tick: `counting = aplikasi resumed && routeKindOf(currentPath) == RouteKind.play`.
- `setPlaySeconds(date, secondsToday)` dipanggil setiap 30 detik terhitung, serta saat `onPause` dan `onHide`.
- `restTaken()` mereset `secondsSinceRest` ke 0 dan `restDue` ke false.
- Perubahan `dailyLimitMinutes` langsung dihitung ulang tanpa menunggu tick berikutnya, jadi menaikkan batas langsung membuka blokir.

`MociApp` memakai `ref.listen(playTimerProvider)`. Saat `restDue` berubah menjadi true dan path saat ini berjenis play, panggil `router.push(Routes.istirahat)` satu kali. Penjaganya: jangan push kalau path sudah `/istirahat`.

Istirahat (D8, mengikuti `Istirahat.dc.html` varian `istirahat`, tanpa pil orang tua (D13)):
- Hitung mundur 20 → 0 per 1000 ms.
- Langkah aktif `left > 13 ? 0 : left > 6 ? 1 : 2`, berisi "Lihat jauh ke luar jendela", "Kedip-kedip 10 kali", dan "Regangkan tangan ke atas".
- Setiap langkah dinarasikan saat mulai: `istirahatStep1` digabung dengan `istirahatTitle` di awal, lalu `istirahatStep2` dan `istirahatStep3`.
- Cincin hitung mundur 150 px (r 62, stroke 14) memakai `semanticsLabel` "Sisa waktu istirahat: N detik".
- Di 0: narasi `istirahatDoneTitle` ("Sudah segar lagi!"), `restTaken()`, lalu `context.pop()`.
- Pasang `PopScope(canPop: false)`.
- Maskot memakai `MociPose.tidur`.

Waktu Habis mengikuti varian `habis` di file yang sama, dengan `MenuTheme.istirahat` dan maskot `MociPose.tidur`:
- Judul `habisTitle`, subjudul `habisSub` dengan placeholder `name` (fallback `childFallbackName`), dan catatan `habisNote`.
- Narasi `habisTitle` saat dibuka.
- Pil `habisParents` → `context.push(Routes.gerbangLanjut(Routes.orangTua))`.
- Pasang `PopScope(canPop: false)`.

- [ ] **Step 1: Tulis tes aturan yang gagal**

```dart
PlayTimerState t0(String d) => PlayTimerState(date: d, secondsToday: 0, secondsSinceRest: 0, restDue: false, limitReached: false);
PlayTimerState run(PlayTimerState s, int seconds, {int? limit = 30, bool rest = true, bool counting = true, DateTime? at}) {
  var now = at ?? DateTime(2026, 11, 14, 9);
  for (var i = 0; i < seconds; i++) {
    now = now.add(const Duration(seconds: 1));
    s = tickPlayTimer(s, now: now, elapsed: const Duration(seconds: 1), counting: counting,
        limitMinutes: limit, restReminder: rest, storedSecondsFor: (_) => 0);
  }
  return s;
}

test('hanya menghitung saat counting', () {
  expect(run(t0('2026-11-14'), 60, counting: false).secondsToday, 0);
  expect(run(t0('2026-11-14'), 60).secondsToday, 60);
});
test('istirahat tepat di 20 menit kalau aktif', () {
  expect(run(t0('2026-11-14'), 1199).restDue, isFalse);
  expect(run(t0('2026-11-14'), 1200).restDue, isTrue);
  expect(run(t0('2026-11-14'), 1200, rest: false).restDue, isFalse);
});
test('batas 15/30/45/tanpa batas', () {
  expect(run(t0('2026-11-14'), 899, limit: 15).limitReached, isFalse);
  expect(run(t0('2026-11-14'), 900, limit: 15).limitReached, isTrue);
  expect(run(t0('2026-11-14'), 1800, limit: 30).limitReached, isTrue);
  expect(run(t0('2026-11-14'), 2699, limit: 45).limitReached, isFalse);
  expect(run(t0('2026-11-14'), 10000, limit: null).limitReached, isFalse);
});
test('tengah malam mereset', () {
  final s = run(t0('2026-11-14'), 1800, at: DateTime(2026, 11, 14, 23, 30));
  expect(s.limitReached, isTrue);
  final next = tickPlayTimer(s, now: DateTime(2026, 11, 15, 0, 0, 5), elapsed: const Duration(seconds: 1),
      counting: true, limitMinutes: 30, restReminder: true, storedSecondsFor: (_) => 0);
  expect((next.date, next.secondsToday, next.limitReached), ('2026-11-15', 1, false));
});
test('jam mundur atau loncat tidak merusak hitungan', () {
  final s = run(t0('2026-11-14'), 100);
  final back = tickPlayTimer(s, now: DateTime(2026, 11, 14, 8), elapsed: const Duration(seconds: -3600),
      counting: true, limitMinutes: 30, restReminder: true, storedSecondsFor: (_) => 0);
  expect(back.secondsToday, 100);
  final jump = tickPlayTimer(s, now: DateTime(2026, 11, 14, 12), elapsed: const Duration(hours: 3),
      counting: true, limitMinutes: 30, restReminder: true, storedSecondsFor: (_) => 0);
  expect(jump.secondsToday, 102);
});
```

`play_timer_flow_test.dart` memakai `pumpApp`, `TestEnv` dengan ticks manual, dan `FakeClock`:
1. Di `/hewan` (dibuka lewat push dari `/`), kirim 1200 tick sambil memajukan jam → path `/istirahat`, dan layar `/hewan` tetap ada di stack.
2. `pump(20 s)` → kembali ke `/hewan`, dan `secondsSinceRest == 0`.
3. Dengan `limit 15`, kirim 900 tick → path `/habis`, dan back sistem tidak mengubah path.
4. `setDailyLimit(30)` → path `/`.
5. Di `/orang-tua` atau `/gerbang`, tick tidak menambah `secondsToday`.
6. Setelah 30 tick terhitung, `progress.playSeconds['2026-11-14'] == 30`.

`istirahat_screen_test.dart`:
- Di detik ke-0, 7, dan 14, teks langkah aktif berganti sesuai urutan.
- Narasi `istirahatStep2` diputar di detik ke-7.
- Tidak ada tombol "Lanjut main".

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/app/play_timer test/features/istirahat`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.**
- [ ] **Step 4: Jalankan tes.** Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(waktu): pengatur waktu harian per tanggal, istirahat 20 detik, Waktu Habis`.

---

### Task 17: Hadiah: stiker dan layar Hebat

**Files:**
- Create: `lib/features/hadiah/stiker.dart`, `lib/features/hadiah/hadiah_controller.dart`, `lib/features/hadiah/hebat_screen.dart`, `test/features/hadiah/hadiah_controller_test.dart`, `test/features/hadiah/hebat_screen_test.dart`, `test/features/hadiah/hebat_golden_test.dart`
- Modify: `lib/app/router.dart`, `l10n/app_*.arb` (kunci `hebat*`)

**Interfaces:**
- Consumes: `progressProvider` (`addStars`, `addSticker`, `stickers`), `narratorProvider`, `MociMascot(pose: senang)`, `MociIllustration`, `Routes`.
- Produces:
  - `const List<String> stickerCatalog`: 30 id stiker dari tabel Task 10, urut per tema: hewan, buah, sayur, kendaraan, benda. File `stiker.dart` tidak boleh mengimpor Flutter, karena validator konten di Rencana 02 ikut membacanya.
  - `final class AwardResult { const AwardResult({required this.stars, this.sticker}); final int stars; final String? sticker; }`.
  - `final class HebatArgs { const HebatArgs({required this.award, required this.replayRoute}); }`.
  - `final hadiahProvider = Provider<HadiahController>(...)`, dengan `Future<AwardResult> finishGame({required String gameId, required String roundId})`. Fungsi ini menambah 3 bintang dan satu stiker acak dari yang belum dimiliki, dengan `Random` yang bisa disuntik lewat `hadiahRandomProvider`. Kalau `roundId` yang sama dipanggil lagi, fungsi mengembalikan hasil yang sama tanpa menambah apa pun.
  - `class HebatScreen extends ConsumerWidget`, terpasang di `Routes.hebat`. Datanya dari `state.extra as HebatArgs`.
  - Pola untuk rencana permainan (Rencana 04 dan 06):
    1. Saat ronde selesai, panggil `finishGame(gameId, roundId)` sekali (D10).
    2. Panel selesai menampilkan "Main lagi" (ronde baru di tempat) dan "Ambil hadiah".
    3. "Ambil hadiah" memanggil `context.pushReplacement(Routes.hebat, extra: HebatArgs(award, replayRoute: <rute permainan>))`.

Tata letak, teks, dan animasi mengikuti `Hebat.dc.html`, dengan teks yang dibuat dinamis:
- `hebatEarned`: "Kamu dapat {count} bintang!"
- `hebatStarsLabel`: "{total} bintang, bertambah {count}"
- Nama stiker diambil dari ARB `stiker_<id>` (nama ID dan EN dari tabel Task 10).
- Album: "{dimiliki} / 30". Bilah kemajuannya `dimiliki / 30`. Enam sel menampilkan stiker terakhir yang dimiliki, dengan sel baru diberi label "BARU"/"NEW".

Perilaku:
1. **Saat dibuka:** narasi `hebatGreat` ("Hebat!" / "Great job!"), lalu `Sfx.sorak`. Bintang muncul satu per satu dengan jeda 0,3 / 0,55 / 0,8 detik, masing-masing berputar −120° → 0 dan membesar 0 → 1 selama 0,6 detik.
2. **Mengetuk Moci:** narasi `hebatYay` ("Yeay, kamu berhasil! Kamu dapat tiga bintang dan stiker baru!"), varian tanpa nama dan tanpa nama stiker (D5).
3. **Kalau `award.sticker == null`** (semua stiker sudah dimiliki): medali stiker tidak ditampilkan, dan album menunjukkan 30 / 30.
4. **Tombol:** "Main lagi" → `context.go(args.replayRoute)`; "Lanjut" → `context.go(Routes.beranda)`.

- [ ] **Step 1: Tulis tes yang gagal**

`hadiah_controller_test.dart`:
- `finishGame('balon', 'r1')` → `stars` bertambah 3, `stickers.length == 1`, dan stiker itu ada di `stickerCatalog`.
- Memanggil lagi dengan `'r1'` → bintang dan stiker tidak bertambah, dan hasilnya sama.
- Dengan 29 stiker sudah dimiliki → stiker baru adalah satu-satunya yang tersisa.
- Dengan 30 stiker sudah dimiliki → `sticker == null` dan `stars` tetap bertambah 3.

`hebat_screen_test.dart`:
- `find.text('Kamu dapat 3 bintang!')` muncul.
- Narasi pertama `ui_hebatGreat`, dan `Sfx.sorak` diputar.
- "Main lagi" → path `/main/balon`; "Lanjut" → path `/`.
- Ketukan ganda cepat di "Lanjut" hanya menghasilkan satu navigasi (Review Focus 1).

`hebat_golden_test.dart` (`@Tags(['golden'])`) membuat `hebat_tablet_id.png` dengan 27 bintang dan stiker baru `apel`, dalam keadaan animasi selesai.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/hadiah --exclude-tags golden`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.**
- [ ] **Step 4: Jalankan tes dan buat golden.** Expected: PASS. Bandingkan dengan `docs/screenshots/27-hadiah.png`.
- [ ] **Step 5: Commit** dengan pesan `feat(hadiah): 3 bintang dan stiker baru per ronde, layar Hebat`.

---

### Task 18: Area Orang Tua dan Hapus semua data

**Files:**
- Create: `lib/features/orang_tua/ringkasan.dart`, `lib/features/orang_tua/orang_tua_screen.dart`, `lib/features/orang_tua/widgets/{profil_card,hari_ini_card,minggu_ini_card,pengaturan_card,option_pills,moci_switch}.dart`, `lib/widgets/moci_dialog.dart`, `lib/app/config.dart`, `test/features/orang_tua/ringkasan_test.dart`, `test/features/orang_tua/orang_tua_screen_test.dart`, `test/features/orang_tua/orang_tua_golden_test.dart`
- Modify: `lib/app/router.dart`, `l10n/app_*.arb` (kunci `orangTua*`), `pubspec.yaml` (`url_launcher`)

**Interfaces:**
- Consumes: `prefsProvider` (semua setter, `resetAll`), `progressProvider` (`harian`, `stickers`, `reset`), `playTimerProvider.secondsToday`, `parentAccessProvider.revoke`, `jsonStoreProvider.deleteAll`, `MociStage(theme: MenuTheme.orangTua, textScaleCap: 1.3)`.
- Produces:
  - `enum RingkasanModul { huruf(26), angka(50), hewan(42), buahSayur(35), membaca(90), mewarnai(14) }`, dengan field `final int total`. Item yang dihitung per modul (D11):

    | Modul | Item | Dicatat oleh |
    | --- | --- | --- |
    | huruf | huruf | Rencana 03 |
    | angka | angka | Rencana 03 |
    | hewan | id hewan | Rencana 04 |
    | buahSayur | id buah atau sayur | Rencana 04 |
    | membaca | suku kata | Rencana 05 |
    | mewarnai | halaman | Rencana 07 |

    Semuanya dicatat lewat `markItem(modul.name, …)`.
  - `final class WeeklyRow { final RingkasanModul modul; final int done; double get ratio => done / modul.total; }`.
  - `List<WeeklyRow> computeWeekly(Map<String, DayStats> harian, DateTime now)`: jumlah item berbeda per modul dalam 7 tanggal terakhir (hari ini dan 6 hari sebelumnya).
  - `RingkasanModul pickSuggestion(List<WeeklyRow> rows)`: rasio terendah. Kalau sama, ambil yang lebih awal di urutan enum.
  - `final class TodaySummary { final int minutesPlayed; final int? limit; final int stars, stickers, karya; int? get minutesLeft; }`.
  - `class MociDialog`, dengan fungsi `static Future<T?> show<T>(BuildContext context, {required Widget child, required List<Widget> actions})`. Tampilannya mengikuti dialog `Karyaku.dc.html:73-100`: overlay `rgba(43,35,80,.55)` dan panel radius 40. Mengetuk di luar panel tidak menutupnya.
  - `abstract final class AppConfig { static const String? privacyPolicyUrl = null; static const String? supportEmail = null; }`. Nilainya diisi di Rencana 10.
  - `class OrangTuaScreen extends ConsumerStatefulWidget`, terpasang di `Routes.orangTua`.

Tata letak dan teks mengikuti `OrangTua.dc.html`.

Bagian layar:
1. **Profil:**
   - Avatar berisi huruf pertama nama, atau `MociIllustration('moci')` kalau nama kosong.
   - Fallback nama: `orangTuaChildFallback` ("Si kecil" / "Your child").
   - Subjudul "Usia {age} tahun · {level}". Level: Pemula / Penjelajah / Pembaca (EN: Starter / Explorer / Reader).
   - Pil usia.
   - Tombol pensil membuka `MociDialog` berisi kolom nama (maks. 20) dan tombol simpan (D11a).
2. **Hari ini:**
   - Cincin waktu bermain memakai `minutesPlayed` dan `limit`. Kalau tanpa batas: "Tanpa batas harian" dan chip "Bebas". Kalau tersisa > 0: chip "Sisa {n} menit" dengan busur `#7048E8`. Kalau habis: chip "Waktu habis" dengan busur `#E8590C`.
   - Ubin +bintang, +stiker, dan +karya dari `harian[hari ini]`.
3. **Minggu ini:**
   - Enam baris dari `computeWeekly`, dengan bilah `done/total`.
   - Saran: `orangTuaTip` dengan placeholder `modul` ("Saran: coba {modul} bersama minggu ini." / "Tip: try {modul} together this week."). Teks ini baru dan perlu ditinjau (D11c).
4. **Pengaturan:**
   - Bahasa: `setLang`, lalu narasi nama bahasa.
   - Cara baca huruf: Bunyi (fonik) atau Nama huruf.
   - Batas: 15/30/45 mnt atau Bebas.
   - Saklar Musik latar, Efek suara, dan Pengingat istirahat. Saklar tidak bersuara.
5. **Baris badge bawah:**
   - Empat badge dari prototipe.
   - Pil "Hapus semua data" di kanan, dengan gaya tombol Hapus tahap pertama di Karyaku (putih, teks `#C92A2A`, bayangan `#F5C2C7`) (D11d).
   - Kalau `AppConfig.privacyPolicyUrl` atau `supportEmail` tidak null, tampilkan tautan yang membuka `url_launcher`. Tautan ini aman karena halaman ini sudah di balik gerbang.
6. **Hapus semua data:**
   1. `MociDialog` muncul.
   2. Tombol "Hapus semua data" berubah menjadi "Yakin hapus?" (`#E8384F`, teks putih).
   3. Ketukan kedua menjalankan `jsonStore.deleteAll()`, `progress.reset()`, `prefs.resetAll()`, dan `parentAccess.revoke()`. Redirect lalu membuka `/sambutan`.
7. **Tombol kembali** ("Kunci dan kembali ke beranda"):
   1. `parentAccess.revoke()`.
   2. `context.go(Routes.beranda)`.

   `dispose` juga memanggil `revoke()`.
8. **Ukuran teks:** teks ikut setelan sistem sampai 1,3× (`textScaleCap: 1.3`).

- [ ] **Step 1: Tulis tes yang gagal**

`ringkasan_test.dart`:
```dart
test('item berbeda 7 hari terakhir per modul', () {
  final h = {
    '2026-11-14': const DayStats(stars: 0, stickers: 0, karya: 0, items: {'huruf': ['A', 'B'], 'hewan': ['kucing']}),
    '2026-11-10': const DayStats(stars: 0, stickers: 0, karya: 0, items: {'huruf': ['B', 'C']}),
    '2026-11-07': const DayStats(stars: 0, stickers: 0, karya: 0, items: {'huruf': ['Z']}), // di luar 7 hari
  };
  final rows = computeWeekly(h, DateTime(2026, 11, 14, 9));
  expect(rows.firstWhere((r) => r.modul == RingkasanModul.huruf).done, 3);
  expect(rows.firstWhere((r) => r.modul == RingkasanModul.hewan).done, 1);
  expect(pickSuggestion(rows), RingkasanModul.angka); // 0/50, sama dengan yang lain, dan paling awal di urutan enum
});
```

`orang_tua_screen_test.dart`:
- Dengan `TestEnv(progress: harian hari ini bintang 9, stiker 1, karya 1)` dan 1080 detik bermain hari ini → tampil "18 menit", "Sisa 12 menit", "+9", "+1", dan "+1".
- Batas Bebas → `prefs.dailyLimitMinutes == null` dan tampil "Tanpa batas harian".
- Saklar Musik dimatikan → `prefs.music == false`.
- Hapus semua data: ketuk pil, lalu ketuk "Hapus semua data" dan "Yakin hapus?" → `env.json` kosong, `prefs.onboarded == false`, dan path `/sambutan`. Ketukan pertama saja tidak menghapus apa pun.
- Tombol kembali → path `/` dan `parentAccessProvider == false`. `router.go('/orang-tua')` setelahnya membuka `/gerbang`.
- Kalau `AppConfig.privacyPolicyUrl == null`, tautan kebijakan privasi tidak tampil.

`orang_tua_golden_test.dart` (`@Tags(['golden'])`) membuat `orang_tua_tablet_id.png`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/orang_tua --exclude-tags golden`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Jalankan `fvm flutter pub add url_launcher`. Manifest Android tidak perlu `<queries>` selama tautan masih null; Rencana 10 menambahkannya bersama URL-nya.
- [ ] **Step 4: Jalankan tes dan buat golden.** Expected: PASS. Bandingkan dengan `docs/screenshots/30-area-orang-tua.png`.
- [ ] **Step 5: Commit** dengan pesan `feat(orang-tua): profil, hari ini, minggu ini, pengaturan, hapus semua data`.

---

### Task 19: Uji integrasi dan pemeriksaan akhir

**Files:**
- Create: `integration_test/app_test.dart`
- Modify: `pubspec.yaml` (dev `integration_test` dari SDK), `lib/main.dart` (`runMoci` menerima overrides untuk tes)

**Interfaces:**
- Consumes: `runMoci({List<Override> overrides})`, `clockProvider`, `playTimerTicksProvider`.

Tiga skenario dari Spesifikasi Teknis. Skenario "satu permainan → Hebat" ditambahkan di rencana yang pertama kali mengirim permainan, yaitu Rencana 06.
1. **Pertama kali:** install bersih → splash → Sambutan (pilih EN, nama "Raka", 4–5) → Beranda menampilkan "Hi, Raka!" → tutup dan buka lagi aplikasi → langsung Beranda tanpa Sambutan.
2. **Gerbang:** dari Beranda ke Orang Tua, jawab salah, jawab benar, Masuk → Area Orang Tua → kembali → buka `/orang-tua` lagi → diarahkan ke gerbang.
3. **Batas waktu:** jam palsu dan tick manual lewat overrides, batas 15 → setelah 900 tick muncul Waktu Habis → orang tua menaikkan batas ke 30 → kembali ke Beranda.

- [ ] **Step 1: Tulis `integration_test/app_test.dart`** dengan ketiga skenario di atas.
- [ ] **Step 2: Jalankan di simulator iPad dan emulator Android.**

```bash
fvm flutter test integration_test -d "iPad (A16)"
fvm flutter test integration_test -d emulator-5554
```
Expected: semua skenario PASS di kedua perangkat. Nama perangkat menyesuaikan `fvm flutter devices`.

- [ ] **Step 3: Pemeriksaan akhir rencana**

```bash
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
fvm flutter build apk --release --target-platform android-arm64
```
Expected: semua lolos. Lalu jalankan `"$ANDROID_HOME"/build-tools/36.0.0/aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk`, yang tidak boleh mencetak izin apa pun.

- [ ] **Step 4: Commit** dengan pesan `test: uji integrasi alur pertama kali, gerbang, dan batas waktu`.
