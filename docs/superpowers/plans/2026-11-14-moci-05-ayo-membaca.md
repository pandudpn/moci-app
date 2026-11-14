# Moci — Rencana 05: Ayo Membaca — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tiga layar membaca yang benar-benar dimainkan anak — Suku Kata (18 konsonan × 5 vokal dengan contoh kata dua bahasa), Susun Kata (71 kata ID dan 33 kata EN, level 2 dan 3 suku kata, lima kata per ronde lalu Hebat), dan Kalimat (18 kalimat dengan sorotan karaoke dan mode tebak gambar).

**Architecture:**
- Setiap layar punya satu berkas aturan Dart murni dan satu berkas layar, mengikuti TECH-SPEC: `*_game.dart`/`*_timing.dart` tanpa import Flutter, lalu `*_screen.dart` yang hanya menyusun widget. Aturan ronde, pemenggalan kata, dan waktu karaoke bisa dites tanpa perangkat.
- Layar memakai komponen bersama Rencana 01 dan 03: `MociStage`, `MociTopBar`, `MociBackButton`, `MociPressable`, `MociIllustration`, `MociMascot`, `RouteModePill`, `AnswerCard`, `ProgressDots`, `GameGlyph`. Komponen baru hanya yang memang khusus membaca: bilah atas tiga mode, pil level, dan keping suku kata.
- Hanya Susun Kata yang berakhir: lima kata per level lalu `/hebat` lewat `finishGame`. Suku Kata dan Kalimat adalah jelajah bebas, sesuai PRD yang menyebut Hebat hanya untuk permainan berakhir.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart 3, Riverpod 3, `go_router` 18, gen-l10n, `flutter_soloud` lewat `AudioService` yang sudah ada, `Ticker` untuk karaoke. Tidak ada paket baru.

**Spec:**
- `docs/PRD.md` (Fitur per menu: Suku Kata, Susun Kata, Kalimat; syarat Hebat), `docs/TECH-SPEC.md` (struktur proyek, audio, aksesibilitas), `docs/DESIGN-SYSTEM.md`, `docs/CONTENT-ASSETS.md` (bagian `sukuKata`, `kata`, `kalimat`).
- Prototipe: `docs/design/prototype/SukuKata.dc.html`, `Kata.dc.html`, `Kalimat.dc.html`, dan `Hebat.dc.html`. Teks UI disalin persis dari objek `T` tiap artboard.
- Peta rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md` (baris 05) dan keputusan K7 di Rencana 02 (waktu kalimat `null` memakai rumus `420 + 75 × panjang kata` ms).

**Bergantung pada Rencana 01, 02, dan 03:**
- 01: `MociStage` dan D12, `MenuTheme.membaca`, `MociTopBar`, `MociBackButton`, `MociPressable`, `MociButton`, `MociMascot`, `MociIllustration`, `MociText`, `MociColors`, `Narrator`, `AudioService`, `Sfx`, `prefsProvider` (`lang`), `progressProvider` (`setLastActivity`, `markItem`), `hadiahProvider.finishGame`, `HebatArgs`, `clockProvider`, `Routes`, `continueLabels`, harness tes (`pumpApp`, `TestEnv`, `FakeDeviceTts`).
- 02: `Katalog` (`sukuKata`, `kata`, `kalimat`, `item`), `SukuKataInfo`, `KataEntry`, `KalimatEntry`, `Bilingual`, `katalogProvider`, `tools/validate_content.dart`, dan narasi `suku_`, `kata_`, `kalimat_`, `nama_`, `ui_` di `lib/core/content/narasi.dart`.
- 03: `lib/widgets/game/` (`RouteModePill`, `AnswerCard`, `ProgressDots`, `GameGlyph`), TTS perangkat di semua mode build, dan aturan narasi TTS di Global Constraints Rencana 03.

## Global Constraints

- Flutter **3.50.0** lewat FVM. Semua perintah memakai `fvm flutter …` / `fvm dart …`.
- **Tidak ada paket baru.** Rencana ini hanya memakai Riverpod, `go_router`, `flutter_soloud`, dan `Ticker` bawaan. Tidak ada analytics, crash reporting, atau ikon dari paket luar.
- Material diimpor dari `package:material_ui/material_ui.dart`; file yang hanya butuh lapisan widget memakai `package:flutter/widgets.dart`.
- **Tidak ada izin perangkat, kanal native, atau perubahan manifest** di rencana ini. Mikrofon tetap hanya milik Ucapkan.
- **Narasi:** rekaman belum ada sampai Rencana 09, jadi TTS perangkat dipakai di **semua mode build** seperti keputusan H1 Rencana 03. `Narrator` memakai `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a` kalau ada, dan TTS kalau tidak. Id baris harus sama dengan `lib/core/content/narasi.dart`: `suku_<suku>`, `kata_<item>`, `kalimat_<id>`, `nama_<item>`, dan `ui_<kunciArb>` untuk kunci ARB bertanda `"description": "narasi"`. Tidak ada baris narasi baru di luar daftar itu.
- **Layout:** setiap layar adalah `MociStage(theme: MenuTheme.membaca, tablet: …)` berukuran 1180 × 820. HP memakai desain tablet yang diperkecil (D12) sampai Rencana 08; tidak ada builder `phone` di rencana ini.
- Target sentuh **64 pt** tablet, jarak **16 pt**, margin tepi **32 pt**. Kontras teks minimal **4,5 : 1**. Tekan: turun **5 pt**, skala **0,97**, **120 ms**. Muncul: **400–550 ms**, kurva `Cubic(0.3, 1.6, 0.5, 1)`. Saat `MediaQuery.disableAnimations` aktif, animasi hiasan berhenti, tetapi sorotan karaoke, umpan balik benar/salah, dan keping yang terangkat tetap muncul.
- **Kisi Suku Kata:** 18 konsonan dari `katalog.sukuKata.konsonan` (`bcdfghjklmnprstwyz`), 5 vokal dari `katalog.sukuKata.vokal` dengan urutan `a, i, u, e, o`, disusun **4 kolom × 5 baris** (18 sel terisi). Satu baris = satu konsonan × lima vokal.
- **Level Susun Kata:** hanya level **2** dan **3** suku kata. Lima kata per level. Level 2 memakai **2 keping pengganggu**, level 3 memakai **1**, jadi selalu **4 keping**.
- **Waktu kalimat:** `KalimatEntry.waktu` masih `null` sampai Rencana 09. Selama `null`, waktu mulai kata = `420 + 75 × panjang kata` ms, dengan panjang kata termasuk tanda baca (persis prototipe). Kalau `waktu` ada tetapi panjangnya tidak sama dengan jumlah kata atau tidak menaik, rumus prototipe yang dipakai.
- **Dua bahasa setara:** semua teks lewat gen-l10n, dan bahasa bisa berganti saat layar terbuka tanpa memulai ulang aplikasi. Teks dari artboard disalin persis; kunci bernama `<layar><KunciT>` dengan awalan `sukuKata`, `susunKata`, `kalimat`, dan kunci bersama berawalan `membaca`. Hanya kunci yang benar-benar dibacakan diberi `"description": "narasi"`.
- Teks permainan tidak mengikuti ukuran teks sistem (`textScaleCap` 1,0).
- Tidak ada unduhan saat aplikasi berjalan. Semua data dari `assets/content/` dan `assets/illustrations/`.
- **Progres:** modul `membaca` di `RingkasanModul` punya penyebut **90 suku kata** (kisi 18 × 5). Suku Kata mencatat `markItem('membaca', 'dibaca', suku)` saat suku kata diketuk. Susun Kata mencatat suku kata yang berhasil disusun **hanya kalau suku itu ada di kisi 90** (pemenggalan seperti `ple` atau `bra` tidak dihitung, supaya penyebut tidak terlampaui). Kalimat tidak memanggil `markItem`, karena 18 kalimat bukan item modul `membaca`; Kalimat hanya mencatat `setLastActivity`.
- **Lanjutkan:** setiap layar menerima `awal` dari query: `SukuKataScreen` dari `huruf`, `SusunKataScreen` dari `level`, `KalimatScreen` dari `kalimat`. Nilai yang tidak dikenal diabaikan (kembali ke pilihan bawaan). Layar mencatat `setLastActivity` saat dibuka dan saat pilihan berganti. Subjudul kartu Lanjutkan memakai fallback `BerandaMenu.parentOf` → "Ayo Membaca"; `continue_labels.dart` tidak diubah.
- Efek suara hanya dari enum `Sfx` (`klik`, `benar`, `salahLembut`, `sorak`, `bintang`). Tidak ada buzzer.
- **Tes tanpa `pumpAndSettle`:** `MociMascot` dan gerak hiasan berjalan terus. Semua tes memakai `pump` berbatas waktu atau jumlah pump.
- Tidak ada `TODO`, placeholder, teks Inggris hardcoded di widget, atau cabang `kDebugMode` di layar.

## Review Focus

1. **Anak mengetuk bertubi-tubi:** keping suku kata yang sama dua kali, dua keping sekaligus, atau "Lanjut" dua kali di kata kelima. Keping terpakai harus ditolak, kotak tidak boleh terisi dua kali, dan hadiah tidak boleh dobel. Dipatok di Task 3 (`keping terpakai tidak bisa dipakai lagi`) dan Task 4 (`lima kata selesai membuka Hebat sekali`).
2. **Bahasa diganti saat layar terbuka atau saat karaoke berjalan.** Contoh kata, kolam kata, teks kalimat, waktu mulai, pilihan gambar, dan bahasa narasi harus ikut bahasa baru tanpa memulai ulang, dan sorotan karaoke harus berhenti. Dipatok di Task 2 (`ganti bahasa mengganti contoh kata`), Task 4 (`ganti bahasa mengganti kolam kata`), dan Task 6 (`ganti bahasa saat karaoke menghentikan sorotan`).
3. **Waktu kalimat tidak wajar:** `waktu` rekaman lebih pendek dari jumlah kata, tidak menaik, kalimat satu kata, kata terpanjang, dan kalimat enam kata. Tidak boleh ada `RangeError`, sorotan tidak boleh melewati kata terakhir, dan karaoke harus berhenti sendiri. Dipatok di Task 5 (`waktu rekaman yang tidak cocok diabaikan`, `indeks karaoke mengikuti waktu mulai`) dan Task 6 (`kalimat panjang EN tidak overflow`).
4. **Isi yang tidak lengkap atau kueri salah:** suku kata yang tidak punya contoh kata, `?huruf=q`, `?level=9`, `?kalimat=tidak-ada`, dan kata yang gambarnya tidak ada. Layar harus jatuh ke pilihan bawaan atau placeholder, bukan melempar galat. Dipatok di Task 1 (`suku tanpa contoh tidak punya contoh kata`), Task 2 (`suku tanpa contoh menampilkan ajakan ucapkan`), dan Task 6 (`kalimat tak dikenal kembali ke kalimat pertama`).
5. **Isi terpanjang di tata letak sempit:** `Brokoli`/`Semangka` di tiga kotak, `Butterfly`/`Crocodile` di level 3 EN, dan kalimat `The elephant has a long trunk.` di kartu 620 pt. Tidak boleh ada overflow atau teks terpotong. Dipatok di Task 4 (`level 3 dan kata panjang tidak overflow`) dan Task 6 (`kalimat panjang EN tidak overflow`).

## Keputusan rencana ini

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| B1 | Bilah atas ketiga layar memakai `MembacaTopBar`: kembali, judul "Ayo Membaca", lalu `RouteModePill` tiga tab. Tidak ada `StarCounter`, karena artboard Ayo Membaca tidak memuatnya; bintang hanya terlihat di Beranda dan Hebat. | Kesetiaan pada artboard; bintang di tiap layar akan mengalihkan perhatian dari kata. |
| B2 | Suku Kata selalu menampilkan lima vokal untuk satu konsonan. Konsonan awal `b` (atau `?huruf=`), vokal awal `a`. Kisi konsonan 4 × 5 dengan sel terakhir kosong. | Prototipe dan PRD: anak memilih konsonan untuk membentuk ba-bi-bu-be-bo. |
| B3 | Memilih konsonan membacakan kelima suku kata berurutan sambil menyorot kartunya. Mengetuk satu kartu membacakan suku itu dan menandainya di progres. "Baca semua" mengulang kelima suku dengan sorotan yang mengikuti tiap baris yang selesai dibacakan. | Prototipe membacakan kelima suku saat konsonan dipilih; sorotan mengikuti suara, bukan timer buta. |
| B4 | Contoh kata diambil per bahasa. Kalau sel tidak punya contoh, kartu menampilkan suku kata di lingkaran dan label "Ayo ucapkan!", bukan kata palsu. Garis bawah contoh hanya di awal kata kalau kata benar-benar diawali suku itu. | Data prototipe hanya punya 41 contoh dari 90 sel; memalsukan contoh akan mengajari pelafalan yang salah. |
| B5 | Progres `membaca` hanya menghitung 90 suku kata kisi. Susun Kata menandai suku kata hasil susunan yang ada di kisi; Kalimat tidak menandai item. | `RingkasanModul.membaca` memakai penyebut 90; suku kata pemenggalan seperti `ple` akan membuat rasio melewati 1. |
| B6 | Susun Kata: lima kata per level, selalu empat keping (level 2: dua pengganggu; level 3: satu), kata tidak berulang berurutan, dan level berakhir hanya lewat tombol "Lanjut" di kata kelima. Ronde memakai `Random` dari `membacaRandomProvider`. | Empat keping cukup untuk jari anak dan menjaga tata letak artboard; tombol Lanjut mencegah hadiah muncul saat narasi pujian masih berbunyi. |
| B7 | Hadiah Susun Kata memakai `finishGame(gameId: 'membaca/susun-kata', roundId: '<bahasa>-<level>-<microsecondsSinceEpoch>')`, lalu `context.push(Routes.hebat, extra: HebatArgs(...))` dengan `replayRoute` yang membawa `?level=`. Flag `_selesai` menahan panggilan kedua. `HebatArgs`/`hadiahProvider` diimpor dari `features/hadiah`; itu satu-satunya impor lintas fitur di rencana ini karena Hebat adalah layar tujuan bersama, bukan aturan permainan lain. | `roundId` unik per penyelesaian sehingga "Main lagi" tetap bisa mendapat hadiah, sementara ketukan ganda pada ronde yang sama tidak. |
| B8 | Kalimat: "Baca bersama" memutar `kalimat_<id>` dan menyalakan kata memakai `Ticker` dengan waktu mulai dari `waktu` rekaman atau rumus K7. Sorotan berhenti di akhir dan dikosongkan. Karaoke berhenti saat kata diketuk, mode diganti, kalimat diganti, bahasa diganti, atau layar ditutup. `DeviceTts` tidak diberi parameter laju: selama rekaman belum ada, TTS perangkat berbicara pada laju bawaannya dan sorotan mengikuti jadwal K7, jadi bisa bergeser sedikit; setelah Rencana 09 mengisi `waktu`, jadwal dan rekaman sama. | `Ticker` memberi waktu yang tepat di tes dan di perangkat; tidak ada seek di `AudioService`, dan memperluas `DeviceTts`/kanal native berada di luar lingkup rencana ini. |
| B9 | Mengetuk satu kata membacakan kata itu saja lewat `NarrationLine(jenis: 'kata', id: <kata tanpa tanda baca, huruf kecil>, text: <kata tanpa tanda baca>)`. Kalau rekaman `kata_<id>` ada (kata Susun Kata), rekaman itu yang dipakai; kalau tidak, TTS. | Prototipe membacakan kata yang diketuk; tidak ada rekaman per kata untuk kalimat, dan aturan narasi Rencana 03 sudah menetapkan TTS untuk teks tanpa rekaman. |
| B10 | Mode Tebak gambar memakai tiga `AnswerCard` 240 × 180 berisi gambar; jawaban benar membuka gambar besar dan membacakan kalimatnya, jawaban salah bergoyang lembut lalu bisa dicoba lagi. Tidak ada Hebat. | PRD hanya mewajibkan karaoke dan tebak gambar; Hebat khusus permainan berakhir. |
| B11 | `setLastActivity`: `/membaca/suku-kata` dengan `{'huruf': k}`, `/membaca/susun-kata` dengan `{'level': '2'|'3'}`, `/membaca/kalimat` dengan `{'kalimat': id}`. Layar mencatatnya saat dibuka dan setiap pilihan berganti. | Kartu Lanjutkan membuka `route?param` dan memakai fallback judul menu; tidak perlu entri `continue_labels` baru. |
| B12 | Kunci ARB baru mengikuti `<layar><KunciT>`: `sukuKataPilih`, `susunKataLevel2`, `kalimatReadMode`, dan seterusnya. Kata "Betul! " prototipe dirapikan menjadi `susunKataYes` "Betul!" tanpa spasi ekor. Hanya kunci yang dibacakan diberi `"description": "narasi"`. | Rekaman butuh satu berkas per kalimat utuh; spasi ekor di ARB mudah hilang dan membuat berkas narasi salah nama. |

## Peta file

```
lib/features/membaca/membaca_providers.dart            # membacaRandomProvider
lib/features/membaca/widgets/membaca_top_bar.dart      # bilah atas + tiga tab mode
lib/features/membaca/widgets/membaca_pill.dart         # pil level/mode 50 pt
lib/features/membaca/suku_kata/suku_kata_game.dart     # kisi, contoh kata, pemecah awalan (Dart murni)
lib/features/membaca/suku_kata/suku_kata_screen.dart   # layar Suku Kata
lib/features/membaca/susun_kata/susun_kata_game.dart   # lima ronde, keping, penilaian (Dart murni)
lib/features/membaca/susun_kata/susun_tile.dart        # keping suku kata 168 × 116
lib/features/membaca/susun_kata/susun_kata_screen.dart # layar Susun Kata + Hebat
lib/features/membaca/kalimat/kalimat_timing.dart       # kata, waktu mulai, indeks karaoke (Dart murni)
lib/features/membaca/kalimat/kalimat_game.dart         # id gambar + tiga pilihan (Dart murni)
lib/features/membaca/kalimat/kalimat_word.dart         # kata yang menyala
lib/features/membaca/kalimat/kalimat_screen.dart       # layar Kalimat
```

Berkas di atas adalah kontrak untuk Rencana 06–08: nama tipe dan kunci di task 2, 4, dan 6 tidak boleh berubah setelah rencana ini selesai tanpa memperbarui rencana berikutnya.

---

### Task 1: Aturan Suku Kata

**Files:**
- Create: `lib/features/membaca/suku_kata/suku_kata_game.dart`, `test/features/membaca/suku_kata_game_test.dart`

**Interfaces:**
- Consumes: `SukuKataInfo` (`konsonan`, `vokal`, `contoh`), `AppLang`.
- Produces (dipakai Task 2):
  - `final class SukuContoh { const SukuContoh({required this.suku, required this.item, required this.kata}); final String suku, item, kata; }`
  - `final class SukuKartu { const SukuKartu({required this.suku, required this.konsonan, required this.vokal, this.contoh}); final String suku, konsonan, vokal; final SukuContoh? contoh; bool get adaContoh; }`
  - `List<String> konsonanKisi(SukuKataInfo info)` — huruf kecil, urut seperti katalog, tanpa duplikat.
  - `List<String> vokalKisi(SukuKataInfo info)` — persis `info.vokal` (`a, i, u, e, o`).
  - `List<SukuKartu> barisKonsonan(SukuKataInfo info, String konsonan, AppLang bahasa)` — lima kartu, urut vokal; daftar kosong kalau konsonan tidak ada di kisi.
  - `SukuContoh? contohSuku(SukuKataInfo info, AppLang bahasa, String suku)` — `null` kalau bahasa itu tidak punya contoh; `item` adalah id ilustrasi.
  - `({String awalan, String sisa}) pecahContoh(String kata, String suku)` — `awalan` = potongan kata sepanjang suku kata hanya kalau kata (huruf kecil) diawali suku itu; selain itu `awalan` kosong.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/membaca/suku_kata/suku_kata_game.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

void main() {
  final info = _katalog().sukuKata;

  test('kisi memuat 18 konsonan dan 5 vokal', () {
    expect(konsonanKisi(info).length, 18);
    expect(konsonanKisi(info).first, 'b');
    expect(vokalKisi(info), ['a', 'i', 'u', 'e', 'o']);
  });
  test('baris konsonan berisi lima suku berurutan', () {
    final baris = barisKonsonan(info, 'b', AppLang.id);
    expect(baris.map((e) => e.suku), ['ba', 'bi', 'bu', 'be', 'bo']);
    expect(baris.first.contoh?.kata, 'Badak');
    expect(baris.first.contoh?.item, 'badak');
  });
  test('contoh kata mengikuti bahasa', () {
    expect(contohSuku(info, AppLang.id, 'ba')?.kata, 'Badak');
    expect(contohSuku(info, AppLang.en, 'ba')?.kata, 'Ball');
  });
  test('suku tanpa contoh tidak punya contoh kata', () {
    expect(contohSuku(info, AppLang.id, 'zi'), isNull);
    expect(barisKonsonan(info, 'q', AppLang.id), isEmpty);
    expect(barisKonsonan(info, 'z', AppLang.id)[1].adaContoh, isFalse);
  });
  test('awalan contoh mengikuti suku kata di awal kata', () {
    expect(pecahContoh('Badak', 'ba'), (awalan: 'Ba', sisa: 'dak'));
    expect(pecahContoh('Bola', 'la'), (awalan: '', sisa: 'Bola'));
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/suku_kata_game_test.dart`. Expected: FAIL karena file belum ada.

- [ ] **Step 3: Implementasikan aturan.** `konsonanKisi` membuang spasi dan duplikat dari `info.konsonan.toLowerCase().split('')`. `barisKonsonan` mengembalikan `[]` kalau konsonan tidak ada, lalu memetakan `vokalKisi` ke `SukuKartu(suku: '$k$v', …)` dengan `contohSuku`. `contohSuku` membaca `info.contoh[bahasa.name]?[suku]` dan membungkus `item`/`kata`. Jangan mengimpor Flutter.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/membaca/suku_kata_game_test.dart`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(membaca): aturan kisi suku kata dan contoh kata dua bahasa`.

---

### Task 2: Layar Suku Kata

**Files:**
- Create: `lib/features/membaca/widgets/membaca_top_bar.dart`, `lib/features/membaca/suku_kata/suku_kata_screen.dart`, `test/features/membaca/suku_kata_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/membaca/suku-kata`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/membaca/suku_kata_screen_test.dart`

**Interfaces:**
- Consumes: `katalogProvider`, `MociStage(MenuTheme.membaca)`, `MembacaTopBar`, `MociBackButton`, `MociPressable`, `MociIllustration`, `MociMascot`, `Narrator`, `prefsProvider`, `progressProvider`, `Routes`, `barisKonsonan`, `pecahContoh`.
- Produces (dipakai Task 4 dan 6):
  - `class MembacaTopBar extends StatelessWidget { const MembacaTopBar({super.key}); }` — `MociTopBar(leading: MociBackButton(semanticLabel: l10n.commonBack), title: l10n.membacaTitle, trailing: [RouteModePill(tabs: membacaTabs(l10n), semanticLabel: l10n.membacaModes, accent: Color(0xFFE0661A))])`.
  - `List<({String label, String route, Widget? icon})> membacaTabs(AppLocalizations l10n)` — Suku Kata → `Routes.sukuKata`, Susun Kata → `Routes.susunKata`, Kalimat → `Routes.kalimat`.
  - `class SukuKataScreen extends ConsumerStatefulWidget { const SukuKataScreen({super.key, this.awal}); final String? awal; static ValueKey<String> konsonanKey(String k); static ValueKey<String> sukuKey(String suku); static const listenKey = ValueKey<String>('suku-kata-listen'); static const readAllKey = ValueKey<String>('suku-kata-read-all'); }`
  - `awal` = konsonan dari `?huruf=k` (huruf kecil); di luar kisi diabaikan, bawaan `'b'`. Vokal awal selalu `a`.
  - Tata letak `MociStage(MenuTheme.membaca)`: bilah atas; kartu kiri 300 × 660 di (32,122) berisi label `sukuKataPilih`, kisi konsonan 4 kolom × 5 baris (sel 56 tinggi, radius 18, font 30, terpilih `#E0661A` + bayangan `#A9480D`, lainnya `#FFF1E6` + bayangan `#F7C9A5`), Moci 100, dan `sukuKataTip` 15 pt; kartu kanan 792 × 660 di (356,122) radius 44 berisi kepala konsonan 78 (`#2B2350`, huruf putih 50), tanda `+` 44 `#ADB5BD`, lima vokal 58 dengan warna `a #E8384F`, `i #1C7ED6`, `u #2F9E44`, `e #F08C00`, `o #7048E8`; lima kartu suku 150 tinggi radius 34 (warna vokal, bayangan 9, font 64, huruf konsonan 85% opasitas, kartu aktif naik 10 dan skala 1,06 dengan titik 16 di bawah); kartu contoh `#FFF6EE` 290 tinggi radius 34 berisi gambar 210 atau lingkaran suku kata, label `sukuKataExample`/`sukuKataSayIt`, kata Fredoka 76 (56 kalau lebih dari 9 huruf) dengan awalan bergaris bawah 6, tombol `sukuKataHear` (60, `#FFB020`) dan `sukuKataReadAll` (60, `#E0661A`).
  - Perilaku: saat dibuka `setLastActivity(Routes.sukuKata, {'huruf': k})` lalu `sayAll([ui sukuKataTip])`. Memilih konsonan mengulang vokal ke `a`, menyorot kartu pertama, memperbarui `lastActivity`, dan membacakan lima suku berurutan dengan sorotan mengikuti tiap baris. Mengetuk kartu suku membacakan `suku_<suku>`, menyorot kartu itu, dan `markItem('membaca', 'dibaca', suku)`. `sukuKataHear` membacakan `suku_<suku>` lalu `nama_<item>` kalau ada contoh. `sukuKataReadAll` mengulang lima suku dengan sorotan. Ganti bahasa memuat ulang contoh untuk konsonan/vokal yang sama, menghentikan sorotan dan narasi, tanpa memulai ulang aplikasi.
  - ARB baru (ID / EN): `membacaTitle` "Ayo Membaca" / "Let's Read"; `membacaModes` "Mode membaca" / "Reading mode"; `membacaSukuKata` "Suku Kata" / "Syllables"; `membacaSusunKata` "Susun Kata" / "Build Words"; `membacaKalimat` "Kalimat" / "Sentences"; `sukuKataPilih` "Pilih huruf" / "Pick a letter"; `sukuKataTip` "Ketuk suku kata untuk mendengarnya!" / "Tap a syllable to hear it!" (`"description": "narasi"`); `sukuKataHear` "Dengar kata" / "Hear word"; `sukuKataReadAll` "Baca semua" / "Read all"; `sukuKataExample` "Contoh kata" / "Example word"; `sukuKataSayIt` "Ayo ucapkan!" / "Say it out loud!"; `sukuKataLetter` "Huruf {huruf}" / "Letter {huruf}"; `sukuKataSyllable` "Suku kata {suku}" / "Syllable {suku}".
  - `GoRoute` `/membaca/suku-kata` membaca `state.uri.queryParameters['huruf']` dan meneruskannya sebagai `awal`; `_soon(Routes.sukuKata, …)` dihapus.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/routes.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/membaca/suku_kata/suku_kata_screen.dart';

import '../../helpers/harness.dart';

Progress _progress(WidgetTester t) => ProviderScope.containerOf(
  t.element(find.byType(MociApp)),
).read(progressProvider);

void main() {
  testWidgets('membuka: konsonan b, lima suku, contoh Badak', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    expect(find.text('Ayo Membaca'), findsOneWidget);
    expect(find.text('Pilih huruf'), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('ba')), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('bo')), findsOneWidget);
    expect(find.text('Badak', findRichText: true), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['Ketuk suku kata untuk mendengarnya!']);
  });
  testWidgets('memilih konsonan mengganti baris dan membacakan lima suku', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    env.tts.spoken.clear();
    await t.tap(find.byKey(SukuKataScreen.konsonanKey('k')));
    await t.pump();
    await t.pump();
    expect(find.text('Kado', findRichText: true), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['ka', 'ki', 'ku', 'ke', 'ko']);
  });
  testWidgets('mengetuk suku kata mencatat progres membaca', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    await t.tap(find.byKey(SukuKataScreen.sukuKey('bi')));
    await t.pump();
    expect(env.tts.spoken.last.$1, 'bi');
    expect(_progress(t).perkembangan['membaca']!['dibaca'], ['bi']);
  });
  testWidgets('suku tanpa contoh menampilkan ajakan ucapkan', (t) async {
    await pumpApp(t, initialLocation: Routes.sukuKata);
    await t.tap(find.byKey(SukuKataScreen.konsonanKey('z')));
    await t.pump();
    expect(find.text('Ayo ucapkan!'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('baca semua membacakan lima suku berurutan', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    env.tts.spoken.clear();
    await t.tap(find.byKey(SukuKataScreen.readAllKey));
    await t.pump();
    await t.pump();
    expect(env.tts.spoken.map((e) => e.$1), ['ba', 'bi', 'bu', 'be', 'bo']);
  });
  testWidgets('ganti bahasa mengganti contoh kata', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.sukuKata);
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text('Ball', findRichText: true), findsOneWidget);
    expect(find.text('Badak', findRichText: true), findsNothing);
  });
  testWidgets('lanjutkan membuka konsonan terakhir', (t) async {
    await pumpApp(t, initialLocation: '${Routes.sukuKata}?huruf=k');
    expect(find.text('Kado', findRichText: true), findsOneWidget);
    expect(find.byKey(SukuKataScreen.sukuKey('ko')), findsOneWidget);
  });
  testWidgets('kueri konsonan tidak dikenal kembali ke b', (t) async {
    await pumpApp(t, initialLocation: '${Routes.sukuKata}?huruf=q');
    expect(find.text('Badak', findRichText: true), findsOneWidget);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.sukuKata);
    await t.tap(find.text('Susun Kata'));
    await t.pump();
    expect(router.routerDelegate.currentConfiguration.last.matchedLocation, Routes.susunKata);
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/suku_kata_screen_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`, layar belum ada).

- [ ] **Step 3: Implementasikan layar, bilah atas, ARB, dan rute.** Salin teks dari `SukuKata.dc.html` baris 144–145. Tambah kunci ARB beserta metadata `@kunci` (termasuk placeholder `huruf` dan `suku`), lalu `fvm flutter gen-l10n`; jangan menyunting `lib/l10n/app_localizations*.dart` dengan tangan. Ganti `_soon(Routes.sukuKata, …)` dengan `GoRoute` seperti di Interfaces. Sorotan "Baca semua" memakai penghitung generasi di state supaya ketukan baru menghentikan urutan lama; jangan memakai `Timer.periodic` untuk ini.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/membaca test/widgets/game`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(membaca): layar Suku Kata 18 × 5 dengan contoh kata dua bahasa`.

---

### Task 3: Aturan Susun Kata

**Files:**
- Create: `lib/features/membaca/susun_kata/susun_kata_game.dart`, `test/features/membaca/susun_kata_game_test.dart`

**Interfaces:**
- Consumes: `KataEntry` (`item`, `kata`, `suku`, `level`), `dart:math` (`Random`).
- Produces (dipakai Task 4):
  - `const rondePerLevel = 5;`, `const levelTersedia = [2, 3];`
  - `enum SusunKetuk { mengisi, benar, salah, penuh, dipakai }`
  - `final class SusunRonde { const SusunRonde({required this.entry, required this.tiles, required this.slots}); final KataEntry entry; final List<String> tiles; final List<int?> slots; bool get lengkap; int get terisi; String get tersusun; String get target; bool get benar; }`
  - `final class SusunKataGame { SusunKataGame({required List<KataEntry> kata, required Random random, int level = 2}); int get level; int get nomor; SusunRonde get ronde; bool get levelSelesai; void gantiLevel(int level); SusunKetuk ketuk(int tile); bool lepasSlot(int slot); void kosongkan(); void berikutnya(); }`
  - Aturan: kolam = `kata.where((e) => e.level == level)`. Level selain 2/3 atau kolam kosong → `ArgumentError`. Kata berikutnya tidak boleh sama dengan kata sebelumnya. Keping = suku kata target + pengganggu dari suku kata kata lain di kolam (tanpa suku kata target), diacak; jumlah pengganggu 2 (level 2) atau 1 (level 3). `ketuk(tile)` mengisi kotak kosong pertama; keping yang sudah terpakai → `dipakai`; tidak ada kotak kosong → `penuh`; setelah kotak penuh, `tersusun == target` → `benar`, selain itu `salah`. `kosongkan()` mengosongkan semua kotak tanpa mengganti kata. `berikutnya()` menaikkan `nomor` dan membuat ronde baru; pada `nomor == 5` ia menandai `levelSelesai = true` dan tidak membuat ronde baru.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/membaca/susun_kata/susun_kata_game.dart';

const _kata = [
  KataEntry(item: 'bola', kata: 'Bola', suku: ['bo', 'la']),
  KataEntry(item: 'buku', kata: 'Buku', suku: ['bu', 'ku']),
  KataEntry(item: 'kereta', kata: 'Kereta', suku: ['ke', 're', 'ta']),
  KataEntry(item: 'sepatu', kata: 'Sepatu', suku: ['se', 'pa', 'tu']),
];

void _selesaikan(SusunKataGame g) {
  for (final suku in g.ronde.entry.suku) {
    if (!g.ronde.benar) g.ketuk(g.ronde.tiles.indexOf(suku));
  }
}

void main() {
  test('level 2: empat keping, dua di antaranya pengganggu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final r = g.ronde;
    expect(r.entry.level, 2);
    expect(r.tiles.length, 4);
    expect(r.tiles.toSet().length, 4);
    expect(r.tiles, containsAll(r.entry.suku));
    expect(r.slots.length, 2);
  });
  test('level 3: empat keping dengan satu pengganggu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7), level: 3);
    expect(g.ronde.entry.level, 3);
    expect(g.ronde.tiles.length, 4);
    expect(g.ronde.slots.length, 3);
  });
  test('mengetuk berurutan menyelesaikan kata', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    _selesaikan(g);
    expect(g.ronde.benar, isTrue);
    expect(g.ronde.tersusun, g.ronde.target);
  });
  test('keping terpakai tidak bisa dipakai lagi', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final i = g.ronde.tiles.indexOf(g.ronde.entry.suku.first);
    expect(g.ketuk(i), SusunKetuk.mengisi);
    expect(g.ketuk(i), SusunKetuk.dipakai);
  });
  test('keping salah mengisi lalu kosongkan', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final target = g.ronde.entry.suku.toSet();
    final salah = g.ronde.tiles.indexWhere((s) => !target.contains(s));
    expect(g.ketuk(salah), SusunKetuk.mengisi);
    expect(g.ketuk(g.ronde.tiles.indexOf(g.ronde.entry.suku.first)), SusunKetuk.salah);
    expect(g.ronde.lengkap, isTrue);
    g.kosongkan();
    expect(g.ronde.slots, [null, null]);
    expect(g.ronde.entry.kata, isNotEmpty);
  });
  test('lima ronde berakhir dan kata tidak berulang berurutan', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    final urutan = <String>[g.ronde.entry.kata];
    for (var i = 0; i < 4; i++) {
      _selesaikan(g);
      g.berikutnya();
      urutan.add(g.ronde.entry.kata);
    }
    expect(g.nomor, 5);
    expect(g.levelSelesai, isFalse);
    for (var i = 1; i < urutan.length; i++) {
      expect(urutan[i], isNot(urutan[i - 1]));
    }
    _selesaikan(g);
    g.berikutnya();
    expect(g.levelSelesai, isTrue);
    expect(g.nomor, 5);
  });
  test('ganti level memulai ulang dari ronde satu', () {
    final g = SusunKataGame(kata: _kata, random: Random(7));
    _selesaikan(g);
    g.berikutnya();
    expect(g.nomor, 2);
    g.gantiLevel(3);
    expect(g.nomor, 1);
    expect(g.ronde.entry.level, 3);
    expect(g.levelSelesai, isFalse);
  });
  test('kolam level kosong atau level asing ditolak', () {
    const duaSaja = [
      KataEntry(item: 'bola', kata: 'Bola', suku: ['bo', 'la']),
    ];
    expect(
      () => SusunKataGame(kata: duaSaja, random: Random(1), level: 3),
      throwsArgumentError,
    );
    expect(
      () => SusunKataGame(kata: _kata, random: Random(1), level: 4),
      throwsArgumentError,
    );
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/susun_kata_game_test.dart`. Expected: FAIL karena file belum ada.

- [ ] **Step 3: Implementasikan aturan.** Simpan `_kata`, `_random`, `_level`, `_nomor`, `_ronde`, `_selesai`, dan `_sebelumnya`. Pembuatan keping: ambil `entry.suku`, kumpulkan suku kata unik dari kata lain di kolam yang tidak ada di target, `shuffle(_random)`, ambil 2 atau 1, gabung, `shuffle(_random)`. Suku kata target yang berulang (misalnya EN `banana` = `ba`, `na`, `na`) tetap menjadi dua keping terpisah; semua penilaian memakai indeks keping, bukan teks. Jangan mengimpor Flutter.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/membaca/susun_kata_game_test.dart`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(membaca): aturan ronde Susun Kata level 2 dan 3`.

---

### Task 4: Layar Susun Kata dan Hebat

**Files:**
- Create: `lib/features/membaca/membaca_providers.dart`, `lib/features/membaca/widgets/membaca_pill.dart`, `lib/features/membaca/susun_kata/susun_tile.dart`, `lib/features/membaca/susun_kata/susun_kata_screen.dart`, `test/features/membaca/susun_kata_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/membaca/susun-kata`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/membaca/susun_kata_screen_test.dart`

**Interfaces:**
- Consumes: `katalogProvider`, `membacaRandomProvider`, `clockProvider`, `audioServiceProvider`, `MembacaTopBar`, `MembacaPill`, `ProgressDots`, `GameGlyph`, `MociIllustration`, `MociMascot`, `Narrator`, `Sfx`, `prefsProvider`, `progressProvider`, `hadiahProvider`, `HebatArgs`, `Routes`, `SusunKataGame`, `SusunTile`.
- Produces (dipakai Task 6):
  - `final membacaRandomProvider = Provider<Random>((_) => Random());`
  - `class MembacaPill extends StatelessWidget { const MembacaPill({super.key, required this.label, required this.selected, required this.onTap, this.height = 50}); final String label; final bool selected; final VoidCallback onTap; final double height; }` — radius penuh, terpilih `#E0661A` + bayangan `#A9480D` + teks putih, lainnya putih + bayangan tema + tinta; font Fredoka 600 19.
  - `class SusunTile extends StatelessWidget { const SusunTile({super.key, required this.index, required this.suku, required this.used, required this.onTap}); final int index; final String suku; final bool used; final VoidCallback? onTap; }` — 168 × 116, radius 30, warna dari lima warna prototipe (`#FF8A3D`, `#1C8CF0`, `#7048E8`, `#26A03B`, `#E8384F`) bergiliran menurut `index`, bayangan 10 versi gelap, teks putih 54; `used` → opasitas 0,25 dan `onTap` null.
  - `class SusunKataScreen extends ConsumerStatefulWidget { const SusunKataScreen({super.key, this.awal}); final String? awal; static ValueKey<int> levelKey(int level); static ValueKey<int> tileKey(int i); static ValueKey<int> slotKey(int i); static const hearKey = ValueKey<String>('susun-kata-hear'); static const nextKey = ValueKey<String>('susun-kata-next'); }`
  - `awal` = level dari `?level=3`; selain 2/3 diabaikan, bawaan 2.
  - Tata letak: bilah atas; pil level di (70,120) (`susunKataLevel2`/`susunKataLevel3`); `ProgressDots(count: 5, current: nomor - 1, activeColor: #E0661A)` di kanan atas 70/136; kartu 1040 × 400 di (70,186) radius 48 berisi lingkaran 290 + ilustrasi 250 (`MociIllustration(entry.item)`), tombol dengar 78 `#FFB020` (`GameGlyph.listen`) di (145,300), label instruksi 20 pt di (380,34), baris kotak di (380,76) (lebar 250 untuk dua kotak, 190 untuk tiga; tinggi 150; radius 32; kotak kosong bergaris putus-putus `#F7C9A5` dengan `?` 60; kotak terisi warna keping dengan teks 76/60; semua hijau saat benar), baris status di (380,258) berisi kata kapital `#E0661A` + tombol `susunKataNext` 70 saat benar, atau petunjuk; baris empat `SusunTile` di y 628; Moci 120 di (20,690).
  - Perilaku: saat dibuka `setLastActivity(Routes.susunKata, {'level': '$level'})` lalu `sayAll([ui susunKataIns, kata_<item>])`. Ketuk keping → `say(suku_<suku>)`; keping salah → `playSfx(Sfx.salahLembut)` + `say([ui susunKataTryAgain])` lalu kotak dikosongkan setelah **1100 ms**; kata benar → `playSfx(Sfx.benar)` + `sayAll([ui susunKataYes, …suku_<suku>, kata_<item>])` + `markItem('membaca', 'dibaca', suku)` untuk tiap suku yang ada di `katalog.sukuKata.semua`. "Lanjut" di kata 1–4 membuat ronde baru dan membacakan kata barunya; di kata 5 memanggil `finishGame(gameId: 'membaca/susun-kata', roundId: '<bahasa>-<level>-<microsecondsSinceEpoch>')` sekali (`_selesai`), lalu `context.push(Routes.hebat, extra: HebatArgs(award: …, replayRoute: '${Routes.susunKata}?level=$level'))`. Ganti level atau bahasa memulai ronde 1 dengan kata baru, memperbarui `lastActivity`, lalu membacakan `kata_<item>` dalam bahasa baru (narasi lama dihentikan lebih dulu).
  - `GoRoute` `/membaca/susun-kata` membaca `state.uri.queryParameters['level']` sebagai `awal`; `_soon(Routes.susunKata, …)` dihapus.
  - ARB baru (ID / EN): `susunKataLevel` "Level" / "Level"; `susunKataLevel2` "2 suku kata" / "2 parts"; `susunKataLevel3` "3 suku kata" / "3 parts"; `susunKataHear` "Dengar katanya" / "Hear the word"; `susunKataIns` "Ketuk suku kata secara berurutan" / "Tap the parts in order to build the word" (`"description": "narasi"`); `susunKataNext` "Lanjut" / "Next"; `susunKataHintStart` "Dengarkan, lalu ketuk suku kata pertama!" / "Listen, then tap the first part!"; `susunKataHintMore` "Bagus! Sekarang suku kata berikutnya." / "Good! Now the next part."; `susunKataTryAgain` "Ups, belum tepat. Coba lagi!" / "Oops, not quite. Try again!" (`"description": "narasi"`); `susunKataSlot` "Kotak {nomor}" / "Part {nomor}"; `susunKataEmpty` "kosong" / "empty"; `susunKataYes` "Betul!" / "Yes!" (`"description": "narasi"`); `susunKataTile` "Suku kata {suku}" / "Part {suku}"; `susunKataProgress` "Kemajuan" / "Progress".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/routes.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/membaca/susun_kata/susun_kata_screen.dart';
import 'package:moci/features/membaca/susun_kata/susun_tile.dart';
import 'package:moci/widgets/moci_illustration.dart';

import '../../helpers/harness.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

Progress _progress(WidgetTester t) => ProviderScope.containerOf(
  t.element(find.byType(MociApp)),
).read(progressProvider);

String _item(WidgetTester t) =>
    t.widget<MociIllustration>(find.byType(MociIllustration)).id;

Future<void> _ketukSuku(WidgetTester t, String suku) async {
  final finder = find.byWidgetPredicate(
    (w) => w is SusunTile && w.suku == suku && !w.used,
  );
  await t.tap(finder.first);
  await t.pump();
}

Future<void> _selesaikanKata(WidgetTester t, AppLang lang) async {
  final item = _item(t);
  final entry = (lang == AppLang.en ? _katalog().kata.en : _katalog().kata.id)
      .firstWhere((e) => e.item == item);
  for (final suku in entry.suku) {
    await _ketukSuku(t, suku);
  }
}

void main() {
  testWidgets('membuka: level 2, empat keping, dua kotak, dan narasi', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    expect(find.text('2 suku kata'), findsOneWidget);
    expect(find.byType(SusunTile), findsNWidgets(4));
    expect(find.byKey(SusunKataScreen.slotKey(0)), findsOneWidget);
    expect(find.byKey(SusunKataScreen.slotKey(1)), findsOneWidget);
    expect(env.tts.spoken.first.$1, 'Ketuk suku kata secara berurutan');
    expect(t.takeException(), isNull);
  });
  testWidgets('menyusun kata dengan benar menandai suku kata', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    final item = _item(t);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == item);
    await _selesaikanKata(t, AppLang.id);
    await t.pump();
    expect(find.byKey(SusunKataScreen.nextKey), findsOneWidget);
    final dicatat = _progress(t).perkembangan['membaca']!['dibaca']!;
    for (final suku in entry.suku) {
      if (_katalog().sukuKata.semua.contains(suku)) {
        expect(dicatat, contains(suku));
      }
    }
    expect(env.tts.spoken.map((e) => e.$1), contains('Betul!'));
  });
  testWidgets('keping salah mengosongkan kotak', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == _item(t));
    final salah = t.widgetList<SusunTile>(find.byType(SusunTile))
        .firstWhere((w) => !entry.suku.contains(w.suku));
    await t.tap(find.byKey(SusunKataScreen.tileKey(salah.index)));
    await t.pump();
    await _ketukSuku(t, entry.suku.first);
    expect(find.text('Ups, belum tepat. Coba lagi!'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1200));
    expect(find.descendant(of: find.byKey(SusunKataScreen.slotKey(0)), matching: find.text('?')), findsOneWidget);
  });
  testWidgets('level 3 punya tiga kotak dan satu pengganggu', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.byKey(SusunKataScreen.levelKey(3)));
    await t.pump();
    expect(find.byType(SusunTile), findsNWidgets(4));
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsOneWidget);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == _item(t));
    expect(entry.level, 3);
    expect(t.takeException(), isNull);
  });
  testWidgets('level 3 dan kata panjang tidak overflow', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.byKey(SusunKataScreen.levelKey(3)));
    await t.pump();
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(t.takeException(), isNull);
  });
  testWidgets('ganti bahasa mengganti kolam kata', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    await t.pump();
    expect(_katalog().kata.en.any((e) => e.item == _item(t)), isTrue);
    expect(env.tts.spoken.last.$2, AppLang.en);
  });
  testWidgets('lima kata selesai membuka Hebat sekali', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.susunKata);
    for (var i = 0; i < 5; i++) {
      await _selesaikanKata(t, AppLang.id);
      await t.pump(const Duration(milliseconds: 450));
      await t.tap(find.byKey(SusunKataScreen.nextKey));
      if (i == 4) {
        await t.tap(find.byKey(SusunKataScreen.nextKey), warnIfMissed: false);
      }
      await t.pump();
      await t.pump();
    }
    for (var i = 0; i < 10; i++) {
      await t.pump();
    }
    expect(router.routerDelegate.currentConfiguration.last.matchedLocation, Routes.hebat);
    expect(find.text('Hebat!'), findsOneWidget);
    expect(_progress(t).stars, 3);
    expect(_progress(t).stickers.length, 1);
    await t.pump(const Duration(milliseconds: 500));
    expect(_progress(t).stars, 3);
  });
  testWidgets('lanjutkan membuka level terakhir', (t) async {
    await pumpApp(t, initialLocation: '${Routes.susunKata}?level=3');
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsOneWidget);
  });
  testWidgets('kueri level tidak dikenal kembali ke level 2', (t) async {
    await pumpApp(t, initialLocation: '${Routes.susunKata}?level=9');
    expect(find.byKey(SusunKataScreen.slotKey(1)), findsOneWidget);
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsNothing);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.text('Kalimat'));
    await t.pump();
    expect(router.routerDelegate.currentConfiguration.last.matchedLocation, Routes.kalimat);
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/susun_kata_screen_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`, provider dan layar belum ada).

- [ ] **Step 3: Implementasikan layar, pil, keping, ARB, dan rute.** Salin teks dari `Kata.dc.html` baris 176–177. Tambah kunci ARB + metadata (`nomor`, `suku`), `fvm flutter gen-l10n`, lalu ganti `_soon(Routes.susunKata, …)`. Jangan memakai `Random` langsung di layar: selalu `ref.read(membacaRandomProvider)`. Tahan timer pengosongan 1100 ms di state dan batalkan saat ronde berganti, layar ditutup, atau bahasa berganti.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/membaca test/features/hadiah`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(membaca): layar Susun Kata lima ronde dengan Hebat`.

---

### Task 5: Waktu karaoke dan aturan Kalimat

**Files:**
- Create: `lib/features/membaca/kalimat/kalimat_timing.dart`, `lib/features/membaca/kalimat/kalimat_game.dart`, `test/features/membaca/kalimat_timing_test.dart`, `test/features/membaca/kalimat_game_test.dart`

**Interfaces:**
- Consumes: `KalimatEntry` (`id`, `teks`, `gambar`, `waktu`), `Katalog` (`item`, `kalimat`), `Bilingual`, `dart:math`.
- Produces (dipakai Task 6):
  - `const jedaAwalKata = 420;` (ms), `const tambahanPerHuruf = 75;` (ms per huruf).
  - `List<String> kataKalimat(String teks)` — pisah pada spasi beruntun, buang bagian kosong, pertahankan tanda baca.
  - `Duration durasiKata(String kata)` — `420 + 75 × kata.length` ms.
  - `List<Duration> waktuMulaiKata({required List<String> kata, List<double>? waktu})` — kalau `waktu` tidak null, panjangnya sama dengan `kata`, dan menaik ketat, pakai detik rekaman; selain itu waktu mulai kumulatif rumus prototipe. Daftar kosong → `[]`.
  - `Duration totalKata(List<String> kata, List<Duration> mulai)` — `mulai.last + durasiKata(kata.last)`; `Duration.zero` kalau kosong.
  - `int indeksKata(List<Duration> mulai, Duration berlalu)` — indeks kata terakhir yang `mulai[i] <= berlalu`; `0` sebelum kata pertama, `mulai.length - 1` setelah kata terakhir, `-1` untuk daftar kosong.
  - `String itemDariGambar(String gambar)` — ambil nama berkas tanpa folder dan `.svg`.
  - `List<String> pilihanGambar({required Katalog katalog, required KalimatEntry kalimat, required Random random})` — tiga id item unik yang berisi id gambar kalimat; dua pengganggu diambil dari `katalog.item` dan diacak.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/membaca/kalimat_timing_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/membaca/kalimat/kalimat_timing.dart';

void main() {
  test('kata dipisah dan tanda baca ikut dihitung', () {
    expect(kataKalimat('Ini bola.'), ['Ini', 'bola.']);
    expect(kataKalimat('  Dua   spasi '), ['Dua', 'spasi']);
    expect(kataKalimat(''), isEmpty);
  });
  test('tanpa waktu rekaman, rumus 420 + 75 × panjang kata', () {
    final kata = kataKalimat('Ini bola.');
    final mulai = waktuMulaiKata(kata: kata);
    expect(mulai, [Duration.zero, const Duration(milliseconds: 645)]);
    expect(totalKata(kata, mulai), const Duration(milliseconds: 1440));
  });
  test('waktu rekaman dipakai kalau panjangnya cocok', () {
    expect(
      waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0, 0.5]),
      [Duration.zero, const Duration(milliseconds: 500)],
    );
  });
  test('waktu rekaman yang tidak cocok diabaikan', () {
    final rumus = [Duration.zero, const Duration(milliseconds: 645)];
    expect(waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0]), rumus);
    expect(waktuMulaiKata(kata: ['Ini', 'bola.'], waktu: [0.6, 0.5]), rumus);
  });
  test('indeks karaoke mengikuti waktu mulai', () {
    final mulai = [Duration.zero, const Duration(milliseconds: 645)];
    expect(indeksKata(mulai, Duration.zero), 0);
    expect(indeksKata(mulai, const Duration(milliseconds: 600)), 0);
    expect(indeksKata(mulai, const Duration(milliseconds: 645)), 1);
    expect(indeksKata(mulai, const Duration(seconds: 9)), 1);
    expect(indeksKata(const [], const Duration(seconds: 1)), -1);
  });
}
```
`test/features/membaca/kalimat_game_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/membaca/kalimat/kalimat_game.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

void main() {
  test('id gambar diambil dari path', () {
    expect(itemDariGambar('illustrations/bola.svg'), 'bola');
  });
  test('tiga pilihan unik berisi jawaban dan dua pengganggu', () {
    final katalog = _katalog();
    final opsi = pilihanGambar(
      katalog: katalog,
      kalimat: katalog.kalimat.first,
      random: Random(7),
    );
    expect(opsi.length, 3);
    expect(opsi.toSet().length, 3);
    expect(opsi, contains('bola'));
  });
  test('setiap kalimat punya tiga pilihan dengan jawabannya', () {
    final katalog = _katalog();
    for (final kalimat in katalog.kalimat) {
      final opsi = pilihanGambar(katalog: katalog, kalimat: kalimat, random: Random(3));
      expect(opsi, contains(itemDariGambar(kalimat.gambar)));
      expect(opsi.toSet().length, 3);
    }
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/kalimat_timing_test.dart test/features/membaca/kalimat_game_test.dart`. Expected: FAIL karena file belum ada.

- [ ] **Step 3: Implementasikan dua berkas Dart murni.** Jangan mengimpor Flutter. `itemDariGambar` disalin ke berkas ini (bukan diimpor dari `features/ucapkan`) karena fitur tidak boleh saling mengimpor. `waktuMulaiKata` memakai waktu rekaman hanya kalau `waktu.length == kata.length` dan setiap nilai lebih besar dari sebelumnya; konversi detik ke `Duration(milliseconds: (d * 1000).round())`. `pilihanGambar` menyaring `katalog.item` yang punya id berbeda dari jawaban, mengacak dengan `random`, mengambil dua, lalu mengacak hasil akhir.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/membaca/kalimat_timing_test.dart test/features/membaca/kalimat_game_test.dart`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(membaca): waktu karaoke kalimat dan pilihan gambar`.

---

### Task 6: Layar Kalimat

**Files:**
- Create: `lib/features/membaca/kalimat/kalimat_word.dart`, `lib/features/membaca/kalimat/kalimat_screen.dart`, `test/features/membaca/kalimat_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/membaca/kalimat`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/membaca/kalimat_screen_test.dart`

**Interfaces:**
- Consumes: `katalogProvider`, `membacaRandomProvider`, `audioServiceProvider`, `MembacaTopBar`, `MembacaPill`, `AnswerCard`, `MociIllustration`, `MociMascot`, `Narrator`, `Sfx`, `prefsProvider`, `progressProvider`, `Routes`, `kataKalimat`, `waktuMulaiKata`, `totalKata`, `indeksKata`, `itemDariGambar`, `pilihanGambar`.
- Produces:
  - `class KalimatWord extends StatelessWidget { const KalimatWord({super.key, required this.text, required this.sorot, required this.onTap}); final String text; final bool sorot; final VoidCallback onTap; }` — tinggi 76, radius 22, padding 16, Fredoka 700 46, latar `#FFD43B` + bayangan `#F08C00` + naik 6 saat `sorot`, selain itu `#FFF6EE` + bayangan `#F7C9A5`.
  - `class KalimatScreen extends ConsumerStatefulWidget { const KalimatScreen({super.key, this.awal}); final String? awal; static ValueKey<int> kataKey(int i); static ValueKey<String> gambarKey(String item); static const gambarBesarKey = ValueKey<String>('kalimat-gambar-besar'); static const bacaKey = ValueKey<String>('kalimat-baca'); static const prevKey = ValueKey<String>('kalimat-prev'); static const nextKey = ValueKey<String>('kalimat-next'); }`
  - `awal` = id kalimat dari `?kalimat=bola`; tidak dikenal/kosong → kalimat pertama.
  - Tata letak: bilah atas; pil mode "Baca"/"Tebak gambar" di (70,120); pil penghitung "{index + 1} / {total}" di kanan atas 70/120; kartu 1040 × 380 di (70,190) radius 48 berisi lingkaran 300 + gambar 260 (atau `?` 150 saat tebak), label `kalimatIns` di (380,40), deretan `KalimatWord` yang membungkus di (380,82) lebar 620, dan baris bawah di (380, bottom 34) berisi tombol `kalimatRead` 70 (`#E0661A`, `GameGlyph.play`) + tombol bulat sebelumnya/berikutnya 70 (`#FFF1E6`); mode tebak menampilkan label `kalimatWhich` 230 pt + tiga `AnswerCard(width: 240, height: 180, illustrationSize: 140)` di (70,606); mode baca menampilkan gelembung `kalimatReadTip` di (200,640) dengan Moci 70.
  - Perilaku: saat dibuka dan setiap kali kalimat berganti, `setLastActivity(Routes.kalimat, {'kalimat': id})` lalu `sayAll([ui kalimatIns, kalimat_<id>])`; pergantian lewat panah hanya membacakan `kalimat_<id>`. "Baca bersama" menghentikan karaoke sebelumnya, menyalakan kata pertama, memutar `kalimat_<id>`, lalu menjalankan `Ticker` yang menghitung `indeksKata` dari `waktuMulaiKata`; saat `berlalu >= totalKata`, ticker berhenti dan sorotan dikosongkan. Mengetuk kata menghentikan karaoke, menyorot kata itu, dan `say(NarrationLine(jenis: 'kata', id: <kata tanpa tanda baca huruf kecil>, text: <kata tanpa tanda baca>))`. Mode tebak memakai `pilihanGambar` sekali per kalimat/bahasa; jawaban benar → `playSfx(Sfx.benar)` + `sayAll([ui kalimatYes, kalimat_<id>])` + gambar besar terbuka; jawaban salah → `playSfx(Sfx.salahLembut)` + `say([ui kalimatNo])` + kartu salah, lalu bisa dicoba lagi. Ganti bahasa menghentikan karaoke dan narasi, memuat teks/waktu/pilihan baru, dan membacakan kalimat dalam bahasa baru. Tidak ada `markItem` dan tidak ada Hebat.
  - `GoRoute` `/membaca/kalimat` membaca `state.uri.queryParameters['kalimat']` sebagai `awal`; `_soon(Routes.kalimat, …)` dihapus.
  - ARB baru (ID / EN): `kalimatIns` "Ketuk kata untuk mendengarnya" / "Tap a word to hear it" (`"description": "narasi"`); `kalimatRead` "Baca bersama" / "Read with me"; `kalimatPrev` "Kalimat sebelumnya" / "Previous sentence"; `kalimatNext` "Kalimat berikutnya" / "Next sentence"; `kalimatWhich` "Gambar mana yang cocok?" / "Which picture matches?"; `kalimatReadMode` "Baca" / "Read"; `kalimatQuizMode` "Tebak gambar" / "Guess the picture"; `kalimatReadTip` "Ketuk \"Baca bersama\" lalu ikuti kata yang menyala!" / "Tap \"Read with me\" and follow the words as they light up!"; `kalimatYes` "Betul! Pintar sekali!" / "Yes! That is right!" (`"description": "narasi"`); `kalimatNo` "Bukan yang itu. Coba lagi!" / "Not that one. Try again!" (`"description": "narasi"`); `kalimatPicture` "Gambar kalimat" / "Sentence picture".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/routes.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/membaca/kalimat/kalimat_screen.dart';
import 'package:moci/features/membaca/kalimat/kalimat_word.dart';
import 'package:moci/widgets/game/answer_card.dart';

import '../../helpers/harness.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

void main() {
  testWidgets('membuka: kalimat pertama dan kata pertama menyala', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('Ini'), findsOneWidget);
    expect(find.text('bola.'), findsOneWidget);
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(0))).sorot, isTrue);
    expect(env.tts.spoken.map((e) => e.$1), ['Ketuk kata untuk mendengarnya', 'Ini bola.']);
  });
  testWidgets('baca bersama menyalakan kata mengikuti waktu', (t) async {
    await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.bacaKey));
    await t.pump();
    await t.pump(const Duration(milliseconds: 700));
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot, isTrue);
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(0))).sorot, isFalse);
    await t.pump(const Duration(milliseconds: 900));
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot, isFalse);
  });
  testWidgets('mengetuk kata membacakan kata itu', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    env.tts.spoken.clear();
    await t.tap(find.byKey(KalimatScreen.kataKey(1)));
    await t.pump();
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot, isTrue);
    expect(env.tts.spoken.single.$1, 'bola');
  });
  testWidgets('kalimat berikutnya mengganti teks dan mencatat', (t) async {
    await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.nextKey));
    await t.pump();
    await t.pump();
    expect(find.text('2 / 18'), findsOneWidget);
    expect(find.text('Kucing'), findsOneWidget);
    expect(find.text('tidur.'), findsOneWidget);
  });
  testWidgets('kalimat tak dikenal kembali ke kalimat pertama', (t) async {
    await pumpApp(t, initialLocation: '${Routes.kalimat}?kalimat=tidak-ada');
    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('Ini'), findsOneWidget);
  });
  testWidgets('tebak gambar: salah lalu benar', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    await t.tap(find.text('Tebak gambar'));
    await t.pump();
    expect(find.byType(AnswerCard), findsNWidgets(3));
    expect(find.byKey(KalimatScreen.gambarBesarKey), findsNothing);
    final salah = t.widgetList<AnswerCard>(find.byType(AnswerCard))
        .firstWhere((c) => c.illustration != 'bola');
    await t.tap(find.byWidget(salah));
    await t.pump();
    expect(find.byKey(AnswerCard.badgeKey), findsNothing);
    expect(env.tts.spoken.last.$1, 'Bukan yang itu. Coba lagi!');
    await t.pump(const Duration(milliseconds: 450));
    final benar = t.widgetList<AnswerCard>(find.byType(AnswerCard))
        .firstWhere((c) => c.illustration == 'bola');
    await t.tap(find.byWidget(benar));
    await t.pump();
    await t.pump();
    expect(find.byKey(AnswerCard.badgeKey), findsOneWidget);
    expect(find.byKey(KalimatScreen.gambarBesarKey), findsOneWidget);
    expect(env.tts.spoken.last.$1, 'Ini bola.');
  });
  testWidgets('ganti bahasa saat karaoke menghentikan sorotan', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.bacaKey));
    await t.pump(const Duration(milliseconds: 700));
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    await t.pump();
    expect(find.text('This'), findsOneWidget);
    expect(env.tts.spoken.last.$2, AppLang.en);
    await t.pump(const Duration(milliseconds: 400));
    expect(t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot, isFalse);
  });
  testWidgets('kalimat panjang EN tidak overflow', (t) async {
    await pumpApp(t, initialLocation: '${Routes.kalimat}?kalimat=gajah');
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text('trunk.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.text('Suku Kata'));
    await t.pump();
    expect(router.routerDelegate.currentConfiguration.last.matchedLocation, Routes.sukuKata);
  });
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/membaca/kalimat_screen_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`, layar belum ada).

- [ ] **Step 3: Implementasikan layar dan kata.** Salin teks dari `Kalimat.dc.html` baris 166–168. Tambah kunci ARB + metadata, `fvm flutter gen-l10n`, lalu ganti `_soon(Routes.kalimat, …)`. Pakai `TickerProviderStateMixin`; batalkan ticker di `dispose`, saat kata diketuk, saat mode/kalimat/bahasa berganti. Jangan pernah memakai `Timer.periodic` untuk karaoke. Pilihan gambar dihitung sekali per kalimat/bahasa dan disimpan di state supaya tidak berubah saat rebuild.

- [ ] **Step 4: Jalankan tes fokus.** Run: `fvm flutter test test/features/membaca`. Expected: PASS.

- [ ] **Step 5: Pemeriksaan akhir.** Run:
```bash
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm dart run tool/validate_content.dart
```
Expected: semua tes PASS (termasuk golden Beranda dan Hebat); analyze dan format bersih; validator keluar dengan kode 0 dan hanya peringatan rekaman yang belum ada (`narasi_lengkap`).

- [ ] **Step 6: Commit** dengan pesan `feat(membaca): layar Kalimat dengan karaoke dan tebak gambar`.
