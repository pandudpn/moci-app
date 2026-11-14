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
  });

  /// Tanggal lokal (`yyyy-MM-dd`) yang dihitung.
  final String date;
  final int secondsToday;
  final int secondsSinceRest;
  final bool restDue;
  final bool limitReached;

  PlayTimerState copyWith({
    String? date,
    int? secondsToday,
    int? secondsSinceRest,
    bool? restDue,
    bool? limitReached,
  }) => PlayTimerState(
    date: date ?? this.date,
    secondsToday: secondsToday ?? this.secondsToday,
    secondsSinceRest: secondsSinceRest ?? this.secondsSinceRest,
    restDue: restDue ?? this.restDue,
    limitReached: limitReached ?? this.limitReached,
  );

  @override
  bool operator ==(Object other) =>
      other is PlayTimerState &&
      other.date == date &&
      other.secondsToday == secondsToday &&
      other.secondsSinceRest == secondsSinceRest &&
      other.restDue == restDue &&
      other.limitReached == limitReached;

  @override
  int get hashCode =>
      Object.hash(date, secondsToday, secondsSinceRest, restDue, limitReached);

  @override
  String toString() =>
      'PlayTimerState($date, hari ini $secondsToday s, sejak istirahat '
      '$secondsSinceRest s, restDue $restDue, limitReached $limitReached)';
}

/// Satu langkah pengatur waktu (murni).
///
/// [elapsed] dijepit ke 0–2 detik: jam yang mundur, jam yang loncat, dan
/// aplikasi yang ditangguhkan tanpa event pause tidak merusak hitungan.
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

  final key = dateKey(now);
  if (key != date) {
    date = key;
    today = storedSecondsFor(key);
    sinceRest = 0;
  }
  if (counting) {
    // Dibulatkan, bukan dipotong: tick 999 ms tetap terhitung satu detik.
    final seconds = (elapsed.inMilliseconds / 1000).round().clamp(0, 2);
    today += seconds;
    sinceRest += seconds;
  }
  return PlayTimerState(
    date: date,
    secondsToday: today,
    secondsSinceRest: sinceRest,
    restDue: restReminder && sinceRest >= restIntervalSeconds,
    limitReached: limitMinutes != null && today >= limitMinutes * 60,
  );
}
