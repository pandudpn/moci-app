# Moci — Rencana 06: Main Yuk! — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Hub Main Yuk! dan enam permainan yang punya akhir — Cocokkan, Memori, Bayangan, Puzzle, Balon, dan Besar & Kecil — dengan tingkat kesulitan mengikuti usia anak, hadiah lewat `finishGame`, dan satu uji integrasi "satu permainan → Hebat".

**Architecture:**
- Aturan setiap permainan ditulis sebagai Dart murni di `lib/features/main_yuk/<nama>_game.dart`: pembuatan ronde, pemilihan tema, langkah yang sah, dan kapan ronde selesai. Layar hanya memegang pilihan yang sedang terlihat, animasi, dan narasi, jadi seluruh aturan bisa dites tanpa widget.
- Tujuh layar (`HubScreen` + enam permainan) memakai satu `GameScaffold` yang membungkus `MociStage` dan `MociTopBar`, lalu meletakkan isi di kanvas tablet 1180 × 820 dengan koordinat dari artboard. Komponen permainan Rencana 03 (`GameModePill`, `GameInstruction`, `AnswerCard`, `ProgressDots`, `GameGlyph`) dipakai ulang, bukan dibuat ulang.
- Hadiah selalu lewat satu jalur: `selesaikanRonde()` memanggil `HadiahController.finishGame(gameId, roundId)` lalu `push('/hebat')`. `roundId` berasal dari penghitung milik sesi aplikasi, bukan dari nomor ronde milik layar, supaya "Main lagi" di Hebat selalu memberi hadiah baru.

**Tech Stack:** Flutter 3.50.0 (FVM), Dart 3, `dart:math` (`Random` yang bisa di-seed), `CustomPainter` untuk papan Cocokkan dan balon, Riverpod 3, `go_router` 18, gen-l10n.

**Spec:**
- `docs/PRD.md` (tabel Fitur per menu, baris Cocokkan Gambar sampai Besar & Kecil; aturan "permainan yang punya akhir ditutup dengan layar Hebat"), `docs/TECH-SPEC.md` (rute Main Yuk!, `ColorFilter` Bayangan dan `ClipRect` Puzzle), `docs/DESIGN-SYSTEM.md` (latar per menu, ukuran target sentuh, umpan balik benar/salah).
- Prototipe: `docs/design/prototype/Permainan.dc.html` (hub), `Cocokkan.dc.html`, `Memori.dc.html`, `Bayangan.dc.html`, `Puzzle.dc.html`, `Balon.dc.html`, `BesarKecil.dc.html`, dan `Hebat.dc.html`. Teks UI disalin persis dari objek `T` tiap artboard; ukuran dan warna dari markup-nya.
- Peta rencana: `docs/superpowers/plans/2026-11-14-moci-roadmap.md` (baris 06).

**Bergantung pada Rencana 01, 02, dan 03:**
- 01: `MociStage`, `MenuTheme` (sudah memuat `mainYuk`, `cocokkan`, `memori`, `bayangan`, `puzzle`, `balon`, `besarKecil`), `MociTopBar`, `MociBackButton`, `MociPressable`, `MociButton`, `MociIllustration` (termasuk `silhouette`), `MociMascot`, `StarCounter`, `Narrator`, `AudioService`, `Sfx`, `prefsProvider` (`AgeLevel`), `progressProvider` (`setLastActivity`), `hadiahProvider` (`finishGame`, `HebatArgs`, `AwardResult`), `HebatScreen`, rute `/hebat`, harness tes (`TestEnv`, `pumpApp`, `pumpScreen`), dan `integration_test/app_test.dart`.
- 02: `Katalog` (`item`, `byKategori`, `byId`), `Item` (`id` = nama berkas ilustrasi), `Bilingual`, `barisUi/barisNama/barisHuruf` lewat `NarrationLine`, `tools/validate_content.dart`.
- 03: `lib/widgets/game/game_mode_pill.dart` (`GameModePill`, `GameModeTab`), `game_instruction.dart` (`GameInstruction`), `answer_card.dart` (`AnswerCard`, `AnswerCardState`), `progress_dots.dart` (`ProgressDots`), `game_glyphs.dart` (`GameGlyph`, `GameGlyphKind`), dan nama provider TTS hasil Task 2 Rencana 03 (`deviceTtsProvider`, `FakeDeviceTts`).

## Global Constraints

- Flutter **3.50.0** lewat FVM. Semua perintah memakai `fvm flutter …` / `fvm dart …`.
- Tidak ada paket baru. Tidak ada analytics, crash reporting, ikon, atau font dari paket luar.
- Material diimpor dari `package:material_ui/material_ui.dart`; file yang hanya butuh lapisan widget memakai `package:flutter/widgets.dart`.
- **Aturan permainan hidup di `*_game.dart`** (K11): jumlah pasangan, set huruf balon, ukuran kisi puzzle, jumlah pilihan Bayangan, dan daftar ukuran Besar & Kecil. Tidak ada satu pun angka kesulitan di `katalog.json`, `assets/content/`, atau widget layar.
- **Dart murni:** `cocokkan_game.dart`, `memori_game.dart`, `bayangan_game.dart`, `puzzle_game.dart`, `balon_game.dart`, dan `besar_kecil_game.dart` tidak mengimpor Flutter. Semua keacakan datang dari parameter `Random`; layar mengambilnya dari `gameRandomProvider`, dan tes menggantinya dengan `Random(seed)`.
- **Hadiah:** hanya `HadiahController.finishGame(gameId: <nama permainan>, roundId: <id ronde>)`. Tidak ada `addStars`, `addSticker`, atau `markItem` dari layar permainan. `gameId` = `MainYukGame.id`.
- **`roundId` unik sepanjang sesi aplikasi** lewat `mainYukRoundSeqProvider`: `'<gameId>-<n>'` dengan `n` naik global. Nomor ronde milik layar (yang mulai dari 1 setelah layar dibangun ulang) tidak boleh dipakai, karena `finishGame` menyimpan hasil per `'$gameId/$roundId'` dan akan menyajikan hadiah lama tanpa menambah bintang.
- **Permainan berakhir di Hebat:** setiap ronde yang selesai membuka `/hebat` lewat `push`. Hanya layar permainan yang membuka `/hebat`; hub tidak.
- **Lanjutkan:** setiap layar permainan mencatat `setLastActivity(<rute>)` saat dibuka, tanpa `param`. Tidak ada `markItem`, karena `RingkasanModul` tidak punya baris permainan (D11).
- **Layout:** setiap layar adalah `MociStage` dengan builder `tablet` berukuran 1180 × 820. HP memakai desain tablet yang diperkecil (D12) sampai Rencana 08; tidak ada builder `phone`.
- Target sentuh **64 pt** tablet, jarak **16 pt**, margin tepi **32 pt**. Kontras teks minimal **4,5 : 1**. Tekan: turun **5 pt**, skala **0,97**, **120 ms**. Muncul: **400–550 ms**, kurva `Cubic(0.3, 1.6, 0.5, 1)`. Saat `MediaQuery.disableAnimations` aktif, denyut, goyang hiasan, dan balon mengapung berhenti, tetapi umpan balik benar/salah tetap muncul.
- **Dua bahasa setara:** semua teks lewat gen-l10n dan bisa berganti saat layar terbuka. Kunci bernama `<layar><KunciT>` (`cocokkanShuffle`, `memoriMoves`); kunci bersama enam permainan berawalan `mainYuk` (`mainYukPairs`, `mainYukTemaBuah`). Teks dinamis yang dibacakan diberi `"description": "narasi"`.
- **Narasi:** id baris narasi harus sama dengan nama di `lib/core/content/narasi.dart`: `ui_<kunciArb>` untuk kunci ARB bertanda narasi, `nama_<id>` untuk nama benda katalog, `huruf_<huruf kecil>` untuk huruf. Kalimat prototipe yang menggabung dua potongan (`match: '! Cocok!'`) dipecah menjadi baris utuh yang dibacakan berurutan.
- Teks permainan tidak mengikuti ukuran teks sistem (`textScaleCap` 1,0 sudah bawaan `MociStage`).
- Tidak ada unduhan saat aplikasi berjalan. Bayangan dan keping puzzle dibuat dari `assets/illustrations/` yang sudah ada; tidak ada berkas gambar baru.
- Efek suara hanya dari enum `Sfx` (`klik`, `benar`, `salahLembut`, `sorak`, `bintang`). Tidak ada buzzer.
- Tidak ada `TODO`, placeholder, teks Inggris hardcoded di widget, atau `pumpAndSettle` di tes (MociMascot beranimasi terus; pakai `t.pump(Duration)` berbatas).

## Review Focus

1. **Anak mengetuk pasangan/kartu terakhir dua kali, atau mengetuk lagi saat layar Hebat sedang masuk.** Satu ronde hanya boleh memberi satu hadiah dan membuka Hebat sekali. Dipatok di Task 2 (`ketukan kedua pada pasangan terakhir tidak menambah hadiah`) dan Task 2 (`Main lagi dari Hebat memberi ronde baru dan hadiah baru`).
2. **Kartu Memori ketiga dibuka saat dua masih terbuka, atau kartu yang sama diketuk dua kali.** Maksimal dua kartu terbuka; langkah dihitung sekali per percobaan; pasangan yang sudah ketemu tidak bisa dibuka lagi. Dipatok di Task 3 (`dua kartu terbuka dan kartu ketiga diabaikan`) dan tes model Task 3 (`pasangan salah menutup dua kartu setelah langkah`).
3. **Garis Cocokkan dilepas di luar kartu, di kartu yang sudah cocok, atau di kartu kosong.** Tidak boleh ada pasangan palsu, pilihan harus kosong lagi, dan garis harus mengikuti jari tanpa tersendat (digambar `CustomPainter`, bukan tumpukan widget). Dipatok di Task 2 (`lepas di luar kartu tidak mencocokkan`, `garis mengikuti jari sampai kartu pasangannya`).
4. **Tingkat kesulitan usia tidak terpakai.** Pemula harus melihat Balon 9 huruf, Puzzle 2 × 2, Bayangan 3 pilihan, dan Besar & Kecil 3 ukuran; Pembaca 23 huruf, 3 × 3, 4 pilihan, 4 ukuran. Dipatok di Task 5 (`papan 2 × 2 untuk pemula, 3 × 3 untuk pembaca`), Task 6 (`pemula hanya sembilan huruf`), Task 4 (`pembaca memakai empat pilihan`), dan Task 7 (`pembaca memakai empat ukuran`).
5. **Label panjang atau isi yang banyak:** kartu "Besar & Kecil" di hub, "Mainan & Benda" di pil tema, 8 pasang Memori dari tema Kendaraan (9 benda), dan hub di layar HP 844 × 390. Tidak boleh ada overflow, teks terpotong, atau `takeException`. Dipatok di Task 1 (`kartu hub tidak overflow di HP`) dan Task 3 (`delapan pasang dari tema kendaraan`).

## Keputusan rencana ini

| Kode | Keputusan | Alasan |
| --- | --- | --- |
| M1 | Kesulitan mengikuti `prefs.ageLevel` dengan tabel tetap per permainan: Cocokkan 3/4/5 pasang, Memori 4/6/8 pasang, Bayangan 3/3/4 pilihan, Puzzle 2 × 2 / 3 × 2 / 3 × 3, Balon 9/23/23 huruf, Besar & Kecil 3/3/4 ukuran (pemula → penjelajah → pembaca). Angka ini tinggal di `*_game.dart`, bukan di katalog (K11). | PRD kolom "Menyesuaikan usia"; K11. |
| M2 | Hanya Cocokkan dan Memori yang menampilkan pil level seperti prototipe (`3/4/5 pasang`, `4/6/8 pasang`); nilainya mulai dari level usia dan boleh diganti anak. Empat permainan lain mengikuti level usia saja, karena artboard-nya memang tanpa pil level. Ronde pertama tiap layar memakai tema tetap yang sudah terpilih di pilnya: Cocokkan `buah`, Memori `hewan`; `acak` hanya dipilih lewat ketukan anak. | Prototipe dan PRD; pil level adalah cara prototipe memberi variasi. Tema tetap membuat ronde pertama tidak berubah-ubah. |
| M3 | Lencana usia di kartu hub disalin statis dari prototipe ("Usia 2+", "Usia 3+", "Usia 4+"): itu usia minimum permainan, bukan level yang dipakai. | Lencana menjelaskan permainan; kesulitan sudah mengikuti profil. |
| M4 | Parameter ronde (jumlah pasangan, kisi, set huruf, jumlah ukuran) dibekukan saat ronde dibuat. Perubahan level usia di Area Orang Tua berlaku pada ronde berikutnya, bukan dengan membangun ulang ronde yang sedang berjalan. | Menghindari papan berubah di tengah permainan; anak tidak kehilangan progres. |
| M5 | `roundId` berasal dari `mainYukRoundSeqProvider` (Notifier<int> milik sesi aplikasi), bukan penghitung milik layar. | `finishGame` menyimpan `'$gameId/$roundId'`; layar yang dibangun ulang setelah "Main lagi" akan mulai dari ronde 1 lagi dan hadiah kedua diam-diam hilang. |
| M6 | Ronde selesai → `finishGame` → `push('/hebat')`. Tidak ada kartu "selesai" dengan tombol "Main lagi"/"Ambil hadiah" seperti prototipe; tombol itu pindah ke Hebat (`hebatAgain`, `hebatNext`). | PRD: permainan berakhir ditutup Hebat; satu jalur hadiah, tidak ada ronde yang berakhir tanpa bintang. |
| M7 | Jawaban benar terakhir tetap memakai umpan baliknya sendiri, lalu Hebat dibuka setelah jeda dari prototipe: Bayangan 1500 ms (agar bayangan berubah warna terlihat), Balon 1000 ms (agar balon pecah terlihat), Besar & Kecil 1300 ms. Cocokkan, Memori, dan Puzzle membuka Hebat seketika. Kalimat "great" prototipe tidak dipakai karena Hebat sudah membacakan pujiannya. | Umpan balik akhir tetap terlihat tanpa narasi yang saling memotong. |
| M8 | Layar permainan mencatat `setLastActivity(route)` saat dibuka dan tidak pernah `markItem`. | `RingkasanModul` menghitung isi konten (huruf, angka, hewan, …); tidak ada modul permainan (D11). |
| M9 | Semua keacakan lewat `gameRandomProvider` (`Provider<Random>`); model murni menerima `Random` sebagai parameter. | Aturan AGENTS: permainan harus bisa diuji dengan `Random(seed)`. |
| M10 | Kartu hub membacakan judul permainan lalu `push` rutenya (sama seperti kartu Beranda). Layar permainan `push('/hebat')`, dan tombol Hebat memakai `go`, sehingga tumpukan kembali tidak pernah menuju ronde yang sudah selesai. | D7/back stack; perilaku Hebat yang sudah ada di Rencana 01. |
| M11 | Ilustrasi memakai `Item.id` langsung (`MociIllustration(item.id)`), karena eksportir Rencana 02 menulis `gambar: 'illustrations/<id>.svg'`. Tidak ada pemetaan gambar baru. | Satu sumber id; Bayangan memakai `silhouette: true` + `Opacity(0.78)` dari filter prototipe. |
| M12 | Bayangan, Balon, dan Besar & Kecil memakai `ProgressDots` dengan 6/5/6 titik dan satu pil kemajuan; Cocokkan dan Memori tidak memakai titik, tetapi pil jumlah pasangan dan pil langkah seperti prototipe. | Prototipe; titik hanya untuk permainan berronde tetap. |
| M13 | Set huruf Balon disalin persis: `ABCIMOPSU` (9, pemula) dan `ABCDEFGHIJKLMNOPRSTUWYZ` (23, penjelajah dan pembaca). Sepuluh huruf lain (J, K, Q, V, X, …) tidak muncul di level yang lebih kecil. | PRD "9 huruf untuk 2–3 tahun, 23 huruf untuk usia lain"; K11. |

## Peta file

```
lib/features/main_yuk/main_yuk_game.dart        # enum MainYukGame + MainYukTema + pilihTema + baris narasi
lib/features/main_yuk/game_round.dart           # gameRandomProvider, mainYukRoundSeqProvider, selesaikanRonde
lib/features/main_yuk/game_scaffold.dart        # MociStage + MociTopBar untuk tujuh layar
lib/features/main_yuk/hub_screen.dart           # hub Main Yuk! (enam kartu)
lib/features/main_yuk/cocokkan_game.dart        # ronde + sesi Cocokkan (Dart murni)
lib/features/main_yuk/cocokkan_screen.dart      # papan 800 × 660, garis jari, tema
lib/features/main_yuk/memori_game.dart          # ronde + sesi Memori (Dart murni)
lib/features/main_yuk/memori_screen.dart        # kisi 4/6/8 pasang, maksimal dua terbuka
lib/features/main_yuk/bayangan_game.dart        # ronde + skor Bayangan (Dart murni)
lib/features/main_yuk/bayangan_screen.dart      # bayangan + 3/4 pilihan, 6 ronde
lib/features/main_yuk/puzzle_game.dart           # kisi + sesi Puzzle (Dart murni)
lib/features/main_yuk/puzzle_screen.dart        # papan 480 + baki keping
lib/features/main_yuk/balon_game.dart           # set huruf + ronde Balon (Dart murni)
lib/features/main_yuk/balon_screen.dart         # enam balon, target diulang dua kali
lib/features/main_yuk/besar_kecil_game.dart     # ukuran + ronde Besar & Kecil (Dart murni)
lib/features/main_yuk/besar_kecil_screen.dart   # tiga atau empat ukuran, tanya bergantian
lib/app/router.dart                             # /main dan enam rute permainan menggantikan _soon
l10n/app_id.arb, l10n/app_en.arb                # kunci mainYuk*, cocokkan*, memori*, …
integration_test/app_test.dart                  # skenario "puzzle → Hebat → Beranda"
```

Komponen `lib/widgets/game/*` dan nama tipe di Rencana 03 adalah kontrak: Rencana 06 memakainya apa adanya dan tidak mengubahnya. Kalau sebuah komponen ternyata kurang satu parameter, perbaikan dilakukan di rencana ini dengan menyebut perubahan itu di commit pesannya, dan Rencana 04–05 ikut memakainya.

---

### Task 1: Fondasi Main Yuk (hub, nomor ronde, jalur hadiah)

**Files:**
- Create: `lib/features/main_yuk/main_yuk_game.dart`, `lib/features/main_yuk/game_round.dart`, `lib/features/main_yuk/game_scaffold.dart`, `lib/features/main_yuk/hub_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/main_yuk_game_test.dart`, `test/features/main_yuk/hub_screen_test.dart`

**Interfaces:**
- Consumes: `Routes`, `MenuTheme`, `MociStage`, `MociTopBar`, `MociBackButton`, `MociPressable`, `MociIllustration`, `MociMascot`, `StarCounter`, `Narrator`, `hadiahProvider`, `HebatArgs`, `progressProvider`, `katalogProvider`, `prefsProvider`.
- Produces (dipakai Task 2–8):
  - `enum MainYukGame { cocokkan(Routes.cocokkan, Color(0xFFFF7EB6), Color(0xFFE0528F), 2), memori(Routes.memori, Color(0xFF4DA8FF), Color(0xFF2A84E0), 3), bayangan(Routes.bayangan, Color(0xFF9775FA), Color(0xFF7048E8), 2), puzzle(Routes.puzzle, Color(0xFFFFB020), Color(0xFFE0870B), 3), balon(Routes.balon, Color(0xFF22C1C3), Color(0xFF129A9C), 4), besarKecil(Routes.besarKecil, Color(0xFF5FD068), Color(0xFF3BAA45), 2) }` dengan `route`, `color`, `shadow`, `usiaMinimum`, `String get id => name`, `String labelHub(AppLocalizations)` (kunci `mainYukCocokkanHub`, `mainYukMemoriHub`, `mainYukBayanganHub`, `mainYukPuzzleHub`, `mainYukBalonHub`, `mainYukBesarKecilHub`), dan `String labelUsia(AppLocalizations)` (`mainYukAge2/3/4`). Judul di bilah atas tiap permainan memakai kunci layarnya sendiri (`cocokkanTitle`, …) yang ditambahkan task permainan itu.
  - `enum MainYukTema { acak, buah, hewan, sayur, kendaraan, benda }` dengan `String? get kategori` (`acak` = null), `String label(AppLocalizations)`, dan `static const pilihan = [acak, buah, hewan, sayur, kendaraan, benda]`.
  - `({MainYukTema tema, List<Item> item}) pilihTema(Katalog katalog, MainYukTema tema, {required Random random, MainYukTema? hindari})` — `acak` memilih satu dari lima kategori selain `hindari`; hasil `item` diambil dari `katalog.byKategori(tema.kategori!)`.
  - `NarrationLine barisUi(String id, String text)`, `NarrationLine barisNama(String id, String text)`, `NarrationLine barisHuruf(String huruf, String text)` — `barisHuruf` memakai `huruf.toLowerCase()` sebagai id.
  - `final gameRandomProvider = Provider<Random>((_) => Random());`
  - `final class MainYukRoundSeq extends Notifier<int>` dengan `String next(String gameId)` (`state += 1; return '$gameId-$state'`) dan `final mainYukRoundSeqProvider = NotifierProvider<MainYukRoundSeq, int>(MainYukRoundSeq.new);`
  - `Future<void> selesaikanRonde(BuildContext context, WidgetRef ref, {required String gameId, required String roundId, required String replayRoute})` — `finishGame`, lalu `context.push(Routes.hebat, extra: HebatArgs(award: award, replayRoute: replayRoute))` bila `context.mounted`.
  - `class GameScaffold extends StatelessWidget { const GameScaffold({super.key, required this.theme, required this.title, this.trailing = const [], required this.children}); }` — `MociStage(theme: theme, tablet: …)` berisi `SizedBox(1180 × 820)` dengan `Stack`: `Positioned(left: 0, right: 0, top: 0, child: MociTopBar(leading: MociBackButton(), title: title, trailing: trailing))` lalu `...children`. `static const barKey = ValueKey('game-top-bar');`
  - `class HubScreen extends ConsumerWidget` dengan `static ValueKey<String> cardKey(MainYukGame g) => ValueKey('main-yuk-${g.name}');` dan `static const ageKeyPrefix = 'main-yuk-age-'`. Tata letak `MociStage(MenuTheme.mainYuk)`: bilah atas sendiri (bukan `MociTopBar`) berisi kembali 76, judul `menuMainTitle` 46, subjudul `mainYukSub` 18 warna `#3D7F80`, lalu `StarCounter`; kisi 1042 × 606 di (69, 136) berisi 3 kolom × 2 baris kartu 276 tinggi, jarak baris 30 dan kolom 26, radius 40, bayangan 12, seni kartu dari ilustrasi katalog (Cocokkan dua kartu kembar, Memori tiga kartu, Bayangan gambar + siluetnya, Puzzle empat keping, Balon tiga balon A/B/C, Besar & Kecil 56/84/118), pil putih 70 di bawah berisi judul 24 dan lencana usia 15 (latar `#F3EEFF`, tinta `#5032B8`); Moci 120 mengintip di (1040, 700).
  - Perilaku hub: ketukan membacakan `barisUi(<kunci labelHub>, g.labelHub(l10n))` lalu `context.push(g.route)`.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/main_yuk_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');

Katalog _katalogLima() => Katalog(item: [
  for (final k in ['buah', 'hewan', 'sayur', 'kendaraan', 'benda'])
    for (var i = 0; i < 3; i++) _item('$k$i', k),
]);

test('enam permainan: rute, warna, dan usia minimum dari prototipe', () {
  expect(MainYukGame.values.map((g) => g.route), [
    '/main/cocokkan', '/main/memori', '/main/bayangan',
    '/main/puzzle', '/main/balon', '/main/besar-kecil']);
  expect(MainYukGame.values.map((g) => g.usiaMinimum), [2, 3, 2, 3, 4, 2]);
  expect(MainYukGame.balon.id, 'balon');
});
test('tema acak memilih kategori selain tema sebelumnya', () {
  final k = _katalogLima();
  for (var seed = 0; seed < 8; seed++) {
    final p = pilihTema(k, MainYukTema.acak,
        random: Random(seed), hindari: MainYukTema.hewan);
    expect(p.tema, isNot(MainYukTema.hewan));
    expect(p.item, isNotEmpty);
    expect(p.item.every((i) => i.kategori == p.tema.kategori), isTrue);
  }
});
test('tema tetap mengembalikan benda kategorinya saja', () {
  final p = pilihTema(_katalogLima(), MainYukTema.buah, random: Random(1));
  expect(p.tema, MainYukTema.buah);
  expect(p.item.map((i) => i.id), ['buah0', 'buah1', 'buah2']);
});
test('nomor ronde naik dan unik lintas layar', () {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  final seq = c.read(mainYukRoundSeqProvider.notifier);
  expect(seq.next('puzzle'), 'puzzle-1');
  expect(seq.next('puzzle'), 'puzzle-2');
  expect(seq.next('balon'), 'balon-3');
});
test('baris narasi memakai jenis dan id yang benar', () {
  expect(barisHuruf('B', 'be').id, 'b');
  expect(barisHuruf('B', 'be').jenis, 'huruf');
  expect(barisNama('apel', 'Apel').jenis, 'nama');
  expect(barisUi('cocokkanMatch', 'Cocok!').jenis, 'ui');
});
```

`test/features/main_yuk/hub_screen_test.dart`:
```dart
testWidgets('hub: enam kartu, lencana usia, dan bintang', (t) async {
  await pumpApp(t, initialLocation: '/main');
  expect(find.text('Main Yuk!'), findsOneWidget);
  expect(find.text('Pilih permainan'), findsOneWidget);
  for (final g in MainYukGame.values) {
    expect(find.byKey(HubScreen.cardKey(g)), findsOneWidget);
  }
  expect(find.text('Cocokkan Gambar'), findsOneWidget);
  expect(find.text('Kartu Memori'), findsOneWidget);
  expect(find.text('Besar & Kecil'), findsOneWidget);
  expect(find.text('Usia 2+'), findsNWidgets(3));
  expect(find.text('Usia 3+'), findsNWidgets(2));
  expect(find.text('Usia 4+'), findsOneWidget);
  expect(find.byType(StarCounter), findsOneWidget);
});
testWidgets('hub: ketuk kartu membacakan judul lalu membuka rutenya', (t) async {
  final env = TestEnv();
  final router = await pumpApp(t, env: env, initialLocation: '/main');
  await t.tap(find.byKey(HubScreen.cardKey(MainYukGame.memori)));
  await t.pump();
  await t.pump();
  expect(env.tts.spoken.single.$1, 'Kartu Memori');
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/main/memori');
});
testWidgets('hub: kembali ke Beranda', (t) async {
  final router = await pumpApp(t, initialLocation: '/main');
  await t.tap(find.bySemanticsLabel('Kembali ke beranda'));
  await t.pump();
  await t.pump();
  expect(router.routerDelegate.currentConfiguration.last.matchedLocation, '/');
});
testWidgets('hub: ganti bahasa mengganti subjudul dan lencana', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main');
  ProviderScope.containerOf(t.element(find.byType(MociApp)))
      .read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text("Let's Play!"), findsOneWidget);
  expect(find.text('Pick a game'), findsOneWidget);
  expect(find.text('Ages 2+'), findsNWidgets(3));
});
testWidgets('hub: kartu tidak overflow di HP 844 x 390', (t) async {
  await pumpApp(t, initialLocation: '/main', size: phoneSize);
  expect(find.byKey(HubScreen.cardKey(MainYukGame.besarKecil)), findsOneWidget);
  expect(t.takeException(), isNull);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk`. Expected: FAIL karena file `main_yuk_game.dart` dan `hub_screen.dart` belum ada, dan `/main` masih `ComingSoonScreen`.

- [ ] **Step 3: Implementasikan** enum, `pilihTema`, tiga helper narasi, `gameRandomProvider`, `MainYukRoundSeq`, `selesaikanRonde`, `GameScaffold`, dan `HubScreen` sesuai Interfaces. Ganti `_soon(Routes.mainYuk, MenuTheme.mainYuk)` dengan `GoRoute` `HubScreen`. Tambah ARB: `mainYukSub` "Pilih permainan" / "Pick a game"; `mainYukAge2` "Usia 2+" / "Ages 2+"; `mainYukAge3` "Usia 3+" / "Ages 3+"; `mainYukAge4` "Usia 4+" / "Ages 4+"; `mainYukCocokkanHub` "Cocokkan Gambar" / "Match Pictures"; `mainYukMemoriHub` "Kartu Memori" / "Memory Cards"; `mainYukBayanganHub` "Tebak Bayangan" / "Shadow Match"; `mainYukPuzzleHub` "Puzzle" / "Jigsaw Puzzle"; `mainYukBalonHub` "Balon Huruf" / "Letter Balloons"; `mainYukBesarKecilHub` "Besar & Kecil" / "Big & Small"; `mainYukTemaAcak` "Acak!" / "Surprise!"; `mainYukTemaBuah` "Buah" / "Fruits"; `mainYukTemaHewan` "Hewan" / "Animals"; `mainYukTemaSayur` "Sayur" / "Veggies"; `mainYukTemaKendaraan` "Kendaraan" / "Vehicles"; `mainYukTemaBenda` "Mainan & Benda" / "Toys & Things"; `mainYukPairs` "{n} pasang" / "{n} pairs" (placeholder `int n`); `mainYukMoves` "Langkah: {n}" / "Moves: {n}"; `gameLevel` "Level" / "Level". Judul hub memakai `menuMainTitle` yang sudah ada. Jalankan `fvm flutter gen-l10n`. Seni kartu memakai `katalogProvider` (`byId('kucing')`, `byId('apel')`, dan ilustrasi lain yang ada di `assets/illustrations/`); tidak ada berkas baru.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk test/features/beranda`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): hub Main Yuk dengan enam kartu, nomor ronde, dan jalur hadiah`.

---

### Task 2: Cocokkan

**Files:**
- Create: `lib/features/main_yuk/cocokkan_game.dart`, `lib/features/main_yuk/cocokkan_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/cocokkan`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/cocokkan_game_test.dart`, `test/features/main_yuk/cocokkan_screen_test.dart`

**Interfaces:**
- Consumes: `Katalog.byKategori`, `Item`, `MainYukGame.cocokkan`, `MainYukTema`, `pilihTema`, `GameScaffold`, `GameModePill`, `GameModeTab`, `GameInstruction`, `MociPressable`, `MociIllustration`, `MociMascot`, `Narrator`, `Sfx`, `gameRandomProvider`, `mainYukRoundSeqProvider`, `selesaikanRonde`, `prefsProvider`, `progressProvider`.
- Produces:
  - `enum CocokkanSisi { kiri, kanan }`
  - `enum CocokkanStep { abaikan, pilih, cocok, salah, selesai }`
  - `int cocokkanPasangan(AgeLevel usia)` → 3/4/5.
  - `final class CocokkanRonde { const CocokkanRonde({required this.tema, required this.kiri, required this.kanan}); final MainYukTema tema; final List<String> kiri, kanan; int get jumlah; }` — `kiri` = id terpilih berurutan, `kanan` = id yang sama setelah diacak, dan tidak boleh sama persis dengan `kiri` bila `jumlah > 1`.
  - `CocokkanRonde buatCocokkan(Katalog katalog, {required int pasangan, required MainYukTema tema, required Random random, MainYukTema? sebelumnya})`.
  - `final class CocokkanSesi { CocokkanSesi(this.ronde); final CocokkanRonde ronde; CocokkanSisi? get sisiDipilih; int? get indeksDipilih; final Map<int, int> cocok; bool terpasang(CocokkanSisi sisi, int indeks); CocokkanStep ketuk(CocokkanSisi sisi, int indeks); bool get selesai; void ulang(); }` — ketuk kartu yang sudah cocok → `abaikan` tanpa mengubah pilihan; ketuk sisi yang sama → `pilih` dan pilihan berpindah; dua sisi berbeda yang id-nya sama → `cocok` (atau `selesai` bila pasangan terakhir) dan pilihan kosong; id berbeda → `salah` dan pilihan kosong.
  - `class CocokkanScreen extends ConsumerStatefulWidget` dengan `static const boardKey = ValueKey('cocokkan-board');`, `static ValueKey<String> kartuKey(CocokkanSisi sisi, int i) => ValueKey('cocokkan-${sisi.name}-$i');`, `static ValueKey<int> garisKey(int kiri) => ValueKey('cocokkan-garis-$kiri');`, `static ValueKey<MainYukTema> temaKey(MainYukTema t)`, `static const shuffleKey = ValueKey('cocokkan-shuffle');`
  - Tata letak `GameScaffold(theme: MenuTheme.cocokkan, title: cocokkanTitle, trailing: [GameModePill(3/4/5 pasang), tombol shuffle])`: papan putih 800 × 660 di (190, 118) radius 44; `GameInstruction` di dalam papan (190, 140) dengan `title` = judul tema, `text` = `cocokkanIns`, `narration` = `[barisUi('cocokkanInst', …)]`, `listenLabel` = `cocokkanHear`; kartu bulat 130 (3 pasang) / 108 (4) / 88 (5), kiri di x 110, kanan di x `690 - ukuran`, y = `132 + gap + i * (ukuran + gap)` dengan `gap = (640 - 132 - n * ukuran) / (n + 1)`, ilustrasi 72% ukuran, cincin 7 `#F3D9E5` (terpilih `#E64980`, cocok warna palet `[#E64980, #1C7ED6, #2F9E44, #F08C00, #7048E8]`); garis cocok kubik 10 dari tepi kanan kartu kiri (+21) ke tepi kiri kartu kanan (−21) dalam satu `CustomPainter` per pasangan (kunci `garisKey`), garis jari putus-putus `#E64980` + titik 12 selama `Listener` bergerak; kolom tema 146 di (1010, 130) berisi label `cocokkanTema` dan enam pil `MainYukTema.pilihan`; tip + Moci 150 di (24, 520)/(24, 652).
  - Ronde pertama memakai `MainYukTema.buah` dengan pil itu terpilih (M2); `acak` hanya dipilih lewat ketukan anak.
  - Perilaku: buka layar → `setLastActivity(Routes.cocokkan)` + `sayAll([barisUi('cocokkanInst', …)])`. Ketuk kartu → `sayAll([barisNama(id, nama)])`. Cocok → `Sfx.benar` + `sayAll([barisNama(id, nama), barisUi('cocokkanMatch', …)])`. Salah → `Sfx.salahLembut` + `sayAll([barisUi('cocokkanRetry', …)])` + goyang 450 ms. Pil level, pil tema, dan shuffle membuat ronde baru (ronde baru = `mainYukRoundSeqProvider.next('cocokkan')`). Ronde selesai → `selesaikanRonde(gameId: 'cocokkan', roundId: <ronde itu>, replayRoute: Routes.cocokkan)` **sekali**, dijaga `bool _selesai`.
  - Geser: `Listener` `onPointerDown/Move/Up` pada papan. Lepas dengan jarak < 12 px → dianggap ketuk. Lepas di atas kartu sisi lain (radius `ukuran / 2 + 18`) → percobaan cocok; lepas di luar kartu atau di kartu yang sudah cocok → batal tanpa efek.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/cocokkan_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');
Katalog _katalogBuah([int n = 6]) => Katalog(item: [
  for (var i = 0; i < n; i++) _item('b$i', 'buah')]);

CocokkanRonde _rondeTetap() => const CocokkanRonde(tema: MainYukTema.buah,
  kiri: ['a', 'b', 'c'], kanan: ['c', 'a', 'b']);

test('pasangan mengikuti level usia', () {
  expect(cocokkanPasangan(AgeLevel.pemula), 3);
  expect(cocokkanPasangan(AgeLevel.penjelajah), 4);
  expect(cocokkanPasangan(AgeLevel.pembaca), 5);
});
test('ronde berisi pasangan unik dan kolom kanan teracak', () {
  final r = buatCocokkan(_katalogBuah(), pasangan: 4,
      tema: MainYukTema.buah, random: Random(7));
  expect(r.kiri, hasLength(4));
  expect(r.kanan.toSet(), r.kiri.toSet());
  expect(r.kanan, isNot(r.kiri));
});
test('ketuk dua kartu sama menjadi cocok', () {
  final s = CocokkanSesi(_rondeTetap());
  expect(s.ketuk(CocokkanSisi.kiri, 0), CocokkanStep.pilih);
  expect(s.ketuk(CocokkanSisi.kanan, 1), CocokkanStep.cocok);
  expect(s.cocok, {0: 1});
  expect(s.sisiDipilih, isNull);
});
test('kartu yang sudah cocok diabaikan', () {
  final s = CocokkanSesi(_rondeTetap())
    ..ketuk(CocokkanSisi.kiri, 0)..ketuk(CocokkanSisi.kanan, 1);
  expect(s.ketuk(CocokkanSisi.kiri, 0), CocokkanStep.abaikan);
  expect(s.ketuk(CocokkanSisi.kanan, 1), CocokkanStep.abaikan);
});
test('pasangan salah mengosongkan pilihan', () {
  final s = CocokkanSesi(_rondeTetap());
  s..ketuk(CocokkanSisi.kiri, 0)..ketuk(CocokkanSisi.kanan, 0);
  expect(s.cocok, isEmpty);
  expect(s.sisiDipilih, isNull);
});
test('pasangan terakhir menyelesaikan sesi', () {
  final s = CocokkanSesi(_rondeTetap());
  for (var i = 0; i < 3; i++) {
    final j = _rondeTetap().kanan.indexOf(_rondeTetap().kiri[i]);
    s..ketuk(CocokkanSisi.kiri, i)..ketuk(CocokkanSisi.kanan, j);
  }
  expect(s.selesai, isTrue);
});
```
`_rondeTetap()` dipanggil ulang di dalam loop agar `kanan` tetap sumbernya; salin sekali ke variabel lokal di tes sebenarnya.

`test/features/main_yuk/cocokkan_screen_test.dart`:
```dart
String _label(WidgetTester t, CocokkanSisi s, int i) =>
  t.widget<MociPressable>(find.byKey(CocokkanScreen.kartuKey(s, i))).semanticLabel!;
int _cariKartu(WidgetTester t, CocokkanSisi s, String label) {
  for (var i = 0;
      find.byKey(CocokkanScreen.kartuKey(s, i)).evaluate().isNotEmpty;
      i++) {
    if (_label(t, s, i) == label) return i;
  }
  fail('tidak ada kartu ${s.name} "$label"');
}
Future<void> _ketukPasangan(WidgetTester t, CocokkanSisi s, int i) async {
  final label = _label(t, s, i);
  await t.tap(find.byKey(CocokkanScreen.kartuKey(s, i)));
  await t.pump(const Duration(milliseconds: 450));
  final lain = s == CocokkanSisi.kiri ? CocokkanSisi.kanan : CocokkanSisi.kiri;
  await t.tap(
    find.byKey(CocokkanScreen.kartuKey(lain, _cariKartu(t, lain, label))),
  );
  await t.pump(const Duration(milliseconds: 450));
}
Future<void> _selesaikan(WidgetTester t, int jumlah) async {
  for (var i = 0; i < jumlah; i++) {
    await _ketukPasangan(t, CocokkanSisi.kiri, i);
  }
}

testWidgets('layar cocokkan: tiga pasang, tema buah, dan instruksi', (t) async {
  await pumpApp(t, initialLocation: '/main/cocokkan');
  expect(find.text('Cocokkan!'), findsOneWidget);
  expect(find.text('Cocokkan Buah yang Sama'), findsOneWidget);
  expect(find.text('3 pasang'), findsOneWidget);
  expect(find.byKey(CocokkanScreen.boardKey), findsOneWidget);
  expect(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, 2)), findsOneWidget);
});
testWidgets('ketuk dua gambar sama menggambar garis dan bicara', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/cocokkan');
  final nama = _label(t, CocokkanSisi.kiri, 0);
  await _ketukPasangan(t, CocokkanSisi.kiri, 0);
  expect(find.byKey(CocokkanScreen.garisKey(0)), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1), containsAllInOrder([nama, 'Cocok!']));
});
testWidgets('garis mengikuti jari sampai kartu pasangannya', (t) async {
  await pumpApp(t, initialLocation: '/main/cocokkan');
  final dari = t.getRect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)));
  final pasangan = _cariKartu(t, CocokkanSisi.kanan,
      _label(t, CocokkanSisi.kiri, 0));
  final ke = t.getRect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, pasangan)));
  final g = await t.startGesture(dari.center);
  await g.moveTo(Offset.lerp(dari.center, ke.center, 0.5)!);
  await t.pump();
  expect(find.byKey(CocokkanScreen.garisJariKey), findsOneWidget);
  await g.moveTo(ke.center);
  await g.up();
  await t.pump();
  expect(find.byKey(CocokkanScreen.garisKey(0)), findsOneWidget);
});
testWidgets('lepas di luar kartu tidak mencocokkan', (t) async {
  await pumpApp(t, initialLocation: '/main/cocokkan');
  final dari = t.getRect(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)));
  final g = await t.startGesture(dari.center);
  await g.moveTo(dari.center + const Offset(-150, 0));
  await g.up();
  await t.pump();
  expect(find.byKey(CocokkanScreen.garisKey(0)), findsNothing);
});
testWidgets('pasangan salah memanggil narasi coba lagi', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/cocokkan');
  final salah = _label(t, CocokkanSisi.kanan, 0) == _label(t, CocokkanSisi.kiri, 0) ? 1 : 0;
  await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, salah)));
  await t.pump();
  expect(env.tts.spoken.last.$1, 'Ups, coba lagi ya!');
  expect(find.text('Pilih satu gambar!'), findsOneWidget);
});
testWidgets('semua pasang membuka Hebat dan memberi tiga bintang', (t) async {
  await pumpApp(t, initialLocation: '/main/cocokkan');
  await _selesaikan(t, 3);
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
  expect(_progress(t).stickers, hasLength(1));
});
testWidgets('ketukan kedua pada pasangan terakhir tidak menambah hadiah', (t) async {
  await pumpApp(t, initialLocation: '/main/cocokkan');
  await _selesaikan(t, 2);
  final nama = _label(t, CocokkanSisi.kiri, 2);
  final kanan = _cariKartu(t, CocokkanSisi.kanan, nama);
  await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 2)));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, kanan)));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, kanan)));
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
testWidgets('Main lagi dari Hebat memberi ronde baru dan hadiah baru', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/cocokkan');
  await _selesaikan(t, 3);
  await t.pump();
  await t.pump();
  await t.tap(find.text('Main lagi'));
  await t.pump();
  await t.pump();
  expect(find.text('Cocokkan!'), findsOneWidget);
  await _selesaikan(t, 3);
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 6);
});
testWidgets('ganti bahasa mengganti judul tema', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/cocokkan');
  ProviderScope.containerOf(t.element(find.byType(MociApp)))
      .read(prefsProvider.notifier).setLang(AppLang.en);
  await t.pump();
  expect(find.text('Match the same fruits'), findsOneWidget);
});
```
`_progress(t)` di semua tes permainan membaca provider yang sama:
```dart
Progress _progress(WidgetTester t) => ProviderScope
    .containerOf(t.element(find.byType(MociApp)))
    .read(progressProvider);
```
Berkas tes mengimpor `package:moci/app/moci_app.dart`, `package:moci/core/progress/progress_controller.dart`, `package:moci/features/hadiah/hebat_screen.dart`, dan `test/helpers/harness.dart`.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/cocokkan_game_test.dart test/features/main_yuk/cocokkan_screen_test.dart`. Expected: FAIL karena file belum ada dan `/main/cocokkan` masih `ComingSoonScreen`.

- [ ] **Step 3: Implementasikan** model dan layar sesuai Interfaces; ganti `_soon(Routes.cocokkan, MenuTheme.cocokkan)`. Tambah `garisJariKey` (`ValueKey('cocokkan-garis-jari')`) ke daftar kunci layar. ARB baru: `cocokkanTitle` "Cocokkan!" / "Match It!"; `cocokkanTema` "Tema" / "Theme"; `cocokkanShuffle` "Gambar baru" / "New pictures"; `cocokkanHear` "Dengarkan petunjuk" / "Listen to the instructions"; `cocokkanIns` "Tarik garis atau ketuk dua gambar yang sama" / "Draw a line, or tap two pictures that are the same"; `cocokkanInst` (narasi) "Tarik garis dari gambar ke gambar yang sama." / "Draw a line from a picture to the one that is the same."; `cocokkanHeadBuah` "Cocokkan Buah yang Sama" / "Match the same fruits"; `cocokkanHeadHewan` "Cocokkan Hewan yang Sama" / "Match the same animals"; `cocokkanHeadSayur` "Cocokkan Sayur yang Sama" / "Match the same veggies"; `cocokkanHeadKendaraan` "Cocokkan Kendaraan yang Sama" / "Match the same vehicles"; `cocokkanHeadBenda` "Cocokkan Mainan & Benda yang Sama" / "Match the same toys & things"; `cocokkanMatch` (narasi) "Cocok!" / "Match!"; `cocokkanRetry` (narasi) "Ups, coba lagi ya!" / "Oops, try again!"; `cocokkanTipPick` "Pilih satu gambar!" / "Pick a picture!"; `cocokkanTipNext` "Sekarang cari yang sama!" / "Now find the same one!"; `cocokkanTipDone` "Horee!" / "Hooray!". Jalankan `fvm flutter gen-l10n`.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Cocokkan dengan garis jari dan pasangan tema`.

---

### Task 3: Kartu Memori

**Files:**
- Create: `lib/features/main_yuk/memori_game.dart`, `lib/features/main_yuk/memori_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/memori`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/memori_game_test.dart`, `test/features/main_yuk/memori_screen_test.dart`

**Interfaces:**
- Consumes: `Katalog.byKategori`, `Item`, `MainYukGame.memori`, `MainYukTema`, `pilihTema`, `GameScaffold`, `GameModePill`, `MociPressable`, `MociIllustration`, `Narrator`, `Sfx`, `gameRandomProvider`, `mainYukRoundSeqProvider`, `selesaikanRonde`, `prefsProvider`, `progressProvider`.
- Produces:
  - `int memoriPasangan(AgeLevel usia)` → 4/6/8.
  - `final class MemoriRonde { const MemoriRonde({required this.tema, required this.deck}); final MainYukTema tema; final List<String> deck; int get pasangan => deck.length ~/ 2; }` — setiap id muncul tepat dua kali, urutan teracak.
  - `MemoriRonde buatMemori(Katalog katalog, {required int pasangan, required MainYukTema tema, required Random random, MainYukTema? sebelumnya})`.
  - `enum MemoriStep { abaikan, terbuka, sepasang, salah, selesai }`
  - `final class MemoriSesi { MemoriSesi(this.ronde); final MemoriRonde ronde; List<int> get terbuka; Set<String> get ketemu; int get langkah; MemoriStep buka(int indeks); void tutup(); bool get selesai; void ulang(); }` — `buka` mengabaikan indeks yang sudah `ketemu`, sudah terbuka, atau saat `terbuka.length == 2`; kartu kedua menaikkan `langkah` sekali; pasangan sama → `ketemu` + `sepasang`/`selesai`; beda → `salah` dan `tutup()` mengosongkan dua kartu.
  - `class MemoriScreen extends ConsumerStatefulWidget` dengan `static ValueKey<int> kartuKey(int i)`, `static ValueKey<MainYukTema> temaKey(MainYukTema t)`, `static const restartKey`, `static const langkahKey`.
  - Tata letak `GameScaffold(theme: MenuTheme.memori, title: memoriTitle, trailing: [GameModePill(4/6/8 pasang), pil langkah, tombol restart])`: baris pil tema di (32, 116) rata tengah (label `memoriTema` 17 `#3B5BDB` + pil `MainYukTema.pilihan` 48); kisi 4 kolom, kartu 210 × 230 (4 pasang) / 190 × 186 (6) / 146 × 140 (8), jarak 20 (≤6 pasang) atau 16, atur dari (590, 188), ilustrasi 66% sisi pendek; kartu tertutup radius 26 warna tema (`buah #FF6B6B/#E04848`, `hewan #22C1C3/#129A9C`, `sayur #5FD068/#3BAA45`, `kendaraan #3BA4FF/#1C7ED6`, `benda #9775FA/#7048E8`, `acak` memakai warna tema yang terpilih) dengan dua titik putih; kartu terbuka putih border 6 (hijau `#26A03B` saat pasangan ketemu, `#D3E3FF` selain itu) dan ilustrasi penuh; putaran balik 300 ms `AnimatedBuilder` (langsung 1,0 saat `disableAnimations`).
  - Ronde pertama memakai `MainYukTema.hewan` dengan pil itu terpilih (M2).
  - Perilaku: buka layar → `setLastActivity(Routes.memori)` + `sayAll([barisUi('memoriInst', …)])` + `sayAll([barisUi(label tema)])`. Ketuk kartu → `sayAll([barisNama(id, nama)])`. Pasangan → `Sfx.benar` + `sayAll([barisNama(id, nama), barisUi('memoriPair', …)])`; salah → setelah 950 ms `tutup()` (timer dibatalkan saat layar ditutup atau `Main baru`). Ronde selesai → `selesaikanRonde(gameId: 'memori', roundId: …, replayRoute: Routes.memori)` sekali. "Main baru", pil level, dan pil tema membuat ronde baru (`mainYukRoundSeqProvider.next('memori')`).

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/memori_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');
Katalog _katalogBuah([int n = 8]) => Katalog(item: [
  for (var i = 0; i < n; i++) _item('b$i', 'buah')]);

test('pasangan mengikuti level usia', () {
  expect(memoriPasangan(AgeLevel.pemula), 4);
  expect(memoriPasangan(AgeLevel.penjelajah), 6);
  expect(memoriPasangan(AgeLevel.pembaca), 8);
});
test('setiap id muncul dua kali dan teracak', () {
  final r = buatMemori(_katalogBuah(8), pasangan: 4,
      tema: MainYukTema.buah, random: Random(3));
  expect(r.deck, hasLength(8));
  expect(r.deck.toSet(), hasLength(4));
  for (final id in r.deck.toSet()) {
    expect(r.deck.where((e) => e == id), hasLength(2));
  }
});
test('pasangan salah menutup dua kartu setelah langkah', () {
  final s = MemoriSesi(const MemoriRonde(tema: MainYukTema.buah,
      deck: ['a', 'b', 'c', 'b', 'a', 'c']));
  expect(s.buka(0), MemoriStep.terbuka);
  expect(s.buka(1), MemoriStep.salah);
  expect(s.langkah, 1);
  s.tutup();
  expect(s.terbuka, isEmpty);
});
test('kartu ketiga diabaikan saat dua terbuka', () {
  final s = MemoriSesi(const MemoriRonde(tema: MainYukTema.buah,
      deck: ['a', 'b', 'c', 'b', 'a', 'c']));
  s..buka(0)..buka(1);
  expect(s.buka(2), MemoriStep.abaikan);
  expect(s.terbuka, [0, 1]);
  expect(s.langkah, 1);
});
test('pasangan cocok menetap dan selesai saat pasangan terakhir', () {
  final s = MemoriSesi(const MemoriRonde(tema: MainYukTema.buah,
      deck: ['a', 'b', 'a', 'b']));
  expect(s.buka(0), MemoriStep.terbuka);
  expect(s.buka(2), MemoriStep.sepasang);
  expect(s.ketemu, {'a'});
  expect(s.buka(1), MemoriStep.terbuka);
  expect(s.buka(3), MemoriStep.selesai);
});
```

`test/features/main_yuk/memori_screen_test.dart`:
```dart
testWidgets('layar memori: empat pasang untuk pemula, delapan kartu tertutup', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  expect(find.text('Kartu Memori'), findsOneWidget);
  expect(find.text('4 pasang'), findsOneWidget);
  expect(find.byKey(MemoriScreen.kartuKey(7)), findsOneWidget);
  expect(find.byKey(MemoriScreen.kartuKey(8)), findsNothing);
  expect(find.text('Langkah: 0'), findsOneWidget);
});
testWidgets('kartu tertutup berlabel tersembunyi', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  expect(t.widget<MociPressable>(find.byKey(MemoriScreen.kartuKey(0))).semanticLabel,
      'Kartu tertutup');
});
testWidgets('dua kartu terbuka dan kartu ketiga diabaikan', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  await t.tap(find.byKey(MemoriScreen.kartuKey(0)));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.byKey(MemoriScreen.kartuKey(1)));
  await t.pump();
  expect(find.text('Langkah: 1'), findsOneWidget);
  final labelPertama = _label(t, 1);
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.byKey(MemoriScreen.kartuKey(2)));
  await t.pump();
  // Kartu ketiga tidak membuka dan tidak menambah langkah, apa pun isi dek.
  expect(find.text('Langkah: 1'), findsOneWidget);
  expect(_label(t, 2), 'Kartu tertutup');
  expect(_label(t, 1), labelPertama);
});
testWidgets('pil delapan pasang mengganti papan', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  await t.tap(find.text('8 pasang'));
  await t.pump();
  expect(find.byKey(MemoriScreen.kartuKey(15)), findsOneWidget);
  expect(find.byKey(MemoriScreen.kartuKey(16)), findsNothing);
  expect(t.takeException(), isNull);
});
testWidgets('delapan pasang dari tema kendaraan tidak overflow', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  await t.tap(find.byKey(MemoriScreen.temaKey(MainYukTema.kendaraan)));
  await t.pump();
  await t.tap(find.text('8 pasang'));
  await t.pump();
  expect(t.takeException(), isNull);
});
testWidgets('semua pasangan membuka Hebat', (t) async {
  await pumpApp(t, initialLocation: '/main/memori');
  await _selesaikanMemori(t, 8);
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
```
```dart
String _label(WidgetTester t, int i) =>
    t.widget<MociPressable>(find.byKey(MemoriScreen.kartuKey(i))).semanticLabel!;

/// Membuka kartu berpasangan sampai semua pasangan ketemu.
Future<void> _selesaikanMemori(WidgetTester t, int jumlahKartu) async {
  for (var putaran = 0; putaran < jumlahKartu; putaran++) {
    final tertutup = [
      for (var i = 0; i < jumlahKartu; i++)
        if (_label(t, i) == 'Kartu tertutup') i,
    ];
    if (tertutup.isEmpty) return;
    final a = tertutup.first;
    for (final b in tertutup.skip(1)) {
      await t.tap(find.byKey(MemoriScreen.kartuKey(a)));
      await t.pump(const Duration(milliseconds: 450));
      await t.tap(find.byKey(MemoriScreen.kartuKey(b)));
      await t.pump();
      if (_label(t, b) == _label(t, a) && _label(t, b) != 'Kartu tertutup') {
        await t.pump(const Duration(milliseconds: 450));
        break;
      }
      await t.pump(const Duration(milliseconds: 1000));
    }
  }
  fail('pasangan tidak ketemu semua');
}
```
Jeda 450 ms di antara ketukan karena `MociPressable` menelan ketukan kedua dalam 400 ms.

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/memori_game_test.dart test/features/main_yuk/memori_screen_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan** model dan layar; ganti `_soon(Routes.memori, MenuTheme.memori)`. ARB baru: `memoriTitle` "Kartu Memori" / "Memory Cards"; `memoriRestart` "Main baru" / "New game"; `memoriTema` "Tema:" / "Theme:"; `memoriMoves` "Langkah: {n}" / "Moves: {n}" (placeholder `int n`); `memoriPair` (narasi) "Sepasang!" / "A pair!"; `memoriHidden` "Kartu tertutup" / "Hidden card"; `memoriInst` (narasi) "Buka dua kartu dan cari pasangannya." / "Open two cards and find the pair.". Jalankan `fvm flutter gen-l10n`.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Kartu Memori dengan maksimal dua kartu terbuka`.

---

### Task 4: Tebak Bayangan

**Files:**
- Create: `lib/features/main_yuk/bayangan_game.dart`, `lib/features/main_yuk/bayangan_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/bayangan`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/bayangan_game_test.dart`, `test/features/main_yuk/bayangan_screen_test.dart`

**Interfaces:**
- Consumes: `AnswerCard`, `AnswerCardState`, `ProgressDots`, `MociIllustration` (`silhouette`), `GameGlyph` (`listen`, `refresh`), `Katalog.byKategori`, semua dari Task 1.
- Produces:
  - `int bayanganPilihan(AgeLevel usia)` → 3/3/4.
  - `const bayanganRonde = 6;`
  - `const _kategoriBayangan = ['hewan', 'buah', 'kendaraan', 'benda'];` (tema yang dipakai prototipe; Sayur tidak dipakai).
  - `final class BayanganRonde { const BayanganRonde({required this.target, required this.pilihan}); final String target; final List<String> pilihan; }`
  - `BayanganRonde buatBayangan(Katalog katalog, {required int pilihan, required Random random, String? hindari})` — `hindari` adalah target ronde sebelumnya; target selalu ada di `pilihan`.
  - `final class BayanganGame { BayanganGame({required Katalog katalog, required AgeLevel usia, required Random random}); int get skor; BayanganRonde get ronde; bool get selesai; bool get terbuka; Set<String> get salah; bool pilih(String id); void lanjut(); }` — `pilih` mengembalikan true hanya untuk target; salah menambah `salah` tanpa mengakhiri ronde; `lanjut()` menaikkan `skor`, membuat ronde baru (kalau belum 6), dan menutup ronde.
  - `class BayanganScreen extends ConsumerStatefulWidget` dengan `static const targetKey = ValueKey('bayangan-target');` (dipasang pada `MociIllustration` bayangan, sehingga tes membaca `id`-nya), `static ValueKey<String> pilihanKey(String id)` (pada `AnswerCard`), `static const skorKey`.
  - Tata letak `GameScaffold(theme: MenuTheme.bayangan, title: bayanganTitle, trailing: [pil kemajuan + ProgressDots(count: 6, current: skor)])`: kartu putih 1100 × 410 di (40, 120) radius 44; tombol tanya (MociPressable) di (68, 146) berisi bulatan 60 `#9775FA` dengan `GameGlyph(GameGlyphKind.listen)` dan teks `bayanganAsk` 34; bayangan 300 × 300 di (400, 160) memakai `Opacity(0.78, MociIllustration(id, size: 300, silhouette: !terbuka, semanticLabel: terbuka ? nama : bayanganShadow)`), elips `#EEE8FF` 320 × 40 di bawahnya; pil hijau nama 84 di (740, 270) setelah terbuka; baris pilihan di y 566: `AnswerCard(width: 230, height: 200, illustrationSize: 150, state: id == target && terbuka ? correct : salah.contains(id) ? wrong : idle)` untuk 3 pilihan, atau 4 kartu 200 × 180 dengan jarak 24.
  - Perilaku: buka layar → `setLastActivity(Routes.bayangan)` + `sayAll([barisUi('bayanganInst', …)])` + `sayAll([barisUi('bayanganAsk', …), barisNama(target, nama)])`. Benar → `Sfx.benar` + `sayAll([barisUi('bayanganYes', …), barisNama(target, nama)])`; salah → `Sfx.salahLembut` + `sayAll([barisUi('bayanganNo', …), barisNama(id, nama)])` dan pilihan itu ditandai salah. Setelah benar: timer 1500 ms → `lanjut()`; bila `selesai` → `selesaikanRonde(gameId: 'bayangan', roundId: …, replayRoute: Routes.bayangan)` sekali (timer dibatalkan saat `dispose`). Tidak ada tombol "Main lagi" di layar ini; Hebat yang menyediakannya (M10). Tombol tanya membacakan `barisUi('bayanganAsk', …)` lagi.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/bayangan_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');
Katalog _katalogBayangan() => Katalog(item: [
  for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
    for (var i = 0; i < 8; i++) _item('$k$i', k),
]);

test('pilihan mengikuti level usia', () {
  expect(bayanganPilihan(AgeLevel.pemula), 3);
  expect(bayanganPilihan(AgeLevel.penjelajah), 3);
  expect(bayanganPilihan(AgeLevel.pembaca), 4);
});
test('target selalu ada di pilihan dan tidak mengulang ronde sebelumnya', () {
  final k = _katalogBayangan();
  for (var seed = 0; seed < 6; seed++) {
    final r = buatBayangan(k, pilihan: 4, random: Random(seed), hindari: 'kucing');
    expect(r.pilihan, contains(r.target));
    expect(r.target, isNot('kucing'));
    expect(r.pilihan.toSet(), hasLength(4));
  }
});
test('pilihan salah tidak menambah skor', () {
  final g = BayanganGame(katalog: _katalogBayangan(), usia: AgeLevel.pemula,
      random: Random(5));
  final salah = g.ronde.pilihan.firstWhere((id) => id != g.ronde.target);
  expect(g.pilih(salah), isFalse);
  expect(g.salah, contains(salah));
  expect(g.skor, 0);
  expect(g.selesai, isFalse);
});
test('enam jawaban benar menyelesaikan permainan', () {
  final g = BayanganGame(katalog: _katalogBayangan(), usia: AgeLevel.pemula,
      random: Random(5));
  for (var i = 0; i < 6; i++) {
    expect(g.pilih(g.ronde.target), isTrue);
    g.lanjut();
  }
  expect(g.skor, 6);
  expect(g.selesai, isTrue);
});
```


`test/features/main_yuk/bayangan_screen_test.dart`:
```dart
testWidgets('layar bayangan: tiga pilihan dan bayangan misteri', (t) async {
  await pumpApp(t, initialLocation: '/main/bayangan');
  expect(find.text('Tebak Bayangan'), findsOneWidget);
  expect(find.text('Bayangan siapa ini?'), findsOneWidget);
  expect(find.byType(AnswerCard), findsNWidgets(3));
  expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
  expect(find.byKey(BayanganScreen.skorKey), findsOneWidget);
});
testWidgets('pembaca memakai empat pilihan', (t) async {
  final env = TestEnv();
  env.store.setString('moci.usia', '6-7');
  await pumpApp(t, env: env, initialLocation: '/main/bayangan');
  expect(find.byType(AnswerCard), findsNWidgets(4));
});
/// Id target dibaca dari ilustrasi bayangan (kunci `targetKey`).
String _target(WidgetTester t) =>
    t.widget<MociIllustration>(find.byKey(BayanganScreen.targetKey)).id;
/// Id semua pilihan, dibaca dari kunci `pilihanKey` tiap AnswerCard.
List<String> _pilihan(WidgetTester t) => [
  for (final w in t.widgetList<AnswerCard>(find.byType(AnswerCard)))
    (w.key! as ValueKey<String>).value,
];
String _nama(WidgetTester t, String id) => ProviderScope
    .containerOf(t.element(find.byType(MociApp)))
    .read(katalogProvider)
    .byId(id)!
    .nama
    .of(AppLang.id);

testWidgets('jawaban benar membuka warna dan maju setelah 1500 ms', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/bayangan');
  final target = _target(t);
  await t.tap(find.byKey(BayanganScreen.pilihanKey(target)));
  await t.pump();
  expect(
    t.widget<AnswerCard>(find.byKey(BayanganScreen.pilihanKey(target))).state,
    AnswerCardState.correct,
  );
  expect(find.bySemanticsLabel(_nama(t, target)), findsWidgets);
  expect(env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Betul! Itu', _nama(t, target)]));
  await t.pump(const Duration(milliseconds: 1600));
  expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
  expect(t.widget<ProgressDots>(find.byType(ProgressDots)).current, 1);
});
testWidgets('pilihan salah tetap di ronde yang sama', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/bayangan');
  final target = _target(t);
  final salah = _pilihan(t).firstWhere((id) => id != target);
  await t.tap(find.byKey(BayanganScreen.pilihanKey(salah)));
  await t.pump();
  expect(
    t.widget<AnswerCard>(find.byKey(BayanganScreen.pilihanKey(salah))).state,
    AnswerCardState.wrong,
  );
  expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
  expect(env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Bukan yang itu, itu', _nama(t, salah)]));
});
testWidgets('enam jawaban benar membuka Hebat', (t) async {
  await pumpApp(t, initialLocation: '/main/bayangan');
  for (var i = 0; i < 6; i++) {
    await t.tap(find.byKey(BayanganScreen.pilihanKey(_target(t))));
    await t.pump(const Duration(milliseconds: 1600));
  }
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/bayangan_game_test.dart test/features/main_yuk/bayangan_screen_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan** model dan layar; ganti `_soon(Routes.bayangan, MenuTheme.bayangan)`. ARB baru: `bayanganTitle` "Tebak Bayangan" / "Shadow Match"; `bayanganAsk` (narasi) "Bayangan siapa ini?" / "Whose shadow is this?"; `bayanganShadow` "Bayangan misteri" / "A mystery shadow"; `bayanganProgress` "Kemajuan" / "Progress"; `bayanganYes` (narasi) "Betul! Itu" / "Yes! It is the"; `bayanganNo` (narasi) "Bukan yang itu, itu" / "Not that one, that is the"; `bayanganInst` (narasi) "Ketuk gambar yang bayangannya sama." / "Tap the picture that matches the shadow."; `bayanganSemantic` "Pilihan bayangan" / "Shadow choices". Jalankan `fvm flutter gen-l10n`.
  `AnswerCard` harus menerima `super.key` supaya `pilihanKey(id)` bisa dipasang; kalau Rencana 03 belum menambahkannya, tambahkan parameter itu di `lib/widgets/game/answer_card.dart` tanpa mengubah parameter lain, dan sebut perubahan kontrak itu di pesan commit.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Tebak Bayangan dengan enam ronde dan bayangan dari gambar yang sama`.

---

### Task 5: Puzzle

**Files:**
- Create: `lib/features/main_yuk/puzzle_game.dart`, `lib/features/main_yuk/puzzle_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/puzzle`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/puzzle_game_test.dart`, `test/features/main_yuk/puzzle_screen_test.dart`

**Interfaces:**
- Consumes: `MociIllustration`, `MociPressable`, `MociMascot`, `GameGlyph`, semua dari Task 1.
- Produces:
  - `({int kolom, int baris}) puzzleKisi(AgeLevel usia)` → `(2, 2)` / `(3, 2)` / `(3, 3)`.
  - `const puzzleSisi = 480.0;`
  - `enum PuzzleStep { pilih, pas, salah, selesai }`
  - `final class PuzzleGame { PuzzleGame({required Katalog katalog, required AgeLevel usia, required Random random, String? hindari}); String get gambar; int get kolom, baris; List<int> get urutan; Set<int> get terpasang; int? get dipilih; int get jumlah; bool get selesai; PuzzleStep pilih(int keping); PuzzleStep letak(int slot); void ulang(); }` — `gambar` adalah `Item.id`; `urutan` = indeks keping di baki (diacak, tanpa yang sudah terpasang); `pilih` mengabaikan keping yang sudah terpasang (`PuzzleStep.pilih` tanpa perubahan); `letak` tanpa pilihan → `PuzzleStep.pilih`; slot benar → `pas`/`selesai`; slot salah → `salah` (pilihan tetap).
  - Kategori puzzle: `['hewan', 'buah', 'kendaraan', 'benda']` seperti prototipe.
  - `class PuzzleScreen extends ConsumerStatefulWidget` dengan `static const boardKey`, `static ValueKey<int> slotKey(int i)`, `static ValueKey<int> pieceKey(int i)`, `static const otherKey`, `static const countKey`.
  - Label semantik: `puzzleSpot` "Tempat {n}" / "Spot {n}" untuk slot, `puzzlePiece` "Potongan {n}" / "Puzzle piece {n}" untuk keping.
  - Tata letak `GameScaffold(theme: MenuTheme.puzzle, title: puzzleTitle, trailing: [pil hitungan "n / m potongan", tombol `puzzleOther`])`: papan 480 × 480 di (60, 128) radius 26 putih dengan ilustrasi penuh 16% opasitas; slot = `kolom × baris` kotak `480 / kolom` × `480 / baris` dengan border putus-putus 4 `#F2C57C` (terpilih `#E0870B`, latar `rgba(255,176,32,.10)`), keping terpasang = `ClipRect` + `MociIllustration` 480 diskalakan dan digeser `-x * lebar`, `-y * tinggi`; baki 520 × 480 di (600, 128) latar `rgba(255,255,255,.7)` + border dalam 3 `#FFE3B3`, keping 0,9 × ukuran slot, jarak 16; hint + Moci 48 di (60, 636).
  - Perilaku: buka layar → `setLastActivity(Routes.puzzle)` + `sayAll([barisUi('puzzleInst', …)])`. Ketuk keping → `sayAll([barisUi('puzzleTipPlace', …)])`; `pas` → `Sfx.benar` + `sayAll([barisUi('puzzleFits', …)])`; `salah` → `Sfx.salahLembut` + goyang 450 ms + `sayAll([barisUi('puzzleNo', …)])`; `selesai` → `sayAll([barisUi('puzzleDone', …), barisNama(gambar, nama)])` + `selesaikanRonde(gameId: 'puzzle', roundId: …, replayRoute: Routes.puzzle)` sekali. `Puzzle lain` membuat ronde baru dengan gambar selain gambar sekarang (`mainYukRoundSeqProvider.next('puzzle')`).

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/puzzle_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');
Katalog _katalogPuzzle() => Katalog(item: [
  for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
    for (var i = 0; i < 4; i++) _item('$k$i', k),
]);

test('kisi mengikuti level usia', () {
  expect(puzzleKisi(AgeLevel.pemula), (kolom: 2, baris: 2));
  expect(puzzleKisi(AgeLevel.penjelajah), (kolom: 3, baris: 2));
  expect(puzzleKisi(AgeLevel.pembaca), (kolom: 3, baris: 3));
});
test('urutan berisi semua keping sekali', () {
  final g = PuzzleGame(katalog: _katalogPuzzle(), usia: AgeLevel.pembaca, random: Random(9));
  expect(g.urutan, hasLength(9));
  expect(g.urutan.toSet(), hasLength(9));
});
test('keping yang salah tidak terpasang', () {
  final g = PuzzleGame(katalog: _katalogPuzzle(), usia: AgeLevel.pemula, random: Random(2));
  final k = g.urutan.first;
  expect(g.pilih(k), PuzzleStep.pilih);
  expect(g.letak((k + 1) % g.jumlah), PuzzleStep.salah);
  expect(g.terpasang, isEmpty);
  expect(g.dipilih, k);
});
test('keping yang tepat terpasang dan selesai saat keping terakhir', () {
  final g = PuzzleGame(katalog: _katalogPuzzle(), usia: AgeLevel.pemula, random: Random(2));
  for (var i = 0; i < 4; i++) {
    g.pilih(i);
    expect(g.letak(i), i == 3 ? PuzzleStep.selesai : PuzzleStep.pas);
  }
  expect(g.selesai, isTrue);
});
test('gambar baru tidak memakai gambar sebelumnya', () {
  final g = PuzzleGame(katalog: _katalogPuzzle(), usia: AgeLevel.pemula, random: Random(4));
  final lama = g.gambar;
  g.ulang();
  expect(g.gambar, isNot(lama));
  expect(g.terpasang, isEmpty);
});
```

`test/features/main_yuk/puzzle_screen_test.dart`:
```dart
testWidgets('layar puzzle: empat keping dan baki', (t) async {
  await pumpApp(t, initialLocation: '/main/puzzle');
  expect(find.text('Puzzle'), findsOneWidget);
  expect(find.text('0 / 4 potongan'), findsOneWidget);
  expect(find.bySemanticsLabel('Potongan 1'), findsOneWidget);
  expect(find.bySemanticsLabel('Tempat 4'), findsOneWidget);
});
testWidgets('papan 2 x 2 untuk pemula, 3 x 3 untuk pembaca', (t) async {
  final env = TestEnv();
  env.store.setString('moci.usia', '6-7');
  await pumpApp(t, env: env, initialLocation: '/main/puzzle');
  expect(find.bySemanticsLabel('Tempat 9'), findsOneWidget);
  expect(find.text('0 / 9 potongan'), findsOneWidget);
});
testWidgets('ketuk keping lalu tempatnya memasang gambar', (t) async {
  await pumpApp(t, initialLocation: '/main/puzzle');
  await t.tap(find.bySemanticsLabel('Potongan 1'));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.bySemanticsLabel('Tempat 1'));
  await t.pump(const Duration(milliseconds: 450));
  expect(find.text('1 / 4 potongan'), findsOneWidget);
  expect(find.bySemanticsLabel('Potongan 1'), findsNothing);
});
testWidgets('empat keping membuka Hebat', (t) async {
  await pumpApp(t, initialLocation: '/main/puzzle');
  for (var i = 1; i <= 4; i++) {
    await t.tap(find.bySemanticsLabel('Potongan $i'));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.bySemanticsLabel('Tempat $i'));
    await t.pump(const Duration(milliseconds: 450));
  }
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
testWidgets('tempat salah tetap menampilkan keping di baki', (t) async {
  await pumpApp(t, initialLocation: '/main/puzzle');
  await t.tap(find.bySemanticsLabel('Potongan 1'));
  await t.pump(const Duration(milliseconds: 450));
  await t.tap(find.bySemanticsLabel('Tempat 2'));
  await t.pump();
  expect(find.text('0 / 4 potongan'), findsOneWidget);
  expect(find.bySemanticsLabel('Potongan 1'), findsOneWidget);
});
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/puzzle_game_test.dart test/features/main_yuk/puzzle_screen_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan** model dan layar; ganti `_soon(Routes.puzzle, MenuTheme.puzzle)`. ARB baru: `puzzleTitle` "Puzzle" / "Puzzle"; `puzzleOther` "Puzzle lain" / "New puzzle"; `puzzleBoard` "Papan puzzle" / "Puzzle board"; `puzzleHintPick` "Ketuk potongan, lalu ketuk tempatnya." / "Tap a piece, then tap where it goes."; `puzzleHintPlace` "Sekarang ketuk tempat yang pas di gambar!" / "Now tap the right spot on the picture!"; `puzzleFits` (narasi) "Pas!" / "It fits!"; `puzzleNo` (narasi) "Bukan di situ. Coba tempat lain!" / "Not there. Try another spot!"; `puzzlePieces` "{n} / {m} potongan" / "{n} / {m} pieces" (dua placeholder `int n`, `int m`); `puzzlePiece` "Potongan {n}" / "Puzzle piece {n}"; `puzzleSpot` "Tempat {n}" / "Spot {n}"; `puzzleDone` "Hore! Gambarnya" / "Hooray! It is a"; `puzzleInst` (narasi) "Ketuk potongan, lalu ketuk tempatnya." / "Tap a piece, then tap where it goes."; `puzzleTipPlace` (narasi) "Sekarang ketuk tempat yang pas di gambar!" / "Now tap the right spot on the picture!". Jalankan `fvm flutter gen-l10n`.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Puzzle 4/6/9 keping dari satu ilustrasi`.

---

### Task 6: Balon Huruf

**Files:**
- Create: `lib/features/main_yuk/balon_game.dart`, `lib/features/main_yuk/balon_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/balon`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/balon_game_test.dart`, `test/features/main_yuk/balon_screen_test.dart`

**Interfaces:**
- Consumes: `ProgressDots`, `GameGlyph`, `Katalog.huruf` (`HurufEntry.of(lang).nama`/`bunyi`), semua dari Task 1.
- Produces:
  - `const hurufBalonPemula = 'ABCIMOPSU';`, `const hurufBalonPenjelajah = 'ABCDEFGHIJKLMNOPRSTUWYZ';`, `String setHurufBalon(AgeLevel usia)` → huruf pemula untuk `pemula`, sisanya 23 huruf.
  - `const balonRonde = 5;` dan `const balonPerRonde = 6;`
  - `final class BalonRonde { const BalonRonde({required this.target, required this.huruf}); final String target; final List<String> huruf; }` — `huruf` berisi target dua kali + empat pengecoh, teracak.
  - `BalonRonde buatBalon(AgeLevel usia, {required Random random, String? hindari})`.
  - `enum BalonStep { pecah, salah, selesai }`
  - `final class BalonGame { BalonGame({required AgeLevel usia, required Random random}); int get skor; BalonRonde get ronde; Set<int> get pecah; bool get selesai; BalonStep pilih(int indeks); void lanjut(); }` — memilih balon target menandai `pecah` dan mengembalikan `selesai` bila itu huruf benar kelima; huruf lain → `salah` tanpa mengubah skor.
  - `class BalonScreen extends ConsumerStatefulWidget` dengan `static ValueKey<int> balonKey(int i)` (pada `MociPressable` berlabel `balonLabel(huruf)`), `static const targetKey = ValueKey('balon-target');` (pada `Text` huruf target di bilah atas), `static const progressKey`.
  - Tata letak `GameScaffold(theme: MenuTheme.balon, title: balonTitle, trailing: [tombol tanya (target), pil kemajuan + ProgressDots(count: 5, current: skor)])`: balon 150 × 236 di enam slot `[(60,400),(240,270),(420,430),(600,290),(780,440),(960,300)]`, warna berpasangan `[#FF6B6B/#E03E3E, #FFB020/#E0870B, #22C1C3/#129A9C, #9775FA/#7048E8, #51CF66/#2F9E44, #F06595/#C2255C]`, huruf 68 putih dengan bayangan teks; mengapung 10–14 s (berhenti saat `disableAnimations`); pecah = ledakan bintang 400 ms lalu hilang. Tombol tanya di bilah atas: teks `balonAsk` 28 + kotak huruf 58 `#22C1C3`.
  - Perilaku: buka layar → `setLastActivity(Routes.balon)` + `sayAll([barisUi('balonInst', …)])` + `sayAll([barisUi('balonAsk', …), barisHuruf(target, namaHuruf)])`. Benar → `Sfx.benar` + `sayAll([barisUi('balonYes', …), barisHuruf(target, namaHuruf)])`, lalu timer 1000 ms → `lanjut()`; bila `selesai` → `selesaikanRonde(gameId: 'balon', roundId: …, replayRoute: Routes.balon)`. Salah → `Sfx.salahLembut` + goyang + `sayAll([barisUi('balonNo', …), barisHuruf(huruf, namaHuruf)])`. Timer dibatalkan saat `dispose`.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/balon_game_test.dart`:
```dart
test('set huruf pemula sembilan huruf', () {
  expect(setHurufBalon(AgeLevel.pemula), 'ABCIMOPSU');
});
test('usia lain memakai dua puluh tiga huruf tanpa Q V X', () {
  final s = setHurufBalon(AgeLevel.penjelajah);
  expect(s, hasLength(23));
  expect('QVX'.split('').where(s.contains), isEmpty);
  expect(setHurufBalon(AgeLevel.pembaca), s);
});
test('ronde berisi target dua kali dan empat pengecoh', () {
  final r = buatBalon(AgeLevel.pemula, random: Random(3));
  expect(r.huruf, hasLength(6));
  expect(r.huruf.where((h) => h == r.target), hasLength(2));
  expect(r.huruf.toSet(), hasLength(5));
  expect(hurufBalonPemula.contains(r.target), isTrue);
});
test('target tidak mengulang ronde sebelumnya', () {
  for (var seed = 0; seed < 8; seed++) {
    expect(buatBalon(AgeLevel.penjelajah, random: Random(seed), hindari: 'B').target, isNot('B'));
  }
});
test('balon salah tidak menambah skor', () {
  final g = BalonGame(usia: AgeLevel.pemula, random: Random(1));
  final salah = g.ronde.huruf.indexWhere((h) => h != g.ronde.target);
  expect(g.pilih(salah), BalonStep.salah);
  expect(g.skor, 0);
  expect(g.pecah, isEmpty);
});
test('lima huruf benar menyelesaikan permainan', () {
  final g = BalonGame(usia: AgeLevel.pemula, random: Random(1));
  for (var i = 0; i < 5; i++) {
    final target = g.ronde.huruf.indexOf(g.ronde.target);
    expect(g.pilih(target), i == 4 ? BalonStep.selesai : BalonStep.pecah);
    g.lanjut();
  }
  expect(g.skor, 5);
  expect(g.selesai, isTrue);
});
```

`test/features/main_yuk/balon_screen_test.dart`:
```dart
testWidgets('layar balon: enam balon dan target di bilah atas', (t) async {
  await pumpApp(t, initialLocation: '/main/balon');
  expect(find.text('Balon Huruf'), findsOneWidget);
  for (var i = 0; i < 6; i++) {
    expect(find.byKey(BalonScreen.balonKey(i)), findsOneWidget);
  }
  expect(find.byKey(BalonScreen.targetKey), findsOneWidget);
  expect(find.text('Pecahkan balon huruf'), findsOneWidget);
});
testWidgets('pemula hanya memakai sembilan huruf', (t) async {
  await pumpApp(t, initialLocation: '/main/balon');
  for (var i = 0; i < 6; i++) {
    final label = t.widget<MociPressable>(find.byKey(BalonScreen.balonKey(i))).semanticLabel!;
    final huruf = label.split(' ').last;
    expect(hurufBalonPemula.contains(huruf), isTrue, reason: label);
  }
});
testWidgets('balon salah bergoyang dan target tetap sama', (t) async {
  final env = TestEnv();
  await pumpApp(t, env: env, initialLocation: '/main/balon');
  final target = _hurufTarget(t);
  final salah = _indeksSalah(t);
  await t.tap(find.byKey(BalonScreen.balonKey(salah)));
  await t.pump();
  expect(env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Ups, itu huruf', _labelBalon(t, salah).split(' ').last]));
  expect(_hurufTarget(t), target);
});
testWidgets('lima huruf benar membuka Hebat', (t) async {
  await pumpApp(t, initialLocation: '/main/balon');
  for (var i = 0; i < 5; i++) {
    await t.tap(find.byKey(BalonScreen.balonKey(_indeksTarget(t))));
    await t.pump(const Duration(milliseconds: 1100));
  }
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
```
```dart
/// Huruf target dari kotak huruf di bilah atas.
String _hurufTarget(WidgetTester t) =>
    t.widget<Text>(find.descendant(
      of: find.byKey(BalonScreen.targetKey), matching: find.byType(Text))).data!;
String _labelBalon(WidgetTester t, int i) =>
    t.widget<MociPressable>(find.byKey(BalonScreen.balonKey(i))).semanticLabel!;
/// Indeks balon yang hurufnya sama dengan target.
int _indeksTarget(WidgetTester t) {
  final target = _hurufTarget(t);
  for (var i = 0; i < 6; i++) {
    if (_labelBalon(t, i).endsWith(target)) return i;
  }
  fail('tidak ada balon huruf $target');
}
/// Indeks balon yang hurufnya bukan target.
int _indeksSalah(WidgetTester t) {
  final target = _hurufTarget(t);
  for (var i = 0; i < 6; i++) {
    if (!_labelBalon(t, i).endsWith(target)) return i;
  }
  fail('semua balon huruf $target');
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/balon_game_test.dart test/features/main_yuk/balon_screen_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan** model dan layar; ganti `_soon(Routes.balon, MenuTheme.balon)`. ARB baru: `balonTitle` "Balon Huruf" / "Letter Balloons"; `balonAsk` (narasi) "Pecahkan balon huruf" / "Pop the letter"; `balonProgress` "Kemajuan" / "Progress"; `balonYes` (narasi) "Dor! Itu huruf" / "Pop! That is"; `balonNo` (narasi) "Ups, itu huruf" / "Oops, that is"; `balonInst` (narasi) "Pecahkan balon yang hurufnya sama dengan yang disebut Moci." / "Pop the balloon with the letter Moci says."; `balonLabel` "Balon huruf {huruf}" / "Balloon {huruf}". Jalankan `fvm flutter gen-l10n`.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Balon Huruf dengan set huruf per usia`.

---

### Task 7: Besar & Kecil

**Files:**
- Create: `lib/features/main_yuk/besar_kecil_game.dart`, `lib/features/main_yuk/besar_kecil_screen.dart`
- Modify: `lib/app/router.dart` (rute `/main/besar-kecil`), `l10n/app_id.arb`, `l10n/app_en.arb`
- Test: `test/features/main_yuk/besar_kecil_game_test.dart`, `test/features/main_yuk/besar_kecil_screen_test.dart`

**Interfaces:**
- Consumes: `ProgressDots`, `GameGlyph`, `MociIllustration`, semua dari Task 1.
- Produces:
  - `List<double> ukuranBesarKecil(AgeLevel usia)` → `[120, 200, 300]` untuk pemula dan penjelajah, `[150, 200, 250, 300]` untuk pembaca.
  - `const besarKecilRonde = 6;`
  - `final class BesarKecilRonde { const BesarKecilRonde({required this.gambar, required this.termuda, required this.ukuran}); final String gambar; final bool termuda; final List<double> ukuran; double get jawaban; }` — `gambar` adalah `Item.id`; `termuda` true berarti "paling besar"; `jawaban` = ukuran maksimum atau minimum.
  - `BesarKecilRonde buatBesarKecil(Katalog katalog, {required AgeLevel usia, required bool? tanyaSebelumnya, required Random random, String? hindari})` — pertanyaan bergantian: bila `tanyaSebelumnya` true (sebelumnya "besar") ronde baru menanyakan "kecil", dan sebaliknya; `ukuran` diacak.
  - `final class BesarKecilGame { BesarKecilGame({required Katalog katalog, required AgeLevel usia, required Random random}); int get skor; BesarKecilRonde get ronde; bool get selesai; bool pilih(int indeks); void lanjut(); }` — `pilih` benar hanya untuk ukuran `jawaban`; setelah benar layar memanggil `lanjut()`.
  - `class BesarKecilScreen extends ConsumerStatefulWidget` dengan `static ValueKey<int> ukuranKey(int i)` (pada kotak bergambar seukuran `ukuran[i]`), `static const askKey = ValueKey('besar-kecil-ask');` (pada `Text` kata tanya "BESAR"/"KECIL"), `static const progressKey`.
  - Tata letak `GameScaffold(theme: MenuTheme.besarKecil, title: besarKecilTitle, trailing: [pil kemajuan + ProgressDots(count: 6, current: skor)])`: bar tanya 1100 × 92 di (40, 120) radius 30 berisi tombol (bulatan 64 `#5FD068` + `GameGlyph(GameGlyphKind.listen)`, `besarKecilWhich` 38, pil kata 60 (`besarKecilBig` 36 latar `#E8590C` atau `besarKecilSmall` latar `#1C7ED6`, teks putih, bayangan 5), "?" 38); kartu putih 1100 × 548 di (40, 236) dengan tanah `#D3F9D8` 96 di bawah; gambar selebar ukurannya, diletakkan di `x = 1100 / (n + 1) * (i + 1) - ukuran / 2`, `y = 478 - ukuran`; lencana centang hijau 54 di pojok kanan atas gambar benar.
  - Perilaku: buka layar → `setLastActivity(Routes.besarKecil)` + `sayAll([barisUi('besarKecilInst', …)])` + `sayAll([barisUi('besarKecilWhich', …), barisUi(termuda ? 'besarKecilBigSay' : 'besarKecilSmallSay', …)])`. Benar → `Sfx.benar` + `sayAll([barisUi('besarKecilYes', …), barisUi(termuda ? 'besarKecilBigSay' : 'besarKecilSmallSay', …)])`, timer 1300 ms → `lanjut()`; benar keenam → `selesaikanRonde(gameId: 'besarKecil', roundId: …, replayRoute: Routes.besarKecil)`. Salah → `Sfx.salahLembut` + goyang + `sayAll([barisUi('besarKecilNo', …)])` dan ronde tetap.

- [ ] **Step 1: Tulis tes yang gagal**

`test/features/main_yuk/besar_kecil_game_test.dart`:
```dart
Item _item(String id, String kategori) => Item(id: id, kategori: kategori,
  nama: Bilingual(id, id), gambar: 'illustrations/$id.svg');
Katalog _katalogBesar() => Katalog(item: [
  for (final k in ['hewan', 'buah', 'kendaraan', 'benda'])
    for (var i = 0; i < 4; i++) _item('$k$i', k),
]);

test('tiga ukuran, empat untuk pembaca', () {
  expect(ukuranBesarKecil(AgeLevel.pemula), [120, 200, 300]);
  expect(ukuranBesarKecil(AgeLevel.penjelajah), [120, 200, 300]);
  expect(ukuranBesarKecil(AgeLevel.pembaca), [150, 200, 250, 300]);
});
test('pertanyaan bergantian besar dan kecil', () {
  final g = BesarKecilGame(katalog: _katalogBesar(), usia: AgeLevel.pemula, random: Random(1));
  final pertama = g.ronde.termuda;
  final kedua = buatBesarKecil(_katalogBesar(), usia: AgeLevel.pemula,
      tanyaSebelumnya: pertama, random: Random(2));
  expect(kedua.termuda, isNot(pertama));
});
test('jawaban adalah ukuran terbesar atau terkecil', () {
  final g = BesarKecilGame(katalog: _katalogBesar(), usia: AgeLevel.pembaca,
      random: Random(3));
  expect(g.ronde.jawaban,
      g.ronde.ukuran.reduce(g.ronde.termuda ? max : min));
});
test('enam jawaban benar menyelesaikan permainan', () {
  final g = BesarKecilGame(katalog: _katalogBesar(), usia: AgeLevel.pemula, random: Random(1));
  for (var i = 0; i < 6; i++) {
    final idx = g.ronde.ukuran.indexOf(g.ronde.jawaban);
    expect(g.pilih(idx), isTrue);
    g.lanjut();
  }
  expect(g.skor, 6);
  expect(g.selesai, isTrue);
});
test('gambar baru tidak mengulang benda sebelumnya', () {
  final g = BesarKecilGame(katalog: _katalogBesar(), usia: AgeLevel.pemula, random: Random(6));
  final lama = g.ronde.gambar;
  g.lanjut();
  expect(g.ronde.gambar, isNot(lama));
});
```
(`max` dan `min` dari `dart:math`.)

`test/features/main_yuk/besar_kecil_screen_test.dart`:
```dart
testWidgets('layar besar & kecil: tiga ukuran dan pertanyaan', (t) async {
  await pumpApp(t, initialLocation: '/main/besar-kecil');
  expect(find.text('Besar & Kecil'), findsOneWidget);
  expect(find.text('Mana yang paling'), findsOneWidget);
  for (var i = 0; i < 3; i++) {
    expect(find.byKey(BesarKecilScreen.ukuranKey(i)), findsOneWidget);
  }
  expect(find.byType(ProgressDots), findsOneWidget);
});
testWidgets('pembaca memakai empat ukuran', (t) async {
  final env = TestEnv();
  env.store.setString('moci.usia', '6-7');
  await pumpApp(t, env: env, initialLocation: '/main/besar-kecil');
  expect(find.byKey(BesarKecilScreen.ukuranKey(3)), findsOneWidget);
});
testWidgets('enam jawaban benar membuka Hebat', (t) async {
  await pumpApp(t, initialLocation: '/main/besar-kecil');
  for (var i = 0; i < 6; i++) {
    await t.tap(find.byKey(BesarKecilScreen.ukuranKey(_indeksJawaban(t))));
    await t.pump(const Duration(milliseconds: 1400));
  }
  await t.pump();
  await t.pump();
  expect(find.byType(HebatScreen), findsOneWidget);
  expect(_progress(t).stars, 3);
});
```
```dart
/// Indeks gambar yang paling besar atau paling kecil, dibaca dari ukuran
/// widget dan kata tanya di `askKey`.
int _indeksJawaban(WidgetTester t) {
  final besar = find
      .descendant(
        of: find.byKey(BesarKecilScreen.askKey),
        matching: find.text('BESAR'),
      )
      .evaluate()
      .isNotEmpty;
  final ukuran = [
    for (var i = 0;
        find.byKey(BesarKecilScreen.ukuranKey(i)).evaluate().isNotEmpty;
        i++)
      t.getSize(find.byKey(BesarKecilScreen.ukuranKey(i))).width,
  ];
  var pilih = 0;
  for (var i = 1; i < ukuran.length; i++) {
    if (besar ? ukuran[i] > ukuran[pilih] : ukuran[i] < ukuran[pilih]) {
      pilih = i;
    }
  }
  return pilih;
}
```

- [ ] **Step 2: Pastikan tesnya gagal.** Run: `fvm flutter test test/features/main_yuk/besar_kecil_game_test.dart test/features/main_yuk/besar_kecil_screen_test.dart`. Expected: FAIL.

- [ ] **Step 3: Implementasikan** model dan layar; ganti `_soon(Routes.besarKecil, MenuTheme.besarKecil)`. ARB baru: `besarKecilTitle` "Besar & Kecil" / "Big & Small"; `besarKecilWhich` (narasi) "Mana yang paling" / "Which one is the"; `besarKecilBig` "BESAR" / "BIGGEST"; `besarKecilSmall` "KECIL" / "SMALLEST"; `besarKecilProgress` "Kemajuan" / "Progress"; `besarKecilYes` (narasi) "Betul! Itu yang paling" / "Yes! That is the"; `besarKecilNo` (narasi) "Coba lihat lagi!" / "Look again!"; `besarKecilBigSay` (narasi) "besar" / "biggest"; `besarKecilSmallSay` (narasi) "kecil" / "smallest"; `besarKecilInst` (narasi) "Ketuk gambar yang paling besar atau paling kecil." / "Tap the biggest or the smallest picture."; `besarKecilLabel` "{nama}, ukuran {n}" / "{nama}, size {n}". Jalankan `fvm flutter gen-l10n`.

- [ ] **Step 4: Jalankan tes.** Run: `fvm flutter test test/features/main_yuk`. Expected: PASS.

- [ ] **Step 5: Commit** dengan pesan `feat(main-yuk): Besar & Kecil dengan tiga atau empat ukuran`.

---

### Task 8: Uji integrasi "satu permainan → Hebat" dan pemeriksaan akhir

**Files:**
- Modify: `integration_test/app_test.dart`
- Test: `integration_test/app_test.dart`

**Interfaces:**
- Consumes: seluruh task di atas; `_prepareDevice`, `_Launch`, `_screen`, `_tap`, `_pumpUntil`, `_container`, `_stack` yang sudah ada.
- Produces: satu skenario perangkat yang menempuh hub, satu permainan utuh, hadiah, dan kembali ke Beranda.

Skenario memakai Puzzle karena satu-satunya permainan yang urutannya bisa dipastikan tanpa membaca isi: keping `n` selalu cocok dengan `Tempat n`, dan level bawaan (`pemula`) memberi papan 2 × 2. Tes berjalan dalam bahasa Inggris seperti tiga skenario yang sudah ada.

- [ ] **Step 1: Tulis uji integrasi.** Tambah sebelum penutup `main()`:
```dart
testWidgets('permainan: puzzle, hadiah, lalu kembali ke Beranda', (t) async {
  await _prepareDevice(lang: AppLang.en, childName: 'Raka', onboarded: true);
  final app = _Launch();
  addTearDown(app.dispose);
  await app.run(t);
  await _screen(t, find.text('Hi, Raka!'));
  expect(_stack(t), ['/']);

  // Beranda → hub.
  await _tap(t, find.text("Let's Play!"));
  await _screen(t, find.text('Pick a game'));
  expect(_lastPath(t), '/main');

  // Hub → Puzzle (papan 2 × 2 untuk pemula).
  await _tap(t, find.text('Jigsaw Puzzle'));
  await _screen(t, find.text('Puzzle'));
  expect(_lastPath(t), '/main/puzzle');
  expect(find.text('0 / 4 pieces'), findsOneWidget);

  // Empat keping: ketuk keping, lalu tempatnya.
  for (var i = 1; i <= 4; i++) {
    await _tap(t, find.bySemanticsLabel('Puzzle piece $i'));
    await t.pump(const Duration(milliseconds: 450));
    await _tap(t, find.bySemanticsLabel('Spot $i'));
    await t.pump(const Duration(milliseconds: 450));
  }

  // Ronde selesai: hadiah disimpan sebelum Hebat tampil.
  await _screen(t, find.text('Great job!'));
  expect(_lastPath(t), '/hebat');
  expect(_container(t).read(progressProvider).stars, 3);
  expect(_container(t).read(progressProvider).stickers, hasLength(1));

  // Lanjut menutup permainan: kembali ke Beranda, bukan ke papan yang selesai.
  await _tap(t, find.text('Continue'));
  await _pumpUntil(t, find.text('Hi, Raka!'));
  expect(_stack(t), ['/']);
}, timeout: const Timeout(Duration(minutes: 3)));
```
Tambahkan impor `package:moci/core/progress/progress_controller.dart` di berkas itu.

- [ ] **Step 2: Jalankan di perangkat.** Run: `fvm flutter test integration_test -d "iPad (A16)"`. Expected: PASS. Ini tes pertama yang menempuh hub dan satu permainan utuh (router, nomor ronde, `finishGame`, Hebat, `go`), jadi kegagalan di sini adalah bug integrasi: perbaiki layarnya, bukan tesnya.

- [ ] **Step 3: Jalankan seluruh pemeriksaan akhir.**
```bash
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm flutter analyze
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
fvm dart run tool/validate_content.dart
```
Expected: format dan analyze bersih; semua tes PASS; validator keluar dengan kode 0 dan hanya peringatan yang sudah ada (`mewarnai_contoh`, `narasi_lengkap` untuk rekaman yang belum ada).

- [ ] **Step 4: Cek manual di perangkat.** Di iPad dan emulator Android: mainkan keenam permainan sekali sampai Hebat; di Area Orang Tua ganti level usia ke Pembaca lalu ulangi Puzzle (3 × 3), Balon (23 huruf), Bayangan (4 pilihan), dan Besar & Kecil (4 ukuran); nyalakan `Reduce Motion`/`Remove animations` lalu pastikan tidak ada balon mengapung, denyut, atau goyangan hiasan, tetapi umpan balik benar/salah tetap muncul. Expected: tidak ada layar yang macet, tidak ada teks terpotong, dan setiap permainan berakhir di Hebat.

- [ ] **Step 5: Commit** dengan pesan `test(main-yuk): uji integrasi satu permainan sampai Hebat`.
