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

  @override
  String get hebatGreat => 'Hebat!';

  @override
  String hebatEarned(int count) {
    return 'Kamu dapat $count bintang!';
  }

  @override
  String hebatStarsLabel(int total, int count) {
    return '$total bintang, bertambah $count';
  }

  @override
  String get hebatNewSticker => 'Stiker baru';

  @override
  String get hebatAgain => 'Main lagi';

  @override
  String get hebatNext => 'Lanjut';

  @override
  String get hebatAlbum => 'Album stiker';

  @override
  String get hebatNewTag => 'BARU';

  @override
  String get hebatYay =>
      'Yeay, kamu berhasil! Kamu dapat tiga bintang dan stiker baru!';

  @override
  String get hebatBubble => 'Yeay, kamu berhasil!';

  @override
  String hebatBubbleName(String name) {
    return 'Yeay, $name berhasil!';
  }

  @override
  String get hebatTapHint => 'ketuk untuk mendengar';

  @override
  String get stiker_kucing => 'Kucing';

  @override
  String get stiker_ikan => 'Ikan';

  @override
  String get stiker_singa => 'Singa';

  @override
  String get stiker_gajah => 'Gajah';

  @override
  String get stiker_panda => 'Panda';

  @override
  String get stiker_pinguin => 'Pinguin';

  @override
  String get stiker_apel => 'Apel';

  @override
  String get stiker_pisang => 'Pisang';

  @override
  String get stiker_stroberi => 'Stroberi';

  @override
  String get stiker_semangka => 'Semangka';

  @override
  String get stiker_nanas => 'Nanas';

  @override
  String get stiker_buahnaga => 'Buah Naga';

  @override
  String get stiker_wortel => 'Wortel';

  @override
  String get stiker_tomat => 'Tomat';

  @override
  String get stiker_brokoli => 'Brokoli';

  @override
  String get stiker_jagung => 'Jagung';

  @override
  String get stiker_labu => 'Labu';

  @override
  String get stiker_jamur => 'Jamur';

  @override
  String get stiker_mobil => 'Mobil';

  @override
  String get stiker_bus => 'Bus';

  @override
  String get stiker_kereta => 'Kereta';

  @override
  String get stiker_pesawat => 'Pesawat';

  @override
  String get stiker_kapal => 'Kapal';

  @override
  String get stiker_roket => 'Roket';

  @override
  String get stiker_bola => 'Bola';

  @override
  String get stiker_balon => 'Balon';

  @override
  String get stiker_kado => 'Kado';

  @override
  String get stiker_eskrim => 'Es Krim';

  @override
  String get stiker_layang => 'Layang-layang';

  @override
  String get stiker_payung => 'Payung';

  @override
  String get orangTuaTitle => 'Area Orang Tua';

  @override
  String get orangTuaBack => 'Kunci dan kembali ke beranda';

  @override
  String get orangTuaLocks => 'Terkunci saat keluar';

  @override
  String get orangTuaProfile => 'Profil anak';

  @override
  String get orangTuaEditName => 'Ubah nama anak';

  @override
  String get orangTuaChildFallback => 'Si kecil';

  @override
  String orangTuaSub(String age, String level) {
    return 'Usia $age tahun · $level';
  }

  @override
  String get orangTuaAgeLevel => 'Level usia';

  @override
  String orangTuaAgeChip(String range) {
    return '$range thn';
  }

  @override
  String get orangTuaLevelPemula => 'Pemula';

  @override
  String get orangTuaLevelPenjelajah => 'Penjelajah';

  @override
  String get orangTuaLevelPembaca => 'Pembaca';

  @override
  String get orangTuaNameHint => 'Nama anak';

  @override
  String get orangTuaSave => 'Simpan';

  @override
  String get orangTuaCancel => 'Batal';

  @override
  String get orangTuaToday => 'Hari ini';

  @override
  String get orangTuaPlayTime => 'Waktu bermain';

  @override
  String get orangTuaMin => 'menit';

  @override
  String get orangTuaStars => 'bintang';

  @override
  String get orangTuaStickers => 'stiker';

  @override
  String get orangTuaArt => 'karya';

  @override
  String get orangTuaNoLimit => 'Tanpa batas harian';

  @override
  String get orangTuaUnlimited => 'Bebas';

  @override
  String orangTuaRingOf(int limit) {
    return 'dari $limit menit hari ini';
  }

  @override
  String orangTuaLeft(int n) {
    return 'Sisa $n menit';
  }

  @override
  String get orangTuaTimeUp => 'Waktu habis';

  @override
  String get orangTuaProgress => 'Perkembangan';

  @override
  String get orangTuaWeek => 'Minggu ini';

  @override
  String orangTuaTip(String modul) {
    return 'Saran: coba $modul bersama minggu ini.';
  }

  @override
  String get orangTuaSettings => 'Pengaturan';

  @override
  String get orangTuaLangLabel => 'Bahasa · Language';

  @override
  String get orangTuaLetters => 'Cara baca huruf';

  @override
  String get orangTuaPhonics => 'Bunyi (fonik)';

  @override
  String get orangTuaNames => 'Nama huruf';

  @override
  String get orangTuaLettersHintPhonics => 'B dibaca “beh”, lalu “Bola!”';

  @override
  String get orangTuaLettersHintNames => 'B dibaca “be”, lalu “Bola!”';

  @override
  String get orangTuaLimit => 'Batas waktu harian';

  @override
  String orangTuaLimitMin(int n) {
    return '$n mnt';
  }

  @override
  String get orangTuaLimitOff => 'Bebas';

  @override
  String get orangTuaMusic => 'Musik latar';

  @override
  String get orangTuaSfx => 'Efek suara';

  @override
  String get orangTuaBreaks => 'Pengingat istirahat';

  @override
  String get orangTuaBadgeAds => 'Tanpa iklan';

  @override
  String get orangTuaBadgePurchases => 'Tanpa pembelian dalam aplikasi';

  @override
  String get orangTuaBadgeOffline => 'Bisa offline';

  @override
  String get orangTuaBadgeData => 'Data hanya di perangkat ini';

  @override
  String get orangTuaDelete => 'Hapus semua data';

  @override
  String get orangTuaDeleteTitle => 'Hapus semua data?';

  @override
  String get orangTuaDeleteBody =>
      'Nama, pengaturan, bintang, stiker, dan karya di perangkat ini akan dihapus. Ini tidak bisa dibatalkan.';

  @override
  String get orangTuaDeleteSure => 'Yakin hapus?';

  @override
  String get orangTuaPrivacy => 'Kebijakan privasi';

  @override
  String get orangTuaSupport => 'Hubungi kami';

  @override
  String get mewarnaiFilter => 'Jenis gambar';

  @override
  String get mewarnaiTabSemua => 'Semua';

  @override
  String get mewarnaiTabHewan => 'Hewan';

  @override
  String get mewarnaiTabBenda => 'Benda & Alam';

  @override
  String get mewarnaiHintPick => 'Pilih gambar yang mau kamu warnai!';

  @override
  String mewarnaiOpenPage(String nama) {
    return 'Warnai gambar: $nama';
  }

  @override
  String get mewarnaiContinue => 'Lanjutkan';

  @override
  String get mewarnaiKaryaku => 'Karyaku';

  @override
  String mewarnaiKaryaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karya',
      one: '1 karya',
      zero: 'Belum ada karya',
    );
    return '$_temp0';
  }

  @override
  String mewarnaiOpenKaryaku(int count) {
    return 'Buka Karyaku, $count karya';
  }

  @override
  String get mewarnaiBackGaleri => 'Kembali ke galeri';

  @override
  String get mewarnaiChangePage => 'Gambar';

  @override
  String get mewarnaiUndo => 'Batal';

  @override
  String get mewarnaiClear => 'Mulai lagi';

  @override
  String get mewarnaiSave => 'Simpan';

  @override
  String get mewarnaiTools => 'Alat';

  @override
  String get mewarnaiToolBrush => 'Kuas';

  @override
  String get mewarnaiToolFill => 'Isi';

  @override
  String get mewarnaiToolErase => 'Hapus';

  @override
  String get mewarnaiToolCap => 'Stiker';

  @override
  String get mewarnaiBrushSize => 'Ukuran kuas';

  @override
  String get mewarnaiBrushSmall => 'Kuas kecil';

  @override
  String get mewarnaiBrushMedium => 'Kuas sedang';

  @override
  String get mewarnaiBrushBig => 'Kuas besar';

  @override
  String get mewarnaiCrayons => 'Krayon';

  @override
  String get mewarnaiCaps => 'Stiker';

  @override
  String get mewarnaiHintBrush =>
      'Warnai di dalam bagian gambar. Krayonnya tidak akan keluar garis!';

  @override
  String get mewarnaiHintFill =>
      'Ketuk satu bagian untuk mengisinya dengan warna.';

  @override
  String get mewarnaiHintErase => 'Gosok untuk menghapus warna.';

  @override
  String get mewarnaiHintCap => 'Ketuk gambar untuk menempel stiker.';

  @override
  String mewarnaiCanvasLabel(String nama) {
    return 'Gambar untuk diwarnai: $nama';
  }

  @override
  String get mewarnaiSayClear => 'Ayo mulai dari awal!';
}
