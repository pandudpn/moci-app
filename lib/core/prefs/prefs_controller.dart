import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:characters/characters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lang.dart';
import '../providers.dart';
import '../storage/key_value_store.dart';
import 'app_prefs.dart';

final deviceLocaleProvider = Provider<Locale>(
  (_) => PlatformDispatcher.instance.locale,
);

final prefsProvider = NotifierProvider<PrefsController, AppPrefs>(
  PrefsController.new,
);

const _kLang = 'moci.bahasa';
const _kName = 'moci.nama';
const _kAge = 'moci.usia';
const _kLetter = 'moci.caraBaca';
const _kLimit = 'moci.batasMenit';
const _kMusic = 'moci.musik';
const _kSfx = 'moci.efek';
const _kRest = 'moci.istirahat';
const _kOnboarded = 'moci.sambutanSelesai';

const _maxNameLength = 20;
const _allowedLimits = {15, 30, 45};
const _ageCodes = {
  AgeLevel.pemula: '2-3',
  AgeLevel.penjelajah: '4-5',
  AgeLevel.pembaca: '6-7',
};

final class PrefsController extends Notifier<AppPrefs> {
  KeyValueStore get _store => ref.read(keyValueStoreProvider);

  @override
  AppPrefs build() {
    final store = ref.watch(keyValueStoreProvider);
    final defaultLang = defaultLangFor(ref.watch(deviceLocaleProvider));

    final lang =
        AppLang.values.asNameMap()[store.getString(_kLang)] ?? defaultLang;
    final ageCode = store.getString(_kAge);
    final age =
        _ageCodes.entries
            .where((e) => e.value == ageCode)
            .map((e) => e.key)
            .firstOrNull ??
        AgeLevel.pemula;
    final letter =
        LetterMode.values.asNameMap()[store.getString(_kLetter)] ??
        LetterMode.fonik;
    final storedLimit = store.getInt(_kLimit);
    final int? limit = storedLimit == null
        ? 30
        : storedLimit == 0
        ? null
        : (_allowedLimits.contains(storedLimit) ? storedLimit : 30);

    return AppPrefs(
      lang: lang,
      childName: _trimName(store.getString(_kName) ?? ''),
      ageLevel: age,
      letterMode: letter,
      dailyLimitMinutes: limit,
      music: store.getBool(_kMusic) ?? true,
      sfx: store.getBool(_kSfx) ?? true,
      restReminder: store.getBool(_kRest) ?? true,
      onboarded: store.getBool(_kOnboarded) ?? false,
    );
  }

  static String _trimName(String name) {
    final t = name.trim();
    final chars = t.characters;
    if (chars.length <= _maxNameLength) return t;
    // Potong di batas kluster supaya emoji tidak jadi surrogate tunggal.
    return chars.take(_maxNameLength).toString().trimRight();
  }

  Future<void> setLang(AppLang lang) {
    state = state.copyWith(lang: lang);
    return _store.setString(_kLang, lang.name);
  }

  Future<void> setChildName(String name) {
    final clean = _trimName(name);
    state = state.copyWith(childName: clean);
    return _store.setString(_kName, clean);
  }

  Future<void> setAgeLevel(AgeLevel age) {
    state = state.copyWith(ageLevel: age);
    return _store.setString(_kAge, _ageCodes[age]!);
  }

  Future<void> setLetterMode(LetterMode mode) {
    state = state.copyWith(letterMode: mode);
    return _store.setString(_kLetter, mode.name);
  }

  Future<void> setDailyLimit(int? minutes) {
    if (minutes != null && !_allowedLimits.contains(minutes)) {
      throw ArgumentError.value(
        minutes,
        'minutes',
        'harus 15, 30, 45, atau null',
      );
    }
    state = state.copyWith(dailyLimitMinutes: minutes);
    return _store.setInt(_kLimit, minutes ?? 0);
  }

  Future<void> setMusic(bool value) {
    state = state.copyWith(music: value);
    return _store.setBool(_kMusic, value);
  }

  Future<void> setSfx(bool value) {
    state = state.copyWith(sfx: value);
    return _store.setBool(_kSfx, value);
  }

  Future<void> setRestReminder(bool value) {
    state = state.copyWith(restReminder: value);
    return _store.setBool(_kRest, value);
  }

  Future<void> completeOnboarding({
    required AppLang lang,
    required String childName,
    required AgeLevel age,
  }) async {
    final clean = _trimName(childName);
    state = state.copyWith(
      lang: lang,
      childName: clean,
      ageLevel: age,
      onboarded: true,
    );
    final store = _store;
    await store.setString(_kLang, lang.name);
    await store.setString(_kName, clean);
    await store.setString(_kAge, _ageCodes[age]!);
    await store.setBool(_kOnboarded, true);
  }

  Future<void> resetAll() async {
    state = AppPrefs(lang: defaultLangFor(ref.read(deviceLocaleProvider)));
    await _store.clear();
  }
}
