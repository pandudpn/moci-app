# Contributing

Guide for working in the Moci repo. The same rules for humans and automated agents are in [`AGENTS.md`](AGENTS.md).

## 1. Setup

- Every Flutter command uses FVM. The Flutter version is pinned in `.fvmrc`, 3.50.0, so write `fvm flutter …` and `fvm dart …`.
- Xcode 26 or newer for iOS builds and golden tests.
- Android SDK 36. `compileSdk`, `targetSdk`, and `minSdk` are in `android/app/build.gradle.kts`.
- Python 3, only when rebuilding the fonts with `tool/fonts/build_fonts.sh`. That script creates a venv and installs `fonttools`.

```bash
fvm install
fvm flutter pub get
```

## 2. Workflow

1. Create a feature branch from `main`, for example `feat/menu-huruf`.
2. Work on one topic per branch. Do not commit to `main`.
3. Run the local checks in section 4 before pushing.
4. Open a pull request to `main`.
5. The PR is merged once CI is green. `.github/workflows/ci.yml` runs analyze, the format check, the content validator, and tests without golden on Linux, then golden on macOS.

## 3. Commit style

- One title line in the form `<type>(<area>): <summary>`. Example: `feat(content): build narration list from catalog and ARB`.
- Types used: `feat`, `fix`, `test`, `docs`, `chore`, `refactor`, `ci`, `build`.
- Titles, commit bodies, code comments, CI workflow text, and documentation are written in English, lowercase at the start of the title, with no trailing period. Documentation covers `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, and every file under `docs/`; only in-app UI strings stay bilingual, Indonesian and English, in `l10n/app_id.arb` and `l10n/app_en.arb`.
- One commit holds one change that can be explained on its own.

## 4. TDD and tests

Write the failing test first, then the code until the test passes. Commands that must pass:

```bash
fvm flutter analyze
fvm dart format --output=none --set-exit-if-changed lib test tool integration_test
fvm dart run tool/validate_content.dart
fvm flutter test --exclude-tags golden
fvm flutter test --tags golden
```

- `--exclude-tags golden` is the set that runs on every machine. This is what CI uses on Linux.
- `--tags golden` uses `*_golden_test.dart` files. Run it on macOS.
- Integration tests need a device or simulator that is on: `fvm flutter test integration_test -d <device>`. Device IDs are listed with `fvm flutter devices`.
- Fakes and test helpers are in `test/helpers/`. `testWidgets` must not touch real files or the network.

## 5. Updating golden

Golden tests cover only Beranda (Home), Hebat (Great), and Area Orang Tua (Parent Area), in `test/features/beranda/goldens/`, `test/features/hadiah/goldens/`, and `test/features/orang_tua/goldens/`. Text renders differently on Linux and macOS, so golden files are updated on macOS.

```bash
fvm flutter test --tags golden --update-goldens
```

After updating, open the PNGs that changed and check the diff. Make sure the change is the one you asked for and not an accidental layout shift.

## 6. Changing or adding content

The JSON catalog in `assets/content/` is the source of truth. `docs/design/prototype/` is a frozen snapshot, so do not edit it.

1. Edit `assets/content/katalog.json`, `assets/tracing/`, or `assets/coloring/`.
2. Add an illustration in `assets/illustrations/` if needed.
3. Run `fvm dart run tool/validate_content.dart`. Every error must be zero.
4. For the narration script, run `fvm dart run tool/validate_content.dart --naskah=build/naskah.csv`.
5. Before release, add `--rilis`. This mode fails if the narration or the animal sounds are incomplete.

Content rules, file formats, and the asset list are explained in [`docs/CONTENT-ASSETS.md`](docs/CONTENT-ASSETS.md).

## 7. Audio

- Only two sources of sound: Freesound under the CC0 licence, or your own recording. Pixabay and CC BY are not used.
- Every file is recorded on one line in `assets/audio/LICENSES.csv`. The `lisensi` column only holds `CC0` or `Milik sendiri` ("own work").
- The validator rejects an audio file with no licence line.
- Guidance for picking a sound per animal, including the Freesound links, is in [`docs/audio/SUARA-HEWAN.md`](docs/audio/SUARA-HEWAN.md).

## 8. Releases

The version number is not typed in three places. `tool/rilis/naikkan_versi.dart` is the only thing that writes it, on the `version:` line in `pubspec.yaml`:

```bash
fvm dart run tool/rilis/naikkan_versi.dart show          # the version in the file, e.g. 1.0.2+3
fvm dart run tool/rilis/naikkan_versi.dart bump patch     # writes 1.0.2+3; the build number always goes up
fvm dart run tool/rilis/naikkan_versi.dart bump 2.0.0-rc.1
fvm dart run tool/rilis/naikkan_versi.dart check v1.0.2   # the guard the workflow runs
```

Two paths release, both run the same checks in one run:

```bash
# 1. the button that computes the tag
gh workflow run Release -f bump=patch

# 2. or your own tag after bumping the version
fvm dart run tool/rilis/naikkan_versi.dart bump patch
git commit -am "chore(release): v1.0.2"
git tag -a v1.0.2 -m "Moci 1.0.2" && git push origin v1.0.2
```

The release page contents are not typed by hand either. `tool/rilis/catatan_rilis.dart` walks the mainline path between the previous tag and this tag. A merged pull request becomes one entry that links its pull request, with its commits folded in; a direct commit on `main` links its short commit. Each entry names its author through the GitHub login when `gh` is available, and through the git name without `@` when not. The subject is read as a conventional commit and then grouped into Breaking changes, Features, Fixes, Documentation, Build and CI, and Other changes. There is a Contributors section, a fixed Install section, and a link to the full changelog. `chore(release)` and `chore(rilis)` commits, their reverts, and bot commits are left out. Write commit subjects that are worth reading, because that is the content of the release page:

```bash
fvm dart run tool/rilis/catatan_rilis.dart --to v1.0.2   # preview before tagging
```

`SUMMARY.md` may hold the release title and a short summary. The workflow copies it before the bump, and the bump commit deletes it, so the words for one release do not carry over to the next one.

One workflow run does the rest: it rejects a tag that does not match `pubspec.yaml`, runs the format check, analyze, the content validator, tests without golden, and golden on macOS, builds a signed AAB and APK plus an unsigned IPA, then publishes a GitHub Release with the three files and `SHA256SUMS`.

A version with a suffix (`v2.0.0-rc.1`) is published as a prerelease. `gh workflow run Release -f bump=patch` builds the bump commit and the tag inside the runner and pushes nothing at first. Other jobs test and build that commit from the artifact bundle. Only the publish job pushes, after every gate passes, with a single `git push --atomic` for the branch and the tag. A gate that fails leaves `main` and the tag as they were, and a tag push by `GITHUB_TOKEN` does not trigger a second run.

Dispatch only runs from `main`, and is rejected before anything is staged if `main` has moved since the button was pressed or `HEAD` is already tagged with a release. Pressing the button twice means releasing once. Releasing an existing tag again, for example when its release was never created, is a dispatch with `bump=none`.

## 9. PR checklist

- [ ] `fvm flutter analyze` is clean.
- [ ] `fvm dart format --output=none --set-exit-if-changed lib test tool integration_test` is clean.
- [ ] `fvm dart run tool/validate_content.dart` with no errors.
- [ ] `fvm flutter test --exclude-tags golden` passes.
- [ ] Golden files are updated and the images checked if the UI changed.
- [ ] New audio is recorded in `assets/audio/LICENSES.csv` with the CC0 or `Milik sendiri` licence.
- [ ] No `android/key.properties`, `*.jks`, `*.keystore`, `*.p12`, or `.env` is committed.
- [ ] New commands and paths mentioned in documents have been run or checked.
