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
  String get hurufTitle => 'Huruf';

  @override
  String get hurufLearn => 'Kenali';

  @override
  String get hurufWrite => 'Tulis';

  @override
  String get hurufSay => 'Ucapkan';

  @override
  String get modeSemantic => 'Mode belajar';

  @override
  String get tulisFollow => 'Geser Moci ikuti panah kuning sampai ke bintang!';

  @override
  String get tulisWriteVerb => 'Tulis';

  @override
  String get tulisLine => 'Garis';

  @override
  String get tulisOf => 'dari';

  @override
  String get tulisDone => 'Selesai!';

  @override
  String get tulisGreat => 'Hebat!';

  @override
  String get tulisNext => 'Lanjut';

  @override
  String get tulisCrayons => 'Krayon';

  @override
  String get tulisAgain => 'Ulangi';

  @override
  String get tulisListen => 'Dengar';

  @override
  String get tulisArea => 'Area menulis';

  @override
  String get tulisWriteAgain => 'Tulis lagi';

  @override
  String get tulisColor1 => 'Krayon merah muda';

  @override
  String get tulisColor2 => 'Krayon biru';

  @override
  String get tulisColor3 => 'Krayon hijau';

  @override
  String get tulisColor4 => 'Krayon oranye';

  @override
  String get tulisColor5 => 'Krayon ungu';

  @override
  String get tulisPickHuruf => 'Pilih huruf';

  @override
  String get tulisUnitHuruf => 'huruf';

  @override
  String tulisKeyLabel(String huruf) {
    return 'Tulis huruf $huruf';
  }

  @override
  String tulisAreaLabel(String huruf) {
    return 'Area menulis huruf $huruf';
  }

  @override
  String tulisProgress(int n, int total) {
    return '$n dari $total';
  }

  @override
  String get tulisSayStartHuruf => 'Ayo tulis huruf';

  @override
  String get tulisSayDoneHuruf => 'Hebat! Kamu bisa menulis huruf';

  @override
  String get tulisNice => 'Bagus!';

  @override
  String get tulisHint => 'Geser Moci ikuti panah kuning sampai ke bintang.';

  @override
  String berandaContinueTulisHuruf(String huruf) {
    return 'Tulis huruf $huruf';
  }

  @override
  String get tulisPickAngka => 'Pilih angka';

  @override
  String tulisKeyLabelAngka(String angka) {
    return 'Tulis angka $angka';
  }

  @override
  String tulisAreaLabelAngka(String angka) {
    return 'Area menulis angka $angka';
  }

  @override
  String get tulisSayStartAngka => 'Ayo tulis angka';

  @override
  String get tulisSayDoneAngka => 'Hebat! Kamu bisa menulis angka';

  @override
  String get angkaTitle => 'Angka';

  @override
  String get angkaCount => 'Berhitung';

  @override
  String get tulisUnitAngka => 'angka';

  @override
  String berandaContinueTulisAngka(String angka) {
    return 'Tulis angka $angka';
  }

  @override
  String get hurufListen => 'Dengarkan bunyi huruf dan kata';

  @override
  String get hurufPrev => 'Huruf sebelumnya';

  @override
  String get hurufNext => 'Huruf berikutnya';

  @override
  String get hurufLetter => 'Huruf';

  @override
  String get hurufTapHint => 'ketuk untuk mendengar bunyinya';

  @override
  String get hurufTapHintName => 'ketuk untuk mendengar namanya';

  @override
  String get hurufSound => 'Bunyi';

  @override
  String get hurufName => 'Nama:';

  @override
  String get hurufSoundOf => 'Bunyi huruf';

  @override
  String get hurufNameOf => 'Nama huruf';

  @override
  String hurufLetterLabel(String huruf, String petunjuk) {
    return 'Huruf $huruf, $petunjuk';
  }

  @override
  String hurufSoundAria(String huruf, String bunyi) {
    return 'Bunyi huruf $huruf $bunyi';
  }

  @override
  String hurufNameAria(String huruf) {
    return 'Nama huruf $huruf';
  }

  @override
  String get hurufGridLabel => 'Pilih huruf';

  @override
  String berandaContinueHuruf(String huruf) {
    return 'Huruf $huruf';
  }

  @override
  String get angkaListen => 'Dengar angkanya';

  @override
  String get angkaAuto => 'Hitung bareng';

  @override
  String get angkaRange => 'Rentang angka';

  @override
  String get angkaPick => 'Pilih angka';

  @override
  String angkaNumber(int n) {
    return 'Angka $n';
  }

  @override
  String angkaCountPrompt(String benda) {
    return 'Ayo hitung $benda!';
  }

  @override
  String get angkaTapIt => 'Ketuk untuk menghitung';

  @override
  String angkaDone(String kata, String benda) {
    return 'Ada $kata $benda!';
  }

  @override
  String get angkaDoneSay => 'Hebat, hitungannya benar!';

  @override
  String berandaContinueAngka(String angka) {
    return 'Angka $angka';
  }

  @override
  String get ucapkanHear => 'Dengar contoh';

  @override
  String get ucapkanYourTurn => 'Sekarang giliranmu! Bilang:';

  @override
  String get ucapkanIdle => 'Ketuk mic, lalu ucapkan';

  @override
  String get ucapkanListen => 'Moci mendengarkan…';

  @override
  String get ucapkanGood => 'Bagus sekali!';

  @override
  String get ucapkanAgain => 'Ulangi';

  @override
  String get ucapkanNextWord => 'Kata berikutnya';

  @override
  String get ucapkanSyl => 'Suku kata';

  @override
  String get ucapkanMicIdle => 'Ketuk lalu ucapkan';

  @override
  String get ucapkanMicListen => 'Moci sedang mendengarkan';

  @override
  String get ucapkanLetsSay => 'Ayo bilang';

  @override
  String get ucapkanTryAgain => 'Ayo coba lagi!';

  @override
  String get ucapkanDoneSay => 'Hebat! Kamu bisa bilang';

  @override
  String get ucapkanMicAskTitle => 'Panggil Ayah atau Bunda';

  @override
  String get ucapkanMicAskBody =>
      'Mikrofon hanya dinyalakan oleh orang tua. Suara Adik dikenali di perangkat ini saja, tidak disimpan dan tidak dikirim.';

  @override
  String get ucapkanMicAskAction => 'Buka Gerbang';

  @override
  String get ucapkanMicDenied =>
      'Tanpa mikrofon, kita dengar dan tiru saja, ya!';

  @override
  String get ucapkanMicUnavailable =>
      'Moci belum bisa mendengar di perangkat ini. Dengar dan tiru saja, ya!';

  @override
  String get ucapkanPractice => 'Dengar dan tiru';

  @override
  String ucapkanMicLabel(String kata) {
    return 'Ketuk lalu ucapkan $kata';
  }

  @override
  String ucapkanWordLabel(String kata) {
    return '$kata, ketuk untuk mendengar';
  }

  @override
  String berandaContinueUcapkan(String kata) {
    return 'Ucapkan $kata';
  }

  @override
  String get membacaTitle => 'Ayo Membaca';

  @override
  String get membacaModes => 'Mode membaca';

  @override
  String get membacaSukuKata => 'Suku Kata';

  @override
  String get membacaSusunKata => 'Susun Kata';

  @override
  String get membacaKalimat => 'Kalimat';

  @override
  String get sukuKataPilih => 'Pilih huruf';

  @override
  String get sukuKataTip => 'Ketuk suku kata untuk mendengarnya!';

  @override
  String get sukuKataHear => 'Dengar kata';

  @override
  String get sukuKataReadAll => 'Baca semua';

  @override
  String get sukuKataExample => 'Contoh kata';

  @override
  String get sukuKataSayIt => 'Ayo ucapkan!';

  @override
  String sukuKataLetter(String huruf) {
    return 'Huruf $huruf';
  }

  @override
  String sukuKataSyllable(String suku) {
    return 'Suku kata $suku';
  }

  @override
  String get susunKataLevel => 'Level';

  @override
  String get susunKataLevel2 => '2 suku kata';

  @override
  String get susunKataLevel3 => '3 suku kata';

  @override
  String get susunKataHear => 'Dengar katanya';

  @override
  String get susunKataIns => 'Ketuk suku kata secara berurutan';

  @override
  String get susunKataNext => 'Lanjut';

  @override
  String get susunKataHintStart => 'Dengarkan, lalu ketuk suku kata pertama!';

  @override
  String get susunKataHintMore => 'Bagus! Sekarang suku kata berikutnya.';

  @override
  String get susunKataTryAgain => 'Ups, belum tepat. Coba lagi!';

  @override
  String susunKataSlot(int nomor) {
    return 'Kotak $nomor';
  }

  @override
  String get susunKataEmpty => 'kosong';

  @override
  String get susunKataYes => 'Betul!';

  @override
  String susunKataTile(String suku) {
    return 'Suku kata $suku';
  }

  @override
  String get susunKataProgress => 'Kemajuan';

  @override
  String get kalimatIns => 'Ketuk kata untuk mendengarnya';

  @override
  String get kalimatRead => 'Baca bersama';

  @override
  String get kalimatPrev => 'Kalimat sebelumnya';

  @override
  String get kalimatNext => 'Kalimat berikutnya';

  @override
  String get kalimatWhich => 'Gambar mana yang cocok?';

  @override
  String get kalimatReadMode => 'Baca';

  @override
  String get kalimatQuizMode => 'Tebak gambar';

  @override
  String get kalimatReadTip =>
      'Ketuk \"Baca bersama\" lalu ikuti kata yang menyala!';

  @override
  String get kalimatYes => 'Betul! Pintar sekali!';

  @override
  String get kalimatNo => 'Bukan yang itu. Coba lagi!';

  @override
  String get kalimatPicture => 'Gambar kalimat';

  @override
  String get mewarnaiFilter => 'Jenis gambar';

  @override
  String get mewarnaiTabSemua => 'Semua';

  @override
  String get mewarnaiTabHewan => 'Hewan';

  @override
  String get mewarnaiTabLaut => 'Laut';

  @override
  String get mewarnaiTabBuah => 'Buah & Sayur';

  @override
  String get mewarnaiTabKota => 'Kota';

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

  @override
  String get mewarnaiSaved => 'Tersimpan di Karyaku!';

  @override
  String get mewarnaiSaySaved => 'Tersimpan! Bagus sekali!';

  @override
  String get mewarnaiPickPage => 'Pilih gambar';

  @override
  String get mewarnaiClose => 'Tutup';

  @override
  String get mewarnaiKaryakuHint =>
      'Ketuk gambar untuk melihatnya lebih besar.';

  @override
  String get mewarnaiKaryakuEmpty => 'Belum ada karya';

  @override
  String get mewarnaiKaryakuEmptyHint =>
      'Yuk mewarnai dulu! Tekan Simpan, nanti gambarmu muncul di sini.';

  @override
  String get mewarnaiColorAgain => 'Warnai lagi';

  @override
  String get mewarnaiDelete => 'Hapus';

  @override
  String get mewarnaiDeleteConfirm => 'Yakin hapus?';

  @override
  String mewarnaiViewArt(String nama) {
    return 'Lihat karya: $nama';
  }

  @override
  String get mainYukSub => 'Pilih permainan';

  @override
  String get mainYukAge2 => 'Usia 2+';

  @override
  String get mainYukAge3 => 'Usia 3+';

  @override
  String get mainYukAge4 => 'Usia 4+';

  @override
  String get mainYukCocokkanHub => 'Cocokkan Gambar';

  @override
  String get mainYukMemoriHub => 'Kartu Memori';

  @override
  String get mainYukBayanganHub => 'Tebak Bayangan';

  @override
  String get mainYukPuzzleHub => 'Puzzle';

  @override
  String get mainYukBalonHub => 'Balon Huruf';

  @override
  String get mainYukBesarKecilHub => 'Besar & Kecil';

  @override
  String get mainYukTemaAcak => 'Acak!';

  @override
  String get mainYukTemaBuah => 'Buah';

  @override
  String get mainYukTemaHewan => 'Hewan';

  @override
  String get mainYukTemaSayur => 'Sayur';

  @override
  String get mainYukTemaKendaraan => 'Kendaraan';

  @override
  String get mainYukTemaBenda => 'Mainan & Benda';

  @override
  String mainYukPairs(int n) {
    return '$n pasang';
  }

  @override
  String mainYukMoves(int n) {
    return 'Langkah: $n';
  }

  @override
  String get gameLevel => 'Level';

  @override
  String get cocokkanTitle => 'Cocokkan!';

  @override
  String get cocokkanTema => 'Tema';

  @override
  String get cocokkanShuffle => 'Gambar baru';

  @override
  String get cocokkanHear => 'Dengarkan petunjuk';

  @override
  String get cocokkanIns => 'Tarik garis atau ketuk dua gambar yang sama';

  @override
  String get cocokkanInst => 'Tarik garis dari gambar ke gambar yang sama.';

  @override
  String get cocokkanHeadBuah => 'Cocokkan Buah yang Sama';

  @override
  String get cocokkanHeadHewan => 'Cocokkan Hewan yang Sama';

  @override
  String get cocokkanHeadSayur => 'Cocokkan Sayur yang Sama';

  @override
  String get cocokkanHeadKendaraan => 'Cocokkan Kendaraan yang Sama';

  @override
  String get cocokkanHeadBenda => 'Cocokkan Mainan & Benda yang Sama';

  @override
  String get cocokkanMatch => 'Cocok!';

  @override
  String get cocokkanRetry => 'Ups, coba lagi ya!';

  @override
  String get cocokkanTipPick => 'Pilih satu gambar!';

  @override
  String get cocokkanTipNext => 'Sekarang cari yang sama!';

  @override
  String get cocokkanTipDone => 'Horee!';

  @override
  String get memoriTitle => 'Kartu Memori';

  @override
  String get memoriRestart => 'Main baru';

  @override
  String get memoriTema => 'Tema';

  @override
  String get memoriPair => 'Sepasang!';

  @override
  String get memoriHidden => 'Kartu tertutup';

  @override
  String get memoriInst => 'Buka dua kartu dan cari pasangannya.';

  @override
  String get bayanganTitle => 'Tebak Bayangan';

  @override
  String get bayanganAsk => 'Bayangan siapa ini?';

  @override
  String get bayanganShadow => 'Bayangan misteri';

  @override
  String get bayanganProgress => 'Kemajuan';

  @override
  String get bayanganYes => 'Betul! Itu';

  @override
  String get bayanganNo => 'Bukan yang itu, itu';

  @override
  String get bayanganInst => 'Ketuk gambar yang bayangannya sama.';

  @override
  String get bayanganSemantic => 'Pilihan bayangan';

  @override
  String get puzzleTitle => 'Puzzle';

  @override
  String get puzzleOther => 'Puzzle lain';

  @override
  String get puzzleBoard => 'Papan puzzle';

  @override
  String get puzzleHintPick => 'Ketuk potongan, lalu ketuk tempatnya.';

  @override
  String get puzzleHintPlace => 'Sekarang ketuk tempat yang pas di gambar!';

  @override
  String get puzzleFits => 'Pas!';

  @override
  String get puzzleNo => 'Bukan di situ. Coba tempat lain!';

  @override
  String puzzlePiece(int n) {
    return 'Potongan $n';
  }

  @override
  String puzzleSpot(int n) {
    return 'Tempat $n';
  }

  @override
  String get puzzleDone => 'Hore! Gambarnya';

  @override
  String get puzzleInst => 'Ketuk potongan, lalu ketuk tempatnya.';

  @override
  String get puzzleTipPlace => 'Sekarang ketuk tempat yang pas di gambar!';

  @override
  String puzzlePieces(int n, int m) {
    return '$n / $m potongan';
  }

  @override
  String get balonTitle => 'Balon Huruf';

  @override
  String get balonAsk => 'Pecahkan balon huruf';

  @override
  String get balonProgress => 'Kemajuan';

  @override
  String get balonYes => 'Dor! Itu huruf';

  @override
  String get balonNo => 'Ups, itu huruf';

  @override
  String get balonInst =>
      'Pecahkan balon yang hurufnya sama dengan yang disebut Moci.';

  @override
  String balonLabel(String huruf) {
    return 'Balon huruf $huruf';
  }

  @override
  String get besarKecilTitle => 'Besar & Kecil';

  @override
  String get besarKecilWhich => 'Mana yang paling';

  @override
  String get besarKecilBig => 'BESAR';

  @override
  String get besarKecilSmall => 'KECIL';

  @override
  String get besarKecilProgress => 'Kemajuan';

  @override
  String get besarKecilYes => 'Betul! Itu yang paling';

  @override
  String get besarKecilNo => 'Coba lihat lagi!';

  @override
  String get besarKecilBigSay => 'besar';

  @override
  String get besarKecilSmallSay => 'kecil';

  @override
  String get besarKecilInst =>
      'Ketuk gambar yang paling besar atau paling kecil.';

  @override
  String besarKecilLabel(String nama, int n) {
    return '$nama, ukuran $n';
  }

  @override
  String get hewanGroups => 'Kelompok hewan';

  @override
  String get hewanGroupAll => 'Semua';

  @override
  String get hewanGroupRumah => 'Peliharaan & Ternak';

  @override
  String get hewanGroupLiar => 'Hutan & Savana';

  @override
  String get hewanGroupReptil => 'Reptil & Katak';

  @override
  String get hewanGroupAir => 'Laut & Air';

  @override
  String get hewanGroupKecil => 'Burung & Serangga';

  @override
  String get hewanDidYou => 'Tahukah kamu?';

  @override
  String get hewanHearName => 'Dengar nama';

  @override
  String get hewanHearSound => 'Dengar suara';

  @override
  String get hewanPrev => 'Hewan sebelumnya';

  @override
  String get hewanNext => 'Hewan berikutnya';

  @override
  String get hewanTapHint => ', ketuk untuk mendengar suaranya';

  @override
  String hewanCounterLabel(int nomor, int total) {
    return 'Hewan $nomor dari $total';
  }

  @override
  String get buahLearn => 'Kenali';

  @override
  String get buahGuess => 'Tebak';

  @override
  String get buahCats => 'Kategori';

  @override
  String get buahCatAll => 'Semua';

  @override
  String get buahCatFruit => 'Buah';

  @override
  String get buahCatVeggie => 'Sayur';

  @override
  String get buahTagFruit => 'BUAH';

  @override
  String get buahTagVeggie => 'SAYUR';

  @override
  String get buahListen => 'Dengarkan pertanyaan';

  @override
  String buahQuestion(String nama) {
    return 'Mana yang $nama?';
  }

  @override
  String get buahQuestionSay => 'Mana yang';

  @override
  String get buahYesSay => 'Betul!';

  @override
  String get buahWrongSay => 'Bukan, coba lagi ya!';

  @override
  String buahRight(String nama) {
    return 'Betul! Itu $nama!';
  }

  @override
  String get buahNext => 'Lanjut';

  @override
  String buahProgress(int n, int total) {
    return 'Pertanyaan $n dari $total';
  }

  @override
  String get warnaPick => 'Pilih warna';

  @override
  String get warnaNewSet => 'Gambar baru';

  @override
  String get warnaNextColor => 'Warna lain';

  @override
  String get warnaInstructionPre => 'Sentuh semua yang';

  @override
  String warnaDone(String warna) {
    return 'Semua yang $warna ketemu!';
  }

  @override
  String warnaCounterLabel(int found, int total) {
    return '$found dari $total ketemu';
  }

  @override
  String warnaChipLabel(String nama) {
    return 'Warna $nama';
  }

  @override
  String get warnaSentuh => 'Sentuh semua yang berwarna';

  @override
  String get warnaBetul => 'Betul!';

  @override
  String get warnaBukan => 'Bukan yang ini. Cari yang';

  @override
  String get warnaSemuaKetemu => 'Semua gambarnya sudah ketemu!';

  @override
  String get warnaBalon => 'balon';

  @override
  String get warnaBintang => 'bintang';

  @override
  String get warnaHati => 'hati';

  @override
  String get bentukLearn => 'Kenali';

  @override
  String get bentukFind => 'Cari';

  @override
  String get bentukCountCorners => 'Hitung sudut';

  @override
  String get bentukCountTips => 'Hitung ujung';

  @override
  String bentukSisi(int n) {
    return '$n sisi';
  }

  @override
  String bentukSudut(int n) {
    return '$n sudut';
  }

  @override
  String bentukUjung(int n) {
    return '$n ujung';
  }

  @override
  String get bentukSayang => 'Lambang sayang';

  @override
  String get bentukTanpaSudut => 'Tidak punya sudut';

  @override
  String bentukShapeLabel(String nama) {
    return 'Bentuk $nama';
  }

  @override
  String bentukQuestion(String nama) {
    return 'Mana $nama?';
  }

  @override
  String get bentukQuestionSay => 'Mana';

  @override
  String get bentukYesSay => 'Betul! Itu';

  @override
  String get bentukNoSay => 'Bukan, itu';

  @override
  String get bentukTryAgain => 'Coba lagi!';

  @override
  String get bentukDone => 'Hebat! Semua bentuk ketemu!';

  @override
  String get bentukAgain => 'Main lagi';

  @override
  String get bentukPrize => 'Ambil hadiah';

  @override
  String bentukProgress(int n, int total) {
    return 'Kemajuan $n dari $total';
  }

  @override
  String get bentukListen => 'Dengarkan pertanyaan';

  @override
  String get musikXylophone => 'Xilofon';

  @override
  String get musikDrum => 'Drum';

  @override
  String get musikModes => 'Alat musik';

  @override
  String get musikSongLabel => 'LAGU';

  @override
  String get musikSongsLabel => 'Pilih lagu';

  @override
  String get musikStop => 'Berhenti';

  @override
  String get musikFollow => 'Ikuti';

  @override
  String musikFollowingCount(int posisi, int total) {
    return 'Mengikuti · $posisi / $total';
  }

  @override
  String get musikSongDone => 'Hebat! Kamu memainkan satu lagu!';

  @override
  String get musikBeat => 'Mainkan irama';

  @override
  String get musikDrumHint =>
      'Ketuk drumnya! Atau mainkan irama, lalu ikut menepuk bersama Moci.';

  @override
  String musikNote(String sol, int nomor) {
    return 'Nada $sol $nomor';
  }

  @override
  String get musikPadDrum => 'Drum';

  @override
  String get musikPadClap => 'Tepuk';

  @override
  String get musikPadCymbal => 'Simbal';

  @override
  String get musikPadShaker => 'Kerincing';

  @override
  String get musikTwinkle => 'Twinkle Twinkle';

  @override
  String get musikMary => 'Mary Had a Little Lamb';
}
