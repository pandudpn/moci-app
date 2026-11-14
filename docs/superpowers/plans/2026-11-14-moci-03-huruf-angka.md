# Moci — Rencana 03: Huruf & Angka — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lima layar pertama yang benar-benar dimainkan anak — Kenal Huruf, Tulis Huruf, Tulis Angka, Ucapkan, dan Berhitung — beserta mesin tracing, pengenalan ucapan di perangkat, dan komponen permainan bersama yang dipakai Rencana 04–07.

**Architecture:**
- Aturan tracing ditulis sebagai Dart murni di `lib/features/tulis/tracing_engine.dart` (sampel path, koridor jari, aturan maju saja), lalu digambar `CustomPainter` di `lib/features/tulis/tulis_board.dart`. Layar Tulis Huruf dan Tulis Angka memakai satu `TulisScreen` dengan `TulisMode`, sama seperti prototipe memakai satu artboard `Tulis.dc.html`.
- Komponen permainan bersama tinggal di `lib/widgets/game/` dan tidak tahu apa pun tentang isi: pil mode, kotak instruksi, kartu jawaban, titik kemajuan, dan tombol mikrofon menerima label serta callback dari layarnya.
- Ucapkan memakai `speech_to_text` hanya dalam mode `onDevice`, di balik antarmuka `SpeechEngine` supaya layarnya bisa dites tanpa plugin. Kalau pengenalan offline tidak tersedia, layar memakai pengukur level suara milik sendiri (kanal `moci/mic_level`), bukan pengenalan daring.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart 3, `speech_to_text` 7.5, `CustomPainter`, Riverpod 3, `go_router` 18, gen-l10n.

**Spec:**
- `docs/PRD.md` (Fitur per menu), `docs/TECH-SPEC.md` (Mesin tracing, Mikrofon di menu Ucapkan), `docs/DESIGN-SYSTEM.md`, `docs/CONTENT-ASSETS.md`, `docs/PRIVACY-RELEASE.md` (izin mikrofon).
- Prototipe: `docs/design/prototype/Huruf.dc.html`, `Tulis.dc.html`, `Angka.dc.html`, `Ucapkan.dc.html`, dan `Cocokkan.dc.html` (bentuk kartu jawaban). Teks UI disalin persis dari objek `T` tiap artboard.
- Peta rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md` (baris 03).

**Bergantung pada Rencana 01 dan 02:**
- 01: `MociStage` dan D12, tema per menu, `MociTopBar`, `MociBackButton`, `MociPressable`, `MociButton`, `MociDialog`, `StarCounter`, `Narrator`, `AudioService`, `Sfx`, `prefsProvider` (`LetterMode`, `lang`, `music`, `sfx`), `progressProvider` (`lastActivity`, `markItem`), Gerbang, `continueLabels`, harness tes.
- 02: `Katalog` (`huruf`, `angka.benda`, `ucapkan`), `HurufEntry`, `UcapkanEntry`, `TracingSet`, `angkaKata`, `ContentRepository.loadTracing`, `tools/validate_content.dart`.

## Global Constraints

- Flutter **3.50.0** lewat FVM. Semua perintah memakai `fvm flutter …` / `fvm dart …`.
- Paket pihak ketiga baru hanya **`speech_to_text` 7.5** (sudah dijanjikan di Global Constraints Rencana 01). Tidak ada paket lain, tidak ada analytics, crash reporting, atau ikon dari paket luar.
- Material diimpor dari `package:material_ui/material_ui.dart`; file yang hanya butuh lapisan widget memakai `package:flutter/widgets.dart`.
- **Izin perangkat:** Android rilis hanya menambah `RECORD_AUDIO`, blok `<queries>` untuk `android.speech.RecognitionService`, dan blok `<queries>` untuk `TTS_SERVICE` yang pindah dari manifest debug/profile ke manifest utama. INTERNET dan Bluetooth tidak boleh ada di manifest rilis; kalau manifest plugin menyuntikkan INTERNET, baris itu dibuang dengan `tools:node="remove"`. iOS hanya menambah `NSMicrophoneUsageDescription` dan `NSSpeechRecognitionUsageDescription`.
- **Mikrofon hanya untuk Ucapkan**, dan permintaan izinnya selalu didahului Gerbang Orang Tua. Suara tidak ditulis ke berkas dan tidak dikirim ke mana pun; `speech_to_text` selalu dipanggil dengan `onDevice: true` dan tidak pernah tanpa itu.
- **Narasi:** rekaman belum ada sampai Rencana 09, jadi TTS perangkat dipakai di **semua mode build**. `Narrator` memakai berkas `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a` kalau ada, dan TTS kalau tidak. Id baris narasi harus sama dengan nama di `lib/core/content/narasi.dart`: `fonik_<huruf>`, `huruf_<huruf>`, `contoh_<huruf>`, `angka_<n>`, `nama_<id>`, `suku_<suku>`, dan `ui_<kunciArb>` untuk kunci ARB bertanda `"description": "narasi"`. Validator `--rilis` tidak dipakai sebagai gerbang build sideload.
- **Layout:** setiap layar adalah `MociStage` dengan builder `tablet` berukuran 1180 × 820. HP memakai desain tablet yang diperkecil (D12) sampai Rencana 08; tidak ada builder `phone` di rencana ini.
- Target sentuh **64 pt** tablet, jarak **16 pt**, margin tepi **32 pt**. Kontras teks minimal **4,5 : 1**. Tekan: turun **5 pt**, skala **0,97**, **120 ms**. Muncul: **400–550 ms**, kurva `Cubic(0.3, 1.6, 0.5, 1)`. Saat `MediaQuery.disableAnimations` aktif, animasi hiasan berhenti, tetapi umpan balik benar/salah tetap muncul.
- **Tracing 60 fps:** mesin tracing bekerja pada sampel berjarak **4 unit** di kotak **520 × 520**; koridor jari **44 unit**; lompatan maju maksimal **40 unit**; radius mulai **74 unit**; goresan selesai di **97%** panjang path; kemajuan hanya maju. Kanvas berada di dalam `RepaintBoundary` dan tidak membangun ulang widget saat jari bergerak.
- **Dua bahasa setara:** semua teks lewat gen-l10n, dan bahasa bisa berganti saat layar terbuka tanpa memulai ulang aplikasi. Teks dari artboard disalin persis; kunci bernama `<layar><KunciT>` (contoh `hurufTapHint`, `tulisWriteAgain`), dan kunci turunan diberi akhiran yang menyebut bedanya (`tulisSayStartHuruf`).
- Teks permainan tidak mengikuti ukuran teks sistem (`textScaleCap` 1,0).
- Tidak ada unduhan saat aplikasi berjalan. Semua data dari `assets/content/` dan `assets/tracing/`.
- Progres: id modul mengikuti `RingkasanModul` (`huruf`, `angka`). Setiap layar mencatat `setLastActivity` saat item pertama dipilih dan `markItem` saat item benar-benar dikerjakan.
- **Lanjutkan:** `BerandaScreen._resume` membuka `route?param`. Setiap layar menerima `awal` dari query: `TulisScreen` dari `huruf`/`angka`, `HurufScreen` dari `huruf`, `BerhitungScreen` dari `angka`, `UcapkanScreen` dari `kata`. Nilai yang tidak dikenal diabaikan (kembali ke pilihan bawaan). Layar mencatat `setLastActivity` saat dibuka, bukan hanya saat item diganti.
- Efek suara hanya dari enum `Sfx` (`klik`, `benar`, `salahLembut`, `sorak`, `bintang`). Tidak ada buzzer.
- Tidak ada `TODO`, placeholder, atau teks Inggris hardcoded di widget.

## Review Focus

1. **Jari mulai jauh dari titik pandu, atau menggeser ke samping menjauhi jalur.** Kemajuan tidak boleh melompat, mundur, atau memotong jalur; goresan hanya selesai setelah 97% path. Dipatok di Task 3 (`gerak mundur dan lompatan jauh ditolak`) dan Task 4 (`mulai jauh dari titik pandu tidak memajukan goresan`).
2. **Anak mengetuk bertubi-tubi, berganti huruf di tengah goresan, atau menekan "Lanjut" dua kali.** Goresan harus mulai ulang di huruf baru, narasi tidak menumpuk, dan `markItem` tidak dobel. Dipatok di Task 5 (`kunci baru mengulang goresan dan mencatat sekali`) dan Task 8 (`hitung bareng berhenti saat angka berganti`).
3. **Izin mikrofon ditolak, atau perangkat tidak punya pengenalan offline untuk bahasa itu.** Ucapkan tetap bisa dimainkan (dengar dan tiru atau pengukur level suara), tidak pernah memakai pengenalan daring, dan tidak melempar galat. Dipatok di Task 9 (`kataCocok`), Task 10 (`suaraCukup`), dan Task 11 (`izin ditolak`, `pengenalan tidak tersedia`).
4. **Bahasa diganti saat layar terbuka.** Teks, contoh kata huruf, kata bilangan, locale pengenalan, dan narasi harus ikut bahasa baru tanpa memulai ulang. Dipatok di Task 7 (`ganti bahasa mengganti kata contoh`) dan Task 8 (`ganti bahasa mengganti kata bilangan`).
5. **Isi yang panjang atau banyak:** angka `50` di Berhitung, kata EN `twenty-one` dan `Strawberry`, `0` di Tulis Angka, serta `Layang-layang` di Kenal Huruf. Tidak boleh ada overflow atau teks terpotong. Dipatok di Task 6 (`angka 0 punya jalur`) dan Task 8 (`50 benda dan kata panjang tidak overflow`).

## Keputusan rencana ini

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| H1 | TTS perangkat dipakai di semua mode build, dan `allowTts` dihapus dari `Narrator`. `NoopDevTts` dihapus, `DevTts` diganti nama menjadi `DeviceTts`. Blok `<queries>` `TTS_SERVICE` pindah ke manifest utama. | Rekaman belum ada sampai Rencana 09; aplikasi hanya disebar lewat sideload, jadi tidak ada build rilis yang harus bisu. |
| H2 | Setiap layar adalah `MociStage` tablet tanpa builder `phone`. | D12; layout HP didesain di Rencana 08. |
| H3 | Pil mode selalu menampilkan semua mode. Perpindahan mode memakai `pushReplacement`, jadi tombol kembali tetap menuju Beranda dan tidak menumpuk riwayat mode. | Prototipe memakai navigasi datar; tumpukan mode akan membingungkan anak. |
| H4 | Kenal Huruf selalu menampilkan kedua pil, "Bunyi /b/" dan "Nama: be". Ketukan pada huruf besar, tombol sebelumnya/berikutnya, dan "Dengarkan" mengikuti `prefs.letterMode`; pil satunya tetap bisa diketuk. | PRD meminta mode mengikuti pengaturan orang tua, prototipe menyediakan keduanya. |
| H5 | Angka tracing mengikuti spec: sampel 4 unit, koridor 44, lompatan maju 40, selesai di 97%, radius mulai 74 dari prototipe. Pujian per goresan hanya `Sfx.benar`; narasi pujian hanya di akhir huruf. | Spec bagian tracing; narasi tiap goresan akan memotong irama menulis. |
| H6 | Tulis Huruf dan Tulis Angka memakai satu `TulisScreen` dengan `TulisMode`. Bintang di kunci diambil dari `perkembangan[modul]['ditulis']`, bukan state sesi seperti prototipe. Krayon 5 warna dari prototipe. | Satu mesin, satu layar; bintang yang tersimpan lebih jujur daripada state yang hilang saat layar ditutup. |
| H7 | Berhitung mulai dari angka 1 (prototipe 23), memakai 12 `katalog.angka.benda`, dan tidak berakhir di Hebat. | Angka awal prototipe hanya contoh statis; Berhitung adalah jelajah bebas, bukan ronde (PRD: hanya permainan berakhir yang memakai Hebat). |
| H8 | Ucapkan: izin diminta lewat dialog "Panggil Ayah atau Bunda" yang mendorong Gerbang dan menunggu hasilnya; setelah gerbang lolos baru `SpeechEngine.prepare`. Giliran mendengar 4 detik. Cocok = teks setelah huruf kecil tanpa tanda baca sama dengan target, atau beda satu huruf untuk target 4 huruf ke atas. Dua percobaan, lalu tetap dipuji. Tidak ada Hebat. | PRD dan TECH-SPEC bagian mikrofon. |
| H9 | Kalau pengenalan offline tidak tersedia untuk bahasa itu, Ucapkan memakai pengukur level suara sendiri: suara dianggap ada kalau level di atas **0,12** selama **300 ms**. Tidak pernah memakai pengenalan daring. | TECH-SPEC butir 5; satu-satunya paket baru adalah `speech_to_text`, jadi pengukur dibuat sebagai kanal platform milik Moci. |
| H10 | Selama 4 detik mendengar, narasi dan musik dihentikan lewat `AudioService.pauseForListening()`, lalu `resumeAfterListening()` memulihkan musik kalau sakelarnya menyala. Sesi audio iOS dikembalikan ke playback setelah tiap giliran. | TECH-SPEC: mikrofon tidak boleh merekam narasi atau musik. |
| H11 | Progres: Kenal Huruf `huruf/dibaca`, Tulis `huruf|angka/ditulis`, Berhitung `angka/dihitung`. Ucapkan hanya mencatat `lastActivity`, tanpa `markItem`, karena id katanya bukan 26 huruf atau 50 angka dan akan melewati penyebut modul. | `RingkasanModul` menghitung item berbeda per modul terhadap total isi. |
| H12 | Kunci ARB baru mengikuti `<layar><KunciT>`. Teks yang digabung prototipe dari beberapa potongan (`sayStart` + `unit`) dipecah menjadi kunci utuh dengan akhiran (`tulisSayStartHuruf`), dan teks baru di luar prototipe memakai awalan layar yang sama. Hanya kunci yang benar-benar dibacakan diberi `"description": "narasi"`. | Rekaman butuh satu berkas per kalimat utuh, bukan potongan. |

## Peta file

```
lib/widgets/game/game_glyphs.dart              # ikon garis dari artboard (mata, pensil, mic, …)
lib/widgets/game/game_mode_pill.dart           # pil mode, presentational
lib/widgets/game/route_mode_pill.dart          # pil mode yang berpindah rute (pushReplacement)
lib/widgets/game/game_instruction.dart         # kotak instruksi + tombol dengar
lib/widgets/game/answer_card.dart              # kartu jawaban idle/benar/salah
lib/widgets/game/progress_dots.dart            # titik kemajuan
lib/widgets/game/mic_button.dart               # tombol mikrofon 180 pt
lib/features/tulis/tracing_engine.dart         # sampel path + aturan gerak (Dart murni)
lib/features/tulis/tracing_board.dart          # kanvas tracing 520 × 520 + gestur
lib/features/tulis/tulis_keys.dart             # kisi kunci dan krayon per mode
lib/features/tulis/tulis_screen.dart           # Tulis Huruf dan Tulis Angka
lib/features/huruf/huruf_screen.dart           # Kenal Huruf
lib/features/berhitung/berhitung_benda.dart    # jamak EN dan kisi hitung
lib/features/berhitung/berhitung_screen.dart   # Berhitung 1–50
lib/features/ucapkan/ucapkan_kata.dart         # kata Ucapkan + id benda dari gambar
lib/features/ucapkan/ucapkan_screen.dart       # Ucapkan
lib/core/speech/speech_engine.dart             # antarmuka SpeechEngine + kataCocok
lib/core/speech/speech_to_text_engine.dart     # adapter speech_to_text (onDevice saja)
lib/core/speech/mic_level_meter.dart           # antarmuka + suaraCukup
lib/core/speech/method_channel_mic_level_meter.dart
lib/core/audio/device_tts.dart                 # rename dari dev_tts.dart
android/app/src/main/AndroidManifest.xml       # RECORD_AUDIO, queries TTS + RecognitionService
android/app/src/main/kotlin/id/pandudpn/moci/MainActivity.kt   # kanal moci/mic_level
ios/Runner/MociChannels.swift                  # kanal moci/mic_level
ios/Runner/Info.plist                          # dua alasan izin
```

Komponen bersama di `lib/widgets/game/` adalah kontrak untuk Rencana 04–07: file dan nama tipe di task 1 dan 5 tidak boleh berubah setelah rencana ini selesai tanpa memperbarui rencana berikutnya.

---

### Task 1: Komponen permainan bersama

**Files:**
- Create: `lib/widgets/game/game_glyphs.dart`, `lib/widgets/game/game_mode_pill.dart`, `lib/widgets/game/game_instruction.dart`, `lib/widgets/game/answer_card.dart`, `lib/widgets/game/progress_dots.dart`, `lib/widgets/game/mic_button.dart`
- Test: `test/widgets/game/game_mode_pill_test.dart`, `test/widgets/game/game_instruction_test.dart`, `test/widgets/game/answer_card_test.dart`, `test/widgets/game/progress_dots_test.dart`, `test/widgets/game/mic_button_test.dart`

**Interfaces:**
- Consumes: `MociPressable`, `MociIllustration`, `MociText`, `MociColors`, `mociTheme`, `narratorProvider`, `prefsProvider`, `NarrationLine`, `AppLang`.
- Produces (dipakai Rencana 04–07):
  - `enum GameGlyphKind { eye, pencil, mic, count, listen, play, check, refresh, next, star }` dan `class GameGlyph extends StatelessWidget { const GameGlyph(this.kind, {super.key, this.size = 26, this.color = MociColors.ink}); }`. Path diambil dari artboard (`viewBox 0 0 24 24`, bintang 40 × 40 yang diskalakan); ikon di luar semantik.
  - `class GameModeTab { const GameModeTab({required this.label, this.icon}); final String label; final Widget? icon; }`
  - `class GameModePill extends StatelessWidget` dengan `tabs`, `selected` (indeks), `onSelected`, `semanticLabel`, `accent`; tinggi tab 56, kontainer putih radius 999 dengan padding 6 dan bayangan 6 dari tema. Tab aktif: latar `accent`, teks putih. Tab lain: latar transparan, teks `MociColors.ink`.
  - `class GameInstruction extends ConsumerWidget` dengan `title`, `text`, `semanticLabel`, `narration` (`List<NarrationLine>`, bawaan kosong), `listenLabel`, `titleColor`. Tombol dengar bulat 60 warna `#FFB020` hanya muncul kalau `narration` tidak kosong, dan memanggil `Narrator.sayAll(narration, prefs.lang)`. `static const listenKey = ValueKey('game-instruction-listen');`
  - `enum AnswerCardState { idle, correct, wrong }` dan `class AnswerCard extends StatelessWidget` dengan `semanticLabel`, `onTap`, `illustration`, `text`, `child`, `state`, `width` (300), `height` (340), `illustrationSize` (210), `accent`. Putih, radius 42, border 8, bayangan 12: `correct` hijau + lencana centang, `wrong` salmon. `static const badgeKey = ValueKey('answer-card-badge');`
  - `class ProgressDots extends StatelessWidget` dengan `count`, `current` (0-based), `semanticLabel`, `dotSize` (12), `activeWidth` (30), `activeColor`. Titik yang sudah lewat hijau, titik aktif lebih lebar, sisanya `#F3C2B3`. `static ValueKey<String> dotKey(int i)`.
  - `enum MicPhase { idle, listening, good, off }` dan `class MicButton extends StatelessWidget` dengan `phase`, `onTap`, `semanticLabel`, `size` (180). `listening`: dua cincin berdenyut; `good`: centang putih di latar hijau; `off`: `onTap` null dan warna abu. `static const ringsKey = ValueKey('mic-rings');`

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('pil mode: tab aktif putih, tab lain tinta, pilihan diteruskan', (t) async {
  var picked = -1;
  await pumpScreen(t, GameModePill(
    tabs: const [GameModeTab(label: 'Kenali'), GameModeTab(label: 'Tulis'), GameModeTab(label: 'Ucapkan')],
    selected: 0, onSelected: (i) => picked = i, semanticLabel: 'Mode belajar', accent: const Color(0xFFE8384F)));
  expect(t.widget<Text>(find.text('Kenali')).style?.color, MociColors.white);
  expect(t.widget<Text>(find.text('Tulis')).style?.color, MociColors.ink);
  await t.tap(find.text('Ucapkan'));
  expect(picked, 2);
});
testWidgets('kotak instruksi membacakan baris narasi', (t) async {
  final env = TestEnv();
  await pumpScreen(t, GameInstruction(title: 'Hitung bareng', text: 'Ketuk benda satu per satu', semanticLabel: 'Instruksi',
    narration: const [NarrationLine(jenis: 'ui', id: 'angkaAutoSay', text: 'Hitung bareng')], listenLabel: 'Dengar instruksi'), env: env);
  await t.tap(find.byKey(GameInstruction.listenKey));
  expect(env.tts.spoken.single.$1, 'Hitung bareng');
});
testWidgets('tanpa narasi tidak ada tombol dengar', (t) async {
  await pumpScreen(t, const GameInstruction(title: 'A', text: 'B', semanticLabel: 'Instruksi'));
  expect(find.byKey(GameInstruction.listenKey), findsNothing);
});
testWidgets('kartu jawaban: gambar, label, ketukan, dan tanda benar', (t) async {
  var taps = 0;
  await pumpScreen(t, AnswerCard(illustration: 'apel', text: 'Apel', semanticLabel: 'Apel', onTap: () => taps++, state: AnswerCardState.correct));
  expect(find.byType(MociIllustration), findsOneWidget);
  expect(find.byKey(AnswerCard.badgeKey), findsOneWidget);
  await t.tap(find.text('Apel'));
  expect(taps, 1);
});
testWidgets('titik kemajuan: aktif lebih lebar, yang lewat hijau', (t) async {
  await pumpScreen(t, const ProgressDots(count: 5, current: 2, semanticLabel: 'Kemajuan'));
  expect(t.getSize(find.byKey(ProgressDots.dotKey(2))).width, 30);
  expect(t.getSize(find.byKey(ProgressDots.dotKey(1))).width, 12);
  expect((t.widget<DecoratedBox>(find.byKey(ProgressDots.dotKey(1))).decoration as BoxDecoration).color, MociColors.correct);
});
testWidgets('tombol mikrofon: dua cincin saat mendengar', (t) async {
  await pumpScreen(t, MicButton(phase: MicPhase.listening, onTap: () {}, semanticLabel: 'Moci mendengarkan'));
  expect(find.byKey(MicButton.ringsKey), findsNWidgets(2));
});
testWidgets('tombol mikrofon: centang saat berhasil', (t) async {
  await pumpScreen(t, MicButton(phase: MicPhase.good, onTap: () {}, semanticLabel: 'Bagus'));
  expect(find.byWidgetPredicate((w) => w is GameGlyph && w.kind == GameGlyphKind.check), findsOneWidget);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/widgets/game`. Expected: FAIL karena file belum ada.
- [ ] **Step 3: Implementasikan keenam file** sesuai Interfaces. Warna dan ukuran diambil dari artboard (`Huruf.dc.html` baris 40–56, `Cocokkan.dc.html` baris 64–100, `Ucapkan.dc.html` baris 66–131). Semua target memakai `MociPressable`; ikon dekoratif memakai `ExcludeSemantics`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/widgets/game`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(game): pil mode, kotak instruksi, kartu jawaban, titik kemajuan, tombol mikrofon`.

---

### Task 2: Narasi TTS di semua mode build

**Files:**
- Rename: `lib/core/audio/dev_tts.dart` → `lib/core/audio/device_tts.dart`
- Modify: `lib/core/audio/audio_providers.dart`, `lib/core/audio/narrator.dart`, `test/core/audio/narrator_test.dart`, `test/helpers/fake_audio.dart`, `test/helpers/harness.dart`, `test/app/moci_app_lifecycle_test.dart`, `integration_test/app_test.dart`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/debug/AndroidManifest.xml`, `android/app/src/profile/AndroidManifest.xml`
- Test: `test/core/audio/narrator_test.dart` (ubah), `test/platform/platform_config_test.dart` (buat)

**Interfaces:**
- Consumes: `AudioService`, `AssetCatalog`, `AppLang`.
- Produces:
  - `abstract interface class DeviceTts { Future<void> speak(String text, AppLang lang); Future<void> stop(); }`, `MethodChannelDeviceTts`, dan `NoopDevTts` dihapus.
  - `final deviceTtsProvider = Provider<DeviceTts>((_) => const MethodChannelDeviceTts());` tanpa cabang `kReleaseMode`.
  - `Narrator({required AudioService audio, required AssetCatalog assets, required DeviceTts tts})`; `say` dan `sayAll` selalu memakai TTS saat rekaman tidak ada.
  - `test/helpers/fake_audio.dart`: `FakeDevTts` → `FakeDeviceTts` (perilaku sama: `spoken`, `stopCount`).

- [ ] **Step 1: Tulis tes yang gagal**

`test/core/audio/narrator_test.dart` (ganti tes `allowTts` yang ada):
```dart
test('tanpa rekaman, TTS perangkat dipakai', () async {
  final n = build(const {});
  await n.say(_kucing, AppLang.en);
  expect(tts.spoken.single.$1, 'Cat');
});
test('rekaman ada: diputar dan TTS tidak dipanggil', () async {
  final n = build({'assets/audio/vo/en/nama_kucing.m4a'});
  await n.say(_kucing, AppLang.en);
  expect(tts.spoken, isEmpty);
});
test('sayAll membacakan semua baris berurutan', () async {
  final n = build(const {});
  await n.sayAll(const [
    NarrationLine(jenis: 'fonik', id: 'b', text: 'beh'),
    NarrationLine(jenis: 'contoh', id: 'b', text: 'Bola'),
  ], AppLang.id);
  expect(tts.spoken.map((e) => e.$1), ['beh', 'Bola']);
});
```
`test/platform/platform_config_test.dart`:
```dart
test('manifest utama memuat queries TTS untuk build rilis', () {
  final xml = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  expect(xml, contains('android.intent.action.TTS_SERVICE'));
  expect(xml, isNot(contains('android.permission.INTERNET')));
});
test('manifest debug dan profile tidak lagi mendeklarasikan TTS', () {
  for (final f in ['android/app/src/debug/AndroidManifest.xml', 'android/app/src/profile/AndroidManifest.xml']) {
    expect(File(f).readAsStringSync(), isNot(contains('TTS_SERVICE')));
  }
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/audio test/platform`. Expected: FAIL (`allowTts` masih wajib, manifest utama belum punya TTS).
- [ ] **Step 3: Implementasikan rename dan pindahkan blok `<queries>` TTS.** Ganti semua rujukan `DevTts`, `MethodChannelDevTts`, `NoopDevTts`, `devTtsProvider`, `FakeDevTts`, dan parameter `allowTts` di `lib`, `test`, dan `integration_test` (termasuk komentar native yang menyebut "TTS dev"). Native `moci/tts` tidak berubah.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/core/audio test/platform test/app/moci_app_lifecycle_test.dart`. Expected: PASS.
- [ ] **Step 5: Cek di perangkat.** Run: `fvm flutter run --release -d emulator-5554`, buka Gerbang sampai mendengar narasi. Expected: kalimat gerbang terdengar dari TTS tanpa rekaman. Ulangi di iPad fisik dengan `--release`; simulator iOS tidak mendukung mode release.
- [ ] **Step 6: Commit** dengan pesan `feat(audio): TTS perangkat untuk semua mode build, queries TTS di manifest utama`.

---

### Task 3: Mesin tracing

**Files:**
- Create: `lib/features/tulis/tracing_engine.dart`, `test/features/tulis/tracing_engine_test.dart`

**Interfaces:**
- Consumes: `dart:ui` (`Offset`, `Path`, `PathMetric`).
- Produces (dipakai Task 4–6):
  - `const jarakSampelBawaan = 4.0;` `const toleransiJalur = 44.0;` `const lompatanMaju = 40.0;` `const radiusMulai = 74.0;` `const selesaiPada = 0.97;`
  - `final class TracePoint { const TracePoint({required this.x, required this.y, required this.jarak}); final double x, y, jarak; Offset get offset; }` — `jarak` adalah jarak kumulatif dari awal goresan.
  - `final class TraceStroke { const TraceStroke({required this.path, required this.points, required this.length}); factory TraceStroke.fromSvgPath(String d); final String path; final List<TracePoint> points; final double length; int get terakhir; }`
  - `final class TraceGuide { const TraceGuide(this.strokes); factory TraceGuide.fromPaths(List<String> paths); final List<TraceStroke> strokes; bool get kosong; }` — path kosong dilewati.
  - `enum TraceStep { tetap, maju, goresanSelesai, selesai }`
  - `final class TracingSession { TracingSession(this.guide); final TraceGuide guide; int get goresan; int get titik; bool get selesai; double get kemajuan; Offset get pandu; bool mulai(Offset p); TraceStep gerak(Offset p); void ulang(); }`
  - `fromSvgPath` membangun `Path` dari perintah `M L H V C` absolut (persis yang diloloskan validator), lalu menyampel `computeMetrics().first` tiap 4 unit, termasuk titik awal dan titik akhir.

Aturan `mulai`: benar kalau jarak ke `pandu` ≤ `radiusMulai`. Aturan `gerak`: hanya titik di depan `titik` yang jarak kumulatifnya ≤ `jarak sekarang + lompatanMaju`; di antara itu ambil yang terjauh dengan jarak Euclidean ke jari ≤ `toleransiJalur`; kalau tidak ada, `tetap`. Kalau kemajuan titik terpilih ≥ `selesaiPada`, kembalikan `goresanSelesai` (dan `selesai` untuk goresan terakhir).

- [ ] **Step 1: Tulis tes yang gagal**

```dart
test('garis lurus disampel tiap 4 unit', () {
  final s = TraceStroke.fromSvgPath('M0 0L100 0');
  expect(s.points.length, 26);
  expect(s.points[1].jarak, 4);
  expect(s.length, 100);
});
test('perintah H dan V ikut dibaca', () {
  final s = TraceStroke.fromSvgPath('M0 0L40 0H80V40');
  expect(s.length, 120);
  expect(s.points.last.offset, const Offset(80, 40));
});
test('kurva C disampel halus', () {
  final s = TraceStroke.fromSvgPath('M0 0C0 60 100 60 100 0');
  expect(s.points.length, greaterThan(30));
  expect(s.length, inInclusiveRange(90, 150));
});
test('mulai hanya di dekat titik pandu', () {
  final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']));
  expect(sesi.mulai(const Offset(80, 0)), isFalse);
  expect(sesi.mulai(const Offset(10, 0)), isTrue);
});
test('gerak mundur dan lompatan jauh ditolak', () {
  final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))..mulai(const Offset(0, 0));
  expect(sesi.gerak(const Offset(-20, 0)), TraceStep.tetap);
  expect(sesi.gerak(const Offset(500, 200)), TraceStep.tetap);
  expect(sesi.titik, 0);
});
test('kemajuan mengikuti jari tapi tidak melewati 40 unit', () {
  final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))..mulai(const Offset(0, 0));
  expect(sesi.gerak(const Offset(60, 0)), TraceStep.maju);
  expect(sesi.titik, 10);
  expect(sesi.kemajuan, closeTo(0.4, 0.001));
});
test('goresan selesai di 97% lalu pindah ke goresan berikutnya', () {
  final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0', 'M0 100L100 100']))..mulai(const Offset(0, 0));
  var step = TraceStep.tetap;
  for (var x = 20; x <= 100 && sesi.goresan == 0; x += 20) {
    final s = sesi.gerak(Offset(x.toDouble(), 0));
    if (s != TraceStep.tetap) step = s;
  }
  expect(step, TraceStep.goresanSelesai);
  expect(sesi.goresan, 1);
  expect(sesi.titik, 0);
  expect(sesi.mulai(const Offset(0, 100)), isTrue);
  for (var x = 20; x <= 100 && !sesi.selesai; x += 20) {
    final s = sesi.gerak(Offset(x.toDouble(), 100));
    if (s != TraceStep.tetap) step = s;
  }
  expect(step, TraceStep.selesai);
  expect(sesi.selesai, isTrue);
});
test('ulang mengembalikan ke goresan pertama', () {
  final sesi = TracingSession(TraceGuide.fromPaths(const ['M0 0L100 0']))
    ..mulai(const Offset(0, 0))
    ..gerak(const Offset(60, 0));
  sesi.ulang();
  expect((sesi.goresan, sesi.titik, sesi.selesai), (0, 0, false));
  expect(sesi.mulai(const Offset(0, 0)), isTrue);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/tulis/tracing_engine_test.dart`. Expected: FAIL karena file belum ada.
- [ ] **Step 3: Implementasikan mesin** sesuai Interfaces. Jangan mengimpor Flutter di file ini; cukup `dart:ui`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/tulis/tracing_engine_test.dart`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(tulis): mesin tracing sampel 4 unit, koridor 44, maju saja`.

---

### Task 4: Papan tracing

**Files:**
- Create: `lib/features/tulis/tracing_board.dart`, `test/features/tulis/tracing_board_test.dart`

**Interfaces:**
- Consumes: `TracingSession`, `TraceGuide`, `Sfx` (`benar`), `MociMascot`, `MociColors`.
- Produces:
  - `class TracingBoard extends StatefulWidget { const TracingBoard({super.key, required this.paths, required this.ink, required this.semanticLabel, this.onStrokeDone, this.onDone, this.onWrongStart, this.onProgress}); }` dengan `paths: List<String>`, `ink: Color`, `onStrokeDone: ValueChanged<int>?` (indeks goresan), `onDone: VoidCallback?`, `onWrongStart: VoidCallback?`, `onProgress: void Function(int goresan, int total)?`.
  - `static const surfaceKey = ValueKey('tracing-surface');` pada kotak 520 × 520 yang menerima gestur.
  - Menggambar lapisan berikut di satu `CustomPainter` di dalam `RepaintBoundary`: kertas `#FFFDFB` radius 20, garis bantu biru di y 70 dan 450, garis tengah putus-putus `#FFC9BD`, jalur bayangan 66 `#ECE7F8`, goresan selesai 60 warna `ink` ditimpa bintang putih 55%, goresan aktif 66 `#4C3F86` dengan dash kuning `#FFD43B`, nomor goresan berikutnya, panah kuning tiap 58 unit, bintang tujuan di ujung goresan. Moci 86 px diletakkan di `pandu` dengan cincin hijau saat diam; ledakan cincin+bintang 900 ms di ujung goresan yang selesai.
  - Gestur: `Listener` `onPointerDown/Move/Up/Cancel` dengan `behavior: HitTestBehavior.opaque`; awal yang jauh memanggil `onWrongStart` dan menggoyang Moci 450 ms (tanpa animasi saat `disableAnimations`). `onProgress` dipanggil tiap kali goresan berganti dan sekali saat `initState`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
Future<void> _trace(WidgetTester t, Offset a, Offset b) async {
  final r = t.getRect(find.byKey(TracingBoard.surfaceKey));
  Offset p(Offset v) => Offset(r.left + v.dx * r.width / 520, r.top + v.dy * r.height / 520);
  final g = await t.startGesture(p(a));
  for (var i = 1; i <= 20; i++) {
    await g.moveTo(p(Offset.lerp(a, b, i / 20)!));
    await t.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await t.pump(const Duration(milliseconds: 100));
}
testWidgets('mengikuti jalur menyelesaikan goresan', (t) async {
  var done = 0, strokes = 0, wrong = 0;
  await pumpScreen(t, Center(child: SizedBox(width: 520, height: 520, child: TracingBoard(
    paths: const ['M0 0L100 0'], ink: const Color(0xFFE8384F), semanticLabel: 'Area menulis huruf A',
    onStrokeDone: (_) => strokes++, onDone: () => done++, onWrongStart: () => wrong++))));
  await _trace(t, Offset.zero, const Offset(100, 0));
  expect((strokes, done, wrong), (1, 1, 0));
});
testWidgets('mulai jauh dari titik pandu tidak memajukan goresan', (t) async {
  var done = 0, wrong = 0;
  await pumpScreen(t, Center(child: SizedBox(width: 520, height: 520, child: TracingBoard(
    paths: const ['M0 0L100 0'], ink: const Color(0xFFE8384F), semanticLabel: 'Area menulis',
    onDone: () => done++, onWrongStart: () => wrong++))));
  await _trace(t, const Offset(400, 400), const Offset(400, 200));
  expect((wrong, done), (1, 0));
});
testWidgets('kunci baru mengulang dari goresan pertama', (t) async {
  var progress = <int>[];
  Widget board(String key) => Center(child: SizedBox(width: 520, height: 520, child: TracingBoard(
    key: ValueKey(key), paths: const ['M0 0L100 0'], ink: const Color(0xFFE8384F),
    semanticLabel: 'Area menulis', onProgress: (i, _) => progress.add(i))));
  await pumpScreen(t, board('a'));
  await _trace(t, Offset.zero, const Offset(100, 0));
  expect(progress.last, 0); // guide satu goresan: tidak ada goresan berikutnya yang dilaporkan
  await pumpScreen(t, board('b'));
  expect(progress.sublist(progress.length - 2), [0, 0]);
  expect(t.takeException(), isNull);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/tulis/tracing_board_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implementasikan papan dan painter.** Simpan hanya `TracingSession`, `drag`, `burst`, dan `nudge` di state; jangan membangun ulang anak-anak lain saat jari bergerak. Tampilan statis saat `MediaQuery.disableAnimations` (tanpa denyut, goyang, atau dash berjalan).
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/tulis`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(tulis): papan tracing 520 dengan panah, bintang, dan panduan Moci`.

---

### Task 5: Layar Tulis Huruf

**Files:**
- Create: `lib/features/tulis/tulis_keys.dart`, `lib/features/tulis/tulis_screen.dart`, `lib/widgets/game/route_mode_pill.dart`, `test/features/tulis/tulis_huruf_test.dart`, `test/widgets/game/route_mode_pill_test.dart`
- Modify: `lib/core/content/content_repository.dart` (provider tracing), `lib/main.dart` (muat dua `TracingSet`), `test/helpers/harness.dart` (override tracing), `lib/app/router.dart` (rute `/huruf/tulis`), `lib/features/beranda/continue_labels.dart`, `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `tracingHurufProvider`, `Katalog.huruf`, `TracingBoard`, `GameModePill` (lewat `RouteModePill`), `MociTopBar`, `MociBackButton`, `StarCounter`, `Narrator`, `Sfx`, `progressProvider`, `prefsProvider`.
- Produces:
  - `final tracingHurufProvider = Provider<TracingSet>((_) => throw UnimplementedError('override di runMoci'));` dan `tracingAngkaProvider` yang sama. `runMoci` mengisinya dengan `ContentRepository.loadTracing(rootBundle, angka: false/true)`.
  - `enum TulisMode { huruf, angka }` dan `class TulisScreen extends ConsumerStatefulWidget { const TulisScreen({super.key, this.mode = TulisMode.huruf, this.awal}); static ValueKey<String> keyKey(String k); }` (`awal` = kunci pertama, bawaan `A`). Kartu Lanjutkan membuka `/huruf/tulis?huruf=Z`: `GoRoute` membaca `state.uri.queryParameters['huruf']` dan meneruskannya sebagai `awal`; nilai di luar A–Z diabaikan. Kunci `awal` dicatat `setLastActivity` saat layar dibuka.
  - `class TulisKeySpec { const TulisKeySpec({required this.keys, required this.columns, required this.keyHeight, required this.fontSize}); static TulisKeySpec of(TulisMode mode); }` — huruf: 26 kunci `A`–`Z`, 4 kolom, tinggi 50, font 26; angka (Task 6): 10 kunci `0`–`9`, 2 kolom, tinggi 74, font 40.
  - `const tulisCrayons = <Color>[Color(0xFFFF5C8A), Color(0xFF3BA4FF), Color(0xFF51CF66), Color(0xFFFFB020), Color(0xFF9775FA)];`
  - `class RouteModePill extends ConsumerWidget { const RouteModePill({super.key, required this.tabs, required this.semanticLabel, required this.accent}); final List<({String label, String route, Widget? icon})> tabs; }` — tab aktif dari `currentPathProvider`, ketukan memakai `context.pushReplacement(route)`.
  - `TulisScreen` menampilkan `MociStage(theme: MenuTheme.huruf, tablet: …)`: bilah atas (kembali, `hurufTitle`, `RouteModePill` Kenali/Tulis/Ucapkan, `StarCounter`), kartu kiri 236 × 650 berisi kisi kunci + petunjuk `tulisFollow`, kartu tengah 600 × 650 berisi judul "Tulis <huruf>", `tulisLine <n> tulisOf <total>`, papan 520 (diskalakan 1,0385) dan bilah selesai 552 × 112, kartu kanan 236 × 650 berisi 5 krayon, `tulisAgain`, `tulisListen`. Bintang kecil di kunci yang ada di `perkembangan['huruf']['ditulis']`.
  - Narasi: saat layar dibuka dan saat kunci dipilih, `sayAll([ui tulisSayStartHuruf, huruf_<k>])`; tombol dengar `sayAll([tulisSayStartHuruf, huruf_<k>, ui tulisHint])`; goresan selesai `Sfx.benar`; huruf selesai `sayAll([ui tulisSayDoneHuruf, huruf_<k>])` + `Sfx.sorak`. Kunci baru mengulang papan lewat `ValueKey('$k-$run')`, mencatat `setLastActivity(Routes.hurufTulis, {'huruf': k})`, dan menyelesaikan huruf mencatat `markItem('huruf', 'ditulis', k)`.
  - ARB baru (ID / EN): `hurufTitle` "Huruf" / "Letters"; `hurufLearn` "Kenali" / "Learn"; `hurufWrite` "Tulis" / "Write"; `hurufSay` "Ucapkan" / "Say"; `modeSemantic` "Mode belajar" / "Learning mode"; `tulisFollow` "Geser Moci ikuti panah kuning sampai ke bintang!" / "Drag Moci along the yellow arrows to the star!"; `tulisWriteVerb` "Tulis" / "Write"; `tulisLine` "Garis" / "Line"; `tulisOf` "dari" / "of"; `tulisDone` "Selesai!" / "All done!"; `tulisGreat` "Hebat!" / "Great job!"; `tulisNext` "Lanjut" / "Next"; `tulisCrayons` "Krayon" / "Crayons"; `tulisAgain` "Ulangi" / "Again"; `tulisListen` "Dengar" / "Listen"; `tulisArea` "Area menulis" / "Writing area"; `tulisWriteAgain` "Tulis lagi" / "Write again"; `tulisColor1` … `tulisColor5` ("Krayon merah muda/biru/hijau/oranye/ungu" / "Pink/Blue/Green/Orange/Purple crayon"); `tulisPickHuruf` "Pilih huruf" / "Pick a letter"; `tulisUnitHuruf` "huruf" / "the letter"; `tulisKeyLabel` "Tulis huruf {huruf}" / "Write the letter {huruf}"; `tulisAreaLabel` "Area menulis huruf {huruf}" / "Writing area for the letter {huruf}"; `tulisProgress` "{n} dari {total}" / "{n} of {total}"; `tulisSayStartHuruf` "Ayo tulis huruf" / "Let's write the letter" (narasi); `tulisSayDoneHuruf` "Hebat! Kamu bisa menulis huruf" / "Great job! You wrote the letter" (narasi); `tulisNice` "Bagus!" / "Nice!" (narasi); `tulisHint` "Geser Moci ikuti panah kuning sampai ke bintang." / "Drag Moci along the yellow arrows to the star." (narasi); `berandaContinueTulisHuruf` "Tulis huruf {huruf}" / "Write the letter {huruf}".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('layar tulis huruf: kunci, papan A, dan progres goresan', (t) async {
  await pumpApp(t, initialLocation: '/huruf/tulis');
  expect(find.text('Huruf'), findsOneWidget);
  expect(find.text('Tulis A'), findsOneWidget);
  expect(find.text('Garis 1 dari 3'), findsOneWidget);
  expect(find.byType(TracingBoard), findsOneWidget);
  expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths.length, 3);
});
testWidgets('menyelesaikan A memberi bilah Hebat dan mencatat sekali', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/huruf/tulis');
  await _traceA(t);
  expect(find.text('Hebat!'), findsOneWidget);
  expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
  await t.tap(find.text('Lanjut'));
  await t.pump();
  expect(find.text('Tulis B'), findsOneWidget);
  expect(find.text('Garis 1 dari 3'), findsOneWidget);
  expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
});
testWidgets('kunci baru mengulang goresan dan mencatat sekali', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/huruf/tulis');
  await _traceA(t);
  await t.tap(find.text('Lanjut'));
  await t.pump();
  await _traceA(t); // A tidak lagi terpilih: gerakan tidak memajukan B
  expect(find.text('Hebat!'), findsNothing);
  expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
});
testWidgets('krayon mengubah tinta papan', (t) async {
  await pumpApp(t, initialLocation: '/huruf/tulis');
  await t.tap(find.bySemanticsLabel('Krayon biru'));
  await t.pump();
  expect(t.widget<TracingBoard>(find.byType(TracingBoard)).ink, tulisCrayons[1]);
});
testWidgets('kartu Lanjutkan memakai subjudul tulis huruf', (t) async {
  final env = TestEnv(progress: const Progress(lastActivity: LastActivity('/huruf/tulis', {'huruf': 'A'})));
  await pumpApp(t, env: env);
  expect(find.text('Tulis huruf A'), findsOneWidget);
});
testWidgets('lanjutkan membuka huruf terakhir', (t) async {
  await pumpApp(t, initialLocation: '/huruf/tulis?huruf=Z');
  expect(find.text('Tulis Z'), findsOneWidget);
  expect(find.text('Garis 1 dari 3'), findsOneWidget);
});
testWidgets('pil rute: tab aktif dari lokasi, ketukan mengganti rute', (t) async {
  final router = await pumpApp(t, initialLocation: '/huruf/tulis');
  await t.tap(find.text('Kenali'));
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/huruf');
});
```

`_progress` membaca `progressProvider` lewat `ProviderScope.containerOf(t.element(find.byType(MociApp)))`; `_traceA` menggores tiga path `A` (`M260 70L130 450`, `M260 70L390 450`, `M176 315H344`) dengan gestur yang sama seperti `_trace` di `tracing_board_test.dart`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/tulis/tulis_huruf_test.dart test/widgets/game/route_mode_pill_test.dart`. Expected: FAIL (rute masih `ComingSoonScreen`, provider tracing belum ada).
- [ ] **Step 3: Implementasikan.** Muat kedua `TracingSet` di `runMoci` sebelum `runApp`; tambahkan override di `TestEnv` dengan membaca `assets/tracing/huruf.json` dan `angka.json` sekali per proses; ganti `_soon(Routes.hurufTulis, …)` dengan `GoRoute` layar yang membaca `state.uri.queryParameters['huruf']` sebagai `awal`; tambahkan `continueLabels[Routes.hurufTulis]`. Teks ARB disalin persis dari `Tulis.dc.html` baris 266–267.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/tulis test/widgets/game/route_mode_pill_test.dart test/core/content`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(huruf): layar Tulis Huruf dengan papan tracing, krayon, dan bintang kunci`.

---

### Task 6: Layar Tulis Angka

**Files:**
- Modify: `lib/features/tulis/tulis_keys.dart` (spec angka), `lib/features/tulis/tulis_screen.dart` (cabang angka), `lib/app/router.dart` (rute `/angka/tulis`), `lib/features/beranda/continue_labels.dart`, `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/tulis/tulis_angka_test.dart`

**Interfaces:**
- Consumes: `tracingAngkaProvider`, `TulisScreen`, `TracingBoard`, `MenuTheme.berhitung`.
- Produces: `TulisMode.angka` pada `TulisScreen` — tema `berhitung` (aksen `#1C7ED6`, bayangan `#B7D7F7`), kisi 2 kolom × 5 baris, kunci `0`–`9`, `static ValueKey<String> starKey(String k)`, `TracingBoard.paths` dari `tracingAngkaProvider.of(kunci)`, judul "Tulis angka 3" (huruf kecil seperti prototipe), `markItem('angka', 'ditulis', kunci)`, `setLastActivity(Routes.angkaTulis, {'angka': kunci})`, dan narasi `huruf_` diganti `angka_<kunci>` (`NarrationLine(jenis: 'angka', id: kunci, text: angkaKata(int.parse(kunci), lang))`). `GoRoute` `/angka/tulis` membaca `state.uri.queryParameters['angka']` sebagai `awal`; nilai di luar `0`–`9` diabaikan.
- ARB tambahan: `angkaTitle` "Angka" / "Numbers"; `angkaCount` "Berhitung" / "Count" (label pil mode, dipakai lagi di Task 8); `tulisPickAngka` "Pilih angka" / "Pick a number"; `tulisUnitAngka` "angka" / "the number"; `tulisKeyLabelAngka` "Tulis angka {angka}" / "Write the number {angka}"; `tulisAreaLabelAngka` "Area menulis angka {angka}" / "Writing area for the number {angka}"; `tulisSayStartAngka` "Ayo tulis angka" / "Let's write the number" (narasi); `tulisSayDoneAngka` "Hebat! Kamu bisa menulis angka" / "Great job! You wrote the number" (narasi); `berandaContinueTulisAngka` "Tulis angka {angka}" / "Write the number {angka}".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('layar tulis angka: 10 kunci, dua kolom, mulai dari 2', (t) async {
  await pumpApp(t, initialLocation: '/angka/tulis');
  expect(find.text('Angka'), findsOneWidget);
  expect(find.text('Tulis angka 2'), findsOneWidget);
  expect(find.text('Garis 1 dari 1'), findsOneWidget);
  expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths.length, 1);
  expect(t.getSize(find.byKey(TulisScreen.keyKey('0'))).height, 74);
});
testWidgets('angka 0 punya jalur', (t) async {
  await pumpApp(t, initialLocation: '/angka/tulis');
  await t.tap(find.byKey(TulisScreen.keyKey('0')));
  await t.pump();
  expect(find.text('Tulis angka 0'), findsOneWidget);
  expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths, isNotEmpty);
});
testWidgets('menyelesaikan angka 1 menandai kunci', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/angka/tulis');
  await t.tap(find.byKey(TulisScreen.keyKey('1')));
  await t.pump();
  await _trace1(t);
  expect(find.text('Hebat!'), findsOneWidget);
  expect(_progress(t).perkembangan['angka']!['ditulis'], ['1']);
});
testWidgets('kunci yang selesai tetap berbintang setelah layar dibuka lagi', (t) async {
  final env = TestEnv(progress: const Progress(perkembangan: {'angka': {'ditulis': ['1']}}));
  await pumpApp(t, env: env, initialLocation: '/angka/tulis');
  expect(find.byKey(TulisScreen.starKey('1')), findsOneWidget);
  expect(find.byKey(TulisScreen.starKey('3')), findsNothing);
});
testWidgets('ganti bahasa mengganti label', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/angka/tulis');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Write the number 2'), findsOneWidget);
});
testWidgets('lanjutkan membuka angka terakhir', (t) async {
  await pumpApp(t, initialLocation: '/angka/tulis?angka=7');
  expect(find.text('Tulis angka 7'), findsOneWidget);
});
```

`_trace1` menggores path `1` (`M200 140L275 70V450`): (200,140) → (275,70) lalu (275,70) → (275,450). Salin helper `_progress` dari `tulis_huruf_test.dart` (membaca `progressProvider` lewat `ProviderScope.containerOf`).

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/tulis/tulis_angka_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implementasikan cabang angka** di `TulisScreen` dan `TulisKeySpec`, ganti `_soon(Routes.angkaTulis, …)`, tambah `continueLabels[Routes.angkaTulis]`, baca `state.uri.queryParameters['angka']` sebagai `awal`, dan tambah kunci bintang di kisi (`TulisScreen.starKey`).
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/tulis`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(angka): layar Tulis Angka dengan kisi 0–9 dan bintang tersimpan`.

---

### Task 7: Layar Kenal Huruf

**Files:**
- Create: `lib/features/huruf/huruf_screen.dart`, `test/features/huruf/huruf_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/huruf`), `lib/features/beranda/continue_labels.dart`, `test/helpers/harness.dart` (field `letterMode`), `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog.huruf`, `HurufEntry.of(lang)`, `MociIllustration`, `RouteModePill`, `Narrator`, `prefsProvider.letterMode`, `markItem`, `setLastActivity`.
- Produces:
  - `class HurufScreen extends ConsumerStatefulWidget { const HurufScreen({super.key, this.awal}); }` dengan `static const letterKey`, `wordKey`, `alphabetKey`, `listenKey`, `prevKey`, `nextKey`, `static ValueKey<String> alphabetCellKey(String huruf)`; `awal` = huruf dari query `?huruf=B` (di luar A–Z diabaikan, bawaan `A`).
  - Tata letak `MociStage(MenuTheme.huruf)`: bilah atas (kembali, `hurufTitle`, `RouteModePill` tiga mode, `StarCounter`), kartu 840 × 420 di (170,134) berisi huruf besar 196 `#E8384F` + huruf kecil 150 `#1C8CF0`, label indeks "1 / 26", dua pil 54 (`hurufSound` + `bunyi`, `hurufName` + `nama`), kata contoh 66/54/44 px dengan huruf target merah, gambar 240 dalam lingkaran `#FFF1EC`, tombol dengar bulat 100 `#FFB020`, tombol sebelumnya/berikutnya 96 bulat di tepi kartu, kisi 13 × 2 huruf di bawah, Moci 150 di kiri bawah.
  - Perilaku: mode baris utama, panah, dan tombol dengar mengikuti `prefs.letterMode` (`fonik` → `NarrationLine(jenis: 'fonik', id: huruf.toLowerCase(), text: contoh.bunyi)`, `nama` → `jenis: 'huruf'`); kedua pil selalu bisa diketuk. Tombol dengar membacakan `sayAll([baris mode, NarrationLine(jenis: 'contoh', id: …, text: kata)])`. Huruf yang tampil dicatat `markItem('huruf', 'dibaca', huruf)` dan `setLastActivity(Routes.huruf, {'huruf': huruf})`. Saat bahasa berganti, narasi diulang dalam bahasa baru.
- ARB baru: `hurufListen` "Dengarkan bunyi huruf dan kata" / "Hear the letter sound and word"; `hurufPrev` "Huruf sebelumnya" / "Previous letter"; `hurufNext` "Huruf berikutnya" / "Next letter"; `hurufLetter` "Huruf" / "Letter"; `hurufTapHint` "ketuk untuk mendengar bunyinya" / "tap to hear its sound"; `hurufTapHintName` "ketuk untuk mendengar namanya" / "tap to hear its name"; `hurufSound` "Bunyi" / "Sound"; `hurufName` "Nama:" / "Name:"; `hurufSoundOf` "Bunyi huruf" / "Sound of letter"; `hurufNameOf` "Nama huruf" / "Name of letter"; `hurufLetterLabel` "Huruf {huruf}, {petunjuk}" / "Letter {huruf}, {petunjuk}"; `hurufSoundAria` "Bunyi huruf {huruf} {bunyi}" / "Sound of letter {huruf} {bunyi}"; `hurufNameAria` "Nama huruf {huruf}" / "Name of letter {huruf}"; `hurufGridLabel` "Pilih huruf" / "Pick a letter"; `berandaContinueHuruf` "Huruf {huruf}" / "Letter {huruf}".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
testWidgets('membuka layar: huruf A, kata Apel, dan narasi fonik', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/huruf');
  expect(find.byKey(HurufScreen.letterKey), findsOneWidget);
  expect(find.text('Apel', findRichText: true), findsOneWidget);
  expect(find.text('1 / 26'), findsOneWidget);
  expect(find.text('Bunyi'), findsOneWidget);
  expect(find.text('Nama:'), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), ['a', 'Apel']);
});
testWidgets('ketukan huruf mengikuti cara baca orang tua', (t) async {
  final env = TestEnv(letterMode: LetterMode.nama);
  await pumpApp(t, env: env, initialLocation: '/huruf');
  await t.tap(find.byKey(HurufScreen.nextKey));
  await t.pump();
  env.tts.spoken.clear();
  await t.tap(find.byKey(HurufScreen.letterKey));
  expect(env.tts.spoken.map((e) => e.$1), ['be']);
});
testWidgets('panah berikutnya: kata dan indeks ikut berganti', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/huruf');
  await t.tap(find.byKey(HurufScreen.nextKey));
  await t.pump();
  expect(find.text('Bola', findRichText: true), findsOneWidget);
  expect(find.text('2 / 26'), findsOneWidget);
  expect(_progress(t).perkembangan['huruf']!['dibaca'], ['A', 'B']);
});
testWidgets('kisi huruf: memilih Z', (t) async {
  await pumpApp(t, initialLocation: '/huruf');
  await t.tap(find.byKey(HurufScreen.alphabetCellKey('Z')));
  await t.pump();
  expect(find.text('Zebra', findRichText: true), findsOneWidget);
});
testWidgets('ganti bahasa mengganti kata contoh', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/huruf');
  await t.tap(find.byKey(HurufScreen.nextKey));
  await t.pump();
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Ball', findRichText: true), findsOneWidget);
  expect(env.tts.spoken.last.$2, AppLang.en);
});
testWidgets('lanjutkan membuka huruf terakhir', (t) async {
  await pumpApp(t, initialLocation: '/huruf?huruf=B');
  expect(find.text('2 / 26'), findsOneWidget);
  expect(find.text('Bola', findRichText: true), findsOneWidget);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/huruf`. Expected: FAIL.
- [ ] **Step 3: Implementasikan layar.** Ganti `_soon(Routes.huruf, …)`, tambah `continueLabels[Routes.huruf]`, tambah `letterMode` ke `TestEnv` (tulis `moci.caraBaca` di konstruktor). `GoRoute` membaca `state.uri.queryParameters['huruf']` sebagai `awal`. Salin teks dari `Huruf.dc.html` baris 144–145.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/huruf`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(huruf): layar Kenal Huruf dengan cara baca fonik/nama dan kisi A–Z`.

---

### Task 8: Layar Berhitung

**Files:**
- Create: `lib/features/berhitung/berhitung_benda.dart`, `lib/features/berhitung/berhitung_screen.dart`, `test/features/berhitung/berhitung_benda_test.dart`, `test/features/berhitung/berhitung_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/angka`), `lib/features/beranda/continue_labels.dart`, `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog.angka` (`maks`, `rentang`, `benda`), `ByLang` `angkaKata`, `MociIllustration`, `RouteModePill`, `Narrator`, `Sfx`, `markItem`, `setLastActivity`.
- Produces:
  - `String bendaJamak(String nama, AppLang lang)` — ID mengembalikan nama apa adanya; EN memakai peta `Fish: fish`, `Strawberry: strawberries`, `Butterfly: butterflies`, `Balloons: balloons`, selain itu nama huruf kecil + `s` (port `plural` prototipe).
  - `({int columns, double size, double gap}) hitungGrid(int n)` — n ≤ 10: kolom `min(n, 5)` dan ukuran 130/110/96; n ≤ 20: 10 × 54; selain itu 10 × 46; jarak 22/10/10.
  - `class BerhitungScreen extends ConsumerStatefulWidget { const BerhitungScreen({super.key, this.awal}); }` dengan `static ValueKey<int> itemKey(int i)`, `static ValueKey<int> numberKey(int n)`, `static ValueKey<int> rangeKey(int awal)`; `awal` = angka dari query `?angka=15` (dijepit 1..`maks`, bawaan 1).
  - Tata letak `MociStage(MenuTheme.berhitung)`: kartu angka 360 × 490 di (50,124) berisi angka 240/200, kata berkapital 52/40/34, tombol dengar 96; panel hitung 700 × 490 di (436,124) berisi judul `angkaCountPrompt`, tombol `angkaAuto`, pil hitung "{count} / {n}", kisi benda, dan bilah selesai; pil rentang 50 tinggi di y 640; kisi 10 angka 76 tinggi di y 708.
  - Perilaku: angka `awal` diperlakukan seperti memilih angka (narasi, `setLastActivity`, `markItem('angka', 'dibaca')`), tanpa menaikkan hitungan. Pilih angka → `count = 0`, narasi `angka_<n>`, `setLastActivity(Routes.angka, {'angka': '$n'})`, `markItem('angka', 'dibaca', '$n')`; ketuk benda menaikkan hitungan dan membacakan `angka_<count>`; hitungan penuh → `sayAll([ui angkaDoneSay, angka_<n>, nama_<benda>])` + `Sfx.sorak` + `markItem('angka', 'dihitung', '$n')`. "Hitung bareng" memakai `Timer.periodic` 700/450/260 ms, membacakan tiap langkah untuk n ≤ 20 (dan tiap 10 serta terakhir untuk n > 20), dan dibatalkan saat angka berganti atau layar ditutup.
- ARB baru (selain `angkaTitle` dan `angkaCount` dari Task 6): `angkaListen` "Dengar angkanya" / "Hear the number"; `angkaAuto` "Hitung bareng" / "Count for me"; `angkaRange` "Rentang angka" / "Number range"; `angkaPick` "Pilih angka" / "Pick a number"; `angkaNumber` "Angka {n}" / "Number {n}"; `angkaCountPrompt` "Ayo hitung {benda}!" / "Let's count the {benda}!"; `angkaTapIt` "Ketuk untuk menghitung" / "Tap to count"; `angkaDone` "Ada {kata} {benda}!" / "{jumlah} {benda}!"; `angkaDoneSay` "Hebat, hitungannya benar!" / "Great counting!" (narasi); `berandaContinueAngka` "Angka {angka}" / "Number {angka}".

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/berhitung/berhitung_benda_test.dart`:
```dart
test('jamak EN mengikuti prototipe', () {
  expect(bendaJamak('apel', AppLang.id), 'apel');
  expect(bendaJamak('Apple', AppLang.en), 'apples');
  expect(bendaJamak('Fish', AppLang.en), 'fish');
  expect(bendaJamak('Strawberry', AppLang.en), 'strawberries');
  expect(bendaJamak('Butterfly', AppLang.en), 'butterflies');
  expect(bendaJamak('Cupcake', AppLang.en), 'cupcakes');
});
test('kisi hitung untuk 1, 10, 20, dan 50', () {
  expect(hitungGrid(1), (columns: 1, size: 130.0, gap: 22.0));
  expect(hitungGrid(10), (columns: 5, size: 96.0, gap: 22.0));
  expect(hitungGrid(20), (columns: 10, size: 54.0, gap: 10.0));
  expect(hitungGrid(50), (columns: 10, size: 46.0, gap: 10.0));
});
```
`test/features/berhitung/berhitung_screen_test.dart`:
```dart
testWidgets('membuka: angka 1, kata Satu, satu apel', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/angka');
  expect(find.text('1'), findsWidgets);
  expect(find.text('Satu'), findsOneWidget);
  expect(find.text('Ayo hitung apel!'), findsOneWidget);
  expect(find.text('0 / 1'), findsOneWidget);
  expect(env.tts.spoken.first.$1, 'satu');
});
testWidgets('mengetuk benda menyelesaikan hitungan dan mencatat', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/angka');
  await t.tap(find.byKey(BerhitungScreen.itemKey(0)));
  await t.pump();
  expect(find.text('1 / 1'), findsOneWidget);
  expect(find.text('Ada satu apel!'), findsOneWidget);
  expect(_progress(t).perkembangan['angka']!['dihitung'], ['1']);
  expect(env.tts.spoken.map((e) => e.$1), containsAllInOrder(['Hebat, hitungannya benar!', 'satu', 'Apel']));
});
testWidgets('rentang dan angka: 41–50 memilih lima puluh', (t) async {
  await pumpApp(t, initialLocation: '/angka');
  await t.tap(find.byKey(BerhitungScreen.rangeKey(41)));
  await t.pump();
  await t.tap(find.byKey(BerhitungScreen.numberKey(50)));
  await t.pump();
  expect(find.text('Lima puluh'), findsOneWidget);
  expect(find.byKey(BerhitungScreen.itemKey(49)), findsOneWidget);
  expect(t.takeException(), isNull);
});
testWidgets('hitung bareng berhenti saat angka berganti', (t) async {
  await pumpApp(t, initialLocation: '/angka');
  await t.tap(find.byKey(BerhitungScreen.numberKey(3)));
  await t.pump();
  await t.tap(find.text('Hitung bareng'));
  await t.pump(const Duration(milliseconds: 700));
  await t.tap(find.byKey(BerhitungScreen.numberKey(5)));
  await t.pump(const Duration(milliseconds: 1400));
  expect(find.text('0 / 5'), findsOneWidget);
});
testWidgets('ganti bahasa mengganti kata bilangan', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/angka');
  _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('One'), findsOneWidget);
  expect(find.text("Let's count the apples!"), findsOneWidget);
  expect(find.text("Let's count the apple!"), findsNothing);
});
testWidgets('50 benda dan kata panjang tidak overflow', (t) async {
  await pumpApp(t, initialLocation: '/angka');
  await t.tap(find.byKey(BerhitungScreen.rangeKey(41)));
  await t.pump();
  await t.tap(find.byKey(BerhitungScreen.numberKey(50)));
  await t.pump();
  expect(find.text('Lima puluh'), findsOneWidget);
  expect(find.byKey(BerhitungScreen.itemKey(49)), findsOneWidget);
  expect(t.takeException(), isNull);
});
testWidgets('lanjutkan membuka angka terakhir', (t) async {
  await pumpApp(t, initialLocation: '/angka?angka=15');
  expect(find.text('Lima belas'), findsOneWidget);
  expect(find.text('0 / 15'), findsOneWidget);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/berhitung`. Expected: FAIL.
- [ ] **Step 3: Implementasikan layar dan pembantu.** Ganti `_soon(Routes.angka, …)`, tambah `continueLabels[Routes.angka]`, baca `state.uri.queryParameters['angka']` sebagai `awal`. Teks dari `Angka.dc.html` baris 192–194; ukuran kisi dan ukuran kata dari baris 173–181 dan 230–234.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/berhitung`. Expected: PASS.
- [ ] **Step 5: Commit** dengan pesan `feat(angka): layar Berhitung 1–50 dengan hitung bareng dan kisi benda`.

---

### Task 9: Pengenal ucapan di perangkat

**Files:**
- Create: `lib/core/speech/speech_engine.dart`, `lib/core/speech/speech_to_text_engine.dart`, `test/core/speech/speech_test.dart`, `test/helpers/fake_speech.dart`
- Modify: `lib/core/audio/audio_service.dart` (jeda untuk mendengar), `test/helpers/harness.dart` (override `speechEngineProvider`), `pubspec.yaml` (`speech_to_text: ^7.5.0`), `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `test/platform/platform_config_test.dart`
- Test: `test/core/speech/speech_test.dart`, `test/core/audio/audio_service_test.dart` (tambah), `test/platform/platform_config_test.dart` (tambah)

**Interfaces:**
- Consumes: `speech_to_text` 7.5 (`SpeechToText`, `SpeechListenOptions`, `AudioSessionConfigurator`), `FakeAudioEngine`, `AssetCatalog`.
- Produces:
  - `enum SpeechStatus { siap, izinDitolak, tidakTersedia }`
  - `final class SpeechTurn { const SpeechTurn({required this.didengar, this.teks}); final bool didengar; final String? teks; }`
  - `abstract interface class SpeechEngine { Future<bool> hasPermission(); Future<SpeechStatus> prepare(AppLang lang); Future<SpeechTurn?> listen({required String target, required AppLang lang, required Duration batas}); Future<void> stop(); }`
  - `bool kataCocok(String target, String ucapan)` — normalkan ke huruf kecil tanpa tanda baca dan spasi ganda; cocok kalau sama, atau (target ≥ 4 huruf) jarak Levenshtein ≤ 1.
  - `final class SpeechToTextEngine implements SpeechEngine` — `listen` selalu `SpeechListenOptions(onDevice: true, cancelOnError: true, partialResults: true, listenMode: ListenMode.dictation, contextualPhrases: [target], localeId: id_ID|en_US, listenFor: batas)`. Error `error_network`, `error_language_not_supported`, `error_server`, `error_audio`, atau `error_client` → `null` (pengenalan teks tidak tersedia). Error `error_no_match` / `error_speech_timeout` → `SpeechTurn(didengar: false)`. Timer cadangan `batas + 300 ms` menyelesaikan dengan hasil parsial terakhir. Setelah tiap giliran, `stop()` dan sesi audio dikembalikan ke playback.
  - `final speechEngineProvider = Provider<SpeechEngine>((_) => SpeechToTextEngine());`
  - `AudioService.pauseForListening()`: hentikan narasi dan musik, tahan `startMusic` selama jeda. `AudioService.resumeAfterListening()`: mainkan lagi musik kalau `_musicRequested` dan sakelar musik menyala.
  - `test/helpers/fake_speech.dart`: `FakeSpeechEngine` dengan `status`, `turn`, `targets`, `prepareCount`, `listenCount`, `hasPermissionValue`, dan `gate` (`Completer`). `TestEnv` mendapat field `final speech = FakeSpeechEngine();` dan override `speechEngineProvider`.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
test('kata cocok setelah huruf kecil dan tanda baca', () {
  expect(kataCocok('Apel', 'apel!'), isTrue);
  expect(kataCocok('Apple', '  APPLE. '), isTrue);
  expect(kataCocok('Bola', 'buku'), isFalse);
});
test('selisih satu huruf hanya untuk empat huruf ke atas', () {
  expect(kataCocok('Bola', 'bala'), isTrue);
  expect(kataCocok('Apple', 'aple'), isTrue);
  expect(kataCocok('Api', 'ati'), isFalse);
});
test('kata berbeda tidak cocok', () {
  expect(kataCocok('Zebra', 'apple'), isFalse);
  expect(kataCocok('Yoyo', 'yoyo!'), isTrue);
});
test('pauseForListening menghentikan musik, resume memulainya lagi', () async {
  final engine = FakeAudioEngine();
  final service = AudioService(engine: engine, assets: AssetCatalog({AudioService.musicAsset}));
  await engine.init();
  await service.startMusic();
  expect(engine.live.values, contains(AudioService.musicAsset));
  await service.pauseForListening();
  expect(engine.live, isEmpty);
  await service.resumeAfterListening();
  expect(engine.live.values, contains(AudioService.musicAsset));
});
```
`test/platform/platform_config_test.dart` tambahan:
```dart
test('manifest rilis menambah RECORD_AUDIO dan queries pengenal', () {
  final xml = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  expect(xml, contains('android.permission.RECORD_AUDIO'));
  expect(xml, contains('android.speech.RecognitionService'));
  final internet = RegExp(r'<uses-permission[^>]*android\.permission\.INTERNET[^>]*>')
      .allMatches(xml).map((m) => m.group(0)!).where((e) => !e.contains('tools:node="remove"'));
  expect(internet, isEmpty);
});
test('Info.plist memuat dua alasan izin', () {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();
  expect(plist, contains('NSMicrophoneUsageDescription'));
  expect(plist, contains('NSSpeechRecognitionUsageDescription'));
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/speech test/core/audio test/platform`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Jalankan `fvm flutter pub add speech_to_text`. Periksa manifest plugin di `~/.pub-cache/hosted/pub.dev/speech_to_text-*/android/src/main/AndroidManifest.xml`; kalau plugin mendeklarasikan INTERNET, buang dengan `<uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>` di manifest utama. Tambah `RECORD_AUDIO`, `<queries>` RecognitionService, dan dua kunci Info.plist. Teks alasan iOS ditujukan untuk orang tua, misalnya "Moci memakai mikrofon supaya anak bisa berlatih mengucapkan kata. Suara dikenali di perangkat ini saja, tidak disimpan dan tidak dikirim." Tambah field `speech` dan override `speechEngineProvider` di `TestEnv`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/core/speech test/core/audio test/platform`. Expected: PASS.
- [ ] **Step 5: Cek manifest gabungan.** Run: `fvm flutter build apk --release --target-platform android-arm64`, lalu `$ANDROID_HOME/build-tools/*/aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk`. Expected: hanya `id.pandudpn.moci.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` dan `android.permission.RECORD_AUDIO`; tidak ada INTERNET atau BLUETOOTH.
- [ ] **Step 6: Commit** dengan pesan `feat(ucapkan): pengenal ucapan on-device, izin mikrofon, dan jeda audio`.

---

### Task 10: Pengukur level suara

**Files:**
- Create: `lib/core/speech/mic_level_meter.dart`, `lib/core/speech/method_channel_mic_level_meter.dart`, `test/core/speech/mic_level_meter_test.dart`
- Modify: `android/app/src/main/kotlin/id/pandudpn/moci/MainActivity.kt`, `ios/Runner/MociChannels.swift`, `test/helpers/fake_speech.dart`, `test/helpers/harness.dart`
- Test: `test/core/speech/mic_level_meter_test.dart`

**Interfaces:**
- Consumes: `EventChannel`, `MethodChannel`, `AVAudioEngine`/`AudioRecord`.
- Produces:
  - `const ambangSuara = 0.12;` `const sampelBicara = 6;` `const jedaLevel = Duration(milliseconds: 50);`
  - `bool suaraCukup(List<double> level)` — benar kalau ada `sampelBicara` nilai berurutan ≥ `ambangSuara`.
  - `abstract interface class MicLevelMeter { Future<bool> get available; Future<bool> listen({required Duration batas}); Future<void> stop(); }`
  - `class MethodChannelMicLevelMeter implements MicLevelMeter` — `EventChannel('moci/mic_level_events')` mengalirkan level 0..1 tiap 50 ms; `available` memanggil `MethodChannel('moci/mic_level').invokeMethod<bool>('available')`; `listen` mengumpulkan level sampai `suaraCukup`, batas waktu habis (false), atau `no_permission`.
  - `final micLevelMeterProvider = Provider<MicLevelMeter>((_) => const MethodChannelMicLevelMeter());` di Android/iOS, `const NoopMicLevelMeter()` di platform lain.
  - `FakeMicLevelMeter` dengan `bool hasil`, `bool available`, `int listenCount`.

Native:
- Android `moci/mic_level`: `available` memeriksa `checkSelfPermission(RECORD_AUDIO)`; `start` menjalankan `AudioRecord` 16 kHz mono PCM16 di thread latar dan mengirim RMS ternormalisasi (`min(1, rms / 32768 * 4)`) lewat `EventChannel`; `stop` menghentikan thread dan melepas recorder. Error `no_permission` kalau izin belum ada.
- iOS `moci/mic_level`: `available` dari `AVAudioSession.sharedInstance().recordPermission == .granted`; `start` memakai tap `AVAudioEngine` pada `inputNode` (buffer 1024), RMS `min(1, rms * 8)` dikirim di main queue, dan kategori sesi sementara `.playAndRecord` dengan `.defaultToSpeaker, .mixWithOthers`; `stop` melepas tap dan mengembalikan kategori `.playback`.
- Suara tidak pernah ditulis ke berkas; buffer dibuang setelah RMS dihitung.

- [ ] **Step 1: Tulis tes yang gagal**

```dart
test('suara cukup setelah enam sampel berurutan di atas ambang', () {
  expect(suaraCukup([0, 0.2, 0.2, 0.2, 0.2, 0.2]), isFalse);
  expect(suaraCukup([0, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]), isTrue);
});
test('sampel terpisah tidak dihitung', () {
  expect(suaraCukup([0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3]), isFalse);
});
test('ambang 0,12', () {
  expect(suaraCukup(List.filled(6, 0.11)), isFalse);
  expect(suaraCukup(List.filled(6, 0.12)), isTrue);
});
test('noop selalu tidak tersedia', () async {
  const meter = NoopMicLevelMeter();
  expect(await meter.available, isFalse);
  expect(await meter.listen(batas: const Duration(seconds: 1)), isFalse);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/core/speech/mic_level_meter_test.dart`. Expected: FAIL.
- [ ] **Step 3: Implementasikan Dart dan native.** Daftarkan `MethodChannel` dan `EventChannel` di `configureFlutterEngine` (Android) dan `register` (iOS). Tambah field `final meter = FakeMicLevelMeter();` dan override `micLevelMeterProvider` di `TestEnv`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/core/speech`. Expected: PASS.
- [ ] **Step 5: Cek kanal native setelah layar Ucapkan ada.** Kanal ini baru terpakai di Task 11, jadi pemeriksaan perangkat dilakukan di Task 11 Step 5 (level bergerak saat bicara, berhenti saat diam, dan tidak ada berkas audio baru di folder aplikasi iOS). Jangan menulis kode debug sementara di `runMoci`.
- [ ] **Step 6: Commit** dengan pesan `feat(ucapkan): pengukur level suara native sebagai cadangan pengenalan offline`.

---

### Task 11: Layar Ucapkan

**Files:**
- Create: `lib/features/ucapkan/ucapkan_kata.dart`, `lib/features/ucapkan/ucapkan_screen.dart`, `test/features/ucapkan/ucapkan_kata_test.dart`, `test/features/ucapkan/ucapkan_screen_test.dart`
- Modify: `lib/app/router.dart` (rute `/huruf/ucapkan`), `lib/features/beranda/continue_labels.dart`, `l10n/app_id.arb`, `l10n/app_en.arb`

**Interfaces:**
- Consumes: `Katalog.ucapkan` (`UcapkanEntry { kata, suku, gambar }`), `speechEngineProvider`, `micLevelMeterProvider`, `SpeechStatus`, `SpeechTurn`, `kataCocok`, `AudioService.pauseForListening/resumeAfterListening`, `Narrator`, `Sfx`, `MicButton`, `ProgressDots`, `MociDialog`, `MociButton`.
- Produces:
  - `final class UcapkanKata { const UcapkanKata({required this.kata, required this.suku, required this.itemId}); }`, `String itemIdDariGambar(String gambar)` (membuang awalan `illustrations/` dan akhiran `.svg`), dan `List<UcapkanKata> ucapkanKata(Katalog katalog, AppLang lang)`.
  - `class UcapkanScreen extends ConsumerStatefulWidget { const UcapkanScreen({super.key, this.awal}); }` dengan `static const micKey`, `nextKey`, `static ValueKey<int> syllableKey(int i)`; `awal` = kata dari query `?kata=Bola` (cocok tanpa beda huruf besar-kecil; tidak dikenal → kata pertama).
  - Tata letak `MociStage(MenuTheme.ucapkan)`: kartu kiri 500 × 600 di (60,128) berisi gambar 250, tombol suku kata 100 (warna `#E8384F`, `#1C8CF0`, `#7048E8` bergiliran), pil "Dengar contoh", titik kemajuan 5; Moci 190 di (612,132); gelembung "Sekarang giliranmu! Bilang:" + kata besar di (806,126); tombol mikrofon 180 di (780,372); teks status di y 584; bintang + `Ulangi` + `Kata berikutnya` di y 712 setelah berhasil.
  - Alur izin (H8): ketukan mic pertama memanggil `hasPermission()`; kalau belum, tampilkan `MociDialog` "Panggil Ayah atau Bunda" dengan aksi `Buka Gerbang` yang menunggu `context.push<bool>(Routes.gerbang)`; kalau hasilnya `true`, panggil `prepare(lang)`. `izinDitolak` → mode dengar dan tiru (tombol mic diganti `MociButton` "Dengar dan tiru", kata tetap bisa didengar, `Kata berikutnya` selalu ada). `tidakTersedia` → tetap coba `listen`; kalau hasilnya `null`, pakai `micLevelMeterProvider`; kalau meter juga tidak tersedia, masuk mode dengar dan tiru.
  - Alur giliran: `pauseForListening` → `listen(batas: 4 detik)` → `resumeAfterListening` + sesi playback. `SpeechTurn` cocok → `Sfx.benar`, status `ucapkanGood`, `sayAll([ui ucapkanDoneSay, nama_<itemId>])`, bintang, tombol `Ulangi` + `Kata berikutnya`. Tidak cocok → `sayAll([ui ucapkanTryAgain])`, putar ulang contoh, coba lagi; setelah dua percobaan tetap `ucapkanGood` (tanpa bintang hadiah). Tidak ada Hebat.
  - Narasi contoh: `sayAll([suku_<suku>, …, nama_<itemId>])`; `Kata berikutnya` membacakan `sayAll([ui ucapkanLetsSay, nama_<itemId>])` lalu mencatat `setLastActivity(Routes.hurufUcapkan, {'kata': kata})`. Kata `awal` mencatat `lastActivity` yang sama saat layar dibuka.
- ARB baru: `ucapkanHear` "Dengar contoh" / "Hear it"; `ucapkanYourTurn` "Sekarang giliranmu! Bilang:" / "Your turn! Say:"; `ucapkanIdle` "Ketuk mic, lalu ucapkan" / "Tap the mic, then say it"; `ucapkanListen` "Moci mendengarkan…" / "Moci is listening…"; `ucapkanGood` "Bagus sekali!" / "Well done!"; `ucapkanAgain` "Ulangi" / "Again"; `ucapkanNextWord` "Kata berikutnya" / "Next word"; `ucapkanSyl` "Suku kata" / "Syllable"; `ucapkanMicIdle` "Ketuk lalu ucapkan" / "Tap and say"; `ucapkanMicListen` "Moci sedang mendengarkan" / "Moci is listening"; `ucapkanLetsSay` "Ayo bilang" / "Let's say" (narasi); `ucapkanTryAgain` "Ayo coba lagi!" / "Let's try again!" (narasi); `ucapkanDoneSay` "Hebat! Kamu bisa bilang" / "Great job! You can say" (narasi); `ucapkanMicAskTitle` "Panggil Ayah atau Bunda" / "Call Mom or Dad"; `ucapkanMicAskBody` "Mikrofon hanya dinyalakan oleh orang tua. Suara Adik dikenali di perangkat ini saja, tidak disimpan dan tidak dikirim." / "Only a grown-up turns on the microphone. Your voice is recognized on this device only; it is not saved or sent."; `ucapkanMicAskAction` "Buka Gerbang" / "Open Gate"; `ucapkanMicDenied` "Tanpa mikrofon, kita dengar dan tiru saja, ya!" / "Without the microphone, let's listen and repeat!"; `ucapkanMicUnavailable` "Moci belum bisa mendengar di perangkat ini. Dengar dan tiru saja, ya!" / "Moci can't listen on this device yet. Let's listen and repeat!"; `ucapkanPractice` "Dengar dan tiru" / "Listen and repeat"; `ucapkanMicLabel` "Ketuk lalu ucapkan {kata}" / "Tap and say {kata}"; `ucapkanWordLabel` "{kata}, ketuk untuk mendengar" / "{kata}, tap to hear it"; `berandaContinueUcapkan` "Ucapkan {kata}" / "Say {kata}".

- [ ] **Step 1: Tulis tes yang gagal**

```dart
test('id benda diambil dari path gambar', () {
  expect(itemIdDariGambar('illustrations/apel.svg'), 'apel');
  expect(itemIdDariGambar('illustrations/kuekecil.svg'), 'kuekecil');
});
test('lima kata per bahasa dengan suku kata', () {
  final k = _katalogUji();
  expect(ucapkanKata(k, AppLang.id).map((e) => e.kata), ['Apel', 'Bola', 'Ikan', 'Sapi', 'Topi']);
  expect(ucapkanKata(k, AppLang.en).first.itemId, 'apel');
});
```
```dart
testWidgets('mic pertama membuka gerbang, bukan permintaan izin', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/huruf/ucapkan');
  await t.tap(find.byKey(UcapkanScreen.micKey));
  await t.pump();
  expect(find.text('Panggil Ayah atau Bunda'), findsOneWidget);
  await t.tap(find.text('Buka Gerbang'));
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/gerbang');
  expect(env.speech.prepareCount, 0);
  router.pop(true);
  await t.pump();
  await t.pump();
  expect(env.speech.prepareCount, 1);
});
testWidgets('kata cocok: pujian, bintang, dan kata berikutnya', (t) async {
  final env = TestEnv();
  env.speech.hasPermissionValue = true;
  env.speech.turn = const SpeechTurn(didengar: true, teks: 'apel');
  await pumpApp(t, env: env, initialLocation: '/huruf/ucapkan');
  await t.tap(find.byKey(UcapkanScreen.micKey));
  await t.pump();
  expect(find.text('Bagus sekali!'), findsOneWidget);
  expect(env.speech.targets.single, 'Apel');
  await t.tap(find.text('Kata berikutnya'));
  await t.pump();
  expect(find.text('BOLA'), findsOneWidget);
})
testWidgets('izin ditolak: layar tetap bisa dimainkan', (t) async {
  final env = TestEnv();
  env.speech.hasPermissionValue = true;
  env.speech.status = SpeechStatus.izinDitolak;
  await pumpApp(t, env: env, initialLocation: '/huruf/ucapkan');
  await t.tap(find.byKey(UcapkanScreen.micKey));
  await t.pump();
  expect(find.text('Dengar dan tiru'), findsOneWidget);
  expect(find.byKey(UcapkanScreen.micKey), findsNothing);
  expect(find.text('Kata berikutnya'), findsOneWidget);
  expect(t.takeException(), isNull);
});
testWidgets('pengenalan tidak tersedia: meter suara menentukan', (t) async {
  final env = TestEnv();
  env.speech.hasPermissionValue = true;
  env.speech.turn = null;
  env.meter.hasil = true;
  await pumpApp(t, env: env, initialLocation: '/huruf/ucapkan');
  await t.tap(find.byKey(UcapkanScreen.micKey));
  await t.pump();
  expect(env.meter.listenCount, 1);
  expect(find.text('Bagus sekali!'), findsOneWidget);
});
testWidgets('dua percobaan gagal tetap memuji dan menawarkan kata berikutnya', (t) async {
  final env = TestEnv();
  env.speech.hasPermissionValue = true;
  env.speech.turn = const SpeechTurn(didengar: true, teks: 'buku');
  await pumpApp(t, env: env, initialLocation: '/huruf/ucapkan');
  for (var i = 0; i < 2; i++) {
    await t.tap(find.byKey(UcapkanScreen.micKey));
    await t.pump();
  }
  expect(find.text('Ayo coba lagi!'), findsNothing);
  expect(find.text('Kata berikutnya'), findsOneWidget);
});
testWidgets('lanjutkan membuka kata terakhir', (t) async {
  await pumpApp(t, initialLocation: '/huruf/ucapkan?kata=Bola');
  expect(find.text('BOLA'), findsOneWidget);
  expect(find.byKey(UcapkanScreen.syllableKey(0)), findsOneWidget);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/ucapkan`. Expected: FAIL.
- [ ] **Step 3: Implementasikan.** Ganti `_soon(Routes.hurufUcapkan, MenuTheme.ucapkan)` dengan `GoRoute`, tambah `continueLabels[Routes.hurufUcapkan]`, dan baca `state.uri.queryParameters['kata']` sebagai `awal`. Teks dari `Ucapkan.dc.html` baris 213–214. Pastikan `pauseForListening` dipanggil sebelum mikrofon hidup dan `resumeAfterListening` di `finally`.
- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/ucapkan`. Expected: PASS.
- [ ] **Step 5: Cek manual.** Di iPad dan emulator Android: mode pesawat menyala, ucapkan "Apel" dan "Apple"; tolak izin mikrofon lalu pastikan layar tetap jalan; nyalakan musik latar lalu pastikan berhenti selama mendengar dan kembali sesudahnya. Di emulator tanpa model pengenalan offline, pastikan layar memakai pengukur level suara dan tetap memuji setelah anak bersuara.
- [ ] **Step 6: Commit** dengan pesan `feat(ucapkan): layar Ucapkan dengan gerbang izin, pengenalan on-device, dan mode dengar-tiru`.

---

### Task 12: Dokumentasi, uji integrasi, dan pemeriksaan akhir

**Files:**
- Modify: `ARCHITECTURE.md`, `DESIGN.md`, `SYSTEM_DESIGN.md`, `integration_test/app_test.dart`
- Test: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: semua task sebelumnya.
- Produces: dokumentasi yang cocok dengan kode (peta folder, provider, rute, komponen bersama, konstanta tracing, alur izin), dan satu skenario integrasi perangkat.

Dokumentasi yang harus berubah:
- `ARCHITECTURE.md`: baris peta folder untuk `lib/widgets/game/`, `lib/features/{huruf,tulis,berhitung,ucapkan}`, `lib/core/speech/`; baris provider `tracingHurufProvider`, `tracingAngkaProvider`, `speechEngineProvider`, `micLevelMeterProvider`; rute `/huruf`, `/huruf/tulis`, `/huruf/ucapkan`, `/angka`, `/angka/tulis` tidak lagi `ComingSoonScreen`; harness menyebut `FakeSpeechEngine` dan `FakeMicLevelMeter`; §7 menyebut komponen permainan bersama.
- `DESIGN.md`: ganti paragraf "Komponen permainan bersama … belum ada" dengan tabel lima komponen beserta API-nya, tambah aturan `LetterMode`, konstanta tracing, dan alur izin Ucapkan.
- `SYSTEM_DESIGN.md`: §1 (izin rilis hanya `RECORD_AUDIO`), §4 (TTS di semua mode, queries TTS di manifest utama), §5 (Ucapkan sudah dibangun, meter level suara, tidak ada pengenalan daring), §7 (izin rilis).
- `integration_test/app_test.dart`: skenario "huruf → tulis" — buka Beranda, ketuk kartu Kenal Huruf, pindah ke Tulis lewat pil, gores A sampai bilah Hebat muncul, kembali ke Beranda, dan pastikan kartu Lanjutkan bersubjudul "Tulis huruf A". Tidak memakai `pumpAndSettle`; penantian lewat `_pumpUntil` yang sudah ada.

- [ ] **Step 1: Tulis uji integrasi.** Tambah `testWidgets('huruf: kenal, tulis A, lalu lanjutkan', …)` dengan langkah di atas, memakai `_prepareDevice` dan `runMoci(overrides: _quietAudio(...))` yang sudah ada.
- [ ] **Step 2: Jalankan di perangkat.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS. Ini tes pertama yang menempuh jalur utuh (router, penyimpanan, papan tracing), jadi kegagalan di sini adalah bug integrasi: perbaiki layarnya, bukan tesnya.
- [ ] **Step 3: Perbarui dokumentasi** sesuai daftar di atas. Jangan menyalin isi spec; tulis hanya yang berubah di kode.
- [ ] **Step 4: Jalankan uji integrasi lagi.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS.
- [ ] **Step 5: Pemeriksaan akhir.** Run:
```bash
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm flutter analyze
fvm flutter test
fvm dart run tool/validate_content.dart
```
Expected: format dan analyze bersih; semua tes PASS; validator keluar dengan kode 0 dan hanya peringatan (`mewarnai_contoh`, `narasi_lengkap` untuk rekaman yang belum ada).
- [ ] **Step 6: Commit** dengan pesan `docs(huruf-angka): peta folder, komponen permainan, alur izin, dan uji integrasi`.
