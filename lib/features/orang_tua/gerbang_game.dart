import 'dart:math';

/// Soal perkalian Gerbang Orang Tua: angka pertama 6–9, angka kedua 3–9.
final class GateQuestion {
  const GateQuestion(this.a, this.b);

  final int a, b;

  int get answer => a * b;

  @override
  bool operator ==(Object other) =>
      other is GateQuestion && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);
}

/// Soal acak; kalau sama dengan [previous], diulang sampai 20 kali.
GateQuestion nextGateQuestion(Random rng, {GateQuestion? previous}) {
  var q = GateQuestion(6 + rng.nextInt(4), 3 + rng.nextInt(7));
  for (var i = 0; i < 20 && q == previous; i++) {
    q = GateQuestion(6 + rng.nextInt(4), 3 + rng.nextInt(7));
  }
  return q;
}

enum GateStatus { idle, ok, bad, retry }

final class GateState {
  const GateState(this.q, this.input, this.status);

  final GateQuestion q;
  final String input;
  final GateStatus status;

  GateState copyWith({String? input, GateStatus? status}) =>
      GateState(q, input ?? this.input, status ?? this.status);
}

/// Menambah satu digit. Maksimal dua digit; digit kedua langsung dinilai.
/// Diabaikan saat status `ok` atau `bad`.
GateState gateDigit(GateState s, int digit) {
  if (s.status == GateStatus.ok || s.status == GateStatus.bad) return s;
  if (s.input.length >= 2) return s;
  final input = '${s.input}$digit';
  if (input.length < 2) {
    return s.copyWith(input: input, status: GateStatus.idle);
  }
  final benar = int.parse(input) == s.q.answer;
  return s.copyWith(
    input: input,
    status: benar ? GateStatus.ok : GateStatus.bad,
  );
}

/// Menghapus satu digit dan mengembalikan status ke `idle` (setelah `ok`,
/// gerbang terkunci lagi). Diabaikan saat `bad` atau saat isian kosong.
GateState gateDelete(GateState s) {
  if (s.status == GateStatus.bad || s.input.isEmpty) return s;
  return s.copyWith(
    input: s.input.substring(0, s.input.length - 1),
    status: GateStatus.idle,
  );
}

/// Soal baru dengan isian kosong dan status `idle`.
GateState gateNewQuestion(GateState s, Random rng) =>
    GateState(nextGateQuestion(rng, previous: s.q), '', GateStatus.idle);
