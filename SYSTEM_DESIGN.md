# Sistem berjalan Moci

Dokumen ini menjelaskan perilaku sistem saat aplikasi berjalan: batas privasi, data yang tersimpan, pengatur waktu, audio, mikrofon, pipeline konten, konfigurasi platform, anggaran, dan rilis. Rencana teknis lengkap ada di [TECH-SPEC](docs/TECH-SPEC.md), kewajiban store ada di [PRIVACY-RELEASE](docs/PRIVACY-RELEASE.md), dan aturan isi ada di [CONTENT-ASSETS](docs/CONTENT-ASSETS.md).

## 1. Batas privasi dan offline

- Tidak ada server, akun, iklan, analytics, atau crash reporting. Tidak ada satu pun paket yang mengirim data.
- Manifest rilis Android hanya meminta `RECORD_AUDIO` untuk Ucapkan, dan tidak meminta INTERNET. Semua isi ikut di bundel: katalog, tracing, halaman mewarnai, ilustrasi, dan nanti audio.
- Data anak hanya di folder aplikasi. `android:allowBackup="false"` mematikan cadangan Android, dan folder `<application support>/moci` ditandai `isExcludedFromBackup` di iOS lewat kanal `moci/backup`. Karena itu, data tidak pindah saat ganti perangkat.
- Debug dan profile tetap memakai INTERNET untuk hot reload, jadi izin itu hanya ada di manifest debug dan profile.
- Satu-satunya izin adalah mikrofon untuk Ucapkan, ditambahkan di Rencana 03 bersama dua alasan izin di iOS. Rinciannya di bagian 5.

## 2. Data yang tersimpan

| Data | Tempat | Isi |
| --- | --- | --- |
| Pengaturan | `shared_preferences` | Sembilan kunci di bawah |
| Kemajuan | `progress.json` | Bintang, stiker, kegiatan terakhir, waktu bermain, perkembangan, ringkasan harian |
| Karya | `karya/<id>.json`, maksimal 12 berkas | Isi halaman, waktu simpan, dan `gambar` (PNG 300 × 225 base64) |
| Draf mewarnai | `draf/<halaman>.json`, satu per halaman | Isi halaman, tanpa PNG |

Kunci pengaturan, semuanya berawalan `moci.`:

| Kunci | Nilai |
| --- | --- |
| `moci.bahasa` | `id` atau `en`; bawaan mengikuti bahasa perangkat |
| `moci.nama` | Nama panggilan, maksimal 20 karakter setelah dirapikan |
| `moci.usia` | `2-3`, `4-5`, atau `6-7` |
| `moci.caraBaca` | `fonik` atau `nama` |
| `moci.batasMenit` | `15`, `30`, `45`, atau `0` untuk tanpa batas; bawaan 30 |
| `moci.musik` | `true` atau `false` |
| `moci.efek` | `true` atau `false` |
| `moci.istirahat` | `true` atau `false` |
| `moci.sambutanSelesai` | `true` setelah Sambutan selesai |

Nilai yang tidak dikenal jatuh ke bawaan: bahasa dari perangkat, usia `pemula`, cara baca `fonik`, batas 30 menit, dan sakelar menyala.

Bentuk `progress.json`:

```json
{
  "versi": 1,
  "bintang": 27,
  "stiker": ["apel", "moci-senang"],
  "kegiatanTerakhir": { "rute": "/huruf/tulis", "param": { "huruf": "A" } },
  "waktuBermain": { "2026-11-14": 1260 },
  "perkembangan": { "huruf": { "dilihat": ["A", "B"], "ditulis": ["A"] } },
  "harian": {
    "2026-11-14": {
      "bintang": 3,
      "stiker": 1,
      "karya": 0,
      "item": { "huruf": ["A"] }
    }
  }
}
```

Aturan penyimpanan:

- Setiap berkas punya `versi`. `Progress.versi` sekarang 1, dan pembacaan bersifat toleran: field yang hilang atau salah tipe memakai nilai kosong, bukan melempar.
- Penulisan atomik: `FileJsonStore.write` menulis `<berkas>.tmp` dengan flush, lalu mengganti nama.
- Berkas yang tidak bisa dibaca dipindah ke `<berkas>.rusak-<milidetik>` dan dianggap kosong. `list` melewati `.tmp` dan `.rusak-`.
- `waktuBermain` dan `harian` disimpan untuk 7 hari terakhir. Pemangkasan terjadi setiap kali progres berubah.
- `perkembangan` tidak dipangkas; ini data jangka panjang yang dipakai ringkasan Area Orang Tua.
- `karya/` dan `draf/` dibaca dan ditulis `KaryaRepository` lewat `JsonStore`, lalu dibagikan ke layar sebagai `karyaProvider`. Batasnya 12 karya (yang tertua dipangkas), satu draf per halaman, dan 200 KB per berkas. PNG pratinjau ikut di dalam JSON karya, bukan berkas terpisah, supaya satu karya tetap satu berkas atomik.
- Simpan menulis karya lebih dulu, baru mencatat progres (`recordKarya`, `markItem('mewarnai', 'diwarnai', halaman)`). Draf tidak dihapus saat Simpan, dan menghapus karya tidak menghapus draf.
- Hapus semua data di Area Orang Tua menjalankan `jsonStore.deleteAll`, `progress.reset`, dan `prefs.resetAll`, membuang pengatur waktu dari memori, mencabut akses orang tua, lalu membuka Sambutan lagi.

### Fitur mewarnai (Rencana 07)

| Berkas | Isi |
| --- | --- |
| `lib/features/mewarnai/galeri_screen.dart` | 14 halaman, saring jenis gambar, lencana Lanjutkan, kartu Karyaku |
| `lib/features/mewarnai/kanvas_screen.dart` | alat, 16 krayon, 8 stiker, batal, draf otomatis, Simpan, pemilih gambar |
| `lib/features/mewarnai/karyaku_screen.dart` | 12 karya, detail, hapus dua langkah, warnai lagi |
| `lib/features/mewarnai/mewarnai_engine.dart` | isi, kuas, hapus, stiker, dan riwayat batal 30 langkah |
| `lib/features/mewarnai/mewarnai_painter.dart` | painter halaman yang sama untuk layar dan ekspor PNG |
| `lib/features/mewarnai/karya_repository.dart` | baca dan tulis `draf/` serta `karya/` lewat `JsonStore` |

Rute `/mewarnai`, `/mewarnai/:halaman`, dan `/karyaku` sudah memakai layar asli, bukan `ComingSoonScreen`.

## 3. Pengatur waktu bermain

- Satu detak per detik dari `playTimerTicksProvider`. Tes menggantinya dengan aliran manual.
- Waktu dihitung hanya saat aplikasi di depan (`AppLifecycleState.resumed`) dan rute saat ini rute bermain (D14). Splash, Sambutan, Gerbang, Area Orang Tua, Istirahat, dan Waktu Habis tidak dihitung.
- Selisih antar detak dijepit ke 0 sampai 2 detik, lalu dibulatkan. Jam yang mundur, jam yang loncat, atau aplikasi yang ditangguhkan tanpa event pause tidak merusak hitungan.
- Ganti tanggal tengah malam memuat detik tersimpan untuk tanggal baru dan mengulang hitungan sejak istirahat terakhir.
- Detik disimpan ke `progress.json` setiap 30 detik terhitung, saat aplikasi ke latar, dan saat hari berganti. Istirahat selesai memakai `restTaken`, yang mengulang hitungan 20 menit.
- Pengingat istirahat: `restDue` setelah 1.200 detik bermain sejak istirahat terakhir. `MociApp` membuka `/istirahat` sekali per `restDue` kalau rute sedang rute bermain dan batas belum tercapai. Setelah 20 detik, layar ditutup dan anak kembali ke layar tadi. Waktu Habis menang atas Istirahat.
- Batas harian: `limitReached` saat detik hari ini mencapai batas dalam menit. `limitReachedProvider` menyegarkan router, jadi rute bermain dialihkan ke `/habis`. Menaikkan batas di Area Orang Tua langsung membuka blokir, tetapi Area Orang Tua tidak ikut tertutup karena router tidak disegarkan selama akses orang tua terbuka.

## 4. Audio

Alur satu suara:

1. `AssetCatalog` memuat daftar aset dari manifest bundel. Pemutaran apa pun dicek dulu ke katalog ini, jadi aset yang belum ada tidak menjadi galat.
2. `AudioService` mengatur prioritas: narasi di atas efek, efek di atas musik. Volume narasi 1,0; efek 0,7; musik 0,25; musik turun ke 0,10 selama narasi berbunyi.
3. `SoLoudAudioEngine` memuat aset sekali per path, memutar lewat `flutter_soloud`, dan memberi kabar selesai dari `AudioSource.soundEvents` saat `handleIsNoMoreValid`.
4. `Narrator` menyusun path `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a`. Kalau rekaman belum ada, teks dibacakan `DeviceTts` di semua mode build.

Aturan yang sudah berlaku di kode:

- Satu narasi pada satu waktu. `Narrator.say` dan `sayAll` memakai nomor generasi, jadi narasi baru membatalkan yang lama, termasuk narasi yang masih dimuat.
- `stopAll` dan `narrator.stop` dipanggil saat aplikasi disembunyikan atau dijeda. Saat kembali, sesi audio iOS diaktifkan lagi dan musik dinyalakan ulang kalau sakelarnya menyala.
- Efek memakai enum `Sfx`: `klik`, `benar`, `salahLembut`, `sorak`, `bintang`, dengan path `assets/audio/sfx/<nama>.wav`.
- Musik latar memakai `AudioService.musicAsset`: berkas OGG di `assets/audio/`, diputar berulang. Berkasnya belum ada, jadi pemutaran musik saat ini tidak menghasilkan suara.
- Sesi iOS memakai kategori playback lewat kanal `moci/audio_session`, supaya suara tetap terdengar saat sakelar senyap menyala. Pelaksana native-nya ada di `ios/Runner/MociChannels.swift`.
- TTS perangkat dipakai di semua mode build. Ia memakai kanal `moci/tts`, dan manifest utama menambahkan blok `<queries>` untuk `TTS_SERVICE` (Android 11+).

## 5. Mikrofon (Rencana 03)

Mesin pengenal dan izinnya sudah terpasang di `lib/core/speech/`; layar Ucapkan menyusul. Aturan yang berlaku:

- `speech_to_text` dipakai dengan `onDevice: true` dan `contextualPhrases` berisi kata target. Tidak ada mode yang boleh memakai layanan jaringan.
- Gerbang Orang Tua muncul sebelum dialog izin sistem. Kalau izin ditolak, Ucapkan berjalan dalam mode dengar dan tiru tanpa mikrofon.
- Android hanya meminta `RECORD_AUDIO` dan blok `<queries>` untuk `android.speech.RecognitionService`. INTERNET dan Bluetooth tidak ditambahkan, dan Ucapkan diuji di mode pesawat.
- iOS menambah `NSMicrophoneUsageDescription` dan `NSSpeechRecognitionUsageDescription` dengan teks untuk orang tua.
- Suara tidak direkam ke berkas dan tidak dikirim. Setelah izin atau manifest berubah, `docs/PRIVACY-RELEASE.md` wajib diperbarui.

## 6. Pipeline konten dan validator

| Tahap | Berkas | Cara kerja |
| --- | --- | --- |
| Ekspor sekali | `tool/konten/ekspor_prototipe.dart` | Membaca snapshot `docs/design/prototype/`, menulis `assets/content/`, `assets/tracing/`, `assets/coloring/`, dan `assets/illustrations/` |
| Parser | `tool/konten/js_literal.dart` | Membaca literal JavaScript prototipe: kutip tunggal, kunci tanpa kutip, koma akhir |
| Validasi | `tool/konten/validasi/` | Aturan terpisah per bagian: struktur, SVG, tracing, mewarnai, narasi, audio |
| Pintu masuk | `tool/validate_content.dart` | Menjalankan semua aturan, mencetak ringkasan, keluar dengan kode 1 kalau ada galat |

Aturan yang ditegakkan:

- `json_valid`: keenam berkas JSON bisa dibaca dan bentuknya sesuai.
- `id_unik`, `referensi_gambar_ada`, `referensi_warna_ada`, `nama_dua_bahasa`, `kata_utuh`: katalog konsisten dan setiap rujukan punya sasaran.
- `svg_aturan`, `svg_tanpa_pemakai`, `anggaran_ilustrasi`: SVG sesuai aturan (viewBox 200 × 200, tanpa style, gradien, image, teks, filter, mask), tidak ada berkas yatim, total di bawah 4 MB.
- `tracing_lengkap`, `tracing_perintah_didukung`: huruf dan angka punya jalur, dan hanya memakai perintah `M L H V C`.
- `mewarnai_tertutup`, `mewarnai_contoh`: setiap bagian gambar tertutup, dan warna contoh dilaporkan sebagai peringatan selama belum lengkap.
- `narasi_lengkap`: baris narasi yang diharapkan dibandingkan dengan rekaman. Mode pengembangan memberi peringatan, `--rilis` memberi galat.
- `lisensi_audio_lengkap`: setiap berkas audio punya baris di `assets/audio/LICENSES.csv` dengan lisensi `CC0` atau `Milik sendiri`. Nilai lain selalu galat, juga di mode pengembangan.
- `suara_hewan_lengkap`, `anggaran_audio`: suara hewan dan total audio diperiksa; `--rilis` menuntut kelengkapan.

`--naskah=build/naskah.csv` menulis CSV berisi kolom `file`, `bahasa`, `teks`, dan `catatan` untuk semua baris yang belum direkam. Hanya bentuk `--naskah=<path>` yang dibaca.

## 7. Konfigurasi platform

| Hal | Nilai di repo |
| --- | --- |
| Orientation | Landscape kiri dan kanan. `SystemChrome.setPreferredOrientations` di `lib/main.dart`, `UISupportedInterfaceOrientations` dan `UISupportedInterfaceOrientations~ipad` hanya landscape, `UIRequiresFullScreen` = true, `android:screenOrientation="sensorLandscape"` |
| Resizable Android 16 | `<property android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY" android:value="true"/>` di `<application>` |
| Nama aplikasi | `Moci` di `android:label` dan `CFBundleDisplayName` |
| Bundle id | `id.pandudpn.moci` di iOS dan `applicationId` Android (D3) |
| Versi OS | iOS 15.0, Android minimal API 24, target dan compile API 36 |
| Versi aplikasi | `1.0.0+1` dari `pubspec.yaml` |
| Bahasa | `CFBundleLocalizations` berisi `id` dan `en`; Android mengambil locale perangkat lewat plugin Flutter, lalu teks dari ARB |
| Cadangan | `android:allowBackup="false"` dan `isExcludedFromBackup` untuk folder data iOS |
| Izin rilis | Tidak ada. `aapt2 dump permissions` menunjukkan satu izin yang disuntikkan androidx.core, `id.pandudpn.moci.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, dan izin itu milik aplikasi sendiri (protectionLevel `signature`), bukan izin sistem |
| Signing | Belum ada. `android/app/build.gradle.kts` masih memakai kunci debug, dan `android/key.properties` beserta berkas kunci ditolak `.gitignore` |

Kalau sistem mengabaikan kunci orientasi, panggung tetap aman karena isi selalu diskalakan ke area aman oleh `fitStage`.

## 8. Anggaran performa dan ukuran

| Hal | Target | Cara memeriksa |
| --- | --- | --- |
| Unduhan | Di bawah 30 MB | Ukuran bundel rilis di Rencana 10 |
| Ilustrasi | Di bawah 4 MB | `anggaran_ilustrasi` di validator |
| Audio | Di bawah 12 MB | `anggaran_audio` di validator |
| Font | Di bawah 1 MB untuk delapan berkas | `test/app/theme/font_budget_test.dart` |
| Kecepatan | 60 fps, ketukan dijawab di bawah 100 ms | Uji perangkat |
| Buka aplikasi | Splash bergerak di bawah 1,5 detik | Uji perangkat |
| Memori | Di bawah 200 MB | Uji perangkat |
| Kontras | Teks minimal 4,5 : 1 | `test/app/theme/contrast_test.dart` |

Ukuran sekarang: ilustrasi 452 KB, font 320 KB, dan belum ada berkas audio.

## 9. CI dan rilis

`.github/workflows/ci.yml` menjalankan dua job:

- `test` di Ubuntu: cek versi Flutter 3.50 di `.fvmrc`, `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `dart run tool/validate_content.dart`, lalu `flutter test --exclude-tags golden`.
- `golden` di macOS: `flutter pub get` dan `flutter test --tags golden`.

Belum ada workflow tag rilis. Rencana 10 menambahkan build TestFlight dan Play internal testing, signing, kebijakan privasi publik, serta pengisian `AppConfig.privacyPolicyUrl` dan `AppConfig.supportEmail`. Selama keduanya `null`, tautan terkait tidak tampil di Area Orang Tua.
