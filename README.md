<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/github/banner-dark.png">
    <img src="docs/brand/github/banner-light.png" alt="Moci — Main &amp; Belajar" width="100%">
  </picture>
</p>

<p align="center">
  <b>A learning and play app for children aged 2–7.</b><br>
  No ads · No in-app purchases · Works offline · Bahasa Indonesia &amp; English<br>
  iPad · iPhone · Android (phone &amp; tablet)
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-iOS%20%7C%20Android-1C8CF0" alt="Flutter for iOS and Android">
  <img src="https://img.shields.io/badge/usia-2%E2%80%937%20tahun-26A03B" alt="Ages 2–7">
  <a href="https://github.com/pandudpn/moci-app/releases/latest"><img src="https://img.shields.io/github/v/release/pandudpn/moci-app?label=download" alt="Latest release"></a>
</p>

---

## Table of contents

- [About Moci](#about-moci)
- [Install](#install)
- [Features](#features)
- [App screens](#app-screens)
- [For parents: privacy and safety](#for-parents-privacy-and-safety)
- [Tech stack](#tech-stack)
- [Repo layout](#repo-layout)
- [Running the app](#running-the-app)
- [Documentation](#documentation)
- [Brand and assets](#brand-and-assets)
- [Roadmap](#roadmap)
- [Audio](#audio)
- [License](#license)

---

## About Moci

Moci is a play and learning companion for early childhood. Its mascot, Moci, is a small round yellow creature with a leaf sprout on its head, and appears on every screen: it greets the child by name, gives hints by voice, and celebrates every success.

Kids trace letters and numbers, count, read syllables and sentences, explore animals, fruit, colours, shapes and music, play six mini games, and colour pictures without ever going outside the lines. The design and the interactive prototype are done, the Flutter foundation is in place (shell, navigation, local storage, audio, two languages), the content pipeline is complete, and the menus are being built one at a time.

Principles that hold on every screen:

- **No ads, no purchases, no accounts.** The child is never sent out of the app.
- **Data stays on the device.** The child's name, settings, and artwork are stored locally. There is no server and no third-party analytics.
- **Works offline.** All content ships inside the app.
- **Two languages.** Text and voice are available in Bahasa Indonesia and English, and can be switched at any time.
- **Friendly to small children.** Big buttons, little text, lots of voice and animation, positive feedback, and difficulty levels that follow age (2–3, 4–5, 6–7).

## Install

Moci is not on the App Store or Play Store. Ready-to-install builds are on the [latest release page](https://github.com/pandudpn/moci-app/releases/latest), under **Assets**.

| File | For | How |
| --- | --- | --- |
| `moci-<version>.apk` | Android phone or tablet (Android 7.0 or newer) | Install directly |
| `moci-<version>.ipa` | iPad or iPhone | Install with Sideloadly or AltStore |
| `moci-<version>.aab` | Google Play only | Cannot be installed directly |
| `SHA256SUMS` | Checking the downloads | Optional |

### Android

1. Open the [latest release](https://github.com/pandudpn/moci-app/releases/latest) on the phone or tablet and tap `moci-<version>.apk`.
2. Open the downloaded file. When Android asks, allow your browser or file manager to install unknown apps.
3. Tap **Install**, then open Moci.

A newer APK installs over the old one and keeps the child's progress.

### iPad and iPhone

The IPA is unsigned, so it needs a sideloading tool that signs it with your own Apple ID. A free Apple ID works.

1. Download `moci-<version>.ipa` from the [latest release](https://github.com/pandudpn/moci-app/releases/latest) to a Mac or Windows PC.
2. Install [Sideloadly](https://sideloadly.io) (or [AltStore](https://altstore.io)) and connect the iPad or iPhone by cable.
3. Drag the IPA into Sideloadly, enter your Apple ID, and start.
4. On the device, trust your Apple ID in **Settings > General > VPN & Device Management**. On iOS 16 or newer, turn on **Settings > Privacy & Security > Developer Mode** when asked.
5. Open Moci.

With a free Apple ID the app stops opening after 7 days. Run Sideloadly again to re-sign it; the child's progress stays. With the Apple Developer Program, the signature lasts 1 year.

### Checking a download

```bash
shasum -a 256 -c SHA256SUMS --ignore-missing
```

To build and install from source instead, see [Running the app](#running-the-app).

## Features

| Menu                | Contents                                                                                                                                                             |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Letters (Kenal Huruf)**     | 26 letters A–Z with pictures and example words, readable as a sound (phonics) or a letter name, writing practice (tracing) with direction arrows, and pronunciation practice. |
| **Counting (Berhitung)**      | Numbers 1–50 with objects to count together, plus writing practice for the digits 0–9.                                                                                |
| **Animal World (Dunia Hewan)**     | 42 animals in 5 groups, each with its name, a sound imitation, and a short fact.                                                                                     |
| **Fruit & Veg (Buah & Sayur)**    | 21 fruits and 14 vegetables, with a Learn mode and a Guess mode.                                                                                                     |
| **Colours (Warna)**           | 11 colours. The child taps every object in the colour asked for.                                                                                                      |
| **Shapes (Bentuk)**          | 10 shapes, including counting sides and corners, plus a Find mode.                                                                                                    |
| **Music (Main Musik)**      | An 8-note xylophone with songs to follow along, plus drums with 4 sounds and example rhythms.                                                                         |
| **Let's Read (Ayo Membaca)**     | Syllables (ba-bi-bu-be-bo), building words from syllables, and reading sentences with the words lighting up one at a time.                                            |
| **Let's Play (Main Yuk!)**       | 6 mini games: Match the Picture (Cocokkan Gambar), Memory Cards (Kartu Memori), Guess the Shadow (Tebak Bayangan), Puzzle, Letter Balloons (Balon Huruf), Big & Small (Besar & Kecil). |
| **Colouring (Mewarnai)**        | 44 pictures: animals, sea, fruit & veg, city, and objects. Colour cannot leave the lines. There are brushes, fill, eraser, stickers, and Karyaku (My Work) to save the results. |
| **Rewards (Hadiah)**          | Stars and stickers each time the child finishes a game.                                                                                                              |
| **For parents (Untuk orang tua)** | Parent gate, child profile, progress summary, how to read letters, daily time limit, and break reminders.                                                            |

## App screens

All screenshots are taken from the interactive prototype in its tablet version (1180 × 820), not from the Flutter app being built.

### Start

<table>
<tr>
<td width="50%"><img src="docs/screenshots/01-splash.png" alt="Splash screen"><br><b>Splash.</b> Moci falls from the top and bounces, the letters M-o-c-i appear one by one, then the tagline "Main &amp; Belajar" (Play &amp; Learn).</td>
<td width="50%"><img src="docs/screenshots/02-sambutan.png" alt="Welcome"><br><b>Sambutan (Welcome).</b> Parents pick a language, enter the child's nickname, and pick an age. The data is stored on the device only.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/03-beranda.png" alt="Home"><br><b>Beranda (Home).</b> Moci greets with "Hai, &lt;nama anak&gt;!" (Hi, &lt;child name&gt;!). There are 10 picture menus, a continue button, an ID/EN language switch, the star count, and a door into the Parent Area.</td>
<td width="50%"><img src="docs/screenshots/31-beranda-hp.png" alt="Home on a phone"><br><b>Beranda (Home) on a phone.</b> Landscape layout for the iPhone and Android phones.</td>
</tr>
</table>

### Letters & numbers

<table>
<tr>
<td width="50%"><img src="docs/screenshots/04-huruf.png" alt="Letters"><br><b>Kenal Huruf (Letters).</b> Upper and lower case, a picture, and an example word. Tap to hear the letter sound (phonics) or its name.</td>
<td width="50%"><img src="docs/screenshots/05-tulis-huruf.png" alt="Letter writing"><br><b>Tulis Huruf (Letter writing).</b> 26 letters. The child drags Moci along the yellow arrows, line by line, until the star.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/06-ucapkan.png" alt="Say it"><br><b>Ucapkan (Say it).</b> Hear the example, then the child says the word. For now the microphone is still simulated.</td>
<td width="50%"><img src="docs/screenshots/07-berhitung.png" alt="Counting"><br><b>Berhitung (Counting).</b> Numbers 1–50 with their names. The "Hitung bareng" (count together) button counts objects one at a time.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/08-tulis-angka.png" alt="Number writing"><br><b>Tulis Angka (Number writing).</b> Tracing the digits 0–9 with the same direction guides as letters.</td>
<td width="50%"></td>
</tr>
</table>

### The world around

<table>
<tr>
<td width="50%"><img src="docs/screenshots/09-hewan.png" alt="Animal world"><br><b>Dunia Hewan (Animal World).</b> 42 animals in 5 groups: pets &amp; farm, forest &amp; savanna, reptiles &amp; frogs, sea &amp; water, and birds &amp; insects. There are buttons to hear the name, hear the sound, and read a short fact.</td>
<td width="50%"><img src="docs/screenshots/10-buah-sayur.png" alt="Fruit and veg"><br><b>Buah &amp; Sayur (Fruit &amp; Veg).</b> A Learn mode to get to know the names, and a Guess mode with three picture choices.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/11-warna.png" alt="Colours"><br><b>Warna (Colours).</b> The child taps every object in the colour asked for. There are 11 colours, and the "Gambar baru" (new picture) button shuffles the screen.</td>
<td width="50%"><img src="docs/screenshots/12-bentuk.png" alt="Shapes"><br><b>Bentuk (Shapes).</b> 10 shapes with funny faces. The "Hitung sudut" (count corners) button marks the corners one by one while saying the number.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/12b-bentuk-cari.png" alt="Shapes in find mode"><br><b>Bentuk: Cari (Shapes: Find).</b> "Mana segitiga?" (Where is the triangle?) Colours are deliberately shuffled, so the child recognises the shape, not the colour. The number of choices follows age.</td>
<td width="50%"><img src="docs/screenshots/13-musik-xilofon.png" alt="Xylophone"><br><b>Main Musik: Xilofon (Music: Xylophone).</b> 8 notes, do to do. The "Ikuti" (follow) mode shows the next bar for playing Twinkle Twinkle or Mary Had a Little Lamb.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/13b-musik-drum.png" alt="Drum"><br><b>Main Musik: Drum.</b> Drum, clap, cymbal, and shaker, plus example rhythms to follow.</td>
<td width="50%"></td>
</tr>
</table>

### Let's read

<table>
<tr>
<td width="50%"><img src="docs/screenshots/14-suku-kata.png" alt="Syllables"><br><b>Suku Kata (Syllables).</b> Pick a consonant to form ba-bi-bu-be-bo. Tap a syllable to hear it, then see an example word.</td>
<td width="50%"><img src="docs/screenshots/15-susun-kata.png" alt="Build the word"><br><b>Susun Kata (Build the word).</b> Listen to the word, then tap its syllables in order. There are 2 and 3 syllable levels.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/16-kalimat.png" alt="Sentences"><br><b>Kalimat (Sentences).</b> "Baca bersama" (read together) lights up the words one at a time like karaoke. There is also a Guess the Picture mode.</td>
<td width="50%"></td>
</tr>
</table>

### Let's play

<table>
<tr>
<td width="50%"><img src="docs/screenshots/17-main-yuk.png" alt="Let's Play"><br><b>Main Yuk! (Let's Play).</b> Six mini games with age labels.</td>
<td width="50%"><img src="docs/screenshots/18-cocokkan.png" alt="Match the picture"><br><b>Cocokkan Gambar (Match the Picture).</b> Connect identical pictures by tapping them or drawing a line. The theme is random: fruit, animals, vegetables, vehicles, objects.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/19-kartu-memori.png" alt="Memory cards"><br><b>Kartu Memori (Memory Cards).</b> Open two cards and find the pair. There are 4, 6, or 8 pairs.</td>
<td width="50%"><img src="docs/screenshots/20-tebak-bayangan.png" alt="Guess the shadow"><br><b>Tebak Bayangan (Guess the Shadow).</b> "Bayangan siapa ini?" (Whose shadow is this?) Pick the matching picture, and the shadow turns to colour.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/21-puzzle.png" alt="Puzzle"><br><b>Puzzle.</b> Tap a piece, then tap its place. There are 4, 6, or 9 pieces depending on age.</td>
<td width="50%"><img src="docs/screenshots/22-balon-huruf.png" alt="Letter balloons"><br><b>Balon Huruf (Letter Balloons).</b> Moci says a letter, then the child pops the balloon with the matching letter. There are 5 rounds.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/23-besar-kecil.png" alt="Big and small"><br><b>Besar &amp; Kecil (Big &amp; Small).</b> "Mana yang paling besar?" (which is biggest?) or "paling kecil?" (smallest?). The same object is shown at several sizes.</td>
<td width="50%"></td>
</tr>
</table>

### Colouring

<table>
<tr>
<td width="50%"><img src="docs/screenshots/24-galeri-mewarnai.png" alt="Colouring gallery"><br><b>Pilih Gambar (Choose a picture).</b> 44 pictures in five categories, plus Karyaku (My Work).</td>
<td width="50%"><img src="docs/screenshots/25-mewarnai.png" alt="Colouring canvas"><br><b>Kanvas (Canvas).</b> Colour cannot leave the lines. A stroke stays locked to the part of the picture where the finger first touched. There are 3 brush sizes, fill, eraser, stickers, undo, and 16 crayons.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/26-karyaku.png" alt="My Work"><br><b>Karyaku (My Work).</b> Everything that was saved. Tap to see it bigger, colour it again, or delete it.</td>
<td width="50%"></td>
</tr>
</table>

### Rewards & breaks

<table>
<tr>
<td width="50%"><img src="docs/screenshots/27-hadiah.png" alt="Rewards"><br><b>Hadiah (Rewards).</b> New stars and stickers each time the child finishes a game.</td>
<td width="50%"><img src="docs/screenshots/28-istirahat.png" alt="Break"><br><b>Waktunya Istirahat (Time for a break).</b> Appears every 20 minutes of play when the reminder is on. There is a countdown with three simple movements.</td>
</tr>
<tr>
<td width="50%"><img src="docs/screenshots/28b-waktu-habis.png" alt="Time is up"><br><b>Waktu Habis (Time is up).</b> Appears when the daily limit is reached. Only a parent can open it again.</td>
<td width="50%"></td>
</tr>
</table>

### Parents

<table>
<tr>
<td width="50%"><img src="docs/screenshots/29-gerbang-orang-tua.png" alt="Parent gate"><br><b>Gerbang Orang Tua (Parent gate).</b> A simple multiplication question so the child cannot open settings or outbound links.</td>
<td width="50%"><img src="docs/screenshots/30-area-orang-tua.png" alt="Parent area"><br><b>Area Orang Tua (Parent area).</b> Child profile, play time today, this week's progress, language, how to read letters, daily time limit, music, sound effects, and break reminders.</td>
</tr>
</table>

## For parents: privacy and safety

- No ads, no in-app purchases, and no account needed.
- No server. The child's name, settings, progress, and artwork are stored on the device only.
- No analytics or third-party SDK tracking the child.
- Settings and any link sit behind the Parent Gate.
- The daily time limit (15, 30, or 45 minutes, or no limit) and break reminders are set by parents.

## Tech stack

| Part               | Choice                                                                                                               |
| ------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Framework          | Flutter 3.50 with FVM, one codebase for iPad, iPhone, Android phones, and Android tablets                             |
| Material           | `material_ui`, because `package:flutter/material.dart` is deprecated in Flutter 3.50                                 |
| Navigation         | `go_router`, with centralised redirects for Welcome, the Gate, and the time limit                                    |
| State              | `flutter_riverpod`                                                                                                   |
| Illustrations      | SVG, rendered by `vector_graphics` and compiled at build time                                                        |
| Tracing & colouring | Flutter canvas (`CustomPainter` + clip path). Strokes are saved as data, not as pictures                            |
| Animation          | Flutter's built-in animation, with no Lottie, Rive, or video                                                         |
| Audio              | `flutter_soloud` for effects and music; narration is read by the device TTS in every build, including releases       |
| Text               | gen-l10n from `l10n/app_id.arb` and `l10n/app_en.arb`                                                                |
| Storage            | `shared_preferences` for settings, JSON files in the app folder for progress and artwork                             |
| Network            | None in release builds. All content ships in the bundle                                                              |
| Checks             | Analyze, format check, content validator, and tests without golden on Linux; golden on macOS. All through GitHub Actions |
| Build & release    | The Release workflow from a `v*` tag or the Actions button: bump the version in `pubspec.yaml`, build a signed AAB and APK plus an unsigned IPA, release notes from commits, then publish to GitHub Releases |

Target: app size under 30 MB and 60 fps animation, including on low-end Android tablets.

Repo layout today:

```
moci-app/
├── lib/
│   ├── app/            # shell, router, theme, layout stage, timers
│   ├── core/           # content models, storage, audio, settings, progress
│   ├── features/       # screens per menu
│   ├── l10n/           # gen-l10n output
│   └── widgets/        # shared widgets: buttons, mascot, dialogs, number board
├── assets/
│   ├── content/        # content catalog
│   ├── tracing/        # letter & number paths
│   ├── coloring/       # colouring pages, stickers, crayons
│   ├── illustrations/  # 111 SVG
│   ├── fonts/          # Fredoka, Nunito, OFL licences
│   └── audio/          # animal sounds, instruments, effects, LICENSES.csv
├── tool/               # content validator, prototype export, font build
├── test/               # unit, widget, golden tests
├── integration_test/   # three on-device scenarios
├── l10n/               # app_id.arb, app_en.arb
├── docs/               # spec copies, plans, prototype, brand, screenshots
└── AGENTS.md           # working instructions for humans and agents
```

## Running the app

The Flutter version is pinned in `.fvmrc`, so every command uses FVM:

```bash
fvm install
fvm flutter pub get
fvm flutter run -d <device>
```

Device IDs are listed with `fvm flutter devices` or `make devices`. The check commands, golden tests, content validator, and integration tests are in [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md).

### Installing from a Mac

Moci is not published on the App Store or Play Store. For your own build, install a release build straight from the Mac to a device connected by cable:

```bash
make devices                      # list connected devices
make install                      # build release, install, then open the app
make install DEVICE=<id>          # pick a specific device
make run                          # debug mode with hot reload
```

Without `DEVICE`, the first physical device is used, iOS first. `DEVICE=<simulator-UDID>` (see `xcrun simctl list devices`) installs a debug build on the iOS simulator. All targets are in [scripts/moci.sh](scripts/moci.sh).

- **iPad/iPhone:** the device needs Developer Mode on, and Xcode needs to be signed in to the team's Apple account (Xcode > Settings > Accounts). The first time, open `ios/Runner.xcworkspace` once and pick the team in Signing & Capabilities. With a free Apple account, the app stops opening after 7 days and needs reinstalling; with the Apple Developer Program, it lasts 1 year.
- **Android:** turn on USB debugging. The release APK is signed with the release key if `android/key.properties` exists, and with the debug key if not. Either is enough for installing your own build.

## Documentation

| Document | Contents |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Working instructions for humans and agents: commands, code rules, test rules |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Code layers, providers, routes, state flow, test harness |
| [SYSTEM_DESIGN.md](SYSTEM_DESIGN.md) | Stored data, timers, audio, content pipeline, platforms, CI |
| [DESIGN.md](DESIGN.md) | Tokens, components, tablet and phone stages, motion, accessibility |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Workflow, commit style, PR checklist |
| [docs/README.md](docs/README.md) | Project summary, decisions, and documentation map |

Spec copies are in [`docs/PRD.md`](docs/PRD.md), [`docs/TECH-SPEC.md`](docs/TECH-SPEC.md), [`docs/DESIGN-SYSTEM.md`](docs/DESIGN-SYSTEM.md), [`docs/CONTENT-ASSETS.md`](docs/CONTENT-ASSETS.md), and [`docs/PRIVACY-RELEASE.md`](docs/PRIVACY-RELEASE.md).

## Brand and assets

All final brand assets are in [`docs/brand`](docs/brand), in PNG and SVG format.

| Folder                    | Contents                                                                                        |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| `docs/brand/icon/ios`     | 1024 px icons in light, dark, and tinted versions                                               |
| `docs/brand/icon/android` | Adaptive icon layers (foreground, background, monochrome), a 512 px Play Store icon, and the old icon |
| `docs/brand/logo`         | Stacked and horizontal logos (colour, black, white, for dark backgrounds), the Moci wordmark, and the mascot |
| `docs/brand/splash`       | Logo for the splash screen and the Android 12+ splash icon                                      |
| `docs/brand/github`       | 1280 × 640 social preview, light & dark README banners, avatar                                  |

- **Illustrations** are drawn specifically for Moci, not taken from other sites.
- **Fonts:** [Fredoka](https://fonts.google.com/specimen/Fredoka) and [Nunito](https://fonts.google.com/specimen/Nunito), both under the SIL Open Font License 1.1.
- **Main colours:** sky blue `#74C4FF`, Moci yellow `#FFD43B`, navy `#2B2350`. Logo letters: pink `#F03E7C`, orange `#FF9F1C`, blue `#1C8CF0`, green `#26A03B`.

## Roadmap

- [x] Design and interactive prototype for every menu (tablet version)
- [x] Icons, logo, splash screen, and GitHub assets
- [ ] Phone layout for every screen
- [ ] Bahasa Indonesia & English narration recordings
- [x] Animal sounds from Freesound (47 CC0 files; some animals use a substitute sound)
- [ ] On-device speech recognition for the Say it screen
- [x] Flutter app: shell, navigation, local storage
- [ ] Port every menu to Flutter
- [ ] Test on devices (iPad, iPhone, Android phones and tablets)
- [x] Direct install to your own device (`make install`); Moci is not published on the App Store or Play Store

## Audio

- **Narration** is read by the device's built-in voice (text-to-speech), not a recording. Accent and tone follow the voice that is installed, so they can differ between iPad, iPhone, and Android phones. Other voices can be installed in the device settings: on iOS through Settings, Accessibility, Spoken Content, Voices; on Android through the sound settings.
- **Animal sounds and sound effects** come from [Freesound](https://freesound.org) under the CC0 licence (public domain), then cut and levelled. Some animals use a substitute sound because no suitable CC0 recording exists: the orangutan uses a gibbon call, and a few small animals use a similar effect.
- **Instrument notes** (xylophone and drums) were made for Moci through `tool/buat_instrumen.dart`.
- **Full sources** for every file, including the uploader and the link, are in [`assets/audio/LICENSES.csv`](assets/audio/LICENSES.csv): 47 CC0 files from Freesound and 12 instrument notes owned by the project.

Narration recordings do not exist yet. Until the Bahasa Indonesia and English recordings are done, narration keeps using the device TTS in every build, including releases.

## License

All Moci code, illustrations, sound, text, and brand assets are copyrighted by the owner. The full text is in [`LICENSE`](LICENSE).

Third-party licences apply on top of that: the Fredoka and Nunito fonts use the SIL Open Font License 1.1, audio uses CC0 or is marked `Milik sendiri` ("own work") in `assets/audio/LICENSES.csv`, and every Dart or Flutter package uses its own licence.
