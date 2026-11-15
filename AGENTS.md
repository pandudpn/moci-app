# Moci agent instructions

This document is the only source of instructions for agents. `CLAUDE.md` only points here.

## 1. Project summary

Moci is a learning and play app for children aged 2–7: fully offline, two languages (Indonesian and English), for iPad, iPhone, Android phones, and Android tablets. The code is Flutter 3.50 pinned by FVM in `.fvmrc`.

## 2. Documentation map

| Document | Contents |
| --- | --- |
| `docs/README.md` | Summary, decisions, open questions, documentation map |
| `docs/PRD.md` | What v1 builds: users, principles, flows, features |
| `docs/TECH-SPEC.md` | Architecture, data, audio, performance, testing |
| `docs/DESIGN-SYSTEM.md` | Colours, type, sizes, motion, components |
| `docs/CONTENT-ASSETS.md` | Illustrations, JSON catalog, narration, audio, how to add content |
| `docs/PRIVACY-RELEASE.md` | Privacy, permissions, store requirements, release checklist |
| `ARCHITECTURE.md` | Code layers, folder map, providers, routes, state flow, test harness |
| `SYSTEM_DESIGN.md` | Stored data, timers, audio, microphone, content pipeline, platforms, CI |
| `DESIGN.md` | Tokens, components, tablet and phone stages, motion, accessibility |
| `CONTRIBUTING.md` | Workflow, commit style, PR checklist |
| `docs/design/prototype/` | Frozen snapshot of the interactive prototype |
| `docs/audio/SUARA-HEWAN.md` | Sources and licences for the animal sounds |

## 3. Commands

Every Flutter command goes through FVM.

| Need | Command |
| --- | --- |
| Fetch packages | `fvm flutter pub get` |
| Analyze | `fvm flutter analyze` |
| Format check | `fvm dart format --output=none --set-exit-if-changed lib test tool integration_test` |
| Tests without golden | `fvm flutter test --exclude-tags golden` |
| Golden tests (macOS) | `fvm flutter test --tags golden` |
| Update golden (macOS) | `fvm flutter test --tags golden --update-goldens` |
| Content validator | `fvm dart run tool/validate_content.dart` |
| Narration script | `fvm dart run tool/validate_content.dart --naskah=build/naskah.csv` |
| Validator in release mode | `fvm dart run tool/validate_content.dart --rilis` |
| Integration test | `fvm flutter test integration_test -d <device>` |
| Run the app | `fvm flutter run -d <device>` |
| Install to your own device | `make install` (or `scripts/moci.sh install`; pick with `DEVICE=<id>`) |
| Checks before commit | `make check` |

- `--naskah` is only read in the form `--naskah=<path>`; the separate form is ignored without a message.
- `--rilis` exits with code 1 as long as no narration recording exists. That is the expected state, not a bug. The validator names every line that has not been recorded.
- Format takes a folder list, not a dot: `fvm dart format .` also scans `build/test/listener_0.dart` once the integration test has run.
- Golden tests cover only Beranda (Home), Hebat (Great), and Area Orang Tua (Parent Area), and are only run or updated on macOS.

## 4. Code rules

- Import Material from `package:material_ui/material_ui.dart`, not `package:flutter/material.dart`, which is deprecated in Flutter 3.50. Code that only needs the widget layer uses `package:flutter/widgets.dart`.
- Allowed packages: `go_router`, `flutter_riverpod`, `shared_preferences`, `flutter_soloud`, `vector_graphics`, `vector_graphics_compiler`, `path_provider`, `url_launcher`, `flutter_localizations`, `intl`, and `speech_to_text` for Plan 03. A new package is only allowed if it sends no data, adds no permission, and is still maintained. No `google_fonts`, no analytics SDK, no crash reporting.
- No network, extra permissions, or telemetry. The Android release manifest contains no permission at all.
- Every screen is wrapped in `MociStage` from `lib/app/layout/moci_stage.dart`, with one `MenuTheme`.
- Game rules live in `*_game.dart` as pure Dart, without widgets, with a `Random` that can be seeded through a provider.
- UI text comes from the ARB files `l10n/app_id.arb` and `l10n/app_en.arb`, with keys `<screen><Key>`, copied exactly from the prototype.
- Sentences that are read aloud are marked `"description": "narasi"` in ARB. Narration recordings live in `assets/audio/vo/<language>/<kind>_<id>.m4a`; the folders are already declared in `pubspec.yaml` (Flutter does not walk folders, so a new audio folder has to be added by hand).

## 5. Test rules

- TDD: write the failing test first, then the code until it passes.
- Fakes and helpers are in `test/helpers/`: `TestEnv`, `pumpScreen`, and `pumpApp`. `testWidgets` must not touch real files or the network.
- Golden tests cover only Beranda (Home), Hebat (Great), and Area Orang Tua (Parent Area), and run on macOS.
- Integration tests use `runMoci(overrides:)` and do not use `pumpAndSettle`, because the mascot animates all the time.

## 6. Content

- The JSON catalog in `assets/content/katalog.json` is the source of truth. Export from `docs/design/prototype/` once, then edit the JSON directly.
- How to add content, the SVG rules, tracing, and colouring pages are in `docs/CONTENT-ASSETS.md`.
- Audio comes only from Freesound CC0 or your own recordings (`Milik sendiri`, "own work"), recorded in `assets/audio/LICENSES.csv`. Pixabay and CC BY are not used. This rule is stricter than `docs/CONTENT-ASSETS.md`, which still mentions Pixabay and CC BY; the strict rule wins. The validator enforces it through `lisensi_audio_lengkap`.
- Every new narration line has to go into the script. `--rilis` fails while any text has no recording.

## 7. Git

- Work on a feature branch, then open a PR to `main`. Never push straight to `main`.
- One commit per task, in the style `feat(area): summary` or `docs: summary`.
- Commits, code comments, workflow text, and documentation are written in English. Documentation covers `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, and every document under `docs/`. Only in-app UI strings stay bilingual, Indonesian and English, in the ARB files `l10n/app_id.arb` and `l10n/app_en.arb`.
- Before commit: format, analyze, tests, and validator.

## 8. Don't

- Touch `docs/design/prototype/`. It is a frozen snapshot.
- Commit non-CC0 audio, signing secrets, or `.env`. `.gitignore` rejects them.
- Add an Android or iOS permission without updating `docs/PRIVACY-RELEASE.md`.
