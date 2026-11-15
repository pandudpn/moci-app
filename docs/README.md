> Salinan dari Claude Docs "Dokumentasi Moci", tab Ringkasan, per 2026-11-14. Sumber kebenaran: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Dokumentasi Moci

14 November 2026 · Pandu

## Ringkasan

Moci adalah aplikasi belajar dan bermain untuk anak usia 2–7 tahun: tanpa iklan, bisa offline, dalam Bahasa Indonesia dan English, untuk iPad, iPhone, serta HP dan tablet Android. Desain dan prototipe interaktif semua menu versi tablet sudah selesai. Versi HP baru ada untuk Beranda, dan kode Flutter belum dimulai.

### Isi dokumentasi

Setiap dokumen berdiri sendiri. Sumber aslinya ada di Claude Docs "Dokumentasi Moci"; kalau dokumen itu diubah, export ulang tab yang berubah ke file di bawah.

| Tab | Isi | Nama file di repo |
| --- | --- | --- |
| [PRD](PRD.md) | Apa yang dibangun untuk v1: pengguna, prinsip, alur, fitur per menu, kriteria selesai | `docs/PRD.md` |
| [Spesifikasi Teknis](TECH-SPEC.md) | Cara membangunnya dengan Flutter: arsitektur, data, audio, performa, pengujian | `docs/TECH-SPEC.md` |
| [Sistem Desain](DESIGN-SYSTEM.md) | Warna, huruf, ukuran sentuh, komponen, animasi, dan suara | `docs/DESIGN-SYSTEM.md` |
| [Konten & Aset](CONTENT-ASSETS.md) | Ilustrasi, katalog isi, narasi, suara, aset brand, cara menambah isi | `docs/CONTENT-ASSETS.md` |
| [Privasi & Rilis](PRIVACY-RELEASE.md) | Kebijakan privasi, syarat App Store dan Google Play, checklist rilis | `docs/PRIVACY-RELEASE.md` |

### Keputusan dan rekomendasi

Kolom Status bisa diubah langsung. Kalau sebuah rekomendasi disetujui, ganti statusnya jadi Diputuskan.

| Hal | Pilihan | Status |
| --- | --- | --- |
| Platform | iPad, iPhone, HP Android, tablet Android | Diputuskan |
| Usia | 2–7 tahun, dalam 3 level: 2–3, 4–5, 6–7 | Diputuskan |
| Bahasa | Bahasa Indonesia dan English, bisa diganti kapan saja | Rekomendasi |
| Iklan | Tidak ada | Diputuskan |
| Pembelian dalam aplikasi | Tidak ada | Rekomendasi |
| Data anak | Hanya di perangkat, tanpa akun, server, atau analytics | Rekomendasi |
| Ikon aplikasi | A. Wajah Moci | Diputuskan |
| Warna latar ikon | Biru langit | Rekomendasi |
| Logo | Bertumpuk atau mendatar, sesuai ruang yang tersedia | Diputuskan |
| Splash screen | Versi terang | Diputuskan |
| Teknologi | Flutter, satu kode untuk iOS dan Android | Rekomendasi |
| Nama repo | moci-app | Rekomendasi |

Keputusan tambahan per 14 November 2026: Ucapkan v1 memakai mikrofon dengan pengenalan ucapan di perangkat, dan semua layar dikunci di orientasi landscape.

### Pertanyaan terbuka

- [ ] Lisensi repo: apakah kode dan aset gambar boleh dipakai orang lain.
- [ ] Harga di store: gratis atau berbayar sekali beli.
- [ ] Akun developer Apple dan Google: atas nama pribadi atau badan usaha.
- [ ] Siapa yang merekam narasi Bahasa Indonesia dan English.
- [ ] Sumber suara hewan asli.
- [ ] Ketersediaan nama "Moci" di App Store, Play Store, dan pangkalan data merek DJKI.
- [ ] Email dukungan dan alamat web untuk kebijakan privasi.
- [ ] Rentang usia di kategori Kids App Store: 5 tahun ke bawah atau 6–8.
- [ ] Penilaian mandiri PP Tunas: perlu diajukan atau tidak (batas Komdigi 31 Desember 2026).

## Peta dokumentasi

| Dokumen | Isi |
| --- | --- |
| [PRD.md](PRD.md) | Tujuan v1, menu, alur aplikasi, prinsip produk |
| [TECH-SPEC.md](TECH-SPEC.md) | Teknologi, arsitektur, penyimpanan, audio, pengujian |
| [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) | Warna, huruf, ukuran, gerak, komponen |
| [CONTENT-ASSETS.md](CONTENT-ASSETS.md) | Ilustrasi, katalog JSON, narasi, suara, cara menambah isi |
| [PRIVACY-RELEASE.md](PRIVACY-RELEASE.md) | Privasi, izin, kategori anak di toko aplikasi, alur rilis |
| [design/](design/) | Snapshot prototipe interaktif |
| [audio/SUARA-HEWAN.md](audio/SUARA-HEWAN.md) | Panduan sumber dan lisensi suara hewan |
