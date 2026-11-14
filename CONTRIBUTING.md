# Kontribusi

Panduan untuk mengerjakan repo Moci. Aturan yang sama untuk manusia dan agen otomatis ada di [`AGENTS.md`](AGENTS.md).

## 1. Persiapan

- Semua perintah Flutter memakai FVM. Versi Flutter dikunci di `.fvmrc`, yaitu 3.50.0, jadi tulis `fvm flutter …` dan `fvm dart …`.
- Xcode 26 atau lebih baru untuk build iOS dan golden.
- Android SDK 36. `compileSdk`, `targetSdk`, dan `minSdk` ada di `android/app/build.gradle.kts`.
- Python 3, hanya kalau membangun ulang font dengan `tool/fonts/build_fonts.sh`. Skrip itu membuat venv dan memasang `fonttools`.

```bash
fvm install
fvm flutter pub get
```

## 2. Alur kerja

1. Buat branch fitur dari `main`, misalnya `feat/menu-huruf`.
2. Kerjakan satu topik per branch. Jangan commit ke `main`.
3. Jalankan pemeriksaan lokal di bagian 4 sebelum push.
4. Buka pull request ke `main`.
5. PR digabung setelah CI hijau. `.github/workflows/ci.yml` menjalankan analyze, cek format, validator konten, dan tes tanpa golden di Linux, lalu golden di macOS.

## 3. Gaya commit

- Satu baris judul dengan bentuk `<jenis>(<area>): <ringkasan>`. Contoh: `feat(konten): daftar narasi dari katalog dan ARB`.
- Jenis yang dipakai: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`.
- Ringkasan dalam Bahasa Indonesia, huruf kecil di awal, tanpa titik di akhir.
- Satu commit berisi satu perubahan yang bisa dijelaskan sendiri.

## 4. TDD dan tes

Tulis tes yang gagal dulu, lalu kode sampai tes lulus. Perintah yang wajib berhasil:

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm dart run tool/validate_content.dart
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
```

- `--exclude-tags golden` adalah tes yang jalan di semua mesin. Ini yang dipakai CI di Linux.
- `--tags golden` memakai berkas `*_golden_test.dart`. Jalankan di macOS.
- Integration test butuh perangkat atau simulator yang menyala: `fvm flutter test integration_test -d <perangkat>`. Id perangkat dilihat dengan `fvm flutter devices`.
- Fake dan helper tes ada di `test/helpers/`. `testWidgets` tidak boleh menyentuh berkas atau jaringan sungguhan.

## 5. Memperbarui golden

Golden hanya untuk Beranda, Hebat, dan Area Orang Tua, di `test/features/beranda/goldens/`, `test/features/hadiah/goldens/`, dan `test/features/orang_tua/goldens/`. Render teks berbeda di Linux dan macOS, jadi golden diperbarui di macOS.

```bash
fvm flutter test --tags golden --update-goldens
```

Setelah diperbarui, buka PNG yang berubah dan periksa diff-nya. Pastikan perubahannya memang yang diminta, bukan pergeseran tata letak yang tidak disengaja.

## 6. Mengubah atau menambah isi

Katalog JSON di `assets/content/` adalah sumber kebenaran. `docs/design/prototype/` adalah snapshot beku, jadi jangan mengeditnya.

1. Sunting `assets/content/katalog.json`, `assets/tracing/`, atau `assets/coloring/`.
2. Tambah ilustrasi di `assets/illustrations/` kalau perlu.
3. Jalankan `fvm dart run tool/validate_content.dart`. Semua galat harus nol.
4. Untuk naskah narasi, jalankan `fvm dart run tool/validate_content.dart --naskah=build/naskah.csv`.
5. Sebelum rilis, tambahkan `--rilis`. Mode ini gagal kalau narasi atau suara hewan belum lengkap.

Aturan isi, format berkas, dan daftar aset dijelaskan di `docs/CONTENT-ASSETS.md`.

## 7. Audio

- Sumber suara hanya dua: Freesound dengan lisensi CC0, atau rekaman sendiri. Pixabay dan CC BY tidak dipakai.
- Setiap berkas dicatat satu baris di `assets/audio/LICENSES.csv`. Kolom `lisensi` hanya berisi `CC0` atau `Milik sendiri`.
- Validator menolak berkas audio yang tidak punya baris lisensi.
- Panduan memilih suara per hewan, termasuk link Freesound, ada di [`docs/audio/SUARA-HEWAN.md`](docs/audio/SUARA-HEWAN.md).

## 8. Checklist PR

- [ ] `fvm flutter analyze` bersih.
- [ ] `fvm dart format --output=none --set-exit-if-changed lib test tool integration_test` bersih.
- [ ] `fvm dart run tool/validate_content.dart` tanpa galat.
- [ ] `fvm flutter test --exclude-tags golden` lulus.
- [ ] Golden diperbarui dan gambarnya diperiksa kalau tampilan berubah.
- [ ] Audio baru tercatat di `assets/audio/LICENSES.csv` dengan lisensi CC0 atau `Milik sendiri`.
- [ ] Tidak ada `android/key.properties`, `*.jks`, `*.keystore`, `*.p12`, atau `.env` yang ikut ter-commit.
- [ ] Perintah dan path baru yang disebut di dokumen sudah dijalankan atau dicek.
