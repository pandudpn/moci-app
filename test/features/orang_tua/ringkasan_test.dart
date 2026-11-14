import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/features/orang_tua/ringkasan.dart';

void main() {
  test('item berbeda 7 hari terakhir per modul', () {
    final h = {
      '2026-11-14': const DayStats(
        items: {
          'huruf': ['A', 'B'],
          'hewan': ['kucing'],
        },
      ),
      '2026-11-10': const DayStats(
        items: {
          'huruf': ['B', 'C'],
        },
      ),
      '2026-11-07': const DayStats(
        items: {
          'huruf': ['Z'],
        },
      ), // di luar 7 hari
    };
    final rows = computeWeekly(h, DateTime(2026, 11, 14, 9));
    expect(rows.firstWhere((r) => r.modul == RingkasanModul.huruf).done, 3);
    expect(rows.firstWhere((r) => r.modul == RingkasanModul.hewan).done, 1);
    expect(pickSuggestion(rows), RingkasanModul.angka);
  });

  test('tanggal paling awal (6 hari lalu) masuk, 7 hari lalu tidak', () {
    final h = {
      '2026-11-08': const DayStats(
        items: {
          'angka': ['1'],
        },
      ),
      '2026-11-07': const DayStats(
        items: {
          'angka': ['2'],
        },
      ),
    };
    final rows = computeWeekly(h, DateTime(2026, 11, 14, 23, 59));
    expect(rows.firstWhere((r) => r.modul == RingkasanModul.angka).done, 1);
  });

  test('enam baris berurutan seperti enum dan rasio = done / total', () {
    final rows = computeWeekly(const {}, DateTime(2026, 11, 14));
    expect(rows.map((r) => r.modul), RingkasanModul.values);
    expect(RingkasanModul.values.map((m) => m.total), [26, 50, 42, 35, 90, 14]);
    expect(rows.every((r) => r.ratio == 0), isTrue);
  });

  test('saran: rasio terendah, bukan done terendah', () {
    final h = {
      '2026-11-14': DayStats(
        items: {
          'huruf': ['A'],
          'angka': [for (var i = 0; i < 10; i++) '$i'],
          'hewan': ['a', 'b'],
          'buahSayur': ['a', 'b'],
          'membaca': ['a'],
          'mewarnai': ['a'],
        },
      ),
    };
    final rows = computeWeekly(h, DateTime(2026, 11, 14));
    // membaca 1/90 paling rendah
    expect(pickSuggestion(rows), RingkasanModul.membaca);
  });

  test('TodaySummary.minutesLeft', () {
    expect(
      const TodaySummary(
        minutesPlayed: 18,
        limit: 30,
        stars: 0,
        stickers: 0,
        karya: 0,
      ).minutesLeft,
      12,
    );
    expect(
      const TodaySummary(
        minutesPlayed: 40,
        limit: 30,
        stars: 0,
        stickers: 0,
        karya: 0,
      ).minutesLeft,
      0,
    );
    expect(
      const TodaySummary(
        minutesPlayed: 5,
        limit: null,
        stars: 0,
        stickers: 0,
        karya: 0,
      ).minutesLeft,
      isNull,
    );
  });
}
