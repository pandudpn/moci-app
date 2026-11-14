> Salinan dari Claude Docs "Dokumentasi Moci", tab Sistem Desain, per 2026-11-14. Sumber kebenaran: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Sistem Desain Moci

Sistem desain Moci diambil langsung dari prototipe: latar lembut berbeda untuk tiap menu, teks ungu tua, huruf bulat, dan tombol tebal dengan bayangan padat yang terasa seperti mainan. Semua nilai di sini menjadi token di tema Flutter (`lib/app/theme`).

## Warna

### Warna inti

| Peran | Hex | Dipakai untuk |
| --- | --- | --- |
| Tinta | `#2B2350` | Semua teks utama dan ikon garis |
| Tinta lembut | `#6B5F99` | Teks pendukung dan label kecil |
| Kuning Moci | `#FFD43B` | Badan maskot, bintang, sorotan |
| Biru langit | `#74C4FF` | Latar ikon aplikasi dan langit Beranda |
| Benar | `#26A03B`, bayangan `#1E8A31` | Umpan balik benar dan tombol lanjut |
| Salah | `#E8384F` | Penanda salah yang muncul sekejap |
| Huruf logo | `#F03E7C`, `#FF9F1C`, `#1C8CF0`, `#26A03B` | Huruf M-o-c-i dan aksen hiasan |
| Putih | `#FFFFFF` | Kartu dan tombol |

### Latar per menu

Setiap menu punya satu latar lembut. Bayangan tombol di menu itu memakai versi lebih gelap dari warna yang sama, misalnya `#F3C2B3` di Kenal Huruf.

| Layar | Latar |
| --- | --- |
| Beranda | Gradasi `#74C4FF` ke `#B5E2FF` ke `#DDF3FF` |
| Sambutan | `#DDF3FF` |
| Kenal Huruf dan Ucapkan | `#FFEDE6` |
| Berhitung | `#E7F3FF` |
| Dunia Hewan | Gradasi `#BFEBFF` ke `#E3F7FF` |
| Buah & Sayur | `#FFEAF3` |
| Warna | `#F3EEFF` |
| Bentuk | `#EEF1FF` |
| Main Musik | `#FFF0F6` |
| Ayo Membaca | `#FFF1E6` |
| Main Yuk! | `#E3FAFA` dengan pola titik |
| Cocokkan Gambar | `#FDF0F6` |
| Kartu Memori | `#EAF2FF` |
| Tebak Bayangan | `#F3F0FF` |
| Puzzle | `#FFF4E0` |
| Balon Huruf | Gradasi `#8FD3FF` ke `#EAF6FF` |
| Besar & Kecil | `#EBFBEE` |
| Mewarnai dan Galeri | `#FFF8E1` |
| Karyaku | `#FFF7E0` |
| Hebat | `#FFE58F` |
| Istirahat | Gradasi malam `#241D4A` ke `#7C6BD6` |
| Gerbang Orang Tua | `#3B3170` |
| Area Orang Tua | `#F1EEF9` |

Warna tidak pernah jadi satu-satunya penanda. Jawaban benar dan salah selalu juga punya suara dan gerakan.

## Tipografi

Moci memakai dua font berlisensi SIL Open Font License 1.1: Fredoka untuk judul dan huruf besar, dan Nunito untuk teks biasa. Fredoka memakai bentuk a dan g satu tingkat, yang mirip tulisan tangan anak, jadi cocok untuk Kenal Huruf.

Ukuran di bawah ini dalam pt (logical pixel Flutter) pada ukuran dasar tablet 1180 × 820, sama dengan px di prototipe. Layout HP punya skala sendiri, dengan Beranda HP sebagai patokan.

| Peran | Font | Ukuran |
| --- | --- | --- |
| Judul layar | Fredoka 700 | 44–46 |
| Angka besar di Berhitung | Fredoka 700 | 200–240 |
| Teks tombol utama | Fredoka 600–700 | 24–30 |
| Teks isi | Nunito 700–800 | 22–24 |
| Label kecil | Nunito 800 | 15–18 |

Aturan:

- Font dibundel di `assets/fonts` dan tidak diunduh saat aplikasi berjalan. Jangan memakai paket `google_fonts` dengan mode unduh.
- Hanya subset huruf Latin yang dibundel, supaya ukuran font tetap di bawah 1 MB.
- Teks di bawah 18 pt hanya dipakai untuk label yang juga dibacakan, atau yang tidak penting bagi anak.

## Ukuran sentuh, jarak, sudut, dan bayangan

Target sentuh minimal 64 pt di tablet dan 56 pt di HP. Angka ini jauh di atas batas umum 44 pt, karena jari anak kecil belum tepat sasaran.

| Elemen | Ukuran tablet (pt) | Sudut (pt) | Bayangan |
| --- | --- | --- | --- |
| Tombol kembali | 76 × 76 | 26 | Turun 7 pt |
| Kartu menu Beranda | 236 × 214 (HP: 156 × 142) | 34 (HP: 26) | Turun 10–12 pt |
| Tombol kecil di bilah atas | 62 × 62 | 18 | Turun 6 pt |
| Tombol papan angka Gerbang | 88 × 88 | 28 | Turun 6 pt |
| Pil mode dan level | Tinggi 50 | Penuh | Turun 5 pt |
| Krayon | Area sentuh setinggi 96 | Tidak ada | Krayon terpilih naik sedikit |
| Panel isi besar | Mengikuti layar | 40–44 | Turun 12 pt |

Aturan:

- Bayangan selalu padat tanpa blur, bergeser lurus ke bawah. Warnanya versi gelap dari warna elemen atau latar menu.
- Saat ditekan, tombol turun 5 pt dan mengecil ke 97% selama 120 ms, seolah bayangannya tertekan.
- Jarak antar target sentuh minimal 16 pt. Margin tepi layar 32 pt di tablet.
- Sudut membulat di mana-mana. Tidak ada sudut tajam, kecuali pada bentuk yang memang diajarkan di menu Bentuk.

## Komponen utama

Sebelas komponen ini dipakai berulang di semua menu dan menjadi widget bersama di `lib/widgets`. Layar baru sebaiknya dirakit dari komponen ini dulu sebelum membuat yang baru.

| Komponen | Isi | Perilaku |
| --- | --- | --- |
| Tombol utama | Kotak membulat, teks Fredoka, bayangan padat | Turun 5 pt saat ditekan dan berbunyi klik halus. Tombol bergambar membacakan labelnya. |
| Tombol kembali | Kotak putih 76 pt dengan panah | Selalu di kiri atas, kembali satu layar |
| Kartu menu | Gambar besar, nama, dan subjudul pendek | Moci menyebut nama menu, lalu menu terbuka |
| Pil mode dan level | Deretan pilihan berbentuk pil | Pilihan aktif ditandai warna dan dibacakan |
| Maskot Moci | SVG pose biasa dan pose senang | Mengintip dan bergoyang pelan. Menyapa saat diketuk. |
| Kotak instruksi | Kalimat pendek dan tombol Dengar | Dibacakan otomatis saat layar dibuka, dan bisa diulang |
| Tombol mikrofon | Lingkaran besar dengan ikon mikrofon, hanya di Ucapkan | Berdenyut selama mendengar, paling lama 4 detik. Berubah hijau kalau ucapan cocok. |
| Kartu jawaban | Kartu putih besar berisi gambar | Benar: membesar, hijau, dan bersuara. Salah: bergoyang dan merah sekejap. |
| Penanda kemajuan | Titik-titik di bagian atas | Titik aktif memanjang. Titik selesai berubah hijau. |
| Dialog | Panel di tengah dengan latar diredupkan | Dipakai untuk detail karya dan konfirmasi hapus dua langkah |
| Papan angka | Tombol angka 88 pt | Hanya di Gerbang Orang Tua |

## Layout tablet dan HP

Setiap layar punya dua desain dasar, tablet 1180 × 820 pt dan HP 844 × 390 pt, keduanya landscape. Layar lain diskalakan proporsional dari salah satunya, dan sisa ruang diisi warna latar menu.

Pola tablet, diambil dari prototipe:

- Bilah atas berisi tombol kembali di kiri, judul layar, lalu pil mode atau level di kanan.
- Area isi ada di bawah bilah atas, dengan margin tepi 32 pt.
- Kotak instruksi dan tombol Dengar selalu di posisi yang sama dalam satu menu.

Pola HP:

- Baru Beranda yang punya desain HP. Layar lain mengikuti polanya: bilah atas lebih tipis, kartu menu 156 × 142 pt, dan tombol kecil 62 pt.
- Area aman di kiri dan kanan (notch, Dynamic Island, kamera berlubang) selalu dikosongkan.
- Kartu jawaban maksimal 4 per baris supaya tetap mudah disentuh.

Contoh penyesuaian di ukuran lain:

| Layar | Rasio | Hasil |
| --- | --- | --- |
| iPad 11 inci (1180 × 820) | 1,44 | Pas dengan desain dasar |
| iPad 4:3 (1024 × 768, 1366 × 1024) | 1,33 | Ada sisa ruang tipis di atas dan bawah |
| Tablet Android 16:10 (1280 × 800) | 1,60 | Ada sisa ruang di kiri dan kanan |
| Posisi potret di tablet | Di bawah 1 | Tidak terjadi, karena orientasi dikunci landscape. Kalau OS mengabaikan kunci, layout landscape diperkecil. |

## Animasi dan suara umpan balik

Gerak di Moci pendek dan memantul. Setiap ketukan dijawab dalam waktu kurang dari 100 ms dengan gerak, suara, atau keduanya, supaya anak tahu sentuhannya terbaca.

| Kejadian | Gerak | Suara |
| --- | --- | --- |
| Tombol ditekan | Turun 5 pt dan mengecil ke 97%, 120 ms | Klik halus |
| Elemen muncul | Membesar dengan pantulan, 400–550 ms, kurva `cubic-bezier(.3, 1.6, .5, 1)` | Tidak ada |
| Jawaban benar | Kartu membesar dengan garis hijau, Moci senang | "Betul!" ditambah nama bendanya, lalu denting |
| Jawaban salah | Kartu bergoyang 450 ms dan merah sekejap | "Bukan yang itu. Coba lagi!" dengan nada lembut |
| Permainan selesai | Layar Hebat: bintang muncul satu per satu, lalu stiker baru | "Hebat!" dan sorakan pendek |
| Maskot diam | Mengintip dan bergoyang pelan, satu putaran 2,4–3 detik | Tidak ada |
| Splash | Moci jatuh lalu memantul, huruf M-o-c-i muncul berselang 0,1 detik | Tidak ada |

Aturan:

- Tidak ada bunyi gagal yang keras, sedih, atau berupa buzzer.
- Efek suara paling lama 0,6 detik, supaya tidak menumpuk dengan narasi.
- Kalau perangkat meminta animasi dikurangi, semua animasi hiasan (mengintip, bergoyang, awan, bintang berkelip) dimatikan. Umpan balik benar dan salah tetap muncul, tetapi tanpa pantulan.
