> Copy of Claude Docs "Dokumentasi Moci", Summary tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci documentation

14 November 2026 · Pandu

## Summary

Moci is a learning and play app for children aged 2–7: no ads, works offline, in Indonesian and English, for iPad, iPhone, and Android phones and tablets. The design and the interactive prototype for every tablet menu are done. A phone version exists only for Home, and the Flutter code has not started.

### Documentation contents

Each document stands on its own. The original source is in Claude Docs "Dokumentasi Moci"; if a document there changes, re-export the changed tab to the file below.

| Tab | Contents | File name in the repo |
| --- | --- | --- |
| [PRD](PRD.md) | What is built for v1: users, principles, flows, features per menu, done criteria | `docs/PRD.md` |
| [Technical Specification](TECH-SPEC.md) | How to build it with Flutter: architecture, data, audio, performance, testing | `docs/TECH-SPEC.md` |
| [Design System](DESIGN-SYSTEM.md) | Colors, fonts, touch sizes, components, animation, and sound | `docs/DESIGN-SYSTEM.md` |
| [Content & Assets](CONTENT-ASSETS.md) | Illustrations, content catalog, narration, sounds, brand assets, how to add content | `docs/CONTENT-ASSETS.md` |
| [Privacy & Release](PRIVACY-RELEASE.md) | Privacy policy, App Store and Google Play requirements, release checklist | `docs/PRIVACY-RELEASE.md` |

### Decisions and recommendations

The Status column can be edited directly. When a recommendation is approved, change its status to Decided.

| Item | Option | Status |
| --- | --- | --- |
| Platform | iPad, iPhone, Android phones, Android tablets | Decided |
| Age | 2–7 years, in 3 levels: 2–3, 4–5, 6–7 | Decided |
| Language | Indonesian and English, switchable at any time | Recommendation |
| Ads | None | Decided |
| In-app purchases | None | Recommendation |
| Child data | On device only, with no account, server, or analytics | Recommendation |
| App icon | A. Moci's face | Decided |
| Icon background color | Sky blue | Recommendation |
| Logo | Stacked or horizontal, depending on the space available | Decided |
| Splash screen | Light version | Decided |
| Technology | Flutter, one codebase for iOS and Android | Recommendation |
| Repo name | moci-app | Recommendation |

Additional decisions as of 14 November 2026: Say v1 uses the microphone with on-device speech recognition, and every screen is locked to landscape orientation.

### Open questions

- [ ] Repo license: whether the code and image assets may be used by others.
- [ ] Store price: free or a one-time purchase.
- [ ] Apple and Google developer accounts: under a personal name or a business entity.
- [ ] Who records the Indonesian and English narration.
- [ ] Source of the real animal sounds.
- [ ] Availability of the name "Moci" in the App Store, Play Store, and the DJKI trademark database.
- [ ] Support email and web address for the privacy policy.
- [ ] Age range in the App Store Kids category: 5 and under, or 6–8.
- [ ] PP Tunas self-assessment: whether it needs to be submitted (Komdigi deadline 31 December 2026).

## Documentation map

| Document | Contents |
| --- | --- |
| [PRD.md](PRD.md) | v1 goals, menus, app flows, product principles |
| [TECH-SPEC.md](TECH-SPEC.md) | Technology, architecture, storage, audio, testing |
| [DESIGN-SYSTEM.md](DESIGN-SYSTEM.md) | Colors, fonts, sizes, motion, components |
| [CONTENT-ASSETS.md](CONTENT-ASSETS.md) | Illustrations, JSON catalog, narration, sounds, how to add content |
| [PRIVACY-RELEASE.md](PRIVACY-RELEASE.md) | Privacy, permissions, the kids category in the app stores, release flow |
| [design/](design/) | Interactive prototype snapshot |
| [audio/SUARA-HEWAN.md](audio/SUARA-HEWAN.md) | Guide to animal sound sources and licenses |
