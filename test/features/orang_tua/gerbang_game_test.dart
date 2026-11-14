import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/orang_tua/gerbang_game.dart';

const _seven6 = GateQuestion(7, 6);
const _kosong = GateState(_seven6, '', GateStatus.idle);

void main() {
  test('rentang soal 6–9 × 3–9 di 2000 seed', () {
    for (var seed = 0; seed < 2000; seed++) {
      final q = nextGateQuestion(Random(seed));
      expect(q.a, inInclusiveRange(6, 9));
      expect(q.b, inInclusiveRange(3, 9));
      expect(q.answer, inInclusiveRange(18, 81));
    }
  });

  test('soal berikutnya tidak sama persis', () {
    const prev = GateQuestion(7, 6);
    for (var seed = 0; seed < 200; seed++) {
      final q = nextGateQuestion(Random(seed), previous: prev);
      expect((q.a, q.b), isNot((7, 6)));
    }
  });

  test('dua digit menilai jawaban', () {
    var s = _kosong;
    s = gateDigit(gateDigit(s, 4), 2);
    expect(s.status, GateStatus.ok);
    expect(gateDigit(s, 1).input, '42'); // diabaikan setelah ok
    expect(gateDelete(s).status, GateStatus.idle); // terkunci lagi
    final bad = gateDigit(gateDigit(_kosong, 4), 3);
    expect(bad.status, GateStatus.bad);
  });

  test('digit pertama belum dinilai dan menghapus status retry', () {
    final retry = _kosong.copyWith(status: GateStatus.retry);
    final s = gateDigit(retry, 4);
    expect((s.input, s.status), ('4', GateStatus.idle));
  });

  test('digit diabaikan saat bad', () {
    final bad = gateDigit(gateDigit(_kosong, 4), 3);
    expect(gateDigit(bad, 1), same(bad));
  });

  test('hapus diabaikan saat bad, dan saat isian kosong', () {
    final bad = gateDigit(gateDigit(_kosong, 4), 3);
    expect(gateDelete(bad), same(bad));
    expect(gateDelete(_kosong).input, '');
    expect(gateDelete(gateDigit(_kosong, 4)).input, '');
  });

  test('soal baru mengosongkan isian dan tidak sama dengan soal lama', () {
    final bad = gateDigit(gateDigit(_kosong, 4), 3);
    for (var seed = 0; seed < 100; seed++) {
      final s = gateNewQuestion(bad, Random(seed));
      expect((s.input, s.status), ('', GateStatus.idle));
      expect((s.q.a, s.q.b), isNot((7, 6)));
    }
  });
}
