> Copy of the Claude Docs "Moci Documentation", PRD tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci PRD

Moci v1 has 10 menus on Home (Beranda), including 6 mini games in Let's Play (Main Yuk!), plus a Parents' Area (Area Orang Tua). Everything runs offline in Indonesian and English, on tablets and phones.

## v1 goals

1. Children aged 2–7 learn letters, numbers, early reading, and the world around them by playing, without needing to read instructions.
2. Parents feel at ease. There are no ads, purchases, outbound links, or data sent off the device, and play time can be limited.
3. The app stays light and smooth on iPad, iPhone, and low to mid range Android phones and tablets.

## Success measures

Moci uses no analytics. v1 success is measured through direct testing with children, the built-in reports in App Store Connect and Play Console, and store reviews.

| Measure | v1 target | How to measure |
| --- | --- | --- |
| Child plays alone | Every test child finishes one game unaided | 15 minute test session per child, at least one child per age level |
| No stuck points | No screen where a child is confused for more than 30 seconds | Observation during test sessions |
| Stable | At least 99.5% of sessions without a crash | Xcode Organizer and Android vitals, no extra SDK |
| Light | Download size under 30 MB, 60 fps animation on the cheapest test device | Size reports in App Store Connect and Play Console, Flutter DevTools |
| Parents trust it | Average rating of at least 4.5 | App Store and Play Store reviews |

## Users

Moci has two users: the child who plays and the parent who sets things up. The parent picks the child's age the first time the app opens, and that age level sets the difficulty of every game.

| User | Situation | Needs | What Moci provides |
| --- | --- | --- | --- |
| Child aged 2–3 (Beginner level) | Cannot read yet, finger movement still coarse, gets bored quickly | Spoken instructions, big buttons, few choices | 3 answer choices, 4 piece puzzles, 5 basic shapes, Letter Balloons (Balon Huruf) with 9 letters |
| Child aged 4–5 (Explorer level) | Starting to know letters and numbers, enjoys small challenges | Varied questions, clear feedback | 6 piece puzzles, 8 shapes, Letter Balloons with 23 letters |
| Child aged 6–7 (Reader level) | Starting to read syllables and short sentences | Reading challenges, more choices | 9 piece puzzles, 10 shapes, 4 choices in Guess the Shadow (Tebak Bayangan) and Big & Small (Besar & Kecil) |
| Parent | Wants a safe app, wants to follow the child's progress, wants to limit screen time | Controls the child cannot open, a summary that reads fast | Parental Gate (Gerbang Orang Tua), Parents' Area, daily time limit, break reminders |

## Product principles

These eight principles apply to every screen. If a new feature breaks one of them, the feature has to be designed again.

1. **Sound first, text second.** Every instruction is read aloud, and every picture can be tapped to be heard. A child does not need to read to play.
2. **Mistakes are not punished.** A wrong answer gets a gentle voice and an invitation to try again. There are no lives, countdowns, or scores that go down.
3. **Simple gestures.** One finger tap or one finger drag is enough. No double taps, long presses, or two finger gestures.
4. **Always a way back.** The back button is always in the top left corner, with the same size and position on every screen.
5. **Grown-up matters behind a gate.** Settings, outbound links, data deletion, and microphone permission requests only open through the Parental Gate.
6. **Offline, with no data going out.** All content ships with the app. The app needs no internet and sends no data.
7. **Two equal languages.** All text and voice are available in Indonesian and English, and can be switched at any time.
8. **Difficulty follows age.** The number of choices, pieces, and letters follows the age level in the child's profile.

## App flow

![v1 app flow: 11 screens, 1 branch](images/alur-aplikasi.png)

Children always return to Home. Settings and the Time's Up (Waktu Habis) screen can only be reached through the Parental Gate, while the break screen returns to the game after 20 seconds.

## Features per menu

Every mechanic in this table already exists in the prototype. The last column holds the specific requirement before that menu counts as release ready.

| Menu | How to play | Adapts to age | Release ready requirement |
| --- | --- | --- | --- |
| Letters (Kenal Huruf) | 26 letters A–Z with a picture and a sample word. Tap to hear the letter sound (phonics) or the letter name, depending on the parent setting. | No | All 26 letters have a picture, a sample word, and sound and name narration in both languages |
| Letter Tracing (Tulis Huruf) | The child drags Moci along the yellow arrows, stroke by stroke, until the star. | No | All 26 letters have a stroke path with the correct order and direction |
| Say It (Ucapkan) | Hear a sample word split into syllables, then the child says it into the microphone and Moci listens. | No | On-device speech recognition for every Say It word in both languages (details below the table) |
| Counting (Berhitung) | Numbers 1–50 in 5 ranges. "Hitung bareng" ("Count along") counts objects one by one, or the child taps objects to count them alone. | Child picks the range | Number narration 1–50 in both languages |
| Number Tracing (Tulis Angka) | Tracing numbers 0–9 with the same guidance as letters. | No | All 10 numbers have a correct stroke path |
| Animal World (Dunia Hewan) | 42 animals in 5 groups, with buttons to hear the name, hear the sound, and a "Tahukah kamu?" ("Did you know?") fact. | No | Licensed real sounds for 42 animals |
| Fruits & Vegetables (Buah & Sayur) | 21 fruits and 14 vegetables. Recognize mode to learn the names, Guess mode with 3 picture choices. | No | 35 pictures with name narration in both languages |
| Colors (Warna) | "Sentuh semua yang berwarna merah!" ("Touch everything red!") A counter shows how many have been found. | No | 11 colors, and 81 pictures already tagged with their color |
| Shapes (Bentuk) | 10 shapes with faces. Recognize mode counts corners and sides. Find mode has 6 rounds with shuffled colors. | 2–3: 5 shapes, 3 choices. 4–5: 8 shapes, 4 choices. 6–7: 10 shapes, 6 choices | Narration of the name, corner count, and side count for 10 shapes |
| Music Play (Main Musik) | An 8 note xylophone with Listen and Follow modes for 2 songs. A drum with 4 sounds and sample rhythms. | No | Sound comes out less than 50 ms after a touch |
| Syllables (Suku Kata) | Pick a consonant to build ba-bi-bu-be-bo, tap to hear it, then see a sample word. | No | Narration for 90 syllables (18 consonants × 5 vowels) |
| Word Builder (Susun Kata) | Hear a word, then tap its syllables in order. | Level of 2 or 3 syllables | 71 Indonesian words and 33 English words with narration per syllable |
| Sentences (Kalimat) | "Baca bersama" ("Read together") lights up one word at a time like karaoke. There is also a picture guess mode with 3 choices. | No | 18 sentences with narration aligned per word |
| Picture Match (Cocokkan Gambar) | Connect matching pictures by tapping both of them or by dragging a line. | 3 to 5 pairs, with theme choices | The line follows the finger without stalling |
| Memory Cards (Kartu Memori) | Turn over two cards and find the pair. The number of moves is recorded. | 4, 6, or 8 pairs | At most two cards open at the same time |
| Guess the Shadow (Tebak Bayangan) | "Bayangan siapa ini?" ("Whose shadow is this?") Pick the matching picture, then the shadow fills with color. 6 rounds. | 3 choices, or 4 for ages 6–7 | Shadows are made from the same picture, with no extra files |
| Puzzle | Tap a piece, then tap where it goes. | 4, 6, or 9 pieces | Pieces are cut from illustrations that already exist |
| Letter Balloons (Balon Huruf) | Moci says a letter, then the child pops the matching balloon. 5 rounds. | 9 letters for ages 2–3, 23 letters for other ages | Balloons are big enough for a 2 year old's finger |
| Big & Small (Besar & Kecil) | "Mana yang paling besar?" ("Which is biggest?") and "paling kecil?" ("which is smallest?") alternate. 6 rounds. | 3 sizes, or 4 for ages 6–7 | The size difference is easy to tell apart |
| Coloring (Mewarnai) | 14 pictures (6 animals, 8 objects and nature). Color cannot leave the lines. There are 3 brush sizes, fill, erase, stickers, undo, start over, save, and 16 crayons. | No | Artwork is saved on exit and can be continued; My Artwork (Karyaku) keeps the last 12 pieces |

**Say It in v1 uses the microphone.** Microphone permission is requested through a parent the first time this menu opens. The child's voice is recognized right on the device, is not stored, and is not sent anywhere. If the pronunciation matches, Moci praises. If not, Moci plays the sample again and invites another try, at most twice, then still praises the effort. If the device cannot recognize speech offline in that language, Moci only checks that the child has spoken. If permission is denied, Say It stays playable without the microphone.

Requirements that apply to every menu:

- Runs without internet.
- All text and narration available in both languages.
- Has a tablet layout and a phone layout. A phone design currently exists only for Home, so the other screens get designed before they are built.
- Games with an ending (Find mode in Shapes and the 6 mini games) close with the Great Job (Hebat) screen.

## Supporting features

These features keep the child safe and give the parent control. All of them exist in the prototype, except Delete all data (Hapus semua data), which is new for v1.

| Feature | How it works |
| --- | --- |
| Welcome (Sambutan) | Appears once when the app first opens. The parent picks the language, fills in the child's nickname, and picks the age. If the name is left empty, the child is greeted as "Adik" (little one). |
| Splash | Moci falls and bounces, the letters M-o-c-i appear one at a time, then the app moves on by itself after 3.6 seconds. One tap skips it. |
| Home | The greeting "Hai, nama anak!" ("Hi, child's name!"), 10 menus, a Continue (Lanjutkan) button to the last activity, the star count, the ID/EN language switch, and the door to the Parents' Area. |
| Rewards | Every finished game gives 3 stars and one new sticker for the Sticker Album (Album stiker). |
| Daily time limit | Options of 15, 30, or 45 minutes, or no limit. The default is 30 minutes. The count resets every midnight in device time. When it runs out, the Time's Up screen appears and only a parent can open it. |
| Break reminder | If enabled, it appears every 20 minutes of play. The 20 second break screen invites the child to look far out the window, blink 10 times, and stretch their arms. |
| Parental Gate | A multiplication question (first number 6–9, second number 3–9) answered on a number pad. This gate protects settings, every outbound link, and microphone permission requests. |
| Parents' Area | Child profile (name and age level), today's summary (play time, stars, stickers, artwork), this week's progress with practice suggestions, and settings: language, how letters are read, time limit, background music, sound effects, and break reminder. |
| Delete all data | New for v1. A button in the Parents' Area that deletes the name, progress, and artwork, then opens Welcome again. |

## Out of scope for v1

The following are deliberately left out of v1, so the first release stays small and can be finished.

- Accounts, login, cross-device sync, and cloud backup.
- More than one child profile per device.
- Ads, in-app purchases, and subscriptions.
- Extra content downloaded from the internet.
- Portrait orientation. Every screen is locked to landscape (details in [Technical Specification](TECH-SPEC.md)).
- Languages other than Indonesian and English.
- A web version.

The strongest candidate for a version after v1 is a second profile for siblings.
