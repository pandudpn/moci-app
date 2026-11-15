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

- Satu baris judul dengan bentuk `<jenis>(<area>): <ringkasan>`. Contoh: `feat(content): build narration list from catalog and ARB`.
- Jenis yang dipakai: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`, `ci`, `build`.
- Judul, isi commit, komentar kode, dan teks workflow CI ditulis dalam Bahasa Inggris, huruf kecil di awal judul, tanpa titik di akhir.
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

Aturan isi, format berkas, dan daftar aset dijelaskan di [`docs/CONTENT-ASSETS.md`](docs/CONTENT-ASSETS.md).

## 7. Audio

- Sumber suara hanya dua: Freesound dengan lisensi CC0, atau rekaman sendiri. Pixabay dan CC BY tidak dipakai.
- Setiap berkas dicatat satu baris di `assets/audio/LICENSES.csv`. Kolom `lisensi` hanya berisi `CC0` atau `Milik sendiri`.
- Validator menolak berkas audio yang tidak punya baris lisensi.
- Panduan memilih suara per hewan, termasuk link Freesound, ada di [`docs/audio/SUARA-HEWAN.md`](docs/audio/SUARA-HEWAN.md).

## 8. Rilis

Nomor versi tidak diketik di tiga tempat. `tool/rilis/naikkan_versi.dart` adalah satu-satunya yang menulisnya, di baris `version:` pada `pubspec.yaml`:

```bash
fvm dart run tool/rilis/naikkan_versi.dart show          # versi di berkas, misalnya 1.0.2+3
fvm dart run tool/rilis/naikkan_versi.dart bump patch     # tulis 1.0.2+3; nomor build selalu naik
fvm dart run tool/rilis/naikkan_versi.dart bump 2.0.0-rc.1
fvm dart run tool/rilis/naikkan_versi.dart check v1.0.2   # penjaga yang dijalankan workflow
```

Dua jalan merilis, keduanya menjalankan pemeriksaan yang sama di satu run:

```bash
# 1. tombol yang menghitung tag
gh workflow run Release -f bump=patch

# 2. atau tag sendiri setelah menaikkan versi
fvm dart run tool/rilis/naikkan_versi.dart bump patch
git commit -am "chore(release): v1.0.2"
git tag -a v1.0.2 -m "Moci 1.0.2" && git push origin v1.0.2
```

Isi halaman rilis juga tidak diketik tangan. `tool/rilis/catatan_rilis.dart` menyusuri jalur utama antara tag sebelumnya dan tag ini. Pull request yang digabung menjadi satu entri yang menaut pull request-nya, dengan commit di dalamnya dilipat; commit langsung di `main` menaut commit pendeknya. Setiap entri menyebut penulisnya lewat login GitHub kalau `gh` tersedia, dan lewat nama git tanpa `@` kalau tidak. Subjek dibaca sebagai conventional commit lalu dikelompokkan menjadi Breaking changes, Features, Fixes, Documentation, Build and CI, dan Other changes. Ada bagian Contributors, bagian Install yang tetap, dan tautan changelog penuh. Commit `chore(release)` dan `chore(rilis)`, revert-nya, serta commit bot tidak ikut. Tulis subjek commit yang layak dibaca, karena itulah isi halaman rilis:

```bash
fvm dart run tool/rilis/catatan_rilis.dart --to v1.0.2   # pratinjau sebelum menandai tag
```

`SUMMARY.md` boleh berisi judul dan ringkasan singkat rilis. Workflow menyalinnya sebelum bump, dan commit bump menghapusnya, jadi kata untuk satu rilis tidak terbawa ke rilis berikutnya.

Satu run workflow melakukan sisanya: menolak tag yang tidak cocok dengan `pubspec.yaml`, menjalankan cek format, analyze, validator isi, tes tanpa golden, dan golden di macOS, membangun AAB dan APK bertanda tangan serta IPA tanpa tanda tangan, lalu menerbitkan GitHub Release beserta ketiga berkas dan `SHA256SUMS`.

Versi dengan akhiran (`v2.0.0-rc.1`) diterbitkan sebagai prerelease. `gh workflow run Release -f bump=patch` membangun commit bump dan tag di dalam runner dan tidak push apa pun pada awalnya. Job lain menguji dan membangun commit itu dari artifact bundle. Hanya job publish yang push, setelah semua gerbang lulus, dengan satu `git push --atomic` untuk branch dan tag. Gerbang yang gagal meninggalkan `main` dan tag seperti semula, dan push tag oleh `GITHUB_TOKEN` tidak memicu run kedua.

Dispatch hanya jalan dari `main`, dan ditolak sebelum ada yang di-stage kalau `main` sudah bergerak sejak tombol ditekan atau `HEAD` sudah bertag rilis. Menekan tombol dua kali berarti merilis sekali. Merilis ulang tag yang sudah ada, misalnya saat release-nya belum sempat dibuat, adalah dispatch dengan `bump=none`.

## 9. Checklist PR

- [ ] `fvm flutter analyze` bersih.
- [ ] `fvm dart format --output=none --set-exit-if-changed lib test tool integration_test` bersih.
- [ ] `fvm dart run tool/validate_content.dart` tanpa galat.
- [ ] `fvm flutter test --exclude-tags golden` lulus.
- [ ] Golden diperbarui dan gambarnya diperiksa kalau tampilan berubah.
- [ ] Audio baru tercatat di `assets/audio/LICENSES.csv` dengan lisensi CC0 atau `Milik sendiri`.
- [ ] Tidak ada `android/key.properties`, `*.jks`, `*.keystore`, `*.p12`, atau `.env` yang ikut ter-commit.
- [ ] Perintah dan path baru yang disebut di dokumen sudah dijalankan atau dicek.
