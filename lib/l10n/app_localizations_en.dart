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
}
