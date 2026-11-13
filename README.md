<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/github/banner-dark.png">
    <img src="docs/brand/github/banner-light.png" alt="Moci — Main & Belajar" width="100%">
  </picture>
</p>

<p align="center">
  <b>Aplikasi belajar dan bermain untuk anak usia 2–7 tahun.</b><br>
  Tanpa iklan · Tanpa pembelian dalam aplikasi · Bisa offline · Bahasa Indonesia &amp; English<br>
  iPad · iPhone · Android (HP &amp; tablet)
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-desain%20%26%20prototipe-FFB020" alt="Status: desain & prototipe">
  <img src="https://img.shields.io/badge/Flutter-iOS%20%7C%20Android-1C8CF0" alt="Flutter untuk iOS dan Android">
  <img src="https://img.shields.io/badge/usia-2%E2%80%937%20tahun-26A03B" alt="Usia 2–7 tahun">
  <img src="https://img.shields.io/badge/iklan-tidak%20ada-F03E7C" alt="Tanpa iklan">
</p>

> **English summary:** Moci is an ad-free, offline-first learning and play app for children aged 2–7, available in Bahasa Indonesia and English. Kids trace letters and numbers, count, read syllables and sentences, explore animals, fruit, colours, shapes and music, play six mini games, and colour pictures without ever going outside the lines. Everything stays on the device. The design and interactive prototype are done; the Flutter app for iPad, iPhone and Android is in development.

---

## Daftar isi

- [Tentang Moci](#tentang-moci)
- [Fitur](#fitur)
- [Tampilan aplikasi](#tampilan-aplikasi)
- [Untuk orang tua: privasi & keamanan](#untuk-orang-tua-privasi--keamanan)
- [Teknologi](#teknologi)
- [Struktur repo](#struktur-repo)
- [Menjalankan aplikasi](#menjalankan-aplikasi)
- [Brand & aset](#brand--aset)
- [Roadmap](#roadmap)
- [Lisensi](#lisensi)

---

## Tentang Moci

Moci adalah teman main dan belajar untuk anak usia dini. Maskotnya, Moci, makhluk kecil kuning berbentuk bulat dengan tunas daun di kepala, menemani anak di setiap layar: menyapa dengan nama anak, memberi petunjuk lewat suara, dan merayakan setiap keberhasilan.

Prinsip yang dipegang di semua layar:

- **Tanpa iklan, tanpa pembelian, tanpa akun.** Anak tidak pernah diarahkan keluar dari aplikasi.
- **Data hanya di perangkat.** Nama anak, pengaturan, dan karya tersimpan lokal. Tidak ada server dan tidak ada analytics pihak ketiga.
- **Bisa offline.** Semua konten ikut terpasang di aplikasi.
- **Dua bahasa.** Teks dan suara tersedia dalam Bahasa Indonesia dan English, dan bisa diganti kapan saja.
- **Ramah anak kecil.** Tombol besar, sedikit teks, banyak suara dan animasi, umpan balik positif, dan tingkat kesulitan yang menyesuaikan usia (2–3, 4–5, 6–7 tahun).

## Fitur

| Menu | Isi |
|---|---|
| **Kenal Huruf** | 26 huruf A–Z dengan gambar dan contoh kata, bisa dibaca sebagai bunyi (fonik) atau nama huruf, latihan menulis (tracing) dengan panah arah, dan latihan mengucapkan. |
| **Berhitung** | Angka 1–50 dengan benda untuk dihitung bersama, serta latihan menulis angka 0–9. |
| **Dunia Hewan** | 42 hewan dalam 5 kelompok, lengkap dengan nama, tiruan suara, dan fakta singkat. |
| **Buah & Sayur** | 21 buah dan 14 sayur, dengan mode Kenali dan mode Tebak. |
| **Warna** | 11 warna. Anak menyentuh semua benda yang warnanya diminta. |
| **Bentuk** | 10 bentuk, termasuk menghitung sisi dan sudutnya, plus mode Cari. |
| **Main Musik** | Xilofon 8 nada dengan lagu untuk diikuti, serta drum dengan 4 bunyi dan contoh irama. |
| **Ayo Membaca** | Suku kata (ba-bi-bu-be-bo), menyusun kata dari suku kata, dan membaca kalimat dengan kata yang menyala satu per satu. |
| **Main Yuk!** | 6 mini game: Cocokkan Gambar, Kartu Memori, Tebak Bayangan, Puzzle, Balon Huruf, Besar & Kecil. |
| **Mewarnai** | 14 gambar. Warna tidak bisa keluar garis. Ada kuas, isi warna, penghapus, stiker, dan Karyaku untuk menyimpan hasil. |
| **Hadiah** | Bintang dan stiker setiap kali anak menyelesaikan permainan. |
| **Untuk orang tua** | Gerbang orang tua, profil anak, ringkasan perkembangan, cara baca huruf, batas waktu harian, dan pengingat istirahat. |

## Tampilan aplikasi

Semua tangkapan layar diambil dari prototipe interaktif versi tablet (1180 × 820).

### Mulai

<table>
<tr>
<td width="50%"><img src="docs/screenshots/01-splash.png" alt="Splash screen"><br><b>Splash.</b> Moci jatuh dari atas lalu memantul, huruf M-o-c-i muncul satu per satu, lalu tagline "Main &amp; Belajar".</td>
<td width="50%"><img src="docs/screenshots/02-sambutan.png" alt="Sambutan"><br><b>Sambutan.</b> Orang tua memilih bahasa, mengisi nama panggilan anak, dan memilih usia. Data hanya tersimpan di perangkat.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/03-beranda.png" alt="Beranda"><br><b>Beranda.</b> Moci menyapa "Hai, &lt;nama anak&gt;!". Ada 10 menu bergambar, tombol lanjutkan, pengganti bahasa ID/EN, jumlah bintang, dan pintu ke Area Orang Tua.</td>
<td width="50%"><img src="docs/screenshots/31-beranda-hp.png" alt="Beranda versi HP"><br><b>Beranda versi HP.</b> Tata letak landscape untuk iPhone dan HP Android.</td>
</tr>
</table>

### Huruf & Angka

<table>
<tr>
<td width="50%"><img src="docs/screenshots/04-huruf.png" alt="Kenal huruf"><br><b>Kenal Huruf.</b> Huruf besar dan kecil, gambar, dan contoh kata. Ketuk untuk mendengar bunyi huruf (fonik) atau nama hurufnya.</td>
<td width="50%"><img src="docs/screenshots/05-tulis-huruf.png" alt="Tulis huruf"><br><b>Tulis Huruf (tracing).</b> 26 huruf. Anak menggeser Moci mengikuti panah kuning, garis demi garis, sampai ke bintang.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/06-ucapkan.png" alt="Ucapkan"><br><b>Ucapkan.</b> Dengar contoh, lalu anak mengucapkan kata. Untuk sementara mikrofonnya masih simulasi.</td>
<td width="50%"><img src="docs/screenshots/07-berhitung.png" alt="Berhitung"><br><b>Berhitung.</b> Angka 1–50 dengan nama angkanya. Tombol "Hitung bareng" menghitung benda satu per satu.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/08-tulis-angka.png" alt="Tulis angka"><br><b>Tulis Angka.</b> Tracing angka 0–9 dengan panduan arah yang sama seperti huruf.</td>
<td width="50%"></td>
</tr>
</table>

### Dunia Sekitar

<table>
<tr>
<td width="50%"><img src="docs/screenshots/09-hewan.png" alt="Dunia hewan"><br><b>Dunia Hewan.</b> 42 hewan dalam 5 kelompok: peliharaan &amp; ternak, hutan &amp; savana, reptil &amp; katak, laut &amp; air, serta burung &amp; serangga. Ada tombol dengar nama, dengar suara, dan fakta singkat.</td>
<td width="50%"><img src="docs/screenshots/10-buah-sayur.png" alt="Buah dan sayur"><br><b>Buah &amp; Sayur.</b> Mode Kenali untuk mengenal nama, dan mode Tebak dengan tiga pilihan gambar.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/11-warna.png" alt="Warna"><br><b>Warna.</b> Anak menyentuh semua benda yang warnanya diminta. Ada 11 warna, dan tombol "Gambar baru" mengacak isi layar.</td>
<td width="50%"><img src="docs/screenshots/12-bentuk.png" alt="Bentuk"><br><b>Bentuk.</b> 10 bentuk berwajah lucu. Tombol "Hitung sudut" menandai sudut satu per satu sambil menyebut angkanya.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/12b-bentuk-cari.png" alt="Bentuk mode cari"><br><b>Bentuk: Cari.</b> "Mana segitiga?" Warna sengaja diacak, jadi anak mengenali bentuk, bukan warna. Jumlah pilihan menyesuaikan usia.</td>
<td width="50%"><img src="docs/screenshots/13-musik-xilofon.png" alt="Xilofon"><br><b>Main Musik: Xilofon.</b> 8 nada do–do. Mode "Ikuti" menunjukkan balok berikutnya untuk memainkan lagu Twinkle Twinkle atau Mary Had a Little Lamb.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/13b-musik-drum.png" alt="Drum"><br><b>Main Musik: Drum.</b> Ada drum, tepuk, simbal, dan kerincing, plus contoh irama untuk diikuti.</td>
<td width="50%"></td>
</tr>
</table>

### Ayo Membaca

<table>
<tr>
<td width="50%"><img src="docs/screenshots/14-suku-kata.png" alt="Suku kata"><br><b>Suku Kata.</b> Pilih konsonan untuk membentuk ba-bi-bu-be-bo. Ketuk suku kata untuk mendengarnya, lalu lihat contoh katanya.</td>
<td width="50%"><img src="docs/screenshots/15-susun-kata.png" alt="Susun kata"><br><b>Susun Kata.</b> Dengarkan kata, lalu ketuk suku katanya secara berurutan. Ada level 2 dan 3 suku kata.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/16-kalimat.png" alt="Kalimat"><br><b>Kalimat.</b> "Baca bersama" menyalakan kata satu per satu seperti karaoke. Ada juga mode Tebak Gambar.</td>
<td width="50%"></td>
</tr>
</table>

### Main Yuk!

<table>
<tr>
<td width="50%"><img src="docs/screenshots/17-main-yuk.png" alt="Main Yuk"><br><b>Main Yuk!</b> Enam mini game dengan label usia.</td>
<td width="50%"><img src="docs/screenshots/18-cocokkan.png" alt="Cocokkan"><br><b>Cocokkan Gambar.</b> Hubungkan gambar yang sama dengan ketuk-ketuk atau tarik garis. Temanya acak: buah, hewan, sayur, kendaraan, benda.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/19-kartu-memori.png" alt="Kartu memori"><br><b>Kartu Memori.</b> Buka dua kartu dan temukan pasangannya. Tersedia 4, 6, atau 8 pasang.</td>
<td width="50%"><img src="docs/screenshots/20-tebak-bayangan.png" alt="Tebak bayangan"><br><b>Tebak Bayangan.</b> "Bayangan siapa ini?" Pilih gambar yang cocok, dan bayangannya berubah jadi berwarna.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/21-puzzle.png" alt="Puzzle"><br><b>Puzzle.</b> Ketuk potongan, lalu ketuk tempatnya. Ada 4, 6, atau 9 potongan sesuai usia.</td>
<td width="50%"><img src="docs/screenshots/22-balon-huruf.png" alt="Balon huruf"><br><b>Balon Huruf.</b> Moci menyebut satu huruf, lalu anak memecahkan balon yang hurufnya cocok. Ada 5 ronde.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/23-besar-kecil.png" alt="Besar dan kecil"><br><b>Besar &amp; Kecil.</b> "Mana yang paling besar?" atau "paling kecil?". Benda yang sama ditampilkan dalam beberapa ukuran.</td>
<td width="50%"></td>
</tr>
</table>

### Mewarnai

<table>
<tr>
<td width="50%"><img src="docs/screenshots/24-galeri-mewarnai.png" alt="Galeri mewarnai"><br><b>Pilih Gambar.</b> 14 gambar hewan, benda, dan alam, plus Karyaku.</td>
<td width="50%"><img src="docs/screenshots/25-mewarnai.png" alt="Kanvas mewarnai"><br><b>Kanvas.</b> Warna tidak bisa keluar garis. Coretan terkunci di bagian gambar tempat jari mulai menyentuh. Ada kuas 3 ukuran, isi warna, penghapus, stiker, batal, dan 16 krayon.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/26-karyaku.png" alt="Karyaku"><br><b>Karyaku.</b> Semua hasil yang disimpan. Ketuk untuk melihat lebih besar, mewarnai lagi, atau menghapus.</td>
<td width="50%"></td>
</tr>
</table>

### Hadiah & Istirahat

<table>
<tr>
<td width="50%"><img src="docs/screenshots/27-hadiah.png" alt="Hadiah"><br><b>Hadiah.</b> Bintang dan stiker baru setiap kali anak menyelesaikan permainan.</td>
<td width="50%"><img src="docs/screenshots/28-istirahat.png" alt="Istirahat"><br><b>Waktunya Istirahat.</b> Muncul setiap 20 menit bermain jika pengingat aktif. Ada hitungan mundur dengan tiga gerakan sederhana.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/28b-waktu-habis.png" alt="Waktu habis"><br><b>Waktu Habis.</b> Muncul saat batas waktu harian tercapai. Hanya orang tua yang bisa membuka lagi.</td>
<td width="50%"></td>
</tr>
</table>

### Orang tua

<table>
<tr>
<td width="50%"><img src="docs/screenshots/29-gerbang-orang-tua.png" alt="Gerbang orang tua"><br><b>Gerbang Orang Tua.</b> Soal perkalian sederhana supaya anak tidak membuka pengaturan atau tautan keluar.</td>
<td width="50%"><img src="docs/screenshots/30-area-orang-tua.png" alt="Area orang tua"><br><b>Area Orang Tua.</b> Profil anak, waktu bermain hari ini, perkembangan minggu ini, bahasa, cara baca huruf, batas waktu harian, musik, efek suara, dan pengingat istirahat.</td>
</tr>
</table>

## Untuk orang tua: privasi & keamanan

- Tidak ada iklan, tidak ada pembelian dalam aplikasi, dan tidak perlu akun.
- Tidak ada server. Nama anak, pengaturan, perkembangan, dan karya disimpan di perangkat saja.
- Tidak ada analytics atau SDK pihak ketiga yang melacak anak.
- Pengaturan dan tautan apa pun berada di balik Gerbang Orang Tua.
- Batas waktu harian (15, 30, atau 45 menit, atau tanpa batas) dan pengingat istirahat bisa diatur orang tua.

## Teknologi

| Bagian | Pilihan |
|---|---|
| Framework | Flutter (Dart), satu kode untuk iPad, iPhone, HP Android, dan tablet Android |
| Ilustrasi | SVG, dirender dengan `flutter_svg` dan di-precompile supaya cepat |
| Tracing & mewarnai | Kanvas Flutter (`CustomPainter` + clip path). Coretan yang sudah selesai disimpan sebagai gambar diam supaya ringan |
| Animasi | Animasi bawaan Flutter, tanpa Lottie, Rive, atau video |
| Suara | File audio pendek terkompresi (`just_audio`). TTS perangkat sebagai cadangan |
| Penyimpanan | File lokal kecil. Karya anak disimpan sebagai data coretan, bukan foto |
| Jaringan | Tidak ada. Aplikasi 100% offline |
| Build & rilis | Xcode atau Codemagic untuk iOS, Gradle untuk Android. TestFlight dan Play internal testing |

Target: ukuran aplikasi di bawah 30 MB dan animasi 60 fps, termasuk di tablet Android kelas bawah.

## Struktur repo

Rencana struktur saat kode Flutter mulai ditulis:

```
moci-app/
├── lib/
│   ├── app/            # shell aplikasi, navigasi, tema
│   ├── features/       # satu folder per menu (huruf, angka, hewan, mewarnai, ...)
│   ├── widgets/        # komponen bersama (tombol, kartu, maskot)
│   └── data/           # pemuat konten JSON & penyimpanan lokal
├── assets/
│   ├── illustrations/  # SVG hewan, buah, sayur, benda, kendaraan
│   ├── coloring/       # data halaman mewarnai (JSON)
│   ├── tracing/        # jalur huruf & angka (JSON)
│   ├── content/        # katalog kata, kalimat, fakta (JSON)
│   └── audio/          # narasi & suara hewan
├── docs/
│   ├── brand/          # ikon, logo, splash, aset GitHub (PNG + SVG)
│   └── screenshots/    # tangkapan layar untuk README
└── README.md
```

## Menjalankan aplikasi

> Kode Flutter belum ada di repo ini. Langkah di bawah berlaku setelah proyek Flutter dibuat.

```bash
flutter pub get
flutter run            # pilih simulator iPad/iPhone atau perangkat Android
```

## Brand & aset

Semua aset brand final ada di [`docs/brand`](docs/brand), dalam format PNG dan SVG.

| Folder | Isi |
|---|---|
| `docs/brand/icon/ios` | Ikon 1024 px versi terang, gelap, dan tinted |
| `docs/brand/icon/android` | Layer adaptive icon (foreground, background, monochrome), ikon Play Store 512 px, dan ikon lama |
| `docs/brand/logo` | Logo bertumpuk dan mendatar (warna, hitam, putih, untuk latar gelap), tulisan Moci, dan maskot |
| `docs/brand/splash` | Logo untuk splash screen dan ikon splash Android 12+ |
| `docs/brand/github` | Social preview 1280 × 640, banner README terang & gelap, avatar |

- **Ilustrasi** digambar khusus untuk Moci, bukan diambil dari situs lain.
- **Font:** [Fredoka](https://fonts.google.com/specimen/Fredoka) dan [Nunito](https://fonts.google.com/specimen/Nunito), keduanya berlisensi SIL Open Font License 1.1.
- **Warna utama:** biru langit `#74C4FF`, kuning Moci `#FFD43B`, navy `#2B2350`. Huruf logo: pink `#F03E7C`, oranye `#FF9F1C`, biru `#1C8CF0`, hijau `#26A03B`.

## Roadmap

- [x] Desain dan prototipe interaktif semua menu (versi tablet)
- [x] Ikon, logo, splash screen, dan aset GitHub
- [ ] Tata letak versi HP untuk semua layar
- [ ] Rekaman narasi Bahasa Indonesia & English
- [ ] Suara hewan asli (berlisensi CC0 atau Pixabay)
- [ ] Pengenalan suara on-device untuk layar Ucapkan
- [ ] Aplikasi Flutter: shell, navigasi, penyimpanan lokal
- [ ] Porting semua menu ke Flutter
- [ ] Uji di perangkat (iPad, iPhone, HP dan tablet Android)
- [ ] Rilis TestFlight dan Play internal testing, lalu App Store dan Play Store

## Lisensi

Belum ditentukan. Sampai ada keputusan, seluruh kode, ilustrasi, dan aset brand di repo ini dilindungi hak cipta (all rights reserved).
