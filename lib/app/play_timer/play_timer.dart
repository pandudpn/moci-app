import 'package:flutter/foundation.dart';

import '../../core/progress/progress.dart';

/// Detik bermain antara dua istirahat (20 menit).
const restIntervalSeconds = 1200;

/// Keadaan pengatur waktu: detik bermain hari ini dan sejak istirahat terakhir.
@immutable
final class PlayTimerState {
  const PlayTimerState({
    required this.date,
    required this.secondsToday,
    required this.secondsSinceRest,
    required this.restDue,
    required this.limitReached,
    this.carryMs = 0,
  });

  /// Tanggal lokal (`yyyy-MM-dd`) yang dihitung.
  final String date;
  final int secondsToday;
  final int secondsSinceRest;
  final bool restDue;
  final bool limitReached;

  /// Sisa milidetik yang belum menjadi detik penuh, dibawa ke tick berikutnya.
  ///
  /// Bagian dari nilai supaya [tickPlayTimer] tetap murni: jarak tick pecahan
  /// (0,4 s) tidak hilang dan tidak dibulatkan sendiri-sendiri.
  final int carryMs;

  PlayTimerState copyWith({
    String? date,
    int? secondsToday,
    int? secondsSinceRest,
    bool? restDue,
    bool? limitReached,
    int? carryMs,
  }) => PlayTimerState(
    date: date ?? this.date,
    secondsToday: secondsToday ?? this.secondsToday,
    secondsSinceRest: secondsSinceRest ?? this.secondsSinceRest,
    restDue: restDue ?? this.restDue,
    limitReached: limitReached ?? this.limitReached,
    carryMs: carryMs ?? this.carryMs,
  );

  @override
  bool operator ==(Object other) =>
      other is PlayTimerState &&
      other.date == date &&
      other.secondsToday == secondsToday &&
      other.secondsSinceRest == secondsSinceRest &&
      other.restDue == restDue &&
      other.limitReached == limitReached &&
      other.carryMs == carryMs;

  @override
  int get hashCode => Object.hash(
    date,
    secondsToday,
    secondsSinceRest,
    restDue,
    limitReached,
    carryMs,
  );

  @override
  String toString() =>
      'PlayTimerState($date, hari ini $secondsToday s, sejak istirahat '
      '$secondsSinceRest s, restDue $restDue, limitReached $limitReached, '
      'sisa $carryMs ms)';
}

/// Satu langkah pengatur waktu (murni).
///
/// Milidetik dijumlahkan lalu dipotong: tick 0,4 s dan 0,6 s bersama-sama
/// menghasilkan satu detik. Kontribusi satu tick dijepit 0–2 detik supaya jam
/// yang mundur, jam yang loncat, dan aplikasi yang ditangguhkan tanpa event
/// pause tidak merusak hitungan.
PlayTimerState tickPlayTimer(
  PlayTimerState s, {
  required DateTime now,
  required Duration elapsed,
  required bool counting,
  required int? limitMinutes,
  required bool restReminder,
  required int Function(String date) storedSecondsFor,
}) {
  var date = s.date;
  var today = s.secondsToday;
  var sinceRest = s.secondsSinceRest;
  var carry = s.carryMs;

  final key = dateKey(now);
  if (key != date) {
    date = key;
    today = storedSecondsFor(key);
    sinceRest = 0;
    carry = 0;
  }
  if (counting) {
    final ms = carry + elapsed.inMilliseconds.clamp(0, 2000);
    final seconds = ms ~/ 1000;
    carry = ms % 1000;
    today += seconds;
    sinceRest += seconds;
  }
  return PlayTimerState(
    date: date,
    secondsToday: today,
    secondsSinceRest: sinceRest,
    restDue: restReminder && sinceRest >= restIntervalSeconds,
    limitReached: limitMinutes != null && today >= limitMinutes * 60,
    carryMs: carry,
  );
}
