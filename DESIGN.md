# Design system in code

This document translates the design system into the code that exists: tokens, components, the tablet and phone stage, motion, sound feedback, accessibility, and how to read a prototype artboard. The full visual rules are in [DESIGN-SYSTEM](docs/DESIGN-SYSTEM.md), and content data is in [CONTENT-ASSETS](docs/CONTENT-ASSETS.md).

## 1. Tokens

### Colors

| Token | Value | Used for |
| --- | --- | --- |
| `MociColors.ink` | `#2B2350` | All text and lines |
| `MociColors.inkSoft` | `#6B5F99` | Secondary text |
| `MociColors.sky` | `#74C4FF` | `ColorScheme` seed color, Home background |
| `MociColors.mociYellow` | `#FFD43B` | Yellow accent |
| `MociColors.correct` | `#26A03B` | Primary button and correct answers |
| `MociColors.correctShadow` | `#1E8A31` | Primary button shadow |
| `MociColors.wrong` | `#E8384F` | Wrong answers |
| `MociColors.logoM` | `#F03E7C` | The letter M in the logo |
| `MociColors.logoO` | `#FF9F1C` | The letter o in the logo |
| `MociColors.logoC` | `#1C8CF0` | The letter c in the logo |
| `MociColors.logoI` | `#26A03B` | The letter i in the logo |
| `MociColors.white` | `#FFFFFF` | Cards and pills |
| `MociColors.starFill` | `#FFC21A` | Star fill |
| `MociColors.starStroke` | `#F08C00` | Star outline |
| `MociColors.neutralShadow` | `rgba(43, 35, 80, 0.12)` | Shadow when there is no menu theme |

`mociTheme()` uses Material 3, the Nunito font family, a transparent background, and `NoSplash.splashFactory`: press feedback comes from `MociPressable`, not a ripple.

### Menu themes

`MenuTheme` sets the full-screen background and the button shadow color. A gradient stops at `stops` when present.

| Theme | Background | Shadow |
| --- | --- | --- |
| `beranda` | gradient `#74C4FF` 0, `#B5E2FF` 0.55, `#DDF3FF` 1 | `#8EC5EE` |
| `sambutan` | gradient `#74C4FF` 0, `#B5E2FF` 0.6, `#DDF3FF` 1 | `#8EC5EE` |
| `huruf`, `ucapkan` | `#FFEDE6` | `#F3C2B3` |
| `berhitung` | `#E7F3FF` | `#B7D7F7` |
| `hewan` | gradient `#BFEBFF` 0, `#E3F7FF` 0.52, `#E3F7FF` 1 | `#9FD3A0` |
| `buahSayur` | `#FFEAF3` | `#F5BCD3` |
| `warna`, `bayangan` | `#F3EEFF` | `#D0BFFF` |
| `bentuk` | `#EEF1FF` | `#C5CEF7` |
| `musik` | `#FFF0F6` | `#F8C4D9` |
| `membaca` | `#FFF1E6` | `#F7C9A5` |
| `mainYuk` | `#E3FAFA` | `#9EDCDD` |
| `cocokkan` | `#FDF0F6` | `#F5BCD3` |
| `memori` | `#EAF2FF` | `#B7D0F7` |
| `puzzle` | `#FFF4E0` | `#F2C57C` |
| `balon` | gradient `#8FD3FF` 0, `#CDEBFF` 0.6, `#EAF6FF` 1 | `#8ECBEE` |
| `besarKecil` | `#EBFBEE` | `#B2F2BB` |
| `mewarnai` | `#FFF8E1` | `#F2D27A` |
| `karyaku` | `#FFF7E0` | `#F2D27A` |
| `hebat` | `#FFE58F` | `#F2C94C` |
| `istirahat` | gradient `#241D4A` 0, `#3E3180` 0.55, `#7C6BD6` 1 | `#1F1846` |
| `gerbang` | `#3B3170` | `#1F1846` |
| `orangTua` | `#F1EEF9` | `#DCD5EE` |

`istirahat` and `gerbang` are marked `dark`, so their text is white and their contrast is tested separately.

### Fonts

Fredoka for titles, numbers, and buttons. Nunito for body and labels. Eight files live in `assets/fonts` and every test loads them through `test/flutter_test_config.dart`.

| Token | Style |
| --- | --- |
| `MociText.title` | Fredoka 700, 46 |
| `MociText.button` | Fredoka 600, 24 |
| `MociText.body` | Nunito 800, 23 |
| `MociText.label` | Nunito 800, 17 |
| `MociText.bigNumber` | Fredoka 700, 240 |

### Sizes

| Token | Value |
| --- | --- |
| `MociSize.backButton` | 76 |
| `MociSize.backRadius` | 26 |
| `MociSize.backShadow` | 7 |
| `MociSize.topPillHeight` | 64 |
| `MociSize.topShadow` | 6 |
| `MociSize.pillHeight` | 50 |
| `MociSize.pillShadow` | 5 |
| `MociSize.menuCardTablet` | 236 × 214 |
| `MociSize.menuCardPhone` | 156 × 142 |
| `MociSize.menuRadiusTablet` | 34 |
| `MociSize.menuRadiusPhone` | 26 |
| `MociSize.menuShadow` | 10 |
| `MociSize.panelRadius` | 44 |
| `MociSize.panelShadow` | 12 |
| `MociSize.minTouchTablet` | 64 |
| `MociSize.minTouchPhone` | 56 |
| `MociSize.targetGap` | 16 |
| `MociSize.edgeTablet` | 32 |
| `MociSize.topBarTop` | 22 |

### Motion

| Token | Value |
| --- | --- |
| `MociMotion.press` | 120 ms |
| `MociMotion.pressDepth` | 5 |
| `MociMotion.pressScale` | 0.97 |
| `MociMotion.popIn` | 450 ms |
| `MociMotion.popCurve` | `Cubic(0.3, 1.6, 0.5, 1)` |
| `MociMotion.shake` | 450 ms |
| `MociMotion.tapCooldown` | 400 ms |

Shadows are always solid with no blur, shift straight down, and take no layout space.

## 2. Shared components

| Component | When it is used |
| --- | --- |
| `MociPressable` | Every visible raised touch target. Default shadow 7, radius 26, drops 5 pt and shrinks to 0.97 while pressed, click sound, and a 400 ms tap cooldown. |
| `MociButton` | Labeled button. Three kinds: `primary` green, `light` white, `accent` orange. Default height 70 and radius half the height. |
| `MociBackButton` | Back button at the top left of every screen. 76 × 76. Without `onTap` it pops the route, or returns to Home when there is no route. |
| `MociTopBar` | Title row above the screen. The 32 edge margin and 22 top gap are already included. |
| `MociIllustration` | SVG from `assets/illustrations/<id>.svg`. `silhouette` colors the whole picture with ink, used by Guess the Shadow. |
| `MociMascot` | The Moci mascot with three poses: `biasa`, `senang`, `tidur`. `biasa` is drawn by a `CustomPainter` and animated; the other two poses use full images that move. |
| `MociDialog` | Dialog above the screen. `rgba(43, 35, 80, 0.55)` scrim, white panel with radius 40, not dismissed by an outside tap or system back. It closes through the button in `actions`. |
| `NumberKeypad` | Gate number pad. Buttons 96 × 84 with a 14 gap, no tap cooldown so two deletes in a row are accepted. |
| `StarCounter` | Star pill and its count. Height 64 on tablet, 48 in `compact` mode for phone. |

### Game components

| Component | API and behavior |
| --- | --- |
| `GameGlyph` | `GameGlyph(kind, size, color)`. Line icons from the artboard: `eye`, `pencil`, `mic`, `count`, `listen`, `play`, `check`, `refresh`, `next`, `star`. |
| `GameModePill` | `GameModePill(tabs, selected, onSelected, semanticLabel, accent)`. White round pill; the active tab has an `accent` background. Without a route it only reports. |
| `RouteModePill` | `RouteModePill(tabs: (label, route, icon), semanticLabel, accent)`. The active tab is read from `currentPathProvider`; switching uses `pushReplacement`, so the back button still goes to Home. |
| `GameInstruction` | `GameInstruction(title, text, semanticLabel, narration, listenLabel)`. Instruction box with a listen button that only appears when there is a narration line. |
| `AnswerCard` | `AnswerCard(state: idle/benar/salah, accent, illustration, text, child, width, height)`. Answer card with a border and a badge that match the state. |
| `ProgressDots` | `ProgressDots(count, current, semanticLabel, dotSize, activeWidth, activeColor)`. Passed dots are green, the active dot is wider. |
| `MicButton` | `MicButton(phase: idle/listening/good/off, onTap, semanticLabel, size)`. 180 pt; two rings pulse while listening and a green check appears on success. `off` disables taps. |
| `RingPulse` | Pulsing ring behind the listen button; it stops under `disableAnimations`. |

### Letter reading mode

`prefs.letterMode` (`LetterMode.fonik` or `LetterMode.nama`) decides what a tap on a capital letter, the previous/next buttons, and "Dengarkan" (Listen) read in Letter Recognition. Both pills, "Bunyi /b/" (Sound /b/) and "Nama: be" (Name: be), are always visible and stay tappable; a pill that does not match the setting is simply not marked active.

### How the parent is called

`prefs.panggilan` (`PanggilanOrtu`) fills `{panggilan}` in the gate sentence, the gate narration, and the microphone dialog title: `ayahBunda` (default, the old Indonesian text), `bapakIbu`, `papiMami`, `daddyMommy`, or `orangTua`. The choice appears as pills in the Parent Area Settings card; the default narration recording still uses the id `gerbangHelpSay`, and the other choices use `gerbangHelpSay_<nama pilihan>`.

### Tracing constants

`lib/features/tulis/tracing_engine.dart` works on samples of 4 units in a 520 × 520 box: finger corridor 44 units, maximum forward jump 40 units, start radius 74 units, and a stroke finishes at 97% of the path length. Progress only moves forward, so backward motion or a far jump is rejected. The board draws one `CustomPainter` inside a `RepaintBoundary`; a moving finger only reports through a `ValueNotifier` instead of rebuilding widgets.

### Say permission flow

1. The first microphone tap opens a "Panggil <panggilan>" (Call <greeting>) dialog that follows `prefs.panggilan`. The "Buka Gerbang" (Open Gate) button pushes `/gerbang`, and only a `true` result calls `SpeechEngine.prepare`. The Gate always comes before the system permission prompt.
2. Permission denied: the screen switches to listen and imitate mode, the microphone button is replaced by a `MociButton` "Dengar dan tiru" (Listen and imitate), words can still be heard, and "Kata berikutnya" (Next word) is always there.
3. Offline recognition unavailable: the screen still tries `listen`; if the answer is `null`, `MicLevelMeter` decides there is sound (0.12 for 300 ms). If the meter is unavailable too, the screen switches to listen and imitate mode. Online recognition is never used.
4. While listening, `AudioService.pauseForListening` stops narration and music; `resumeAfterListening` restores music if its switch is on, and the iOS session returns to the playback category.

### Layout of the five menus

Every screen uses the 1180 × 820 tablet stage, a `MociTopBar` with a back button, and a `GameModePill` when it has two modes.

| Screen | Layout |
| --- | --- |
| Animal World | Large card on the left with illustration, name, facts, a "Dengar suara" (Hear the sound) button, and the five group pills; the right rail holds the 42 animals in two columns |
| Fruits & Vegetables | Recognize: six-column grid of 35 cards. Guess: question bubble with a colored name, three `AnswerCard`s, and `ProgressDots` for six questions |
| Colors | 12 cards per color set: up to four pictures marked with that color and the rest in other colors, plus 11 color chips and the "Gambar baru" (New picture) and "Warna lain" (Other colors) buttons |
| Shapes | Recognize: 640 × 668 card on the left with 48 pt corner marks and a two-column grid on the right. Find: 1100 × 92 question bar, 1100 × 548 board, options of 3/4/6 choices with a 56 pt check badge |
| Music Play | Xylophone: 1100 × 88 song bar, 1100 × 562 board with two rails and eight 100 pt bars. Drums: four 240 × 300 pads, a 72 pt "Mainkan irama" (Play the rhythm) button, and hint text |

Age level rules for Shapes: 2–3 years 5 shapes and 3 choices, 4–5 years 8 shapes and 4 choices, 6–7 years 10 shapes and 6 choices. The number of choices always includes the target and never exceeds the pool.

Only Shapes Find ends: six rounds, then `finishGame(gameId: 'bentuk', …)` and the Great screen. Fruits Guess, Colors, and Music Play loop without end. Music Play gives no reward; after a song finishes it shows the pill "Hebat! Kamu memainkan satu lagu!" ("Great! You played one song!") for 3.5 seconds, then returns to the free state.

## 3. Tablet and phone stage

`MociStage` paints the theme background full screen, then places base-size content in the safe area, scaled proportionally and centered. The remaining space is filled by the background.

| Item | Value |
| --- | --- |
| Tablet base | 1180 × 820 (`kTabletBase`) |
| Phone base | 844 × 390 (`kPhoneBase`) |
| Threshold | `layoutKindFor`: tablet when the screen's shortest side ≥ 600 dp |
| Scale | `fitStage`: `min(available width / base width, available height / base height)` |

Stage content receives a `MediaQuery` with the base size, zero padding, and a text scaler that follows `textScaleCap`. Game screens use the default 1.0, meaning text ignores the system setting. The Parent Area uses 1.3.

Rule D12: a screen without a phone design shows the tablet design scaled down. `MociStage` only uses the `phone` builder when the screen provides it; otherwise it uses the `tablet` builder and prints one debug message. Only Splash and Home have a phone layout. Adding a phone layout means filling in `phone:` and using `context.layoutKind`.

## 4. Motion and reduced motion

- Press: drops 5 pt, scale 0.97, 120 ms, plus a click sound.
- Appear: grows with a bounce for 450 ms on the `Cubic(0.3, 1.6, 0.5, 1)` curve.
- Wrong answer: shakes for 450 ms and flashes red.
- Idle mascot: one loop of about 2.6 seconds.

When `MediaQuery.disableAnimations` is on, decorative animation stops: mascot, Splash, Home sky, Rest scene, and star blinking. Correct and wrong feedback still appears, but without the bounce, and touch targets stay tappable. This check lives in `lib/widgets/moci_mascot.dart`, `lib/features/istirahat/istirahat_scene.dart`, `lib/features/orang_tua/gerbang_screen.dart`, and `lib/features/hadiah/hebat_screen.dart`.

## 5. Sound feedback

- Every `MociPressable` plays `Sfx.klik` unless it is turned off with `clickSound: false`.
- Effect names: `klik`, `benar`, `salahLembut`, `sorak`, `bintang`. Failure sounds are always soft, never a buzzer.
- Priority from `AudioService`: narration above effects, effects above music. Volumes 1.0; 0.7; 0.25, and music drops to 0.10 while narration plays.
- Sound stops when the app goes to the background. The effect and music files are not in the repo yet; playback is checked against `AssetCatalog`, so a missing asset never raises an error.

## 6. Accessibility

- Touch targets at least 64 pt on tablet and 56 pt on phone, at least 16 pt between targets, 32 pt edge margin on tablet.
- Text contrast at least 4.5 : 1. `test/app/theme/contrast_test.dart` checks ink on every light background, soft ink on white, and white text on dark screens.
- Game text ignores the system setting; the Parent Area follows it up to 1.3 times.
- Every target has a semantic label from the ARB files. An image without `semanticLabel` is dropped from the semantics tree, so a screen reader does not read out file names. `NumberKeypad` labels delete and removes its icon from semantics.
- Sound first, text second: every important instruction is read by `Narrator`, and the on-screen text stays as a companion.

## 7. Reading a prototype artboard

The snapshot is in `docs/design/prototype/`: 40 `*.dc.html` artboards and `canvas.json`. This snapshot is frozen; do not edit it.

1. Open the matching artboard, for example `Main.dc.html` for Home or `Gate.dc.html` for Gate.
2. Text comes from the `T` objects in the artboard script. Copy it exactly into the ARB files, in ID and EN, with the key `<layar><KunciT>`.
3. Background and shadow colors are matched to `MenuTheme`. If a value is missing, add an enum value; do not write a raw color in the screen.
4. Sizes and gaps come from the element styles in the artboard, then are compared with `MociSize`. A number that repeats becomes a token.
5. Content data, not layout, comes from the `data()` function in the artboard. Its export result is already in `assets/content/`, and that JSON catalog is the source of truth for content.

## 8. Design decisions

| Code | Decision | Reason |
| --- | --- | --- |
| D1 | Material is imported from `material_ui`. | Flutter 3.50 deprecates `package:flutter/material.dart` ([breaking change](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui)). |
| D2 | Additional first-party packages: `material_ui`, `path_provider` (app folder), `url_launcher` (links behind the gate), `flutter_localizations`, `intl`. SVG is rendered with `vector_graphics`, without `flutter_svg`. | Required by the spec but missing from the package table. |
| D3 | Bundle id and application id `id.pandudpn.moci`. | Not in the spec yet. Change it before the first upload if needed. |
| D4 | Welcome appears once (the `moci.sambutanSelesai` flag). The default language follows the device. | As in the spec. The prototype always shows Welcome and always uses `id`. |
| D5 | Recorded narration never says the child's name. A sentence that contains the name is read in a variant without the name, while the on-screen text keeps the name. | A free-form name cannot be recorded, and TTS is not used in the release. |
| D6 | The "Lanjutkan" (Continue) card is hidden until there is a last activity. | The prototype is static ("Tulis huruf A"). |
| D7 | Menus open with `push`, so system back = the back button. Home, Splash, Welcome, Rest, and Time's Up ignore system back. | Spec: system back behaves like the back button. Home has no back button. |
| D8 | Rest opens above the active screen, so game state stays. Every step is read aloud, and the app returns automatically after 20 seconds. The "Lanjut main" (Keep playing) button from the prototype is not used. | Spec: return after 20 seconds. The "sound first" principle. |
| D9 | The Gate opens with a random question and an empty input. The narration "Ini khusus orang tua. Panggil Ayah atau Bunda, ya!" ("This is for parents only. Call Dad or Mom, okay!") plays when the gate opens. "Batal" (Cancel) returns to the opening screen. Number buttons 96 × 84, radius 24 (prototype size). | The spec asks for narration when the gate opens; the text comes from the prototype. The 88 pt number in the document is the lock tile size, not the number button. |
| D10 | The reward is given when the game ends, not at "Ambil hadiah" (Take the reward). In Great, "Main lagi" (Play again) returns to that game and "Lanjut" (Continue) goes to Home. A 30-sticker catalog (6 per theme). A new sticker is picked at random from the ones not owned yet; if all are owned, the child only gets stars. | The prototype has no sticker catalog ("8 / 30"), and "Main lagi" in the prototype always goes to the hub. |
| D11 | Parent Area: (a) the name is changed through a dialog in the Parent Area, not by opening Welcome; (b) "Minggu ini" (This week) = the number of distinct items opened in the last 7 days per module, divided by the module's total content; (c) suggestion = the module with the lowest coverage, with new text that needs review; (d) "Hapus semua data" (Delete all data) is in the bottom badge row, uses a two-step dialog, and deletes all settings and files. | The prototype uses fake numbers and has no "Hapus semua data". |
| D12 | Screens without a phone design (all except Splash and Home) temporarily show the tablet design scaled down on phone. | PRD: phone screens are designed before they are built (Plan 08). |
| D13 | The "Untuk orang tua" (For parents) pill exists only on Time's Up, not on Rest. | So rest cannot be skipped. |
| D14 | Play time is counted on Home, all menus, and Great. It is not counted on Splash, Welcome, Gate, Parent Area, Rest, and Time's Up. | Spec plus prototype behavior. |
