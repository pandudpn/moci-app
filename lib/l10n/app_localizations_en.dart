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
  String get hurufListen => 'Hear the letter sound and word';

  @override
  String get hurufPrev => 'Previous letter';

  @override
  String get hurufNext => 'Next letter';

  @override
  String get hurufLetter => 'Letter';

  @override
  String get hurufTapHint => 'tap to hear its sound';

  @override
  String get hurufTapHintName => 'tap to hear its name';

  @override
  String get hurufSound => 'Sound';

  @override
  String get hurufName => 'Name:';

  @override
  String get hurufSoundOf => 'Sound of letter';

  @override
  String get hurufNameOf => 'Name of letter';

  @override
  String hurufLetterLabel(String huruf, String petunjuk) {
    return 'Letter $huruf, $petunjuk';
  }

  @override
  String hurufSoundAria(String huruf, String bunyi) {
    return 'Sound of letter $huruf $bunyi';
  }

  @override
  String hurufNameAria(String huruf) {
    return 'Name of letter $huruf';
  }

  @override
  String get hurufGridLabel => 'Pick a letter';

  @override
  String berandaContinueHuruf(String huruf) {
    return 'Letter $huruf';
  }

  @override
  String get angkaListen => 'Hear the number';

  @override
  String get angkaAuto => 'Count for me';

  @override
  String get angkaRange => 'Number range';

  @override
  String get angkaPick => 'Pick a number';

  @override
  String angkaNumber(int n) {
    return 'Number $n';
  }

  @override
  String angkaCountPrompt(String benda) {
    return 'Let\'s count the $benda!';
  }

  @override
  String get angkaTapIt => 'Tap to count';

  @override
  String angkaDone(String kata, String benda) {
    return '$kata $benda!';
  }

  @override
  String get angkaDoneSay => 'Great counting!';

  @override
  String berandaContinueAngka(String angka) {
    return 'Number $angka';
  }

  @override
  String get ucapkanHear => 'Hear it';

  @override
  String get ucapkanYourTurn => 'Your turn! Say:';

  @override
  String get ucapkanIdle => 'Tap the mic, then say it';

  @override
  String get ucapkanListen => 'Moci is listening…';

  @override
  String get ucapkanGood => 'Well done!';

  @override
  String get ucapkanAgain => 'Again';

  @override
  String get ucapkanNextWord => 'Next word';

  @override
  String get ucapkanSyl => 'Syllable';

  @override
  String get ucapkanMicIdle => 'Tap and say';

  @override
  String get ucapkanMicListen => 'Moci is listening';

  @override
  String get ucapkanLetsSay => 'Let\'s say';

  @override
  String get ucapkanTryAgain => 'Let\'s try again!';

  @override
  String get ucapkanDoneSay => 'Great job! You can say';

  @override
  String get ucapkanMicAskTitle => 'Call Mom or Dad';

  @override
  String get ucapkanMicAskBody =>
      'Only a grown-up turns on the microphone. Your voice is recognized on this device only; it is not saved or sent.';

  @override
  String get ucapkanMicAskAction => 'Open Gate';

  @override
  String get ucapkanMicDenied =>
      'Without the microphone, let\'s listen and repeat!';

  @override
  String get ucapkanMicUnavailable =>
      'Moci can\'t listen on this device yet. Let\'s listen and repeat!';

  @override
  String get ucapkanPractice => 'Listen and repeat';

  @override
  String ucapkanMicLabel(String kata) {
    return 'Tap and say $kata';
  }

  @override
  String ucapkanWordLabel(String kata) {
    return '$kata, tap to hear it';
  }

  @override
  String berandaContinueUcapkan(String kata) {
    return 'Say $kata';
  }

  @override
  String get membacaTitle => 'Let\'s Read';

  @override
  String get membacaModes => 'Reading mode';

  @override
  String get membacaSukuKata => 'Syllables';

  @override
  String get membacaSusunKata => 'Build Words';

  @override
  String get membacaKalimat => 'Sentences';

  @override
  String get sukuKataPilih => 'Pick a letter';

  @override
  String get sukuKataTip => 'Tap a syllable to hear it!';

  @override
  String get sukuKataHear => 'Hear word';

  @override
  String get sukuKataReadAll => 'Read all';

  @override
  String get sukuKataExample => 'Example word';

  @override
  String get sukuKataSayIt => 'Say it out loud!';

  @override
  String sukuKataLetter(String huruf) {
    return 'Letter $huruf';
  }

  @override
  String sukuKataSyllable(String suku) {
    return 'Syllable $suku';
  }

  @override
  String get susunKataLevel => 'Level';

  @override
  String get susunKataLevel2 => '2 parts';

  @override
  String get susunKataLevel3 => '3 parts';

  @override
  String get susunKataHear => 'Hear the word';

  @override
  String get susunKataIns => 'Tap the parts in order to build the word';

  @override
  String get susunKataNext => 'Next';

  @override
  String get susunKataHintStart => 'Listen, then tap the first part!';

  @override
  String get susunKataHintMore => 'Good! Now the next part.';

  @override
  String get susunKataTryAgain => 'Oops, not quite. Try again!';

  @override
  String susunKataSlot(int nomor) {
    return 'Part $nomor';
  }

  @override
  String get susunKataEmpty => 'empty';

  @override
  String get susunKataYes => 'Yes!';

  @override
  String susunKataTile(String suku) {
    return 'Part $suku';
  }

  @override
  String get susunKataProgress => 'Progress';

  @override
  String get kalimatIns => 'Tap a word to hear it';

  @override
  String get kalimatRead => 'Read with me';

  @override
  String get kalimatPrev => 'Previous sentence';

  @override
  String get kalimatNext => 'Next sentence';

  @override
  String get kalimatWhich => 'Which picture matches?';

  @override
  String get kalimatReadMode => 'Read';

  @override
  String get kalimatQuizMode => 'Guess the picture';

  @override
  String get kalimatReadTip =>
      'Tap \"Read with me\" and follow the words as they light up!';

  @override
  String get kalimatYes => 'Yes! That is right!';

  @override
  String get kalimatNo => 'Not that one. Try again!';

  @override
  String get kalimatPicture => 'Sentence picture';

  @override
  String get mewarnaiFilter => 'Picture type';

  @override
  String get mewarnaiTabSemua => 'All';

  @override
  String get mewarnaiTabHewan => 'Animals';

  @override
  String get mewarnaiTabBenda => 'Things & Nature';

  @override
  String get mewarnaiHintPick => 'Pick a picture to color!';

  @override
  String mewarnaiOpenPage(String nama) {
    return 'Color the picture: $nama';
  }

  @override
  String get mewarnaiContinue => 'Continue';

  @override
  String get mewarnaiKaryaku => 'My Artwork';

  @override
  String mewarnaiKaryaCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artworks',
      one: '1 artwork',
      zero: 'No artwork yet',
    );
    return '$_temp0';
  }

  @override
  String mewarnaiOpenKaryaku(int count) {
    return 'Open My Artwork, $count artworks';
  }

  @override
  String get mewarnaiBackGaleri => 'Back to pictures';

  @override
  String get mewarnaiChangePage => 'Pictures';

  @override
  String get mewarnaiUndo => 'Undo';

  @override
  String get mewarnaiClear => 'Start over';

  @override
  String get mewarnaiSave => 'Save';

  @override
  String get mewarnaiTools => 'Tools';

  @override
  String get mewarnaiToolBrush => 'Brush';

  @override
  String get mewarnaiToolFill => 'Fill';

  @override
  String get mewarnaiToolErase => 'Eraser';

  @override
  String get mewarnaiToolCap => 'Sticker';

  @override
  String get mewarnaiBrushSize => 'Brush size';

  @override
  String get mewarnaiBrushSmall => 'Small brush';

  @override
  String get mewarnaiBrushMedium => 'Medium brush';

  @override
  String get mewarnaiBrushBig => 'Big brush';

  @override
  String get mewarnaiCrayons => 'Crayons';

  @override
  String get mewarnaiCaps => 'Stickers';

  @override
  String get mewarnaiHintBrush =>
      'Color inside a shape. Your crayon will not go outside the line!';

  @override
  String get mewarnaiHintFill => 'Tap a shape to fill it with one color.';

  @override
  String get mewarnaiHintErase => 'Rub to erase the color.';

  @override
  String get mewarnaiHintCap => 'Tap the picture to put a sticker.';

  @override
  String mewarnaiCanvasLabel(String nama) {
    return 'Picture to color: $nama';
  }

  @override
  String get mewarnaiSayClear => 'Let\'s start over!';

  @override
  String get mewarnaiSaved => 'Saved to My Artwork!';

  @override
  String get mewarnaiSaySaved => 'Saved! Beautiful work!';

  @override
  String get mewarnaiPickPage => 'Pick a picture';

  @override
  String get mewarnaiClose => 'Close';

  @override
  String get mewarnaiKaryakuHint => 'Tap a picture to see it bigger.';

  @override
  String get mewarnaiKaryakuEmpty => 'No artwork yet';

  @override
  String get mewarnaiKaryakuEmptyHint =>
      'Let\'s color something! Tap Save and your picture will show up here.';

  @override
  String get mewarnaiColorAgain => 'Color again';

  @override
  String get mewarnaiDelete => 'Delete';

  @override
  String get mewarnaiDeleteConfirm => 'Delete for sure?';

  @override
  String mewarnaiViewArt(String nama) {
    return 'See artwork: $nama';
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

  @override
  String get bayanganTitle => 'Shadow Match';

  @override
  String get bayanganAsk => 'Whose shadow is this?';

  @override
  String get bayanganShadow => 'A mystery shadow';

  @override
  String get bayanganProgress => 'Progress';

  @override
  String get bayanganYes => 'Yes! It is the';

  @override
  String get bayanganNo => 'Not that one, that is the';

  @override
  String get bayanganInst => 'Tap the picture that matches the shadow.';

  @override
  String get bayanganSemantic => 'Shadow choices';

  @override
  String get puzzleTitle => 'Puzzle';

  @override
  String get puzzleOther => 'New puzzle';

  @override
  String get puzzleBoard => 'Puzzle board';

  @override
  String get puzzleHintPick => 'Tap a piece, then tap where it goes.';

  @override
  String get puzzleHintPlace => 'Now tap the right spot on the picture!';

  @override
  String get puzzleFits => 'It fits!';

  @override
  String get puzzleNo => 'Not there. Try another spot!';

  @override
  String puzzlePiece(int n) {
    return 'Puzzle piece $n';
  }

  @override
  String puzzleSpot(int n) {
    return 'Spot $n';
  }

  @override
  String get puzzleDone => 'Hooray! It is a';

  @override
  String get puzzleInst => 'Tap a piece, then tap where it goes.';

  @override
  String get puzzleTipPlace => 'Now tap the right spot on the picture!';

  @override
  String puzzlePieces(int n, int m) {
    return '$n / $m pieces';
  }

  @override
  String get balonTitle => 'Letter Balloons';

  @override
  String get balonAsk => 'Pop the letter';

  @override
  String get balonProgress => 'Progress';

  @override
  String get balonYes => 'Pop! That is';

  @override
  String get balonNo => 'Oops, that is';

  @override
  String get balonInst => 'Pop the balloon with the letter Moci says.';

  @override
  String balonLabel(String huruf) {
    return 'Balloon $huruf';
  }

  @override
  String get besarKecilTitle => 'Big & Small';

  @override
  String get besarKecilWhich => 'Which one is the';

  @override
  String get besarKecilBig => 'BIGGEST';

  @override
  String get besarKecilSmall => 'SMALLEST';

  @override
  String get besarKecilProgress => 'Progress';

  @override
  String get besarKecilYes => 'Yes! That is the';

  @override
  String get besarKecilNo => 'Look again!';

  @override
  String get besarKecilBigSay => 'biggest';

  @override
  String get besarKecilSmallSay => 'smallest';

  @override
  String get besarKecilInst => 'Tap the biggest or the smallest picture.';

  @override
  String besarKecilLabel(String nama, int n) {
    return '$nama, size $n';
  }

  @override
  String get hewanGroups => 'Animal groups';

  @override
  String get hewanGroupAll => 'All';

  @override
  String get hewanGroupRumah => 'Pets & Farm';

  @override
  String get hewanGroupLiar => 'Wild';

  @override
  String get hewanGroupReptil => 'Reptiles & Frogs';

  @override
  String get hewanGroupAir => 'Sea & Water';

  @override
  String get hewanGroupKecil => 'Birds & Bugs';

  @override
  String get hewanDidYou => 'Did you know?';

  @override
  String get hewanHearName => 'Hear name';

  @override
  String get hewanHearSound => 'Hear sound';

  @override
  String get hewanPrev => 'Previous animal';

  @override
  String get hewanNext => 'Next animal';

  @override
  String get hewanTapHint => ', tap to hear its sound';

  @override
  String hewanCounterLabel(int nomor, int total) {
    return 'Animal $nomor of $total';
  }

  @override
  String get buahLearn => 'Learn';

  @override
  String get buahGuess => 'Guess';

  @override
  String get buahCats => 'Category';

  @override
  String get buahCatAll => 'All';

  @override
  String get buahCatFruit => 'Fruits';

  @override
  String get buahCatVeggie => 'Veggies';

  @override
  String get buahTagFruit => 'FRUIT';

  @override
  String get buahTagVeggie => 'VEGGIE';

  @override
  String get buahListen => 'Listen to the question';

  @override
  String buahQuestion(String nama) {
    return 'Find the $nama!';
  }

  @override
  String get buahQuestionSay => 'Find the';

  @override
  String get buahYesSay => 'Yes!';

  @override
  String get buahWrongSay => 'That\'s not it. Try again!';

  @override
  String buahRight(String nama) {
    return 'Yes! $nama!';
  }

  @override
  String get buahNext => 'Next';

  @override
  String buahProgress(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get warnaPick => 'Pick a color';

  @override
  String get warnaNewSet => 'New pictures';

  @override
  String get warnaNextColor => 'Next color';

  @override
  String get warnaInstructionPre => 'Tap everything';

  @override
  String warnaDone(String warna) {
    return 'You found all the $warna things!';
  }

  @override
  String warnaCounterLabel(int found, int total) {
    return '$found of $total found';
  }

  @override
  String warnaChipLabel(String nama) {
    return 'Color $nama';
  }

  @override
  String get warnaSentuh => 'Tap everything that is';

  @override
  String get warnaBetul => 'Yes!';

  @override
  String get warnaBukan => 'Not this one. Find';

  @override
  String get warnaSemuaKetemu => 'You found them all!';

  @override
  String get warnaBalon => 'balloon';

  @override
  String get warnaBintang => 'star';

  @override
  String get warnaHati => 'heart';

  @override
  String get bentukLearn => 'Learn';

  @override
  String get bentukFind => 'Find';

  @override
  String get bentukCountCorners => 'Count the corners';

  @override
  String get bentukCountTips => 'Count the points';

  @override
  String bentukSisi(int n) {
    return '$n sides';
  }

  @override
  String bentukSudut(int n) {
    return '$n corners';
  }

  @override
  String bentukUjung(int n) {
    return '$n points';
  }

  @override
  String get bentukSayang => 'A symbol of love';

  @override
  String get bentukTanpaSudut => 'No corners';

  @override
  String bentukShapeLabel(String nama) {
    return 'Shape $nama';
  }

  @override
  String bentukQuestion(String nama) {
    return 'Where is the $nama?';
  }

  @override
  String get bentukQuestionSay => 'Where is the';

  @override
  String get bentukYesSay => 'Yes! That is the';

  @override
  String get bentukNoSay => 'No, that is the';

  @override
  String get bentukTryAgain => 'Try again!';

  @override
  String get bentukDone => 'Great job! You found them all!';

  @override
  String get bentukAgain => 'Play again';

  @override
  String get bentukPrize => 'Get a prize';

  @override
  String bentukProgress(int n, int total) {
    return 'Progress $n of $total';
  }

  @override
  String get bentukListen => 'Listen to the question';

  @override
  String get musikXylophone => 'Xylophone';

  @override
  String get musikDrum => 'Drums';

  @override
  String get musikModes => 'Instrument';

  @override
  String get musikSongLabel => 'SONG';

  @override
  String get musikSongsLabel => 'Pick a song';

  @override
  String get musikStop => 'Stop';

  @override
  String get musikFollow => 'Play along';

  @override
  String musikFollowingCount(int posisi, int total) {
    return 'Playing along · $posisi / $total';
  }

  @override
  String get musikSongDone => 'Wonderful! You played the whole song!';

  @override
  String get musikBeat => 'Play a rhythm';

  @override
  String get musikDrumHint =>
      'Tap the drums! Or play a rhythm, then clap along with Moci.';

  @override
  String musikNote(String sol, int nomor) {
    return 'Note $sol $nomor';
  }

  @override
  String get musikPadDrum => 'Drum';

  @override
  String get musikPadClap => 'Clap';

  @override
  String get musikPadCymbal => 'Cymbal';

  @override
  String get musikPadShaker => 'Shaker';

  @override
  String get musikTwinkle => 'Twinkle Twinkle';

  @override
  String get musikMary => 'Mary Had a Little Lamb';
}
