// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Moci';

  @override
  String get commonBack => 'Kembali ke beranda';

  @override
  String get commonListen => 'Dengar';

  @override
  String get langNameId => 'Bahasa Indonesia';

  @override
  String get langNameEn => 'English';

  @override
  String get childFallbackName => 'Adik';

  @override
  String get berandaTag => 'Main & Belajar';

  @override
  String get sambutanTag => 'Main & Belajar';

  @override
  String get sambutanHi => 'Halo! Aku Moci.';

  @override
  String get sambutanSub => 'Teman main dan belajar untuk anak usia 2–7 tahun.';

  @override
  String get sambutanNameLabel => 'Nama anak';

  @override
  String get sambutanNamePh => 'Nama panggilan si kecil';

  @override
  String get sambutanAge => 'Usia anak';

  @override
  String get sambutanYears => 'tahun';

  @override
  String get sambutanNote =>
      'Nama hanya tersimpan di perangkat ini. Bisa diubah di Area Orang Tua.';

  @override
  String get sambutanStart => 'Ayo Mulai!';

  @override
  String get sambutanSkip => 'Lewati intro';

  @override
  String get sambutanHello => 'Hai';

  @override
  String get sambutanFriend => 'teman';

  @override
  String get sambutanSay => 'Halo! Aku Moci. Siapa namamu?';

  @override
  String get sambutanHalo => 'Halo! Aku Moci.';

  @override
  String get sambutanBadge1 => 'Tanpa iklan';

  @override
  String get sambutanBadge2 => 'Tanpa pembelian';

  @override
  String get sambutanBadge3 => 'Bisa offline';

  @override
  String berandaHi(String name) {
    return 'Hai, $name!';
  }

  @override
  String get berandaAsk => 'Mau main apa hari ini?';

  @override
  String get berandaSay => 'Hai! Aku Moci. Mau main apa hari ini?';

  @override
  String get berandaContinue => 'Lanjutkan';

  @override
  String get berandaParents => 'Orang Tua';

  @override
  String get berandaLangLabel => 'Bahasa';

  @override
  String get berandaMociLabel => 'Moci, ketuk untuk menyapa';

  @override
  String berandaStarsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bintang',
      one: '1 bintang',
    );
    return '$_temp0';
  }

  @override
  String get menuHurufTitle => 'Kenal Huruf';

  @override
  String get menuHurufSub => 'A sampai Z';

  @override
  String get menuAngkaTitle => 'Berhitung';

  @override
  String get menuAngkaSub => '1 sampai 50';

  @override
  String get menuHewanTitle => 'Dunia Hewan';

  @override
  String get menuHewanSub => 'Nama & suaranya';

  @override
  String get menuBuahTitle => 'Buah & Sayur';

  @override
  String get menuBuahSub => 'Tebak namanya';

  @override
  String get menuBacaTitle => 'Ayo Membaca';

  @override
  String get menuBacaSub => 'Suku kata & kalimat';

  @override
  String get menuMainTitle => 'Main Yuk!';

  @override
  String get menuMainSub => 'Cocokkan & ingat';

  @override
  String get menuWarnaiTitle => 'Mewarnai';

  @override
  String get menuWarnaiSub => 'Warnai sesukamu';

  @override
  String get menuWarnaTitle => 'Warna';

  @override
  String get menuWarnaSub => 'Cari & sentuh';

  @override
  String get menuBentukTitle => 'Bentuk';

  @override
  String get menuBentukSub => 'Bulat, segitiga, kotak';

  @override
  String get menuMusikTitle => 'Main Musik';

  @override
  String get menuMusikSub => 'Ketuk & dengar';

  @override
  String get gerbangCancel => 'Batal';

  @override
  String get gerbangTitle => 'Khusus Orang Tua';

  @override
  String get gerbangSub =>
      'Jawab soal ini untuk membuka pengaturan dan laporan belajar.';

  @override
  String get gerbangHint => 'Ketuk angka di sebelah kanan.';

  @override
  String get gerbangBad => 'Belum tepat.';

  @override
  String get gerbangRetry => 'Coba soal baru ini, ya.';

  @override
  String get gerbangOk => 'Benar! Silakan masuk.';

  @override
  String get gerbangNewQ => 'Ganti soal';

  @override
  String get gerbangEnter => 'Masuk';

  @override
  String get gerbangKeypad => 'Papan angka';

  @override
  String get gerbangDel => 'Hapus';

  @override
  String get gerbangHelp => 'Panggil Ayah atau Bunda, ya!';

  @override
  String get gerbangHelpSay =>
      'Ini khusus orang tua. Panggil Ayah atau Bunda, ya!';

  @override
  String get gerbangNote =>
      'Gerbang ini menjaga si kecil agar tidak membuka pengaturan atau tautan keluar.';

  @override
  String gerbangTimes(int a, int b) {
    return '$a kali $b';
  }

  @override
  String get istirahatTitle => 'Istirahat sebentar, yuk!';

  @override
  String get istirahatSub =>
      'Mata dan badan juga perlu istirahat. Ikuti Moci sampai hitungannya selesai.';

  @override
  String get istirahatStep1 => 'Lihat jauh ke luar jendela';

  @override
  String get istirahatStep2 => 'Kedip-kedip 10 kali';

  @override
  String get istirahatStep3 => 'Regangkan tangan ke atas';

  @override
  String get istirahatDoneTitle => 'Sudah segar lagi!';

  @override
  String get istirahatSecs => 'detik';

  @override
  String istirahatTimer(int n) {
    return 'Sisa waktu istirahat: $n detik';
  }

  @override
  String get habisTitle => 'Waktu main hari ini sudah habis';

  @override
  String habisSub(String name) {
    return 'Sampai besok, $name! Moci juga mau tidur dulu.';
  }

  @override
  String get habisNote =>
      'Orang tua bisa mengubah batas waktu harian di Area Orang Tua.';

  @override
  String get habisParents => 'Untuk orang tua';
}
