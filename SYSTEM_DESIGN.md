# Moci running system

This document explains how the system behaves while the app runs: privacy boundaries, stored data, the play timer, audio, the microphone, the content pipeline, platform configuration, budgets, and release. The full technical plan is in [TECH-SPEC](docs/TECH-SPEC.md), store obligations are in [PRIVACY-RELEASE](docs/PRIVACY-RELEASE.md), and content rules are in [CONTENT-ASSETS](docs/CONTENT-ASSETS.md).

## 1. Privacy and offline boundaries

- No server, account, ads, analytics, or crash reporting. Not a single package sends data.
- The Android release manifest only asks for `RECORD_AUDIO` for Say, and does not ask for INTERNET. All content ships in the bundle: catalog, tracing, coloring pages, illustrations, and later audio.
- Child data lives only in the app folder. `android:allowBackup="false"` turns off Android backup, and the `<application support>/moci` folder is marked `isExcludedFromBackup` on iOS through the `moci/backup` channel. That way data does not move when the device changes.
- Debug and profile builds still use INTERNET for hot reload, so that permission exists only in the debug and profile manifests.
- The only system permission is the microphone for Say, added in Plan 03 together with the two permission reasons on iOS. The release also carries one app-owned permission injected by androidx.core, `id.pandudpn.moci.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Details are in sections 5 and 7.

## 2. Stored data

| Data | Location | Contents |
| --- | --- | --- |
| Settings | `shared_preferences` | The ten keys below |
| Progress | `progress.json` | Stars, stickers, last activity, play time, development, daily summary |
| Artwork | `karya/<id>.json`, at most 12 files | Page fill, save time, and `gambar` (300 × 225 PNG as base64) |
| Coloring draft | `draf/<halaman>.json`, one per page | Page fill, without the PNG |

Settings keys, all prefixed with `moci.`:

| Key | Value |
| --- | --- |
| `moci.bahasa` | `id` or `en`; the default follows the device language |
| `moci.nama` | Nickname, at most 20 characters after trimming |
| `moci.usia` | `2-3`, `4-5`, or `6-7` |
| `moci.caraBaca` | `fonik` or `nama` |
| `moci.panggilan` | `ayahBunda`, `bapakIbu`, `papiMami`, `daddyMommy`, or `orangTua`; default `ayahBunda` |
| `moci.batasMenit` | `15`, `30`, `45`, or `0` for no limit; default 30 |
| `moci.musik` | `true` or `false` |
| `moci.efek` | `true` or `false` |
| `moci.istirahat` | `true` or `false` |
| `moci.sambutanSelesai` | `true` after Welcome finishes |

Unknown values fall back to defaults: device language, age `pemula`, reading mode `fonik`, greeting `ayahBunda`, a 30-minute limit, and switches on.

Shape of `progress.json`:

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

Storage rules:

- Every file has `versi`. `Progress.versi` is 1 for now, and reading is tolerant: a missing field or a field of the wrong type becomes an empty value instead of throwing.
- Atomic writes: `FileJsonStore.write` writes `<file>.tmp` with a flush, then renames it.
- A file that cannot be read is moved to `<file>.rusak-<milliseconds>` and treated as empty. `list` skips `.tmp` and `.rusak-`.
- `waktuBermain` and `harian` are kept for the last 7 days. Trimming happens every time progress changes.
- `perkembangan` is never trimmed; it is long-term data used by the Parent Area summary.
- `karya/` and `draf/` are read and written by `KaryaRepository` through `JsonStore`, then shared to screens as `karyaProvider`. The limits are 12 artworks (the oldest is trimmed), one draft per page, and 200 KB per file. The preview PNG lives inside the artwork JSON, not as a separate file, so one artwork stays one atomic file.
- Save writes the artwork first, then records progress (`recordKarya`, `markItem('mewarnai', 'diwarnai', halaman)`). Save does not delete the draft, and deleting an artwork does not delete the draft.
- `perkembangan` is only filled by `markItem` for the `hewan` module (42 items) and `buahSayur` (35 items). Colors, Shapes, and Music Play only record `kegiatanTerakhir`, because those modules are not in the This week summary.
- Delete all data in the Parent Area runs `jsonStore.deleteAll`, `progress.reset`, and `prefs.resetAll`, drops the play timer from memory, revokes parent access, then opens Welcome again.

### Coloring feature (Plan 07)

| File | Contents |
| --- | --- |
| `lib/features/mewarnai/galeri_screen.dart` | 44 pages in five categories, six filter pills, a scrollable grid, a Continue badge, the My Artwork card |
| `tool/konten/halaman_mewarnai/` | generator for new pages; `buat_halaman.dart` adds 30 pages to `pages.json` |
| `lib/features/mewarnai/kanvas_screen.dart` | tools, 16 crayons, 8 stickers, undo, draft autosave, Save, picture picker |
| `lib/features/mewarnai/karyaku_screen.dart` | 12 artworks, detail, two-step delete, color again |
| `lib/features/mewarnai/mewarnai_engine.dart` | fill, brush, erase, stickers, and a 30-step undo history |
| `lib/features/mewarnai/mewarnai_painter.dart` | one page painter shared by the screen and the PNG export |
| `lib/features/mewarnai/karya_repository.dart` | reads and writes `draf/` and `karya/` through `JsonStore` |

## 3. Play timer

- One tick per second from `playTimerTicksProvider`. Tests replace it with a manual stream.
- Time is counted only while the app is in front (`AppLifecycleState.resumed`) and the current route is a play route (D14). Splash, Welcome, Gate, Parent Area, Rest, and Time's Up are not counted.
- The gap between ticks is clamped to 0 through 2 seconds, then rounded. A clock that runs backwards, a clock that jumps, or an app suspended without a pause event does not break the count.
- Crossing midnight loads the stored seconds for the new date and restarts the count since the last rest.
- Seconds are saved to `progress.json` every 30 counted seconds, when the app goes to the background, and when the day changes. Finishing a rest uses `restTaken`, which restarts the 20-minute count.
- Rest reminder: `restDue` after 1,200 seconds of play since the last rest. `MociApp` opens `/istirahat` once per `restDue` when the current route is a play route and the limit has not been reached. After 20 seconds the screen closes and the child returns to the previous screen. Time's Up wins over Rest.
- Daily limit: `limitReached` when today's seconds reach the limit in minutes. `limitReachedProvider` refreshes the router, so a play route redirects to `/habis`. Raising the limit in the Parent Area unblocks immediately, but the Parent Area does not close because the router is not refreshed while parent access is open.

## 4. Audio

Flow of one sound:

1. `AssetCatalog` loads the asset list from the bundle manifest. Every playback is checked against this catalog first, so an asset that does not exist yet never becomes an error.
2. `AudioService` sets priority: narration above effects, effects above music. Narration volume 1.0; effects 0.7; music 0.25; music drops to 0.10 while narration plays.
3. `SoLoudAudioEngine` loads an asset once per path, plays it through `flutter_soloud`, and reports completion from `AudioSource.soundEvents` at `handleIsNoMoreValid`.
4. `Narrator` builds the path `assets/audio/vo/<bahasa>/<jenis>_<id>.m4a`. If the recording does not exist yet, `DeviceTts` reads the text in every build mode.

Rules already in the code:

- One narration at a time. `Narrator.say` and `sayAll` use a generation number, so a new narration cancels the old one, including a narration that is still loading.
- `stopAll` and `narrator.stop` are called when the app is hidden or paused. On return, the iOS audio session is activated again and music starts again if its switch is on.
- Effects use the `Sfx` enum: `klik`, `benar`, `salahLembut`, `sorak`, `bintang`, with path `assets/audio/sfx/<nama>.wav`.
- Background music uses `AudioService.musicAsset`: an OGG file in `assets/audio/`, played on repeat. The file does not exist yet, so playing music currently produces no sound.
- The iOS session uses the playback category through the `moci/audio_session` channel, so sound is still heard while the silent switch is on. Its native implementation is in `ios/Runner/MociChannels.swift`.
- Device TTS is used in every build mode. It uses the `moci/tts` channel, and the main manifest adds a `<queries>` block for `TTS_SERVICE` (Android 11+).
- Music Play instruments use 12 mono 16-bit 24 kHz WAVs in `assets/audio/instrumen/`, made by `tool/buat_instrumen.dart` and recorded as `Milik sendiri` (own work). There is no synthesis while the app runs; `MusikAudio` loads them all once after the first frame, then plays notes directly through `AudioEngine` at effect volume 0.7, following the Sound effects switch. Play latency on device is targeted below 50 ms.
- Animal sounds use `assets/audio/hewan/<id>.m4a` (42 CC0 files). If the asset is not in `AssetCatalog`, "Dengar suara" (Hear the sound) reads the sound imitation from the catalog through TTS; the screen never plays a path that does not exist.

## 5. Microphone (Plan 03)

The recognizer, the sound level meter, and the Say screen are already in place. The rules that apply:

- `speech_to_text` is used with `onDevice: true` and `contextualPhrases` holding the target word. No mode may use a network service.
- The Parent Gate appears before the system permission dialog. If permission is denied, Say runs in listen and imitate mode without a microphone.
- Android only asks for `RECORD_AUDIO` and a `<queries>` block for `android.speech.RecognitionService`. INTERNET and Bluetooth are not added, and Say is tested in airplane mode.
- iOS adds `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` with text written for parents.
- Sound is not recorded to a file and is not sent anywhere. After a permission or manifest change, `docs/PRIVACY-RELEASE.md` must be updated.
- `MicLevelMeter` is the fallback when offline recognition is unavailable: the `moci/mic_level` channel streams a 0..1 level every 50 ms from `AudioRecord` (Android) or a 1024-frame `AVAudioEngine` tap (iOS). Sound counts as present when the level is above 0.12 for 300 ms; the buffer is dropped after RMS is computed.
- The Say screen calls `pauseForListening` before the microphone goes live and `resumeAfterListening` in `finally`, so narration and music are not recorded.

## 6. Content pipeline and validator

| Stage | File | How it works |
| --- | --- | --- |
| One-time export | `tool/konten/ekspor_prototipe.dart` | Reads the `docs/design/prototype/` snapshot, writes `assets/content/`, `assets/tracing/`, `assets/coloring/`, and `assets/illustrations/` |
| Parser | `tool/konten/js_literal.dart` | Reads prototype JavaScript literals: single quotes, unquoted keys, trailing commas |
| Validation | `tool/konten/validasi/` | Separate rules per area: structure, SVG, tracing, coloring, narration, audio |
| Entry point | `tool/validate_content.dart` | Runs every rule, prints a summary, exits with code 1 if there is an error |

Rules enforced:

- `json_valid`: the six JSON files can be read and their shape matches.
- `id_unik`, `referensi_gambar_ada`, `referensi_warna_ada`, `nama_dua_bahasa`, `kata_utuh`: the catalog is consistent and every reference has a target.
- `svg_aturan`, `svg_tanpa_pemakai`, `anggaran_ilustrasi`: SVGs follow the rules (viewBox 200 × 200, no style, gradient, image, text, filter, mask), no file is orphaned, and the total is under 4 MB.
- `tracing_lengkap`, `tracing_perintah_didukung`: letters and numbers have paths, and only the `M L H V C` commands are used.
- `mewarnai_tertutup`, `mewarnai_contoh`: every part of a picture is closed, and an example color is reported as a warning while it is incomplete.
- `narasi_lengkap`: expected narration lines are compared with the recordings. Development mode gives a warning, `--rilis` gives an error.
- `lisensi_audio_lengkap`: every audio file has a row in `assets/audio/LICENSES.csv` with the license `CC0` or `Milik sendiri` (own work). Any other value is always an error, including in development mode.
- `suara_hewan_lengkap`, `anggaran_audio`: animal sounds and total audio are checked; `--rilis` demands completeness.

`--naskah=build/naskah.csv` writes a CSV with the columns `file`, `bahasa`, `teks`, and `catatan` for every line that is not recorded yet. Only the form `--naskah=<path>` is read.

## 7. Platform configuration

| Item | Value in the repo |
| --- | --- |
| Orientation | Landscape left and right. `SystemChrome.setPreferredOrientations` in `lib/main.dart`, `UISupportedInterfaceOrientations` and `UISupportedInterfaceOrientations~ipad` landscape only, `UIRequiresFullScreen` = true, `android:screenOrientation="sensorLandscape"` |
| Android 16 resizable | `<property android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY" android:value="true"/>` in `<application>` |
| App name | `Moci` in `android:label` and `CFBundleDisplayName` |
| Bundle id | `id.pandudpn.moci` on iOS and the Android `applicationId` (D3) |
| OS versions | iOS 15.0, Android minimum API 24, target and compile API 36 |
| App version | `1.0.0+1` from `pubspec.yaml` |
| Languages | `CFBundleLocalizations` holds `id` and `en`; Android takes the device locale through the Flutter plugin, then text from the ARB files |
| Backup | `android:allowBackup="false"` and `isExcludedFromBackup` for the iOS data folder |
| Release permissions | `RECORD_AUDIO` for Say, plus one app-owned permission injected by androidx.core, `id.pandudpn.moci.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (protectionLevel `signature`). `aapt2 dump permissions` on the release arm64 APK shows only those two: no INTERNET and no Bluetooth |
| Signing | Release APK and AAB are signed with the Moci key if `android/key.properties` exists, and with the debug key if not. The key files live outside the repo; `.gitignore` rejects `android/key.properties` and `*.jks` |

If the system ignores the orientation lock, the stage stays safe because content is always scaled into the safe area by `fitStage`.

## 8. Performance and size budgets

| Item | Target | How to check |
| --- | --- | --- |
| Download | Under 30 MB | Release bundle size in Plan 10 |
| Illustrations | Under 4 MB | `anggaran_ilustrasi` in the validator |
| Audio | Under 12 MB | `anggaran_audio` in the validator |
| Fonts | Under 1 MB for eight files | `test/app/theme/font_budget_test.dart` |
| Speed | 60 fps, taps answered under 100 ms | Device test |
| App open | Splash animation under 1.5 seconds | Device test |
| Memory | Under 200 MB | Device test |
| Contrast | Text at least 4.5 : 1 | `test/app/theme/contrast_test.dart` |

Current sizes: illustrations 452 KB, fonts 320 KB, and audio 1.9 MB (42 CC0 animal sounds and 12 `Milik sendiri` instruments).

## 9. CI and release

`.github/workflows/ci.yml` runs two jobs:

- `test` on Ubuntu: checks the Flutter 3.50 version in `.fvmrc`, `flutter pub get`, `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `dart run tool/validate_content.dart`, then `flutter test --exclude-tags golden`.
- `golden` on macOS: `flutter pub get` and `flutter test --tags golden`.

`.github/workflows/release.yml` (named Release) runs from two triggers: pushing a `v*` tag, or `workflow_dispatch` from `main` with the choice `none`, `patch`, `minor`, `major`, or an explicit version. The goal is sideloading, not the stores: signed AAB and APK for Android, unsigned IPA for iOS. Six jobs:

- `prepare`: rejects a tag that does not match `x.y.z` in `pubspec.yaml`, rejects a stale dispatch or one whose `HEAD` is already tagged, copies `SUMMARY.md`, then stages a `chore(release): v<x.y.z>` commit and an annotated tag inside the runner without pushing. That commit, the summary contents, and the git bundle are sent to other jobs as artifacts.
- `verify`: checks out at the staged tag through `.github/actions/release-checkout` (a composite action that fetches the bundle artifact), then checks format, analyze, the content validator, tests without golden, and the tag against `pubspec.yaml`.
- `golden`: macOS, `flutter test --tags golden`.
- `android`: JDK 21, the keystore from secrets to `$RUNNER_TEMP`, `flutter build appbundle --release` and `flutter build apk --release` (one universal APK). Files are named `moci-<versi>.aab` and `moci-<versi>.apk`. `apksigner verify --print-certs` fails the job if the APK is still signed with the debug key.
- `ios`: macOS, `flutter build ios --release --no-codesign`, then `Runner.app` inside `Payload/` is zipped into `moci-<versi>.ipa`.
- `publish`: pushes the bump commit and tag atomically with `GITHUB_TOKEN` only if this run created them, assembles the notes with `tool/rilis/catatan_rilis.dart`, publishes or edits a release titled `Moci <x.y.z>`, then uploads the AAB, APK, IPA, and `SHA256SUMS`. A version with `-` becomes a prerelease.

Release notes are assembled from the mainline, not from `--generate-notes`: a merged pull request becomes one entry that links its pull request with the commits inside it folded in, a direct commit links its short commit, and authors are named by their GitHub login. `chore(release)`/`chore(rilis)` commits, their reverts, and bot commits are left out. The committed `SUMMARY.md` appears above the entries, then the fixed Install section. `.github/release.yml` is only used by `--generate-notes`, which the workflow never calls; its group titles are kept the same so both read the same. A tag push by `GITHUB_TOKEN` does not trigger a second run, so the same run publishes, and a `bump=none` dispatch republishes a tag whose release does not exist yet.

Android signing uses four repo secrets; only their names are recorded here: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, and `ANDROID_KEY_ALIAS`. The workflow writes the keystore to `$RUNNER_TEMP` and `android/key.properties` on the runner, never to the repo. On a local machine, `android/key.properties` holds `storePassword`, `keyPassword`, `keyAlias`, and an absolute `storeFile` pointing at the keystore outside the repo.

The IPA is unsigned because the Apple account in use is free. Installation is through Sideloadly or AltStore with your own Apple ID, and the app stops opening after 7 days.

What remains in Plan 10: a TestFlight and Play internal testing build, a public privacy policy, and filling in `AppConfig.privacyPolicyUrl` and `AppConfig.supportEmail`. While both are `null`, the related links do not show in the Parent Area.

## 10. Menus and games that end

- Every Plan 04 menu takes starting parameters from the query (`hewan`, `buah` and `mode`, `warna`, `bentuk` and `mode`, `alat` and `lagu`), records `setLastActivity` when it opens and when the choice changes, and ignores unknown values.
- Only Shapes Find ends. The sixth round calls `finishGame(gameId: 'bentuk', roundId: '<seed>/6')` then opens `/hebat` with `HebatArgs`; `roundId` uses a per-play seed, so "Ambil hadiah" twice is still one reward and the next play can still earn a reward.
- Fruits Guess, Colors, and Music Play loop without end. Music Play gives no stars or stickers: a finished song is marked by a pill and the narration "Hebat! Kamu memainkan satu lagu!" ("Great! You played one song!"), then the screen returns to the free state.
