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
  /// **'Panggil {panggilan}, ya!'**
  String gerbangHelp(String panggilan);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ini khusus orang tua. Panggil {panggilan}, ya!'**
  String gerbangHelpSay(String panggilan);

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

  /// Label pilihan sebutan orang tua
  ///
  /// In id, this message translates to:
  /// **'Panggilan untuk orang tua'**
  String get orangTuaPanggilan;

  /// Pilihan panggilan ayah dan bunda
  ///
  /// In id, this message translates to:
  /// **'Ayah / Bunda'**
  String get orangTuaPanggilanAyahBunda;

  /// Pilihan panggilan bapak dan ibu
  ///
  /// In id, this message translates to:
  /// **'Bapak / Ibu'**
  String get orangTuaPanggilanBapakIbu;

  /// Pilihan panggilan papi dan mami
  ///
  /// In id, this message translates to:
  /// **'Papi / Mami'**
  String get orangTuaPanggilanPapiMami;

  /// Pilihan panggilan daddy dan mommy
  ///
  /// In id, this message translates to:
  /// **'Daddy / Mommy'**
  String get orangTuaPanggilanDaddyMommy;

  /// Pilihan panggilan orang tua
  ///
  /// In id, this message translates to:
  /// **'Orang tua'**
  String get orangTuaPanggilanOrangTua;

  /// Frasa panggilan di dalam kalimat
  ///
  /// In id, this message translates to:
  /// **'Ayah atau Bunda'**
  String get panggilanAyahBunda;

  /// Frasa panggilan di dalam kalimat
  ///
  /// In id, this message translates to:
  /// **'Bapak atau Ibu'**
  String get panggilanBapakIbu;

  /// Frasa panggilan di dalam kalimat
  ///
  /// In id, this message translates to:
  /// **'Papi atau Mami'**
  String get panggilanPapiMami;

  /// Frasa panggilan di dalam kalimat
  ///
  /// In id, this message translates to:
  /// **'Daddy atau Mommy'**
  String get panggilanDaddyMommy;

  /// Frasa panggilan di dalam kalimat
  ///
  /// In id, this message translates to:
  /// **'orang tua'**
  String get panggilanOrangTua;

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
  /// **'Tanpa pembelian'**
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

  /// Pil keterangan suara
  ///
  /// In id, this message translates to:
  /// **'Tentang suara'**
  String get orangTuaSounds;

  /// Judul dialog keterangan suara
  ///
  /// In id, this message translates to:
  /// **'Tentang suara di Moci'**
  String get orangTuaSoundsTitle;

  /// Paragraf narasi TTS
  ///
  /// In id, this message translates to:
  /// **'Narasi Moci dibacakan suara bawaan perangkat (text-to-speech), bukan rekaman. Logat dan nadanya mengikuti suara yang terpasang di iPad atau HP, jadi bisa berbeda di tiap perangkat.'**
  String get orangTuaSoundsTts;

  /// Paragraf tip memasang suara TTS
  ///
  /// In id, this message translates to:
  /// **'Kalau ingin suara yang lebih jelas, pasang suara lain di pengaturan perangkat. Di iOS: Pengaturan, Aksesibilitas, Konten Lisan, Suara. Di Android: pengaturan suara di perangkat.'**
  String get orangTuaSoundsTip;

  /// Paragraf sumber Freesound
  ///
  /// In id, this message translates to:
  /// **'Suara hewan dan efek suara diambil dari Freesound.org dengan lisensi CC0 (domain publik). Semuanya sudah dipotong dan volumenya disamakan untuk Moci.'**
  String get orangTuaSoundsFreesound;

  /// Paragraf suara pengganti
  ///
  /// In id, this message translates to:
  /// **'Sebagian suara hewan adalah pengganti karena tidak ada rekaman CC0 yang cocok: orangutan memakai suara owa, dan beberapa hewan kecil memakai efek yang mirip.'**
  String get orangTuaSoundsSwap;

  /// Paragraf alat musik dan daftar lisensi
  ///
  /// In id, this message translates to:
  /// **'Nada alat musik, yaitu xilofon dan drum, dibuat sendiri untuk Moci. Daftar lengkap sumber, pengunggah, dan tautannya ada di berkas LICENSES.csv pada folder assets/audio di repositori Moci.'**
  String get orangTuaSoundsInstruments;

  /// Tombol tutup dialog suara
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get orangTuaSoundsClose;

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

  /// Label tombol dengar di layar angka
  ///
  /// In id, this message translates to:
  /// **'Dengar angkanya'**
  String get angkaListen;

  /// Tombol hitung otomatis
  ///
  /// In id, this message translates to:
  /// **'Hitung bareng'**
  String get angkaAuto;

  /// Label semantik grup rentang angka
  ///
  /// In id, this message translates to:
  /// **'Rentang angka'**
  String get angkaRange;

  /// Label semantik kisi pilih angka
  ///
  /// In id, this message translates to:
  /// **'Pilih angka'**
  String get angkaPick;

  /// Label semantik satu angka di kisi
  ///
  /// In id, this message translates to:
  /// **'Angka {n}'**
  String angkaNumber(int n);

  /// Judul panel hitung
  ///
  /// In id, this message translates to:
  /// **'Ayo hitung {benda}!'**
  String angkaCountPrompt(String benda);

  /// Label semantik benda yang belum dihitung
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk menghitung'**
  String get angkaTapIt;

  /// Bilah selesai hitung
  ///
  /// In id, this message translates to:
  /// **'Ada {kata} {benda}!'**
  String angkaDone(String kata, String benda);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat, hitungannya benar!'**
  String get angkaDoneSay;

  /// Subjudul kartu Lanjutkan untuk Berhitung
  ///
  /// In id, this message translates to:
  /// **'Angka {angka}'**
  String berandaContinueAngka(String angka);

  /// Tombol dengar contoh Ucapkan
  ///
  /// In id, this message translates to:
  /// **'Dengar contoh'**
  String get ucapkanHear;

  /// Gelembung giliran bicara
  ///
  /// In id, this message translates to:
  /// **'Sekarang giliranmu! Bilang:'**
  String get ucapkanYourTurn;

  /// Status Ucapkan saat menunggu
  ///
  /// In id, this message translates to:
  /// **'Ketuk mic, lalu ucapkan'**
  String get ucapkanIdle;

  /// Status Ucapkan saat mendengar
  ///
  /// In id, this message translates to:
  /// **'Moci mendengarkan…'**
  String get ucapkanListen;

  /// Status Ucapkan setelah berhasil
  ///
  /// In id, this message translates to:
  /// **'Bagus sekali!'**
  String get ucapkanGood;

  /// Tombol ulangi kata
  ///
  /// In id, this message translates to:
  /// **'Ulangi'**
  String get ucapkanAgain;

  /// Tombol kata berikutnya
  ///
  /// In id, this message translates to:
  /// **'Kata berikutnya'**
  String get ucapkanNextWord;

  /// Label tombol suku kata
  ///
  /// In id, this message translates to:
  /// **'Suku kata'**
  String get ucapkanSyl;

  /// Label tombol mikrofon saat menunggu
  ///
  /// In id, this message translates to:
  /// **'Ketuk lalu ucapkan'**
  String get ucapkanMicIdle;

  /// Label tombol mikrofon saat mendengar
  ///
  /// In id, this message translates to:
  /// **'Moci sedang mendengarkan'**
  String get ucapkanMicListen;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo bilang'**
  String get ucapkanLetsSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo coba lagi!'**
  String get ucapkanTryAgain;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat! Kamu bisa bilang'**
  String get ucapkanDoneSay;

  /// Judul dialog gerbang mikrofon
  ///
  /// In id, this message translates to:
  /// **'Panggil {panggilan}'**
  String ucapkanMicAskTitle(String panggilan);

  /// Isi dialog gerbang mikrofon
  ///
  /// In id, this message translates to:
  /// **'Mikrofon hanya dinyalakan oleh orang tua. Suara Adik dikenali di perangkat ini saja, tidak disimpan dan tidak dikirim.'**
  String get ucapkanMicAskBody;

  /// Tombol buka Gerbang Orang Tua
  ///
  /// In id, this message translates to:
  /// **'Buka Gerbang'**
  String get ucapkanMicAskAction;

  /// Keterangan mode dengar dan tiru karena izin ditolak
  ///
  /// In id, this message translates to:
  /// **'Tanpa mikrofon, kita dengar dan tiru saja, ya!'**
  String get ucapkanMicDenied;

  /// Keterangan mode dengar dan tiru karena pengenalan tidak tersedia
  ///
  /// In id, this message translates to:
  /// **'Moci belum bisa mendengar di perangkat ini. Dengar dan tiru saja, ya!'**
  String get ucapkanMicUnavailable;

  /// Tombol mode dengar dan tiru
  ///
  /// In id, this message translates to:
  /// **'Dengar dan tiru'**
  String get ucapkanPractice;

  /// Label semantik tombol mikrofon
  ///
  /// In id, this message translates to:
  /// **'Ketuk lalu ucapkan {kata}'**
  String ucapkanMicLabel(String kata);

  /// Label semantik kata Ucapkan
  ///
  /// In id, this message translates to:
  /// **'{kata}, ketuk untuk mendengar'**
  String ucapkanWordLabel(String kata);

  /// Subjudul kartu Lanjutkan untuk Ucapkan
  ///
  /// In id, this message translates to:
  /// **'Ucapkan {kata}'**
  String berandaContinueUcapkan(String kata);

  /// Judul layar Ayo Membaca
  ///
  /// In id, this message translates to:
  /// **'Ayo Membaca'**
  String get membacaTitle;

  /// Label aksesibilitas tiga tab mode membaca
  ///
  /// In id, this message translates to:
  /// **'Mode membaca'**
  String get membacaModes;

  /// Tab Suku Kata
  ///
  /// In id, this message translates to:
  /// **'Suku Kata'**
  String get membacaSukuKata;

  /// Tab Susun Kata
  ///
  /// In id, this message translates to:
  /// **'Susun Kata'**
  String get membacaSusunKata;

  /// Tab Kalimat
  ///
  /// In id, this message translates to:
  /// **'Kalimat'**
  String get membacaKalimat;

  /// Judul kisi konsonan
  ///
  /// In id, this message translates to:
  /// **'Pilih huruf'**
  String get sukuKataPilih;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk suku kata untuk mendengarnya!'**
  String get sukuKataTip;

  /// Tombol contoh kata
  ///
  /// In id, this message translates to:
  /// **'Dengar kata'**
  String get sukuKataHear;

  /// Tombol membaca lima suku kata
  ///
  /// In id, this message translates to:
  /// **'Baca semua'**
  String get sukuKataReadAll;

  /// Label contoh kata
  ///
  /// In id, this message translates to:
  /// **'Contoh kata'**
  String get sukuKataExample;

  /// Label suku tanpa contoh kata
  ///
  /// In id, this message translates to:
  /// **'Ayo ucapkan!'**
  String get sukuKataSayIt;

  /// Label aksesibilitas tombol konsonan
  ///
  /// In id, this message translates to:
  /// **'Huruf {huruf}'**
  String sukuKataLetter(String huruf);

  /// Label aksesibilitas kartu suku kata
  ///
  /// In id, this message translates to:
  /// **'Suku kata {suku}'**
  String sukuKataSyllable(String suku);

  /// Label pilihan level
  ///
  /// In id, this message translates to:
  /// **'Level'**
  String get susunKataLevel;

  /// Pil level dua suku kata
  ///
  /// In id, this message translates to:
  /// **'2 suku kata'**
  String get susunKataLevel2;

  /// Pil level tiga suku kata
  ///
  /// In id, this message translates to:
  /// **'3 suku kata'**
  String get susunKataLevel3;

  /// Tombol mendengar kata
  ///
  /// In id, this message translates to:
  /// **'Dengar katanya'**
  String get susunKataHear;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk suku kata secara berurutan'**
  String get susunKataIns;

  /// Tombol ronde berikutnya
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get susunKataNext;

  /// Petunjuk saat kotak masih kosong
  ///
  /// In id, this message translates to:
  /// **'Dengarkan, lalu ketuk suku kata pertama!'**
  String get susunKataHintStart;

  /// Petunjuk setelah satu kotak terisi
  ///
  /// In id, this message translates to:
  /// **'Bagus! Sekarang suku kata berikutnya.'**
  String get susunKataHintMore;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ups, belum tepat. Coba lagi!'**
  String get susunKataTryAgain;

  /// Label aksesibilitas kotak susun
  ///
  /// In id, this message translates to:
  /// **'Kotak {nomor}'**
  String susunKataSlot(int nomor);

  /// Keterangan kotak kosong
  ///
  /// In id, this message translates to:
  /// **'kosong'**
  String get susunKataEmpty;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul!'**
  String get susunKataYes;

  /// Label aksesibilitas keping suku kata
  ///
  /// In id, this message translates to:
  /// **'Suku kata {suku}'**
  String susunKataTile(String suku);

  /// Label aksesibilitas titik kemajuan
  ///
  /// In id, this message translates to:
  /// **'Kemajuan'**
  String get susunKataProgress;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk kata untuk mendengarnya'**
  String get kalimatIns;

  /// Tombol karaoke kalimat
  ///
  /// In id, this message translates to:
  /// **'Baca bersama'**
  String get kalimatRead;

  /// Tombol kalimat sebelumnya
  ///
  /// In id, this message translates to:
  /// **'Kalimat sebelumnya'**
  String get kalimatPrev;

  /// Tombol kalimat berikutnya
  ///
  /// In id, this message translates to:
  /// **'Kalimat berikutnya'**
  String get kalimatNext;

  /// Pertanyaan mode tebak gambar
  ///
  /// In id, this message translates to:
  /// **'Gambar mana yang cocok?'**
  String get kalimatWhich;

  /// Pil mode baca
  ///
  /// In id, this message translates to:
  /// **'Baca'**
  String get kalimatReadMode;

  /// Pil mode tebak gambar
  ///
  /// In id, this message translates to:
  /// **'Tebak gambar'**
  String get kalimatQuizMode;

  /// Gelembung petunjuk karaoke
  ///
  /// In id, this message translates to:
  /// **'Ketuk \"Baca bersama\" lalu ikuti kata yang menyala!'**
  String get kalimatReadTip;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul! Pintar sekali!'**
  String get kalimatYes;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan yang itu. Coba lagi!'**
  String get kalimatNo;

  /// Label aksesibilitas gambar kalimat
  ///
  /// In id, this message translates to:
  /// **'Gambar kalimat'**
  String get kalimatPicture;

  /// Label semantik grup saring galeri
  ///
  /// In id, this message translates to:
  /// **'Jenis gambar'**
  String get mewarnaiFilter;

  /// Pil saring semua gambar
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get mewarnaiTabSemua;

  /// Pil saring gambar hewan
  ///
  /// In id, this message translates to:
  /// **'Hewan'**
  String get mewarnaiTabHewan;

  /// Pil saring gambar laut
  ///
  /// In id, this message translates to:
  /// **'Laut'**
  String get mewarnaiTabLaut;

  /// Pil saring gambar buah dan sayur
  ///
  /// In id, this message translates to:
  /// **'Buah & Sayur'**
  String get mewarnaiTabBuah;

  /// Pil saring gambar kota
  ///
  /// In id, this message translates to:
  /// **'Kota'**
  String get mewarnaiTabKota;

  /// Pil saring gambar benda dan alam
  ///
  /// In id, this message translates to:
  /// **'Benda & Alam'**
  String get mewarnaiTabBenda;

  /// Petunjuk di bawah galeri
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar yang mau kamu warnai!'**
  String get mewarnaiHintPick;

  /// Label semantik kartu halaman
  ///
  /// In id, this message translates to:
  /// **'Warnai gambar: {nama}'**
  String mewarnaiOpenPage(String nama);

  /// Lencana halaman yang drafnya berisi
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get mewarnaiContinue;

  /// Nama kartu dan judul layar Karyaku
  ///
  /// In id, this message translates to:
  /// **'Karyaku'**
  String get mewarnaiKaryaku;

  /// Jumlah karya di kartu Karyaku
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Belum ada karya} =1{1 karya} other{{count} karya}}'**
  String mewarnaiKaryaCount(int count);

  /// Label semantik kartu Karyaku
  ///
  /// In id, this message translates to:
  /// **'Buka Karyaku, {count} karya'**
  String mewarnaiOpenKaryaku(int count);

  /// Tombol kembali dari kanvas
  ///
  /// In id, this message translates to:
  /// **'Kembali ke galeri'**
  String get mewarnaiBackGaleri;

  /// Tombol buka pemilih gambar
  ///
  /// In id, this message translates to:
  /// **'Gambar'**
  String get mewarnaiChangePage;

  /// Tombol batal langkah terakhir
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get mewarnaiUndo;

  /// Tombol mengosongkan halaman
  ///
  /// In id, this message translates to:
  /// **'Mulai lagi'**
  String get mewarnaiClear;

  /// Tombol menyimpan karya
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get mewarnaiSave;

  /// Label grup alat di panel
  ///
  /// In id, this message translates to:
  /// **'Alat'**
  String get mewarnaiTools;

  /// Nama alat kuas
  ///
  /// In id, this message translates to:
  /// **'Kuas'**
  String get mewarnaiToolBrush;

  /// Nama alat isi
  ///
  /// In id, this message translates to:
  /// **'Isi'**
  String get mewarnaiToolFill;

  /// Nama alat hapus
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get mewarnaiToolErase;

  /// Nama alat stiker
  ///
  /// In id, this message translates to:
  /// **'Stiker'**
  String get mewarnaiToolCap;

  /// Label grup ukuran kuas
  ///
  /// In id, this message translates to:
  /// **'Ukuran kuas'**
  String get mewarnaiBrushSize;

  /// Ukuran kuas kecil
  ///
  /// In id, this message translates to:
  /// **'Kuas kecil'**
  String get mewarnaiBrushSmall;

  /// Ukuran kuas sedang
  ///
  /// In id, this message translates to:
  /// **'Kuas sedang'**
  String get mewarnaiBrushMedium;

  /// Ukuran kuas besar
  ///
  /// In id, this message translates to:
  /// **'Kuas besar'**
  String get mewarnaiBrushBig;

  /// Label grup krayon
  ///
  /// In id, this message translates to:
  /// **'Krayon'**
  String get mewarnaiCrayons;

  /// Label grup stiker
  ///
  /// In id, this message translates to:
  /// **'Stiker'**
  String get mewarnaiCaps;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Warnai di dalam bagian gambar. Krayonnya tidak akan keluar garis!'**
  String get mewarnaiHintBrush;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk satu bagian untuk mengisinya dengan warna.'**
  String get mewarnaiHintFill;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Gosok untuk menghapus warna.'**
  String get mewarnaiHintErase;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk gambar untuk menempel stiker.'**
  String get mewarnaiHintCap;

  /// Label semantik kanvas
  ///
  /// In id, this message translates to:
  /// **'Gambar untuk diwarnai: {nama}'**
  String mewarnaiCanvasLabel(String nama);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ayo mulai dari awal!'**
  String get mewarnaiSayClear;

  /// Toast setelah karya tersimpan
  ///
  /// In id, this message translates to:
  /// **'Tersimpan di Karyaku!'**
  String get mewarnaiSaved;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Tersimpan! Bagus sekali!'**
  String get mewarnaiSaySaved;

  /// Judul pemilih gambar
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar'**
  String get mewarnaiPickPage;

  /// Tombol menutup dialog
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get mewarnaiClose;

  /// Petunjuk di atas kisi Karyaku
  ///
  /// In id, this message translates to:
  /// **'Ketuk gambar untuk melihatnya lebih besar.'**
  String get mewarnaiKaryakuHint;

  /// Judul Karyaku saat kosong
  ///
  /// In id, this message translates to:
  /// **'Belum ada karya'**
  String get mewarnaiKaryakuEmpty;

  /// Ajakan mewarnai saat Karyaku kosong
  ///
  /// In id, this message translates to:
  /// **'Yuk mewarnai dulu! Tekan Simpan, nanti gambarmu muncul di sini.'**
  String get mewarnaiKaryakuEmptyHint;

  /// Tombol membuka kanvas dengan isi karya
  ///
  /// In id, this message translates to:
  /// **'Warnai lagi'**
  String get mewarnaiColorAgain;

  /// Tombol menghapus karya
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get mewarnaiDelete;

  /// Konfirmasi hapus karya
  ///
  /// In id, this message translates to:
  /// **'Yakin hapus?'**
  String get mewarnaiDeleteConfirm;

  /// Label semantik kartu karya
  ///
  /// In id, this message translates to:
  /// **'Lihat karya: {nama}'**
  String mewarnaiViewArt(String nama);

  /// Subjudul hub Main Yuk
  ///
  /// In id, this message translates to:
  /// **'Pilih permainan'**
  String get mainYukSub;

  /// Lencana usia minimum permainan
  ///
  /// In id, this message translates to:
  /// **'Usia 2+'**
  String get mainYukAge2;

  /// Lencana usia minimum permainan
  ///
  /// In id, this message translates to:
  /// **'Usia 3+'**
  String get mainYukAge3;

  /// Lencana usia minimum permainan
  ///
  /// In id, this message translates to:
  /// **'Usia 4+'**
  String get mainYukAge4;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Gambar'**
  String get mainYukCocokkanHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Kartu Memori'**
  String get mainYukMemoriHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Tebak Bayangan'**
  String get mainYukBayanganHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Puzzle'**
  String get mainYukPuzzleHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Balon Huruf'**
  String get mainYukBalonHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Besar & Kecil'**
  String get mainYukBesarKecilHub;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Acak!'**
  String get mainYukTemaAcak;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Buah'**
  String get mainYukTemaBuah;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hewan'**
  String get mainYukTemaHewan;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Sayur'**
  String get mainYukTemaSayur;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Kendaraan'**
  String get mainYukTemaKendaraan;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Mainan & Benda'**
  String get mainYukTemaBenda;

  /// Jumlah pasangan permainan
  ///
  /// In id, this message translates to:
  /// **'{n} pasang'**
  String mainYukPairs(int n);

  /// Jumlah langkah permainan
  ///
  /// In id, this message translates to:
  /// **'Langkah: {n}'**
  String mainYukMoves(int n);

  /// Label pil level kesulitan
  ///
  /// In id, this message translates to:
  /// **'Level'**
  String get gameLevel;

  /// Judul bilah atas layar Cocokkan
  ///
  /// In id, this message translates to:
  /// **'Cocokkan!'**
  String get cocokkanTitle;

  /// Label kolom tema
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get cocokkanTema;

  /// Tombol gambar baru
  ///
  /// In id, this message translates to:
  /// **'Gambar baru'**
  String get cocokkanShuffle;

  /// Tombol dengar petunjuk
  ///
  /// In id, this message translates to:
  /// **'Dengarkan petunjuk'**
  String get cocokkanHear;

  /// Petunjuk singkat di papan
  ///
  /// In id, this message translates to:
  /// **'Tarik garis atau ketuk dua gambar yang sama'**
  String get cocokkanIns;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Tarik garis dari gambar ke gambar yang sama.'**
  String get cocokkanInst;

  /// Judul tema buah
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Buah yang Sama'**
  String get cocokkanHeadBuah;

  /// Judul tema hewan
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Hewan yang Sama'**
  String get cocokkanHeadHewan;

  /// Judul tema sayur
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Sayur yang Sama'**
  String get cocokkanHeadSayur;

  /// Judul tema kendaraan
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Kendaraan yang Sama'**
  String get cocokkanHeadKendaraan;

  /// Judul tema mainan dan benda
  ///
  /// In id, this message translates to:
  /// **'Cocokkan Mainan & Benda yang Sama'**
  String get cocokkanHeadBenda;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Cocok!'**
  String get cocokkanMatch;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ups, coba lagi ya!'**
  String get cocokkanRetry;

  /// Petunjuk saat pasangan salah
  ///
  /// In id, this message translates to:
  /// **'Pilih satu gambar!'**
  String get cocokkanTipPick;

  /// Petunjuk setelah memilih satu gambar
  ///
  /// In id, this message translates to:
  /// **'Sekarang cari yang sama!'**
  String get cocokkanTipNext;

  /// Seruan saat semua pasangan cocok
  ///
  /// In id, this message translates to:
  /// **'Horee!'**
  String get cocokkanTipDone;

  /// Judul bilah atas layar Kartu Memori
  ///
  /// In id, this message translates to:
  /// **'Kartu Memori'**
  String get memoriTitle;

  /// Tombol ronde baru Kartu Memori
  ///
  /// In id, this message translates to:
  /// **'Main baru'**
  String get memoriRestart;

  /// Label baris tema Kartu Memori
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get memoriTema;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Sepasang!'**
  String get memoriPair;

  /// Label kartu yang belum dibuka
  ///
  /// In id, this message translates to:
  /// **'Kartu tertutup'**
  String get memoriHidden;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Buka dua kartu dan cari pasangannya.'**
  String get memoriInst;

  /// Judul bilah atas layar Tebak Bayangan
  ///
  /// In id, this message translates to:
  /// **'Tebak Bayangan'**
  String get bayanganTitle;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bayangan siapa ini?'**
  String get bayanganAsk;

  /// Label bayangan yang belum terbuka
  ///
  /// In id, this message translates to:
  /// **'Bayangan misteri'**
  String get bayanganShadow;

  /// Label pil kemajuan enam ronde
  ///
  /// In id, this message translates to:
  /// **'Kemajuan'**
  String get bayanganProgress;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul! Itu'**
  String get bayanganYes;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan yang itu, itu'**
  String get bayanganNo;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk gambar yang bayangannya sama.'**
  String get bayanganInst;

  /// Label kelompok pilihan bayangan
  ///
  /// In id, this message translates to:
  /// **'Pilihan bayangan'**
  String get bayanganSemantic;

  /// Judul bilah atas layar Puzzle
  ///
  /// In id, this message translates to:
  /// **'Puzzle'**
  String get puzzleTitle;

  /// Tombol gambar puzzle baru
  ///
  /// In id, this message translates to:
  /// **'Puzzle lain'**
  String get puzzleOther;

  /// Label papan puzzle
  ///
  /// In id, this message translates to:
  /// **'Papan puzzle'**
  String get puzzleBoard;

  /// Petunjuk saat belum ada keping dipilih
  ///
  /// In id, this message translates to:
  /// **'Ketuk potongan, lalu ketuk tempatnya.'**
  String get puzzleHintPick;

  /// Petunjuk setelah keping dipilih
  ///
  /// In id, this message translates to:
  /// **'Sekarang ketuk tempat yang pas di gambar!'**
  String get puzzleHintPlace;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Pas!'**
  String get puzzleFits;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan di situ. Coba tempat lain!'**
  String get puzzleNo;

  /// Label keping puzzle
  ///
  /// In id, this message translates to:
  /// **'Potongan {n}'**
  String puzzlePiece(int n);

  /// Label tempat keping di papan
  ///
  /// In id, this message translates to:
  /// **'Tempat {n}'**
  String puzzleSpot(int n);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hore! Gambarnya'**
  String get puzzleDone;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk potongan, lalu ketuk tempatnya.'**
  String get puzzleInst;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Sekarang ketuk tempat yang pas di gambar!'**
  String get puzzleTipPlace;

  /// Hitungan keping terpasang
  ///
  /// In id, this message translates to:
  /// **'{n} / {m} potongan'**
  String puzzlePieces(int n, int m);

  /// Judul bilah atas layar Balon Huruf
  ///
  /// In id, this message translates to:
  /// **'Balon Huruf'**
  String get balonTitle;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Pecahkan balon huruf'**
  String get balonAsk;

  /// Label pil kemajuan lima ronde
  ///
  /// In id, this message translates to:
  /// **'Kemajuan'**
  String get balonProgress;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Dor! Itu huruf'**
  String get balonYes;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ups, itu huruf'**
  String get balonNo;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Pecahkan balon yang hurufnya sama dengan yang disebut Moci.'**
  String get balonInst;

  /// Label balon berisi satu huruf
  ///
  /// In id, this message translates to:
  /// **'Balon huruf {huruf}'**
  String balonLabel(String huruf);

  /// Judul bilah atas layar Besar & Kecil
  ///
  /// In id, this message translates to:
  /// **'Besar & Kecil'**
  String get besarKecilTitle;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Mana yang paling'**
  String get besarKecilWhich;

  /// Kata tanya paling besar
  ///
  /// In id, this message translates to:
  /// **'BESAR'**
  String get besarKecilBig;

  /// Kata tanya paling kecil
  ///
  /// In id, this message translates to:
  /// **'KECIL'**
  String get besarKecilSmall;

  /// Label pil kemajuan enam ronde
  ///
  /// In id, this message translates to:
  /// **'Kemajuan'**
  String get besarKecilProgress;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul! Itu yang paling'**
  String get besarKecilYes;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Coba lihat lagi!'**
  String get besarKecilNo;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'besar'**
  String get besarKecilBigSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'kecil'**
  String get besarKecilSmallSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Ketuk gambar yang paling besar atau paling kecil.'**
  String get besarKecilInst;

  /// Label gambar dengan nama dan ukurannya
  ///
  /// In id, this message translates to:
  /// **'{nama}, ukuran {n}'**
  String besarKecilLabel(String nama, int n);

  /// Label kelompok di layar Dunia Hewan
  ///
  /// In id, this message translates to:
  /// **'Kelompok hewan'**
  String get hewanGroups;

  /// Kelompok hewan: semua
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get hewanGroupAll;

  /// Kelompok hewan: peliharaan dan ternak
  ///
  /// In id, this message translates to:
  /// **'Peliharaan & Ternak'**
  String get hewanGroupRumah;

  /// Kelompok hewan: hutan dan savana
  ///
  /// In id, this message translates to:
  /// **'Hutan & Savana'**
  String get hewanGroupLiar;

  /// Kelompok hewan: reptil dan katak
  ///
  /// In id, this message translates to:
  /// **'Reptil & Katak'**
  String get hewanGroupReptil;

  /// Kelompok hewan: laut dan air
  ///
  /// In id, this message translates to:
  /// **'Laut & Air'**
  String get hewanGroupAir;

  /// Kelompok hewan: burung dan serangga
  ///
  /// In id, this message translates to:
  /// **'Burung & Serangga'**
  String get hewanGroupKecil;

  /// Judul kartu fakta hewan
  ///
  /// In id, this message translates to:
  /// **'Tahukah kamu?'**
  String get hewanDidYou;

  /// Tombol membacakan nama hewan
  ///
  /// In id, this message translates to:
  /// **'Dengar nama'**
  String get hewanHearName;

  /// Tombol memutar suara hewan
  ///
  /// In id, this message translates to:
  /// **'Dengar suara'**
  String get hewanHearSound;

  /// Label tombol panah sebelumnya
  ///
  /// In id, this message translates to:
  /// **'Hewan sebelumnya'**
  String get hewanPrev;

  /// Label tombol panah berikutnya
  ///
  /// In id, this message translates to:
  /// **'Hewan berikutnya'**
  String get hewanNext;

  /// Tambahan label gambar hewan
  ///
  /// In id, this message translates to:
  /// **', ketuk untuk mendengar suaranya'**
  String get hewanTapHint;

  /// Label semantik hitungan hewan
  ///
  /// In id, this message translates to:
  /// **'Hewan {nomor} dari {total}'**
  String hewanCounterLabel(int nomor, int total);

  /// Tab mode Kenali
  ///
  /// In id, this message translates to:
  /// **'Kenali'**
  String get buahLearn;

  /// Tab mode Tebak
  ///
  /// In id, this message translates to:
  /// **'Tebak'**
  String get buahGuess;

  /// Label kelompok kategori
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get buahCats;

  /// Kategori semua
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get buahCatAll;

  /// Kategori buah
  ///
  /// In id, this message translates to:
  /// **'Buah'**
  String get buahCatFruit;

  /// Kategori sayur
  ///
  /// In id, this message translates to:
  /// **'Sayur'**
  String get buahCatVeggie;

  /// Tag kartu buah
  ///
  /// In id, this message translates to:
  /// **'BUAH'**
  String get buahTagFruit;

  /// Tag kartu sayur
  ///
  /// In id, this message translates to:
  /// **'SAYUR'**
  String get buahTagVeggie;

  /// Label tombol dengar pertanyaan
  ///
  /// In id, this message translates to:
  /// **'Dengarkan pertanyaan'**
  String get buahListen;

  /// Pertanyaan Tebak
  ///
  /// In id, this message translates to:
  /// **'Mana yang {nama}?'**
  String buahQuestion(String nama);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Mana yang'**
  String get buahQuestionSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul!'**
  String get buahYesSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan, coba lagi ya!'**
  String get buahWrongSay;

  /// Teks bilah selesai
  ///
  /// In id, this message translates to:
  /// **'Betul! Itu {nama}!'**
  String buahRight(String nama);

  /// Tombol soal berikutnya
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get buahNext;

  /// Label semantik kemajuan soal
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan {n} dari {total}'**
  String buahProgress(int n, int total);

  /// Label kisi chip warna
  ///
  /// In id, this message translates to:
  /// **'Pilih warna'**
  String get warnaPick;

  /// Tombol mengacak ulang kartu
  ///
  /// In id, this message translates to:
  /// **'Gambar baru'**
  String get warnaNewSet;

  /// Tombol lanjut ke warna berikutnya
  ///
  /// In id, this message translates to:
  /// **'Warna lain'**
  String get warnaNextColor;

  /// Awal kalimat instruksi warna
  ///
  /// In id, this message translates to:
  /// **'Sentuh semua yang'**
  String get warnaInstructionPre;

  /// Teks bilah selesai
  ///
  /// In id, this message translates to:
  /// **'Semua yang {warna} ketemu!'**
  String warnaDone(String warna);

  /// Label semantik hitungan warna
  ///
  /// In id, this message translates to:
  /// **'{found} dari {total} ketemu'**
  String warnaCounterLabel(int found, int total);

  /// Label semantik chip warna
  ///
  /// In id, this message translates to:
  /// **'Warna {nama}'**
  String warnaChipLabel(String nama);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Sentuh semua yang berwarna'**
  String get warnaSentuh;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul!'**
  String get warnaBetul;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan yang ini. Cari yang'**
  String get warnaBukan;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Semua gambarnya sudah ketemu!'**
  String get warnaSemuaKetemu;

  /// Nama bentuk balon
  ///
  /// In id, this message translates to:
  /// **'balon'**
  String get warnaBalon;

  /// Nama bentuk bintang
  ///
  /// In id, this message translates to:
  /// **'bintang'**
  String get warnaBintang;

  /// Nama bentuk hati
  ///
  /// In id, this message translates to:
  /// **'hati'**
  String get warnaHati;

  /// Tab mode Kenali
  ///
  /// In id, this message translates to:
  /// **'Kenali'**
  String get bentukLearn;

  /// Tab mode Cari
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get bentukFind;

  /// Tombol hitung sudut
  ///
  /// In id, this message translates to:
  /// **'Hitung sudut'**
  String get bentukCountCorners;

  /// Tombol hitung ujung bintang
  ///
  /// In id, this message translates to:
  /// **'Hitung ujung'**
  String get bentukCountTips;

  /// Chip jumlah sisi
  ///
  /// In id, this message translates to:
  /// **'{n} sisi'**
  String bentukSisi(int n);

  /// Chip jumlah sudut
  ///
  /// In id, this message translates to:
  /// **'{n} sudut'**
  String bentukSudut(int n);

  /// Chip jumlah ujung bintang
  ///
  /// In id, this message translates to:
  /// **'{n} ujung'**
  String bentukUjung(int n);

  /// Chip bentuk hati
  ///
  /// In id, this message translates to:
  /// **'Lambang sayang'**
  String get bentukSayang;

  /// Chip bentuk bulat
  ///
  /// In id, this message translates to:
  /// **'Tidak punya sudut'**
  String get bentukTanpaSudut;

  /// Label semantik kartu bentuk
  ///
  /// In id, this message translates to:
  /// **'Bentuk {nama}'**
  String bentukShapeLabel(String nama);

  /// Soal mode Cari
  ///
  /// In id, this message translates to:
  /// **'Mana {nama}?'**
  String bentukQuestion(String nama);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Mana'**
  String get bentukQuestionSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Betul! Itu'**
  String get bentukYesSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Bukan, itu'**
  String get bentukNoSay;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Coba lagi!'**
  String get bentukTryAgain;

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat! Semua bentuk ketemu!'**
  String get bentukDone;

  /// Tombol main lagi mode Cari
  ///
  /// In id, this message translates to:
  /// **'Main lagi'**
  String get bentukAgain;

  /// Tombol ambil hadiah mode Cari
  ///
  /// In id, this message translates to:
  /// **'Ambil hadiah'**
  String get bentukPrize;

  /// Label kemajuan enam ronde
  ///
  /// In id, this message translates to:
  /// **'Kemajuan {n} dari {total}'**
  String bentukProgress(int n, int total);

  /// Tombol dengar soal mode Cari
  ///
  /// In id, this message translates to:
  /// **'Dengarkan pertanyaan'**
  String get bentukListen;

  /// Tab mode xilofon
  ///
  /// In id, this message translates to:
  /// **'Xilofon'**
  String get musikXylophone;

  /// Tab mode drum
  ///
  /// In id, this message translates to:
  /// **'Drum'**
  String get musikDrum;

  /// Label semantik pil alat musik
  ///
  /// In id, this message translates to:
  /// **'Alat musik'**
  String get musikModes;

  /// Label bilah lagu
  ///
  /// In id, this message translates to:
  /// **'LAGU'**
  String get musikSongLabel;

  /// Label semantik daftar lagu
  ///
  /// In id, this message translates to:
  /// **'Pilih lagu'**
  String get musikSongsLabel;

  /// Tombol berhenti memainkan lagu atau irama
  ///
  /// In id, this message translates to:
  /// **'Berhenti'**
  String get musikStop;

  /// Tombol ikuti lagu
  ///
  /// In id, this message translates to:
  /// **'Ikuti'**
  String get musikFollow;

  /// Label posisi mengikuti lagu
  ///
  /// In id, this message translates to:
  /// **'Mengikuti · {posisi} / {total}'**
  String musikFollowingCount(int posisi, int total);

  /// narasi
  ///
  /// In id, this message translates to:
  /// **'Hebat! Kamu memainkan satu lagu!'**
  String get musikSongDone;

  /// Tombol mainkan irama drum
  ///
  /// In id, this message translates to:
  /// **'Mainkan irama'**
  String get musikBeat;

  /// Petunjuk mode drum
  ///
  /// In id, this message translates to:
  /// **'Ketuk drumnya! Atau mainkan irama, lalu ikut menepuk bersama Moci.'**
  String get musikDrumHint;

  /// Label semantik batang xilofon
  ///
  /// In id, this message translates to:
  /// **'Nada {sol} {nomor}'**
  String musikNote(String sol, int nomor);

  /// Nama pad drum
  ///
  /// In id, this message translates to:
  /// **'Drum'**
  String get musikPadDrum;

  /// Nama pad tepuk
  ///
  /// In id, this message translates to:
  /// **'Tepuk'**
  String get musikPadClap;

  /// Nama pad simbal
  ///
  /// In id, this message translates to:
  /// **'Simbal'**
  String get musikPadCymbal;

  /// Nama pad kerincing
  ///
  /// In id, this message translates to:
  /// **'Kerincing'**
  String get musikPadShaker;

  /// Judul lagu pertama
  ///
  /// In id, this message translates to:
  /// **'Twinkle Twinkle'**
  String get musikTwinkle;

  /// Judul lagu kedua
  ///
  /// In id, this message translates to:
  /// **'Mary Had a Little Lamb'**
  String get musikMary;
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
