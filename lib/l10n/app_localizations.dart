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

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Istirahat sebentar, yuk!'**
  String get istirahatTitle;

  /// No description provided for @istirahatSub.
  ///
  /// In id, this message translates to:
  /// **'Mata dan badan juga perlu istirahat. Ikuti Moci sampai hitungannya selesai.'**
  String get istirahatSub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Lihat jauh ke luar jendela'**
  String get istirahatStep1;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Kedip-kedip 10 kali'**
  String get istirahatStep2;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Regangkan tangan ke atas'**
  String get istirahatStep3;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Sudah segar lagi!'**
  String get istirahatDoneTitle;

  /// Satuan di bawah angka hitung mundur
  ///
  /// In id, this message translates to:
  /// **'detik'**
  String get istirahatSecs;

  /// Label semantik hitung mundur istirahat
  ///
  /// In id, this message translates to:
  /// **'Sisa waktu istirahat: {n} detik'**
  String istirahatTimer(int n);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Waktu main hari ini sudah habis'**
  String get habisTitle;

  /// Subjudul Waktu Habis
  ///
  /// In id, this message translates to:
  /// **'Sampai besok, {name}! Moci juga mau tidur dulu.'**
  String habisSub(String name);

  /// No description provided for @habisNote.
  ///
  /// In id, this message translates to:
  /// **'Orang tua bisa mengubah batas waktu harian di Area Orang Tua.'**
  String get habisNote;

  /// No description provided for @habisParents.
  ///
  /// In id, this message translates to:
  /// **'Untuk orang tua'**
  String get habisParents;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat!'**
  String get hebatGreat;

  /// Teks jumlah bintang yang didapat
  ///
  /// In id, this message translates to:
  /// **'Kamu dapat {count} bintang!'**
  String hebatEarned(int count);

  /// Label semantik pil bintang di Hebat
  ///
  /// In id, this message translates to:
  /// **'{total} bintang, bertambah {count}'**
  String hebatStarsLabel(int total, int count);

  /// No description provided for @hebatNewSticker.
  ///
  /// In id, this message translates to:
  /// **'Stiker baru'**
  String get hebatNewSticker;

  /// No description provided for @hebatAgain.
  ///
  /// In id, this message translates to:
  /// **'Main lagi'**
  String get hebatAgain;

  /// No description provided for @hebatNext.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get hebatNext;

  /// No description provided for @hebatAlbum.
  ///
  /// In id, this message translates to:
  /// **'Album stiker'**
  String get hebatAlbum;

  /// No description provided for @hebatNewTag.
  ///
  /// In id, this message translates to:
  /// **'BARU'**
  String get hebatNewTag;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Yeay, kamu berhasil! Kamu dapat tiga bintang dan stiker baru!'**
  String get hebatYay;

  /// No description provided for @hebatBubble.
  ///
  /// In id, this message translates to:
  /// **'Yeay, kamu berhasil!'**
  String get hebatBubble;

  /// Gelembung Moci memakai nama anak (hanya teks layar)
  ///
  /// In id, this message translates to:
  /// **'Yeay, {name} berhasil!'**
  String hebatBubbleName(String name);

  /// No description provided for @hebatTapHint.
  ///
  /// In id, this message translates to:
  /// **'ketuk untuk mendengar'**
  String get hebatTapHint;

  /// No description provided for @stiker_kucing.
  ///
  /// In id, this message translates to:
  /// **'Kucing'**
  String get stiker_kucing;

  /// No description provided for @stiker_ikan.
  ///
  /// In id, this message translates to:
  /// **'Ikan'**
  String get stiker_ikan;

  /// No description provided for @stiker_singa.
  ///
  /// In id, this message translates to:
  /// **'Singa'**
  String get stiker_singa;

  /// No description provided for @stiker_gajah.
  ///
  /// In id, this message translates to:
  /// **'Gajah'**
  String get stiker_gajah;

  /// No description provided for @stiker_panda.
  ///
  /// In id, this message translates to:
  /// **'Panda'**
  String get stiker_panda;

  /// No description provided for @stiker_pinguin.
  ///
  /// In id, this message translates to:
  /// **'Pinguin'**
  String get stiker_pinguin;

  /// No description provided for @stiker_apel.
  ///
  /// In id, this message translates to:
  /// **'Apel'**
  String get stiker_apel;

  /// No description provided for @stiker_pisang.
  ///
  /// In id, this message translates to:
  /// **'Pisang'**
  String get stiker_pisang;

  /// No description provided for @stiker_stroberi.
  ///
  /// In id, this message translates to:
  /// **'Stroberi'**
  String get stiker_stroberi;

  /// No description provided for @stiker_semangka.
  ///
  /// In id, this message translates to:
  /// **'Semangka'**
  String get stiker_semangka;

  /// No description provided for @stiker_nanas.
  ///
  /// In id, this message translates to:
  /// **'Nanas'**
  String get stiker_nanas;

  /// No description provided for @stiker_buahnaga.
  ///
  /// In id, this message translates to:
  /// **'Buah Naga'**
  String get stiker_buahnaga;

  /// No description provided for @stiker_wortel.
  ///
  /// In id, this message translates to:
  /// **'Wortel'**
  String get stiker_wortel;

  /// No description provided for @stiker_tomat.
  ///
  /// In id, this message translates to:
  /// **'Tomat'**
  String get stiker_tomat;

  /// No description provided for @stiker_brokoli.
  ///
  /// In id, this message translates to:
  /// **'Brokoli'**
  String get stiker_brokoli;

  /// No description provided for @stiker_jagung.
  ///
  /// In id, this message translates to:
  /// **'Jagung'**
  String get stiker_jagung;

  /// No description provided for @stiker_labu.
  ///
  /// In id, this message translates to:
  /// **'Labu'**
  String get stiker_labu;

  /// No description provided for @stiker_jamur.
  ///
  /// In id, this message translates to:
  /// **'Jamur'**
  String get stiker_jamur;

  /// No description provided for @stiker_mobil.
  ///
  /// In id, this message translates to:
  /// **'Mobil'**
  String get stiker_mobil;

  /// No description provided for @stiker_bus.
  ///
  /// In id, this message translates to:
  /// **'Bus'**
  String get stiker_bus;

  /// No description provided for @stiker_kereta.
  ///
  /// In id, this message translates to:
  /// **'Kereta'**
  String get stiker_kereta;

  /// No description provided for @stiker_pesawat.
  ///
  /// In id, this message translates to:
  /// **'Pesawat'**
  String get stiker_pesawat;

  /// No description provided for @stiker_kapal.
  ///
  /// In id, this message translates to:
  /// **'Kapal'**
  String get stiker_kapal;

  /// No description provided for @stiker_roket.
  ///
  /// In id, this message translates to:
  /// **'Roket'**
  String get stiker_roket;

  /// No description provided for @stiker_bola.
  ///
  /// In id, this message translates to:
  /// **'Bola'**
  String get stiker_bola;

  /// No description provided for @stiker_balon.
  ///
  /// In id, this message translates to:
  /// **'Balon'**
  String get stiker_balon;

  /// No description provided for @stiker_kado.
  ///
  /// In id, this message translates to:
  /// **'Kado'**
  String get stiker_kado;

  /// No description provided for @stiker_eskrim.
  ///
  /// In id, this message translates to:
  /// **'Es Krim'**
  String get stiker_eskrim;

  /// No description provided for @stiker_layang.
  ///
  /// In id, this message translates to:
  /// **'Layang-layang'**
  String get stiker_layang;

  /// No description provided for @stiker_payung.
  ///
  /// In id, this message translates to:
  /// **'Payung'**
  String get stiker_payung;

  /// Judul Area Orang Tua
  ///
  /// In id, this message translates to:
  /// **'Area Orang Tua'**
  String get orangTuaTitle;

  /// Tombol kunci dan kembali
  ///
  /// In id, this message translates to:
  /// **'Kunci dan kembali ke beranda'**
  String get orangTuaBack;

  /// Lencana kunci
  ///
  /// In id, this message translates to:
  /// **'Terkunci saat keluar'**
  String get orangTuaLocks;

  /// Label kartu profil
  ///
  /// In id, this message translates to:
  /// **'Profil anak'**
  String get orangTuaProfile;

  /// Tombol pensil dan judul dialog nama
  ///
  /// In id, this message translates to:
  /// **'Ubah nama anak'**
  String get orangTuaEditName;

  /// Nama bila belum diisi
  ///
  /// In id, this message translates to:
  /// **'Si kecil'**
  String get orangTuaChildFallback;

  /// Subjudul profil
  ///
  /// In id, this message translates to:
  /// **'Usia {age} tahun · {level}'**
  String orangTuaSub(String age, String level);

  /// Label pil usia
  ///
  /// In id, this message translates to:
  /// **'Level usia'**
  String get orangTuaAgeLevel;

  /// Pil usia
  ///
  /// In id, this message translates to:
  /// **'{range} thn'**
  String orangTuaAgeChip(String range);

  /// Level usia 2-3
  ///
  /// In id, this message translates to:
  /// **'Pemula'**
  String get orangTuaLevelPemula;

  /// Level usia 4-5
  ///
  /// In id, this message translates to:
  /// **'Penjelajah'**
  String get orangTuaLevelPenjelajah;

  /// Level usia 6-7
  ///
  /// In id, this message translates to:
  /// **'Pembaca'**
  String get orangTuaLevelPembaca;

  /// Isian nama
  ///
  /// In id, this message translates to:
  /// **'Nama anak'**
  String get orangTuaNameHint;

  /// Simpan nama
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get orangTuaSave;

  /// Tutup dialog
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get orangTuaCancel;

  /// Judul kartu hari ini
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get orangTuaToday;

  /// Label kartu hari ini
  ///
  /// In id, this message translates to:
  /// **'Waktu bermain'**
  String get orangTuaPlayTime;

  /// Satuan di tengah cincin
  ///
  /// In id, this message translates to:
  /// **'menit'**
  String get orangTuaMin;

  /// Ubin bintang
  ///
  /// In id, this message translates to:
  /// **'bintang'**
  String get orangTuaStars;

  /// Ubin stiker
  ///
  /// In id, this message translates to:
  /// **'stiker'**
  String get orangTuaStickers;

  /// Ubin karya
  ///
  /// In id, this message translates to:
  /// **'karya'**
  String get orangTuaArt;

  /// Keterangan cincin tanpa batas
  ///
  /// In id, this message translates to:
  /// **'Tanpa batas harian'**
  String get orangTuaNoLimit;

  /// Chip tanpa batas
  ///
  /// In id, this message translates to:
  /// **'Bebas'**
  String get orangTuaUnlimited;

  /// Keterangan cincin
  ///
  /// In id, this message translates to:
  /// **'dari {limit} menit hari ini'**
  String orangTuaRingOf(int limit);

  /// Chip sisa waktu
  ///
  /// In id, this message translates to:
  /// **'Sisa {n} menit'**
  String orangTuaLeft(int n);

  /// Chip waktu habis
  ///
  /// In id, this message translates to:
  /// **'Waktu habis'**
  String get orangTuaTimeUp;

  /// Judul kartu perkembangan
  ///
  /// In id, this message translates to:
  /// **'Perkembangan'**
  String get orangTuaProgress;

  /// Label kartu perkembangan
  ///
  /// In id, this message translates to:
  /// **'Minggu ini'**
  String get orangTuaWeek;

  /// Saran modul dengan cakupan terendah (teks baru, perlu ditinjau)
  ///
  /// In id, this message translates to:
  /// **'Saran: coba {modul} bersama minggu ini.'**
  String orangTuaTip(String modul);

  /// Judul kartu pengaturan
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get orangTuaSettings;

  /// Label pilihan bahasa
  ///
  /// In id, this message translates to:
  /// **'Bahasa · Language'**
  String get orangTuaLangLabel;

  /// Label cara baca huruf
  ///
  /// In id, this message translates to:
  /// **'Cara baca huruf'**
  String get orangTuaLetters;

  /// Pilihan fonik
  ///
  /// In id, this message translates to:
  /// **'Bunyi (fonik)'**
  String get orangTuaPhonics;

  /// Pilihan nama huruf
  ///
  /// In id, this message translates to:
  /// **'Nama huruf'**
  String get orangTuaNames;

  /// Contoh fonik
  ///
  /// In id, this message translates to:
  /// **'B dibaca “beh”, lalu “Bola!”'**
  String get orangTuaLettersHintPhonics;

  /// Contoh nama huruf
  ///
  /// In id, this message translates to:
  /// **'B dibaca “be”, lalu “Bola!”'**
  String get orangTuaLettersHintNames;

  /// Label batas harian
  ///
  /// In id, this message translates to:
  /// **'Batas waktu harian'**
  String get orangTuaLimit;

  /// Pil batas harian
  ///
  /// In id, this message translates to:
  /// **'{n} mnt'**
  String orangTuaLimitMin(int n);

  /// Pil tanpa batas
  ///
  /// In id, this message translates to:
  /// **'Bebas'**
  String get orangTuaLimitOff;

  /// Saklar musik
  ///
  /// In id, this message translates to:
  /// **'Musik latar'**
  String get orangTuaMusic;

  /// Saklar efek suara
  ///
  /// In id, this message translates to:
  /// **'Efek suara'**
  String get orangTuaSfx;

  /// Saklar pengingat istirahat
  ///
  /// In id, this message translates to:
  /// **'Pengingat istirahat'**
  String get orangTuaBreaks;

  /// Lencana
  ///
  /// In id, this message translates to:
  /// **'Tanpa iklan'**
  String get orangTuaBadgeAds;

  /// Lencana
  ///
  /// In id, this message translates to:
  /// **'Tanpa pembelian dalam aplikasi'**
  String get orangTuaBadgePurchases;

  /// Lencana
  ///
  /// In id, this message translates to:
  /// **'Bisa offline'**
  String get orangTuaBadgeOffline;

  /// Lencana
  ///
  /// In id, this message translates to:
  /// **'Data hanya di perangkat ini'**
  String get orangTuaBadgeData;

  /// Pil dan tombol hapus semua data
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data'**
  String get orangTuaDelete;

  /// Judul dialog hapus
  ///
  /// In id, this message translates to:
  /// **'Hapus semua data?'**
  String get orangTuaDeleteTitle;

  /// Isi dialog hapus
  ///
  /// In id, this message translates to:
  /// **'Nama, pengaturan, bintang, stiker, dan karya di perangkat ini akan dihapus. Ini tidak bisa dibatalkan.'**
  String get orangTuaDeleteBody;

  /// Tombol hapus tahap kedua
  ///
  /// In id, this message translates to:
  /// **'Yakin hapus?'**
  String get orangTuaDeleteSure;

  /// Tautan kebijakan privasi
  ///
  /// In id, this message translates to:
  /// **'Kebijakan privasi'**
  String get orangTuaPrivacy;

  /// Tautan surel dukungan
  ///
  /// In id, this message translates to:
  /// **'Hubungi kami'**
  String get orangTuaSupport;

  /// Judul bilah atas layar huruf
  ///
  /// In id, this message translates to:
  /// **'Huruf'**
  String get hurufTitle;

  /// Pil mode kenal huruf
  ///
  /// In id, this message translates to:
  /// **'Kenali'**
  String get hurufLearn;

  /// Pil mode tulis
  ///
  /// In id, this message translates to:
  /// **'Tulis'**
  String get hurufWrite;

  /// Pil mode ucapkan
  ///
  /// In id, this message translates to:
  /// **'Ucapkan'**
  String get hurufSay;

  /// Label semantik pil mode
  ///
  /// In id, this message translates to:
  /// **'Mode belajar'**
  String get modeSemantic;

  /// Petunjuk menulis di kartu kunci
  ///
  /// In id, this message translates to:
  /// **'Geser Moci ikuti panah kuning sampai ke bintang!'**
  String get tulisFollow;

  /// Awalan judul di kartu papan
  ///
  /// In id, this message translates to:
  /// **'Tulis'**
  String get tulisWriteVerb;

  /// Awalan hitungan goresan
  ///
  /// In id, this message translates to:
  /// **'Garis'**
  String get tulisLine;

  /// Penghubung hitungan goresan
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get tulisOf;

  /// Keterangan semua goresan selesai
  ///
  /// In id, this message translates to:
  /// **'Selesai!'**
  String get tulisDone;

  /// Pujian di bilah selesai
  ///
  /// In id, this message translates to:
  /// **'Hebat!'**
  String get tulisGreat;

  /// Tombol ke kunci berikutnya
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get tulisNext;

  /// Judul pilihan krayon
  ///
  /// In id, this message translates to:
  /// **'Krayon'**
  String get tulisCrayons;

  /// Tombol mengulang goresan
  ///
  /// In id, this message translates to:
  /// **'Ulangi'**
  String get tulisAgain;

  /// Tombol mendengar petunjuk
  ///
  /// In id, this message translates to:
  /// **'Dengar'**
  String get tulisListen;

  /// Nama area menulis
  ///
  /// In id, this message translates to:
  /// **'Area menulis'**
  String get tulisArea;

  /// Label tombol ulang di bilah selesai
  ///
  /// In id, this message translates to:
  /// **'Tulis lagi'**
  String get tulisWriteAgain;

  /// Nama krayon pertama
  ///
  /// In id, this message translates to:
  /// **'Krayon merah muda'**
  String get tulisColor1;

  /// Nama krayon kedua
  ///
  /// In id, this message translates to:
  /// **'Krayon biru'**
  String get tulisColor2;

  /// Nama krayon ketiga
  ///
  /// In id, this message translates to:
  /// **'Krayon hijau'**
  String get tulisColor3;

  /// Nama krayon keempat
  ///
  /// In id, this message translates to:
  /// **'Krayon oranye'**
  String get tulisColor4;

  /// Nama krayon kelima
  ///
  /// In id, this message translates to:
  /// **'Krayon ungu'**
  String get tulisColor5;

  /// Judul kisi kunci
  ///
  /// In id, this message translates to:
  /// **'Pilih huruf'**
  String get tulisPickHuruf;

  /// Satuan huruf di label
  ///
  /// In id, this message translates to:
  /// **'huruf'**
  String get tulisUnitHuruf;

  /// Label semantik kunci huruf
  ///
  /// In id, this message translates to:
  /// **'Tulis huruf {huruf}'**
  String tulisKeyLabel(String huruf);

  /// Label area menulis
  ///
  /// In id, this message translates to:
  /// **'Area menulis huruf {huruf}'**
  String tulisAreaLabel(String huruf);

  /// Hitungan goresan
  ///
  /// In id, this message translates to:
  /// **'{n} dari {total}'**
  String tulisProgress(int n, int total);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo tulis huruf'**
  String get tulisSayStartHuruf;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat! Kamu bisa menulis huruf'**
  String get tulisSayDoneHuruf;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bagus!'**
  String get tulisNice;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Geser Moci ikuti panah kuning sampai ke bintang.'**
  String get tulisHint;

  /// Subjudul kartu Lanjutkan untuk Tulis Huruf
  ///
  /// In id, this message translates to:
  /// **'Tulis huruf {huruf}'**
  String berandaContinueTulisHuruf(String huruf);

  /// Judul kisi kunci angka
  ///
  /// In id, this message translates to:
  /// **'Pilih angka'**
  String get tulisPickAngka;

  /// Label semantik kunci angka
  ///
  /// In id, this message translates to:
  /// **'Tulis angka {angka}'**
  String tulisKeyLabelAngka(String angka);

  /// Label area menulis angka
  ///
  /// In id, this message translates to:
  /// **'Area menulis angka {angka}'**
  String tulisAreaLabelAngka(String angka);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo tulis angka'**
  String get tulisSayStartAngka;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat! Kamu bisa menulis angka'**
  String get tulisSayDoneAngka;

  /// Judul bilah atas layar angka
  ///
  /// In id, this message translates to:
  /// **'Angka'**
  String get angkaTitle;

  /// Pil mode berhitung
  ///
  /// In id, this message translates to:
  /// **'Berhitung'**
  String get angkaCount;

  /// Satuan angka di judul
  ///
  /// In id, this message translates to:
  /// **'angka'**
  String get tulisUnitAngka;

  /// Subjudul kartu Lanjutkan untuk Tulis Angka
  ///
  /// In id, this message translates to:
  /// **'Tulis angka {angka}'**
  String berandaContinueTulisAngka(String angka);

  /// Label tombol dengar di layar huruf
  ///
  /// In id, this message translates to:
  /// **'Dengarkan bunyi huruf dan kata'**
  String get hurufListen;

  /// Label tombol huruf sebelumnya
  ///
  /// In id, this message translates to:
  /// **'Huruf sebelumnya'**
  String get hurufPrev;

  /// Label tombol huruf berikutnya
  ///
  /// In id, this message translates to:
  /// **'Huruf berikutnya'**
  String get hurufNext;

  /// Awalan label huruf di kisi
  ///
  /// In id, this message translates to:
  /// **'Huruf'**
  String get hurufLetter;

  /// Petunjuk ketuk huruf dalam mode fonik
  ///
  /// In id, this message translates to:
  /// **'ketuk untuk mendengar bunyinya'**
  String get hurufTapHint;

  /// Petunjuk ketuk huruf dalam mode nama
  ///
  /// In id, this message translates to:
  /// **'ketuk untuk mendengar namanya'**
  String get hurufTapHintName;

  /// Pil bunyi huruf
  ///
  /// In id, this message translates to:
  /// **'Bunyi'**
  String get hurufSound;

  /// Pil nama huruf
  ///
  /// In id, this message translates to:
  /// **'Nama:'**
  String get hurufName;

  /// Awalan label semantik pil bunyi
  ///
  /// In id, this message translates to:
  /// **'Bunyi huruf'**
  String get hurufSoundOf;

  /// Awalan label semantik pil nama
  ///
  /// In id, this message translates to:
  /// **'Nama huruf'**
  String get hurufNameOf;

  /// Label semantik huruf besar
  ///
  /// In id, this message translates to:
  /// **'Huruf {huruf}, {petunjuk}'**
  String hurufLetterLabel(String huruf, String petunjuk);

  /// Label semantik pil bunyi
  ///
  /// In id, this message translates to:
  /// **'Bunyi huruf {huruf} {bunyi}'**
  String hurufSoundAria(String huruf, String bunyi);

  /// Label semantik pil nama
  ///
  /// In id, this message translates to:
  /// **'Nama huruf {huruf}'**
  String hurufNameAria(String huruf);

  /// Label semantik kisi huruf
  ///
  /// In id, this message translates to:
  /// **'Pilih huruf'**
  String get hurufGridLabel;

  /// Subjudul kartu Lanjutkan untuk Kenal Huruf
  ///
  /// In id, this message translates to:
  /// **'Huruf {huruf}'**
  String berandaContinueHuruf(String huruf);
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
