// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Moci';

  @override
  String get commonBack => 'Back to home';

  @override
  String get commonListen => 'Listen';

  @override
  String get langNameId => 'Bahasa Indonesia';

  @override
  String get langNameEn => 'English';

  @override
  String get childFallbackName => 'little one';

  @override
  String get berandaTag => 'Play & Learn';

  @override
  String get sambutanTag => 'Play & Learn';

  @override
  String get sambutanHi => 'Hi! I\'m Moci.';

  @override
  String get sambutanSub => 'A play-and-learn buddy for kids aged 2–7.';

  @override
  String get sambutanNameLabel => 'Child\'s name';

  @override
  String get sambutanNamePh => 'Your little one\'s nickname';

  @override
  String get sambutanAge => 'Child\'s age';

  @override
  String get sambutanYears => 'years';

  @override
  String get sambutanNote =>
      'Saved only on this device. You can change it in Parents\' Corner.';

  @override
  String get sambutanStart => 'Let\'s Go!';

  @override
  String get sambutanSkip => 'Skip intro';

  @override
  String get sambutanHello => 'Hi';

  @override
  String get sambutanFriend => 'friend';

  @override
  String get sambutanSay => 'Hi! I\'m Moci. What\'s your name?';

  @override
  String get sambutanHalo => 'Hi! I\'m Moci.';

  @override
  String get sambutanBadge1 => 'No ads';

  @override
  String get sambutanBadge2 => 'No in-app purchases';

  @override
  String get sambutanBadge3 => 'Works offline';

  @override
  String berandaHi(String name) {
    return 'Hi, $name!';
  }

  @override
  String get berandaAsk => 'What shall we play today?';

  @override
  String get berandaSay => 'Hi! I\'m Moci. What shall we play today?';

  @override
  String get berandaContinue => 'Continue';

  @override
  String get berandaParents => 'Parents';

  @override
  String get berandaLangLabel => 'Language';

  @override
  String get berandaMociLabel => 'Moci, tap to say hi';

  @override
  String berandaStarsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get menuHurufTitle => 'Letters';

  @override
  String get menuHurufSub => 'A to Z';

  @override
  String get menuAngkaTitle => 'Numbers';

  @override
  String get menuAngkaSub => '1 to 50';

  @override
  String get menuHewanTitle => 'Animals';

  @override
  String get menuHewanSub => 'Names & sounds';

  @override
  String get menuBuahTitle => 'Fruits & Veggies';

  @override
  String get menuBuahSub => 'Guess the name';

  @override
  String get menuBacaTitle => 'Let\'s Read';

  @override
  String get menuBacaSub => 'Syllables & sentences';

  @override
  String get menuMainTitle => 'Let\'s Play!';

  @override
  String get menuMainSub => 'Match & remember';

  @override
  String get menuWarnaiTitle => 'Coloring';

  @override
  String get menuWarnaiSub => 'Color your way';

  @override
  String get menuWarnaTitle => 'Colors';

  @override
  String get menuWarnaSub => 'Find & tap';

  @override
  String get menuBentukTitle => 'Shapes';

  @override
  String get menuBentukSub => 'Circle, triangle, square';

  @override
  String get menuMusikTitle => 'Music Time';

  @override
  String get menuMusikSub => 'Tap & listen';

  @override
  String get gerbangCancel => 'Cancel';

  @override
  String get gerbangTitle => 'For Grown-ups';

  @override
  String get gerbangSub => 'Answer this to open settings and learning reports.';

  @override
  String get gerbangHint => 'Tap the numbers on the right.';

  @override
  String get gerbangBad => 'Not quite.';

  @override
  String get gerbangRetry => 'Try this new one.';

  @override
  String get gerbangOk => 'Correct! Come on in.';

  @override
  String get gerbangNewQ => 'New question';

  @override
  String get gerbangEnter => 'Enter';

  @override
  String get gerbangKeypad => 'Number pad';

  @override
  String get gerbangDel => 'Delete';

  @override
  String get gerbangHelp => 'Ask a grown-up for help!';

  @override
  String get gerbangHelpSay =>
      'This part is for grown-ups. Ask a grown-up for help!';

  @override
  String get gerbangNote =>
      'This gate keeps little ones out of settings and outside links.';

  @override
  String gerbangTimes(int a, int b) {
    return '$a times $b';
  }

  @override
  String get istirahatTitle => 'Time for a little break!';

  @override
  String get istirahatSub =>
      'Your eyes and body need a rest too. Follow Moci until the countdown ends.';

  @override
  String get istirahatStep1 => 'Look far out the window';

  @override
  String get istirahatStep2 => 'Blink 10 times';

  @override
  String get istirahatStep3 => 'Stretch your arms up high';

  @override
  String get istirahatDoneTitle => 'All fresh again!';

  @override
  String get istirahatSecs => 'seconds';

  @override
  String istirahatTimer(int n) {
    return 'Break time left: $n seconds';
  }

  @override
  String get habisTitle => 'Playtime is over for today';

  @override
  String habisSub(String name) {
    return 'See you tomorrow, $name! Moci is going to sleep too.';
  }

  @override
  String get habisNote =>
      'A grown-up can change the daily time limit in Parents’ Corner.';

  @override
  String get habisParents => 'For grown-ups';

  @override
  String get hebatGreat => 'Great job!';

  @override
  String hebatEarned(int count) {
    return 'You earned $count stars!';
  }

  @override
  String hebatStarsLabel(int total, int count) {
    return '$total stars, $count new';
  }

  @override
  String get hebatNewSticker => 'New sticker';

  @override
  String get hebatAgain => 'Play more';

  @override
  String get hebatNext => 'Continue';

  @override
  String get hebatAlbum => 'Sticker book';

  @override
  String get hebatNewTag => 'NEW';

  @override
  String get hebatYay =>
      'Yay, you did it! You got three stars and a new sticker!';

  @override
  String get hebatBubble => 'Yay, you did it!';

  @override
  String hebatBubbleName(String name) {
    return 'Yay, $name did it!';
  }

  @override
  String get hebatTapHint => 'tap to listen';

  @override
  String get stiker_kucing => 'Cat';

  @override
  String get stiker_ikan => 'Fish';

  @override
  String get stiker_singa => 'Lion';

  @override
  String get stiker_gajah => 'Elephant';

  @override
  String get stiker_panda => 'Panda';

  @override
  String get stiker_pinguin => 'Penguin';

  @override
  String get stiker_apel => 'Apple';

  @override
  String get stiker_pisang => 'Banana';

  @override
  String get stiker_stroberi => 'Strawberry';

  @override
  String get stiker_semangka => 'Watermelon';

  @override
  String get stiker_nanas => 'Pineapple';

  @override
  String get stiker_buahnaga => 'Dragon Fruit';

  @override
  String get stiker_wortel => 'Carrot';

  @override
  String get stiker_tomat => 'Tomato';

  @override
  String get stiker_brokoli => 'Broccoli';

  @override
  String get stiker_jagung => 'Corn';

  @override
  String get stiker_labu => 'Pumpkin';

  @override
  String get stiker_jamur => 'Mushroom';

  @override
  String get stiker_mobil => 'Car';

  @override
  String get stiker_bus => 'Bus';

  @override
  String get stiker_kereta => 'Train';

  @override
  String get stiker_pesawat => 'Airplane';

  @override
  String get stiker_kapal => 'Ship';

  @override
  String get stiker_roket => 'Rocket';

  @override
  String get stiker_bola => 'Ball';

  @override
  String get stiker_balon => 'Balloons';

  @override
  String get stiker_kado => 'Gift';

  @override
  String get stiker_eskrim => 'Ice Cream';

  @override
  String get stiker_layang => 'Kite';

  @override
  String get stiker_payung => 'Umbrella';

  @override
  String get orangTuaTitle => 'Parents\' Corner';

  @override
  String get orangTuaBack => 'Lock and go back home';

  @override
  String get orangTuaLocks => 'Locks when you leave';

  @override
  String get orangTuaProfile => 'Child profile';

  @override
  String get orangTuaEditName => 'Change child\'s name';

  @override
  String get orangTuaChildFallback => 'Your child';

  @override
  String orangTuaSub(String age, String level) {
    return 'Age $age · $level';
  }

  @override
  String get orangTuaAgeLevel => 'Age level';

  @override
  String orangTuaAgeChip(String range) {
    return '$range yrs';
  }

  @override
  String get orangTuaLevelPemula => 'Starter';

  @override
  String get orangTuaLevelPenjelajah => 'Explorer';

  @override
  String get orangTuaLevelPembaca => 'Reader';

  @override
  String get orangTuaNameHint => 'Child\'s name';

  @override
  String get orangTuaSave => 'Save';

  @override
  String get orangTuaCancel => 'Cancel';

  @override
  String get orangTuaToday => 'Today';

  @override
  String get orangTuaPlayTime => 'Play time';

  @override
  String get orangTuaMin => 'min';

  @override
  String get orangTuaStars => 'stars';

  @override
  String get orangTuaStickers => 'sticker';

  @override
  String get orangTuaArt => 'artwork';

  @override
  String get orangTuaNoLimit => 'No daily limit set';

  @override
  String get orangTuaUnlimited => 'Unlimited';

  @override
  String orangTuaRingOf(int limit) {
    return 'of $limit min today';
  }

  @override
  String orangTuaLeft(int n) {
    return '$n min left';
  }

  @override
  String get orangTuaTimeUp => 'Time\'s up';

  @override
  String get orangTuaProgress => 'Progress';

  @override
  String get orangTuaWeek => 'This week';

  @override
  String orangTuaTip(String modul) {
    return 'Tip: try $modul together this week.';
  }

  @override
  String get orangTuaSettings => 'Settings';

  @override
  String get orangTuaLangLabel => 'Bahasa · Language';

  @override
  String get orangTuaLetters => 'How letters are read';

  @override
  String get orangTuaPhonics => 'Phonics';

  @override
  String get orangTuaNames => 'Letter names';

  @override
  String get orangTuaLettersHintPhonics => 'B says “buh”, then “Ball!”';

  @override
  String get orangTuaLettersHintNames => 'B is read “bee”, then “Ball!”';

  @override
  String get orangTuaLimit => 'Daily time limit';

  @override
  String orangTuaLimitMin(int n) {
    return '$n min';
  }

  @override
  String get orangTuaLimitOff => 'Off';

  @override
  String get orangTuaMusic => 'Background music';

  @override
  String get orangTuaSfx => 'Sound effects';

  @override
  String get orangTuaBreaks => 'Break reminders';

  @override
  String get orangTuaBadgeAds => 'No ads';

  @override
  String get orangTuaBadgePurchases => 'No in-app purchases';

  @override
  String get orangTuaBadgeOffline => 'Works offline';

  @override
  String get orangTuaBadgeData => 'Data stays on this device';

  @override
  String get orangTuaDelete => 'Delete all data';

  @override
  String get orangTuaDeleteTitle => 'Delete all data?';

  @override
  String get orangTuaDeleteBody =>
      'The name, settings, stars, stickers and artwork on this device will be erased. This can\'t be undone.';

  @override
  String get orangTuaDeleteSure => 'Really delete?';

  @override
  String get orangTuaPrivacy => 'Privacy policy';

  @override
  String get orangTuaSupport => 'Contact us';

  @override
  String get hurufTitle => 'Letters';

  @override
  String get hurufLearn => 'Learn';

  @override
  String get hurufWrite => 'Write';

  @override
  String get hurufSay => 'Say';

  @override
  String get modeSemantic => 'Learning mode';

  @override
  String get tulisFollow => 'Drag Moci along the yellow arrows to the star!';

  @override
  String get tulisWriteVerb => 'Write';

  @override
  String get tulisLine => 'Line';

  @override
  String get tulisOf => 'of';

  @override
  String get tulisDone => 'All done!';

  @override
  String get tulisGreat => 'Great job!';

  @override
  String get tulisNext => 'Next';

  @override
  String get tulisCrayons => 'Crayons';

  @override
  String get tulisAgain => 'Again';

  @override
  String get tulisListen => 'Listen';

  @override
  String get tulisArea => 'Writing area';

  @override
  String get tulisWriteAgain => 'Write again';

  @override
  String get tulisColor1 => 'Pink crayon';

  @override
  String get tulisColor2 => 'Blue crayon';

  @override
  String get tulisColor3 => 'Green crayon';

  @override
  String get tulisColor4 => 'Orange crayon';

  @override
  String get tulisColor5 => 'Purple crayon';

  @override
  String get tulisPickHuruf => 'Pick a letter';

  @override
  String get tulisUnitHuruf => 'the letter';

  @override
  String tulisKeyLabel(String huruf) {
    return 'Write the letter $huruf';
  }

  @override
  String tulisAreaLabel(String huruf) {
    return 'Writing area for the letter $huruf';
  }

  @override
  String tulisProgress(int n, int total) {
    return '$n of $total';
  }

  @override
  String get tulisSayStartHuruf => 'Let\'s write the letter';

  @override
  String get tulisSayDoneHuruf => 'Great job! You wrote the letter';

  @override
  String get tulisNice => 'Nice!';

  @override
  String get tulisHint => 'Drag Moci along the yellow arrows to the star.';

  @override
  String berandaContinueTulisHuruf(String huruf) {
    return 'Write the letter $huruf';
  }

  @override
  String get tulisPickAngka => 'Pick a number';

  @override
  String tulisKeyLabelAngka(String angka) {
    return 'Write the number $angka';
  }

  @override
  String tulisAreaLabelAngka(String angka) {
    return 'Writing area for the number $angka';
  }

  @override
  String get tulisSayStartAngka => 'Let\'s write the number';

  @override
  String get tulisSayDoneAngka => 'Great job! You wrote the number';

  @override
  String get angkaTitle => 'Numbers';

  @override
  String get angkaCount => 'Count';

  @override
  String get tulisUnitAngka => 'the number';

  @override
  String berandaContinueTulisAngka(String angka) {
    return 'Write the number $angka';
  }

  @override
  String get mainYukSub => 'Pick a game';

  @override
  String get mainYukAge2 => 'Ages 2+';

  @override
  String get mainYukAge3 => 'Ages 3+';

  @override
  String get mainYukAge4 => 'Ages 4+';

  @override
  String get mainYukCocokkanHub => 'Match Pictures';

  @override
  String get mainYukMemoriHub => 'Memory Cards';

  @override
  String get mainYukBayanganHub => 'Shadow Match';

  @override
  String get mainYukPuzzleHub => 'Jigsaw Puzzle';

  @override
  String get mainYukBalonHub => 'Letter Balloons';

  @override
  String get mainYukBesarKecilHub => 'Big & Small';

  @override
  String get mainYukTemaAcak => 'Surprise!';

  @override
  String get mainYukTemaBuah => 'Fruits';

  @override
  String get mainYukTemaHewan => 'Animals';

  @override
  String get mainYukTemaSayur => 'Veggies';

  @override
  String get mainYukTemaKendaraan => 'Vehicles';

  @override
  String get mainYukTemaBenda => 'Toys & Things';

  @override
  String mainYukPairs(int n) {
    return '$n pairs';
  }

  @override
  String mainYukMoves(int n) {
    return 'Moves: $n';
  }

  @override
  String get gameLevel => 'Level';

  @override
  String get cocokkanTitle => 'Match It!';

  @override
  String get cocokkanTema => 'Theme';

  @override
  String get cocokkanShuffle => 'New pictures';

  @override
  String get cocokkanHear => 'Listen to the instructions';

  @override
  String get cocokkanIns =>
      'Draw a line, or tap two pictures that are the same';

  @override
  String get cocokkanInst =>
      'Draw a line from a picture to the one that is the same.';

  @override
  String get cocokkanHeadBuah => 'Match the same fruits';

  @override
  String get cocokkanHeadHewan => 'Match the same animals';

  @override
  String get cocokkanHeadSayur => 'Match the same veggies';

  @override
  String get cocokkanHeadKendaraan => 'Match the same vehicles';

  @override
  String get cocokkanHeadBenda => 'Match the same toys & things';

  @override
  String get cocokkanMatch => 'Match!';

  @override
  String get cocokkanRetry => 'Oops, try again!';

  @override
  String get cocokkanTipPick => 'Pick a picture!';

  @override
  String get cocokkanTipNext => 'Now find the same one!';

  @override
  String get cocokkanTipDone => 'Hooray!';

  @override
  String get memoriTitle => 'Memory Cards';

  @override
  String get memoriRestart => 'New game';

  @override
  String get memoriTema => 'Theme';

  @override
  String get memoriPair => 'A pair!';

  @override
  String get memoriHidden => 'Hidden card';

  @override
  String get memoriInst => 'Open two cards and find the pair.';
}
