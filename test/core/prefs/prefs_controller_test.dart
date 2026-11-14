import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/key_value_store.dart';

ProviderContainer make(MemoryKeyValueStore s, Locale l) {
  final c = ProviderContainer(overrides: [
    keyValueStoreProvider.overrideWithValue(s),
    deviceLocaleProvider.overrideWithValue(l),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('bawaan ikut bahasa perangkat', () {
    expect(make(MemoryKeyValueStore(), const Locale('id', 'ID')).read(prefsProvider).lang, AppLang.id);
    expect(make(MemoryKeyValueStore(), const Locale('en', 'US')).read(prefsProvider).lang, AppLang.en);
    expect(make(MemoryKeyValueStore(), const Locale('ms', 'MY')).read(prefsProvider).lang, AppLang.en);
  });
  test('nilai bawaan lain', () {
    final p = make(MemoryKeyValueStore(), const Locale('id')).read(prefsProvider);
    expect(p.dailyLimitMinutes, 30);
    expect([p.music, p.sfx, p.restReminder, p.onboarded], [true, true, true, false]);
    expect(p.letterMode, LetterMode.fonik);
    expect(p.ageLevel, AgeLevel.pemula);
  });
  test('tersimpan dan terbaca ulang, termasuk tanpa batas', () async {
    final s = MemoryKeyValueStore();
    final c = make(s, const Locale('id'));
    await c.read(prefsProvider.notifier).completeOnboarding(
        lang: AppLang.en, childName: '  Raka  ', age: AgeLevel.pembaca);
    await c.read(prefsProvider.notifier).setDailyLimit(null);
    final again = make(s, const Locale('id')).read(prefsProvider);
    expect(again.lang, AppLang.en);
    expect(again.childName, 'Raka');
    expect(again.ageLevel, AgeLevel.pembaca);
    expect(again.onboarded, isTrue);
    expect(again.dailyLimitMinutes, isNull);
  });
  test('nama dipotong 20 karakter', () async {
    final c = make(MemoryKeyValueStore(), const Locale('id'));
    await c.read(prefsProvider.notifier).setChildName('A' * 30);
    expect(c.read(prefsProvider).childName.length, 20);
  });
  test('batas di luar 15/30/45/null ditolak', () {
    final c = make(MemoryKeyValueStore(), const Locale('id'));
    expect(() => c.read(prefsProvider.notifier).setDailyLimit(20), throwsArgumentError);
  });
  test('resetAll kembali ke bawaan', () async {
    final s = MemoryKeyValueStore();
    final c = make(s, const Locale('en'));
    await c.read(prefsProvider.notifier).completeOnboarding(lang: AppLang.id, childName: 'Ana', age: AgeLevel.penjelajah);
    await c.read(prefsProvider.notifier).resetAll();
    expect(c.read(prefsProvider).onboarded, isFalse);
    expect(c.read(prefsProvider).childName, '');
    expect(s.getString('moci.nama'), isNull);
  });
  test('nilai tersimpan tidak valid memakai bawaan', () {
    final s = MemoryKeyValueStore();
    s.setString('moci.usia', 'x');
    s.setString('moci.caraBaca', 'z');
    s.setString('moci.bahasa', 'fr');
    s.setInt('moci.batasMenit', 20);
    final p = make(s, const Locale('id')).read(prefsProvider);
    expect(p.ageLevel, AgeLevel.pemula);
    expect(p.letterMode, LetterMode.fonik);
    expect(p.lang, AppLang.id);
    expect(p.dailyLimitMinutes, 30);
  });
  test('setter lain tersimpan', () async {
    final s = MemoryKeyValueStore();
    final c = make(s, const Locale('id'));
    final n = c.read(prefsProvider.notifier);
    await n.setLang(AppLang.en);
    await n.setAgeLevel(AgeLevel.penjelajah);
    await n.setLetterMode(LetterMode.nama);
    await n.setMusic(false);
    await n.setSfx(false);
    await n.setRestReminder(false);
    await n.setDailyLimit(45);
    final p = make(s, const Locale('id')).read(prefsProvider);
    expect(p.lang, AppLang.en);
    expect(p.ageLevel, AgeLevel.penjelajah);
    expect(p.letterMode, LetterMode.nama);
    expect([p.music, p.sfx, p.restReminder], [false, false, false]);
    expect(p.dailyLimitMinutes, 45);
    expect(s.getString('moci.usia'), '4-5');
  });
}
