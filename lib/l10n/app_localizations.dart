import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'Moci'**
  String get appTitle;

  /// Tombol kembali ke layar beranda
  ///
  /// In id, this message translates to:
  /// **'Kembali ke beranda'**
  String get commonBack;

  /// Tombol untuk mendengarkan narasi
  ///
  /// In id, this message translates to:
  /// **'Dengar'**
  String get commonListen;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get langNameId;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get langNameEn;

  /// Sebutan anak bila nama belum diisi
  ///
  /// In id, this message translates to:
  /// **'Adik'**
  String get childFallbackName;

  /// Tagline di Splash dan Beranda
  ///
  /// In id, this message translates to:
  /// **'Main & Belajar'**
  String get berandaTag;

  /// No description provided for @sambutanTag.
  ///
  /// In id, this message translates to:
  /// **'Main & Belajar'**
  String get sambutanTag;

  /// No description provided for @sambutanHi.
  ///
  /// In id, this message translates to:
  /// **'Halo! Aku Moci.'**
  String get sambutanHi;

  /// No description provided for @sambutanSub.
  ///
  /// In id, this message translates to:
  /// **'Teman main dan belajar untuk anak usia 2–7 tahun.'**
  String get sambutanSub;

  /// No description provided for @sambutanNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama anak'**
  String get sambutanNameLabel;

  /// No description provided for @sambutanNamePh.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan si kecil'**
  String get sambutanNamePh;

  /// No description provided for @sambutanAge.
  ///
  /// In id, this message translates to:
  /// **'Usia anak'**
  String get sambutanAge;

  /// No description provided for @sambutanYears.
  ///
  /// In id, this message translates to:
  /// **'tahun'**
  String get sambutanYears;

  /// No description provided for @sambutanNote.
  ///
  /// In id, this message translates to:
  /// **'Nama hanya tersimpan di perangkat ini. Bisa diubah di Area Orang Tua.'**
  String get sambutanNote;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo Mulai!'**
  String get sambutanStart;

  /// Label tombol lewati di Splash
  ///
  /// In id, this message translates to:
  /// **'Lewati intro'**
  String get sambutanSkip;

  /// No description provided for @sambutanHello.
  ///
  /// In id, this message translates to:
  /// **'Hai'**
  String get sambutanHello;

  /// No description provided for @sambutanFriend.
  ///
  /// In id, this message translates to:
  /// **'teman'**
  String get sambutanFriend;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Halo! Aku Moci. Siapa namamu?'**
  String get sambutanSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Halo! Aku Moci.'**
  String get sambutanHalo;

  /// No description provided for @sambutanBadge1.
  ///
  /// In id, this message translates to:
  /// **'Tanpa iklan'**
  String get sambutanBadge1;

  /// No description provided for @sambutanBadge2.
  ///
  /// In id, this message translates to:
  /// **'Tanpa pembelian'**
  String get sambutanBadge2;

  /// No description provided for @sambutanBadge3.
  ///
  /// In id, this message translates to:
  /// **'Bisa offline'**
  String get sambutanBadge3;

  /// Sapaan di Beranda
  ///
  /// In id, this message translates to:
  /// **'Hai, {name}!'**
  String berandaHi(String name);

  /// No description provided for @berandaAsk.
  ///
  /// In id, this message translates to:
  /// **'Mau main apa hari ini?'**
  String get berandaAsk;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hai! Aku Moci. Mau main apa hari ini?'**
  String get berandaSay;

  /// No description provided for @berandaContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get berandaContinue;

  /// No description provided for @berandaParents.
  ///
  /// In id, this message translates to:
  /// **'Orang Tua'**
  String get berandaParents;

  /// No description provided for @berandaLangLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get berandaLangLabel;

  /// No description provided for @berandaMociLabel.
  ///
  /// In id, this message translates to:
  /// **'Moci, ketuk untuk menyapa'**
  String get berandaMociLabel;

  /// Label semantik jumlah bintang
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{1 bintang} other{{count} bintang}}'**
  String berandaStarsLabel(int count);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Kenal Huruf'**
  String get menuHurufTitle;

  /// No description provided for @menuHurufSub.
  ///
  /// In id, this message translates to:
  /// **'A sampai Z'**
  String get menuHurufSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Berhitung'**
  String get menuAngkaTitle;

  /// No description provided for @menuAngkaSub.
  ///
  /// In id, this message translates to:
  /// **'1 sampai 50'**
  String get menuAngkaSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Dunia Hewan'**
  String get menuHewanTitle;

  /// No description provided for @menuHewanSub.
  ///
  /// In id, this message translates to:
  /// **'Nama & suaranya'**
  String get menuHewanSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Buah & Sayur'**
  String get menuBuahTitle;

  /// No description provided for @menuBuahSub.
  ///
  /// In id, this message translates to:
  /// **'Tebak namanya'**
  String get menuBuahSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo Membaca'**
  String get menuBacaTitle;

  /// No description provided for @menuBacaSub.
  ///
  /// In id, this message translates to:
  /// **'Suku kata & kalimat'**
  String get menuBacaSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Main Yuk!'**
  String get menuMainTitle;

  /// No description provided for @menuMainSub.
  ///
  /// In id, this message translates to:
  /// **'Cocokkan & ingat'**
  String get menuMainSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Mewarnai'**
  String get menuWarnaiTitle;

  /// No description provided for @menuWarnaiSub.
  ///
  /// In id, this message translates to:
  /// **'Warnai sesukamu'**
  String get menuWarnaiSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get menuWarnaTitle;

  /// No description provided for @menuWarnaSub.
  ///
  /// In id, this message translates to:
  /// **'Cari & sentuh'**
  String get menuWarnaSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bentuk'**
  String get menuBentukTitle;

  /// No description provided for @menuBentukSub.
  ///
  /// In id, this message translates to:
  /// **'Bulat, segitiga, kotak'**
  String get menuBentukSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Main Musik'**
  String get menuMusikTitle;

  /// No description provided for @menuMusikSub.
  ///
  /// In id, this message translates to:
  /// **'Ketuk & dengar'**
  String get menuMusikSub;

  /// No description provided for @gerbangCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get gerbangCancel;

  /// No description provided for @gerbangTitle.
  ///
  /// In id, this message translates to:
  /// **'Khusus Orang Tua'**
  String get gerbangTitle;

  /// No description provided for @gerbangSub.
  ///
  /// In id, this message translates to:
  /// **'Jawab soal ini untuk membuka pengaturan dan laporan belajar.'**
  String get gerbangSub;

  /// No description provided for @gerbangHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk angka di sebelah kanan.'**
  String get gerbangHint;

  /// No description provided for @gerbangBad.
  ///
  /// In id, this message translates to:
  /// **'Belum tepat.'**
  String get gerbangBad;

  /// No description provided for @gerbangRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba soal baru ini, ya.'**
  String get gerbangRetry;

  /// No description provided for @gerbangOk.
  ///
  /// In id, this message translates to:
  /// **'Benar! Silakan masuk.'**
  String get gerbangOk;

  /// No description provided for @gerbangNewQ.
  ///
  /// In id, this message translates to:
  /// **'Ganti soal'**
  String get gerbangNewQ;

  /// No description provided for @gerbangEnter.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get gerbangEnter;

  /// No description provided for @gerbangKeypad.
  ///
  /// In id, this message translates to:
  /// **'Papan angka'**
  String get gerbangKeypad;

  /// No description provided for @gerbangDel.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get gerbangDel;

  /// No description provided for @gerbangHelp.
  ///
  /// In id, this message translates to:
  /// **'Panggil Ayah atau Bunda, ya!'**
  String get gerbangHelp;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ini khusus orang tua. Panggil Ayah atau Bunda, ya!'**
  String get gerbangHelpSay;

  /// No description provided for @gerbangNote.
  ///
  /// In id, this message translates to:
  /// **'Gerbang ini menjaga si kecil agar tidak membuka pengaturan atau tautan keluar.'**
  String get gerbangNote;

  /// Label semantik soal perkalian
  ///
  /// In id, this message translates to:
  /// **'{a} kali {b}'**
  String gerbangTimes(int a, int b);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
