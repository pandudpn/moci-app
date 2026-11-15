# Moci animal sounds

**Decision as of 14 November 2026:** every animal sound comes from [Freesound](https://freesound.org) under the Creative Commons 0 (CC0) license. CC0 files may be committed to this public repo. Pixabay and the CC BY license are not used.

Moci needs 42 sounds, one for each animal in the Animal World (Dunia Hewan) menu. About 30 animals use real sound recordings. The other 12 animals have no distinctive sound, for example fish, ants, and butterflies, so they use a funny effect that matches their imitation sound in the catalog.

The animal list, ids, and imitation sounds below are taken from the prototype (`docs/design/prototype/Hewan.dc.html`). The format and license rules follow the Content & Assets tab in the Moci documentation.

## Why Freesound CC0

- **CC0 means the uploader gives up all rights.** The [Freesound FAQ](https://freesound.org/help/faq/) says CC0 sounds may be used for "pretty much what you want", even sold, as long as we do not claim to be the creator. So the sounds may be trimmed, used in an app released to the stores, and kept in a public repo, with no attribution needed.
- **Pixabay is not used.** The [Pixabay terms](https://pixabay.com/service/terms/) forbid automatic and bulk downloads, and the [license](https://pixabay.com/service/license-summary/) forbids distributing files "standalone". That second ban does not fit a public repo.

## Rules for choosing sounds

- On the sound page, make sure the license says **Creative Commons 0** when you download. Freesound also has CC BY and CC BY-NC, and neither is used.
- CC0 is a statement from the uploader. Skip sounds that sound like a clip from a film, TV show, or game, and sounds whose description mentions another source. Prefer field recordings with a clear description.
- Do not use AI generated sounds of unclear origin.
- Pick ones that are clear, short (at most 3 seconds after trimming), and not scary for small children.
- **If nothing fits in CC0,** record it yourself: the sound of an animal you can easily meet, or an effect made with objects at home. Do not switch to Pixabay or CC BY.

## How it works per animal

1. Log in to Freesound. The account is free, and logging in is required to download.
2. Open the link in the table. The links already carry the Creative Commons 0 filter; if the filter is not applied, choose "Creative Commons 0" in the license filter.
3. Listen to a few options, then download the original file. Keep it in a raw folder **outside the repo**, for example `~/moci-audio-src/hewan/kucing.wav`, with the file name equal to the animal id. Raw files do not need to be committed; only the processed result goes into the repo.
4. Add one line to `assets/audio/LICENSES.csv` with the columns `file,sumber,URL,lisensi,tanggal unduh,catatan` (file, source, URL, license, download date, notes), for example:
   `hewan/kucing.m4a,Freesound,https://freesound.org/s/12345/,CC0,2026-11-20,"by <uploader name>, trimmed to 1.8 seconds"`
   The `lisensi` (license) column may only hold `CC0`, or `Milik sendiri` (literally "own recording") for a recording you made yourself. The content validator rejects every other value. Recording the source and uploader is not required by CC0, but it keeps the origin of every file clear.
5. The audio processing script in Plan 09 turns the raw file into `assets/audio/hewan/<id>.m4a`: mono, at most 3 seconds, AAC, with loudness at −16 LUFS like the narration.

For the 12 animals with a made-up effect, search Freesound for a CC0 effect using the link in the table. If nothing fits, record objects at home. For example a straw blown in a glass of water for "blub blub", a cracker being chewed for "nyam nyam", and paper flapped quickly for the butterfly. Your own recordings are recorded as `Milik sendiri`.

## The list of 42 animals

The "Type" column shows whether the animal uses a real sound recording or a made-up effect. All links are already filtered to Creative Commons 0.

### Pets & Farm animals

| id | Name | Imitation sound (ID / EN) | Type | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `kucing` | Kucing / Cat | Meong! / Meow! | Real recording | [search](https://freesound.org/search/?q=cat+meow&f=license%3A%22Creative+Commons+0%22) |
| `anjing` | Anjing / Dog | Guk guk! / Woof woof! | Real recording | [search](https://freesound.org/search/?q=dog+bark&f=license%3A%22Creative+Commons+0%22) |
| `kelinci` | Kelinci / Rabbit | Hop hop! / Hop hop! | Made-up effect | [search](https://freesound.org/search/?q=cartoon+hop&f=license%3A%22Creative+Commons+0%22) |
| `tikus` | Tikus / Mouse | Cit cit! / Squeak! | Real recording | [search](https://freesound.org/search/?q=mouse+squeak&f=license%3A%22Creative+Commons+0%22) |
| `sapi` | Sapi / Cow | Mooo! / Moo! | Real recording | [search](https://freesound.org/search/?q=cow+moo&f=license%3A%22Creative+Commons+0%22) |
| `kambing` | Kambing / Goat | Mbeeek! / Maa! | Real recording | [search](https://freesound.org/search/?q=goat+bleat&f=license%3A%22Creative+Commons+0%22) |
| `domba` | Domba / Sheep | Mbeee! / Baa! | Real recording | [search](https://freesound.org/search/?q=sheep+baa&f=license%3A%22Creative+Commons+0%22) |
| `kuda` | Kuda / Horse | Hiiihiii! / Neigh! | Real recording | [search](https://freesound.org/search/?q=horse+neigh&f=license%3A%22Creative+Commons+0%22) |
| `ayam` | Ayam / Chicken | Kukuruyuk! / Cock-a-doodle-doo! | Real recording | [search](https://freesound.org/search/?q=rooster+crow&f=license%3A%22Creative+Commons+0%22) |
| `bebek` | Bebek / Duck | Kwek kwek! / Quack quack! | Real recording | [search](https://freesound.org/search/?q=duck+quack&f=license%3A%22Creative+Commons+0%22) |

### Forest & Savanna

| id | Name | Imitation sound (ID / EN) | Type | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `singa` | Singa / Lion | Aum! / Roar! | Real recording | [search](https://freesound.org/search/?q=lion+roar&f=license%3A%22Creative+Commons+0%22) |
| `harimau` | Harimau / Tiger | Grrr, aum! / Grrr, roar! | Real recording | [search](https://freesound.org/search/?q=tiger+growl&f=license%3A%22Creative+Commons+0%22) |
| `gajah` | Gajah / Elephant | Tuuut! / Toot! | Real recording | [search](https://freesound.org/search/?q=elephant+trumpet&f=license%3A%22Creative+Commons+0%22) |
| `jerapah` | Jerapah / Giraffe | Hmmm... / Hmm... | Made-up effect | [search](https://freesound.org/search/?q=cartoon+hum&f=license%3A%22Creative+Commons+0%22) |
| `zebra` | Zebra / Zebra | Kwaha! / Kwa-ha! | Real recording | [search](https://freesound.org/search/?q=zebra&f=license%3A%22Creative+Commons+0%22) |
| `monyet` | Monyet / Monkey | U-u-a-a! / Ooh-ooh-aah! | Real recording | [search](https://freesound.org/search/?q=monkey&f=license%3A%22Creative+Commons+0%22) |
| `orangutan` | Orangutan / Orangutan | Huu huu! / Hoo hoo! | Real recording | [search](https://freesound.org/search/?q=orangutan&f=license%3A%22Creative+Commons+0%22) |
| `beruang` | Beruang / Bear | Grrr! / Grrr! | Real recording | [search](https://freesound.org/search/?q=bear+growl&f=license%3A%22Creative+Commons+0%22) |
| `panda` | Panda / Panda | Nyam nyam! / Munch munch! | Made-up effect | [search](https://freesound.org/search/?q=munching&f=license%3A%22Creative+Commons+0%22) |
| `badak` | Badak / Rhino | Hrmph! / Hrmph! | Real recording | [search](https://freesound.org/search/?q=rhino+snort&f=license%3A%22Creative+Commons+0%22) |
| `kudanil` | Kuda Nil / Hippo | Hrooo! / Hrooo! | Real recording | [search](https://freesound.org/search/?q=hippo&f=license%3A%22Creative+Commons+0%22) |
| `rubah` | Rubah / Fox | Ak ak! / Yip yip! | Real recording | [search](https://freesound.org/search/?q=fox+bark&f=license%3A%22Creative+Commons+0%22) |
| `quokka` | Quokka / Quokka | Hihi! / Hee hee! | Made-up effect | [search](https://freesound.org/search/?q=cute+squeak&f=license%3A%22Creative+Commons+0%22) |

### Reptiles & Frogs

| id | Name | Imitation sound (ID / EN) | Type | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `buaya` | Buaya / Crocodile | Hssss! / Hiss! | Real recording | [search](https://freesound.org/search/?q=crocodile+hiss&f=license%3A%22Creative+Commons+0%22) |
| `ular` | Ular / Snake | Sssss! / Sss! | Real recording | [search](https://freesound.org/search/?q=snake+hiss&f=license%3A%22Creative+Commons+0%22) |
| `komodo` | Komodo / Komodo Dragon | Hssss! / Hiss! | Real recording | [search](https://freesound.org/search/?q=lizard+hiss&f=license%3A%22Creative+Commons+0%22) |
| `kura` | Kura-kura / Turtle | Pelan-pelan... / Slowly... | Made-up effect | [search](https://freesound.org/search/?q=slow+footsteps&f=license%3A%22Creative+Commons+0%22) |
| `katak` | Katak / Frog | Kung kong! / Ribbit! | Real recording | [search](https://freesound.org/search/?q=frog+croak&f=license%3A%22Creative+Commons+0%22) |

### Sea & Water

| id | Name | Imitation sound (ID / EN) | Type | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `ikan` | Ikan / Fish | Blub blub! / Blub blub! | Made-up effect | [search](https://freesound.org/search/?q=bubbles&f=license%3A%22Creative+Commons+0%22) |
| `lumba` | Lumba-lumba / Dolphin | Ekik ekik! / Click click! | Real recording | [search](https://freesound.org/search/?q=dolphin&f=license%3A%22Creative+Commons+0%22) |
| `paus` | Paus / Whale | Uuuuu! / Ooooo! | Real recording | [search](https://freesound.org/search/?q=whale+song&f=license%3A%22Creative+Commons+0%22) |
| `kepiting` | Kepiting / Crab | Kletek kletek! / Click clack! | Made-up effect | [search](https://freesound.org/search/?q=claw+click&f=license%3A%22Creative+Commons+0%22) |
| `gurita` | Gurita / Octopus | Blup! / Bloop! | Made-up effect | [search](https://freesound.org/search/?q=bloop&f=license%3A%22Creative+Commons+0%22) |
| `ubur` | Ubur-ubur / Jellyfish | Blup blup! / Bloop bloop! | Made-up effect | [search](https://freesound.org/search/?q=bubble+pop&f=license%3A%22Creative+Commons+0%22) |
| `pinguin` | Pinguin / Penguin | Kwak! / Squawk! | Real recording | [search](https://freesound.org/search/?q=penguin&f=license%3A%22Creative+Commons+0%22) |

### Birds & Insects

| id | Name | Imitation sound (ID / EN) | Type | Freesound (CC0) |
| --- | --- | --- | --- | --- |
| `burung` | Burung / Bird | Cuit cuit! / Tweet tweet! | Real recording | [search](https://freesound.org/search/?q=bird+chirp&f=license%3A%22Creative+Commons+0%22) |
| `burunghantu` | Burung Hantu / Owl | Uhu uhu! / Hoo hoo! | Real recording | [search](https://freesound.org/search/?q=owl+hoot&f=license%3A%22Creative+Commons+0%22) |
| `flamingo` | Flamingo / Flamingo | Honk honk! / Honk honk! | Real recording | [search](https://freesound.org/search/?q=flamingo&f=license%3A%22Creative+Commons+0%22) |
| `kupu` | Kupu-kupu / Butterfly | Wusss... / Flutter... | Made-up effect | [search](https://freesound.org/search/?q=wings+flutter&f=license%3A%22Creative+Commons+0%22) |
| `lebah` | Lebah / Bee | Nguuung! / Buzz! | Real recording | [search](https://freesound.org/search/?q=bee+buzz&f=license%3A%22Creative+Commons+0%22) |
| `semut` | Semut / Ant | Tuk tuk tuk! / March march! | Made-up effect | [search](https://freesound.org/search/?q=tiny+footsteps&f=license%3A%22Creative+Commons+0%22) |
| `ulat` | Ulat / Caterpillar | Nyam nyam! / Munch munch! | Made-up effect | [search](https://freesound.org/search/?q=munch&f=license%3A%22Creative+Commons+0%22) |

Some wild animals may be hard to find in CC0, for example the komodo, orangutan, zebra, rhino, and flamingo. If nothing fits yet, try other keywords (for example "lizard" for the komodo, "goose honk" for the flamingo), or make your own effect that matches the imitation sound.

Two animals were decided after a second search on 15 November 2026:

- **Zebra.** There is only one CC0 zebra recording on Freesound, [Zebras - Grant's Zebra Braying](https://freesound.org/s/850661/). The recording is distant, so only the clearest bray is used (1.4 seconds). Do not replace it with a horse sound: a zebra barks short, it does not neigh.
- **Orangutan.** There is no CC0 orangutan recording. Following the rules above, a gibbon hoot is used instead, since gibbons are in the same ape family, [G12-23-Gibbons Hooting](https://freesound.org/s/437955/), and it is noted in the `LICENSES.csv` notes column.

## After everything is collected

An animal counts as done when the processed file `assets/audio/hewan/<id>.m4a` exists and its row in `assets/audio/LICENSES.csv` is complete with a `CC0` or `Milik sendiri` license. The content validator (`dart run tool/validate_content.dart`) checks both for all 42 animals before a release build.
