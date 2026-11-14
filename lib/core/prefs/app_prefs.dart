import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show immutable;

import '../lang.dart';

/// Tingkat usia: pemula 2-3, penjelajah 4-5, pembaca 6-7.
enum AgeLevel { pemula, penjelajah, pembaca }

/// Cara huruf dibacakan: bunyi (fonik) atau nama huruf.
enum LetterMode { fonik, nama }

AppLang defaultLangFor(Locale device) =>
    device.languageCode == 'id' ? AppLang.id : AppLang.en;

@immutable
final class AppPrefs {
  const AppPrefs({
    required this.lang,
    this.childName = '',
    this.ageLevel = AgeLevel.pemula,
    this.letterMode = LetterMode.fonik,
    this.dailyLimitMinutes = 30,
    this.music = true,
    this.sfx = true,
    this.restReminder = true,
    this.onboarded = false,
  });

  final AppLang lang;
  final String childName;
  final AgeLevel ageLevel;
  final LetterMode letterMode;

  /// `null` berarti tanpa batas.
  final int? dailyLimitMinutes;
  final bool music;
  final bool sfx;
  final bool restReminder;
  final bool onboarded;

  static const _keep = Object();

  AppPrefs copyWith({
    AppLang? lang,
    String? childName,
    AgeLevel? ageLevel,
    LetterMode? letterMode,
    Object? dailyLimitMinutes = _keep,
    bool? music,
    bool? sfx,
    bool? restReminder,
    bool? onboarded,
  }) => AppPrefs(
    lang: lang ?? this.lang,
    childName: childName ?? this.childName,
    ageLevel: ageLevel ?? this.ageLevel,
    letterMode: letterMode ?? this.letterMode,
    dailyLimitMinutes: identical(dailyLimitMinutes, _keep)
        ? this.dailyLimitMinutes
        : dailyLimitMinutes as int?,
    music: music ?? this.music,
    sfx: sfx ?? this.sfx,
    restReminder: restReminder ?? this.restReminder,
    onboarded: onboarded ?? this.onboarded,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPrefs &&
      other.lang == lang &&
      other.childName == childName &&
      other.ageLevel == ageLevel &&
      other.letterMode == letterMode &&
      other.dailyLimitMinutes == dailyLimitMinutes &&
      other.music == music &&
      other.sfx == sfx &&
      other.restReminder == restReminder &&
      other.onboarded == onboarded;

  @override
  int get hashCode => Object.hash(
    lang,
    childName,
    ageLevel,
    letterMode,
    dailyLimitMinutes,
    music,
    sfx,
    restReminder,
    onboarded,
  );
}
