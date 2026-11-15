> Copy of the Claude Docs "Moci Documentation", Content & Assets tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci Content & Assets

Moci's content is made of SVG illustrations, a JSON catalog, narration, and sound, and it all ships inside the app. This section covers how to make, name, and add that content.

## Images per theme

![Number of pictures per theme in the prototype catalog, November 2026](images/gambar-per-tema.png)

A Memory Cards (Kartu Memori) game at level 8 pairs takes 8 pictures from one theme. With only 9 vehicles, a Vehicles themed game almost always uses the same pictures. Adding a few vehicles, for example a motorcycle, an ambulance, and a tractor, keeps that theme from feeling repetitive.

## SVG illustration rules

There are currently 116 illustration SVG files with a total of only 147 KB, or 1.3 KB per file on average. The rules below keep new pictures just as small and consistent.

### Object, animal, fruit, vegetable, and vehicle pictures

- Canvas `viewBox="0 0 200 200"`, with the picture centered and a little empty space at the edges.
- Flat style with simple shapes. At most 12 fill colors per picture (currently a median of 5).
- Outline strokes of 3–7 units, in ink `#2B2350` or a darker version of its fill color.
- `opacity` may be used for highlights and soft shadows.
- `<style>` or CSS, gradients, raster images (`<image>`), text (`<text>`), filters, and masks are not allowed. Every color is written as an attribute, for example `fill="#FFD43B"`, because CSS support in flutter\_svg is limited.
- One file holds one object, with no background. The screen provides the background.
- Pictures must stay clear at around 64 pt, the smallest size in the games.
- The file name matches the content id: lowercase with no spaces, for example `buahnaga.svg` or `burunghantu.svg`.
- Every illustration is drawn specifically for Moci, not taken from the internet, so the copyright is clear.

### Coloring pages

- Canvas 800 × 600. Every colorable region is one closed path.
- Detail lines such as eyes and patterns are stored separately, then drawn on top of all the colors.
- The smallest region should be at least 24 units wide, so a child's finger can still touch it.
- Every new page has sample colors for the Gallery (Galeri) thumbnail. Currently 44 pages use a total of 203 KB of data; ten early prototype pages have no sample colors yet.
- A new page is written in `tool/konten/halaman_mewarnai/` (base shapes in `bentuk.dart`, per category in `kota.dart`, `laut.dart`, `hewan.dart`, `buah.dart`, `benda.dart`). Run `fvm dart run tool/konten/halaman_mewarnai/buat_halaman.dart` to add it to `pages.json`.

## Content catalog format

All content that can be added without changing code lives in the `assets/content`, `assets/tracing`, and `assets/coloring` folders. One catalog entry represents one object, and each screen filters entries to fit its needs.

Example of one entry in `katalog.json`:

```json
{
  "id": "kucing",
  "kategori": "hewan",
  "nama": { "id": "Kucing", "en": "Cat" },
  "gambar": "illustrations/kucing.svg",
  "warna": "oranye",
  "hewan": {
    "kelompok": "rumah",
    "bunyi": { "id": "Meong!", "en": "Meow!" },
    "fakta": { "id": "Kucing suka tidur dan bermain.", "en": "Cats love to nap and play." }
  },
  "sukuKata": { "id": ["ku", "cing"], "en": null }
}
```

The other catalog sections:

| Section | Contents of each entry | Current count |
| --- | --- | --- |
| `huruf` | Letter, sample word in two languages, picture id | 26 |
| `angka` | Number and object id to count | 50 numbers, 12 counting objects |
| `warna` | Color id, name in two languages, hex | 11 colors, 81 objects tagged with a color |
| `bentuk` | Name in two languages, side count, corner count | 10 |
| `sukuKata` | Syllable and sample word | 90 syllables, samples for 41 |
| `kata` | Word, syllable split, picture id | 71 Indonesian, 33 English |
| `kalimat` | Sentence in two languages and picture id | 18 |
| `tracing/*.json` | List of strokes as SVG paths in a 520 × 520 box | 26 letters, 10 numbers |
| `coloring/pages.json` | Regions, detail lines, sample colors, category | 44 pages (862 regions) |

All of this starting data (names, animal groups, facts, words, sentences, stroke paths, and coloring pages) already exists in the prototype. So the v1 catalog only needs to be exported into the format above.

## Narration

Everything Moci says is recorded with a human voice, not read by TTS, so pronunciation in both languages is clear and consistent. The early estimate is about 1,200 short clips: roughly 650 Indonesian and 550 English.

### Script

- The script is generated automatically from the catalog as a single CSV file holding the file name, language, text, and pronunciation notes.
- Letter sounds (phonics) are spoken short with no extra vowel, for example /b/ rather than "be". Letter names are recorded separately.
- Sentences need a start time for every word for the karaoke effect. The times are stored in the catalog as a list of seconds, for example `[0.0, 0.42, 0.95]`.

### Recording

- One voice actor per language for the whole app, with a slow, clear, warm pace.
- Record in a quiet room with the same microphone for every session.
- If the voice actor is not you, prepare a voice usage agreement for an app released to the public.

### File format

| Item | Value |
| --- | --- |
| Master recording | WAV 48 kHz, 24-bit, mono. Stored outside the app repo. |
| File in the app | AAC-LC (.m4a) mono, 32 kbps, 24 kHz |
| Loudness | Average −16 LUFS, peaks at most −1 dBTP |
| Silence | At most 50 ms at the start and 150 ms at the end |
| Length | Words at most 1.5 seconds, sentences at most 5 seconds |
| File name | `vo/<bahasa>/<jenis>_<id>.m4a`, for example `vo/id/nama_kucing.m4a` or `vo/en/fakta_kucing.m4a` |

With this format, 1,200 clips averaging 1.5 seconds take about 7 MB, still under the 12 MB audio budget.

## Animal sounds and sound effects

Real animal sounds are not there yet. The prototype still uses spoken imitations, such as "Meong!". For v1, the 42 animal sounds come from sources with a clear license, and the origin of every file is recorded.

### Source order

1. **Own recordings.** Safest for animals you can easily meet, such as cats, chickens, ducks, goats, and cows.
2. **CC0 license (public domain).** For example from Freesound with the Creative Commons 0 license filter.
3. **Pixabay.** Free to use without attribution, but the files may not be redistributed as standalone files ([license summary](https://pixabay.com/service/license-summary/)). Make sure the uploader really owns the recording.

Avoid non-commercial (NC) licenses, "education only" licenses, and sound clips from videos or films.

About 12 animals have no distinctive sound, for example butterflies, ants, fish, and jellyfish. For animals like these, make your own funny effect that matches the imitation in the catalog.

### Format

- Animal sounds: AAC (.m4a) mono, at most 3 seconds, loudness matched to the narration, in `audio/hewan/<id>.m4a`.
- Sound effects (click, correct chime, cheer, balloon pop, card flip): about 15 short WAV files, made in house or CC0.
- Instruments: 8 xylophone notes and 4 drum sounds. They can be recorded from real instruments, or made with a synthesizer and saved as WAV.
- Background music: one short instrumental track that can loop, own composition or CC0.
- The two songs in Music Play (Main Musik), Twinkle Twinkle and Mary Had a Little Lamb, are traditional melodies that are already public domain.

### License notes

Every audio file from outside is recorded in `assets/audio/LICENSES.csv`, with the columns `file,sumber,URL,lisensi,tanggal unduh,catatan` (file, source, URL, license, download date, notes). Prefer CC0. If you have to use a license that asks for attribution (CC BY), show the credit in the Parents' Area (Area Orang Tua).

## Brand assets

All final brand assets live in `docs/brand` in PNG and SVG. The icon uses option A (Moci's Face), the splash uses the light version, and the logo is used stacked or horizontal depending on the space.

| Asset | When to use | File in `docs/brand` |
| --- | --- | --- |
| iOS icon | App icon on iPhone and iPad, including dark mode and tinted mode | `icon/ios/moci-icon-1024.png`, `-dark-1024`, `-tinted-1024` |
| Android adaptive icon | Front and back layers of the icon. The monochrome layer for themed icons on Android 13 and above. | `icon/android/ic_launcher_foreground-1024.png`, `_background-1024`, `_monochrome-1024` |
| Play Store icon | Listing on Google Play | `icon/android/play-store-512.png` |
| Stacked logo | Square or tall space: splash, posters, promo cards | `logo/moci-logo-stacked-color.png` |
| Horizontal logo | Wide and short space: website header, banners, letterhead | `logo/moci-logo-horizontal-color.png` |
| Moci wordmark only | When the mascot is already visible nearby, or at small sizes | `logo/moci-wordmark-color.png` |
| Mascot only | Stickers, avatars, small icons inside the app | `logo/moci-mascot-color.png` |
| Older iOS and Android splash | Logo in the middle of the built-in splash | `splash/splash-logo.png` (685 × 900) |
| Android 12 and later splash | Icon for the SplashScreen API | `splash/splash-icon-android12.png` (1152 × 1152) |
| GitHub | Repo social preview, light and dark README banners, avatar | `github/social-preview.png`, `banner-light.png`, `banner-dark.png`, `avatar.png` |

### Color variants

- **Color:** the primary choice on light backgrounds.
- **Flat:** without shadows, for small sizes and print.
- **Dark background:** for dark purple or black backgrounds.
- **Black and white:** for single color print, stamps, and watermarks.

### Usage rules

- Leave empty space around the logo, at least as tall as the "o" in the logo.
- Do not change the colors of the M-o-c-i letters, rotate the logo, add new gradients or shadows, or place the logo on a busy photo.
- The letters in the logo are already converted into vector shapes (outlines), so the SVG file still looks the same even when the Fredoka font is not installed.

## How to add new content

Adding a new object, animal, or word needs no code change. Just assets and one catalog entry, and the object automatically appears in every game that uses its category, such as Picture Match (Cocokkan Gambar), Memory Cards, Guess the Shadow (Tebak Bayangan), and Puzzle.

Example of adding one animal:

1. Draw the illustration following the SVG rules, then save it as `assets/illustrations/<id>.svg`.
2. Add an entry in `katalog.json`: the name in two languages, the category, the color (if it is clearly one color), the group, the imitation sound, and a fact.
3. Run `dart run tool/validate_content.dart --naskah` to produce the list of narration that has not been recorded.
4. Record the narration in both languages following the format, then save it in `assets/audio/vo/id` and `assets/audio/vo/en`.
5. Add the real sound at `assets/audio/hewan/<id>.m4a`, and record its origin and license in `LICENSES.csv`.
6. Run validation again until it is clean, then check how it looks on tablet and phone.
7. Open a pull request. CI runs the same validation before the change is merged.

A new coloring page is written as a shape in `tool/konten/halaman_mewarnai/`, then `buat_halaman.dart` adds it to `pages.json`: one closed path for every colorable region, separate detail lines, and sample colors for the thumbnail. Letter and number stroke paths are already complete, so they need no additions.
