> Copy of the Claude Docs "Moci Documentation", Design System tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci Design System

Moci's design system comes straight from the prototype: a different soft background for each menu, dark purple text, rounded letters, and thick buttons with solid shadows that feel like a toy. Every value here becomes a token in the Flutter theme (`lib/app/theme`).

## Colors

### Core colors

| Role | Hex | Used for |
| --- | --- | --- |
| Ink | `#2B2350` | All primary text and line icons |
| Soft ink | `#6B5F99` | Supporting text and small labels |
| Moci yellow | `#FFD43B` | Mascot body, stars, highlights |
| Sky blue | `#74C4FF` | App icon background and the Home sky |
| Correct | `#26A03B`, shadow `#1E8A31` | Correct feedback and the next button |
| Wrong | `#E8384F` | The wrong marker that appears for a moment |
| Logo letters | `#F03E7C`, `#FF9F1C`, `#1C8CF0`, `#26A03B` | The M-o-c-i letters and decorative accents |
| White | `#FFFFFF` | Cards and buttons |

### Background per menu

Every menu has one soft background. Button shadows in that menu use a darker version of the same color, for example `#F3C2B3` in Letters (Kenal Huruf).

| Screen | Background |
| --- | --- |
| Home (Beranda) | Gradient `#74C4FF` to `#B5E2FF` to `#DDF3FF` |
| Welcome (Sambutan) | `#DDF3FF` |
| Letters (Kenal Huruf) and Say It (Ucapkan) | `#FFEDE6` |
| Counting (Berhitung) | `#E7F3FF` |
| Animal World (Dunia Hewan) | Gradient `#BFEBFF` to `#E3F7FF` |
| Fruits & Vegetables (Buah & Sayur) | `#FFEAF3` |
| Colors (Warna) | `#F3EEFF` |
| Shapes (Bentuk) | `#EEF1FF` |
| Music Play (Main Musik) | `#FFF0F6` |
| Let's Read (Ayo Membaca) | `#FFF1E6` |
| Let's Play (Main Yuk!) | `#E3FAFA` with a dot pattern |
| Picture Match (Cocokkan Gambar) | `#FDF0F6` |
| Memory Cards (Kartu Memori) | `#EAF2FF` |
| Guess the Shadow (Tebak Bayangan) | `#F3F0FF` |
| Puzzle | `#FFF4E0` |
| Letter Balloons (Balon Huruf) | Gradient `#8FD3FF` to `#EAF6FF` |
| Big & Small (Besar & Kecil) | `#EBFBEE` |
| Coloring (Mewarnai) and Gallery (Galeri) | `#FFF8E1` |
| My Artwork (Karyaku) | `#FFF7E0` |
| Great Job (Hebat) | `#FFE58F` |
| Break (Istirahat) | Night gradient `#241D4A` to `#7C6BD6` |
| Parental Gate (Gerbang Orang Tua) | `#3B3170` |
| Parents' Area (Area Orang Tua) | `#F1EEF9` |

Color is never the only marker. Correct and wrong answers always have sound and motion too.

## Typography

Moci uses two fonts under the SIL Open Font License 1.1: Fredoka for headings and big letters, and Nunito for body text. Fredoka uses single storey a and g shapes, which resemble a child's handwriting, so it suits Letters.

The sizes below are in pt (Flutter logical pixels) at the tablet base size of 1180 × 820, the same as px in the prototype. The phone layout has its own scale, with the phone Home as the reference.

| Role | Font | Size |
| --- | --- | --- |
| Screen title | Fredoka 700 | 44–46 |
| Big numbers in Counting | Fredoka 700 | 200–240 |
| Primary button text | Fredoka 600–700 | 24–30 |
| Body text | Nunito 700–800 | 22–24 |
| Small labels | Nunito 800 | 15–18 |

Rules:

- Fonts are bundled in `assets/fonts` and are not downloaded while the app runs. Do not use the `google_fonts` package in download mode.
- Only the Latin glyph subset is bundled, so the font size stays under 1 MB.
- Text below 18 pt is only used for labels that are also read aloud, or that do not matter to the child.

## Touch sizes, spacing, corners, and shadows

The minimum touch target is 64 pt on tablet and 56 pt on phone. That is well above the usual 44 pt limit, because small children's fingers do not aim precisely yet.

| Element | Tablet size (pt) | Corner (pt) | Shadow |
| --- | --- | --- | --- |
| Back button | 76 × 76 | 26 | Down 7 pt |
| Home menu card | 236 × 214 (phone: 156 × 142) | 34 (phone: 26) | Down 10–12 pt |
| Small button in the top bar | 62 × 62 | 18 | Down 6 pt |
| Gate number pad button | 88 × 88 | 28 | Down 6 pt |
| Mode and level pill | Height 50 | Full | Down 5 pt |
| Crayon | Touch area 96 tall | None | The selected crayon lifts slightly |
| Large content panel | Follows the screen | 40–44 | Down 12 pt |

Rules:

- Shadows are always solid with no blur, offset straight down. The color is a darker version of the element color or the menu background.
- When pressed, a button drops 5 pt and shrinks to 97% for 120 ms, as if the shadow were pressed.
- Spacing between touch targets is at least 16 pt. Screen edge margin is 32 pt on tablet.
- Corners are rounded everywhere. There are no sharp corners, except on the shapes actually taught in the Shapes menu.

## Main components

These eleven components are reused across every menu and live as shared widgets in `lib/widgets`. New screens should be assembled from these components first before making new ones.

| Component | Contents | Behavior |
| --- | --- | --- |
| Primary button | Rounded box, Fredoka text, solid shadow | Drops 5 pt when pressed and plays a soft click. Picture buttons read their label aloud. |
| Back button | White 76 pt box with an arrow | Always top left, goes back one screen |
| Menu card | Large picture, name, and a short subtitle | Moci says the menu name, then the menu opens |
| Mode and level pill | A row of pill shaped choices | The active choice is marked with color and read aloud |
| Moci mascot | SVG in a normal pose and a happy pose | Peeking and swaying gently. Says hello when tapped. |
| Instruction box | A short sentence and a Listen button | Read aloud automatically when the screen opens, and can be repeated |
| Microphone button | Large circle with a microphone icon, only in Say It | Pulses while listening, at most 4 seconds. Turns green when the speech matches. |
| Answer card | Large white card holding a picture | Correct: grows, turns green, and makes a sound. Wrong: shakes and flashes red. |
| Progress marker | Dots along the top | The active dot stretches. Finished dots turn green. |
| Dialog | Panel in the middle over a dimmed background | Used for artwork details and the two step delete confirmation |
| Number pad | 88 pt number buttons | Only in the Parental Gate |

## Tablet and phone layout

Every screen has two base designs, tablet 1180 × 820 pt and phone 844 × 390 pt, both landscape. The other screens scale proportionally from one of them, and leftover space is filled with the menu background color.

Tablet pattern, taken from the prototype:

- The top bar holds the back button on the left, the screen title, then the mode or level pill on the right.
- The content area sits below the top bar, with a 32 pt edge margin.
- The instruction box and Listen button are always in the same position within a menu.

Phone pattern:

- Only Home has a phone design so far. The other screens follow its pattern: a thinner top bar, 156 × 142 pt menu cards, and 62 pt small buttons.
- Safe areas on the left and right (notch, Dynamic Island, punch hole camera) are always kept clear.
- At most 4 answer cards per row, so they stay easy to touch.

Examples of how it adjusts at other sizes:

| Screen | Ratio | Result |
| --- | --- | --- |
| iPad 11 inch (1180 × 820) | 1.44 | Fits the base design |
| iPad 4:3 (1024 × 768, 1366 × 1024) | 1.33 | A thin strip of leftover space at the top and bottom |
| Android tablet 16:10 (1280 × 800) | 1.60 | Leftover space on the left and right |
| Portrait position on a tablet | Below 1 | Does not happen, because orientation is locked to landscape. If the OS ignores the lock, the landscape layout is scaled down. |

## Animation and feedback sound

Motion in Moci is short and bouncy. Every tap is answered within 100 ms with motion, sound, or both, so the child knows the touch registered.

| Event | Motion | Sound |
| --- | --- | --- |
| Button pressed | Drops 5 pt and shrinks to 97%, 120 ms | Soft click |
| Element appears | Grows with a bounce, 400–550 ms, curve `cubic-bezier(.3, 1.6, .5, 1)` | None |
| Correct answer | Card grows with a green outline, Moci is happy | "Betul!" ("Right!") plus the object name, then a chime |
| Wrong answer | Card shakes for 450 ms and flashes red | "Bukan yang itu. Coba lagi!" ("Not that one. Try again!") in a gentle tone |
| Game finished | Great Job screen: stars appear one by one, then the new sticker | "Hebat!" ("Great!") and a short cheer |
| Mascot idle | Peeking and swaying gently, one cycle every 2.4–3 seconds | None |
| Splash | Moci falls and bounces, the M-o-c-i letters appear 0.1 seconds apart | None |

Rules:

- There is no loud, sad, or buzzer-like failure sound.
- Sound effects last at most 0.6 seconds, so they do not pile up under the narration.
- If the device asks for reduced motion, every decorative animation (peeking, swaying, clouds, twinkling stars) is turned off. Correct and wrong feedback still appear, but without the bounce.
