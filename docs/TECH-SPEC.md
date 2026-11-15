> Copy of the Claude Docs "Moci Documentation", Technical Specification tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci Technical Specification

Moci is built as a single Flutter app for iOS and Android that is fully offline. There is no server and no third party SDK that sends data. Every illustration and sound ships inside the app.

## Technology summary

| Area | Choice | Reason |
| --- | --- | --- |
| Framework | Flutter, starting from the latest stable version (3.50, released 11 November 2026) and pinned with FVM | One codebase for iPad, iPhone, and Android phones and tablets |
| Minimum OS version | iOS and iPadOS 15, Android 7.0 (API 24) | The lower bound that Flutter 3.50 supports |
| Android target | API 36 (Android 16) | Required for new apps and updates on Google Play since 31 August 2026 |
| Illustrations | SVG compiled at build time with `vector_graphics_compiler` | Parses faster, and needs no processing while the app runs |
| Navigation | `go_router` | Declarative routes, plus redirects for Welcome and Time's Up |
| State | `flutter_riverpod` | Settings, progress, and timers can be tested without the UI |
| Storage | `shared_preferences` for settings, JSON files in the app folder for progress and artwork | The data is small, no database needed |
| Audio | `flutter_soloud` for narration, sound effects, and instruments | Low latency, and can play M4A, WAV, and OGG |
| Speech recognition | `speech_to_text` in on-device mode (`onDevice`) | Recognizes the child's speech in the Say It (Ucapkan) menu without sending voice out |
| Tracing and coloring | Flutter's built-in `CustomPainter` | No extra package |
| Network | None | The Flutter template does not include the INTERNET permission in Android release builds |
| Crash and analytics | No SDK; use Xcode Organizer and Android vitals | Follows the kids app rules of both stores |

Third party packages are limited to the list above. A new package may only come in if it sends no data, needs no extra permissions, and is still actively maintained. The Flutter version is raised once a quarter, after its new release has been out for about a month.

## Architecture

![App architecture: 5 layers](images/arsitektur.png)

Screens never read files directly. Everything goes through state and core services, and the bottom layer holds only bundled assets and the app folder, with no connection to the outside.

## Project structure

One folder per menu in `lib/features`, and features never import each other. Everything shared lives in `lib/core` (services) and `lib/widgets` (display components).

```text
moci-app/
├── lib/
│   ├── main.dart
│   ├── app/              # MociApp, router, theme, play timer
│   ├── core/             # audio, storage, language, content loader
│   ├── widgets/          # buttons, back button, mode pill, mascot, stars
│   └── features/
│       ├── beranda/ huruf/ tulis/ ucapkan/ angka/
│       ├── hewan/ buah_sayur/ warna/ bentuk/ musik/
│       ├── membaca/      # suku_kata, susun_kata, kalimat
│       ├── main_yuk/     # cocokkan, memori, bayangan, puzzle, balon, besar_kecil
│       ├── mewarnai/     # galeri, kanvas, karyaku
│       └── sambutan/ hadiah/ istirahat/ orang_tua/
├── assets/
│   ├── illustrations/    # SVG, compiled at build time
│   ├── content/          # katalog.json
│   ├── tracing/          # letter and number stroke paths
│   ├── coloring/         # coloring pages
│   ├── audio/            # vo/id, vo/en, sfx, instruments, music
│   └── fonts/            # Fredoka, Nunito
├── l10n/                 # app_id.arb, app_en.arb
├── tool/                 # content validation scripts
├── test/
└── integration_test/
```

Every menu folder holds three parts:

- `*_screen.dart` for the display.
- `*_game.dart` for the game rules, written as pure Dart with no Flutter imports. This part builds rounds, judges answers, and adjusts the age level, with a seedable `Random` so it is easy to test.
- `widgets/` for components only that menu uses.

## Navigation, state, and play timer

Every screen is a `go_router` route under one app shell. That shell also runs the play timer, so the daily limit and breaks apply on any screen.

### Routes

- Start: `/splash`, `/sambutan`, `/` (Home)
- Letters and numbers: `/huruf`, `/huruf/tulis`, `/huruf/ucapkan`, `/angka`, `/angka/tulis`
- The world around: `/hewan`, `/buah-sayur`, `/warna`, `/bentuk`, `/musik`
- Reading: `/membaca/suku-kata`, `/membaca/susun-kata`, `/membaca/kalimat`
- Let's Play: `/main`, `/main/cocokkan`, `/main/memori`, `/main/bayangan`, `/main/puzzle`, `/main/balon`, `/main/besar-kecil`
- Coloring: `/mewarnai`, `/mewarnai/:halaman`, `/karyaku`
- Others: `/hebat`, `/istirahat`, `/habis`, `/gerbang`, `/orang-tua`

Redirect rules:

1. No profile yet: every route redirects to `/sambutan`.
2. Daily limit reached: every route redirects to `/habis`, except `/gerbang` and `/orang-tua`.
3. `/orang-tua` can only be opened through `/gerbang`. The permission is lost as soon as the Parents' Area closes.

The Android system back button behaves the same as the on-screen back button (through `PopScope`).

### State

| Provider | Contents |
| --- | --- |
| `prefsProvider` | Settings from `shared_preferences`. Changes apply immediately, including a language switch. |
| `progressProvider` | Stars, stickers, progress per menu, and the last activity for the Continue button |
| `playTimeProvider` | Today's play time and break status |
| `karyaProvider` | The list of artwork and coloring drafts |

### Play timer

- Time is counted only while the app is in the foreground and the child is on a play route. The Gate, Parents' Area, Break, and Time's Up do not count.
- Time is stored per date for the last 7 days, and resets every midnight in device time.
- If the reminder is on, every 20 minutes of play `/istirahat` opens over the screen in use. After 20 seconds, the child returns to that screen.
- When the limit is reached, play routes redirect to `/habis`. If the parent raises the limit, the child can continue right away.
- The clock is injected as a dependency (`Clock`), so all these rules can be tested without waiting.

## Data and local storage

All data is stored in the app folder and never leaves the device. In the fullest case (12 pieces of artwork plus drafts for 14 pages), the total stays under 6 MB.

| Data | Location | Contents | Size limit |
| --- | --- | --- | --- |
| Settings | `shared_preferences` | Language, name, age level, how letters are read, time limit, background music, sound effects, break reminder, Welcome status | Under 1 KB |
| Progress | `progress.json` | Stars, stickers, progress per menu, last activity, 7 days of play time | Under 50 KB |
| Artwork | `karya/<id>.json`, at most 12 files | Page contents, save time, and `gambar` (a 300 × 225 PNG as base64) | At most 200 KB per piece |
| Coloring drafts | `draf/<halaman>.json`, one per page | Page contents only, no PNG | At most 200 KB per draft |

Example `progress.json` contents:

```json
{
  "versi": 1,
  "bintang": 27,
  "stiker": ["apel", "moci-senang"],
  "kegiatanTerakhir": { "rute": "/huruf/tulis", "param": { "huruf": "A" } },
  "waktuBermain": { "2026-11-14": 1260 },
  "perkembangan": { "huruf": { "dilihat": ["A", "B"], "ditulis": ["A"] } }
}
```

Example `karya/k1763115124512.json` contents (`draf/kupu.json` is the same without `id`, `waktu`, and `gambar`):

```json
{
  "versi": 1,
  "id": "k1763115124512",
  "halaman": "kupu",
  "isian": { "1": "#74C0FC", "2": "#FFD43B" },
  "coretan": {
    "3": [{ "d": "M120 80 L124 81 L140 84", "warna": "#FF4B4B", "lebar": 26 }]
  },
  "cap": [{ "cap": "moci-senang", "x": 640.0, "y": 410.0 }],
  "waktu": "2026-11-14T10:12:04.512",
  "gambar": "iVBORw0KGgoAAAANSUhEUg…"
}
```

- My Artwork thumbnails use the PNG exported on Save; the Gallery uses the sample colors from the page data. There are no separate image files.
- A draft is written 600 ms after the last change and once more when the canvas screen is left. Save does not delete the draft.

Storage rules:

- Files are written atomically: write to a temporary file first, then rename.
- Every file has a `versi` number. When the format changes, the app migrates old files.
- Stroke points are simplified before saving, with a tolerance of 1 canvas unit, so artwork stays small.
- OS automatic backup is turned off: `android:allowBackup="false"` on Android, and the data folder is marked as excluded from backup on iOS. That way the promise "data stays on this device only" is literally true. The consequence is that progress does not move with the child when the device changes.
- Delete all data clears settings and every file, then opens Welcome again.

## Tracing and coloring engine

Tracing and coloring are the heaviest parts of the app. Both are drawn with `CustomPainter` inside a `RepaintBoundary`, and must hold 60 fps while a finger moves. The numbers below are starting values, tuned again during testing with children.

### Tracing (Letter Tracing and Number Tracing)

1. Every letter or number is a list of strokes in a 520 × 520 box, the same as the prototype. Stroke order and path direction define the correct way to write.
2. When a stroke starts, the path is turned into points 4 units apart through `PathMetric`.
3. The finger counts as on the path if it is at most 44 units from the nearest point ahead of the last position.
4. Progress only moves forward. Backward movement is ignored, and jumps more than 40 units ahead are rejected, so the child cannot cut a corner.
5. A stroke is done when progress reaches 97% of the path length. After every stroke is done, a star and a praise sound appear.
6. Moci is drawn at the progress point, and the yellow arrow points to the next direction. The trail already passed is filled with the star pattern from the prototype.

### Coloring

1. Page data comes from `pages.json`: an 800 × 600 canvas, a list of regions (closed paths) with their detail lines, and sample colors.
2. When a finger touches the canvas, the app finds the topmost region containing that point with `Path.contains`. That region is locked until the finger lifts, so color cannot leave the lines.
3. Every region is drawn with `canvas.clipPath`: fill color first, then strokes. The outer line is drawn on top.
4. Finished strokes are stored as a `ui.Picture` per region. Each frame redraws only the strokes in progress.
5. The brush has 3 sizes. Erase uses a white brush inside the region, and Fill replaces one region's color with a single tap.
6. A sticker is placed at the tap point at a fixed size, then stored as a sticker id and its position.
7. Undo keeps up to 30 steps of history, including Start over. So a canvas wiped by accident can be restored.
8. On Save, the page is redrawn through the same painter into a `PictureRecorder` and exported as a 300 × 225 PNG. That PNG is stored as base64 in `gambar` inside the artwork file and used as the My Artwork thumbnail; the Gallery keeps using the preview from the data.
9. Numbers used by the code: brushes of 14 / 26 / 44 units, erase at brush width + 10, 90 unit stickers, 30 step undo history, 600 ms automatic draft, 16 crayons, 8 stickers, and at most 12 pieces of artwork.

Two other games also use illustrations that already exist. Guess the Shadow applies a black `ColorFilter` to the colored picture, and Puzzle cuts the picture per piece with `ClipRect`.

## Audio

All sound plays through one engine, `flutter_soloud`. When sounds collide, the priority is narration first, then sound effects, then background music.

| Type | Format | How it loads | Rules |
| --- | --- | --- | --- |
| Narration | AAC (.m4a), mono | Loaded when a screen opens, released when it closes | Only one narration at a time. A new narration stops the old one. |
| Sound effects | 16-bit WAV, short | Loaded once at app start | Follows the Sound effects setting |
| Instruments | WAV, 8 xylophone notes and 4 drum sounds | Loaded when the Music menu opens | Sound comes out less than 50 ms after a touch |
| Background music | OGG, one loop | Played from the asset file | Follows the Background music setting. Volume drops while narration speaks. |

Starting volume: narration 100%, sound effects 70%, background music 25%. While narration speaks, background music drops to 10%.

Other rules:

- Narration is the main instruction, so the iOS audio session uses the playback category. That way narration still plays with the silent switch on, and volume still follows the volume buttons.
- When the app goes to the background, all sound stops. When a phone call comes in, narration stops and does not resume automatically.
- Device TTS is used in every build mode for text that has no recording yet, because the recordings only land in Plan 09 and the app is distributed through sideload. The validation script still fails `--rilis` if any text is left without a recording.

### Microphone in the Say It menu

Say It listens to the child through the microphone, and all speech recognition runs on the device.

1. The first time Say It opens, the Parental Gate appears first, then the system microphone permission dialog. If permission is denied, Say It runs in listen-and-imitate mode with no microphone.
2. Recognition uses `speech_to_text` with `onDevice: true` and the language from settings. The target word is sent as `contextualPhrases` ([speech\_to\_text](https://pub.dev/packages/speech_to_text)).
3. One listening turn lasts at most 4 seconds. While listening, narration and music are stopped so they are not recorded too. After the turn ends, the audio session returns to playback mode.
4. Speech counts as a match if one recognition result, lowercased and stripped of punctuation, equals the target word. For words of 4 letters or more, a one letter difference is still accepted.
5. If on-device recognition is unavailable for that language, the app only checks the sound level. The child counts as having spoken if their voice stays above the threshold for at least 0.3 seconds.
6. The child's voice is never written to a file and never sent anywhere.
7. Android needs only the `RECORD_AUDIO` permission and a `<queries>` block for `android.speech.RecognitionService`. The plugin README also asks for the INTERNET permission because recognition can use a remote service. Moci only uses on-device mode, so the INTERNET and Bluetooth permissions are not added, and Say It is tested in airplane mode.
8. iOS needs `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` in Info.plist, with text written for parents.

## Two languages, layout, and accessibility

### Two languages

- UI text uses Flutter's built-in `gen-l10n` with two files, `app_id.arb` and `app_en.arb`.
- Content names and facts (animals, fruits, words, sentences) live in `katalog.json`, one column per language.
- Narration lives in `audio/vo/id` and `audio/vo/en` with identical file names.
- The language can be switched at any time from Home or the Parents' Area, without restarting the app. The choice follows the device language automatically: Indonesian for Indonesian language devices, English for everything else.

### Tablet and phone layout

- Every screen is designed in landscape with two base sizes: tablet 1180 × 820 pt and phone 844 × 390 pt, the same as the prototype.
- The tablet layout is used when the screen's shortest side is 600 dp or more. Otherwise the app uses the phone layout.
- Screen contents scale proportionally from the base size to the available safe area. Leftover space is filled with the menu background color, so nothing gets cropped.
- **Orientation is locked to landscape** (left and right) on every device, through `SystemChrome.setPreferredOrientations` with `landscapeLeft` and `landscapeRight` when the app starts.
- iOS: `UISupportedInterfaceOrientations` for iPhone and iPad holds only landscape left and right, and Requires full screen (`UIRequiresFullScreen`) is enabled. On iPad, the orientation lock is only honored when multitasking is off ([Flutter](https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html)).
- Android: `android:screenOrientation="sensorLandscape"` in the main activity. Android 16 ignores this lock on screens with a smallest width of 600 dp or more for apps that target API 36, so add the `android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY` property set to `true` in `<application>` ([Android 16](https://developer.android.com/about/versions/16/behavior-changes-16)).
- This lock gets harder to keep over time. The Android opt-out no longer applies once Moci targets API 37 ([Android 17](https://developer.android.com/about/versions/17/changes/ff-restrictions-ignored)), and the remaining exception is only for apps categorized as games through `android:appCategory`. From iOS SDK 27, `UIRequiresFullScreen` also no longer stops an iPad window from being resized ([TN3192](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key)). That is why the scaled display stays in place as a fallback for when the OS ignores the lock.

### Accessibility

- Every picture button has a `Semantics` label in the active language, like `aria-label` in the prototype.
- If the device asks for reduced motion (`MediaQuery.disableAnimations`), decorative animations are turned off. Correct and wrong feedback still appear.
- Text has a contrast of at least 4.5 : 1 against its background.
- On game screens, text size ignores the system font setting so the layout does not break. In the Parents' Area, text follows the system setting up to 1.3 times.

## Performance and size budget

The main targets are a download size under 30 MB and 60 fps animation on the cheapest test device. These budgets are checked on every release, not only at the end.

| Item | Budget | How to check |
| --- | --- | --- |
| Download size per device | Under 30 MB | Size reports in App Store Connect and Play Console |
| Flutter code and engine | At most 12 MB | `flutter build appbundle --analyze-size` and `flutter build ipa --analyze-size` |
| Illustrations (compiled SVG) | At most 4 MB | Content validation script |
| Audio | At most 12 MB | Content validation script |
| Fonts | At most 1 MB | Latin glyph subset only |
| Time to open until the splash moves | Under 1.5 seconds | Measured on the cheapest device, release build |
| Frames | 60 fps with no stutter during tracing and coloring | Flutter DevTools, profile mode |
| Memory | Under 200 MB | DevTools and the built-in Xcode or Android Studio profiler |
| Instrument latency | Under 50 ms | Slow motion video of a tap |

Minimum test devices:

- 1 older iPad still running iPadOS 15 or 16
- 1 iPhone with a small screen
- 1 Android phone with 3 GB of RAM
- 1 Android tablet of 8–10 inches with 2–3 GB of RAM

## Testing, build, and CI

Every pull request runs analysis, tests, and content validation. Every version tag builds the release files for both stores.

### Testing

| Type | What it covers |
| --- | --- |
| Unit | The rules of every game (rounds, scoring, age level), the tracing algorithm, coloring hit-testing, the play timer with a fake clock, data file migration |
| Widget | Every screen renders correctly in both languages and both layouts (tablet and phone) |
| Golden | Home, Great Job, and the Parents' Area compared against reference images |
| Integration | First-run flow (Welcome, Home, one game, Great Job), the Parental Gate, and the time limit |
| Content validation | Every catalog entry has an SVG, a name in two languages, and narration in two languages. SVGs follow the rules, and folder sizes fit the budget. |
| Testing with children | A 15 minute session per child before every big release, matching the success measures in the [PRD](PRD.md) |

### Build and CI

1. Every pull request runs `flutter analyze`, `flutter test`, and `dart run tool/validate_content.dart` on GitHub Actions.
2. Every `v*` tag builds an `appbundle` for Android and an `ipa` for iOS, then uploads them to Play internal testing and TestFlight.
3. An iOS build needs macOS and Xcode. Without a Mac, use a macOS runner on GitHub Actions or a service like Codemagic.
4. Signing keys (the Android keystore and Apple certificates) are kept in GitHub Secrets, never in the repo.
5. The version number comes from `pubspec.yaml`, for example `1.0.0+1` (version and build number).

## Sources

Checked on 14 November 2026.

- [Flutter: Supported deployment platforms](https://docs.flutter.dev/reference/supported-platforms)
- [Flutter: What's new, 3.50 release](https://docs.flutter.dev/release/whats-new)
- [Flutter: Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [flutter\_soloud on pub.dev](https://pub.dev/packages/flutter_soloud)
- [flutter\_svg on pub.dev](https://pub.dev/packages/flutter_svg)
- [Apple TN3192: Migrating your app from the deprecated UIRequiresFullScreen key](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key)
- [Android: App orientation, aspect ratio, and resizability](https://developer.android.com/develop/adaptive-apps/guides/app-orientation-aspect-ratio-resizability)
- [Android 17: Restrictions on orientation and resizability are ignored](https://developer.android.com/about/versions/17/changes/ff-restrictions-ignored)
- [Google Play: Target API level requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [speech\_to\_text on pub.dev](https://pub.dev/packages/speech_to_text)
- [Flutter: SystemChrome.setPreferredOrientations](https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html)
- [Android 16: Behavior changes](https://developer.android.com/about/versions/16/behavior-changes-16)
