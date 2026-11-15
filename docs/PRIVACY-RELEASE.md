> Copy of the Claude Docs "Moci Documentation", Privacy & Release tab, as of 2026-11-14. Source of truth: https://claude.ai/artifact/VKF6SyozUj7ZBBCFEQ9e8H.

# Moci Privacy & Release

Moci collects no data at all. Because of that, the path to the Kids category on the App Store and Google Play is as simple as it gets: there is no data to report, no consent to request, and nothing to delete from a server. This tab is not legal advice. The regulation section should be confirmed with a lawyer before release.

## Privacy principles

- No accounts, servers, analytics, ads, or third party SDKs that send data.
- The only device permission is the microphone for the Say It (Ucapkan) menu. This permission is requested through a parent, and the child's voice is recognized on the device without being stored or sent. There is no camera, location, contacts, or internet permission.
- Every outbound link, such as the privacy policy, the support email, and the store page, sits behind the Parental Gate (Gerbang Orang Tua).
- Parents can delete all data through Delete all data in the Parents' Area, or by uninstalling the app.

| Data | Filled in by | Stored on | Sent out |
| --- | --- | --- | --- |
| Child's nickname (may be empty) | Parent, in Welcome | Device | No |
| Age level | Parent | Device | No |
| Settings | Parent | Device | No |
| Progress, stars, play time | App | Device | No |
| Coloring artwork | Child | Device | No |
| Child's voice in the Say It menu | Child, after the parent grants microphone permission | Not stored, only recognized briefly on the device | No |

## Privacy policy draft

Both stores require a privacy policy URL the public can open. The drafts below are ready to copy into `PRIVACY.md` in the repo, then hosted on GitHub Pages if the repo is public. The app ships in Bahasa Indonesia and English, so the published policy carries both versions: the Indonesian text first, then the English one. Fill in the bracketed parts before publishing.

```markdown
# Kebijakan Privasi Moci

Berlaku sejak: [tanggal rilis]

Moci adalah aplikasi belajar dan bermain untuk anak usia 2–7 tahun. Kami tidak mengumpulkan, menyimpan, atau membagikan data pribadi apa pun.

## Data yang tersimpan di perangkat

Agar aplikasi bisa bekerja, Moci menyimpan hal berikut hanya di perangkat Anda:

- nama panggilan anak (boleh dikosongkan) dan level usia,
- pengaturan seperti bahasa, batas waktu bermain, dan suara,
- kemajuan belajar, bintang, stiker, dan hasil mewarnai.

Data ini tidak pernah dikirim kepada kami atau pihak lain, dan kami tidak bisa melihatnya. Data ini juga tidak ikut dicadangkan otomatis ke layanan cloud.

## Mikrofon

Menu Ucapkan memakai mikrofon supaya anak bisa berlatih mengucapkan kata. Suara anak dikenali langsung di perangkat, tidak direkam ke file, dan tidak dikirim kepada kami atau pihak lain. Izin mikrofon diminta lewat orang tua dan bisa dicabut kapan saja di pengaturan perangkat. Tanpa izin ini, Ucapkan tetap bisa dimainkan tanpa mikrofon.

## Yang tidak kami lakukan

- Tidak ada akun atau login.
- Tidak ada iklan dan pembelian dalam aplikasi.
- Tidak ada analytics, pelacakan, atau SDK pihak ketiga yang mengumpulkan data.
- Tidak memakai internet, kamera, atau lokasi.

## Menghapus data

Buka Area Orang Tua, lalu pilih Hapus semua data. Menghapus aplikasi juga menghapus semua data Moci dari perangkat.

## Anak-anak

Moci dibuat untuk anak dan tidak mengumpulkan data pribadi anak. Pengaturan dan semua tautan keluar dilindungi Gerbang Orang Tua.

## Perubahan kebijakan

Kalau kebijakan ini berubah, versi terbaru dipasang di halaman ini dengan tanggal berlaku yang baru.

## Kontak

Pertanyaan tentang privasi: [email dukungan]
```

```markdown
# Moci Privacy Policy

Effective date: [release date]

Moci is a learning and play app for children aged 2–7. We do not collect, store, or share any personal data.

## Data stored on your device

To work, Moci keeps the following only on your device:

- your child's nickname (optional) and age level,
- settings such as language, daily time limit, and sound,
- learning progress, stars, stickers, and coloring artwork.

This data is never sent to us or anyone else, and we cannot see it. It is not included in automatic cloud backups.

## Microphone

The Ucapkan (Say It) activity uses the microphone so your child can practice saying words. Your child's voice is recognized directly on the device, is never recorded to a file, and is never sent to us or anyone else. Microphone access is requested through a parent and can be turned off at any time in the device settings. Without it, the activity still works without the microphone.

## What we don't do

- No accounts or logins.
- No ads and no in-app purchases.
- No analytics, tracking, or third-party SDKs that collect data.
- No internet, camera, or location access.

## Deleting data

Open Parents' Corner and choose Delete all data. Uninstalling the app also removes all Moci data from the device.

## Children

Moci is made for children and does not collect any personal information from them. Settings and all external links are protected by a parental gate.

## Changes

If this policy changes, the new version will be posted on this page with a new effective date.

## Contact

Privacy questions: [support email]
```

## App Store

Moci is registered in the Kids category, so it must follow [guideline 1.3 and 5.1.4](https://developer.apple.com/app-store/review/guidelines/). Almost every requirement is already met by Moci's design. One thing still needs a decision: the age band.

| Requirement | Moci status |
| --- | --- |
| No outbound links, purchases, or interruptions for the child, except in areas protected by a parental gate (1.3) | Compliant. Everything is behind the Parental Gate. |
| Does not send personal data or device information to third parties (1.3) | Compliant. No data leaves. |
| No third party analytics or ads (1.3 and 5.1.4) | Compliant |
| Microphone and speech recognition permissions need reason text in Info.plist (`NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`) | The text is aimed at parents. The permission dialog only appears after the Parental Gate. |
| The parental gate must be an adult level task. For children who cannot read yet, Apple suggests a voice that asks the child to call a parent ([Kids apps](https://developer.apple.com/app-store/kids-apps/)). | The multiplication question is already there. Add the narration "Panggil ayah atau ibu, ya!" ("Call dad or mom, okay!") when the gate opens. |
| Pick one age band: 5 and under, 6–8, or 9–11 | Needs a decision, because Moci is for ages 2–7 |
| Once in the Kids category, the rules still apply even if the category is dropped in a later update (1.3) | A note for the future |
| The age rating uses the new 4+, 9+, 13+, 16+, and 18+ system, with a questionnaire that must be answered ([latest requirements](https://developer.apple.com/news/upcoming-requirements/)) | Moci content has nothing inappropriate, so it is expected to get 4+ |
| Privacy label on the product page | Choose that the app collects no data, so the label is Data Not Collected. The voice in Say It does not count, because data processed only on the device is not collected data ([App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)). |
| Since 28 April 2026, builds must be made with Xcode 26 and the iOS 26 SDK | CI uses Xcode 26 or newer |
| Starting iOS 27, a launch screen is required to submit to the App Store ([TN3192](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key)) | The Flutter iOS template already includes a launch screen |

An Apple Developer Program account costs 99 USD per year. If you enroll as an individual, the account holder's real name appears as the seller on the App Store. If you enroll as an organization, a legal entity and a D-U-N-S number are required ([enrollment requirements](https://developer.apple.com/support/enrollment/)).

## Google Play

Because Moci's target users are children, the app must follow the [Families Policy](https://support.google.com/googleplay/android-developer/answer/9893335). The biggest obstacle is not the privacy rules, but the 14 day closed test for new personal accounts.

| Requirement | Moci status |
| --- | --- |
| Declare the target age groups in Play Console. Pick several groups only if the app is really designed for all of them. | Ages 2–7 covers two groups, so both are selected |
| The privacy policy must accurately describe the data collected | The draft above |
| Does not send device IDs (AAID, IMEI, and similar) and does not request location permission | Compliant. The only permission is the microphone (`RECORD_AUDIO`) for Say It. |
| Does not request the AD\_ID permission for child-only apps that target API 33 and above | Compliant |
| Uses only SDKs approved for children's services | Compliant. There is no data collecting SDK. |
| Content must be suitable for children | Compliant |
| The Data safety form and the content rating questionnaire are filled in | Data safety: no data collected or shared. The voice in Say It does not need to be reported, because data processed only on the device is not counted as collected data ([Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)). |
| Since 31 August 2026, new apps must target Android 16 (API 36) ([target API requirement](https://developer.android.com/google/play/requirements/target-sdk)) | Already covered in the [Technical Specification](TECH-SPEC.md) |
| Personal accounts created after 13 November 2023 must run a closed test with at least 12 testers who stay engaged for 14 days before a production release ([testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465)) | Prepare 12 testers, for example family and friends with a Google account and an Android device |
| Android developer verification applies in Indonesia since 30 September 2026. Developers who publish only on Google Play just need a Play Console account ([verification guide](https://developer.android.com/developer-verification/guides)) | Check the verification status in Play Console |

The Google Play Console registration fee is 25 USD, paid once ([registration fee](https://support.google.com/googleplay/android-developer/answer/6112435)).

## Regulation

Because Moci collects no data, most child privacy obligations are not triggered. What still needs checking is PP Tunas, since Moci is indeed designed for children.

| Rule | Summary | Effect on Moci |
| --- | --- | --- |
| UU 27/2022 on Personal Data Protection, Article 25 ([text](https://pasal.id/peraturan/uu/uu-no-27-tahun-2022)) | Processing children's personal data requires consent from a parent or guardian | Moci does not process child data off the device. The name is entered by the parent and never reaches the developer. |
| PP 17/2025 on child protection in electronic systems (PP Tunas), fully in force since 28 March 2026 after a one year transition ([news](https://investortrust.id/national/98247/meutya-hafid-beberkan-aturan-lengkap-pp-tunas-yang-resmi-berlaku-hari-ini)) | Every electronic system operator must comply and submit a self-assessment of its service risk profile to Komdigi ([Antara](https://jogja.antaranews.com/berita/829868/kemkomdigi-menegaskan-semua-pse-di-indonesia-wajib-mematuhi-pp-tunas)). Komdigi set the self-assessment deadline at 31 December 2026, with implementing rules in Permen Komdigi 9/2026 ([Selular](https://selular.id/2026/10/simak-22-platform-digital-berisiko-tinggi-bagi-anak-ada-youtube-hingga-telegram/)). Other obligations include parental consent features, information that children can easily understand, child data protection, age limits, and education ([summary](https://siplawfirm.id/resources/implementasi-pelindungan-anak-yang-mengakses-sistem-elektronik-berdasarkan-peraturan-pemerintah-nomor-17-tahun-2025)). | Moci most likely falls in scope. Most obligations are already met through the Parental Gate and the absence of data collection, but the self-assessment needs to be prepared before release. |
| Rules in other countries, such as COPPA in the United States and GDPR in Europe | Google's Families Policy requires compliance with rules like these | With no data collection, there is no parental consent to request. The privacy policy still explains it. |

Before release, Moci's status against PP Tunas and its obligations as an electronic system operator should be confirmed with a legal consultant or Komdigi.

## Release flow

![v1 release flow: iOS 4 steps, Android 5 steps](images/alur-rilis.png)

Both tracks can run in parallel. The Android closed test should start as early as possible, because its 14 days cannot be sped up, while iOS can follow once TestFlight is done.

## Store listing assets

The README screenshots (1180 × 820) cannot be used as they are, because their size does not match the sizes the stores require. Listing screenshots are taken again from the Flutter app on a simulator and emulator, in landscape.

| Asset | App Store ([specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)) | Google Play ([specifications](https://support.google.com/googleplay/android-developer/answer/9866151)) |
| --- | --- | --- |
| Icon | From the Xcode asset catalog (`moci-icon-1024.png`) | 512 × 512 PNG 32-bit, at most 1 MB (`play-store-512.png`) |
| Feature graphic | None | Feature graphic 1024 × 500, JPEG or PNG without transparency |
| Phone screenshots | iPhone 6.5 inch landscape 2688 × 1242 or 2778 × 1284, required when there is no 6.9 inch version. The 6.9 inch version (2868 × 1320) is optional. | At least 2 screenshots, sides 320–3840 px, the long side at most 2 times the short side. To be eligible for featuring: at least 4 screenshots at 16:9 with a width of at least 1920 px. |
| Tablet screenshots | iPad 13 inch landscape 2752 × 2064 or 2732 × 2048, required because Moci runs on iPad | At least 4 screenshots at 16:9, sides 1080–7680 px |
| Count and format | 1–10 per size, JPEG or PNG without transparency | At most 8 per device type |

Listing text (name, short description, long description) is prepared in Indonesian and English. Use the same brand and screenshots on both stores so they look consistent.

## Release checklist

Tick each item when it is done. The order inside each group follows the order of work.

### Before the release build

- [ ] Decide the Kids Category age band on the App Store
- [ ] Create a dedicated Moci support email
- [ ] Publish the Indonesian and English privacy policy at a public URL
- [ ] Check Moci name availability on both stores and in the DJKI trademark database
- [ ] Enroll in the Apple Developer Program and Google Play Console
- [ ] Prepare the PP Tunas self-assessment, or confirm with a lawyer that it is not required
- [ ] Complete the narration in both languages until content validation is clean
- [ ] Make sure Delete all data works
- [ ] Make sure the merged Android manifest only requests the RECORD\_AUDIO permission, without INTERNET and Bluetooth, and that Info.plist only holds the microphone and speech recognition reason strings
- [ ] Test Say It in airplane mode in both languages, including with microphone permission denied

### iOS

- [ ] Build with Xcode 26 or newer
- [ ] Answer the age rating questionnaire
- [ ] Fill in the privacy label: the app collects no data
- [ ] Pick the Kids category and its age band
- [ ] Upload iPhone and 13 inch iPad screenshots
- [ ] Test through TestFlight on family devices, then submit for review

### Android

- [ ] Target API 36
- [ ] Fill in target audience and content: the two age groups covering ages 2–7
- [ ] Fill in Data safety: no data collected or shared
- [ ] Fill in the content rating questionnaire
- [ ] Run the closed test with 12 testers for 14 consecutive days (personal account)
- [ ] Check the developer verification status in Play Console
- [ ] Upload the feature graphic, phone screenshots, and tablet screenshots
- [ ] Apply for production access, then do a staged rollout

## Sources

Checked on 14 November 2026.

- [Apple: App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple: Kids apps](https://developer.apple.com/app-store/kids-apps/)
- [Apple: Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/)
- [Apple: Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/)
- [Apple: Enrollment](https://developer.apple.com/support/enrollment/)
- [Apple TN3192: Migrating your app from the deprecated UIRequiresFullScreen key](https://developer.apple.com/documentation/technotes/tn3192-migrating-your-app-from-the-deprecated-uirequiresfullscreen-key)
- [Google Play: Families Policy](https://support.google.com/googleplay/android-developer/answer/9893335)
- [Google Play: App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)
- [Google Play: Target API level requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [Google Play: Preview assets](https://support.google.com/googleplay/android-developer/answer/9866151)
- [Google Play: Registration fee](https://support.google.com/googleplay/android-developer/answer/6112435)
- [Android developer verification](https://developer.android.com/developer-verification/guides)
- [UU 27/2022 on Pasal.id](https://pasal.id/peraturan/uu/uu-no-27-tahun-2022)
- [Investortrust: PP Tunas officially in force](https://investortrust.id/national/98247/meutya-hafid-beberkan-aturan-lengkap-pp-tunas-yang-resmi-berlaku-hari-ini)
- [Antara: Every PSE must comply with PP Tunas](https://jogja.antaranews.com/berita/829868/kemkomdigi-menegaskan-semua-pse-di-indonesia-wajib-mematuhi-pp-tunas)
- [Selular: PP Tunas self-assessment deadline](https://selular.id/2026/10/simak-22-platform-digital-berisiko-tinggi-bagi-anak-ada-youtube-hingga-telegram/)
- [SIP Law Firm: PSE obligations in PP 17/2025](https://siplawfirm.id/resources/implementasi-pelindungan-anak-yang-mengakses-sistem-elektronik-berdasarkan-peraturan-pemerintah-nomor-17-tahun-2025)
- [Apple: App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Google Play: Data safety](https://support.google.com/googleplay/android-developer/answer/10787469)
