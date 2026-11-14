# Moci — Rencana 04: Dunia Sekitar — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lima menu dunia sekitar — Dunia Hewan (42 hewan, 5 kelompok, suara asli atau tiruan TTS), Buah & Sayur (Kenali dan Tebak), Warna (11 warna, set 12 kartu), Bentuk (Kenali dan Cari yang berakhir di Hebat), dan Main Musik (xilofon 8 nada, drum 4 bunyi) — plus 12 berkas nada/drum yang dibuat di repo.

**Architecture:**
- Setiap menu punya satu file aturan Dart murni tanpa import Flutter (`hewan_isi.dart`, `buah_game.dart`, `warna_game.dart`, `bentuk_game.dart`, `musik_lagu.dart`) dan satu `*_screen.dart`. Aturan ronde, penyaringan, ukuran teks, dan jadwal nada dites tanpa widget; layar hanya merakit.
- Komponen permainan dari Rencana 03 dipakai apa adanya: `GameModePill`, `AnswerCard`, `ProgressDots`, `GameGlyph`. Tidak ada perubahan di `lib/widgets/game/`.
- Suara hewan memakai `assets/audio/hewan/<id>.m4a` kalau ada; kalau belum, `Narrator` membacakan tiruan bunyi dari katalog lewat TTS. Semua narasi lain memakai baris yang sudah ada (`nama_`, `fakta_`, `warna_`, `bentuk_`, `angka_`) atau kunci ARB bertanda `"description": "narasi"`.
- Main Musik tidak memakai sintesis saat aplikasi berjalan: 12 WAV kecil (8 nada xilofon + 4 drum) dibuat oleh `tool/buat_instrumen.dart`, dicatat `Milik sendiri` di `assets/audio/LICENSES.csv`, lalu diputar lewat `AudioEngine` langsung supaya nada bisa tumpang tindih tanpa menghentikan narasi.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart 3, `flutter_soloud` 5.3 di balik `AudioEngine`, Riverpod 3, `go_router` 18, gen-l10n. Tidak ada paket baru.

**Spec:**
- `docs/PRD.md` (Fitur per menu: Dunia Hewan, Buah & Sayur, Warna, Bentuk, Main Musik; syarat siap rilis), `docs/TECH-SPEC.md` (Struktur proyek, Audio, Dua bahasa), `docs/DESIGN-SYSTEM.md` (latar per menu, ukuran sentuh, animasi), `docs/CONTENT-ASSETS.md` (suara hewan, alat musik, LICENSES.csv), `docs/PRIVACY-RELEASE.md`.
- Prototipe: `docs/design/prototype/Hewan.dc.html`, `Buah.dc.html`, `Warna.dc.html`, `Bentuk.dc.html`, `Musik.dc.html`, `Hebat.dc.html`. Teks UI disalin persis dari objek `T` tiap artboard.
- Peta rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md` (baris 04).

**Bergantung pada Rencana 01, 02, dan 03:**
- 01: `MociStage` tablet 1180 × 820, `MenuTheme.hewan/buahSayur/warna/bentuk/musik`, `MociTopBar`, `MociBackButton`, `MociPressable`, `StarCounter`, `Narrator`, `AudioService`, `Sfx`, `AssetCatalog`, `prefsProvider` (`lang`, `ageLevel`, `sfx`), `progressProvider` (`setLastActivity`, `markItem`), `hadiahProvider.finishGame`, `HebatArgs`, `Routes`, harness tes.
- 02: `Katalog` (`item`, `warna`, `bentuk`), `Item.hewan` (`kelompok`, `bunyi`, `fakta`), `Bilingual`, `WarnaEntry`, `BentukEntry`, `ContentRepository.katalogPath`, `tool/validate_content.dart` beserta aturan lisensi audio dan suara hewan.
- 03: `Narrator` dengan TTS di semua mode build, `NarrationLine`, dan komponen `lib/widgets/game/`: `GameModePill`/`GameModeTab`, `GameGlyph`/`GameGlyphKind`, `AnswerCard`/`AnswerCardState`, `ProgressDots`. `RouteModePill`, `GameInstruction`, dan `MicButton` tersedia tetapi tidak dipakai di rencana ini (lihat W1).

## Global Constraints

- Flutter **3.50.0** lewat FVM. Semua perintah memakai `fvm flutter …` / `fvm dart …`.
- Tidak ada paket pihak ketiga baru. Tidak ada analytics, crash reporting, ikon dari paket luar, atau unduhan saat aplikasi berjalan.
- Material diimpor dari `package:material_ui/material_ui.dart`; file yang hanya butuh lapisan widget memakai `package:flutter/widgets.dart`. File aturan (`*_isi.dart`, `*_game.dart`, `*_lagu.dart`, `instrumen.dart`) tidak mengimpor widget atau Material; tipe data inti (`AppLang`, `AgeLevel`, `Katalog`) dan `dart:ui`/`dart:math` boleh.
- **Narasi:** rekaman belum ada sampai Rencana 09, jadi TTS perangkat dipakai di semua mode build (keputusan Rencana 03 H1). `Narrator` memakai `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a` kalau ada, TTS kalau tidak. Jenis yang dipakai rencana ini: `nama`, `fakta`, `warna`, `bentuk`, `angka`, `bunyi` (tiruan suara hewan, selalu TTS), dan `ui` untuk kunci ARB bertanda `"description": "narasi"`.
- **Suara hewan:** berkas `assets/audio/hewan/<id>.m4a` (42 buah, menyusul di Rencana 09) diputar apa adanya. Selama belum ada, tiruan bunyi dari `Item.hewan.bunyi` dibacakan TTS. Layar tidak pernah menebak path atau memutar berkas yang tidak ada.
- **Alat musik:** 12 WAV mono 16-bit 24 kHz di `assets/audio/instrumen/`, dibuat `tool/buat_instrumen.dart` dan dicatat `Milik sendiri` di `assets/audio/LICENSES.csv`. Tidak ada sampel pihak ketiga, tidak ada sintesis saat aplikasi berjalan.
- **Layout:** setiap layar adalah `MociStage` dengan builder `tablet` 1180 × 820. HP memakai desain tablet yang diperkecil (D12) sampai Rencana 08; tidak ada builder `phone` di rencana ini.
- Target sentuh **64 pt** tablet, jarak **16 pt**, margin tepi **32 pt**. Kontras teks minimal **4,5 : 1**. Tekan: turun **5 pt**, skala **0,97**, **120 ms**. Muncul: **400–550 ms**, kurva `Cubic(0.3, 1.6, 0.5, 1)`. Saat `MediaQuery.disableAnimations` aktif, animasi hiasan berhenti, tetapi umpan balik benar/salah tetap muncul.
- **Dua bahasa setara:** semua teks lewat gen-l10n; bahasa bisa berganti saat layar terbuka tanpa memulai ulang. Teks dari artboard disalin persis; kunci bernama `<layar><KunciT>` (`hewanHearSound`, `buahGuess`, `bentukPrize`, `musikBeat`). Judul lagu tidak diterjemahkan.
- Teks permainan tidak mengikuti ukuran teks sistem (`textScaleCap` 1,0).
- Progres: id modul mengikuti `RingkasanModul` (`hewan` 42, `buahSayur` 35). `markItem` hanya untuk kedua modul itu; Warna, Bentuk, dan Main Musik hanya mencatat `setLastActivity` (modulnya tidak ada di ringkasan Minggu ini).
- **Lanjutkan:** setiap layar menerima `awal` dari query dan mencatat `setLastActivity` saat dibuka dan saat pilihan berganti. Nilai yang tidak dikenal diabaikan. Param yang disimpan: `hewan`, `buah`+`mode`, `warna`, `bentuk`+`mode`, `alat`+`lagu`.
- **Permainan berakhir:** hanya Bentuk Cari yang ditutup `finishGame(gameId: 'bentuk', roundId: '<seed>/6')` lalu `Routes.hebat` dengan `HebatArgs`. Buah Tebak, Warna, dan Main Musik berputar tanpa akhir (PRD: hanya mode Cari di Bentuk dan 6 mini game yang memakai Hebat).
- Efek suara hanya dari enum `Sfx` (`klik`, `benar`, `salahLembut`, `sorak`, `bintang`). Tidak ada buzzer.
- Ikon hanya dari `GameGlyphKind`; tidak ada ikon baru. Panah sebelumnya memakai `next` diputar 180°, bunyi memakai `play`, hitung memakai `count`, ulangi/gambar baru memakai `refresh`, dan bintang memakai `star`.
- `MociPressable` menelan ketukan kedua dalam **400 ms**; tes yang mengetuk widget yang sama dua kali harus memompa ≥ 500 ms di antara ketukan.
- Tidak ada `TODO`, placeholder, teks Inggris hardcoded di widget, atau aset yang dirujuk tanpa berkas.

## Review Focus

1. **Berkas suara hewan belum ada, sebagian, atau gagal dimuat.** "Dengar suara" harus tetap berbunyi (tiruan bunyi katalog lewat TTS), tidak melempar, dan tidak pernah memutar berkas yang tidak ada. Dipatok di Task 2 (`suara tanpa berkas memakai TTS`, `suara dengan berkas memutar m4a`).
2. **Anak mengetuk berulang-ulang.** Kartu warna yang sama tidak menambah hitungan dua kali, soal tidak melompat dua kali, dan "Ambil hadiah" dua kali tetap memberi 3 bintang. Dipatok di Task 3 (`lanjut hanya memajukan satu soal`), Task 4 (`ketukan kedua pada kartu yang sama tidak menambah hitungan`), dan Task 6 (`ambil hadiah dua kali tetap tiga bintang`).
3. **Main Musik tetap berbunyi setelah pindah mode, ganti lagu, atau keluar layar.** Semua `Timer` jadwal nada dan irama harus dibatalkan, dan nada yang sedang hidup dihentikan saat `dispose`. Dipatok di Task 7 (`ganti lagu membatalkan jadwal`, `keluar layar menghentikan nada`).
4. **Level usia Bentuk berubah.** 2–3 tahun: 5 bentuk dan 3 pilihan; 4–5: 8 bentuk dan 4 pilihan; 6–7: 10 bentuk dan 6 pilihan. Jumlah pilihan harus selalu memuat target dan tidak pernah melebihi isi pool. Dipatok di Task 5 (`kisi mengikuti level usia`) dan Task 6 (`pilihan mengikuti level usia`).
5. **Isi panjang atau banyak.** `Komodo Dragon`, `Burung Hantu`, `Lumba-lumba`, `Cock-a-doodle-doo!`, `Persegi panjang`, 42 hewan di rail, 35 kartu buah, dan 11 chip warna. Tidak boleh ada overflow, teks terpotong, atau jumlah pilihan yang melebihi layar. Dipatok di Task 2 (`nama dan bunyi panjang mengecil`), Task 3 (`kartu buah panjang tidak overflow`), dan Task 4 (`sebelas chip warna muat`).

## Keputusan rencana ini

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| W1 | Komponen Rencana 03 dipakai apa adanya: `GameModePill` untuk Kenali/Tebak, Kenali/Cari, Xilofon/Drum; `AnswerCard` untuk tiga pilihan Buah Tebak; `ProgressDots` untuk 6 soal/ronde; `GameGlyph` untuk ikon dengar, centang, putar, dan berikutnya. `GameInstruction`, `RouteModePill`, dan `MicButton` tidak dipakai: pertanyaan Buah dan Bentuk butuh satu baris dengan nama berwarna, dan menu ini tidak punya sub-rute atau mikrofon. | Tidak ada perubahan kontrak Rencana 03; layar hanya memakai bagian yang cocok. |
| W2 | Ilustrasi dipanggil `MociIllustration(item.id)`, bukan dari kolom `gambar`. Invarian `gambar == "illustrations/<id>.svg"` dijaga validator dan satu tes di Task 2. | Semua 42 hewan, 35 buah/sayur, dan 81 benda berwarna memenuhinya; tidak perlu pembantu pemotong path di tiap fitur. |
| W3 | Suara hewan: `assets/audio/hewan/<id>.m4a` kalau ada, selain itu TTS tiruan bunyi katalog. Membuka layar, memilih hewan, dan panah hanya membacakan nama (`nama_<id>`); tiruan bunyi hanya saat "Dengar suara" atau ketukan gambar. | Narasi nama + bunyi berurutan butuh dua mesin audio; nama saja menjaga irama dan tetap "suara dulu". |
| W4 | Pil kelompok hewan tidak dibacakan; memilih kelompok membacakan nama hewan yang tampil. | Menghemat 6 klip narasi dan menjaga isi yang dibacakan tetap nama hewan. |
| W5 | Buah & Sayur: mode bawaan **Tebak** (prototipe), 6 soal berulang tanpa akhir dan tanpa Hebat, kategori (Semua/Buah/Sayur) menyaring Kenali dan memulai ulang Tebak di soal 1. | PRD: hanya Bentuk Cari dan 6 mini game yang berakhir di Hebat. |
| W6 | Warna: setiap set 12 kartu — 4–5 kartu warna target (sampai 4 gambar bertanda warna itu, sisanya bentuk) dan sisanya warna lain + 2 bentuk. "Gambar baru" mengacak ulang warna yang sama; "Warna lain" maju ke warna berikutnya di katalog. | Aturan prototipe; warna dengan sedikit gambar (`hitam` 1, `abu` 3) tetap punya 4 kartu target. |
| W7 | Bentuk Kenali: pool bentuk mengikuti `prefs.ageLevel` (5/8/10), chip sisi/sudut/ujung/lambang/tanpa sudut, "Hitung sudut" menandai satu titik tiap **800 ms** lalu membacakan `angka_<n>` dan `fakta_<bentuk>`. | Fakta katalog sudah menyebut jumlah sisi/sudut, jadi tidak perlu kalimat baru. |
| W8 | Bentuk Cari: 6 ronde, jumlah pilihan 3/4/6 mengikuti level usia, target tidak mengulang bentuk ronde sebelumnya. Ronde ke-6 memberi `finishGame(gameId: 'bentuk', roundId: '<seed>/6')`; `roundId` memakai seed acak per main, sehingga "Ambil hadiah" dua kali tetap satu hadiah. | `finishGame` mengunci per `gameId/roundId`; seed per main membuat main berikutnya tetap dapat hadiah. |
| W9 | Main Musik memakai 12 WAV hasil sintesis offline, bukan sintesis saat berjalan: `flutter_soloud` tidak punya generator derau untuk drum, dan sumber yang dimuat awal menjamin bunyi < 50 ms. Berkas dibuat `tool/buat_instrumen.dart` dan dicatat `Milik sendiri`. | Tech spec: alat musik WAV, latensi < 50 ms; tidak ada aset pihak ketiga di repo publik. |
| W10 | Nada diputar lewat `AudioEngine` langsung (`MusikAudio`), bukan `AudioService.narrate`: nada harus bisa tumpang tindih dan tidak boleh menghentikan narasi. Volume memakai `AudioService.sfxVolume` dan mengikuti sakelar Efek suara. | Prioritas audio: narasi > efek > musik; nada adalah efek. |
| W11 | Main Musik tidak berakhir di Hebat. "Ikuti" selesai menampilkan pil "Hebat! Kamu memainkan satu lagu!" dan narasinya, lalu kembali ke keadaan bebas. | PRD: Main Musik bukan permainan berakhir. |
| W12 | Tidak ada entri `continueLabels` baru. Kartu Lanjutkan memakai judul menu bawaan, tetapi rute beserta param tetap disimpan sehingga item terakhir terbuka lagi. | Label spesifik butuh nama isi yang sudah diterjemahkan, sedangkan `continueLabels` tidak punya akses katalog. |
| W13 | Judul layar memakai kunci `menu*Title` yang sudah ada, bukan kunci baru: EN Dunia Hewan tetap "Animals" (bukan "Animal World" dari artboard). | Kartu Beranda dan bilah atas harus sama di kedua bahasa; artboard EN memakai teks lama. |

## Peta file

```
lib/features/musik/instrumen.dart           # nama 12 berkas, frekuensi nada, pathInstrumen
lib/features/hewan/hewan_isi.dart           # kelompok, filter, path suara, ukuran teks
lib/features/hewan/hewan_screen.dart        # Dunia Hewan
lib/features/buah_sayur/buah_game.dart      # soal Tebak 3 pilihan + kategori
lib/features/buah_sayur/buah_screen.dart    # Kenali dan Tebak
lib/features/warna/warna_game.dart          # set 12 kartu, warna berikutnya
lib/features/warna/warna_screen.dart        # Warna
lib/features/bentuk/bentuk_game.dart        # pool level usia, ronde Cari, chip
lib/features/bentuk/bentuk_shape.dart       # parser path + painter bentuk berwajah
lib/features/bentuk/bentuk_screen.dart      # Kenali, Cari, dan Hebat
lib/features/musik/musik_lagu.dart          # jadwal lagu, ikuti, irama drum
lib/features/musik/musik_audio.dart         # pemutar instrumen lewat AudioEngine
lib/features/musik/musik_screen.dart        # xilofon dan drum
tool/buat_instrumen.dart                    # pembuat 12 WAV (Milik sendiri)
assets/audio/instrumen/*.wav                # 8 nada xilofon + 4 bunyi drum
assets/audio/LICENSES.csv                   # 12 baris Milik sendiri
pubspec.yaml                                # deklarasi assets/audio/
lib/app/router.dart                         # lima rute, bukan ComingSoonScreen
l10n/app_id.arb, l10n/app_en.arb            # teks baru
test/helpers/harness.dart                   # katalogUji() + TestEnv.ageLevel
```

Folder menu mengikuti TECH-SPEC: `hewan/`, `buah_sayur/`, `warna/`, `bentuk/`, `musik/`; fitur tidak saling meng-import.

---

### Task 1: Instrumen musik — 12 nada dan drum

**Files:**
- Create: `tool/buat_instrumen.dart`, `lib/features/musik/instrumen.dart`, `test/features/musik/instrumen_test.dart`, `assets/audio/instrumen/xilo-1.wav` … `xilo-8.wav`, `drum-drum.wav`, `drum-tepuk.wav`, `drum-simbal.wav`, `drum-kerincing.wav`
- Modify: `assets/audio/LICENSES.csv`, `pubspec.yaml`

**Interfaces:**
- Consumes: `dart:io`, `dart:math`, `dart:typed_data`. Tidak ada Flutter.
- Produces:
  - `const nadaXilo = <String>['xilo-1', 'xilo-2', 'xilo-3', 'xilo-4', 'xilo-5', 'xilo-6', 'xilo-7', 'xilo-8'];`
  - `const bunyiDrum = <String>['drum-drum', 'drum-tepuk', 'drum-simbal', 'drum-kerincing'];`
  - `const daftarInstrumen = <String>[...nadaXilo, ...bunyiDrum];`
  - `const frekuensiXilo = <double>[523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77, 1046.5];`
  - `String pathInstrumen(String nama) => 'assets/audio/instrumen/$nama.wav';`
- Bentuk gelombang (prototipe `Musik.dc.html` baris 166–186): xilofon `0.45·sin(2πft)·e^(−t/0,42) + 0,16·sin(2π·3,93ft)·e^(−t/0,06)` dengan attack 6 ms, panjang 1,2 dtk. Drum: kick sinus 165→45 Hz selama 0,35 dtk dengan envelope 0,95·e^(−t/0,12), panjang 0,5 dtk; tepuk = derau band 1500 Hz dengan tiga burst 0/14/28 ms (masing-masing 12 ms) dan ekor 0,3 dtk; simbal = derau high-pass 6500 Hz, envelope 0,55·e^(−t/0,32), panjang 1,4 dtk; kerincing = derau high-pass 4500 Hz, attack 30 ms lalu 0,45·e^(−t/0,05), panjang 0,2 dtk. Semua 24 kHz mono 16-bit, derau dari `Random(20261114)` baru per berkas drum, nilai dijepit ke ±0,98.
- Header WAV: 44 byte, `RIFF`, `WAVE`, `fmt ` 16, PCM 1, kanal 1, sample rate 24000, byte rate 48000, block align 2, bit 16, `data`.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/musik/instrumen_test.dart`:
```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/musik/instrumen.dart';

int _u16(Uint8List b, int i) => b[i] | (b[i + 1] << 8);
int _u32(Uint8List b, int i) =>
    b[i] | (b[i + 1] << 8) | (b[i + 2] << 16) | (b[i + 3] << 24);

const _detik = <String, double>{
  'xilo-1.wav': 1.2, 'xilo-2.wav': 1.2, 'xilo-3.wav': 1.2, 'xilo-4.wav': 1.2,
  'xilo-5.wav': 1.2, 'xilo-6.wav': 1.2, 'xilo-7.wav': 1.2, 'xilo-8.wav': 1.2,
  'drum-drum.wav': 0.5, 'drum-tepuk.wav': 0.3, 'drum-simbal.wav': 1.4,
  'drum-kerincing.wav': 0.2,
};

void main() {
  test('dua belas berkas WAV mono 16-bit 24 kHz dengan panjang tetap', () {
    expect(daftarInstrumen.length, 12);
    for (final nama in daftarInstrumen) {
      final b = File(pathInstrumen(nama)).readAsBytesSync();
      expect(String.fromCharCodes(b.sublist(0, 4)), 'RIFF', reason: nama);
      expect(String.fromCharCodes(b.sublist(8, 12)), 'WAVE', reason: nama);
      expect(_u16(b, 20), 1, reason: nama);
      expect(_u16(b, 22), 1, reason: nama);
      expect(_u32(b, 24), 24000, reason: nama);
      expect(_u32(b, 28), 48000, reason: nama);
      expect(_u16(b, 34), 16, reason: nama);
      expect(b.length, 44 + (_detik['$nama.wav']! * 24000).round() * 2, reason: nama);
    }
  });
  test('setiap berkas tercatat Milik sendiri', () {
    final baris = File('assets/audio/LICENSES.csv').readAsLinesSync().skip(1);
    final lisensi = {
      for (final b in baris)
        if (b.trim().isNotEmpty) b.split(',')[0]: b.split(',')[3],
    };
    for (final nama in daftarInstrumen) {
      expect(lisensi['instrumen/$nama.wav'], 'Milik sendiri', reason: nama);
    }
  });
  test('folder audio dideklarasikan di pubspec', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('- assets/audio/'));
  });
  test('frekuensi nada mengikuti prototipe', () {
    expect(frekuensiXilo, [523.25, 587.33, 659.25, 698.46, 783.99, 880.0, 987.77, 1046.5]);
  });
}
```

`assets/audio/LICENSES.csv` mendapat 12 baris, misalnya:
```csv
instrumen/xilo-1.wav,Milik sendiri (tool/buat_instrumen.dart),,Milik sendiri,2026-11-14,nada do 523.25 Hz
instrumen/drum-simbal.wav,Milik sendiri (tool/buat_instrumen.dart),,Milik sendiri,2026-11-14,derau high-pass 6500 Hz
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/musik/instrumen_test.dart`. Expected: FAIL karena `lib/features/musik/instrumen.dart` belum ada.
- [ ] **Step 3: Implementasikan `instrumen.dart` dan `tool/buat_instrumen.dart`.** Tulis generator sesuai bentuk gelombang di Interfaces; generator mengimpor `package:moci/features/musik/instrumen.dart` untuk nama berkas dan frekuensi, jadi tidak ada daftar kedua. Setiap berkas ditulis lewat `File(path).writeAsBytesSync`. Tambahkan 12 baris lisensi, lalu tambahkan `- assets/audio/` ke daftar `assets:` di `pubspec.yaml`.
- [ ] **Step 4: Jalankan generator dan tes.** Run: `fvm dart run tool/buat_instrumen.dart && fvm flutter test test/features/musik/instrumen_test.dart`. Expected: 12 berkas tertulis, tes PASS.
- [ ] **Step 5: Pastikan generator dapat diulang.** Run:
```bash
shasum -a 256 assets/audio/instrumen/*.wav > /tmp/instrumen-1.sha
fvm dart run tool/buat_instrumen.dart
shasum -a 256 -c /tmp/instrumen-1.sha
```
Expected: setiap baris `OK`, jadi berkas byte-identik setelah dijalankan ulang.
- [ ] **Step 6: Commit** dengan pesan `feat(musik): 12 nada xilofon dan drum hasil sintesis offline`.

---

### Task 2: Layar Dunia Hewan

**Files:**
- Create: `lib/features/hewan/hewan_isi.dart`, `lib/features/hewan/hewan_screen.dart`, `test/features/hewan/hewan_isi_test.dart`, `test/features/hewan/hewan_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/hewan`), `test/app/router_test.dart` (ganti nama tes "ComingSoonScreen mencatat kegiatan terakhir" menjadi "layar hewan mencatat kegiatan terakhir"; asersinya tetap), `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog`, `Item`, `HewanInfo`, `AppLang`, `MociStage`, `MenuTheme.hewan`, `MociTopBar`, `MociBackButton`, `MociPressable`, `MociIllustration`, `StarCounter`, `GameGlyph`, `NarrationLine`, `narratorProvider`, `audioServiceProvider`, `assetCatalogProvider`, `progressProvider`, `prefsProvider`.
- Produces:
  - `enum HewanKelompok { rumah('rumah', 'hewanGroupRumah'), liar('liar', 'hewanGroupLiar'), reptil('reptil', 'hewanGroupReptil'), air('air', 'hewanGroupAir'), kecil('kecil', 'hewanGroupKecil'); const HewanKelompok(this.id, this.labelKey); final String id; final String labelKey; }`
  - `List<Item> hewanTampil(Katalog katalog, {HewanKelompok? kelompok})` — urut seperti katalog; `null` = semua (42).
  - `Item? hewanById(Katalog katalog, String? id)` — `null`/tidak dikenal = item pertama.
  - `String pathSuaraHewan(String id)` → `assets/audio/hewan/<id>.m4a`.
  - `String bunyiHewan(Item item, AppLang lang)`, `String faktaHewan(Item item, AppLang lang)` — `''` kalau `item.hewan` null.
  - `double ukuranNamaHewan(String nama)` — panjang > 11 → 38, > 8 → 44, selain itu 52.
  - `double ukuranBunyiHewan(String bunyi)` — panjang > 13 → 26, > 9 → 32, selain itu 40.
  - `class HewanScreen extends ConsumerStatefulWidget { const HewanScreen({super.key, this.awal}); }` dengan `static const imageKey`, `factKey`, `hearNameKey`, `hearSoundKey`, `prevKey`, `nextKey`, `static ValueKey<String> groupKey(HewanKelompok k)`, `static ValueKey<String> tileKey(String id)`.
- Tata letak `MociStage(MenuTheme.hewan)` (`Hewan.dc.html` baris 59–123): bilah atas (kembali, `menuHewanTitle`, pil `"<n> / <total>"` 60 tinggi, `StarCounter`), pil kelompok 50 tinggi di y 112 (aktif `#2F9E44` bayangan `#1E7A33`, lain putih bayangan `#9FD3A0`), kartu fakta 300 × auto di (44,196) radius 34 (label `hewanDidYou` 17 `#6B5F99`, fakta 23, tombol `commonListen` 50 `#FFF3BF`), gambar hewan 320 di (440,196) di atas elips `#5FC456` 55%, gelembung bunyi di (712,176) (radius 36, teks 40/32/26 `#E8384F`, ekor segitiga), papan nama 400 di (400,520) (`#A9744F`, teks putih 52/44/38, dua kaki `#7A5236`), dua tombol 256 × 80 di (888,268) (`hewanHearName` `#FFB020`, `hewanHearSound` `#26A03B`), panah 70 putih di bawahnya, rail hewan 168 tinggi di y 636 (tile bulat 112, border 6 `#FFB020` terpilih, gambar 84, gulir mendatar).
- Perilaku: `awal` dari `?hewan=<id>`; saat dibuka dan setiap pilihan berganti → `setLastActivity(Routes.hewan, {'hewan': id})`, `markItem('hewan', 'dilihat', id)`, `narrator.sayAll([NarrationLine(jenis: 'nama', id: id, text: nama)], lang)`. "Dengar nama" membacakan baris yang sama. "Dengar suara" dan ketukan gambar: kalau `assets.has(pathSuaraHewan(id))` → `audioService.narrate(path)`; selain itu `narrator.sayAll([NarrationLine(jenis: 'bunyi', id: id, text: bunyi)])`. Ketukan gambar juga memantulkan gelembung 500 ms (`Cubic(0.3, 1.6, 0.5, 1)`). Saat bahasa berganti, nama dan fakta ikut berubah dan nama dibacakan lagi dalam bahasa baru.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `hewanGroups` | Kelompok hewan | Animal groups |
| `hewanGroupAll` | Semua | All |
| `hewanGroupRumah` | Peliharaan & Ternak | Pets & Farm |
| `hewanGroupLiar` | Hutan & Savana | Wild |
| `hewanGroupReptil` | Reptil & Katak | Reptiles & Frogs |
| `hewanGroupAir` | Laut & Air | Sea & Water |
| `hewanGroupKecil` | Burung & Serangga | Birds & Bugs |
| `hewanDidYou` | Tahukah kamu? | Did you know? |
| `hewanHearName` | Dengar nama | Hear name |
| `hewanHearSound` | Dengar suara | Hear sound |
| `hewanPrev` | Hewan sebelumnya | Previous animal |
| `hewanNext` | Hewan berikutnya | Next animal |
| `hewanTapHint` | , ketuk untuk mendengar suaranya | , tap to hear its sound |
| `hewanCounterLabel` | Hewan {nomor} dari {total} | Animal {nomor} of {total} |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/hewan/hewan_isi_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/hewan/hewan_isi.dart';

import '../../helpers/harness.dart';

void main() {
  final katalog = katalogUji();
  test('semua hewan berurutan dan kelompok menyaring', () {
    expect(hewanTampil(katalog).length, 42);
    expect(hewanTampil(katalog).first.id, 'kucing');
    expect(hewanTampil(katalog, kelompok: HewanKelompok.air).map((e) => e.id).toList(),
        ['ikan', 'lumba', 'paus', 'kepiting', 'gurita', 'ubur', 'pinguin']);
    expect(hewanTampil(katalog, kelompok: HewanKelompok.reptil).length, 5);
  });
  test('id tidak dikenal kembali ke hewan pertama', () {
    expect(hewanById(katalog, 'tidak-ada')!.id, 'kucing');
    expect(hewanById(katalog, 'singa')!.id, 'singa');
  });
  test('path suara hewan dari id', () {
    expect(pathSuaraHewan('kucing'), 'assets/audio/hewan/kucing.m4a');
  });
  test('nama dan bunyi panjang mengecil', () {
    expect(ukuranNamaHewan('Kucing'), 52);
    expect(ukuranNamaHewan('Orangutan'), 44);
    expect(ukuranNamaHewan('Komodo Dragon'), 38);
    expect(ukuranBunyiHewan('Meong!'), 40);
    expect(ukuranBunyiHewan('Blub blub!'), 32);
    expect(ukuranBunyiHewan('Cock-a-doodle-doo!'), 26);
  });
  test('gambar setiap item sama dengan id', () {
    for (final item in katalog.item) {
      expect(item.gambar, 'illustrations/${item.id}.svg', reason: item.id);
    }
  });
  test('fakta dan bunyi mengikuti bahasa', () {
    final kucing = hewanById(katalog, 'kucing')!;
    expect(bunyiHewan(kucing, AppLang.id), 'Meong!');
    expect(bunyiHewan(kucing, AppLang.en), 'Meow!');
    expect(faktaHewan(kucing, AppLang.en), contains('Cats'));
  });
}
```
`test/helpers/harness.dart` mendapat `Katalog katalogUji()` (baca `ContentRepository.katalogPath` sekali per proses; `TestEnv` memakai fungsi yang sama).

`test/features/hewan/hewan_screen_test.dart`:
```dart
Future<void> _pump(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 550));
}

testWidgets('membuka: kucing, fakta, 42 hewan, narasi nama', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  expect(find.text('Dunia Hewan'), findsOneWidget);
  expect(find.text('Kucing'), findsOneWidget);
  expect(find.byKey(HewanScreen.factKey), findsOneWidget);
  expect(find.text('1 / 42'), findsOneWidget);
  expect(find.byKey(HewanScreen.tileKey('kucing')), findsOneWidget);
  expect(find.byKey(HewanScreen.tileKey('anjing')), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), ['Kucing']);
});
testWidgets('kelompok air menyaring dan mencatat', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  await t.tap(find.byKey(HewanScreen.groupKey(HewanKelompok.air)));
  await _pump(t);
  expect(find.text('1 / 7'), findsOneWidget);
  expect(find.text('Ikan'), findsOneWidget);
  expect(find.byKey(HewanScreen.tileKey('kucing')), findsNothing);
  expect(_progress(t).perkembangan['hewan']!['dilihat'], ['kucing', 'ikan']);
});
testWidgets('panah berikutnya mengganti nama dan bunyi', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  await t.tap(find.byKey(HewanScreen.nextKey));
  await _pump(t);
  expect(find.text('Anjing'), findsOneWidget);
  expect(find.text('Guk guk!'), findsOneWidget);
  expect(env.tts.spoken.last.$1, 'Anjing');
});
testWidgets('suara tanpa berkas memakai TTS', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  env.tts.spoken.clear();
  await t.tap(find.byKey(HewanScreen.hearSoundKey));
  await t.pump();
  expect(env.tts.spoken.single.$1, 'Meong!');
  expect(env.audio.live, isEmpty);
});
testWidgets('suara dengan berkas memutar m4a', (t) async {
  final env = TestEnv(assets: {'assets/audio/hewan/kucing.m4a'});
  await pumpApp(t, env: env, initialLocation: '/hewan');
  env.tts.spoken.clear();
  await t.tap(find.byKey(HewanScreen.imageKey));
  await t.pump();
  expect(env.audio.live.values, contains('assets/audio/hewan/kucing.m4a'));
  expect(env.tts.spoken, isEmpty);
});
testWidgets('dengar nama dan dengar fakta membacakan baris katalog', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  env.tts.spoken.clear();
  await t.tap(find.byKey(HewanScreen.hearNameKey));
  await t.pump();
  expect(env.tts.spoken.single.$1, 'Kucing');
  await t.pump(const Duration(milliseconds: 500));
  await t.tap(find.text('Dengar'));
  await t.pump();
  expect(env.tts.spoken.last.$1, contains('Kucing suka tidur'));
});
testWidgets('ganti bahasa mengganti nama, bunyi, dan fakta', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/hewan');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await _pump(t);
  expect(find.text('Cat'), findsOneWidget);
  expect(find.text('Meow!'), findsOneWidget);
  expect(find.text('Did you know?'), findsOneWidget);
  expect(env.tts.spoken.last.$2, AppLang.en);
});
testWidgets('lanjutkan membuka hewan terakhir', (t) async {
  await pumpApp(t, initialLocation: '/hewan?hewan=singa');
  expect(find.text('11 / 42'), findsOneWidget);
});
```
`_container` dan `_progress` sama seperti tes layar Rencana 03 (membaca `ProviderScope.containerOf(t.element(find.byType(MociApp)))`).

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/hewan`. Expected: FAIL karena layar dan rute belum ada.
- [ ] **Step 3: Implementasikan.** Ganti `_soon(Routes.hewan, …)` dengan `GoRoute` yang membaca `state.uri.queryParameters['hewan']` sebagai `awal`. Tambah `katalogUji()` di harness. Salin teks dari `Hewan.dc.html` baris 177–181 dan ukuran dari baris 59–123.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/hewan test/l10n`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(hewan): layar Dunia Hewan dengan 5 kelompok, fakta, dan suara asli atau TTS`.

---

### Task 3: Layar Buah & Sayur

**Files:**
- Create: `lib/features/buah_sayur/buah_game.dart`, `lib/features/buah_sayur/buah_screen.dart`, `test/features/buah_sayur/buah_game_test.dart`, `test/features/buah_sayur/buah_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/buah-sayur`), `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog.byKategori`, `Item`, `MociStage`, `MenuTheme.buahSayur`, `GameModePill`, `GameModeTab`, `AnswerCard`, `AnswerCardState`, `ProgressDots`, `GameGlyph`, `MociIllustration`, `Narrator`, `Sfx`, `progressProvider`, `prefsProvider`.
- Produces:
  - `const buahRonde = 6;` `const buahPilihan = 3;`
  - `final class BuahSoal { const BuahSoal({required this.target, required this.pilihan}); final Item target; final List<Item> pilihan; }`
  - `final buahRandomProvider = Provider<Random>((_) => Random());` di `buah_screen.dart` (bukan di file aturan murni), dioverride tes lewat `TestEnv.extraOverrides`.
  - `BuahSoal buatBuahSoal(Katalog katalog, {String? kategori, String? target, String? hindari, required Random random})` — pool = item berkategori `buah`/`sayur`, disaring `kategori` (`'buah'`/`'sayur'`); target = `target` kalau ada dan ada di pool, selain itu acak selain `hindari`; dua pengecoh acak dari pool selain target; hasil diacak.
  - `bool jawabanBuah(Item target, Item dipilih)` → `target.id == dipilih.id`.
  - `String namaBuah(Item item, AppLang lang)`.
  - `double ukuranSoalBuah(String nama)` — panjang > 10 → 36, selain itu 44.
  - `double ukuranKartuBuah(String nama)` — panjang > 11 → 18, selain itu 22.
  - `enum BuahMode { kenali, tebak }` dan `class BuahScreen extends ConsumerStatefulWidget { const BuahScreen({super.key, this.mode = BuahMode.tebak, this.awal}); }` dengan `static ValueKey<int> questionKey(int nomor)`, `static const nextKey`, dan `static ValueKey<String> optionKey(String id)`, `cardKey(String id)`, `categoryKey(String kategori)` (`'semua'`/`'buah'`/`'sayur'`).
- Tata letak `MociStage(MenuTheme.buahSayur)` (`Buah.dc.html` baris 49–149): bilah atas (kembali, `menuBuahTitle`, `GameModePill` Kenali/Tebak aksen `#E64980`, pil kategori 56 tinggi di kanan), Kenali = kisi 6 kolom kartu 196 (gambar 124, nama 18/22, tag 12 `BUAH` `#E64980` / `SAYUR` `#2F9E44`) yang dapat digulir, Tebak = Moci mengintip 168 di (110,118), kotak pertanyaan 660 × 112 di (294,134) (teks 44/36, nama berwarna `#E8384F`, tombol dengar bulat 72 `#FFB020`), pil `ProgressDots` 6 di (976,166), tiga `AnswerCard` 300 × 340 mulai (90,296) jarak 40, bilah selesai 600 × 96 di (290,690) berisi 3 bintang, `buahRight`, dan tombol `buahNext` 66 (`#E64980`).
- Perilaku: `awal` dari `?buah=<id>&mode=kenali|tebak`. Saat dibuka: `setLastActivity(Routes.buahSayur, {'buah': soal.target.id, 'mode': mode.name})`; pertanyaan pertama memakai `target: awal` kalau ada. Kenali: ketuk kartu → `markItem('buahSayur', 'dilihat', id)`, `setLastActivity`, `sayAll([nama_<id>])`. Tebak: soal baru → `sayAll([NarrationLine(jenis: 'ui', id: 'buahQuestionSay', text: …), nama_<target>])`, `setLastActivity` dengan target baru. Salah → `AnswerCardState.wrong` + `Sfx.salahLembut` + `sayAll([nama_<dipilih>, ui buahWrongSay])`, soal tidak maju. Benar → `AnswerCardState.correct` + `Sfx.benar` + `sayAll([ui buahYesSay, nama_<target>])` + `markItem('buahSayur', 'ditebak', id)` + bilah selesai. `buahNext` membuat soal baru (`hindari: target sebelumnya`), nomor soal berputar 1…6, dan memanggil `setLastActivity` dengan target baru.
- Kartu pertanyaan memakai `key: BuahScreen.questionKey(qn)`; `ProgressDots` memakai `buahProgress(qn, 6)` sebagai `semanticLabel`.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `buahLearn` | Kenali | Learn |
| `buahGuess` | Tebak | Guess |
| `buahCats` | Kategori | Category |
| `buahCatAll` | Semua | All |
| `buahCatFruit` | Buah | Fruits |
| `buahCatVeggie` | Sayur | Veggies |
| `buahTagFruit` | BUAH | FRUIT |
| `buahTagVeggie` | SAYUR | VEGGIE |
| `buahListen` | Dengarkan pertanyaan | Listen to the question |
| `buahQuestion` | Mana yang {nama}? | Find the {nama}! |
| `buahQuestionSay` (narasi) | Mana yang | Find the |
| `buahYesSay` (narasi) | Betul! Itu | Yes! |
| `buahWrongSay` (narasi) | Bukan, coba lagi ya! | That's not it. Try again! |
| `buahRight` | Betul! Itu {nama}! | Yes! {nama}! |
| `buahNext` | Lanjut | Next |
| `buahProgress` | Pertanyaan {n} dari {total} | Question {n} of {total} |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/buah_sayur/buah_game_test.dart`:
```dart
void main() {
  final katalog = katalogUji();
  test('katalog memuat 21 buah dan 14 sayur', () {
    expect(katalog.byKategori('buah').length, 21);
    expect(katalog.byKategori('sayur').length, 14);
  });
  test('soal memuat target dan dua pengecoh berbeda', () {
    final soal = buatBuahSoal(katalog, random: Random(3));
    expect(soal.pilihan.length, 3);
    expect(soal.pilihan.map((e) => e.id), contains(soal.target.id));
    expect(soal.pilihan.map((e) => e.id).toSet().length, 3);
    expect(soal.pilihan.every((e) => e.kategori == 'buah' || e.kategori == 'sayur'), isTrue);
  });
  test('kategori menyaring target dan pengecoh', () {
    for (var seed = 0; seed < 20; seed++) {
      final soal = buatBuahSoal(katalog, kategori: 'sayur', random: Random(seed));
      expect(soal.pilihan.every((e) => e.kategori == 'sayur'), isTrue, reason: '$seed');
    }
  });
  test('target dan hindari dihormati', () {
    final soal = buatBuahSoal(katalog, target: 'apel', random: Random(1));
    expect(soal.target.id, 'apel');
    for (var seed = 0; seed < 20; seed++) {
      expect(buatBuahSoal(katalog, hindari: 'pisang', random: Random(seed)).target.id,
          isNot('pisang'));
    }
  });
  test('jawaban hanya benar untuk target', () {
    final soal = buatBuahSoal(katalog, target: 'apel', random: Random(1));
    final salah = soal.pilihan.firstWhere((e) => e.id != 'apel');
    expect(jawabanBuah(soal.target, soal.target), isTrue);
    expect(jawabanBuah(soal.target, salah), isFalse);
  });
  test('ukuran soal mengecil untuk nama panjang', () {
    expect(ukuranSoalBuah('APEL'), 44);
    expect(ukuranSoalBuah('SEMANGKA'), 44);
    expect(ukuranSoalBuah('PERSIK PANJANG'), 36);
    expect(ukuranKartuBuah('Stroberi'), 22);
    expect(ukuranKartuBuah('Strawberry'), 22);
    expect(ukuranKartuBuah('Stroberi Besar'), 18);
  });
}
```
`test/features/buah_sayur/buah_screen_test.dart`:
```dart
testWidgets('membuka: mode Tebak, soal apel, tiga kartu, narasi', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?buah=apel&mode=tebak');
  expect(find.text('Buah & Sayur'), findsOneWidget);
  expect(find.byType(AnswerCard), findsNWidgets(3));
  expect(find.text('Apel'), findsOneWidget);
  expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), ['Mana yang', 'Apel']);
});
testWidgets('jawaban salah tidak memajukan soal', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?buah=apel&mode=tebak');
  final salah = t.widgetList<AnswerCard>(find.byType(AnswerCard))
      .firstWhere((c) => c.text != 'Apel');
  await t.tap(find.byWidget(salah));
  await t.pump();
  expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
  expect(t.widgetList<AnswerCard>(find.byType(AnswerCard)).any((c) => c.state == AnswerCardState.wrong), isTrue);
  expect(find.text('Betul! Itu Apel!'), findsNothing);
  expect(env.tts.spoken.last.$1, 'Bukan, coba lagi ya!');
});
testWidgets('jawaban benar mencatat dan menampilkan bilah', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?buah=apel&mode=tebak');
  await t.tap(find.byKey(BuahScreen.optionKey('apel')));
  await t.pump();
  expect(find.text('Betul! Itu Apel!'), findsOneWidget);
  expect(_progress(t).perkembangan['buahSayur']!['ditebak'], ['apel']);
});
testWidgets('lanjut hanya memajukan satu soal', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?buah=apel&mode=tebak');
  await t.tap(find.byKey(BuahScreen.optionKey('apel')));
  await t.pump(const Duration(milliseconds: 500));
  await t.tap(find.byKey(BuahScreen.nextKey));
  await t.pump();
  expect(find.byKey(BuahScreen.questionKey(2)), findsOneWidget);
  expect(find.text('Betul! Itu Apel!'), findsNothing);
  await t.pump(const Duration(milliseconds: 500));
  expect(find.byKey(BuahScreen.nextKey), findsNothing);
  await t.pump(const Duration(milliseconds: 500));
  expect(find.byKey(BuahScreen.questionKey(2)), findsOneWidget);
});
testWidgets('kenali: 35 kartu, tag, dan catatan dilihat', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?mode=kenali');
  expect(find.byType(AnswerCard), findsNothing);
  expect(find.byKey(BuahScreen.cardKey('apel')), findsOneWidget);
  expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
  expect(find.text('BUAH'), findsWidgets);
  expect(find.text('SAYUR'), findsWidgets);
  await t.tap(find.byKey(BuahScreen.cardKey('apel')));
  await t.pump();
  expect(_progress(t).perkembangan['buahSayur']!['dilihat'], ['apel']);
  expect(env.tts.spoken.last.$1, 'Apel');
});
testWidgets('kategori sayur menyaring kenali dan memulai tebak', (t) async {
  await pumpApp(t, initialLocation: '/buah-sayur?mode=kenali');
  await t.tap(find.byKey(BuahScreen.categoryKey('sayur')));
  await t.pump();
  expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
  expect(find.byKey(BuahScreen.cardKey('apel')), findsNothing);
  await t.tap(find.text('Tebak'));
  await t.pump();
  expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
  final sayur = {
    for (final item in katalogUji().item)
      if (item.kategori == 'sayur') item.nama.of(AppLang.id),
  };
  expect(
    find.byWidgetPredicate((w) => w is AnswerCard && sayur.contains(w.text)),
    findsNWidgets(3),
  );
});
testWidgets('ganti bahasa mengganti pertanyaan dan tag', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/buah-sayur?buah=apel&mode=tebak');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Apple'), findsOneWidget);
  expect(find.text('APPLE', findRichText: true), findsOneWidget);
  expect(find.text('Fruits & Veggies'), findsOneWidget);
  await t.tap(find.text('Learn'));
  await t.pump();
  expect(find.text('FRUIT'), findsWidgets);
});
testWidgets('kartu buah panjang tidak overflow', (t) async {
  await pumpApp(t, initialLocation: '/buah-sayur?mode=kenali');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump(const Duration(milliseconds: 100));
  await t.tap(find.byKey(BuahScreen.categoryKey('sayur')));
  await t.pump();
  expect(t.takeException(), isNull);
  expect(find.byKey(BuahScreen.cardKey('paprika')), findsOneWidget);
});
testWidgets('lanjutkan membuka buah dan mode terakhir', (t) async {
  await pumpApp(t, initialLocation: '/buah-sayur?buah=wortel&mode=kenali');
  expect(find.text('Wortel'), findsOneWidget);
  expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
});
```
Helper `katalogUji()` dan `_progress` sama seperti tes Rencana 03; `_container` membaca `ProviderScope.containerOf(t.element(find.byType(MociApp)))`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/buah_sayur`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Ganti `_soon(Routes.buahSayur, …)` dengan `GoRoute` yang membaca `buah` dan `mode`; mode tidak dikenal → `tebak`. Salin teks dari `Buah.dc.html` baris 199–203 dan tata letak dari baris 49–149. `AnswerCard` dipakai dengan `key: BuahScreen.optionKey(item.id)`, `illustration: item.id`, `text: nama`, `semanticLabel: nama`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/buah_sayur test/l10n`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(buah-sayur): layar Kenali dan Tebak dengan tiga pilihan dan 35 kartu`.

---

### Task 4: Layar Warna

**Files:**
- Create: `lib/features/warna/warna_game.dart`, `lib/features/warna/warna_screen.dart`, `test/features/warna/warna_game_test.dart`, `test/features/warna/warna_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/warna`), `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog.item` (81 item berwarna), `Katalog.warna`, `WarnaEntry`, `Item`, `MociStage`, `MenuTheme.warna`, `MociPressable`, `MociIllustration`, `GameGlyph`, `Narrator`, `Sfx`, `prefsProvider`.
- Produces:
  - `enum WarnaBentuk { balon, bintang, hati }`
  - `final class WarnaKartu { const WarnaKartu({required this.id, this.gambarId, this.bentuk, required this.warna}); final String id; final String? gambarId; final WarnaBentuk? bentuk; final String warna; }`
  - `final class WarnaSet { const WarnaSet({required this.warna, required this.kartu}); final String warna; final List<WarnaKartu> kartu; int get total; }`
  - `final warnaRandomProvider = Provider<Random>((_) => Random());` di `warna_screen.dart`, dioverride tes lewat `TestEnv.extraOverrides`.
  - `WarnaSet buatWarnaSet(Katalog katalog, String warna, Random random)` — aturan W6: sampai 4 gambar bertanda warna itu, `nT = 4 + random.nextInt(2)`, kekurangan target diisi bentuk `WarnaBentuk.values[j % 3]`; kartu lain = `12 − nT − 2` gambar warna lain + 2 bentuk berwarna lain (dua warna berbeda); semua diacak. Id bentuk `'<bentuk>-<warna>'`.
  - `String warnaBerikut(Katalog katalog, String warna)` — id warna berikutnya, berputar ke awal.
  - `String namaKartu(WarnaKartu kartu, Katalog katalog, AppLang lang)` — nama item untuk kartu gambar, `''` untuk bentuk (layar menyusun `warnaBalon` + nama warna).
  - `class WarnaScreen extends ConsumerStatefulWidget { const WarnaScreen({super.key, this.awal}); }` dengan `static const newSetKey`, `nextColorKey`, `static ValueKey<String> chipKey(String warna)`, `kartuKey(String id)`.
- Tata letak `MociStage(MenuTheme.warna)` (`Warna.dc.html` baris 39–114): latar `#F3EEFF` berpola titik; bilah atas (kembali, `menuWarnaTitle`, tombol `warnaNewSet` 64, `StarCounter`); kartu kiri 330 × 660 di (40,120) radius 40 bayangan `#D0BFFF` berisi swatch 180 di (75,18), nama warna kapital 48/38, tombol `commonListen` 220 × 60 `#FFB020`, label `warnaPick` 17, 11 chip bulat 54 dalam kisi 4 kolom (48 × 54); kartu kanan 740 × 660 di (400,120) berisi baris instruksi 30 pt dengan chip warna, pil `found / total` 54, kisi 4 kolom 12 kartu 152 (gambar 120 atau bentuk 92–112, border 6 `#26A03B` kalau ketemu), dan bilah selesai 600 × 72 `#2B2350` di bawah dengan `warnaDone` + tombol `warnaNextColor`.
- Perilaku: `awal` dari `?warna=<id>` (tidak dikenal → `merah`). Saat dibuka: `setLastActivity(Routes.warna, {'warna': warna})`, `sayAll([ui warnaSentuh, warna_<id>])`. Teks pil hitungan adalah `'$ditemukan / ${set.total}'` (angka, sama di dua bahasa) dan label semantiknya `warnaCounterLabel`. Ketuk chip → set baru untuk warna itu + narasi instruksi + `setLastActivity`. "Gambar baru" → set baru warna yang sama, hitungan nol. Ketuk kartu target yang belum ketemu → `Sfx.benar`, tambahkan id, `sayAll([ui warnaBetul, nama_<id>])` untuk kartu gambar atau `sayAll([ui warnaBetul])` untuk bentuk; bila semua ketemu → `Sfx.sorak` + `sayAll([ui warnaSemuaKetemu])` + bilah selesai. Ketuk kartu warna lain → border `#FF8787` + goyang 450 ms + `Sfx.salahLembut` + `sayAll([ui warnaBukan, warna_<id>])`. Kartu yang sudah ketemu mengabaikan ketukan. Tidak ada `markItem`.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `warnaPick` | Pilih warna | Pick a color |
| `warnaNewSet` | Gambar baru | New pictures |
| `warnaNextColor` | Warna lain | Next color |
| `warnaInstructionPre` | Sentuh semua yang | Tap everything |
| `warnaDone` | Semua yang {warna} ketemu! | You found all the {warna} things! |
| `warnaCounterLabel` | {found} dari {total} ketemu | {found} of {total} found |
| `warnaChipLabel` | Warna {nama} | Color {nama} |
| `warnaSentuh` (narasi) | Sentuh semua yang berwarna | Touch everything that is |
| `warnaBetul` (narasi) | Betul! | Yes! |
| `warnaBukan` (narasi) | Bukan yang ini. Cari yang | Not this one. Find |
| `warnaSemuaKetemu` (narasi) | Semua gambarnya sudah ketemu! | You found them all! |
| `warnaBalon` | balon | balloon |
| `warnaBintang` | bintang | star |
| `warnaHati` | hati | heart |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/warna/warna_game_test.dart`:
```dart
void main() {
  final katalog = katalogUji();
  test('katalog memuat 11 warna dan 81 item bertanda warna', () {
    expect(katalog.warna.length, 11);
    expect(katalog.item.where((i) => i.warna != null).length, 81);
  });
  test('set 12 kartu dengan 4–5 target', () {
    for (final warna in katalog.warna) {
      final set = buatWarnaSet(katalog, warna.id, Random(7));
      expect(set.kartu.length, 12, reason: warna.id);
      expect(set.kartu.map((k) => k.id).toSet().length, 12, reason: warna.id);
      expect(set.total, inInclusiveRange(4, 5), reason: warna.id);
      expect(set.kartu.where((k) => k.warna == warna.id).length, set.total);
      for (final kartu in set.kartu.where((k) => k.warna != warna.id)) {
        expect(kartu.warna, isNot(warna.id));
      }
    }
  });
  test('warna dengan sedikit gambar tetap punya empat target', () {
    final set = buatWarnaSet(katalog, 'hitam', Random(1));
    expect(set.total, inInclusiveRange(4, 5));
    expect(set.kartu.where((k) => k.bentuk != null && k.warna == 'hitam'), isNotEmpty);
  });
  test('kartu gambar memakai id item yang warnanya cocok', () {
    final set = buatWarnaSet(katalog, 'merah', Random(9));
    for (final kartu in set.kartu.where((k) => k.gambarId != null)) {
      expect(katalog.byId(kartu.gambarId!)!.warna, kartu.warna);
    }
  });
  test('nama kartu mengikuti bahasa', () {
    final set = buatWarnaSet(katalog, 'merah', Random(9));
    final kartuGambar = set.kartu.firstWhere((k) => k.gambarId != null);
    final item = katalog.byId(kartuGambar.gambarId!)!;
    expect(namaKartu(kartuGambar, katalog, AppLang.id), item.nama.id);
    expect(namaKartu(kartuGambar, katalog, AppLang.en), item.nama.en);
    const bentuk = WarnaKartu(id: 'balon-merah', bentuk: WarnaBentuk.balon, warna: 'merah');
    expect(namaKartu(bentuk, katalog, AppLang.id), '');
  });
  test('warna berikutnya berputar', () {
    expect(warnaBerikut(katalog, 'merah'), 'oranye');
    expect(warnaBerikut(katalog, 'abu'), 'merah');
  });
}
```
`test/features/warna/warna_screen_test.dart`:
```dart
WarnaSet _setMerah() => buatWarnaSet(katalogUji(), 'merah', Random(7));

testWidgets('membuka: instruksi, hitungan, 11 chip, 12 kartu', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  await pumpApp(t, env: env, initialLocation: '/warna');
  expect(find.text('Warna'), findsOneWidget);
  expect(find.text('MERAH'), findsWidgets);
  expect(find.text('0 / ${_setMerah().total}'), findsOneWidget);
  expect(find.byKey(WarnaScreen.chipKey('merah')), findsOneWidget);
  expect(find.byKey(WarnaScreen.chipKey('abu')), findsOneWidget);
  expect(find.byKey(WarnaScreen.kartuKey(_setMerah().kartu.first.id)), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), ['Sentuh semua yang berwarna', 'merah']);
});
testWidgets('kartu target menambah hitungan dan mengabaikan ketukan kedua', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  final set = _setMerah();
  final target = set.kartu.firstWhere((k) => k.warna == 'merah');
  await pumpApp(t, env: env, initialLocation: '/warna');
  await t.tap(find.byKey(WarnaScreen.kartuKey(target.id)));
  await t.pump();
  expect(find.text('1 / ${set.total}'), findsOneWidget);
  await t.pump(const Duration(milliseconds: 500));
  await t.tap(find.byKey(WarnaScreen.kartuKey(target.id)));
  await t.pump();
  expect(find.text('1 / ${set.total}'), findsOneWidget);
});
testWidgets('kartu warna lain tidak menambah hitungan', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  final set = _setMerah();
  final lain = set.kartu.firstWhere((k) => k.warna != 'merah');
  await pumpApp(t, env: env, initialLocation: '/warna');
  await t.tap(find.byKey(WarnaScreen.kartuKey(lain.id)));
  await t.pump();
  expect(find.text('0 / ${set.total}'), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), containsAllInOrder(['Bukan yang ini. Cari yang', 'merah']));
});
testWidgets('semua target ketemu menampilkan bilah dan warna lain', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  final set = _setMerah();
  await pumpApp(t, env: env, initialLocation: '/warna');
  for (final kartu in set.kartu.where((k) => k.warna == 'merah')) {
    await t.tap(find.byKey(WarnaScreen.kartuKey(kartu.id)));
    await t.pump();
  }
  expect(find.text('Semua yang merah ketemu!'), findsOneWidget);
  expect(find.byKey(WarnaScreen.nextColorKey), findsOneWidget);
  await t.tap(find.byKey(WarnaScreen.nextColorKey));
  await t.pump();
  expect(find.text('ORANYE'), findsWidgets);
  expect(find.textContaining('0 / '), findsOneWidget);
});
testWidgets('gambar baru mengosongkan hitungan tanpa ganti warna', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  await pumpApp(t, env: env, initialLocation: '/warna');
  await t.tap(find.byKey(WarnaScreen.newSetKey));
  await t.pump();
  expect(find.text('MERAH'), findsWidgets);
  expect(find.textContaining('0 / '), findsOneWidget);
});
testWidgets('sebelas chip warna muat', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  await pumpApp(t, env: env, initialLocation: '/warna');
  expect(t.takeException(), isNull);
  for (final warna in katalogUji().warna) {
    expect(find.byKey(WarnaScreen.chipKey(warna.id)), findsOneWidget, reason: warna.id);
  }
});
testWidgets('ganti bahasa mengganti nama warna dan chip', (t) async {
  final env = TestEnv(extraOverrides: [warnaRandomProvider.overrideWithValue(Random(7))]);
  await pumpApp(t, env: env, initialLocation: '/warna');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('RED'), findsWidgets);
  expect(find.text('Pick a color'), findsOneWidget);
  expect(find.byKey(WarnaScreen.chipKey('merah')), findsOneWidget);
});
```
`_container` sama seperti tes Rencana 03.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/warna`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Ganti `_soon(Routes.warna, …)` dengan `GoRoute` yang membaca `warna`. Salin teks dari `Warna.dc.html` baris 201–203 dan tata letak dari baris 39–114. Kartu bentuk digambar langsung (balon 100 × 130, bintang 100 × 100, hati 100 × 100) dengan `warna`/`garis` dari `WarnaEntry`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/warna test/l10n`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(warna): layar Warna dengan set 12 kartu dan 11 chip`.

---

### Task 5: Layar Bentuk — Kenali

**Files:**
- Create: `lib/features/bentuk/bentuk_game.dart`, `lib/features/bentuk/bentuk_shape.dart`, `lib/features/bentuk/bentuk_screen.dart`, `test/features/bentuk/bentuk_game_test.dart`, `test/features/bentuk/bentuk_shape_test.dart`, `test/features/bentuk/bentuk_kenali_test.dart`
- Modify: `lib/app/router.dart` (rute `/bentuk`, mode Kenali), `l10n/app_id.arb`, `l10n/app_en.arb`, `test/helpers/harness.dart` (`ageLevel`)

**Interfaces:**
- Consumes: `Katalog.bentuk` (10), `BentukEntry`, `AgeLevel`, `MociStage`, `MenuTheme.bentuk`, `GameModePill`, `GameGlyph`, `Narrator`, `progressProvider`, `prefsProvider`.
- Produces:
  - `const bentukRonde = 6;`
  - `List<int> bentukPool(AgeLevel level)` — `pemula` `[0, 1, 2, 6, 7]`, `penjelajah` `[0…7]`, `pembaca` `[0…9]`; angkanya indeks ke `katalog.bentuk`.
  - `int bentukPilihan(AgeLevel level)` — 3 / 4 / 6.
  - `final class BentukChip { const BentukChip({required this.key, this.jumlah}); final String key; final int? jumlah; }`
  - `List<BentukChip> chipBentuk(BentukEntry bentuk)` — `poly` → `bentukSisi` + `bentukSudut`; `star` → `bentukUjung` (jumlah `sudut`); `love` → `bentukSayang`; lainnya → `bentukTanpaSudut`.
  - Layar memetakan `BentukChip.key` ke `l10n.bentukSisi(jumlah!)`, `bentukSudut`, `bentukUjung`, `bentukSayang`, `bentukTanpaSudut`; tidak ada pembantu ARB di file aturan murni.
  - `enum BentukMode { kenali, cari }` dan `class BentukScreen extends ConsumerStatefulWidget { const BentukScreen({super.key, this.mode = BentukMode.kenali, this.awal}); }` dengan `static const hearKey`, `countKey`, `questionKey`, `static ValueKey<int> markKey(int i)`, `static ValueKey<String> shapeKey(String id)`, `checkKey(String id)` untuk lencana benar. Soal Cari dirender sebagai `Text` biasa ber-kunci `questionKey`.
  - `class BentukShape extends StatelessWidget { const BentukShape({super.key, required this.bentuk, required this.size, this.shadow = false}); }` — menggambar `bentuk.path` di kotak 200 × 200 (diskalakan ke `size`) dengan bayangan `gelap` bergeser 9 unit, garis 14, lalu wajah: mata elips ±17/−6 7 × 9, kilau putih di (−14,5;−9,5) dan (19,5;−9,5) r 2,6, pipi putih 50% di ±28/8 7 × 4,5, senyum `M−9 8 Q0 17 9 8` tebal 4,5, semuanya di `translate(wajahX wajahY) scale(wajahSkala)`.
  - `Path pathDariSvg(String d)` — perintah absolut `M L H V C A Z`; `A` memakai `Path.arcToPoint` dengan `Radius.elliptical(rx, ry)`, `rotation`, `largeArc`, `clockwise: sweep == 1`.
  - `final bentukRandomProvider = Provider<Random>((_) => Random());` di `bentuk_screen.dart` (dipakai Task 6), dioverride tes lewat `TestEnv.extraOverrides`.
- Tata letak Kenali (`Bentuk.dc.html` baris 58–108): latar `#EEF1FF` berpola titik; bilah atas (kembali, `menuBentukTitle`, `GameModePill` Kenali/Cari aksen `#5C7CFA`); kartu kiri 640 × 668 di (40,122) radius 48 berisi bentuk 330 di (155,26) dengan tanda sudut 48 px bernomor 1…n menurut `sudutTitik × 330/200`, nama 58 warna `gelap`, fakta 22 `#5B5480`, chip 40 `#EEF1FF` 17, tombol `commonListen` 64 `#5C7CFA` dan `Hitung sudut`/`Hitung ujung` 64 putih; kisi kanan 2 kolom 118 tinggi di (720,122) berisi `bentukPool(ageLevel)` kartu (ikon 70, nama 19/22, aktif border `gelap`).
- Perilaku: `awal` dari `?bentuk=<id>`, bawaan bentuk pertama pool. Saat dibuka: `setLastActivity(Routes.bentuk, {'bentuk': id, 'mode': mode.name})` + `sayAll([bentuk_<id>])`. Ketuk bentuk besar/kartu kisi → ganti bentuk, `setLastActivity`, `sayAll([bentuk_<id>])`, animasi pop 450 ms. Tombol dengar → `sayAll([bentuk_<id>, fakta_<id>])`. Tombol hitung (`bentukCountCorners` untuk `poly`, `bentukCountTips` untuk `star`) hanya muncul kalau `sudutTitik` tidak kosong: `Timer.periodic(800 ms)` menambah tanda satu per satu dan membacakan `angka_<k>`; setelah tanda terakhir, `sayAll([fakta_<id>])` dan timer berhenti. Timer dibatalkan saat bentuk berganti atau layar ditutup.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `bentukLearn` | Kenali | Learn |
| `bentukFind` | Cari | Find |
| `bentukCountCorners` | Hitung sudut | Count the corners |
| `bentukCountTips` | Hitung ujung | Count the points |
| `bentukSisi` | {n} sisi | {n} sides |
| `bentukSudut` | {n} sudut | {n} corners |
| `bentukUjung` | {n} ujung | {n} points |
| `bentukSayang` | Lambang sayang | A symbol of love |
| `bentukTanpaSudut` | Tidak punya sudut | No corners |
| `bentukShapeLabel` | Bentuk {nama} | Shape {nama} |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/bentuk/bentuk_game_test.dart`:
```dart
void main() {
  final katalog = katalogUji();
  test('katalog memuat sepuluh bentuk', () {
    expect(katalog.bentuk.length, 10);
  });
  test('pool dan jumlah pilihan per level usia', () {
    expect(bentukPool(AgeLevel.pemula), [0, 1, 2, 6, 7]);
    expect(bentukPool(AgeLevel.penjelajah), [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(bentukPool(AgeLevel.pembaca), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    expect(bentukPilihan(AgeLevel.pemula), 3);
    expect(bentukPilihan(AgeLevel.penjelajah), 4);
    expect(bentukPilihan(AgeLevel.pembaca), 6);
  });
  test('chip mengikuti jenis bentuk', () {
    BentukEntry cari(String id) => katalog.bentuk.firstWhere((b) => b.id == id);
    expect(chipBentuk(cari('persegi')).map((c) => (c.key, c.jumlah)),
        [('bentukSisi', 4), ('bentukSudut', 4)]);
    expect(chipBentuk(cari('bintang')).single.jumlah, 5);
    expect(chipBentuk(cari('bintang')).single.key, 'bentukUjung');
    expect(chipBentuk(cari('hati')).single.key, 'bentukSayang');
    expect(chipBentuk(cari('lingkaran')).single.key, 'bentukTanpaSudut');
  });
}
```
`test/features/bentuk/bentuk_shape_test.dart`:
```dart
test('semua path katalog terbaca dan berada di kotak 200', () {
  for (final bentuk in katalogUji().bentuk) {
    final path = pathDariSvg(bentuk.path);
    final bounds = path.getBounds();
    expect(bounds.width, greaterThan(20), reason: bentuk.id);
    expect(bounds.height, greaterThan(20), reason: bentuk.id);
    expect(bounds.left, greaterThanOrEqualTo(-0.5), reason: bentuk.id);
    expect(bounds.right, lessThanOrEqualTo(200.5), reason: bentuk.id);
    expect(path.computeMetrics().isEmpty, isFalse, reason: bentuk.id);
  }
  final lingkaran = pathDariSvg('M18 100A82 82 0 1 1 182 100A82 82 0 1 1 18 100Z');
  expect(lingkaran.getBounds().width, closeTo(164, 1));
});
```
`test/features/bentuk/bentuk_kenali_test.dart`:
```dart
testWidgets('membuka: lingkaran, 5 kartu untuk pemula, narasi nama', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/bentuk');
  expect(find.text('Bentuk'), findsOneWidget);
  expect(find.text('Lingkaran'), findsWidgets);
  expect(find.text('Tidak punya sudut'), findsOneWidget);
  expect(find.byKey(BentukScreen.shapeKey('hati')), findsOneWidget);
  expect(find.byKey(BentukScreen.shapeKey('segilima')), findsNothing);
  expect(find.byKey(BentukScreen.countKey), findsNothing);
  expect(env.tts.spoken.map((e) => e.$1), ['Lingkaran']);
});
testWidgets('kisi mengikuti level usia', (t) async {
  await pumpApp(t, env: TestEnv(ageLevel: AgeLevel.penjelajah), initialLocation: '/bentuk');
  expect(find.byKey(BentukScreen.shapeKey('segilima')), findsNothing);
  expect(find.byKey(BentukScreen.shapeKey('belahketupat')), findsOneWidget);
  await pumpApp(t, env: TestEnv(ageLevel: AgeLevel.pembaca), initialLocation: '/bentuk');
  expect(find.byKey(BentukScreen.shapeKey('segilima')), findsOneWidget);
  expect(find.byKey(BentukScreen.shapeKey('segienam')), findsOneWidget);
});
testWidgets('hitung sudut menandai satu per satu lalu membacakan fakta', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/bentuk?bentuk=persegi');
  await t.tap(find.byKey(BentukScreen.countKey));
  await t.pump(const Duration(milliseconds: 800));
  expect(find.byKey(BentukScreen.markKey(0)), findsOneWidget);
  expect(find.byKey(BentukScreen.markKey(1)), findsNothing);
  await t.pump(const Duration(milliseconds: 2400));
  expect(find.byKey(BentukScreen.markKey(3)), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), containsAllInOrder(['satu', 'dua', 'tiga', 'empat']));
  expect(env.tts.spoken.last.$1, contains('Persegi punya 4 sisi'));
});
testWidgets('bintang memakai hitung ujung', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/bentuk?bentuk=bintang');
  expect(find.text('5 ujung'), findsOneWidget);
  expect(find.text('Hitung ujung'), findsOneWidget);
  env.tts.spoken.clear();
  await t.tap(find.byKey(BentukScreen.hearKey));
  await t.pump();
  expect(env.tts.spoken.map((e) => e.$1), ['Bintang', 'Bintang punya 5 ujung yang lancip.']);
});
testWidgets('ganti bahasa mengganti nama dan chip', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/bentuk?bentuk=persegi');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Square'), findsWidgets);
  expect(find.text('4 sides'), findsOneWidget);
  expect(find.text('4 corners'), findsOneWidget);
});
testWidgets('lanjutkan membuka bentuk terakhir', (t) async {
  await pumpApp(t, initialLocation: '/bentuk?bentuk=segitiga');
  expect(find.text('Segitiga'), findsWidgets);
  expect(find.text('3 sisi'), findsOneWidget);
});
```
`TestEnv` mendapat `AgeLevel ageLevel = AgeLevel.pemula` yang menulis `moci.usia` (`'2-3'`/`'4-5'`/`'6-7'`).

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/bentuk`. Expected: FAIL.
- [ ] **Step 3: Implementasikan `bentuk_game.dart`, `bentuk_shape.dart`, layar mode Kenali.** Ganti `_soon(Routes.bentuk, …)` dengan `GoRoute` yang membaca `bentuk` dan `mode`; mode `cari` baru dipakai Task 6, jadi untuk sekarang nilai itu jatuh ke Kenali. Tambah `ageLevel` ke `TestEnv`. Teks dari `Bentuk.dc.html` baris 245–247, tata letak baris 58–108.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/bentuk test/l10n`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(bentuk): layar Kenali dengan kisi level usia, chip, dan hitung sudut`.

---

### Task 6: Layar Bentuk — Cari dan Hebat

**Files:**
- Modify: `lib/features/bentuk/bentuk_game.dart`, `lib/features/bentuk/bentuk_screen.dart`, `lib/app/router.dart` (mode `cari`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/bentuk/bentuk_cari_test.dart`, `test/features/bentuk/bentuk_game_test.dart` (tambah)

**Interfaces:**
- Consumes: `BentukMode`, `bentukPool`, `bentukPilihan`, `BentukShape`, `AnswerCard`? (tidak; bentuk digambar langsung), `ProgressDots`, `GameGlyph`, `hadiahProvider.finishGame`, `HebatArgs`, `Routes.hebat`, `Sfx`.
- Produces:
  - `final class BentukRonde { const BentukRonde({required this.target, required this.opsi, required this.warna}); final int target; final List<int> opsi; final List<({String warna, String gelap})> warna; }` — `target` dan `opsi` adalah indeks ke `katalog.bentuk`.
  - `BentukRonde buatBentukRonde(Katalog katalog, {required AgeLevel level, required Random random, int? hindari})` — pool = `bentukPool(level)`; target acak selain `hindari`; `bentukPilihan(level) − 1` pengecoh acak; opsi diacak; warna tiap opsi diambil dari pasangan `(warna, gelap)` 10 bentuk yang diacak.
  - `String pertanyaanBentuk(BentukEntry target, AppLang lang)` → nama huruf kecil (`Mana persegi?` / `Where is the square?`).
  - `BentukScreen` dengan tambahan `static const questionKey`, `listenKey`, `againKey`, `prizeKey`, `static ValueKey<String> optionKey(String bentukId)`, `static ValueKey<String> checkKey(String bentukId)`.
- Tata letak Cari (`Bentuk.dc.html` baris 110–149): bilah pertanyaan 1100 × 92 di (40,120) radius 30 berisi tombol dengar bulat 64 `#5C7CFA`, teks soal 40, dan `ProgressDots` 6; papan putih 1100 × 548 di (40,236) radius 44; opsi 3/4/6 pada slot prototipe — 3: pusat x 200/550/900, y 274, ukuran 220; 4: x 150/417/683/950, y 274, ukuran 196; 6: x 183/550/917, y 137/411, ukuran 168 — masing-masing digeser acak ±15 dan digambar `BentukShape` dengan warna opsi; opsi benar menampilkan lencana centang 56; selesai → lapisan putih 94% dengan Moci 200, `bentukDone` 44, tombol `bentukAgain` dan `bentukPrize`.
- Perilaku: `?mode=cari` membuka Cari; `?bentuk=<id>` menjadi target ronde pertama (tidak dikenal → acak). Saat mode Cari dimulai: `_level = ref.read(prefsProvider).ageLevel`, `_seed = random.nextInt(1 << 31)`, ronde pertama dari `buatBentukRonde(katalog, level: _level, random: random, hindari: null)`, narasi `sayAll([ui bentukQuestionSay, bentuk_<target>])`, `setLastActivity(Routes.bentuk, {'bentuk': target, 'mode': 'cari'})`. Salah → opsi merah + goyang + `Sfx.salahLembut` + `sayAll([ui bentukNoSay, bentuk_<dipilih>, ui bentukTryAgain])`, skor tetap. Benar → lencana + `Sfx.benar` + `sayAll([ui bentukYesSay, bentuk_<target>])`, skor +1; setelah 1200 ms ronde berikutnya (`buatBentukRonde(katalog, level: _level, random: random, hindari: target sebelumnya)`) dengan skor yang sama. Ronde ke-6 benar → lapisan selesai + `finishGame(gameId: 'bentuk', roundId: '$_seed/6')` + `sayAll([ui bentukDone])` + `Sfx.sorak`. `bentukPrize` menunggu hadiah (tombol nonaktif selama menunggu, `_menunggu` bool) lalu `context.push(Routes.hebat, extra: HebatArgs(award: award, replayRoute: Routes.bentuk))`. `bentukAgain` memulai seed baru, skor 0, ronde pertama. Timer 1200 ms dibatalkan saat mode berganti, main lagi, atau layar ditutup.
- Mode Cari tidak membacakan nama bentuk saat dibuka (hanya soal); `ProgressDots` memakai `bentukProgress(skor, 6)` sebagai `semanticLabel`. Ronde pertama memakai `?bentuk=` kalau ada, selain itu acak.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `bentukQuestion` | Mana {nama}? | Where is the {nama}? |
| `bentukQuestionSay` (narasi) | Mana | Where is the |
| `bentukYesSay` (narasi) | Betul! Itu | Yes! That is the |
| `bentukNoSay` (narasi) | Bukan, itu | No, that is the |
| `bentukTryAgain` (narasi) | Coba lagi! | Try again! |
| `bentukDone` (narasi) | Hebat! Semua bentuk ketemu! | Great job! You found them all! |
| `bentukAgain` | Main lagi | Play again |
| `bentukPrize` | Ambil hadiah | Get a prize |
| `bentukProgress` | Kemajuan {n} dari {total} | Progress {n} of {total} |
| `bentukListen` | Dengarkan pertanyaan | Listen to the question |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/bentuk/bentuk_game_test.dart` (tambahan):
```dart
test('ronde memuat target dan pilihan sesuai level', () {
  for (final level in AgeLevel.values) {
    final ronde = buatBentukRonde(katalog, level: level, random: Random(5));
    expect(ronde.opsi.length, bentukPilihan(level), reason: level.name);
    expect(ronde.opsi.toSet().length, ronde.opsi.length);
    expect(ronde.opsi, contains(ronde.target));
    expect(ronde.warna.length, ronde.opsi.length);
    expect(ronde.warna.map((w) => w.warna).toSet().length, ronde.opsi.length);
    expect(ronde.opsi.every(bentukPool(level).contains), isTrue);
  }
});
test('target sebelumnya tidak dipilih lagi', () {
  for (var seed = 0; seed < 50; seed++) {
    final ronde = buatBentukRonde(katalog, level: AgeLevel.pemula, random: Random(seed), hindari: 2);
    expect(ronde.target, isNot(2), reason: '$seed');
  }
});
test('pertanyaan memakai nama huruf kecil', () {
  final persegi = katalog.bentuk[1];
  expect(pertanyaanBentuk(persegi, AppLang.id), 'Mana persegi?');
  expect(pertanyaanBentuk(persegi, AppLang.en), 'Where is the square?');
});
```
`test/features/bentuk/bentuk_cari_test.dart`:
```dart
String _targetDariSoal(WidgetTester t) {
  final soal = t.widget<Text>(find.byKey(BentukScreen.questionKey)).data!;
  final inti = soal.replaceFirst('Mana ', '').replaceFirst('Where is the ', '');
  final nama = inti.substring(0, inti.length - 1);
  return nama[0].toUpperCase() + nama.substring(1);
}

Future<void> _jawabBenar(WidgetTester t) async {
  final nama = _targetDariSoal(t);
  final bentuk = katalogUji().bentuk.firstWhere((b) => b.nama.id == nama || b.nama.en == nama);
  await t.tap(find.byKey(BentukScreen.optionKey(bentuk.id)));
  await t.pump(const Duration(milliseconds: 1300));
}

testWidgets('membuka cari: soal, 3 opsi pemula, narasi', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/bentuk?mode=cari&bentuk=persegi');
  expect(find.text('Mana persegi?'), findsOneWidget);
  expect(find.byType(BentukShape), findsNWidgets(3));
  expect(env.tts.spoken.map((e) => e.$1), ['Mana', 'Persegi']);
});
testWidgets('salah tidak menambah kemajuan', (t) async {
  await pumpApp(t, initialLocation: '/bentuk?mode=cari&bentuk=persegi');
  final salah = katalogUji().bentuk
      .where((b) => b.id != 'persegi')
      .firstWhere((b) => find.byKey(BentukScreen.optionKey(b.id)).evaluate().isNotEmpty);
  await t.tap(find.byKey(BentukScreen.optionKey(salah.id)));
  await t.pump(const Duration(milliseconds: 1300));
  expect(find.text('Mana persegi?'), findsOneWidget);
  expect(find.byKey(BentukScreen.checkKey('persegi')), findsNothing);
});
testWidgets('enam ronde selesai: hadiah tiga bintang dan layar Hebat', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/bentuk?mode=cari');
  for (var i = 0; i < 6; i++) {
    await _jawabBenar(t);
  }
  expect(find.text('Hebat! Semua bentuk ketemu!'), findsOneWidget);
  await t.tap(find.byKey(BentukScreen.prizeKey));
  await t.pump();
  await t.runAsync(() => Future<void>.delayed(Duration.zero));
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/hebat');
  expect(_progress(t).stars, 3);
  expect(find.text('Kamu dapat 3 bintang!'), findsOneWidget);
});
testWidgets('ambil hadiah dua kali tetap tiga bintang', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/bentuk?mode=cari');
  for (var i = 0; i < 6; i++) {
    await _jawabBenar(t);
  }
  await t.tap(find.byKey(BentukScreen.prizeKey));
  await t.pump(const Duration(milliseconds: 500));
  await t.tap(find.byKey(BentukScreen.prizeKey), warnIfMissed: false);
  await t.pump();
  await t.runAsync(() => Future<void>.delayed(Duration.zero));
  await t.pump();
  expect(_progress(t).stars, 3);
  final hebat = router.routerDelegate.currentConfiguration.matches
      .where((m) => m.matchedLocation == '/hebat')
      .length;
  expect(hebat, 1);
});
testWidgets('main lagi mengosongkan kemajuan', (t) async {
  await pumpApp(t, initialLocation: '/bentuk?mode=cari');
  for (var i = 0; i < 6; i++) {
    await _jawabBenar(t);
  }
  await t.tap(find.byKey(BentukScreen.againKey));
  await t.pump();
  expect(find.text('Hebat! Semua bentuk ketemu!'), findsNothing);
  expect(find.byKey(BentukScreen.questionKey), findsOneWidget);
});
testWidgets('pilihan mengikuti level usia', (t) async {
  await pumpApp(t, env: TestEnv(ageLevel: AgeLevel.pembaca), initialLocation: '/bentuk?mode=cari');
  expect(find.byType(BentukShape), findsNWidgets(6));
});
```
`_progress` dan `_container` sama seperti tes sebelumnya.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/bentuk`. Expected: FAIL.
- [ ] **Step 3: Implementasikan mode Cari.** Tambah ronde ke `bentuk_game.dart`; sambungkan `?mode=cari`; pasang `Timer` 1200 ms yang dibatalkan di `dispose`; panggil `finishGame` dan dorong Hebat. Teks dari `Bentuk.dc.html` baris 245–247, tata letak baris 110–149.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/bentuk test/features/hadiah`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(bentuk): mode Cari enam ronde dengan hadiah dan layar Hebat`.

---

### Task 7: Layar Main Musik

**Files:**
- Create: `lib/features/musik/musik_lagu.dart`, `lib/features/musik/musik_audio.dart`, `lib/features/musik/musik_screen.dart`, `test/features/musik/musik_lagu_test.dart`, `test/features/musik/musik_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/musik`), `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `AudioEngine`, `audioEngineProvider`, `AudioService.sfxVolume`, `prefsProvider.sfx`, `MociStage`, `MenuTheme.musik`, `GameModePill`, `GameGlyph`, `Narrator`, `Sfx`, `progressProvider`.
- Produces:
  - `const mulaiLagu = Duration(milliseconds: 250);` `const ketukLagu = Duration(milliseconds: 420);` `const langkahIrama = Duration(milliseconds: 150);`
  - `final class Lagu { const Lagu({required this.id, required this.nama, required this.nada, required this.ketuk}); final String id; final String nama; final List<int> nada; final List<int> ketuk; }`
  - `const laguTwinkle = Lagu(id: 'twinkle', nama: 'Twinkle Twinkle', nada: [0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0, 4, 4, 3, 3, 2, 2, 1, 4, 4, 3, 3, 2, 2, 1, 0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0], ketuk: [1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2]);`
  - `const laguMary = Lagu(id: 'mary', nama: 'Mary Had a Little Lamb', nada: [2, 1, 0, 1, 2, 2, 2, 1, 1, 1, 2, 4, 4, 2, 1, 0, 1, 2, 2, 2, 2, 1, 1, 2, 1, 0], ketuk: [1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 4]);`
  - `const daftarLagu = <Lagu>[laguTwinkle, laguMary];`
  - `List<({int ms, int nada})> jadwalLagu(Lagu lagu)` — mulai `250`, langkah `420 × ketuk[i]`.
  - `final class IkutiLagu { IkutiLagu(this.lagu); int get posisi; int get berikut; bool get selesai; bool cocok(int nada); void ulang(); }` — `berikut` = −1 saat selesai; `cocok` hanya benar untuk nada berikutnya dan menambah posisi.
  - `final class KetukanIrama { const KetukanIrama(this.ms, this.nama); final int ms; final String nama; }`
  - `List<KetukanIrama> iramaDrum()` — dua putaran 16 langkah × 150 ms dengan offset 100 ms; langkah 0/6/8 `drum-drum`, 4/12 `drum-tepuk`, putaran kedua langkah 14 `drum-simbal`, langkah genap `drum-kerincing`, urutan dalam satu langkah drum → tepuk → simbal → kerincing.
  - `final musikAudioProvider = Provider<MusikAudio>((ref) { … });`
  - `final class MusikAudio { MusikAudio({required this.engine}); final AudioEngine engine; bool aktif; Future<void> preload(); Future<void> bunyikan(String nama); Future<void> berhenti(); void dispose(); }` — `preload` memuat 12 `pathInstrumen`; `bunyikan` memutar `pathInstrumen(nama)` dengan `AudioService.sfxVolume` kalau `aktif && engine.isReady`; setelah `await engine.play` selesai, id yang datang terlambat langsung dihentikan kalau `_disposed` atau generasi sudah berubah (guard `_disposed` di `berhenti`/`dispose`). Semua id yang hidup dihentikan `berhenti`/`dispose`.
  - `enum MusikMode { xilofon, drum }` dan `class MusikScreen extends ConsumerStatefulWidget { const MusikScreen({super.key, this.awal, this.awalLagu}); }` dengan `static const listenKey`, `followKey`, `beatKey`, `static ValueKey<int> barKey(int nada)`, `static ValueKey<String> padKey(String nama)`, `static ValueKey<String> songKey(String id)`.
- Tata letak (`Musik.dc.html` baris 36–112): bilah atas (kembali, `menuMusikTitle`, `GameModePill` Xilofon/Drum aksen `#F06595`); Xilofon = bilah lagu 1100 × 88 di (40,118) berisi label `musikSongLabel` 17, dua pil lagu 54, tombol `musikListen`/`musikStop` 58 `#F06595`, tombol `musikFollow` 58 (putih; hijau `#26A03B` saat mengikuti); papan 1100 × 562 di (40,230) dengan dua rel `#C8875A` di y 136 dan 398, delapan batang 100 lebar di x 66 + 124·i, tinggi 470 − 24·i, y (562 − tinggi)/2 − 6, warna `#FF6B6B/#FF922B/#FFD43B/#51CF66/#20C997/#339AF0/#5C7CFA/#9775FA` dengan bayangan lebih gelap, nada `do re mi fa sol la si do`, panah penanda nada berikutnya di atas batang, pil selesai 520 × 70 `#2B2350`. Drum = empat pad 240 × 300 di (50,150) jarak 40 (`musikPadDrum` `#FF6B6B`, `musikPadClap` `#FFB020`, `musikPadCymbal` `#339AF0`, `musikPadShaker` `#51CF66`), tombol `musikBeat` 72 `#2B2350` di y 530, teks `musikDrumHint` 21.
- Perilaku: `awal` dari `?alat=xilofon|drum` (tidak dikenal → xilofon), `awalLagu` dari `?lagu=twinkle|mary` (tidak dikenal → `twinkle`). Saat dibuka dan setiap mode/lagu berganti → `setLastActivity(Routes.musik, {'alat': mode.name, 'lagu': lagu.id})`. Ketuk batang → `musikAudio.bunyikan('xilo-${i + 1}')` + animasi tekan. `musikListen` menjadwalkan `jadwalLagu` dengan `Timer`; label berubah `musikStop`; ketukan lagi membatalkan semua timer. `musikFollow` menyalakan `IkutiLagu`; label `musikFollowingCount`; batang berikutnya menambah posisi; batang salah tetap berbunyi tanpa menambah; selesai → pil `musikSongDone` 3500 ms + `sayAll([ui musikSongDone])` + `Sfx.sorak`, mode ikuti mati. Ganti lagu/mode membatalkan timer dan menghentikan nada. Drum: ketuk pad → `bunyikan(nama)` + pop; `musikBeat` menjadwalkan `iramaDrum` (timer), label `musikStop`, ketukan lagi membatalkan; selesai 32 langkah + 500 ms berhenti sendiri. `dispose` membatalkan timer dan `musikAudio.berhenti()`.
- Label mengikuti menampilkan posisi 1-based: `musikFollowingCount(posisi + 1, lagu.nada.length)`.
- ARB baru (ID / EN):

| Kunci | ID | EN |
| --- | --- | --- |
| `musikXylophone` | Xilofon | Xylophone |
| `musikDrum` | Drum | Drums |
| `musikModes` | Alat musik | Instrument |
| `musikSongLabel` | LAGU | SONG |
| `musikSongsLabel` | Pilih lagu | Pick a song |
| `musikStop` | Berhenti | Stop |
| `musikFollow` | Ikuti | Play along |
| `musikFollowingCount` | Mengikuti · {posisi} / {total} | Playing along · {posisi} / {total} |
| `musikSongDone` (narasi) | Hebat! Kamu memainkan satu lagu! | Wonderful! You played the whole song! |
| `musikBeat` | Mainkan irama | Play a rhythm |
| `musikDrumHint` | Ketuk drumnya! Atau mainkan irama, lalu ikut menepuk bersama Moci. | Tap the drums! Or play a rhythm, then clap along with Moci. |
| `musikNote` | Nada {sol} {nomor} | Note {sol} {nomor} |
| `musikPadDrum` | Drum | Drum |
| `musikPadClap` | Tepuk | Clap |
| `musikPadCymbal` | Simbal | Cymbal |
| `musikPadShaker` | Kerincing | Shaker |
| `musikTwinkle` | Twinkle Twinkle | Twinkle Twinkle |
| `musikMary` | Mary Had a Little Lamb | Mary Had a Little Lamb |

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/musik/musik_lagu_test.dart`:
```dart
void main() {
  test('jadwal lagu mulai 250 ms dan memakai panjang ketuk', () {
    final jadwal = jadwalLagu(laguTwinkle);
    expect(jadwal.length, laguTwinkle.nada.length);
    expect(jadwal.first, (ms: 250, nada: 0));
    expect(jadwal[1].ms, 670);
    expect(jadwal[6].ms, 250 + 420 * 6); // nada ke-7 berdurasi 2 ketuk
    expect(jadwal.last.ms, greaterThan(15000));
  });
  test('ikuti hanya menerima nada berikutnya', () {
    final ikuti = IkutiLagu(laguMary);
    expect(ikuti.berikut, 2);
    expect(ikuti.cocok(0), isFalse);
    expect(ikuti.posisi, 0);
    expect(ikuti.cocok(2), isTrue);
    expect(ikuti.posisi, 1);
    expect(ikuti.berikut, 1);
    for (var i = 1; i < laguMary.nada.length; i++) {
      expect(ikuti.cocok(laguMary.nada[i]), isTrue);
    }
    expect(ikuti.selesai, isTrue);
    expect(ikuti.berikut, -1);
    ikuti.ulang();
    expect(ikuti.posisi, 0);
  });
  test('irama drum 32 langkah 150 ms dengan instrumen prototipe', () {
    final irama = iramaDrum();
    expect(irama.length, 27);
    expect(irama.first.ms, 100);
    expect(irama.first.nama, 'drum-drum');
    expect(irama.where((k) => k.ms == 100).map((k) => k.nama),
        ['drum-drum', 'drum-kerincing']);
    expect(irama.any((k) => k.ms == 4600 && k.nama == 'drum-simbal'), isTrue);
    expect(irama.last.ms, 4600);
  });
}
```
`test/features/musik/musik_screen_test.dart`:
```dart
testWidgets('membuka: 8 batang, preload 12 instrumen', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  expect(find.text('Main Musik'), findsOneWidget);
  expect(find.byKey(MusikScreen.barKey(0)), findsOneWidget);
  expect(find.byKey(MusikScreen.barKey(7)), findsOneWidget);
  expect(env.audio.preloaded.where((p) => p.startsWith('assets/audio/instrumen/')).length, 12);
});
testWidgets('ketuk batang memutar nada yang benar', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  await t.tap(find.byKey(MusikScreen.barKey(3)));
  await t.pump();
  expect(env.audio.plays.last.asset, 'assets/audio/instrumen/xilo-4.wav');
  expect(env.audio.plays.last.volume, AudioService.sfxVolume);
});
testWidgets('sakelar efek suara mematikan nada', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  _container(t).read(prefsProvider.notifier).setSfx(false);
  await t.pump();
  await t.tap(find.byKey(MusikScreen.barKey(0)));
  await t.pump();
  expect(env.audio.plays, isEmpty);
});
testWidgets('dengar memainkan seluruh lagu lalu berhenti', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  await t.tap(find.byKey(MusikScreen.listenKey));
  await t.pump(const Duration(milliseconds: 300));
  expect(env.audio.plays.map((p) => p.asset).first, 'assets/audio/instrumen/xilo-1.wav');
  expect(find.text('Berhenti'), findsOneWidget);
  await t.pump(const Duration(milliseconds: 250));
  await t.tap(find.byKey(MusikScreen.listenKey));
  await t.pump(const Duration(milliseconds: 2000));
  final jumlah = env.audio.plays.length;
  await t.pump(const Duration(milliseconds: 2000));
  expect(env.audio.plays.length, jumlah);
});
testWidgets('ganti lagu membatalkan jadwal', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  await t.tap(find.byKey(MusikScreen.listenKey));
  await t.pump(const Duration(milliseconds: 300));
  await t.tap(find.byKey(MusikScreen.songKey('mary')));
  await t.pump();
  final jumlah = env.audio.plays.length;
  await t.pump(const Duration(seconds: 3));
  expect(env.audio.plays.length, jumlah);
});
testWidgets('ikuti menyelesaikan lagu dan memuji', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  await t.tap(find.byKey(MusikScreen.followKey));
  await t.pump();
  for (final nada in laguTwinkle.nada) {
    await t.tap(find.byKey(MusikScreen.barKey(nada)));
    await t.pump(const Duration(milliseconds: 450));
  }
  expect(find.text('Hebat! Kamu memainkan satu lagu!'), findsOneWidget);
  expect(env.tts.spoken.last.$1, 'Hebat! Kamu memainkan satu lagu!');
});
testWidgets('drum: empat pad dan irama berhenti sendiri', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik?alat=drum');
  expect(find.byKey(MusikScreen.padKey('drum-drum')), findsOneWidget);
  expect(find.byKey(MusikScreen.padKey('drum-kerincing')), findsOneWidget);
  await t.tap(find.byKey(MusikScreen.padKey('drum-tepuk')));
  await t.pump();
  expect(env.audio.plays.last.asset, 'assets/audio/instrumen/drum-tepuk.wav');
  await t.tap(find.byKey(MusikScreen.beatKey));
  await t.pump(const Duration(milliseconds: 400));
  expect(env.audio.plays.length, greaterThan(1));
  await t.pump(const Duration(milliseconds: 250));
  await t.tap(find.byKey(MusikScreen.beatKey));
  await t.pump(const Duration(milliseconds: 500));
  expect(find.text('Mainkan irama'), findsOneWidget);
});
testWidgets('keluar layar menghentikan nada', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/musik');
  await t.tap(find.byKey(MusikScreen.listenKey));
  await t.pump(const Duration(milliseconds: 300));
  router.go('/');
  await t.pump();
  await t.runAsync(() => Future<void>.delayed(Duration.zero));
  await t.pump();
  expect(env.audio.live.values.where((a) => a.startsWith('assets/audio/instrumen/')), isEmpty);
});
testWidgets('ganti bahasa mengganti label alat musik', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/musik');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Xylophone'), findsOneWidget);
  expect(find.text('Play along'), findsOneWidget);
});
```
- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/musik`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Tambah `musik_lagu.dart`, `musik_audio.dart`, layar; ganti `_soon(Routes.musik, …)` dengan `GoRoute` yang membaca `alat` dan `lagu`. Timer disimpan dalam satu `List<Timer>` dan dibatalkan lewat satu pembantu `_batal()`. Teks dari `Musik.dc.html` baris 248–250, tata letak dari baris 36–112.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/musik test/l10n`. Expected: PASS.
- [ ] **Step 5: Cek latensi di perangkat.** Run: `fvm flutter run --profile -d "iPad (A16)"`, buka Main Musik, rekam video gerak lambat saat mengetuk batang dan pad. Expected: bunyi terdengar < 50 ms setelah ketukan (kira-kira satu frame pada 60 fps), tanpa tersendat saat beberapa nada dimainkan berurutan.
- [ ] **Step 6: Commit** dengan pesan `feat(musik): layar xilofon delapan nada dan drum empat bunyi`.

---

### Task 8: Dokumentasi, uji integrasi, dan pemeriksaan akhir

**Files:**
- Modify: `ARCHITECTURE.md`, `DESIGN.md`, `SYSTEM_DESIGN.md`, `integration_test/app_test.dart`
- Test: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: semua task sebelumnya (`HewanScreen`, `BuahScreen`, `WarnaScreen`, `BentukScreen`, `MusikScreen`, `MusikAudio`, `finishGame('bentuk', …)`).
- Produces: dokumentasi yang cocok dengan kode, dan satu skenario integrasi perangkat "Bentuk Cari → Hebat".

Dokumentasi yang harus berubah:
- `ARCHITECTURE.md`: baris peta folder untuk `lib/features/{hewan,buah_sayur,warna,bentuk,musik}`, `assets/audio/instrumen/`, `tool/buat_instrumen.dart`; provider `warnaRandomProvider`, `buahRandomProvider`, `bentukRandomProvider`, `musikAudioProvider`; rute `/hewan`, `/buah-sayur`, `/warna`, `/bentuk`, `/musik` tidak lagi `ComingSoonScreen`; harness menyebut `TestEnv.ageLevel`; bagian audio menyebut 12 WAV `Milik sendiri` dan aturan suara hewan.
- `DESIGN.md`: tabel tata letak lima menu (pil kelompok hewan, kisi 6 kolom buah, set 12 kartu warna, papan bentuk dengan tanda sudut, batang xilofon dan pad drum), aturan level usia Bentuk, dan aturan "hanya Bentuk Cari memakai Hebat".
- `SYSTEM_DESIGN.md`: §Audio (alat musik dari WAV sintesis sendiri, volume mengikuti efek suara, latensi < 50 ms), §Data (progres `hewan`/`buahSayur`), §Menu (Bentuk Cari sebagai permainan berakhir).
- `integration_test/app_test.dart`: skenario "bentuk: cari enam ronde lalu Hebat" — buka Beranda, ketuk kartu Bentuk, pilih mode Cari, jawab 6 ronde dengan membaca teks soal dan mengetuk opsi yang cocok, ketuk "Ambil hadiah", lalu pastikan rute `/hebat` dan bintang bertambah 3. Tidak memakai `pumpAndSettle`; penantian lewat `_pumpUntil` dan jeda terbatas.

- [ ] **Step 1: Tulis uji integrasi.** Tambah `testWidgets('bentuk: cari enam ronde lalu Hebat', …)` dengan langkah di atas, memakai `_prepareDevice`, `_Launch`, dan `_pumpUntil` yang sudah ada. Baca soal lewat `find.byKey(BentukScreen.questionKey)` (teks `Text`), hitung nama target, lalu `_tap(t, find.byKey(BentukScreen.optionKey(id)))`; setelah tiap jawaban tunggu `t.pump(const Duration(milliseconds: 1400))` (timer ronde 1200 ms), jangan menunggu kunci soal yang sama karena soal lama masih tampil selama jeda. Setelah ronde keenam tunggu `_pumpUntil(t, find.byKey(BentukScreen.prizeKey))`.
- [ ] **Step 2: Jalankan di perangkat.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS. Ini tes pertama yang menempuh `finishGame` + Hebat dari sebuah layar, jadi kegagalan di sini adalah bug integrasi: perbaiki layarnya, bukan tesnya.
- [ ] **Step 3: Perbarui dokumentasi** sesuai daftar di atas. Jangan menyalin isi spec; tulis hanya yang berubah di kode, dan jangan menyebut path yang belum ada (`test/docs/dokumen_test.dart` memeriksa setiap path di backtick).
- [ ] **Step 4: Jalankan uji integrasi lagi.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS.
- [ ] **Step 5: Pemeriksaan akhir.** Run:
```bash
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
fvm dart run tool/validate_content.dart
```
Expected: format dan analyze bersih; semua tes PASS; validator keluar dengan kode 0 dan hanya peringatan yang sudah ada (`narasi_lengkap`, `suara_hewan_lengkap` untuk rekaman dan suara hewan yang menyusul di Rencana 09).
- [ ] **Step 6: Commit** dengan pesan `docs(dunia-sekitar): peta folder, alat musik, dan uji Bentuk Cari ke Hebat`.
