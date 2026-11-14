import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/features/main_yuk/main_yuk_game.dart';
import 'package:moci/features/main_yuk/memori_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogBuah([int n = 8]) =>
    Katalog(item: [for (var i = 0; i < n; i++) _item('b$i', 'buah')]);

void main() {
  test('pasangan mengikuti level usia', () {
    expect(memoriPasangan(AgeLevel.pemula), 4);
    expect(memoriPasangan(AgeLevel.penjelajah), 6);
    expect(memoriPasangan(AgeLevel.pembaca), 8);
  });

  test('setiap id muncul dua kali dan teracak', () {
    final r = buatMemori(
      _katalogBuah(8),
      pasangan: 4,
      tema: MainYukTema.buah,
      random: Random(3),
    );
    expect(r.deck, hasLength(8));
    expect(r.deck.toSet(), hasLength(4));
    for (final id in r.deck.toSet()) {
      expect(r.deck.where((e) => e == id), hasLength(2));
    }
  });

  test('pasangan salah menutup dua kartu setelah langkah', () {
    final s = MemoriSesi(
      const MemoriRonde(
        tema: MainYukTema.buah,
        deck: ['a', 'b', 'c', 'b', 'a', 'c'],
      ),
    );
    expect(s.buka(0), MemoriStep.terbuka);
    expect(s.buka(1), MemoriStep.salah);
    expect(s.langkah, 1);
    s.tutup();
    expect(s.terbuka, isEmpty);
  });

  test('kartu ketiga diabaikan saat dua terbuka', () {
    final s = MemoriSesi(
      const MemoriRonde(
        tema: MainYukTema.buah,
        deck: ['a', 'b', 'c', 'b', 'a', 'c'],
      ),
    );
    s
      ..buka(0)
      ..buka(1);
    expect(s.buka(2), MemoriStep.abaikan);
    expect(s.terbuka, [0, 1]);
    expect(s.langkah, 1);
  });

  test('pasangan cocok menetap dan selesai saat pasangan terakhir', () {
    final s = MemoriSesi(
      const MemoriRonde(tema: MainYukTema.buah, deck: ['a', 'b', 'a', 'b']),
    );
    expect(s.buka(0), MemoriStep.terbuka);
    expect(s.buka(2), MemoriStep.sepasang);
    expect(s.ketemu, {'a'});
    expect(s.buka(1), MemoriStep.terbuka);
    expect(s.buka(3), MemoriStep.selesai);
  });
}
