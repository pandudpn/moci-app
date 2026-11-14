# Suara hewan Moci

**Keputusan per 14 November 2026:** semua suara hewan diambil dari [Freesound](https://freesound.org) dengan lisensi Creative Commons 0 (CC0). File CC0 boleh di-commit ke repo publik ini. Pixabay dan lisensi CC BY tidak dipakai.

Moci butuh 42 suara, satu untuk setiap hewan di menu Dunia Hewan. Sekitar 30 hewan memakai rekaman suara asli. 12 hewan lainnya tidak punya suara khas, misalnya ikan, semut, dan kupu-kupu, jadi memakai efek lucu yang cocok dengan tiruan bunyinya di katalog.

Daftar hewan, id, dan tiruan bunyi di bawah diambil dari prototipe (`docs/design/prototype/Hewan.dc.html`). Aturan format dan lisensi mengikuti tab Konten & Aset di dokumentasi Moci.

## Kenapa Freesound CC0

- **CC0 berarti pengunggah melepas semua haknya.** [FAQ Freesound](https://freesound.org/help/faq/) menyebut suara CC0 boleh dipakai "pretty much what you want", bahkan boleh dijual, asal kita tidak mengaku sebagai pembuatnya. Jadi suaranya boleh dipotong, dipakai di aplikasi yang dirilis ke store, dan disimpan di repo publik, tanpa perlu atribusi.
- **Pixabay tidak dipakai.** [Ketentuan Pixabay](https://pixabay.com/service/terms/) melarang pengunduhan otomatis dan massal, dan [lisensinya](https://pixabay.com/service/license-summary/) melarang distribusi file "standalone". Larangan kedua tidak cocok dengan repo publik.

## Aturan memilih suara

- Di halaman suara, pastikan lisensinya tertulis **Creative Commons 0** saat kamu mengunduh. Freesound juga punya CC BY dan CC BY-NC, dan keduanya tidak dipakai.
- CC0 adalah pernyataan dari pengunggah. Lewati suara yang terdengar seperti potongan film, TV, atau game, dan suara yang deskripsinya menyebut sumber lain. Utamakan rekaman lapangan dengan deskripsi yang jelas.
- Jangan pakai suara buatan AI yang asal-usulnya tidak jelas.
- Pilih yang jelas, pendek (maksimal 3 detik setelah dipotong), dan tidak menakutkan untuk anak kecil.
- **Kalau tidak ada yang cocok di CC0,** rekam sendiri: suara hewan yang mudah ditemui, atau efek dari benda di rumah. Jangan beralih ke Pixabay atau CC BY.

## Cara kerja per hewan

1. Login ke Freesound. Akunnya gratis, dan login wajib untuk mengunduh.
2. Buka link di tabel. Linknya sudah memakai filter Creative Commons 0; kalau filternya tidak terpasang, pilih "Creative Commons 0" di filter lisensi.
3. Dengarkan beberapa pilihan, lalu unduh file aslinya. Simpan di folder mentah **di luar repo**, misalnya `~/moci-audio-src/hewan/kucing.wav`, dengan nama file = id hewan. File mentah tidak perlu di-commit; yang masuk repo hanya hasil prosesnya.
4. Catat satu baris di `assets/audio/LICENSES.csv` dengan kolom `file,sumber,URL,lisensi,tanggal unduh,catatan`, contohnya:
   `hewan/kucing.m4a,Freesound,https://freesound.org/s/12345/,CC0,2026-11-20,"oleh <nama pengunggah>, dipotong jadi 1,8 detik"`
   Kolom `lisensi` hanya boleh berisi `CC0`, atau `Milik sendiri` untuk rekaman sendiri. Validator konten menolak nilai lain. Mencatat sumber dan pengunggah tidak diwajibkan CC0, tetapi membuat asal-usul setiap file tetap jelas.
5. Skrip pemrosesan audio di Rencana 09 mengubah file mentah menjadi `assets/audio/hewan/<id>.m4a`: mono, maksimal 3 detik, AAC, dengan kenyaringan −16 LUFS seperti narasi.

Untuk 12 hewan dengan efek buatan, cari efek CC0 di Freesound memakai link di tabel. Kalau tidak ada yang cocok, rekam benda di rumah. Contohnya sedotan ditiup di gelas air untuk "blub blub", kerupuk dikunyah untuk "nyam nyam", dan kertas dikibas cepat untuk kupu-kupu. Rekaman sendiri dicatat sebagai `Milik sendiri`.

## Daftar 42 hewan

Kolom "Jenis" menunjukkan apakah hewan memakai rekaman suara asli atau efek buatan. Semua link sudah difilter Creative Commons 0.

### Peliharaan & Ternak

| id | Nama | Tiruan bunyi (ID / EN) | Jenis | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `kucing` | Kucing / Cat | Meong! / Meow! | Rekaman asli | [cari](https://freesound.org/search/?q=cat+meow&f=license%3A%22Creative+Commons+0%22) |
| `anjing` | Anjing / Dog | Guk guk! / Woof woof! | Rekaman asli | [cari](https://freesound.org/search/?q=dog+bark&f=license%3A%22Creative+Commons+0%22) |
| `kelinci` | Kelinci / Rabbit | Hop hop! / Hop hop! | Efek buatan | [cari](https://freesound.org/search/?q=cartoon+hop&f=license%3A%22Creative+Commons+0%22) |
| `tikus` | Tikus / Mouse | Cit cit! / Squeak! | Rekaman asli | [cari](https://freesound.org/search/?q=mouse+squeak&f=license%3A%22Creative+Commons+0%22) |
| `sapi` | Sapi / Cow | Mooo! / Moo! | Rekaman asli | [cari](https://freesound.org/search/?q=cow+moo&f=license%3A%22Creative+Commons+0%22) |
| `kambing` | Kambing / Goat | Mbeeek! / Maa! | Rekaman asli | [cari](https://freesound.org/search/?q=goat+bleat&f=license%3A%22Creative+Commons+0%22) |
| `domba` | Domba / Sheep | Mbeee! / Baa! | Rekaman asli | [cari](https://freesound.org/search/?q=sheep+baa&f=license%3A%22Creative+Commons+0%22) |
| `kuda` | Kuda / Horse | Hiiihiii! / Neigh! | Rekaman asli | [cari](https://freesound.org/search/?q=horse+neigh&f=license%3A%22Creative+Commons+0%22) |
| `ayam` | Ayam / Chicken | Kukuruyuk! / Cock-a-doodle-doo! | Rekaman asli | [cari](https://freesound.org/search/?q=rooster+crow&f=license%3A%22Creative+Commons+0%22) |
| `bebek` | Bebek / Duck | Kwek kwek! / Quack quack! | Rekaman asli | [cari](https://freesound.org/search/?q=duck+quack&f=license%3A%22Creative+Commons+0%22) |

### Hutan & Savana

| id | Nama | Tiruan bunyi (ID / EN) | Jenis | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `singa` | Singa / Lion | Aum! / Roar! | Rekaman asli | [cari](https://freesound.org/search/?q=lion+roar&f=license%3A%22Creative+Commons+0%22) |
| `harimau` | Harimau / Tiger | Grrr, aum! / Grrr, roar! | Rekaman asli | [cari](https://freesound.org/search/?q=tiger+growl&f=license%3A%22Creative+Commons+0%22) |
| `gajah` | Gajah / Elephant | Tuuut! / Toot! | Rekaman asli | [cari](https://freesound.org/search/?q=elephant+trumpet&f=license%3A%22Creative+Commons+0%22) |
| `jerapah` | Jerapah / Giraffe | Hmmm... / Hmm... | Efek buatan | [cari](https://freesound.org/search/?q=cartoon+hum&f=license%3A%22Creative+Commons+0%22) |
| `zebra` | Zebra / Zebra | Kwaha! / Kwa-ha! | Rekaman asli | [cari](https://freesound.org/search/?q=zebra&f=license%3A%22Creative+Commons+0%22) |
| `monyet` | Monyet / Monkey | U-u-a-a! / Ooh-ooh-aah! | Rekaman asli | [cari](https://freesound.org/search/?q=monkey&f=license%3A%22Creative+Commons+0%22) |
| `orangutan` | Orangutan / Orangutan | Huu huu! / Hoo hoo! | Rekaman asli | [cari](https://freesound.org/search/?q=orangutan&f=license%3A%22Creative+Commons+0%22) |
| `beruang` | Beruang / Bear | Grrr! / Grrr! | Rekaman asli | [cari](https://freesound.org/search/?q=bear+growl&f=license%3A%22Creative+Commons+0%22) |
| `panda` | Panda / Panda | Nyam nyam! / Munch munch! | Efek buatan | [cari](https://freesound.org/search/?q=munching&f=license%3A%22Creative+Commons+0%22) |
| `badak` | Badak / Rhino | Hrmph! / Hrmph! | Rekaman asli | [cari](https://freesound.org/search/?q=rhino+snort&f=license%3A%22Creative+Commons+0%22) |
| `kudanil` | Kuda Nil / Hippo | Hrooo! / Hrooo! | Rekaman asli | [cari](https://freesound.org/search/?q=hippo&f=license%3A%22Creative+Commons+0%22) |
| `rubah` | Rubah / Fox | Ak ak! / Yip yip! | Rekaman asli | [cari](https://freesound.org/search/?q=fox+bark&f=license%3A%22Creative+Commons+0%22) |
| `quokka` | Quokka / Quokka | Hihi! / Hee hee! | Efek buatan | [cari](https://freesound.org/search/?q=cute+squeak&f=license%3A%22Creative+Commons+0%22) |

### Reptil & Katak

| id | Nama | Tiruan bunyi (ID / EN) | Jenis | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `buaya` | Buaya / Crocodile | Hssss! / Hiss! | Rekaman asli | [cari](https://freesound.org/search/?q=crocodile+hiss&f=license%3A%22Creative+Commons+0%22) |
| `ular` | Ular / Snake | Sssss! / Sss! | Rekaman asli | [cari](https://freesound.org/search/?q=snake+hiss&f=license%3A%22Creative+Commons+0%22) |
| `komodo` | Komodo / Komodo Dragon | Hssss! / Hiss! | Rekaman asli | [cari](https://freesound.org/search/?q=lizard+hiss&f=license%3A%22Creative+Commons+0%22) |
| `kura` | Kura-kura / Turtle | Pelan-pelan... / Slowly... | Efek buatan | [cari](https://freesound.org/search/?q=slow+footsteps&f=license%3A%22Creative+Commons+0%22) |
| `katak` | Katak / Frog | Kung kong! / Ribbit! | Rekaman asli | [cari](https://freesound.org/search/?q=frog+croak&f=license%3A%22Creative+Commons+0%22) |

### Laut & Air

| id | Nama | Tiruan bunyi (ID / EN) | Jenis | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `ikan` | Ikan / Fish | Blub blub! / Blub blub! | Efek buatan | [cari](https://freesound.org/search/?q=bubbles&f=license%3A%22Creative+Commons+0%22) |
| `lumba` | Lumba-lumba / Dolphin | Ekik ekik! / Click click! | Rekaman asli | [cari](https://freesound.org/search/?q=dolphin&f=license%3A%22Creative+Commons+0%22) |
| `paus` | Paus / Whale | Uuuuu! / Ooooo! | Rekaman asli | [cari](https://freesound.org/search/?q=whale+song&f=license%3A%22Creative+Commons+0%22) |
| `kepiting` | Kepiting / Crab | Kletek kletek! / Click clack! | Efek buatan | [cari](https://freesound.org/search/?q=claw+click&f=license%3A%22Creative+Commons+0%22) |
| `gurita` | Gurita / Octopus | Blup! / Bloop! | Efek buatan | [cari](https://freesound.org/search/?q=bloop&f=license%3A%22Creative+Commons+0%22) |
| `ubur` | Ubur-ubur / Jellyfish | Blup blup! / Bloop bloop! | Efek buatan | [cari](https://freesound.org/search/?q=bubble+pop&f=license%3A%22Creative+Commons+0%22) |
| `pinguin` | Pinguin / Penguin | Kwak! / Squawk! | Rekaman asli | [cari](https://freesound.org/search/?q=penguin&f=license%3A%22Creative+Commons+0%22) |

### Burung & Serangga

| id | Nama | Tiruan bunyi (ID / EN) | Jenis | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `burung` | Burung / Bird | Cuit cuit! / Tweet tweet! | Rekaman asli | [cari](https://freesound.org/search/?q=bird+chirp&f=license%3A%22Creative+Commons+0%22) |
| `burunghantu` | Burung Hantu / Owl | Uhu uhu! / Hoo hoo! | Rekaman asli | [cari](https://freesound.org/search/?q=owl+hoot&f=license%3A%22Creative+Commons+0%22) |
| `flamingo` | Flamingo / Flamingo | Honk honk! / Honk honk! | Rekaman asli | [cari](https://freesound.org/search/?q=flamingo&f=license%3A%22Creative+Commons+0%22) |
| `kupu` | Kupu-kupu / Butterfly | Wusss... / Flutter... | Efek buatan | [cari](https://freesound.org/search/?q=wings+flutter&f=license%3A%22Creative+Commons+0%22) |
| `lebah` | Lebah / Bee | Nguuung! / Buzz! | Rekaman asli | [cari](https://freesound.org/search/?q=bee+buzz&f=license%3A%22Creative+Commons+0%22) |
| `semut` | Semut / Ant | Tuk tuk tuk! / March march! | Efek buatan | [cari](https://freesound.org/search/?q=tiny+footsteps&f=license%3A%22Creative+Commons+0%22) |
| `ulat` | Ulat / Caterpillar | Nyam nyam! / Munch munch! | Efek buatan | [cari](https://freesound.org/search/?q=munch&f=license%3A%22Creative+Commons+0%22) |

Beberapa hewan liar mungkin sulit ditemukan dalam CC0, misalnya komodo, orangutan, zebra, badak, dan flamingo. Kalau belum ada yang cocok, coba kata kunci lain (misalnya "lizard" untuk komodo, "goose honk" untuk flamingo), atau buat efek sendiri yang cocok dengan tiruan bunyinya.

## Setelah semua terkumpul

Satu hewan dianggap selesai kalau file hasil proses `assets/audio/hewan/<id>.m4a` sudah ada dan barisnya di `assets/audio/LICENSES.csv` lengkap dengan lisensi `CC0` atau `Milik sendiri`. Validator konten (`dart run tool/validate_content.dart`) memeriksa keduanya untuk 42 hewan sebelum build rilis.
