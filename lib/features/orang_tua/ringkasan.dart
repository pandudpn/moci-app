import '../../core/progress/progress.dart';

/// Modul yang dirangkum di "Minggu ini", berikut jumlah item per modul (D11).
/// Nama enum = kunci modul di `markItem(modul.name, …)`.
enum RingkasanModul {
  huruf(26),
  angka(50),
  hewan(42),
  buahSayur(35),
  membaca(90),
  mewarnai(14);

  const RingkasanModul(this.total);

  /// Jumlah isi modul: huruf, angka, hewan, buah dan sayur, suku kata, halaman.
  final int total;
}

final class WeeklyRow {
  const WeeklyRow(this.modul, this.done);

  final RingkasanModul modul;
  final int done;

  double get ratio => done / modul.total;
}

/// Jumlah item berbeda per modul dalam 7 tanggal terakhir (hari ini dan 6 hari
/// sebelumnya), urut seperti [RingkasanModul.values].
List<WeeklyRow> computeWeekly(Map<String, DayStats> harian, DateTime now) {
  // Konstruktor DateTime menghindari selisih jam saat pergantian waktu musim.
  final keys = {
    for (var i = 0; i < 7; i++)
      dateKey(DateTime(now.year, now.month, now.day - i)),
  };
  return [
    for (final modul in RingkasanModul.values)
      WeeklyRow(
        modul,
        {
          for (final e in harian.entries)
            if (keys.contains(e.key)) ...?e.value.items[modul.name],
        }.length,
      ),
  ];
}

/// Modul dengan cakupan terendah; sama rata: yang lebih awal di urutan enum.
RingkasanModul pickSuggestion(List<WeeklyRow> rows) {
  var best = rows.first;
  for (final r in rows.skip(1)) {
    if (r.ratio < best.ratio) best = r;
  }
  return best.modul;
}

/// Ringkasan "Hari ini".
final class TodaySummary {
  const TodaySummary({
    required this.minutesPlayed,
    required this.limit,
    required this.stars,
    required this.stickers,
    required this.karya,
  });

  final int minutesPlayed;

  /// Batas harian dalam menit; `null` berarti tanpa batas.
  final int? limit;
  final int stars, stickers, karya;

  /// Sisa menit (tidak negatif); `null` bila tanpa batas.
  int? get minutesLeft {
    final l = limit;
    if (l == null) return null;
    final left = l - minutesPlayed;
    return left < 0 ? 0 : left;
  }
}
