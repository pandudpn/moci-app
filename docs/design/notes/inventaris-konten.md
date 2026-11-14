# Moci prototype — content data inventory (konten)

Source: 40 artboards in `/Users/pandudpn/apps/flutter/moci-app/docs/design/prototype/*.dc.html` (+ `canvas.json`), canvas `https://claude.ai/artifact/SaDuEPgwdFp5WSfoAhvum8`.
The local `.dc.html` copies are byte-identical to the canvas project files already saved in the session scratchpad (`scratchpad/artifact-files/cf17f60d-9ec5-4e35-bfde-7448dd076e37/project/`, `diff -rq` clean).
All line numbers below are 1-based line numbers in those local files. Scripts used: `(skrip sementara) ` (`jsl.py` literal parser, `extract.py`, `samples.py`, `blobrefs.py`, `master.py`, `mastermd.py`, `svgcheck.py`). Extracted JSON copies of every dataset are in `(data sementara) `.

Abbreviations used in tables: Bay=Bayangan, BK=BesarKecil, Coc=Cocokkan, Mem=Memori, Puz=Puzzle, Kal=Kalimat, Hew=Hewan, Bua=Buah, Ang=Angka, War=Warna, Hur=Huruf, Kat=Kata, Suk=SukuKata, Gal=Galeri, Mew=Mewarnai, Kar=Karyaku, Ben=Bentuk, Uca=Ucapkan, Heb=Hebat, Per=Permainan, OT=OrangTua. **THEMES×6** = the identical theme dictionary embedded in Bay, BK, Coc, Mem, Puz and Kal.

---

## 1. Asset snapshot

| item | value |
|---|---|
| Listing | `Artifact list scope=assets`, 4 pages (50 + 50 + 50 + 22) = **172 files**, header "172 files, 549494 … bytes used" |
| Content types | 172 × `image/svg+xml` (no PNG/JPG) |
| Download | `Artifact read` with `paths:[…]` is **refused for assets** ("no file is published at that path"); each asset was fetched with a single `path:<id>` read (172 calls) |
| Copied to | `/Users/pandudpn/apps/flutter/moci-app/docs/design/prototype/assets/<id>.svg` (byte-for-byte `cp -p`) |
| Verification | file count **172** = listing total; total **549,494 bytes** = listing total; sha256 of every file = sha256 in the listing (**172/172 match**); sizes match |
| Nothing else written to the repo | correct (only `docs/design/prototype/assets/`) |

Asset classes (by viewBox + usage):

| class | files | bytes | notes |
|---|---|---|---|
| content illustrations, viewBox `0 0 200 200` | 107 | 150,761 | exactly the set of blobs referenced by content datasets (see §3) |
| coloring-page thumbnails, `0 0 800 600` | 14 | 64,648 | line art, picker thumbnails (Galeri / Mewarnai `t`) |
| coloring outlines, `0 0 600 600`, **unreferenced** | 6 | 7,975 | early uncolored drafts (see §4) |
| mascot / UI, `0 0 240 240` ×2 + `0 0 600 600` ×1 | 3 | 6,598 | Moci, Moci senang, colored butterfly scene (Mewarnai/Karyaku icon) |
| brand (icons A/B/C ×8, logos, wordmarks, mono mascots, GitHub) | 42 | 319,512 | used only by Brand*/Splash* boards |
| **total** | **172** | **549,494** | |

Full per-asset catalogue: Appendix A.

---

## 2. Dataset inventory

### 2.1 Summary table

| # | dataset | file:lines (function / var) | schema (field order) | count |
|---|---|---|---|---|
| 1 | Letters (Huruf) | Huruf.dc.html:148-185 `data(lang)` — `img` map 150-161, EN list 162-170, ID list 170-178 | row `[letter, exampleWord, imgKey, ttsSound, /sound/, letterName]`; `img` = `{imgKey: blobId}` | 26 ID rows + 26 EN rows; 38 img keys |
| 2 | Number words | Angka.dc.html:151-164 `word(n,en)` (EN table L153, ID table L158) + `plural()` 165-168 | generated strings 0–59 | 20 EN units, 10 ID units |
| 3 | Count objects | Angka.dc.html:147-150 `pool()` (literal L148) | `[id, nameID, nameEN, blobId]`; object for n = `pool[(n-1)%12]`; ranges L225 `[[1,10]…[41,50]]` | 12 objects, numbers 1–50 |
| 4 | Animals | Hewan.dc.html:170-173 `data()` (L171) | `[id, nameID, nameEN, blobId, group, soundID, soundEN, factID, factEN]` | 42 (rumah 10, liar 13, reptil 5, air 7, kecil 7) |
| 5 | Fruit & veg | Buah.dc.html:168-171 `data()` (L169) | `[id, nameID, nameEN, blobId, cat(buah\|sayur)]` | 35 (21 + 14) |
| 6 | Colors | Warna.dc.html:155-169 `colors()` (rows 157-167) | `[id, nameID, nameEN, hex, labelTextColor, darkLine]` | 11 |
| 7 | Color-tagged pictures | Warna.dc.html:151-154 `pics()` (L152) | `[id, nameID, nameEN, blobId, colorId]` | 81 |
| 8 | Shapes | Bentuk.dc.html:188-202 `shapes()` (rows 191-200; schema comment L189); age pools `pool()` 203-208 | `[id, nameID, nameEN, colour, darker, path200, faceX, faceY, faceScale, corners[[x,y]…], kind(poly\|round\|love\|star), factID, factEN]` | 10 |
| 9 | Syllables + examples | SukuKata.dc.html:136-139 `data()` (L137); consonants L147, vowels L150, vowel colours L149 | grid = `'bcdfghjklmnprstwyz'` × `['a','i','u','e','o']`; examples `{lang:{syllable:[id, word, blobId]}}` | 90 syllables; 41 ID + 41 EN examples |
| 10 | Susun Kata words | Kata.dc.html:147-150 `words()` (L148) | `{id:[…], en:[…]}`, row `[id, word, [syllables], blobId]` | 71 ID (52×2, 19×3 syll.) + 33 EN (22×2, 11×3) |
| 11 | Sentences | Kalimat.dc.html:146-149 `data()` (L147); read-along timing 209-226 | `[id, sentenceID, sentenceEN, blobId]` | 18 |
| 12 | Say-it words | Ucapkan.dc.html:174-189 `words(lang)` (EN 177-181, ID 183-187) | `{w, syl:[UPPER syllables], img: '/_blob/'+id}` | 5 ID + 5 EN |
| 13 | Tracing guides | Tulis.dc.html:274-313 `guides()` (276-311); `keys()` L314; sampler `samp()` 315-347 | `{glyph: [svgPathStroke1, stroke2, …]}` in a 520×520 box | 36 glyphs (A–Z, 0–9), 63 strokes |
| 14 | Coloring pages (full) | Mewarnai.dc.html:179-182 `pagesData()` (L180) | page `{id, n:[ID,EN], c, r:[region…], demo:{regionIdx:hex}, ds:[[regionIdx, hex, width, path]], t:'/_blob/thumb'}`; region `{d, e?, x?:[[path, fill\|'', strokeW]]}` | 14 pages, 294 regions, 147 details |
| 15 | Coloring pages (copy) + demo artworks | Karyaku.dc.html:140-143 `data()` (L141) | `{pages:[{id,n,r}], demo:[{id,pid,fills,strokes,stk}]}` | 14 pages (regions identical to #14) + 4 demo artworks |
| 16 | Coloring gallery list | Galeri.dc.html:106-121 `var P`; NEW badges L129; Karyaku card L145 | `[id, nameID, nameEN, cat(hewan\|benda), thumbBlobId]` | 14 (+1 Karyaku card) |
| 17 | Stickers (coloring) | Mewarnai.dc.html:244-251 `stickerList()`; Karyaku.dc.html:149-152 `stickerList()` | Mew `['/_blob/id', nameID, nameEN]`; Kar `'/_blob/id'` (same 8, same order) | 8 (no sticker ids) |
| 18 | Reward sticker / album | Hebat.dc.html:206-208 `T` (stickerName), template L107 + L132-136 | static: new sticker 'Apel Merah'/'Red Apple', album "8 / 30", 4 sticker images | 4 images shown |
| 19 | Crayon palette (coloring) | Mewarnai.dc.html:335-340 `var pal` | `[hex, nameID, nameEN]` | 16 |
| 20 | Game themes | THEMES×6: Bayangan.dc.html:130-138 `items()` (P L132), BesarKecil.dc.html:121-129 (P L123), Cocokkan.dc.html:164-167 `pool()` (L165), Memori.dc.html:126-129 `pool()` (L127), Puzzle.dc.html:120-128 `items()` (P L122), Kalimat.dc.html:150-153 `pool()` (L151) | `{theme:[[id, nameID, nameEN, blobId]…]}` | 5 themes: buah 21, sayur 14, hewan 42, kendaraan 9, benda 17 = 103 (identical in all 6 files) |
| 21 | Theme labels / colours | Cocokkan.dc.html:255 `themeNames`, L338 `themesList`, L180 `cats`; Memori.dc.html:170 `names`, L174 `backC` | label maps ID/EN; card-back colours per theme | 7 keys (acak, campur, 5 themes) |
| 22 | Xylophone | Musik.dc.html:168-187 `tone(i)` (freqs L171), L251 `SOL`, L252 `COL` | 8 freqs (Hz), solfège, colour pairs | 8 notes |
| 23 | Drums | Musik.dc.html:199-238 `drum(kind)`; L267-272 `PADS`; labels L249/250 `pads` | `[kind, colour, dark, iconPath(24×24)]` | 4 (kick, clap, cymbal, shaker) |
| 24 | Songs | Musik.dc.html:239-244 `songs()` (241-242) | `{key:{t:title, n:[noteIdx 0-7], b:[beats]}}`; 1 beat = 420 ms | 2 (twinkle 42 notes, mary 26) |
| 25 | Rhythm | Musik.dc.html:348-371 `beat()` | procedural, 16 steps × 2 loops, 150 ms/step | 1 pattern (code, not data) |
| 26 | Letter balloons | Balon.dc.html:134-144 `makeRound()` (letter sets L135); COLS L151, SLOTS L152 | letter-set strings | 9 letters (age 2–3/unset) / 23 letters (else) |
| 27 | Other UI/config datasets | see §2.3 | — | — |

### 2.2 Dataset details with verbatim samples

**1. Letters — Huruf.dc.html:148-185.** Two independent per-language 26-row lists; the example word *and its image* differ per language for 18 of 26 letters (same image only for A apel, B bola, D dadu, M mangga, Q quokka, V vas, Y yoyo, Z zebra). Fields: `letter` (uppercase), `exampleWord` (display), `imgKey` → `img` map → blob, `ttsSound` (text spoken in phonics mode), `/sound/`, `letterName` (spoken in letter-name mode, pref `letters`). Word highlight = first occurrence of the letter (`indexOf`), so EN X 'Box' highlights the middle "x". 38 img keys, all used; 4 keys exist only here or in Warna: `hujan`, `onde`, `vas` (Huruf only) and `sarang` (Huruf EN 'Nest' + Warna).
- EN L163: `['A', 'Apple', 'apel', 'ah', '/a/', 'ay']`, `['B', 'Ball', 'bola', 'buh', '/b/', 'bee']`
- ID L171: `['A', 'Apel', 'apel', 'a', '/a/', 'a']`, `['B', 'Bola', 'bola', 'beh', '/b/', 'be']`
- img L151: `apel: 'f3ad85e8656c762498e18346c0834e64'`, `bola: 'b6ba1bc1e8f26eb3aa05f31a41e7bb31'`

**2/3. Numbers — Angka.dc.html.** `pool()` L148: `["apel","Apel","Apple","f3ad85e8656c762498e18346c0834e64"]`, `["jeruk","Jeruk","Orange","59fd969d55c43ab93330b9607a09797b"]`. Pool order: apel, jeruk, pisang, stroberi, bola, ikan, bebek, kupu, mobil, balon, bunga, kuekecil. Number words are generated: EN units L153 `['zero', 'one', 'two', …, 'nineteen']` + tens `['', '', 'twenty', 'thirty', 'forty', 'fifty']`; ID L158 `['nol', 'satu', …, 'sembilan']` + 'sepuluh', 'sebelas', 'X belas', 'X puluh Y'. EN plural exceptions L166 `{ Fish: 'fish', Strawberry: 'strawberries', Butterfly: 'butterflies', Balloons: 'balloons' }`. Ranges L225 `[[1, 10], [11, 20], [21, 30], [31, 40], [41, 50]]`. Grid layout per n in `grid()` 173-181.

**4. Animals — Hewan.dc.html:171.** Group keys L198 `['semua', 'rumah', 'liar', 'reptil', 'air', 'kecil']`; labels L179/L181 (EN 'Pets & Farm', 'Wild', 'Reptiles & Frogs', 'Sea & Water', 'Birds & Bugs'; ID 'Peliharaan & Ternak', 'Hutan & Savana', 'Reptil & Katak', 'Laut & Air', 'Burung & Serangga'). Code plays `a[9]` as an audio URL (L226/L228) but tuples have only 9 fields → always TTS fallback (no audio data exists).
- `["kucing","Kucing","Cat","6de067c8bd1b21524d7d6e6b6f4c199a","rumah","Meong!","Meow!","Kucing suka tidur dan bermain.","Cats love to nap and play."]`
- `["anjing","Anjing","Dog","c242939ae5225d55061992c4a9c3f53a","rumah","Guk guk!","Woof woof!","Anjing adalah teman yang setia.","Dogs are loyal friends."]`

**5. Fruit & veg — Buah.dc.html:169.** `["apel","Apel","Apple","f3ad85e8656c762498e18346c0834e64","buah"]`, `["pisang","Pisang","Banana","c75dbf0ae357afaddcf97c42d58a1160","buah"]`. Quiz = 3 options, 6 questions per round.

**6/7. Colors — Warna.dc.html.** `colors()` L157-158: `['merah', 'Merah', 'Red', '#E03131', '#FFFFFF', '#C92A2A']`, `['oranye', 'Oranye', 'Orange', '#FF922B', '#2B2350', '#E8590C']`. Order: merah, oranye, kuning, hijau, biru, ungu, **merah muda** (id with a space), cokelat, hitam, putih, abu-abu. `pics()` L152: `["apel","Apel","Apple","f3ad85e8656c762498e18346c0834e64","merah"]`, `["stroberi","Stroberi","Strawberry","09d4664bec1323b432b1b9c812474c22","merah"]`. Tag counts: merah 12, oranye 10, kuning 9, hijau 14, biru 6, ungu 6, merah muda 6, cokelat 8, **hitam 1** (semut only), putih 6, abu-abu 3. Also inline shape items for the colour game in the template (Warna.dc.html:87-95): `balon` (viewBox 100×130), `bintang` and `hati` (100×100), filled with the colour row's hex and darkLine. `makeSet()` 175-187: 4–5 target items + others = 12 tiles.

**8. Shapes — Bentuk.dc.html:188-202.** Path box 200×200 (displayed ×1.65 = 330). `corners` is a list of point coordinates (used to place numbered markers); there is **no `sides` field** — the UI shows "N sisi / N sudut" = `corners.length` only for kind `poly`; `star` shows "5 ujung" (tips); `round`/`love` have `[]`.
- `['lingkaran', 'Lingkaran', 'Circle', '#FF6B6B', '#E03E3E', 'M18 100A82 82 0 1 1 182 100A82 82 0 1 1 18 100Z', 100, 100, 1, [], 'round', 'Lingkaran itu bulat dan tidak punya sudut.', 'A circle is round and has no corners.']`
- `['persegi', 'Persegi', 'Square', '#4DABF7', '#1C7ED6', 'M28 28H172V172H28Z', 100, 104, 1, [[28, 28], [172, 28], [172, 172], [28, 172]], 'poly', 'Persegi punya 4 sisi yang sama panjang.', 'A square has 4 sides that are all the same.']`
- Order: lingkaran, persegi, segitiga, persegipanjang, oval, belahketupat, bintang, hati, segilima, segienam. Corners: 0,4,3,4,0,4,5(tips),0,5,6. Age pools (L205-207): 6–7 → all 10; 4–5 → indices 0-7; else → `[0, 1, 2, 6, 7]`. Find mode: 3/4/6 options by age, 6 rounds.

**9. Syllables — SukuKata.dc.html:137.** 90 syllables generated (18 consonants × 5 vowels, vowel order a i u e o); examples only for 41 syllables per language, keyed by syllable:
- ID: `"ba":["badak","Badak","246ed92afd22d9cd0b627495a965b7d8"]`, `"bu":["bus","Bus","5fa24324963167da186e12222fc34b6a"]`
- EN: `"ba":["bola","Ball","b6ba1bc1e8f26eb3aa05f31a41e7bb31"]`, `"bi":["burung","Bird","a5705cd1aa08b59d26872e7d4381cf2b"]`
- Vowel colours L149: `{ a: ['#E8384F', '#B82A3E'], i: ['#1C7ED6', '#1565B0'], u: ['#2F9E44', '#237A34'], e: ['#F08C00', '#C46F00'], o: ['#7048E8', '#5032B8'] }`.

**10. Susun Kata — Kata.dc.html:148.** `["bola","Bola",["bo","la"],"b6ba1bc1e8f26eb3aa05f31a41e7bb31"]`, `["buku","Buku",["bu","ku"],"40764645d095695dc89e65d699f811f8"]`; EN `["apel","Apple",["ap","ple"],"f3ad85e8656c762498e18346c0834e64"]`, `["zebra","Zebra",["ze","bra"],"e7a48678ca5c900be7908c88a20c5a18"]`. Syllables always join back to the word (checked). Level = number of syllables (2 or 3); distractor tiles: +2 (level 2) / +1 (level 3) syllables from other words; 5 words per round.

**11. Sentences — Kalimat.dc.html:147.** `["bola","Ini bola.","This is a ball.","b6ba1bc1e8f26eb3aa05f31a41e7bb31"]`, `["kucing","Kucing suka tidur.","The cat likes to sleep.","6de067c8bd1b21524d7d6e6b6f4c199a"]`. **No per-word timing is stored**: "Baca bersama" speaks the whole sentence at TTS rate 0.75 and highlights words on a computed schedule `dur(w) = 420 + 75 * w.length` ms (L214, cumulative, polled every 80 ms). Words = `text.split(' ')`, punctuation stripped only when a single word is tapped. Quiz distractors: 2 random items from the theme dict (THEMES copy at L151); fixed first-render options L247 `{ apel: ['pisang', 'apel', 'bola'] }`.

**12. Ucapkan — Ucapkan.dc.html:174-189.** EN `{ w: 'Apple', syl: ['AP', 'PLE'], img: B + 'f3ad85e8656c762498e18346c0834e64' }`, `{ w: 'Zebra', syl: ['ZE', 'BRA'], img: B + 'e7a48678ca5c900be7908c88a20c5a18' }`; ID `{ w: 'Apel', syl: ['A', 'PEL'], img: B + 'f3ad85e8656c762498e18346c0834e64' }`, `{ w: 'Bola', syl: ['BO', 'LA'], img: B + 'b6ba1bc1e8f26eb3aa05f31a41e7bb31' }`. No content ids (blob only). The microphone is simulated (2.6 s timer → "good", L240).

**13. Tracing — Tulis.dc.html:274-313.** Exact format: object keyed `'A'…'Z'`, `'0'…'9'` (uppercase only, no lowercase letters); value = array of SVG path strings, **one string per stroke, in stroke order; path direction = writing direction** (start = first point, end = last point). Commands used: only absolute `M L H V C` (the runtime sampler `samp()` only understands these). Coordinates 70–465 inside a 520×520 box; template guide lines at y=70 (top), y=260 (dashed mid), y=450 (baseline), x 20–500 (Tulis.dc.html:126-128). Track drawn with stroke-width 66, ink 60, round caps. **No arrow / start-point / numbering data is stored** — all derived at runtime: start handle at the first sample, goal star at the last sample, chevrons every 58 units from 52 along the current stroke (L417), stroke-number badges at the start of later strokes unless they coincide (<2 units) with the current start (L408-412). Sampling: lines every ≤4 units, cubic segments 40 samples. Interaction: grab radius 74, follow tolerance 60 units, look-ahead 45 samples. Letters default 'A', digits default '2' (AngkaTulis.dc.html:17 imports Tulis with `mode="angka"`). Strokes per glyph: A3 B3 C1 D2 E4 F3 G1 H3 I1 J1 K3 L1 M3 N3 O1 P2 Q2 R3 S1 T2 U1 V1 W1 X2 Y2 Z1, 0–9: 1 1 1 1 2 2 1 1 1 1 (total 63). Notable: N stroke 3 goes up (`M370 450V70`); 5 draws the body first and the top bar second. Minified JSON 2,908 B (source literal 3,176 B). Crayons: L429 `['#FF5C8A', '#3BA4FF', '#51CF66', '#FFB020', '#9775FA']`, names L266/267.
- `A: ['M260 70L130 450', 'M260 70L390 450', 'M176 315H344']`
- `B: ['M170 70V450', 'M170 70H270C330 70 360 105 360 160C360 215 325 255 270 255H170', 'M170 255H285C345 255 380 295 380 350C380 410 340 450 280 450H170']`

**14–16. Coloring pages.** Canvas 800×600. Exact format (Mewarnai.dc.html:180, minified JSON identical to source, **27,871 bytes** for all 14 pages; per page 1,259–2,902 B):
- page: `id`, `n:[nameID, nameEN]`, `c:'hewan'|'benda'`, `r:[regions]`, `demo:{"<regionIndex>":"#hex"}`, `ds:[[regionIndex, "#hex", width, "pathD"]]` (demo brush strokes), `t:"/_blob/<thumbnail>"`.
- region: `{d: closed path (all 294 end in Z), e?: 1 → evenodd (only 1 region, in roket), x?: [[pathD, fill, strokeWidth]]}`. Region 0 is the background (`M0 0H800V600H0Z`, or sky `M0 0H800V470H0Z` for kucing/mobil). Detail `x`: fill `''` → stroke-only line of width w in ink; fill set (`#2B2350`/`#FFFFFF`) → filled detail (+ outline if w>0). Renderer: each region filled (default `#FFFFFF`), brush strokes clipped to the region, region outline ink `#2B2350` width 6, then details.
- path commands used across all pages: absolute `M H V Z A L C Q` (arcs `A` dominate).
- per page (regions/details): kupu 28/17, ikan 18/5, kucing 17/16, rumah 21/15, mobil 17/14, bunga 27/5, gajah 18/25, dino 26/4, roket 22/1, kapal 19/14, kue 24/3, hantu 22/13, pelangi 16/8, eskrim 19/7.
- **Sample colours exist only for `kupu`** (`demo` = 17 region fills, `ds` = 1 brush stroke); the other 13 pages have `demo:{}` and `ds:[]`. Karyaku.dc.html:141 holds a stripped copy (`{id,n,r}` only — regions identical, 26,494 B) plus 4 demo artworks (`demo-kupu`, `demo-ikan`, `demo-rumah`, `demo-pelangi`; 1,386 B).
- Sample (truncated, the first page is 2,902 chars): `{"id":"kupu","n":["Kupu-kupu","Butterfly"],"c":"hewan","r":[{"d":"M0 0H800V600H0Z"},{"d":"M34 80A46 46 0 1 0 126 80A46 46 0 1 0 34 80Z","x":[["M133.6 102.2L153.9 110.6","",6],…`; second: `{"id":"ikan","n":["Ikan","Fish"],"c":"hewan","r":[{"d":"M0 0H800V600H0Z"},{"d":"M0 520C120 500 260 540 400 520C540 500 680 540 800 515V600H0Z"},…`
- Karyaku demo sample: `{"id":"demo-kupu","pid":"kupu","fills":{"0":"#BDE7FF","1":"#FFD43B",…},"strokes":{"16":[{"c":"#74C0FC","w":30,"d":"M250 360L330 470L300 335L375 455L350 330L395 420"}]},"stk":[{"x":640,"y":410,"s":0}]}`
- Galeri.dc.html:106-121: `['kupu', 'Kupu-kupu', 'Butterfly', 'hewan', 'f3f17810ba3333dafaa73fd14014629b']`, `['ikan', 'Ikan', 'Fish', 'hewan', '08facf88ddb4bdf4b469fb7baf18aee5']`. Galeri order groups hewan first (kupu, ikan, kucing, gajah, dino, hantu, rumah, mobil, bunga, roket, kapal, kue, pelangi, eskrim); Mewarnai/Karyaku order is kupu, ikan, kucing, rumah, mobil, bunga, gajah, dino, roket, kapal, kue, hantu, pelangi, eskrim. NEW badge list L129 `['gajah', 'dino', 'hantu', 'roket', 'kapal', 'kue', 'pelangi', 'eskrim']`. Names, categories and thumbnails agree between Galeri, Mewarnai and Karyaku.
- Brush sizes (800×600 units) Mewarnai.dc.html:272 `{ s: 14, m: 26, l: 44 }`, eraser +10; saved artworks capped at 12 (L426), Karyaku shows 6.

**17/18. Stickers.** Mewarnai.dc.html:246: `['/_blob/0b224341bbd230f2dd731c560e41d4cb', 'Moci', 'Moci']`, `['/_blob/c6f764abf556b8252c9552e7fa94a90d', 'Moci senang', 'Happy Moci']`; then Apel/Apple, Stroberi/Strawberry, Bola/Ball, 'Es krim'/'Ice cream', Kado/Gift, Ikan/Fish. Karyaku.dc.html:150: `'/_blob/0b224341bbd230f2dd731c560e41d4cb'`, `'/_blob/c6f764abf556b8252c9552e7fa94a90d'` (same 8, no names). Placed stickers are stored by **index** into this list (`stk:[{x,y,s}]`), not by id. Hebat (reward screen) is static: new sticker 'Apel Merah'/'Red Apple' (apel image), album "8 / 30", album images kucing, bola, ikan, apel.

**19. Crayons — Mewarnai.dc.html:335-340.** `['#FF4B4B', 'Merah', 'Red']`, `['#FF922B', 'Oranye', 'Orange']` … 16 entries ending `['#FFFFFF', 'Putih', 'White']`. (Different hexes from Warna's 11 colours.)

**20/21. Game themes (THEMES×6).** `{"buah":[["apel","Apel","Apple","f3ad85e8656c762498e18346c0834e64"],["pisang","Pisang","Banana","c75dbf0ae357afaddcf97c42d58a1160"],…],"sayur":[…],"hewan":[["kucing","Kucing","Cat","6de067c8bd1b21524d7d6e6b6f4c199a"],["anjing","Anjing","Dog","c242939ae5225d55061992c4a9c3f53a"],…],"kendaraan":[…],"benda":[…]}` — 6,634 B, identical in all six files. Usage differs: Cocokkan (themes acak/buah/hewan/sayur/kendaraan/benda + code path `campur`, 3/4/5 pairs) and Memori (same themes, 4/6/8 pairs) use all five; **Bayangan merges all five** with no theme picker (3 or 4 options by age, 6 rounds); **Puzzle and BesarKecil merge only hewan, buah, kendaraan, benda (sayur embedded but never used)**; Kalimat uses all five as quiz distractors. Labels: Cocokkan L255 `buah: en ? 'Fruits' : 'Buah', hewan: en ? 'Animals' : 'Hewan', …, benda: en ? 'Toys & Things' : 'Mainan & Benda', campur: Mixed/Campur, acak: 'Surprise!'/'Acak!'`. Memori card backs L174 `{ buah: ['#FF6B6B', '#E04848'], hewan: ['#22C1C3', '#129A9C'], sayur: ['#5FD068', '#3BAA45'], kendaraan: ['#3BA4FF', '#1C7ED6'], benda: ['#9775FA', '#7048E8'] }`. Puzzle grids by age (L129-134): 2×2 / 3×2 / 3×3. BesarKecil sizes (L137): `[120, 200, 300]`, age 6–7 `[150, 200, 250, 300]`.

**22–25. Music — Musik.dc.html.**
- Xylophone L171 `[523.25, 587.33, 659.25, 698.46, 783.99, 880, 987.77, 1046.5]` (C5…C6), L251 `['do', 're', 'mi', 'fa', 'sol', 'la', 'si', 'do']`, L252 `[['#FF6B6B', '#E03E3E'], ['#FF922B', '#E8590C'], …]`. Synth: sine f + sine 3.93·f partial, 1.2 s decay (no samples).
- Drums L268-271: `['kick', '#FF6B6B', '#E03E3E', 'M4 8.5c0-1.7 3.6-3 8-3s8 1.3 8 3-3.6 3-8 3-8-1.3-8-3zM4 8.5v7c0 1.7 3.6 3 8 3s8-1.3 8-3v-7M8 2.5l4 4M16 2.5l-4 4']`, `['clap', '#FFB020', '#E0870B', 'M7.5 12.5V7a1.5 …']`, then cymbal, shaker; labels ID `['Drum', 'Tepuk', 'Simbal', 'Kerincing']`, EN `['Drum', 'Clap', 'Cymbal', 'Shaker']`. All synthesized (kick 165→45 Hz/0.45 s; clap band-pass 1.5 kHz triple burst; cymbal high-pass 6.5 kHz/1.3 s; shaker high-pass 4.5 kHz/0.16 s).
- Songs L241-242: `twinkle: { t: 'Twinkle Twinkle', n: [0, 0, 4, 4, 5, 5, 4, 3, 3, 2, 2, 1, 1, 0, …], b: [1, 1, 1, 1, 1, 1, 2, …] }` (42 notes, 48 beats ≈ 20.4 s), `mary: { t: 'Mary Had a Little Lamb', n: [2, 1, 0, 1, 2, 2, 2, …], b: [1, 1, 1, 1, 1, 1, 2, …] }` (26 notes, 32 beats ≈ 13.7 s). Note index 0–7 = bar index; beat = 420 ms; playback starts at +250 ms. Titles are English only (spoken with lang 'en').
- Rhythm L352-370 (code): step 150 ms, 16 steps, 2 loops: kick on steps 0, 6, 8; clap on 4, 12; cymbal on step 14 of loop 2; shaker on every even step.

**26. Balon — Balon.dc.html:135.** `'ABCIMOPSU'` (age 2–3 or unset) / `'ABCDEFGHIJKLMNOPRSTUWYZ'` (else; no Q, V, X); 6 balloons = target ×2 + 4 others; 5 rounds; COLS L151 `[['#FF6B6B', '#E03E3E'], ['#FFB020', '#E0870B'], …]`.

### 2.3 Other datasets not in the expected list

| dataset | location | content |
|---|---|---|
| Home menu tiles | Main.dc.html:372-393 (tiles 377-381 ID, 387-391 EN), DEST L396; HP.dc.html:283-296 (titles only) | 10 tiles `huruf: ['Kenal Huruf', 'A sampai Z'], angka: ['Berhitung', '1 sampai 50'], …` → destinations; tile images in template (sapi, kucing, wortel, apel, buku, nanas×2, 4061ab5b scene, xilofon) |
| Games menu | Permainan.dc.html:191-193 `G`, L201 ages, template L58-123 | `g1: 'Cocokkan Gambar', g2: 'Kartu Memori'`, …; age badges: Cocokkan 2+, Memori 3+, Bayangan 2+, Puzzle 3+, Balon 4+, Besar&Kecil 2+ |
| Break routine | Istirahat.dc.html:176-182 `texts()`, icons L190-194 | 3 steps ID/EN `['Lihat jauh ke luar jendela', 'Kedip-kedip 10 kali', 'Regangkan tangan ke atas']` + 3 icon paths (24×24); countdown 20 s in app (12 s standalone) |
| Parent gate | Gate.dc.html:142-154 | question a×b, a ∈ 6–9, b ∈ 3–9 (default 7×6), 2-digit answer |
| Parents' area | OrangTua.dc.html:248-260 `T` (badges), L264 level names, L284-291 `M`, L294-298 toggles, L329 limits | age levels 2–3/4–5/6–7 → Pemula/Starter, Penjelajah/Explorer, Pembaca/Reader; limits 15/30/45/off; toggles music, sfx, breaks; **mock progress table** `[en ? 'Letters' : 'Kenal Huruf', 12, 26, '#FF6B6B', '#E04848', '#E8384F', '', 'Aa']`, `[en ? 'Numbers' : 'Berhitung', 7, 10, …]` (6 rows); letters-mode examples L292-293 |
| App shell | Sambutan.dc.html:175-177 `screens()` (28 routes), prefs L256, timers L200-217 | prefs keys lang, name (≤20 chars), age (values use EN DASH `'2–3'`, `'4–5'`, `'6–7'`), letters, limit, music, sfx, breaks (localStorage `moci-*`); splash 3.6 s; play-time tick 15 s; break every 20 min; daily limit default 30 |
| UI string tables | every interactive board, e.g. Angka 193-194, Balon 149-150, Bayangan 154-155, Bentuk 246-247, BesarKecil 145-146, Buah 200-201, Cocokkan 247-248, Galeri 103-104, Gate 193-194, Hebat 207-208, Hewan 178-181, HP 283-296, Huruf 143-146, Istirahat 180-181, Kalimat 178-179, Karyaku 193-194, Kata 177-178, Main 372-393, Memori 168-169, Mewarnai 300-303, Musik 249-250, OrangTua 248-260, Permainan 192-198, Puzzle 152-153, Sambutan 243-246, SukuKata 144-145, Tulis 265-268, Ucapkan 212-215, Warna 202-203 | ID/EN UI copy + spoken prompts |
| Splash themes | SplashTablet.dc.html:99-114 (SplashHP same) | light/dark gradient + hill/pill colours |
| Brand boards | BrandIkonA/B/C, BrandLogo, BrandGitHub, SplashSistem (templates) | 42 brand SVGs with captions (sizes 1024/120/80/60/40, themed, dark, mono) — Appendix A |
| canvas.json notes | canvas.json `notes.pilih`, `notes.coba` | brand decision (Icon A, sky blue); gate answer 7×6=42; TTS now, real animal audio "once files exist" |
| TTS settings | every `speak()` | id-ID / en-US, rate 0.9 (0.85 Istirahat/Kalimat, 0.75 read-along), pitch 1.15 (1.1 Istirahat) |

---

## 3. Master id table

107 content ids = exactly the 107 assets with viewBox `0 0 200 200` (the blob set is identical both ways). Every content id has exactly one blob; no blob is used under two content ids.

**Conflicts found**

| type | id | detail |
|---|---|---|
| same id, different EN name | `paprika` | 'Bell Pepper' (THEMES×6, Buah, Warna) vs **'Pepper'** (Kata EN) |
| same id, different EN name | `kado` | 'Gift' (THEMES×6, SukuKata EN, Warna, Mewarnai sticker) vs **'Box'** (Huruf EN letter X) |
| same id, different ID name (case) | `eskrim` | 'Es Krim' (THEMES×6) vs **'Es krim'** (Huruf ID E, Mewarnai sticker); sticker EN 'Ice cream' vs 'Ice Cream' |
| label variant | `apel` | Hebat reward sticker labelled 'Apel Merah'/'Red Apple' (same blob) |
| same id, different blob (cross-category) | `kupu`, `ikan`, `kucing`, `gajah`, `rumah`, `mobil`, `bunga`, `roket`, `kapal`, `eskrim` | coloring-page id = content id but a different blob (page thumbnail); also `bunga` EN 'Flowers' (page) vs 'Flower', `kapal` EN 'Boat' (page) vs 'Ship' |
| same concept, different ids | `hantu` (coloring page) vs `burunghantu` (content) | both 'Burung Hantu'/'Owl' |
| same blob, different ids | — | none |
| id not lowercase-no-space | `merah muda` | Warna colour id **with a space** (also used as colour tag on 6 pictures) |
| id with hyphen (lowercase, no space) | `abu-abu`; Karyaku demo ids `demo-kupu`, `demo-ikan`, `demo-rumah`, `demo-pelangi` | allowed by the stated rule, listed for awareness; Tulis glyph keys are uppercase `A`–`Z` (glyph keys, not content ids) |
| plural EN name | `balon` | EN name is 'Balloons' everywhere |


### Master id table — 107 content ids (sorted by theme: buah, sayur, hewan, kendaraan, benda, then ids outside the theme dict)

Columns: *data artboards* = artboards whose embedded data lists the id (tags: `[id:X]`/`[en:X]` = Huruf letter X or SukuKata syllable per language, `[id]`/`[en]` = Kata list, `[sentence]` = Kalimat sentence); *img-only refs* = artboards that use the same blob without the id (templates, stickers, Ucapkan). Category = theme key, plus Hewan group and Warna colour tag.

| # | id | category | name ID | name EN | blob | data artboards | img-only refs | flags |
|---|---|---|---|---|---|---|---|---|
| 1 | `alpukat` | buah (warna:hijau) | Alpukat | Avocado | `5f73428052239896d0b19d90bbdca29c` | THEMES×6, Bua, War | — |  |
| 2 | `anggur` | buah (warna:ungu) | Anggur | Grapes | `7e32fcc5a77bca13617a7e9e6ebe6e67` | THEMES×6, Bua, War, Hur[en:G], Kat[id] | — |  |
| 3 | `apel` | buah (warna:merah) | Apel | Apple | `f3ad85e8656c762498e18346c0834e64` | THEMES×6, Kal[sentence], Bua, Ang, War, Hur[en:A id:A], Kat[en id] | HP, Heb, Heb:T.stickerName, Kar:stickerList, Main, Mew:stickerList, OT, Per, Uca:words.en, Uca:words.id | label variant: Apel Merah/Red Apple (Heb) |
| 4 | `buahnaga` | buah (warna:merah muda) | Buah Naga | Dragon Fruit | `ab38e88101d413a3d63b42752d453205` | THEMES×6, Bua, War | — |  |
| 5 | `ceri` | buah (warna:merah) | Ceri | Cherry | `3fd7f59fde32f0a08b786024c2ae1816` | THEMES×6, Bua, War, Hur[id:C], Kat[id], Suk[id:ce] | — |  |
| 6 | `durian` | buah (warna:hijau) | Durian | Durian | `e2d12c8abf7cbc81caa370e3127314c8` | THEMES×6, Bua, War, Kat[id], Suk[id:du] | — |  |
| 7 | `jambu` | buah (warna:merah muda) | Jambu Air | Water Apple | `8fc15ac4c08d61291754b32791eb1206` | THEMES×6, Bua, War | — |  |
| 8 | `jeruk` | buah (warna:oranye) | Jeruk | Orange | `59fd969d55c43ab93330b9607a09797b` | THEMES×6, Bua, Ang, War, Hur[id:J], Kat[id], Suk[id:je] | — |  |
| 9 | `kelapa` | buah (warna:hijau) | Kelapa | Coconut | `d0a5a178291f6bd0606cb8a325a7c385` | THEMES×6, Bua, War, Kat[en id], Suk[id:ke] | — |  |
| 10 | `lemon` | buah (warna:kuning) | Lemon | Lemon | `8b60cce55b018ce76778d0e91124dc59` | THEMES×6, Bua, War, Kat[en id], Suk[en:le] | — |  |
| 11 | `mangga` | buah | Mangga | Mango | `8a6b053fd31a1f50cc94e69e5242e40f` | THEMES×6, Bua, Hur[en:M id:M], Kat[en id], Suk[en:ma id:ma] | Uca:words.en |  |
| 12 | `manggis` | buah (warna:ungu) | Manggis | Mangosteen | `75e7e3110acc6c21ed3fdebef127894a` | THEMES×6, Bua, War, Kat[id] | — |  |
| 13 | `melon` | buah (warna:hijau) | Melon | Melon | `7b51db2aaa58605a7ae15e1af1369775` | THEMES×6, Bua, War, Kat[en id], Suk[en:me id:me] | — |  |
| 14 | `nanas` | buah (warna:kuning) | Nanas | Pineapple | `c5b26a2b99c1d84e15e9b08ad81a2811` | THEMES×6, Bua, War, Hur[en:P id:N], Kat[en id], Suk[en:pi id:na] | HP, Main, Per |  |
| 15 | `pepaya` | buah (warna:oranye) | Pepaya | Papaya | `e656141d6c19c6456cb0733ad9d863f6` | THEMES×6, Bua, War, Kat[en id], Suk[id:pe] | — |  |
| 16 | `pir` | buah (warna:hijau) | Pir | Pear | `cab62ecc12c60a9bac84afc2e9ebdaa9` | THEMES×6, Bua, War, Suk[en:pe id:pi] | — |  |
| 17 | `pisang` | buah (warna:kuning) | Pisang | Banana | `c75dbf0ae357afaddcf97c42d58a1160` | THEMES×6, Kal[sentence], Bua, Ang, War, Hur[id:P], Kat[en id] | — |  |
| 18 | `rambutan` | buah (warna:merah) | Rambutan | Rambutan | `b003fadeccd318f540f8d8b84f0432f8` | THEMES×6, Bua, War, Suk[id:ra] | — |  |
| 19 | `salak` | buah (warna:cokelat) | Salak | Snake Fruit | `9a04b8bf05b1e774b527a1e5b07fe2e4` | THEMES×6, Bua, War, Kat[id] | — |  |
| 20 | `semangka` | buah (warna:merah) | Semangka | Watermelon | `b573b73d242c8297b108f60d1a04c80d` | THEMES×6, Bua, War, Hur[en:W], Kat[id], Suk[en:wa] | — |  |
| 21 | `stroberi` | buah (warna:merah) | Stroberi | Strawberry | `09d4664bec1323b432b1b9c812474c22` | THEMES×6, Bua, Ang, War, Hur[en:S] | Kar:stickerList, Mew:stickerList |  |
| 22 | `bawang` | sayur | Bawang Merah | Shallot | `f87ae2fa3c291525aa0f9743c06faae0` | THEMES×6, Bua | — |  |
| 23 | `brokoli` | sayur (warna:hijau) | Brokoli | Broccoli | `112a01a0bb2ec54bcc9c5d82c4483374` | THEMES×6, Bua, War, Kat[id] | — |  |
| 24 | `buncis` | sayur (warna:hijau) | Buncis | Green Beans | `6fbf958d791ba2f93fe3fec3baef7668` | THEMES×6, Bua, War | — |  |
| 25 | `cabai` | sayur (warna:merah) | Cabai | Chili | `59862cf8071958f919b8bc19c09b5360` | THEMES×6, Bua, War, Suk[id:ca] | — |  |
| 26 | `jagung` | sayur (warna:kuning) | Jagung | Corn | `e08be0e2320e04d93c135ec839e948c3` | THEMES×6, Bua, War, Kat[id] | — |  |
| 27 | `jamur` | sayur (warna:merah) | Jamur | Mushroom | `165cb51bf0986707ffbfb2d921d0e176` | THEMES×6, Bua, War, Kat[id], Suk[en:mu id:ja] | — |  |
| 28 | `kentang` | sayur (warna:cokelat) | Kentang | Potato | `656defb15a88ce7a84799d436f569272` | THEMES×6, Bua, War, Kat[en id], Suk[en:po] | — |  |
| 29 | `kubis` | sayur (warna:hijau) | Kubis | Cabbage | `bb4ae18f2157c2fda0b35c73ac0500a4` | THEMES×6, Bua, War, Kat[id] | — |  |
| 30 | `labu` | sayur (warna:oranye) | Labu | Pumpkin | `515d2976a430bbde0badf4b3ffcb74a5` | THEMES×6, Bua, War, Kat[en id], Suk[en:pu id:la] | — |  |
| 31 | `paprika` | sayur (warna:merah) | Paprika |  ⚠ Bell Pepper (Bay,BK,Bua,Coc,Kal,Mem,Puz,War) / Pepper (Kat) | `b52770bc9ad3fc2ce8c5111f526ebf56` | THEMES×6, Bua, War, Kat[en id] | — | EN-name conflict |
| 32 | `terong` | sayur (warna:ungu) | Terong | Eggplant | `19a19c17820600c0673160b75b8d3f29` | THEMES×6, Bua, War, Kat[id], Suk[id:te] | — |  |
| 33 | `timun` | sayur (warna:hijau) | Timun | Cucumber | `9a8a7f8d87315469e96e98fb1f2b6e65` | THEMES×6, Bua, War, Kat[id] | — |  |
| 34 | `tomat` | sayur (warna:merah) | Tomat | Tomato | `af7684512ef48e45fd48313f41839ba0` | THEMES×6, Bua, War, Hur[en:T], Kat[en id], Suk[en:to] | — |  |
| 35 | `wortel` | sayur (warna:oranye) | Wortel | Carrot | `bd07cd5b5330a2434002468d23961755` | THEMES×6, Bua, War, Hur[id:W], Kat[en id], Suk[id:wo] | HP, Main |  |
| 36 | `anjing` | hewan (hewan:rumah) | Anjing | Dog | `c242939ae5225d55061992c4a9c3f53a` | THEMES×6, Hew, Suk[en:do] | — |  |
| 37 | `ayam` | hewan (hewan:rumah, warna:putih) | Ayam | Chicken | `81f53fe15d52afbfe261d665ef8b74ba` | THEMES×6, Hew, War, Kat[en] | — |  |
| 38 | `badak` | hewan (hewan:liar, warna:abu-abu) | Badak | Rhino | `246ed92afd22d9cd0b627495a965b7d8` | THEMES×6, Hew, War, Kat[en id], Suk[id:ba] | — |  |
| 39 | `bebek` | hewan (hewan:rumah, warna:putih) | Bebek | Duck | `754f0bd7e0eb7cdaa2fd47f6f89b2df2` | THEMES×6, Kal[sentence], Hew, Ang, War, Kat[id], Suk[en:du id:be] | — |  |
| 40 | `beruang` | hewan (hewan:liar, warna:cokelat) | Beruang | Bear | `6227b1cc8d2743c5fdb255f35b6ac00e` | THEMES×6, Hew, War, Kat[id] | — |  |
| 41 | `buaya` | hewan (hewan:reptil, warna:hijau) | Buaya | Crocodile | `e257162228dd7c14327b984fc28fedd7` | THEMES×6, Hew, War, Kat[en id] | — |  |
| 42 | `burung` | hewan (hewan:kecil, warna:biru) | Burung | Bird | `a5705cd1aa08b59d26872e7d4381cf2b` | THEMES×6, Hew, War, Suk[en:bi] | — |  |
| 43 | `burunghantu` | hewan (hewan:kecil, warna:cokelat) | Burung Hantu | Owl | `c26166f1dd3bb0c3f4b4b44cf09a5d4f` | THEMES×6, Hew, War | — |  |
| 44 | `domba` | hewan (hewan:rumah, warna:putih) | Domba | Sheep | `c780d1ee0c9956db8125fe76ed646f3d` | THEMES×6, Hew, War, Kat[id], Suk[id:do] | — |  |
| 45 | `flamingo` | hewan (hewan:kecil, warna:merah muda) | Flamingo | Flamingo | `c1c03878fc3cf75b46b14877a58b8a26` | THEMES×6, Hew, War, Hur[id:F] | — |  |
| 46 | `gajah` | hewan (hewan:liar, warna:abu-abu) | Gajah | Elephant | `8cb65c6477727354f6b9ad662449edba` | THEMES×6, Kal[sentence], Hew, War, Hur[en:E id:G], Kat[en id], Suk[id:ga] | Per |  |
| 47 | `gurita` | hewan (hewan:air, warna:merah muda) | Gurita | Octopus | `b56f04945cb0c68002805a3329cf26c5` | THEMES×6, Hew, War, Hur[en:O], Kat[en id], Suk[id:gu] | — |  |
| 48 | `harimau` | hewan (hewan:liar, warna:oranye) | Harimau | Tiger | `136c12a57e02d6f48327aa4a5aa7e505` | THEMES×6, Hew, War, Kat[en id], Suk[en:ti id:ha] | — |  |
| 49 | `ikan` | hewan (hewan:air, warna:biru) | Ikan | Fish | `ce8b6885ad970a4e66e036e133810b2b` | THEMES×6, Kal[sentence], Hew, Ang, War, Hur[en:F id:I], Kat[id], Suk[en:fi] | Heb, Kar:stickerList, Mew:stickerList, Uca:words.id |  |
| 50 | `jerapah` | hewan (hewan:liar, warna:kuning) | Jerapah | Giraffe | `4c3d5f88d1553c3efc658ffde91c904f` | THEMES×6, Hew, War, Kat[en id] | — |  |
| 51 | `kambing` | hewan (hewan:rumah, warna:putih) | Kambing | Goat | `1c4ae5e05ea5cb5b1c97d7553d420d8f` | THEMES×6, Hew, War, Kat[id], Suk[en:go] | — |  |
| 52 | `katak` | hewan (hewan:reptil, warna:hijau) | Katak | Frog | `bec3ad3d9d42a30492ed1e061fdda4e0` | THEMES×6, Hew, War, Kat[id] | — |  |
| 53 | `kelinci` | hewan (hewan:rumah, warna:putih) | Kelinci | Rabbit | `f7d015c440e821b1c7c751875e4327e8` | THEMES×6, Kal[sentence], Hew, War, Hur[en:R], Kat[en id], Suk[en:ra] | Uca:words.en |  |
| 54 | `kepiting` | hewan (hewan:air, warna:merah) | Kepiting | Crab | `2718e0ad945f18ded680238031a1a768` | THEMES×6, Hew, War, Kat[id] | — |  |
| 55 | `komodo` | hewan (hewan:reptil) | Komodo | Komodo Dragon | `ad4951cf81893165769f3f647fc54846` | THEMES×6, Hew, Kat[id], Suk[en:ko id:ko] | — |  |
| 56 | `kucing` | hewan (hewan:rumah, warna:oranye) | Kucing | Cat | `6de067c8bd1b21524d7d6e6b6f4c199a` | THEMES×6, Kal[sentence], Hew, War, Hur[en:C id:K], Kat[id], Suk[en:ca] | HP, Heb, Main, OT, Per |  |
| 57 | `kuda` | hewan (hewan:rumah, warna:cokelat) | Kuda | Horse | `cc9b06fecc57b5d105417f65369928a4` | THEMES×6, Hew, War, Kat[id], Suk[en:ho id:ku] | — |  |
| 58 | `kudanil` | hewan (hewan:liar) | Kuda Nil | Hippo | `f9fef0ce562868c87a2a2d34583a9a91` | THEMES×6, Hew, Suk[en:hi] | — |  |
| 59 | `kupu` | hewan (hewan:kecil, warna:ungu) | Kupu-kupu | Butterfly | `dbdd2cc62f8a5bd8584cf371fac1c3b5` | THEMES×6, Kal[sentence], Hew, Ang, War, Kat[en] | — |  |
| 60 | `kura` | hewan (hewan:reptil, warna:hijau) | Kura-kura | Turtle | `db916cd9c526fad67c469d232d3e5885` | THEMES×6, Hew, War, Kat[en], Suk[en:tu] | — |  |
| 61 | `lebah` | hewan (hewan:kecil, warna:kuning) | Lebah | Bee | `b79511af670fe0c41fb57609f87bc0d7` | THEMES×6, Hew, War, Kat[id], Suk[en:be id:le] | — |  |
| 62 | `lumba` | hewan (hewan:air, warna:biru) | Lumba-lumba | Dolphin | `52d07c866db14ef1a0fbd2c42022531a` | THEMES×6, Hew, War, Kat[en], Suk[id:lu] | — |  |
| 63 | `monyet` | hewan (hewan:liar, warna:cokelat) | Monyet | Monkey | `817145047067c4f962003b16c2f5fe59` | THEMES×6, Kal[sentence], Hew, War, Kat[en id] | — |  |
| 64 | `orangutan` | hewan (hewan:liar, warna:oranye) | Orangutan | Orangutan | `7ed47b04dad452d96a24e6150153b9f5` | THEMES×6, Hew, War | — |  |
| 65 | `panda` | hewan (hewan:liar) | Panda | Panda | `2aca45982f4d73d88f787d45ec03d315` | THEMES×6, Hew, Kat[en id], Suk[en:pa] | — |  |
| 66 | `paus` | hewan (hewan:air, warna:biru) | Paus | Whale | `193e7df94e29721da1a2ac0f2f472b53` | THEMES×6, Hew, War, Kat[id], Suk[id:pa] | — |  |
| 67 | `pinguin` | hewan (hewan:air) | Pinguin | Penguin | `2d6f65aa46663557cff33fa1ac230978` | THEMES×6, Hew, Kat[en id] | — |  |
| 68 | `quokka` | hewan (hewan:liar, warna:cokelat) | Quokka | Quokka | `4649005d6db1c08190f0c0cd49412f15` | THEMES×6, Hew, War, Hur[en:Q id:Q] | — |  |
| 69 | `rubah` | hewan (hewan:liar, warna:oranye) | Rubah | Fox | `5c40d0968fbcc89166b74a9be572773b` | THEMES×6, Hew, War, Kat[id], Suk[en:fo id:ru] | — |  |
| 70 | `sapi` | hewan (hewan:rumah) | Sapi | Cow | `eb1bebc96da8f6f1ffc1494e0fc98f3f` | THEMES×6, Kal[sentence], Hew, Hur[id:S], Kat[id], Suk[en:co id:sa] | HP, Main, Uca:words.id |  |
| 71 | `semut` | hewan (hewan:kecil, warna:hitam) | Semut | Ant | `f6df9bbf276d2e186a24f33a3041a600` | THEMES×6, Hew, War, Kat[id], Suk[id:se] | — |  |
| 72 | `singa` | hewan (hewan:liar, warna:oranye) | Singa | Lion | `dd80b453f8b3c290ec0572401fe88fe7` | THEMES×6, Hew, War, Hur[en:L], Kat[en], Suk[en:li id:si] | — |  |
| 73 | `tikus` | hewan (hewan:rumah, warna:abu-abu) | Tikus | Mouse | `de9512c85659eedbd04f024fc5074f4b` | THEMES×6, Hew, War, Kat[id], Suk[en:mo id:ti] | — |  |
| 74 | `ubur` | hewan (hewan:air, warna:ungu) | Ubur-ubur | Jellyfish | `e030d26c76d42274c76cf645c9e57bee` | THEMES×6, Hew, War, Hur[en:J], Suk[en:je] | — |  |
| 75 | `ular` | hewan (hewan:reptil, warna:hijau) | Ular | Snake | `4d73c54d6666d5e184ba443f2597f2d9` | THEMES×6, Hew, War, Kat[id] | — |  |
| 76 | `ulat` | hewan (hewan:kecil, warna:hijau) | Ulat | Caterpillar | `2cffab27ed6825a9e2c9fba43d09c3a0` | THEMES×6, Hew, War, Hur[id:U] | — |  |
| 77 | `zebra` | hewan (hewan:liar) | Zebra | Zebra | `e7a48678ca5c900be7908c88a20c5a18` | THEMES×6, Hew, Hur[en:Z id:Z], Kat[en id], Suk[en:ze id:ze] | Uca:words.en |  |
| 78 | `bus` | kendaraan (warna:kuning) | Bus | Bus | `5fa24324963167da186e12222fc34b6a` | THEMES×6, War, Suk[en:bu id:bu] | — |  |
| 79 | `helikopter` | kendaraan (warna:kuning) | Helikopter | Helicopter | `62be577d88c8efa7d0650f8e6fe147ee` | THEMES×6, War, Suk[en:he id:he] | — |  |
| 80 | `kapal` | kendaraan | Kapal | Ship | `c13e9fd9b35f81a1e2e7c8270df7810b` | THEMES×6, Kat[id] | — |  |
| 81 | `kereta` | kendaraan | Kereta | Train | `c0044435766474df6769a38a15b41072` | THEMES×6, Kal[sentence], Kat[id] | — |  |
| 82 | `mobil` | kendaraan (warna:merah) | Mobil | Car | `9a4b52d03d573cb2bb9e7fc33aa00ad6` | THEMES×6, Kal[sentence], Ang, War, Kat[id], Suk[id:mo] | — |  |
| 83 | `pesawat` | kendaraan (warna:biru) | Pesawat | Airplane | `cf3cbdb44abff66623a1b8886c6334a8` | THEMES×6, Kal[sentence], War, Kat[id] | — |  |
| 84 | `roket` | kendaraan | Roket | Rocket | `65a1f0b3aa312fc93fd888b8a105ce98` | THEMES×6, Kat[en id], Suk[en:ro id:ro] | — |  |
| 85 | `sepeda` | kendaraan | Sepeda | Bicycle | `fd16a4542bf6b07d9b4a88c55c68fb95` | THEMES×6, Kat[en id] | — |  |
| 86 | `truk` | kendaraan (warna:oranye) | Truk | Truck | `e64bfdb04579e9fb52398c0da0c80992` | THEMES×6, War | — |  |
| 87 | `balon` | benda | Balon | Balloons | `92d5ae7160761db50ac2050b7ab1a4d5` | THEMES×6, Kal[sentence], Ang, Kat[id] | — |  |
| 88 | `bola` | benda | Bola | Ball | `b6ba1bc1e8f26eb3aa05f31a41e7bb31` | THEMES×6, Kal[sentence], Ang, Hur[en:B id:B], Kat[id], Suk[en:ba id:bo] | Heb, Kar:stickerList, Mew:stickerList, Uca:words.id |  |
| 89 | `buku` | benda | Buku | Book | `40764645d095695dc89e65d699f811f8` | THEMES×6, Kal[sentence], Kat[id], Suk[en:bo] | HP, Main, OT |  |
| 90 | `bunga` | benda (warna:merah muda) | Bunga | Flower | `a09858b43e75375a000f2d1c491d9333` | THEMES×6, Kal[sentence], Ang, War, Kat[id] | — |  |
| 91 | `dadu` | benda | Dadu | Dice | `21ec3ff6cd7241ec48aa204f338666e8` | THEMES×6, Hur[en:D id:D], Kat[id], Suk[en:di id:da] | — |  |
| 92 | `eskrim` | benda |  ⚠ Es Krim (Bay,BK,Coc,Kal,Mem,Puz) / Es krim (Hur) | Ice Cream | `1c9d89ce71c86ba2d59b5b3b05b5733a` | THEMES×6, Kal[sentence], Hur[id:E] | Kar:stickerList, Mew:stickerList | ID-name conflict; label variant: Es krim/Ice cream (Mew) |
| 93 | `igloo` | benda (warna:putih) | Igloo | Igloo | `d8346c1de7889660d9773e168f62ec9b` | THEMES×6, War, Hur[en:I] | — |  |
| 94 | `kado` | benda (warna:kuning) | Kado |  ⚠ Gift (Bay,BK,Coc,Kal,Mem,Puz,Suk,War) / Box (Hur) | `89f1eaa66e0150028701c8f5c32dab8c` | THEMES×6, War, Hur[en:X], Kat[id], Suk[en:gi id:ka] | Kar:stickerList, Mew:stickerList | EN-name conflict |
| 95 | `kaos` | benda (warna:biru) | Kaos | T-shirt | `893ce2f6a36105a5c6bf9dea02c0bc02` | THEMES×6, War, Kat[id] | — |  |
| 96 | `kuekecil` | benda (warna:merah muda) | Kue Mangkuk | Cupcake | `5175853037660fb2f7ad154418e040ec` | THEMES×6, Ang, War, Kat[en], Suk[en:cu] | — |  |
| 97 | `layang` | benda | Layang-layang | Kite | `b318984ee6d49e39029e199e88367107` | THEMES×6, Hur[en:K id:L], Suk[en:ki] | — |  |
| 98 | `payung` | benda | Payung | Umbrella | `f80f0f94891ce851b0295abb6cdfc6b3` | THEMES×6, Hur[en:U], Kat[id] | — |  |
| 99 | `rumah` | benda | Rumah | House | `674389f583852b74d45e31c19d339f86` | THEMES×6, Hur[en:H id:R], Kat[id] | — |  |
| 100 | `sepatu` | benda (warna:merah) | Sepatu | Shoe | `47d389b3dc6c01d69907d0362050c151` | THEMES×6, War, Kat[id] | — |  |
| 101 | `topi` | benda | Topi | Hat | `4ffb45a35e6ab85a85df0806cc4ed5bf` | THEMES×6, Hur[id:T], Kat[id], Suk[en:ha id:to] | Uca:words.id |  |
| 102 | `xilofon` | benda | Xilofon | Xylophone | `01c5c505a58f253f0e264c90f0a261fd` | THEMES×6, Hur[id:X] | HP, Main |  |
| 103 | `yoyo` | benda (warna:ungu) | Yoyo | Yoyo | `d8d724511b118aee435cb582d2599023` | THEMES×6, War, Hur[en:Y id:Y], Kat[en], Suk[en:yo id:yo] | Uca:words.en |  |
| 104 | `hujan` | (none: Huruf/Warna only) | Hujan | — | `6fbbdd5bf31ab213ee619c8555232539` | Hur[id:H] | — | not in theme dict |
| 105 | `onde` | (none: Huruf/Warna only) | Onde-onde | — | `0505610f29535a954866386a3bf2a5ee` | Hur[id:O] | — | not in theme dict |
| 106 | `sarang` | (none: Huruf/Warna only) (warna:cokelat) | Sarang | Nest | `90b95302252dae3e8124a563dbc7cf78` | War, Hur[en:N] | — | not in theme dict |
| 107 | `vas` | (none: Huruf/Warna only) | Vas bunga | Vase | `1ae5db76439373600d63d870be5b0def` | Hur[en:V id:V] | — | not in theme dict |

### Coloring pages (14) — ids collide with content ids above

| id | cat | name ID | name EN | thumbnail blob | artboards | collides with content id? |
|---|---|---|---|---|---|---|
| `kupu` | hewan | Kupu-kupu | Butterfly | `f3f17810ba3333dafaa73fd14014629b` | Gal, Mew, Kar | yes — same id, different blob (`f3f17810…` vs content `dbdd2cc6…`) |
| `ikan` | hewan | Ikan | Fish | `08facf88ddb4bdf4b469fb7baf18aee5` | Gal, Mew, Kar | yes — same id, different blob (`08facf88…` vs content `ce8b6885…`) |
| `kucing` | hewan | Kucing | Cat | `11b0a88f8ebcc3f9ee0bef891976ebbc` | Gal, Mew, Kar | yes — same id, different blob (`11b0a88f…` vs content `6de067c8…`) |
| `gajah` | hewan | Gajah | Elephant | `6a3c5b2df4d80f6bca66f129b80924df` | Gal, Mew, Kar | yes — same id, different blob (`6a3c5b2d…` vs content `8cb65c64…`) |
| `dino` | hewan | Dinosaurus | Dinosaur | `7cd2fd356f2b7bd679ded4fa7d3a4080` | Gal, Mew, Kar | no |
| `hantu` | hewan | Burung Hantu | Owl | `083409af4b96c7b7f100b4df2d1f66e8` | Gal, Mew, Kar | no (same concept as content `burunghantu`) |
| `rumah` | benda | Rumah | House | `e9a05d1b132bbff74f749600fc842bce` | Gal, Mew, Kar | yes — same id, different blob (`e9a05d1b…` vs content `674389f5…`) |
| `mobil` | benda | Mobil | Car | `80d57340d7a04979966c6987151f8149` | Gal, Mew, Kar | yes — same id, different blob (`80d57340…` vs content `9a4b52d0…`) |
| `bunga` | benda | Bunga | Flowers | `a6e8841e95adbb1cee88ec689bff8c75` | Gal, Mew, Kar | yes — same id, different blob (`a6e8841e…` vs content `a09858b4…`); EN Flowers vs Flower |
| `roket` | benda | Roket | Rocket | `6d648e7114505f118092a3c663226a46` | Gal, Mew, Kar | yes — same id, different blob (`6d648e71…` vs content `65a1f0b3…`) |
| `kapal` | benda | Kapal | Boat | `c11dc33d6c0c3f2549d2a1535f1b1282` | Gal, Mew, Kar | yes — same id, different blob (`c11dc33d…` vs content `c13e9fd9…`); EN Boat vs Ship |
| `kue` | benda | Kue Ulang Tahun | Birthday Cake | `d43e8992671c82a372fe69dab7b13707` | Gal, Mew, Kar | no |
| `pelangi` | benda | Pelangi | Rainbow | `3316bfaf816f7653b77542fbf30cd0e4` | Gal, Mew, Kar | no |
| `eskrim` | benda | Es Krim | Ice Cream | `5a0c0aeebf5ba88e69c75c1b4e150baf` | Gal, Mew, Kar | yes — same id, different blob (`5a0c0aee…` vs content `1c9d89ce…`) |

### Shapes (10) and colors (11) — no blobs

| id | kind | name ID | name EN | artboard | flags |
|---|---|---|---|---|---|
| `lingkaran` | shape | Lingkaran | Circle | Bentuk |  |
| `persegi` | shape | Persegi | Square | Bentuk |  |
| `segitiga` | shape | Segitiga | Triangle | Bentuk |  |
| `persegipanjang` | shape | Persegi panjang | Rectangle | Bentuk |  |
| `oval` | shape | Oval | Oval | Bentuk |  |
| `belahketupat` | shape | Belah ketupat | Diamond | Bentuk |  |
| `bintang` | shape | Bintang | Star | Bentuk |  |
| `hati` | shape | Hati | Heart | Bentuk |  |
| `segilima` | shape | Segi lima | Pentagon | Bentuk |  |
| `segienam` | shape | Segi enam | Hexagon | Bentuk |  |
| `merah` | color | Merah | Red | Warna |  |
| `oranye` | color | Oranye | Orange | Warna |  |
| `kuning` | color | Kuning | Yellow | Warna |  |
| `hijau` | color | Hijau | Green | Warna |  |
| `biru` | color | Biru | Blue | Warna |  |
| `ungu` | color | Ungu | Purple | Warna |  |
| `merah muda` | color | Merah Muda | Pink | Warna | **not lowercase-no-space** (contains space) |
| `cokelat` | color | Cokelat | Brown | Warna |  |
| `hitam` | color | Hitam | Black | Warna |  |
| `putih` | color | Putih | White | Warna |  |
| `abu-abu` | color | Abu-abu | Gray | Warna | hyphen in id |

### Blob-only assets (no content id) referenced by artboards

| blob | what | referenced by |
|---|---|---|
| `4061ab5bce10e62e630528c89ad08553` | Colored butterfly garden scene (600×600) — 'Mewarnai' home tile, Karyaku card in Galeri, OrangTua module icon | Gal, HP, Main, OT |
| `2145243b8d9b387f59a3b0d6533130f8` | GitHub README banner — dark (1280×320) | BrandGitHub |
| `48f15b539cc0f3f20048d6b8f16fb886` | GitHub README banner — light (1280×320) | BrandGitHub |
| `3c2f458c2b839d9af96828f0ac327661` | GitHub social preview (1280×640) | BrandGitHub |
| `6027c48450b1b672031bfc4cd0d98133` | Icon A (chosen) — sky-blue bg, 1024; also GitHub avatar, Android splash | BrandGitHub, BrandIkonA, SplashSistem |
| `a7de9580470b7b96c9f5ddd940bb8fad` | Icon A — Android themed | BrandIkonA |
| `ede32ac4c9a3f6bfb791c65cc84625ad` | Icon A — black & white; Android splash mono | BrandIkonA, SplashSistem |
| `1e6ef630c214ce7938064dd106b7c529` | Icon A — dark mode (iOS); Android splash dark | BrandIkonA, SplashSistem |
| `4b63aa4d20499bc594796ed33ccd157d` | Icon A — mint bg | BrandIkonA |
| `03acfdb693e667925cc065e834e9b879` | Icon A — pink bg | BrandIkonA |
| `6d02d35e2d2599bec868f39446c1293b` | Icon A — purple bg | BrandIkonA |
| `3f66fda1cebcd7f29efcb640de919b7d` | Icon A — white on black (iOS tinted base) | BrandIkonA |
| `50997f1207d724de15a3a64de3083247` | Icon B — Android themed | BrandIkonB |
| `71c9e2d0f572e70720afd1c0f902bd1e` | Icon B — black & white | BrandIkonB |
| `003c2a9f96594716fda92027c1ecc753` | Icon B — dark mode | BrandIkonB |
| `ccf3dda513a3502c6fc54e80146d70ab` | Icon B — mint bg | BrandIkonB |
| `ca91acce0efce98ca95a2fdf5acb3a55` | Icon B — pink bg | BrandIkonB |
| `8d0671d39024d63355c33c3b1a89a610` | Icon B — purple bg | BrandIkonB |
| `cd00165a30fd4b4b40318c4f0123c0fb` | Icon B — sky-blue bg (main) | BrandIkonB |
| `a5b210d2f0555d297ae65389f9ac9be2` | Icon B — white on black | BrandIkonB |
| `d285b1b340fd04c51cf74af3c5c3c9a6` | Icon C — Android themed | BrandIkonC |
| `1173ad00a0418fabc454a42954d1c934` | Icon C — black & white | BrandIkonC |
| `b277ed60ce0084846c2a1e900f890f64` | Icon C — cream bg (main) | BrandIkonC |
| `c9ef0d82ca2ec065650161bdad9f0545` | Icon C — dark mode | BrandIkonC |
| `3977f676b1a39a31ebc24dde2bbb2edd` | Icon C — mint bg | BrandIkonC |
| `86e3f0fa6534603f64af12950da4cd33` | Icon C — purple bg | BrandIkonC |
| `8e4fc445da1929a07c58b44808e35475` | Icon C — sky-blue bg | BrandIkonC |
| `08f0679f90e47dbccd1ae9a801e4fd72` | Icon C — white on black | BrandIkonC |
| `bbb2ba7de6d453206301ce65a1af50e0` | Logo horizontal — black (iPhone splash mono) | BrandLogo, SplashSistem |
| `7b6ebd972f1e877f40d58858975b909b` | Logo horizontal — color (iPhone splash) | BrandLogo, SplashSistem |
| `7dfad8f1839a8ac8216ed11376b1cad3` | Logo horizontal — flat color | BrandLogo |
| `0ded4d6e4b853163a1dbcefce0ae1856` | Logo horizontal — for dark bg (iPad/iPhone splash dark) | BrandLogo, SplashSistem |
| `39d9da24ff2602e976c7a1b30de0277a` | Logo horizontal — white | BrandLogo |
| `4bd7cb4605a3976aa922e9bffb7579ac` | Logo stacked — black (iPad splash mono) | BrandLogo, SplashSistem |
| `59b77cd4e093689eeff5744db10efe92` | Logo stacked — color (iPad splash) | BrandLogo, SplashSistem |
| `78eb19a1fbfb4b1cba6b682dfb0aa5ac` | Logo stacked — white | BrandLogo |
| `b708b308709f1d39dcba085f9a3be713` | Mascot mono — black (220×229) | BrandLogo |
| `476a3429d602be0150cffe24fe3da1bf` | Mascot mono — white (220×229) | BrandLogo |
| `c6f764abf556b8252c9552e7fa94a90d` | Moci happy/cheering mascot (240×240) — sticker 'Moci senang/Happy Moci'; splash + reward screens | BK, Balon, Bay, Ben, Heb, Kar:stickerList, Mew:stickerList, Puz, Sambutan, SplashHP, SplashTablet |
| `0b224341bbd230f2dd731c560e41d4cb` | Moci mascot (240×240) — 'Maskot Moci'; sticker 'Moci'; tracing drag handle | BrandLogo, Bua, Coc, Gal, Gate, HP, Hur, Kal, Kar, Kar:stickerList, Kat, Mew, Mew:stickerList, OT, Per, Puz, Suk, Tulis, Uca |
| `3b4742a95ed4aa3cc8c3b2b2c06b441b` | Wordmark 'Moci' — color with white outline | BrandLogo, SplashSistem |
| `35b5ad5816c337cb237008f09d93bc5c` | Wordmark — black | BrandLogo, SplashSistem |
| `ce0d15fbd117d3c8b4648710365a058c` | Wordmark — flat color | BrandLogo |
| `319e3577776c058debabe88b5d1c2cd9` | Wordmark — navy | BrandLogo |
| `0ef7c3a567e5ba80e2da6c475f32eac4` | Wordmark — white | BrandLogo, SplashSistem |

---

## 4. Asset cross-check (referenced blob ids vs asset store)

- Distinct 32-hex ids referenced anywhere in the 40 artboards (+ canvas.json): **166**; all 166 exist in the store. **Referenced but missing from the store: none.**
- Store assets referenced by no artboard: **6** (all `viewBox="0 0 600 600"`, white fill, ink `#2B2350` stroke 7 — uncolored line-art drafts uploaded 2026-11-13 15:03:31–35, superseded by the 800×600 region data in `Mewarnai.pagesData()`; rendered and inspected):

| asset id | bytes | what it shows |
|---|---|---|
| `1faa850e86de94bec0cfbdbd181e33b3` | 2,338 | butterfly with a smiling face in a garden: sun, cloud, two flowers, wavy ground — the same drawing as the colored `4061ab5b…` (which *is* used as the Mewarnai/Karyaku icon) |
| `95508759720b1934a2bf88520028f15f` | 1,261 | fish with big eye, two seaweed strands, bubbles, wavy sea floor |
| `fbe47133ad1873c0f476362c45364343` | 1,295 | sitting cat with curled tail and whiskers |
| `5fcb18ece05ea077ec368ee9d4eba59b` | 959 | house with chimney, arched door, two windows, bushes, ground line |
| `39e85a8439a5052b4714d3c9113b9122` | 1,072 | side-view car with a cloud and ground line |
| `27393f88d3fbe4b32f5a75f94d9056af` | 1,050 | smiling flower in a pot |

- Template-only references (no content id in data): mascots `0b224341…` (Moci, 17 boards) and `c6f764ab…` (Moci senang, 11 boards), the colored butterfly scene `4061ab5b…` (Main, HP, Galeri, OrangTua), and 42 brand assets (Brand*/Splash* boards only).

## 5. SVG rule check — content illustrations

Script: `(skrip sementara) svgcheck.py` (run with `python3 -I`, file paths as arguments; XML parsed with ElementTree after rejecting DOCTYPE/ENTITY; self-tested against a crafted bad SVG — it reports viewBox, `<style>`, `class`/`style` attributes, gradients, `url()` paint, `<image>`, `<text>`, `<filter>`/`filter=`, `<mask>`/`mask=`, and >12 distinct effective fills, with fill inheritance through `<g>` and the SVG initial black).

| metric | value |
|---|---|
| content illustrations | **107** (docs: 116) |
| total size | **150,761 bytes** (≈147.2 KiB; docs ~147 KB) — min 534, median 1,196, max 7,185 B |
| files with violations | **0** |
| viewBox `0 0 200 200` | 107/107 |
| `<style>`, `style=`, `class=` | 0 |
| gradients / `url()` paint | 0 |
| `<image>`, `<text>` | 0 |
| `filter` / `mask` | 0 |
| colours | all paint values are 6-digit hex attributes (`fill`, `stroke`); no named/rgb()/currentColor |
| distinct fill colours per file | 2–11 (max 11: `1c9d89ce…` eskrim, `81f53fe1…` ayam, `dd80b453…` singa); distribution 2:2, 3:8, 4:24, 5:20, 6:22, 7:15, 8:7, 9:6, 11:3 |
| elements used | path 596, circle 537, ellipse 472, rect 103, g 89, clipPath 31, defs 27 |

Non-violation notes relevant to the export/Flutter renderer:
- 27 files use `<defs><clipPath>` + `clip-path="url(#…)"` (allowed by the rules; renderer must support clipPath).
- 66 files use `transform` attributes; 86 files use `opacity`/`stroke-opacity` attributes.
- 19 files contain 58 stroke-only `<path>`s with no `fill` attribute (default fill = black). 57 are straight segments (zero area, invisible fill); **one curved path in `21ec3ff6…` (dadu): `M56 54C62 48 70 46 80 46` would get a thin black implicit fill** — add `fill="none"` on export.
- Root elements have `xmlns` and `viewBox`, no `width`/`height`.

Non-content assets (not subject to the rule, for awareness): brand icons/banners use `linearGradient` (17 files), `mask` (13 files) and 8 have >12 fills (logos/banners/icon B dark, up to 21); coloring thumbnails are 1–2-colour line art; mascots 9 and 12 fills with clipPath. Per-file results for the 107 content files: Appendix B.

## 6. Mismatches with the docs

| item | docs | prototype |
|---|---|---|
| content illustrations | 116, ~147 KB | **107** files (150,761 B ≈ 147.2 KiB). Size matches, count does not. (107 + 2 mascots + 7 600×600 scenes = 116 — possibly what was counted, but those 9 are not 200×200; with them the size would be 165,334 B.) |
| letters | 26 with example word ID/EN + image | 26 letters but **two separate per-language lists**: different example word *and* different image for 18/26 letters; 38 image keys; extra phonics fields (tts sound, /sound/, letter name); uppercase only; EN X → 'Box' (letter not initial) |
| shapes | 10 with sides, corners | 10, but **no `sides` field**; `corners` = point list (0 for circle/oval/heart, star = 5 "tips"); sides only implied for `poly` |
| sentences | 18, check per-word timing | 18, **no per-word timing stored** (computed `420 + 75 × wordLength` ms at TTS rate 0.75) |
| tracing | 26 + 10 with arrow/start data | 36 glyphs / 63 strokes as `M L H V C` paths; **no arrow, start or numbering data stored** — all derived from path geometry; uppercase letters only |
| coloring pages — sample colours | sample colours per page | only `kupu` has `demo` fills (17) + 1 `ds` stroke; 13 pages have empty `demo`/`ds`; 4 extra demo artworks live in Karyaku |
| stickers | ids and images | **no sticker ids**: 8 `[url, nameID, nameEN]` entries (Mewarnai) / 8 urls (Karyaku), referenced by list index; Hebat album "8 / 30" is hard-coded text |
| game themes | used by Cocokkan/Memori/Bayangan/Puzzle/BesarKecil | 5 themes (21/14/42/9/17 = 103) as expected, embedded 6× (also Kalimat); **Puzzle and BesarKecil never use `sayur`**; Bayangan has no theme choice |
| music — rhythm patterns | rhythm patterns | **one** procedural pattern in code (`beat()`), not data; drums and xylophone are synthesized (no audio files) |
| syllable examples | example words for 41 | 41 **per language** (ID 41 + EN 41, different words) |
| animals | 42 in 5 groups | matches; no audio (code reads missing `a[9]`) |
| numbers | 1–50, 12 count objects | matches |
| fruit/veg | 21 + 14 | matches |
| colours | 11 + 81 tagged | matches (`hitam` has 1 object; id `merah muda` contains a space) |
| Susun Kata | 71 ID + 33 EN | matches |
| syllable grid | 90 (18 × 5) | matches (generated, not stored) |
| coloring pages | 14, 800×600 | matches (294 closed regions, 147 details, 27,871 B) |
| asset store | ~172 | 172 |


---

## Appendix A — asset catalogue (172, listing order = upload order)

| # | asset id | bytes | viewBox | class | label / content id | referenced by |
|---|---|---|---|---|---|---|
| 1 | `0b224341bbd230f2dd731c560e41d4cb` | 1846 | 0 0 240 240 | mascot/UI | Moci mascot (240×240) — 'Maskot Moci'; sticker 'Moci'; tracing drag handle | 17: BrandLogo, Buah, Cocokkan, Galeri, Gate, HP, Huruf, Kalimat, Karyaku, Kata, Mewarnai, OrangTua, Permainan, Puzzle, SukuKata, Tulis, Ucapkan |
| 2 | `c6f764abf556b8252c9552e7fa94a90d` | 2100 | 0 0 240 240 | mascot/UI | Moci happy/cheering mascot (240×240) — sticker 'Moci senang/Happy Moci'; splash + reward screens | 11: Balon, Bayangan, Bentuk, BesarKecil, Hebat, Karyaku, Mewarnai, Puzzle, Sambutan, SplashHP, SplashTablet |
| 3 | `f3ad85e8656c762498e18346c0834e64` | 1090 | 0 0 200 200 | content illustration | apel | 19: Angka, Bayangan, BesarKecil, Buah, Cocokkan, HP, Hebat, Huruf, Kalimat, Karyaku, Kata, Main, Memori, Mewarnai, OrangTua, Permainan, Puzzle, Ucapkan, Warna |
| 4 | `c75dbf0ae357afaddcf97c42d58a1160` | 813 | 0 0 200 200 | content illustration | pisang | 11: Angka, Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, Warna |
| 5 | `59fd969d55c43ab93330b9607a09797b` | 989 | 0 0 200 200 | content illustration | jeruk | 12: Angka, Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 6 | `7e32fcc5a77bca13617a7e9e6ebe6e67` | 2377 | 0 0 200 200 | content illustration | anggur | 10: Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, Warna |
| 7 | `b573b73d242c8297b108f60d1a04c80d` | 798 | 0 0 200 200 | content illustration | semangka | 11: Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 8 | `c5b26a2b99c1d84e15e9b08ad81a2811` | 1663 | 0 0 200 200 | content illustration | nanas | 14: Bayangan, BesarKecil, Buah, Cocokkan, HP, Huruf, Kalimat, Kata, Main, Memori, Permainan, Puzzle, SukuKata, Warna |
| 9 | `8a6b053fd31a1f50cc94e69e5242e40f` | 968 | 0 0 200 200 | content illustration | mangga | 11: Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Ucapkan |
| 10 | `09d4664bec1323b432b1b9c812474c22` | 1482 | 0 0 200 200 | content illustration | stroberi | 12: Angka, Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Karyaku, Memori, Mewarnai, Puzzle, Warna |
| 11 | `3fd7f59fde32f0a08b786024c2ae1816` | 1043 | 0 0 200 200 | content illustration | ceri | 11: Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 12 | `6de067c8bd1b21524d7d6e6b6f4c199a` | 1985 | 0 0 200 200 | content illustration | kucing | 16: Bayangan, BesarKecil, Cocokkan, HP, Hebat, Hewan, Huruf, Kalimat, Kata, Main, Memori, OrangTua, Permainan, Puzzle, SukuKata, Warna |
| 13 | `eb1bebc96da8f6f1ffc1494e0fc98f3f` | 2127 | 0 0 200 200 | content illustration | sapi | 13: Bayangan, BesarKecil, Cocokkan, HP, Hewan, Huruf, Kalimat, Kata, Main, Memori, Puzzle, SukuKata, Ucapkan |
| 14 | `81f53fe15d52afbfe261d665ef8b74ba` | 1396 | 0 0 200 200 | content illustration | ayam | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 15 | `754f0bd7e0eb7cdaa2fd47f6f89b2df2` | 1117 | 0 0 200 200 | content illustration | bebek | 11: Angka, Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 16 | `8cb65c6477727354f6b9ad662449edba` | 1354 | 0 0 200 200 | content illustration | gajah | 12: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Kata, Memori, Permainan, Puzzle, SukuKata, Warna |
| 17 | `ce8b6885ad970a4e66e036e133810b2b` | 1382 | 0 0 200 200 | content illustration | ikan | 16: Angka, Bayangan, BesarKecil, Cocokkan, Hebat, Hewan, Huruf, Kalimat, Karyaku, Kata, Memori, Mewarnai, Puzzle, SukuKata, Ucapkan, Warna |
| 18 | `dd80b453f8b3c290ec0572401fe88fe7` | 1968 | 0 0 200 200 | content illustration | singa | 11: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 19 | `f7d015c440e821b1c7c751875e4327e8` | 1793 | 0 0 200 200 | content illustration | kelinci | 12: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Ucapkan, Warna |
| 20 | `c1c03878fc3cf75b46b14877a58b8a26` | 1204 | 0 0 200 200 | content illustration | flamingo | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Memori, Puzzle, Warna |
| 21 | `4649005d6db1c08190f0c0cd49412f15` | 1290 | 0 0 200 200 | content illustration | quokka | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Memori, Puzzle, Warna |
| 22 | `e7a48678ca5c900be7908c88a20c5a18` | 2054 | 0 0 200 200 | content illustration | zebra | 11: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Ucapkan |
| 23 | `b6ba1bc1e8f26eb3aa05f31a41e7bb31` | 837 | 0 0 200 200 | content illustration | bola | 14: Angka, Bayangan, BesarKecil, Cocokkan, Hebat, Huruf, Kalimat, Karyaku, Kata, Memori, Mewarnai, Puzzle, SukuKata, Ucapkan |
| 24 | `40764645d095695dc89e65d699f811f8` | 824 | 0 0 200 200 | content illustration | buku | 11: Bayangan, BesarKecil, Cocokkan, HP, Kalimat, Kata, Main, Memori, OrangTua, Puzzle, SukuKata |
| 25 | `21ec3ff6cd7241ec48aa204f338666e8` | 637 | 0 0 200 200 | content illustration | dadu | 9: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata |
| 26 | `1c9d89ce71c86ba2d59b5b3b05b5733a` | 1788 | 0 0 200 200 | content illustration | eskrim | 9: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Karyaku, Memori, Mewarnai, Puzzle |
| 27 | `6fbbdd5bf31ab213ee619c8555232539` | 1187 | 0 0 200 200 | content illustration | hujan | 1: Huruf |
| 28 | `b318984ee6d49e39029e199e88367107` | 952 | 0 0 200 200 | content illustration | layang | 8: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Memori, Puzzle, SukuKata |
| 29 | `0505610f29535a954866386a3bf2a5ee` | 2408 | 0 0 200 200 | content illustration | onde | 1: Huruf |
| 30 | `674389f583852b74d45e31c19d339f86` | 851 | 0 0 200 200 | content illustration | rumah | 8: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle |
| 31 | `4ffb45a35e6ab85a85df0806cc4ed5bf` | 783 | 0 0 200 200 | content illustration | topi | 10: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Ucapkan |
| 32 | `2cffab27ed6825a9e2c9fba43d09c3a0` | 1651 | 0 0 200 200 | content illustration | ulat | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Memori, Puzzle, Warna |
| 33 | `1ae5db76439373600d63d870be5b0def` | 1840 | 0 0 200 200 | content illustration | vas | 1: Huruf |
| 34 | `bd07cd5b5330a2434002468d23961755` | 765 | 0 0 200 200 | content illustration | wortel | 13: Bayangan, BesarKecil, Buah, Cocokkan, HP, Huruf, Kalimat, Kata, Main, Memori, Puzzle, SukuKata, Warna |
| 35 | `01c5c505a58f253f0e264c90f0a261fd` | 1196 | 0 0 200 200 | content illustration | xilofon | 9: Bayangan, BesarKecil, Cocokkan, HP, Huruf, Kalimat, Main, Memori, Puzzle |
| 36 | `d8d724511b118aee435cb582d2599023` | 750 | 0 0 200 200 | content illustration | yoyo | 11: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Ucapkan, Warna |
| 37 | `1faa850e86de94bec0cfbdbd181e33b3` | 2338 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: butterfly in garden with sun, cloud, 2 flowers (same drawing as 4061ab5b, no fills) | **none** |
| 38 | `4061ab5bce10e62e630528c89ad08553` | 2652 | 0 0 600 600 | mascot/UI | Colored butterfly garden scene (600×600) — 'Mewarnai' home tile, Karyaku card in Galeri, OrangTua module icon | 4: Galeri, HP, Main, OrangTua |
| 39 | `95508759720b1934a2bf88520028f15f` | 1261 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: fish with seaweed, waves, bubbles | **none** |
| 40 | `fbe47133ad1873c0f476362c45364343` | 1295 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: sitting cat with curled tail | **none** |
| 41 | `5fcb18ece05ea077ec368ee9d4eba59b` | 959 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: house with chimney, door, 2 windows, bushes | **none** |
| 42 | `39e85a8439a5052b4714d3c9113b9122` | 1072 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: car with cloud and ground line | **none** |
| 43 | `27393f88d3fbe4b32f5a75f94d9056af` | 1050 | 0 0 600 600 | coloring outline (600×600) | UNREFERENCED — uncolored line-art: smiling flower in a pot | **none** |
| 44 | `e030d26c76d42274c76cf645c9e57bee` | 1359 | 0 0 200 200 | content illustration | ubur | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 45 | `90b95302252dae3e8124a563dbc7cf78` | 1150 | 0 0 200 200 | content illustration | sarang | 2: Huruf, Warna |
| 46 | `af7684512ef48e45fd48313f41839ba0` | 917 | 0 0 200 200 | content illustration | tomat | 11: Bayangan, BesarKecil, Buah, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 47 | `f80f0f94891ce851b0295abb6cdfc6b3` | 1091 | 0 0 200 200 | content illustration | payung | 8: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Kata, Memori, Puzzle |
| 48 | `d8346c1de7889660d9773e168f62ec9b` | 1111 | 0 0 200 200 | content illustration | igloo | 8: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Memori, Puzzle, Warna |
| 49 | `b56f04945cb0c68002805a3329cf26c5` | 1277 | 0 0 200 200 | content illustration | gurita | 11: Bayangan, BesarKecil, Cocokkan, Hewan, Huruf, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 50 | `89f1eaa66e0150028701c8f5c32dab8c` | 777 | 0 0 200 200 | content illustration | kado | 12: Bayangan, BesarKecil, Cocokkan, Huruf, Kalimat, Karyaku, Kata, Memori, Mewarnai, Puzzle, SukuKata, Warna |
| 51 | `f3f17810ba3333dafaa73fd14014629b` | 6287 | 0 0 800 600 | coloring thumbnail | kupu | 2: Galeri, Mewarnai |
| 52 | `08facf88ddb4bdf4b469fb7baf18aee5` | 3294 | 0 0 800 600 | coloring thumbnail | ikan | 2: Galeri, Mewarnai |
| 53 | `11b0a88f8ebcc3f9ee0bef891976ebbc` | 4385 | 0 0 800 600 | coloring thumbnail | kucing | 2: Galeri, Mewarnai |
| 54 | `e9a05d1b132bbff74f749600fc842bce` | 5127 | 0 0 800 600 | coloring thumbnail | rumah | 2: Galeri, Mewarnai |
| 55 | `80d57340d7a04979966c6987151f8149` | 4812 | 0 0 800 600 | coloring thumbnail | mobil | 2: Galeri, Mewarnai |
| 56 | `a6e8841e95adbb1cee88ec689bff8c75` | 4674 | 0 0 800 600 | coloring thumbnail | bunga | 2: Galeri, Mewarnai |
| 57 | `6a3c5b2df4d80f6bca66f129b80924df` | 6123 | 0 0 800 600 | coloring thumbnail | gajah | 2: Galeri, Mewarnai |
| 58 | `7cd2fd356f2b7bd679ded4fa7d3a4080` | 4442 | 0 0 800 600 | coloring thumbnail | dino | 2: Galeri, Mewarnai |
| 59 | `6d648e7114505f118092a3c663226a46` | 3751 | 0 0 800 600 | coloring thumbnail | roket | 2: Galeri, Mewarnai |
| 60 | `c11dc33d6c0c3f2549d2a1535f1b1282` | 4944 | 0 0 800 600 | coloring thumbnail | kapal | 2: Galeri, Mewarnai |
| 61 | `d43e8992671c82a372fe69dab7b13707` | 4533 | 0 0 800 600 | coloring thumbnail | kue | 2: Galeri, Mewarnai |
| 62 | `083409af4b96c7b7f100b4df2d1f66e8` | 4998 | 0 0 800 600 | coloring thumbnail | hantu | 2: Galeri, Mewarnai |
| 63 | `3316bfaf816f7653b77542fbf30cd0e4` | 3396 | 0 0 800 600 | coloring thumbnail | pelangi | 2: Galeri, Mewarnai |
| 64 | `5a0c0aeebf5ba88e69c75c1b4e150baf` | 3882 | 0 0 800 600 | coloring thumbnail | eskrim | 2: Galeri, Mewarnai |
| 65 | `5f73428052239896d0b19d90bbdca29c` | 688 | 0 0 200 200 | content illustration | alpukat | 8: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, Warna |
| 66 | `c242939ae5225d55061992c4a9c3f53a` | 1599 | 0 0 200 200 | content illustration | anjing | 8: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Memori, Puzzle, SukuKata |
| 67 | `246ed92afd22d9cd0b627495a965b7d8` | 1409 | 0 0 200 200 | content illustration | badak | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 68 | `92d5ae7160761db50ac2050b7ab1a4d5` | 1181 | 0 0 200 200 | content illustration | balon | 8: Angka, Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle |
| 69 | `f87ae2fa3c291525aa0f9743c06faae0` | 1279 | 0 0 200 200 | content illustration | bawang | 7: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle |
| 70 | `6227b1cc8d2743c5fdb255f35b6ac00e` | 1545 | 0 0 200 200 | content illustration | beruang | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 71 | `112a01a0bb2ec54bcc9c5d82c4483374` | 887 | 0 0 200 200 | content illustration | brokoli | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 72 | `ab38e88101d413a3d63b42752d453205` | 2508 | 0 0 200 200 | content illustration | buahnaga | 8: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, Warna |
| 73 | `e257162228dd7c14327b984fc28fedd7` | 1753 | 0 0 200 200 | content illustration | buaya | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 74 | `6fbf958d791ba2f93fe3fec3baef7668` | 792 | 0 0 200 200 | content illustration | buncis | 8: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, Warna |
| 75 | `a09858b43e75375a000f2d1c491d9333` | 1123 | 0 0 200 200 | content illustration | bunga | 9: Angka, Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 76 | `a5705cd1aa08b59d26872e7d4381cf2b` | 1361 | 0 0 200 200 | content illustration | burung | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 77 | `c26166f1dd3bb0c3f4b4b44cf09a5d4f` | 1407 | 0 0 200 200 | content illustration | burunghantu | 8: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Memori, Puzzle, Warna |
| 78 | `5fa24324963167da186e12222fc34b6a` | 921 | 0 0 200 200 | content illustration | bus | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 79 | `59862cf8071958f919b8bc19c09b5360` | 564 | 0 0 200 200 | content illustration | cabai | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 80 | `c780d1ee0c9956db8125fe76ed646f3d` | 2714 | 0 0 200 200 | content illustration | domba | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 81 | `e2d12c8abf7cbc81caa370e3127314c8` | 2121 | 0 0 200 200 | content illustration | durian | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 82 | `136c12a57e02d6f48327aa4a5aa7e505` | 2640 | 0 0 200 200 | content illustration | harimau | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 83 | `62be577d88c8efa7d0650f8e6fe147ee` | 1004 | 0 0 200 200 | content illustration | helikopter | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 84 | `e08be0e2320e04d93c135ec839e948c3` | 2820 | 0 0 200 200 | content illustration | jagung | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 85 | `8fc15ac4c08d61291754b32791eb1206` | 1113 | 0 0 200 200 | content illustration | jambu | 8: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, Warna |
| 86 | `165cb51bf0986707ffbfb2d921d0e176` | 1006 | 0 0 200 200 | content illustration | jamur | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 87 | `4c3d5f88d1553c3efc658ffde91c904f` | 2299 | 0 0 200 200 | content illustration | jerapah | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 88 | `1c4ae5e05ea5cb5b1c97d7553d420d8f` | 2436 | 0 0 200 200 | content illustration | kambing | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 89 | `893ce2f6a36105a5c6bf9dea02c0bc02` | 534 | 0 0 200 200 | content illustration | kaos | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 90 | `c13e9fd9b35f81a1e2e7c8270df7810b` | 825 | 0 0 200 200 | content illustration | kapal | 7: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle |
| 91 | `bec3ad3d9d42a30492ed1e061fdda4e0` | 1362 | 0 0 200 200 | content illustration | katak | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 92 | `d0a5a178291f6bd0606cb8a325a7c385` | 891 | 0 0 200 200 | content illustration | kelapa | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 93 | `656defb15a88ce7a84799d436f569272` | 971 | 0 0 200 200 | content illustration | kentang | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 94 | `2718e0ad945f18ded680238031a1a768` | 2114 | 0 0 200 200 | content illustration | kepiting | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 95 | `c0044435766474df6769a38a15b41072` | 1208 | 0 0 200 200 | content illustration | kereta | 7: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle |
| 96 | `ad4951cf81893165769f3f647fc54846` | 1624 | 0 0 200 200 | content illustration | komodo | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata |
| 97 | `bb4ae18f2157c2fda0b35c73ac0500a4` | 733 | 0 0 200 200 | content illustration | kubis | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 98 | `cc9b06fecc57b5d105417f65369928a4` | 1614 | 0 0 200 200 | content illustration | kuda | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 99 | `f9fef0ce562868c87a2a2d34583a9a91` | 1353 | 0 0 200 200 | content illustration | kudanil | 8: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Memori, Puzzle, SukuKata |
| 100 | `5175853037660fb2f7ad154418e040ec` | 1033 | 0 0 200 200 | content illustration | kuekecil | 10: Angka, Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 101 | `dbdd2cc62f8a5bd8584cf371fac1c3b5` | 1476 | 0 0 200 200 | content illustration | kupu | 10: Angka, Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 102 | `db916cd9c526fad67c469d232d3e5885` | 1152 | 0 0 200 200 | content illustration | kura | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 103 | `515d2976a430bbde0badf4b3ffcb74a5` | 895 | 0 0 200 200 | content illustration | labu | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 104 | `b79511af670fe0c41fb57609f87bc0d7` | 1747 | 0 0 200 200 | content illustration | lebah | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 105 | `8b60cce55b018ce76778d0e91124dc59` | 863 | 0 0 200 200 | content illustration | lemon | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 106 | `52d07c866db14ef1a0fbd2c42022531a` | 1213 | 0 0 200 200 | content illustration | lumba | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 107 | `75e7e3110acc6c21ed3fdebef127894a` | 840 | 0 0 200 200 | content illustration | manggis | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 108 | `7b51db2aaa58605a7ae15e1af1369775` | 2015 | 0 0 200 200 | content illustration | melon | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 109 | `9a4b52d03d573cb2bb9e7fc33aa00ad6` | 1007 | 0 0 200 200 | content illustration | mobil | 10: Angka, Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 110 | `817145047067c4f962003b16c2f5fe59` | 1726 | 0 0 200 200 | content illustration | monyet | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 111 | `7ed47b04dad452d96a24e6150153b9f5` | 1558 | 0 0 200 200 | content illustration | orangutan | 8: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Memori, Puzzle, Warna |
| 112 | `2aca45982f4d73d88f787d45ec03d315` | 1523 | 0 0 200 200 | content illustration | panda | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata |
| 113 | `b52770bc9ad3fc2ce8c5111f526ebf56` | 648 | 0 0 200 200 | content illustration | paprika | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 114 | `193e7df94e29721da1a2ac0f2f472b53` | 1431 | 0 0 200 200 | content illustration | paus | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 115 | `e656141d6c19c6456cb0733ad9d863f6` | 724 | 0 0 200 200 | content illustration | pepaya | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 116 | `cf3cbdb44abff66623a1b8886c6334a8` | 782 | 0 0 200 200 | content illustration | pesawat | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 117 | `2d6f65aa46663557cff33fa1ac230978` | 1134 | 0 0 200 200 | content illustration | pinguin | 8: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle |
| 118 | `cab62ecc12c60a9bac84afc2e9ebdaa9` | 1007 | 0 0 200 200 | content illustration | pir | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 119 | `b003fadeccd318f540f8d8b84f0432f8` | 6333 | 0 0 200 200 | content illustration | rambutan | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Memori, Puzzle, SukuKata, Warna |
| 120 | `65a1f0b3aa312fc93fd888b8a105ce98` | 776 | 0 0 200 200 | content illustration | roket | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata |
| 121 | `5c40d0968fbcc89166b74a9be572773b` | 1527 | 0 0 200 200 | content illustration | rubah | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 122 | `9a04b8bf05b1e774b527a1e5b07fe2e4` | 7185 | 0 0 200 200 | content illustration | salak | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 123 | `f6df9bbf276d2e186a24f33a3041a600` | 2211 | 0 0 200 200 | content illustration | semut | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 124 | `47d389b3dc6c01d69907d0362050c151` | 609 | 0 0 200 200 | content illustration | sepatu | 8: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 125 | `fd16a4542bf6b07d9b4a88c55c68fb95` | 1149 | 0 0 200 200 | content illustration | sepeda | 7: Bayangan, BesarKecil, Cocokkan, Kalimat, Kata, Memori, Puzzle |
| 126 | `19a19c17820600c0673160b75b8d3f29` | 561 | 0 0 200 200 | content illustration | terong | 10: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 127 | `de9512c85659eedbd04f024fc5074f4b` | 1599 | 0 0 200 200 | content illustration | tikus | 10: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, SukuKata, Warna |
| 128 | `9a8a7f8d87315469e96e98fb1f2b6e65` | 632 | 0 0 200 200 | content illustration | timun | 9: Bayangan, BesarKecil, Buah, Cocokkan, Kalimat, Kata, Memori, Puzzle, Warna |
| 129 | `e64bfdb04579e9fb52398c0da0c80992` | 725 | 0 0 200 200 | content illustration | truk | 7: Bayangan, BesarKecil, Cocokkan, Kalimat, Memori, Puzzle, Warna |
| 130 | `4d73c54d6666d5e184ba443f2597f2d9` | 1237 | 0 0 200 200 | content illustration | ular | 9: Bayangan, BesarKecil, Cocokkan, Hewan, Kalimat, Kata, Memori, Puzzle, Warna |
| 131 | `2145243b8d9b387f59a3b0d6533130f8` | 14830 | 0 0 1280 320 | brand | GitHub README banner — dark (1280×320) | 1: BrandGitHub |
| 132 | `48f15b539cc0f3f20048d6b8f16fb886` | 20275 | 0 0 1280 320 | brand | GitHub README banner — light (1280×320) | 1: BrandGitHub |
| 133 | `3c2f458c2b839d9af96828f0ac327661` | 65726 | 0 0 1280 640 | brand | GitHub social preview (1280×640) | 1: BrandGitHub |
| 134 | `1e6ef630c214ce7938064dd106b7c529` | 2581 | 0 0 1024 1024 | brand | Icon A — dark mode (iOS); Android splash dark | 2: BrandIkonA, SplashSistem |
| 135 | `ede32ac4c9a3f6bfb791c65cc84625ad` | 1533 | 0 0 1024 1024 | brand | Icon A — black & white; Android splash mono | 2: BrandIkonA, SplashSistem |
| 136 | `6027c48450b1b672031bfc4cd0d98133` | 1982 | 0 0 1024 1024 | brand | Icon A (chosen) — sky-blue bg, 1024; also GitHub avatar, Android splash | 3: BrandGitHub, BrandIkonA, SplashSistem |
| 137 | `4b63aa4d20499bc594796ed33ccd157d` | 1981 | 0 0 1024 1024 | brand | Icon A — mint bg | 1: BrandIkonA |
| 138 | `03acfdb693e667925cc065e834e9b879` | 1981 | 0 0 1024 1024 | brand | Icon A — pink bg | 1: BrandIkonA |
| 139 | `3f66fda1cebcd7f29efcb640de919b7d` | 1533 | 0 0 1024 1024 | brand | Icon A — white on black (iOS tinted base) | 1: BrandIkonA |
| 140 | `a7de9580470b7b96c9f5ddd940bb8fad` | 1533 | 0 0 1024 1024 | brand | Icon A — Android themed | 1: BrandIkonA |
| 141 | `6d02d35e2d2599bec868f39446c1293b` | 1982 | 0 0 1024 1024 | brand | Icon A — purple bg | 1: BrandIkonA |
| 142 | `003c2a9f96594716fda92027c1ecc753` | 3203 | 0 0 1024 1024 | brand | Icon B — dark mode | 1: BrandIkonB |
| 143 | `71c9e2d0f572e70720afd1c0f902bd1e` | 3127 | 0 0 1024 1024 | brand | Icon B — black & white | 1: BrandIkonB |
| 144 | `cd00165a30fd4b4b40318c4f0123c0fb` | 2604 | 0 0 1024 1024 | brand | Icon B — sky-blue bg (main) | 1: BrandIkonB |
| 145 | `ccf3dda513a3502c6fc54e80146d70ab` | 2603 | 0 0 1024 1024 | brand | Icon B — mint bg | 1: BrandIkonB |
| 146 | `ca91acce0efce98ca95a2fdf5acb3a55` | 2603 | 0 0 1024 1024 | brand | Icon B — pink bg | 1: BrandIkonB |
| 147 | `a5b210d2f0555d297ae65389f9ac9be2` | 3127 | 0 0 1024 1024 | brand | Icon B — white on black | 1: BrandIkonB |
| 148 | `50997f1207d724de15a3a64de3083247` | 3127 | 0 0 1024 1024 | brand | Icon B — Android themed | 1: BrandIkonB |
| 149 | `8d0671d39024d63355c33c3b1a89a610` | 2604 | 0 0 1024 1024 | brand | Icon B — purple bg | 1: BrandIkonB |
| 150 | `c9ef0d82ca2ec065650161bdad9f0545` | 5802 | 0 0 1024 1024 | brand | Icon C — dark mode | 1: BrandIkonC |
| 151 | `1173ad00a0418fabc454a42954d1c934` | 1305 | 0 0 1024 1024 | brand | Icon C — black & white | 1: BrandIkonC |
| 152 | `b277ed60ce0084846c2a1e900f890f64` | 5042 | 0 0 1024 1024 | brand | Icon C — cream bg (main) | 1: BrandIkonC |
| 153 | `8e4fc445da1929a07c58b44808e35475` | 7014 | 0 0 1024 1024 | brand | Icon C — sky-blue bg | 1: BrandIkonC |
| 154 | `3977f676b1a39a31ebc24dde2bbb2edd` | 7014 | 0 0 1024 1024 | brand | Icon C — mint bg | 1: BrandIkonC |
| 155 | `08f0679f90e47dbccd1ae9a801e4fd72` | 1305 | 0 0 1024 1024 | brand | Icon C — white on black | 1: BrandIkonC |
| 156 | `d285b1b340fd04c51cf74af3c5c3c9a6` | 1305 | 0 0 1024 1024 | brand | Icon C — Android themed | 1: BrandIkonC |
| 157 | `86e3f0fa6534603f64af12950da4cd33` | 7014 | 0 0 1024 1024 | brand | Icon C — purple bg | 1: BrandIkonC |
| 158 | `4bd7cb4605a3976aa922e9bffb7579ac` | 12960 | 0 0 432.1 581.1 | brand | Logo stacked — black (iPad splash mono) | 2: BrandLogo, SplashSistem |
| 159 | `78eb19a1fbfb4b1cba6b682dfb0aa5ac` | 12960 | 0 0 432.1 581.1 | brand | Logo stacked — white | 1: BrandLogo |
| 160 | `59b77cd4e093689eeff5744db10efe92` | 19409 | 0 0 464.4 610.5 | brand | Logo stacked — color (iPad splash) | 2: BrandLogo, SplashSistem |
| 161 | `7dfad8f1839a8ac8216ed11376b1cad3` | 12595 | 0 0 792.3 284.4 | brand | Logo horizontal — flat color | 1: BrandLogo |
| 162 | `0ded4d6e4b853163a1dbcefce0ae1856` | 18906 | 0 0 811 313.4 | brand | Logo horizontal — for dark bg (iPad/iPhone splash dark) | 2: BrandLogo, SplashSistem |
| 163 | `bbb2ba7de6d453206301ce65a1af50e0` | 12341 | 0 0 792.3 284.4 | brand | Logo horizontal — black (iPhone splash mono) | 2: BrandLogo, SplashSistem |
| 164 | `39d9da24ff2602e976c7a1b30de0277a` | 12341 | 0 0 792.3 284.4 | brand | Logo horizontal — white | 1: BrandLogo |
| 165 | `7b6ebd972f1e877f40d58858975b909b` | 18906 | 0 0 811 313.4 | brand | Logo horizontal — color (iPhone splash) | 2: BrandLogo, SplashSistem |
| 166 | `b708b308709f1d39dcba085f9a3be713` | 1593 | 0 0 220 229 | brand | Mascot mono — black (220×229) | 1: BrandLogo |
| 167 | `476a3429d602be0150cffe24fe3da1bf` | 1593 | 0 0 220 229 | brand | Mascot mono — white (220×229) | 1: BrandLogo |
| 168 | `ce0d15fbd117d3c8b4648710365a058c` | 3068 | 0 0 445.6 165.2 | brand | Wordmark — flat color | 1: BrandLogo |
| 169 | `35b5ad5816c337cb237008f09d93bc5c` | 3030 | 0 0 445.6 165.2 | brand | Wordmark — black | 2: BrandLogo, SplashSistem |
| 170 | `319e3577776c058debabe88b5d1c2cd9` | 3030 | 0 0 445.6 165.2 | brand | Wordmark — navy | 1: BrandLogo |
| 171 | `0ef7c3a567e5ba80e2da6c475f32eac4` | 3030 | 0 0 445.6 165.2 | brand | Wordmark — white | 2: BrandLogo, SplashSistem |
| 172 | `3b4742a95ed4aa3cc8c3b2b2c06b441b` | 9014 | 0 0 479.6 213.2 | brand | Wordmark 'Moci' — color with white outline | 2: BrandLogo, SplashSistem |

## Appendix B — SVG rule check per content file (107)

| # | blob | content id | bytes | distinct fills | elements | violations | notes |
|---|---|---|---|---|---|---|---|
| 1 | `5f73428052239896d0b19d90bbdca29c` | `alpukat` | 688 | 4 | circle 1, ellipse 2, path 2 | none | opacity×2, transform |
| 2 | `7e32fcc5a77bca13617a7e9e6ebe6e67` | `anggur` | 2377 | 4 | circle 30, g 10, path 3 | none | opacity×10, transform |
| 3 | `c242939ae5225d55061992c4a9c3f53a` | `anjing` | 1599 | 8 | circle 3, ellipse 14, path 2 | none | opacity×2, transform |
| 4 | `f3ad85e8656c762498e18346c0834e64` | `apel` | 1090 | 4 | clipPath 1, defs 1, ellipse 1, g 1, path 6 | none | clipPath×1, opacity×1, transform |
| 5 | `81f53fe15d52afbfe261d665ef8b74ba` | `ayam` | 1396 | 11 | circle 5, ellipse 4, path 8 | none | unfilled stroke path(s) (default fill), opacity×1 |
| 6 | `246ed92afd22d9cd0b627495a965b7d8` | `badak` | 1409 | 6 | circle 2, ellipse 4, path 5, rect 4 | none | opacity×1, transform |
| 7 | `92d5ae7160761db50ac2050b7ab1a4d5` | `balon` | 1181 | 4 | ellipse 6, path 6 | none | opacity×3, transform |
| 8 | `f87ae2fa3c291525aa0f9743c06faae0` | `bawang` | 1279 | 3 | clipPath 1, defs 1, ellipse 1, g 1, path 7 | none | clipPath×1, opacity×1, transform |
| 9 | `754f0bd7e0eb7cdaa2fd47f6f89b2df2` | `bebek` | 1117 | 7 | circle 2, ellipse 5, path 6 | none | unfilled stroke path(s) (default fill), opacity×1 |
| 10 | `6227b1cc8d2743c5fdb255f35b6ac00e` | `beruang` | 1545 | 6 | circle 7, ellipse 12, path 1 | none | opacity×2, transform |
| 11 | `b6ba1bc1e8f26eb3aa05f31a41e7bb31` | `bola` | 837 | 4 | circle 4, clipPath 1, defs 1, ellipse 1, g 2, path 3 | none | clipPath×1, opacity×2, transform |
| 12 | `112a01a0bb2ec54bcc9c5d82c4483374` | `brokoli` | 887 | 5 | circle 12, ellipse 1, path 1 | none | opacity×1 |
| 13 | `ab38e88101d413a3d63b42752d453205` | `buahnaga` | 2508 | 6 | ellipse 26 | none | opacity×1, transform |
| 14 | `e257162228dd7c14327b984fc28fedd7` | `buaya` | 1753 | 7 | circle 6, ellipse 10, path 8, rect 1 | none | opacity×1 |
| 15 | `40764645d095695dc89e65d699f811f8` | `buku` | 824 | 6 | g 1, path 4, rect 4 | none | unfilled stroke path(s) (default fill), transform |
| 16 | `6fbf958d791ba2f93fe3fec3baef7668` | `buncis` | 792 | 3 | path 5 | none | transform |
| 17 | `a09858b43e75375a000f2d1c491d9333` | `bunga` | 1123 | 5 | circle 8, ellipse 4, path 2 | none | transform |
| 18 | `a5705cd1aa08b59d26872e7d4381cf2b` | `burung` | 1361 | 7 | circle 3, ellipse 7, path 5 | none | opacity×2, transform |
| 19 | `c26166f1dd3bb0c3f4b4b44cf09a5d4f` | `burunghantu` | 1407 | 7 | circle 6, ellipse 6, path 5 | none | transform |
| 20 | `5fa24324963167da186e12222fc34b6a` | `bus` | 921 | 6 | circle 5, path 1, rect 6 | none |  |
| 21 | `59862cf8071958f919b8bc19c09b5360` | `cabai` | 564 | 2 | path 4 | none | opacity×1 |
| 22 | `3fd7f59fde32f0a08b786024c2ae1816` | `ceri` | 1043 | 4 | circle 6, clipPath 2, defs 1, ellipse 2, g 2, path 3 | none | clipPath×2, opacity×2, transform |
| 23 | `21ec3ff6cd7241ec48aa204f338666e8` | `dadu` | 637 | 4 | circle 5, g 2, path 1, rect 2 | none | unfilled stroke path(s) (default fill), opacity×1, transform |
| 24 | `c780d1ee0c9956db8125fe76ed646f3d` | `domba` | 2714 | 6 | circle 24, ellipse 6, path 1, rect 4 | none | opacity×2, transform |
| 25 | `e2d12c8abf7cbc81caa370e3127314c8` | `durian` | 2121 | 4 | ellipse 2, path 29, rect 1 | none | opacity×1, transform |
| 26 | `1c9d89ce71c86ba2d59b5b3b05b5733a` | `eskrim` | 1788 | 11 | circle 3, clipPath 1, defs 1, ellipse 2, g 2, path 10, rect 6 | none | clipPath×1, unfilled stroke path(s) (default fill), opacity×2, transform |
| 27 | `c1c03878fc3cf75b46b14877a58b8a26` | `flamingo` | 1204 | 6 | circle 3, ellipse 2, path 8 | none | unfilled stroke path(s) (default fill), opacity×1 |
| 28 | `8cb65c6477727354f6b9ad662449edba` | `gajah` | 1354 | 8 | circle 7, ellipse 7, path 3 | none | unfilled stroke path(s) (default fill), opacity×3 |
| 29 | `b56f04945cb0c68002805a3329cf26c5` | `gurita` | 1277 | 5 | circle 5, ellipse 6, g 2, path 6 | none | opacity×3, transform |
| 30 | `136c12a57e02d6f48327aa4a5aa7e505` | `harimau` | 2640 | 7 | circle 7, ellipse 9, path 12 | none | opacity×2 |
| 31 | `62be577d88c8efa7d0650f8e6fe147ee` | `helikopter` | 1004 | 5 | circle 1, ellipse 2, path 5, rect 2 | none | opacity×1, transform |
| 32 | `6fbbdd5bf31ab213ee619c8555232539` | `hujan` | 1187 | 5 | circle 6, ellipse 4, g 3, path 4, rect 2 | none | opacity×2 |
| 33 | `d8346c1de7889660d9773e168f62ec9b` | `igloo` | 1111 | 5 | circle 4, clipPath 1, defs 1, ellipse 1, g 3, path 7 | none | clipPath×1 |
| 34 | `ce8b6885ad970a4e66e036e133810b2b` | `ikan` | 1382 | 6 | circle 5, clipPath 1, defs 1, ellipse 6, g 3, path 6 | none | clipPath×1, opacity×2, transform |
| 35 | `e08be0e2320e04d93c135ec839e948c3` | `jagung` | 2820 | 4 | circle 39, ellipse 1, path 4 | none |  |
| 36 | `8fc15ac4c08d61291754b32791eb1206` | `jambu` | 1113 | 5 | clipPath 1, defs 1, ellipse 2, g 1, path 4, rect 1 | none | clipPath×1, opacity×1, transform |
| 37 | `165cb51bf0986707ffbfb2d921d0e176` | `jamur` | 1006 | 4 | circle 7, ellipse 2, path 3 | none |  |
| 38 | `4c3d5f88d1553c3efc658ffde91c904f` | `jerapah` | 2299 | 7 | circle 9, ellipse 7, path 5, rect 8 | none | opacity×1, transform |
| 39 | `59fd969d55c43ab93330b9607a09797b` | `jeruk` | 989 | 6 | circle 12, clipPath 1, defs 1, ellipse 1, g 2, path 2 | none | clipPath×1, unfilled stroke path(s) (default fill), opacity×2, transform |
| 40 | `89f1eaa66e0150028701c8f5c32dab8c` | `kado` | 777 | 7 | circle 5, g 1, path 2, rect 4 | none | opacity×1 |
| 41 | `1c4ae5e05ea5cb5b1c97d7553d420d8f` | `kambing` | 2436 | 8 | circle 4, ellipse 9, path 4, rect 8 | none | opacity×2, transform |
| 42 | `893ce2f6a36105a5c6bf9dea02c0bc02` | `kaos` | 534 | 2 | path 3 | none |  |
| 43 | `c13e9fd9b35f81a1e2e7c8270df7810b` | `kapal` | 825 | 6 | circle 5, path 3, rect 3 | none |  |
| 44 | `bec3ad3d9d42a30492ed1e061fdda4e0` | `katak` | 1362 | 6 | circle 8, ellipse 9, path 1 | none | opacity×2, transform |
| 45 | `d0a5a178291f6bd0606cb8a325a7c385` | `kelapa` | 891 | 5 | clipPath 1, defs 1, ellipse 3, g 1, path 5 | none | clipPath×1, opacity×1, transform |
| 46 | `f7d015c440e821b1c7c751875e4327e8` | `kelinci` | 1793 | 8 | circle 3, ellipse 11, g 1, path 7, rect 1 | none | unfilled stroke path(s) (default fill), opacity×2, transform |
| 47 | `656defb15a88ce7a84799d436f569272` | `kentang` | 971 | 4 | clipPath 1, defs 1, ellipse 6, g 1, path 3 | none | clipPath×1, opacity×1, transform |
| 48 | `2718e0ad945f18ded680238031a1a768` | `kepiting` | 2114 | 4 | circle 4, ellipse 3, path 13 | none | opacity×2 |
| 49 | `c0044435766474df6769a38a15b41072` | `kereta` | 1208 | 9 | circle 10, path 1, rect 7 | none |  |
| 50 | `ad4951cf81893165769f3f647fc54846` | `komodo` | 1624 | 6 | circle 7, ellipse 8, path 4 | none | opacity×1, transform |
| 51 | `bb4ae18f2157c2fda0b35c73ac0500a4` | `kubis` | 733 | 4 | circle 2, ellipse 1, path 3 | none | opacity×1, transform |
| 52 | `6de067c8bd1b21524d7d6e6b6f4c199a` | `kucing` | 1985 | 8 | circle 3, ellipse 8, g 2, path 14 | none | unfilled stroke path(s) (default fill), opacity×3 |
| 53 | `cc9b06fecc57b5d105417f65369928a4` | `kuda` | 1614 | 7 | circle 2, ellipse 5, path 5, rect 8 | none | opacity×1, transform |
| 54 | `f9fef0ce562868c87a2a2d34583a9a91` | `kudanil` | 1353 | 6 | circle 4, ellipse 11, path 1, rect 2 | none | opacity×2 |
| 55 | `5175853037660fb2f7ad154418e040ec` | `kuekecil` | 1033 | 6 | circle 1, path 4, rect 4 | none | transform |
| 56 | `dbdd2cc62f8a5bd8584cf371fac1c3b5` | `kupu` | 1476 | 5 | circle 9, ellipse 5, path 3 | none | opacity×2, transform |
| 57 | `db916cd9c526fad67c469d232d3e5885` | `kura` | 1152 | 7 | circle 2, ellipse 5, path 6, rect 1 | none | opacity×2, transform |
| 58 | `515d2976a430bbde0badf4b3ffcb74a5` | `labu` | 895 | 4 | ellipse 4, path 4 | none | opacity×1, transform |
| 59 | `b318984ee6d49e39029e199e88367107` | `layang` | 952 | 6 | g 1, path 7 | none | unfilled stroke path(s) (default fill), opacity×1, transform |
| 60 | `b79511af670fe0c41fb57609f87bc0d7` | `lebah` | 1747 | 5 | circle 4, clipPath 1, defs 1, ellipse 7, g 1, path 5, rect 2 | none | clipPath×1, opacity×2, transform |
| 61 | `8b60cce55b018ce76778d0e91124dc59` | `lemon` | 863 | 4 | clipPath 1, defs 1, ellipse 4, g 1, path 4 | none | clipPath×1, opacity×1, transform |
| 62 | `52d07c866db14ef1a0fbd2c42022531a` | `lumba` | 1213 | 7 | circle 4, ellipse 3, path 6 | none | opacity×1, transform |
| 63 | `8a6b053fd31a1f50cc94e69e5242e40f` | `mangga` | 968 | 5 | clipPath 1, defs 1, ellipse 2, g 1, path 6 | none | clipPath×1, opacity×2, transform |
| 64 | `75e7e3110acc6c21ed3fdebef127894a` | `manggis` | 840 | 6 | clipPath 1, defs 1, ellipse 4, g 1, path 3, rect 1 | none | clipPath×1, opacity×1, transform |
| 65 | `7b51db2aaa58605a7ae15e1af1369775` | `melon` | 2015 | 3 | clipPath 1, defs 1, ellipse 1, g 2, path 14 | none | clipPath×1, opacity×1, transform |
| 66 | `9a4b52d03d573cb2bb9e7fc33aa00ad6` | `mobil` | 1007 | 6 | circle 5, path 5, rect 1 | none |  |
| 67 | `817145047067c4f962003b16c2f5fe59` | `monyet` | 1726 | 6 | circle 9, ellipse 8, path 4 | none | opacity×2 |
| 68 | `c5b26a2b99c1d84e15e9b08ad81a2811` | `nanas` | 1663 | 7 | clipPath 1, defs 1, ellipse 4, g 3, path 23 | none | clipPath×1, unfilled stroke path(s) (default fill), opacity×2, transform |
| 69 | `0505610f29535a954866386a3bf2a5ee` | `onde` | 2408 | 5 | circle 9, clipPath 3, defs 1, ellipse 21, g 6 | none | clipPath×3, opacity×1, transform |
| 70 | `7ed47b04dad452d96a24e6150153b9f5` | `orangutan` | 1558 | 7 | circle 7, ellipse 7, path 4 | none | opacity×2 |
| 71 | `2aca45982f4d73d88f787d45ec03d315` | `panda` | 1523 | 4 | circle 7, ellipse 10, path 1 | none | opacity×2, transform |
| 72 | `b52770bc9ad3fc2ce8c5111f526ebf56` | `paprika` | 648 | 4 | ellipse 2, path 3 | none | opacity×1, transform |
| 73 | `193e7df94e29721da1a2ac0f2f472b53` | `paus` | 1431 | 7 | circle 4, ellipse 3, path 7 | none | opacity×1, transform |
| 74 | `f80f0f94891ce851b0295abb6cdfc6b3` | `payung` | 1091 | 5 | circle 1, clipPath 1, defs 1, g 2, path 8 | none | clipPath×1 |
| 75 | `e656141d6c19c6456cb0733ad9d863f6` | `pepaya` | 724 | 5 | circle 6, ellipse 4 | none | opacity×1, transform |
| 76 | `cf3cbdb44abff66623a1b8886c6334a8` | `pesawat` | 782 | 4 | circle 4, path 5, rect 1 | none |  |
| 77 | `2d6f65aa46663557cff33fa1ac230978` | `pinguin` | 1134 | 5 | circle 2, ellipse 11, path 1 | none | opacity×2, transform |
| 78 | `cab62ecc12c60a9bac84afc2e9ebdaa9` | `pir` | 1007 | 4 | clipPath 1, defs 1, ellipse 2, g 1, path 4 | none | clipPath×1, opacity×1, transform |
| 79 | `c75dbf0ae357afaddcf97c42d58a1160` | `pisang` | 813 | 4 | circle 1, clipPath 1, defs 1, g 1, path 5 | none | clipPath×1, opacity×1, transform |
| 80 | `4649005d6db1c08190f0c0cd49412f15` | `quokka` | 1290 | 9 | circle 6, ellipse 11, path 1 | none | opacity×2 |
| 81 | `b003fadeccd318f540f8d8b84f0432f8` | `rambutan` | 6333 | 4 | circle 30, clipPath 1, defs 1, ellipse 1, g 1, path 33 | none | clipPath×1, opacity×1, transform |
| 82 | `65a1f0b3aa312fc93fd888b8a105ce98` | `roket` | 776 | 6 | circle 2, path 6, rect 1 | none |  |
| 83 | `5c40d0968fbcc89166b74a9be572773b` | `rubah` | 1527 | 6 | circle 2, ellipse 9, path 9 | none | opacity×2 |
| 84 | `674389f583852b74d45e31c19d339f86` | `rumah` | 851 | 9 | circle 1, path 3, rect 6 | none | unfilled stroke path(s) (default fill) |
| 85 | `9a04b8bf05b1e774b527a1e5b07fe2e4` | `salak` | 7185 | 3 | clipPath 1, defs 1, ellipse 1, g 2, path 52 | none | clipPath×1, opacity×1, transform |
| 86 | `eb1bebc96da8f6f1ffc1494e0fc98f3f` | `sapi` | 2127 | 9 | circle 3, clipPath 2, defs 1, ellipse 20, g 2, path 2 | none | clipPath×2, transform |
| 87 | `90b95302252dae3e8124a563dbc7cf78` | `sarang` | 1150 | 7 | circle 3, ellipse 7, g 3, path 8 | none | opacity×2 |
| 88 | `b573b73d242c8297b108f60d1a04c80d` | `semangka` | 798 | 4 | ellipse 5, g 2, path 4 | none | transform |
| 89 | `f6df9bbf276d2e186a24f33a3041a600` | `semut` | 2211 | 4 | circle 7, ellipse 6, path 9 | none | opacity×4, transform |
| 90 | `47d389b3dc6c01d69907d0362050c151` | `sepatu` | 609 | 3 | circle 1, ellipse 1, path 2, rect 1 | none | opacity×1 |
| 91 | `fd16a4542bf6b07d9b4a88c55c68fb95` | `sepeda` | 1149 | 3 | circle 5, ellipse 1, path 5 | none |  |
| 92 | `dd80b453f8b3c290ec0572401fe88fe7` | `singa` | 1968 | 11 | circle 22, ellipse 8, g 2, path 2 | none | opacity×2 |
| 93 | `09d4664bec1323b432b1b9c812474c22` | `stroberi` | 1482 | 6 | clipPath 1, defs 1, ellipse 11, g 2, path 5 | none | clipPath×1, unfilled stroke path(s) (default fill), opacity×1, transform |
| 94 | `19a19c17820600c0673160b75b8d3f29` | `terong` | 561 | 3 | ellipse 1, path 3 | none | opacity×1, transform |
| 95 | `de9512c85659eedbd04f024fc5074f4b` | `tikus` | 1599 | 7 | circle 8, ellipse 8, path 3 | none | opacity×2 |
| 96 | `9a8a7f8d87315469e96e98fb1f2b6e65` | `timun` | 632 | 3 | circle 6, rect 2 | none | opacity×1, transform |
| 97 | `af7684512ef48e45fd48313f41839ba0` | `tomat` | 917 | 5 | clipPath 1, defs 1, ellipse 1, g 1, path 5 | none | clipPath×1, unfilled stroke path(s) (default fill), opacity×1, transform |
| 98 | `4ffb45a35e6ab85a85df0806cc4ed5bf` | `topi` | 783 | 6 | circle 6, ellipse 3, g 1, path 2 | none | opacity×1, transform |
| 99 | `e64bfdb04579e9fb52398c0da0c80992` | `truk` | 725 | 8 | circle 5, path 2, rect 3 | none |  |
| 100 | `e030d26c76d42274c76cf645c9e57bee` | `ubur` | 1359 | 5 | circle 4, ellipse 4, g 1, path 7 | none | opacity×3 |
| 101 | `4d73c54d6666d5e184ba443f2597f2d9` | `ular` | 1237 | 4 | circle 2, ellipse 5, path 4 | none | opacity×2 |
| 102 | `2cffab27ed6825a9e2c9fba43d09c3a0` | `ulat` | 1651 | 8 | circle 13, ellipse 8, g 2, path 3 | none | opacity×3 |
| 103 | `1ae5db76439373600d63d870be5b0def` | `vas` | 1840 | 9 | circle 18, ellipse 3, g 3, path 5, rect 1 | none | unfilled stroke path(s) (default fill), opacity×1, transform |
| 104 | `bd07cd5b5330a2434002468d23961755` | `wortel` | 765 | 5 | ellipse 4, g 2, path 5 | none | unfilled stroke path(s) (default fill), opacity×1, transform |
| 105 | `01c5c505a58f253f0e264c90f0a261fd` | `xilofon` | 1196 | 9 | circle 12, g 1, path 2, rect 5 | none | unfilled stroke path(s) (default fill), opacity×1 |
| 106 | `d8d724511b118aee435cb582d2599023` | `yoyo` | 750 | 5 | circle 8, g 1, path 2 | none | unfilled stroke path(s) (default fill), opacity×1 |
| 107 | `e7a48678ca5c900be7908c88a20c5a18` | `zebra` | 2054 | 5 | circle 4, clipPath 1, defs 1, ellipse 7, g 2, path 14 | none | clipPath×1, opacity×2 |
