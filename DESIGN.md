# Sistem desain di kode

Dokumen ini menerjemahkan sistem desain ke kode yang ada: token, komponen, panggung tablet dan HP, gerak, umpan balik suara, aksesibilitas, dan cara membaca artboard prototipe. Aturan visual lengkap ada di [DESIGN-SYSTEM](docs/DESIGN-SYSTEM.md), dan data isi ada di [CONTENT-ASSETS](docs/CONTENT-ASSETS.md).

## 1. Token

### Warna

| Token | Nilai | Dipakai untuk |
| --- | --- | --- |
| `MociColors.ink` | `#2B2350` | Semua teks dan garis |
| `MociColors.inkSoft` | `#6B5F99` | Teks sekunder |
| `MociColors.sky` | `#74C4FF` | Warna benih `ColorScheme`, latar Beranda |
| `MociColors.mociYellow` | `#FFD43B` | Aksen kuning |
| `MociColors.correct` | `#26A03B` | Tombol utama dan jawaban benar |
| `MociColors.correctShadow` | `#1E8A31` | Bayangan tombol utama |
| `MociColors.wrong` | `#E8384F` | Jawaban salah |
| `MociColors.logoM` | `#F03E7C` | Huruf M pada logo |
| `MociColors.logoO` | `#FF9F1C` | Huruf o pada logo |
| `MociColors.logoC` | `#1C8CF0` | Huruf c pada logo |
| `MociColors.logoI` | `#26A03B` | Huruf i pada logo |
| `MociColors.white` | `#FFFFFF` | Kartu dan pil |
| `MociColors.starFill` | `#FFC21A` | Isi bintang |
| `MociColors.starStroke` | `#F08C00` | Garis bintang |
| `MociColors.neutralShadow` | `rgba(43, 35, 80, 0.12)` | Bayangan saat tidak ada tema menu |

`mociTheme()` memakai Material 3, keluarga font Nunito, latar transparan, dan `NoSplash.splashFactory`: umpan balik tekan datang dari `MociPressable`, bukan ripple.

### Tema menu

`MenuTheme` menentukan latar penuh layar dan warna bayangan tombol. Gradien berhenti di `stops` bila ada.

| Tema | Latar | Bayangan |
| --- | --- | --- |
| `beranda` | gradien `#74C4FF` 0, `#B5E2FF` 0,55, `#DDF3FF` 1 | `#8EC5EE` |
| `sambutan` | gradien `#74C4FF` 0, `#B5E2FF` 0,6, `#DDF3FF` 1 | `#8EC5EE` |
| `huruf`, `ucapkan` | `#FFEDE6` | `#F3C2B3` |
| `berhitung` | `#E7F3FF` | `#B7D7F7` |
| `hewan` | gradien `#BFEBFF` 0, `#E3F7FF` 0,52, `#E3F7FF` 1 | `#9FD3A0` |
| `buahSayur` | `#FFEAF3` | `#F5BCD3` |
| `warna`, `bayangan` | `#F3EEFF` | `#D0BFFF` |
| `bentuk` | `#EEF1FF` | `#C5CEF7` |
| `musik` | `#FFF0F6` | `#F8C4D9` |
| `membaca` | `#FFF1E6` | `#F7C9A5` |
| `mainYuk` | `#E3FAFA` | `#9EDCDD` |
| `cocokkan` | `#FDF0F6` | `#F5BCD3` |
| `memori` | `#EAF2FF` | `#B7D0F7` |
| `puzzle` | `#FFF4E0` | `#F2C57C` |
| `balon` | gradien `#8FD3FF` 0, `#CDEBFF` 0,6, `#EAF6FF` 1 | `#8ECBEE` |
| `besarKecil` | `#EBFBEE` | `#B2F2BB` |
| `mewarnai` | `#FFF8E1` | `#F2D27A` |
| `karyaku` | `#FFF7E0` | `#F2D27A` |
| `hebat` | `#FFE58F` | `#F2C94C` |
| `istirahat` | gradien `#241D4A` 0, `#3E3180` 0,55, `#7C6BD6` 1 | `#1F1846` |
| `gerbang` | `#3B3170` | `#1F1846` |
| `orangTua` | `#F1EEF9` | `#DCD5EE` |

`istirahat` dan `gerbang` bertanda `dark`, jadi teksnya putih dan kontrasnya diuji terpisah.

### Huruf

Fredoka untuk judul, angka, dan tombol. Nunito untuk isi dan label. Delapan berkas ada di `assets/fonts` dan dimuat semua tes lewat `test/flutter_test_config.dart`.

| Token | Gaya |
| --- | --- |
| `MociText.title` | Fredoka 700, 46 |
| `MociText.button` | Fredoka 600, 24 |
| `MociText.body` | Nunito 800, 23 |
| `MociText.label` | Nunito 800, 17 |
| `MociText.bigNumber` | Fredoka 700, 240 |

### Ukuran

| Token | Nilai |
| --- | --- |
| `MociSize.backButton` | 76 |
| `MociSize.backRadius` | 26 |
| `MociSize.backShadow` | 7 |
| `MociSize.topPillHeight` | 64 |
| `MociSize.topShadow` | 6 |
| `MociSize.pillHeight` | 50 |
| `MociSize.pillShadow` | 5 |
| `MociSize.menuCardTablet` | 236 × 214 |
| `MociSize.menuCardPhone` | 156 × 142 |
| `MociSize.menuRadiusTablet` | 34 |
| `MociSize.menuRadiusPhone` | 26 |
| `MociSize.menuShadow` | 10 |
| `MociSize.panelRadius` | 44 |
| `MociSize.panelShadow` | 12 |
| `MociSize.minTouchTablet` | 64 |
| `MociSize.minTouchPhone` | 56 |
| `MociSize.targetGap` | 16 |
| `MociSize.edgeTablet` | 32 |
| `MociSize.topBarTop` | 22 |

### Gerak

| Token | Nilai |
| --- | --- |
| `MociMotion.press` | 120 ms |
| `MociMotion.pressDepth` | 5 |
| `MociMotion.pressScale` | 0,97 |
| `MociMotion.popIn` | 450 ms |
| `MociMotion.popCurve` | `Cubic(0.3, 1.6, 0.5, 1)` |
| `MociMotion.shake` | 450 ms |
| `MociMotion.tapCooldown` | 400 ms |

Bayangan selalu padat tanpa blur, bergeser lurus ke bawah, dan tidak memakan tempat tata letak.

## 2. Komponen bersama

| Komponen | Kapan dipakai |
| --- | --- |
| `MociPressable` | Semua target sentuh yang terlihat timbul. Default bayangan 7, radius 26, turun 5 pt dan mengecil ke 0,97 saat ditekan, bunyi klik, dan jeda ketuk 400 ms. |
| `MociButton` | Tombol berlabel. Tiga jenis: `primary` hijau, `light` putih, `accent` oranye. Tinggi bawaan 70 dan radius setengah tinggi. |
| `MociBackButton` | Tombol kembali di kiri atas semua layar. 76 × 76. Tanpa `onTap`, ia mem-pop rute, atau kembali ke Beranda kalau tidak ada rute. |
| `MociTopBar` | Baris judul di atas layar. Margin tepi 32 dan jarak atas 22 sudah termasuk. |
| `MociIllustration` | SVG dari `assets/illustrations/<id>.svg`. `silhouette` mewarnai seluruh gambar dengan tinta, dipakai Tebak Bayangan. |
| `MociMascot` | Maskot Moci dengan tiga pose: `biasa`, `senang`, `tidur`. `biasa` digambar `CustomPainter` dan beranimasi; dua pose lain memakai gambar utuh yang bergerak. |
| `MociDialog` | Dialog di atas layar. Lapisan `rgba(43, 35, 80, 0.55)`, panel putih radius 40, tidak tertutup oleh ketukan luar atau back sistem. Penutupnya tombol di `actions`. |
| `NumberKeypad` | Papan angka Gerbang. Tombol 96 × 84 dengan jarak 14, tanpa jeda ketuk supaya hapus dua kali berurutan tetap diterima. |
| `StarCounter` | Pil bintang dan jumlahnya. Tinggi 64 di tablet, 48 dalam mode `compact` untuk HP. |

Komponen permainan bersama ada di `lib/widgets/game/`: `GameModePill` (pil mode), `AnswerCard` (kartu pilihan jawaban), `ProgressDots` (kemajuan enam ronde), dan `GameGlyph` (ikon garis: dengar, centang, putar, berikutnya, hitung, bintang).

### Tata letak lima menu

Semua layar memakai panggung tablet 1180 × 820, bilah atas `MociTopBar` dengan tombol kembali, dan `GameModePill` bila punya dua mode.

| Layar | Tata letak |
| --- | --- |
| Dunia Hewan | Kartu besar di kiri berisi ilustrasi, nama, fakta, tombol "Dengar suara", dan pil lima kelompok; rail kanan memuat 42 hewan dalam dua kolom |
| Buah & Sayur | Kenali: kisi enam kolom berisi 35 kartu. Tebak: gelembung soal dengan nama berwarna, tiga `AnswerCard`, dan `ProgressDots` enam soal |
| Warna | Set 12 kartu per warna: sampai empat gambar bertanda warna itu dan sisanya warna lain, plus 11 chip warna dan tombol "Gambar baru" serta "Warna lain" |
| Bentuk | Kenali: kartu kiri 640 × 668 dengan tanda sudut 48 pt dan kisi kanan dua kolom. Cari: bilah soal 1100 × 92, papan 1100 × 548, opsi 3/4/6 pilihan dengan lencana centang 56 pt |
| Main Musik | Xilofon: bilah lagu 1100 × 88, papan 1100 × 562 dengan dua rel dan delapan batang 100 pt. Drum: empat pad 240 × 300, tombol "Mainkan irama" 72 pt, dan teks petunjuk |

Aturan level usia Bentuk: 2–3 tahun 5 bentuk dan 3 pilihan, 4–5 tahun 8 bentuk dan 4 pilihan, 6–7 tahun 10 bentuk dan 6 pilihan. Jumlah pilihan selalu memuat target dan tidak pernah melebihi isi pool.

Hanya Bentuk Cari yang berakhir: enam ronde, lalu `finishGame(gameId: 'bentuk', …)` dan layar Hebat. Buah Tebak, Warna, dan Main Musik berputar tanpa akhir. Main Musik tidak memberi hadiah; setelah satu lagu selesai ia menampilkan pil "Hebat! Kamu memainkan satu lagu!" selama 3,5 detik lalu kembali ke keadaan bebas.

## 3. Panggung tablet dan HP

`MociStage` menggambar latar tema penuh layar, lalu menempatkan isi berukuran dasar di area aman, diskalakan proporsional dan dipusatkan. Sisa ruang diisi latar.

| Hal | Nilai |
| --- | --- |
| Dasar tablet | 1180 × 820 (`kTabletBase`) |
| Dasar HP | 844 × 390 (`kPhoneBase`) |
| Ambang | `layoutKindFor`: tablet kalau sisi terpendek layar ≥ 600 dp |
| Skala | `fitStage`: `min(lebar tersedia / lebar dasar, tinggi tersedia / tinggi dasar)` |

Isi panggung menerima `MediaQuery` dengan ukuran dasar, padding nol, dan penskala teks sesuai `textScaleCap`. Layar permainan memakai bawaan 1,0, artinya teks tidak ikut pengaturan sistem. Area Orang Tua memakai 1,3.

Aturan D12: layar yang belum punya desain HP menampilkan desain tablet yang diperkecil. `MociStage` hanya memakai builder `phone` kalau layar menyediakannya; kalau tidak, ia memakai builder `tablet` dan mencetak satu pesan debug. Baru Splash dan Beranda punya layout HP. Menambah layout HP berarti mengisi `phone:` dan memakai `context.layoutKind`.

## 4. Gerak dan gerak dikurangi

- Tekan: turun 5 pt, skala 0,97, 120 ms, ditambah bunyi klik.
- Muncul: membesar memantul 450 ms dengan kurva `Cubic(0.3, 1.6, 0.5, 1)`.
- Jawaban salah: goyang 450 ms dan merah sekejap.
- Maskot diam: satu putaran sekitar 2,6 detik.

Saat `MediaQuery.disableAnimations` aktif, animasi hiasan berhenti: maskot, Splash, langit Beranda, adegan Istirahat, dan kedipan bintang. Umpan balik benar dan salah tetap muncul, tetapi tanpa pantulan, dan target sentuh tetap bisa ditekan. Pemeriksaan ini ada di `lib/widgets/moci_mascot.dart`, `lib/features/istirahat/istirahat_scene.dart`, `lib/features/orang_tua/gerbang_screen.dart`, dan `lib/features/hadiah/hebat_screen.dart`.

## 5. Umpan balik suara

- Setiap `MociPressable` membunyikan `Sfx.klik` kecuali dimatikan dengan `clickSound: false`.
- Nama efek: `klik`, `benar`, `salahLembut`, `sorak`, `bintang`. Bunyi gagal selalu lembut, tanpa buzzer.
- Prioritas dari `AudioService`: narasi di atas efek, efek di atas musik. Volume 1,0; 0,7; 0,25, dan musik turun ke 0,10 selama narasi berbunyi.
- Suara berhenti saat aplikasi ke latar. Berkas efek dan musik belum ada di repo; pemutaran dicek ke `AssetCatalog`, jadi aset yang belum ada tidak menimbulkan galat.

## 6. Aksesibilitas

- Target sentuh minimal 64 pt di tablet dan 56 pt di HP, jarak antar target minimal 16 pt, margin tepi 32 pt di tablet.
- Kontras teks minimal 4,5 : 1. `test/app/theme/contrast_test.dart` memeriksa tinta di atas semua latar terang, tinta lembut di atas putih, dan teks putih di layar gelap.
- Teks permainan tidak ikut pengaturan sistem; Area Orang Tua mengikuti sampai 1,3 kali.
- Setiap target punya label semantik dari ARB. Gambar tanpa `semanticLabel` dikeluarkan dari pohon semantik, supaya pembaca layar tidak membacakan nama berkas. `NumberKeypad` memberi label hapus dan mengeluarkan ikon dari semantik.
- Suara dulu, teks kedua: setiap instruksi penting dibacakan lewat `Narrator`, dan teks di layar tetap ada sebagai pendamping.

## 7. Membaca artboard prototipe

Snapshot ada di `docs/design/prototype/`: 40 artboard `*.dc.html` dan `canvas.json`. Snapshot ini beku; jangan mengeditnya.

1. Buka artboard yang sesuai, misalnya `Main.dc.html` untuk Beranda atau `Gate.dc.html` untuk Gerbang.
2. Teks diambil dari objek `T` di skrip artboard. Salin persis ke ARB, dalam ID dan EN, dengan kunci `<layar><KunciT>`.
3. Warna latar dan bayangan dicocokkan ke `MenuTheme`. Kalau belum ada, tambah nilai enum, jangan menulis warna langsung di layar.
4. Ukuran dan jarak diambil dari gaya elemen di artboard, lalu dibandingkan dengan `MociSize`. Angka yang berulang naik menjadi token.
5. Data isi, bukan tata letak, diambil dari fungsi `data()` di artboard. Hasil ekspornya sudah ada di `assets/content/`, dan rincian per dataset ada di `docs/design/notes/inventaris-konten.md`.

## 8. Keputusan desain

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
| D10 | Hadiah diberikan saat permainan selesai, bukan saat "Ambil hadiah". Di Hebat, "Main lagi" kembali ke permainan tadi dan "Lanjut" ke Beranda. Katalog 30 stiker (6 per tema). Stiker baru dipilih acak dari yang belum dimiliki; kalau semua sudah dimiliki, anak hanya mendapat bintang. | Prototipe tidak punya katalog stiker ("8 / 30"), dan "Main lagi" di prototipe selalu ke hub. |
| D11 | Area Orang Tua: (a) nama diubah lewat dialog di Area Orang Tua, bukan dengan membuka Sambutan; (b) "Minggu ini" = jumlah item berbeda yang dibuka dalam 7 hari terakhir per modul, dibagi total isi modul; (c) saran = modul dengan cakupan terendah, dengan teks baru yang perlu ditinjau; (d) "Hapus semua data" ada di baris badge bawah, memakai dialog dua langkah, dan menghapus semua pengaturan serta file. | Prototipe memakai angka palsu dan tidak punya "Hapus semua data". |
| D12 | Layar yang belum punya desain HP (semua kecuali Splash dan Beranda) sementara menampilkan desain tablet yang diperkecil di HP. | PRD: layar HP didesain dulu sebelum dibangun (Rencana 08). |
| D13 | Pil "Untuk orang tua" hanya ada di Waktu Habis, tidak di Istirahat. | Supaya istirahat tidak bisa dilewati. |
| D14 | Waktu bermain dihitung di Beranda, semua menu, dan Hebat. Tidak dihitung di Splash, Sambutan, Gerbang, Area Orang Tua, Istirahat, dan Waktu Habis. | Spec ditambah perilaku prototipe. |
