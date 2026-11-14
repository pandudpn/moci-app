import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/play_timer/play_timer.dart';

PlayTimerState t0(String d) => PlayTimerState(
  date: d,
  secondsToday: 0,
  secondsSinceRest: 0,
  restDue: false,
  limitReached: false,
);

PlayTimerState run(
  PlayTimerState s,
  int seconds, {
  int? limit = 30,
  bool rest = true,
  bool counting = true,
  DateTime? at,
}) {
  var now = at ?? DateTime(2026, 11, 14, 9);
  for (var i = 0; i < seconds; i++) {
    now = now.add(const Duration(seconds: 1));
    s = tickPlayTimer(
      s,
      now: now,
      elapsed: const Duration(seconds: 1),
      counting: counting,
      limitMinutes: limit,
      restReminder: rest,
      storedSecondsFor: (_) => 0,
    );
  }
  return s;
}

/// Pengatur waktu yang dimajukan per tick dengan jarak milidetik bebas.
final class _Tick {
  _Tick(this.s);

  PlayTimerState s;
  DateTime _now = DateTime(2026, 11, 14, 9);

  void gap(int ms) {
    _now = _now.add(Duration(milliseconds: ms));
    s = tickPlayTimer(
      s,
      now: _now,
      elapsed: Duration(milliseconds: ms),
      counting: true,
      limitMinutes: null,
      restReminder: false,
      storedSecondsFor: (_) => 0,
    );
  }
}

void main() {
  test('hanya menghitung saat counting', () {
    expect(run(t0('2026-11-14'), 60, counting: false).secondsToday, 0);
    expect(run(t0('2026-11-14'), 60).secondsToday, 60);
  });

  test('istirahat tepat di 20 menit kalau aktif', () {
    expect(run(t0('2026-11-14'), 1199).restDue, isFalse);
    expect(run(t0('2026-11-14'), 1200).restDue, isTrue);
    expect(run(t0('2026-11-14'), 1200, rest: false).restDue, isFalse);
  });

  test('batas 15/30/45/tanpa batas', () {
    expect(run(t0('2026-11-14'), 899, limit: 15).limitReached, isFalse);
    expect(run(t0('2026-11-14'), 900, limit: 15).limitReached, isTrue);
    expect(run(t0('2026-11-14'), 1800, limit: 30).limitReached, isTrue);
    expect(run(t0('2026-11-14'), 2699, limit: 45).limitReached, isFalse);
    expect(run(t0('2026-11-14'), 10000, limit: null).limitReached, isFalse);
  });

  test('tengah malam mereset', () {
    // R2: mulai 23:00 supaya 1800 tick berakhir tepat 23:30, sebelum tengah malam.
    final s = run(t0('2026-11-14'), 1800, at: DateTime(2026, 11, 14, 23, 0));
    expect(s.limitReached, isTrue);
    final next = tickPlayTimer(
      s,
      now: DateTime(2026, 11, 15, 0, 0, 5),
      elapsed: const Duration(seconds: 1),
      counting: true,
      limitMinutes: 30,
      restReminder: true,
      storedSecondsFor: (_) => 0,
    );
    expect(
      (next.date, next.secondsToday, next.limitReached),
      ('2026-11-15', 1, false),
    );
    expect(next.secondsSinceRest, 1);
  });

  test('jam mundur atau loncat tidak merusak hitungan', () {
    final s = run(t0('2026-11-14'), 100);
    final back = tickPlayTimer(
      s,
      now: DateTime(2026, 11, 14, 8),
      elapsed: const Duration(seconds: -3600),
      counting: true,
      limitMinutes: 30,
      restReminder: true,
      storedSecondsFor: (_) => 0,
    );
    expect(back.secondsToday, 100);
    final jump = tickPlayTimer(
      s,
      now: DateTime(2026, 11, 14, 12),
      elapsed: const Duration(hours: 3),
      counting: true,
      limitMinutes: 30,
      restReminder: true,
      storedSecondsFor: (_) => 0,
    );
    expect(jump.secondsToday, 102);
  });

  test('pindah tanggal memakai detik tersimpan tanggal baru', () {
    final s = run(t0('2026-11-14'), 50);
    final next = tickPlayTimer(
      s,
      now: DateTime(2026, 11, 15, 8),
      elapsed: const Duration(seconds: 1),
      counting: false,
      limitMinutes: 30,
      restReminder: true,
      storedSecondsFor: (d) => d == '2026-11-15' ? 400 : 0,
    );
    expect(
      (next.date, next.secondsToday, next.secondsSinceRest),
      ('2026-11-15', 400, 0),
    );
  });

  test('pecahan detik diakumulasi antartick', () {
    final t = _Tick(t0('2026-11-14'));
    t.gap(400);
    expect(t.s.secondsToday, 0);
    t.gap(400);
    expect(t.s.secondsToday, 0);
    t.gap(400); // 1,2 s
    expect(t.s.secondsToday, 1);
    t.gap(600); // 1,8 s
    expect(t.s.secondsToday, 1);
    t.gap(600); // 2,4 s
    expect(t.s.secondsToday, 2);
    t.gap(1500); // 3,9 s
    expect(t.s.secondsToday, 3);
  });

  test('tick 1,5 detik dihitung satu detik, bukan dua', () {
    final t = _Tick(t0('2026-11-14'))..gap(1500);
    expect(t.s.secondsToday, 1);
  });
}
