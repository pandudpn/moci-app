import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/balon_game.dart';

void main() {
  test('set huruf pemula sembilan huruf', () {
    expect(setHurufBalon(AgeLevel.pemula), 'ABCIMOPSU');
  });

  test('usia lain memakai dua puluh tiga huruf tanpa Q V X', () {
    final s = setHurufBalon(AgeLevel.penjelajah);
    expect(s, hasLength(23));
    expect('QVX'.split('').where(s.contains), isEmpty);
    expect(setHurufBalon(AgeLevel.pembaca), s);
  });

  test('ronde berisi target dua kali dan empat pengecoh', () {
    final r = buatBalon(AgeLevel.pemula, random: Random(3));
    expect(r.huruf, hasLength(6));
    expect(r.huruf.where((h) => h == r.target), hasLength(2));
    expect(r.huruf.toSet(), hasLength(5));
    expect(hurufBalonPemula.contains(r.target), isTrue);
  });

  test('target tidak mengulang ronde sebelumnya', () {
    for (var seed = 0; seed < 8; seed++) {
      final r = buatBalon(
        AgeLevel.penjelajah,
        random: Random(seed),
        hindari: 'B',
      );
      expect(r.target, isNot('B'));
    }
  });

  test('balon salah tidak menambah skor', () {
    final g = BalonGame(usia: AgeLevel.pemula, random: Random(1));
    final salah = g.ronde.huruf.indexWhere((h) => h != g.ronde.target);
    expect(g.pilih(salah), BalonStep.salah);
    expect(g.skor, 0);
    expect(g.pecah, isEmpty);
  });

  test('lima huruf benar menyelesaikan permainan', () {
    final g = BalonGame(usia: AgeLevel.pemula, random: Random(1));
    for (var i = 0; i < 5; i++) {
      final target = g.ronde.huruf.indexOf(g.ronde.target);
      expect(g.pilih(target), i == 4 ? BalonStep.selesai : BalonStep.pecah);
      g.lanjut();
    }
    expect(g.skor, 5);
    expect(g.selesai, isTrue);
  });
}
