import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/features/main_yuk/main_yuk_game.dart';

Item _item(String id, String kategori) => Item(
  id: id,
  kategori: kategori,
  nama: Bilingual(id, id),
  gambar: 'illustrations/$id.svg',
);

Katalog _katalogLima() => Katalog(
  item: [
    for (final k in ['buah', 'hewan', 'sayur', 'kendaraan', 'benda'])
      for (var i = 0; i < 3; i++) _item('$k$i', k),
  ],
);

void main() {
  test('enam permainan: rute, warna, dan usia minimum dari prototipe', () {
    expect(MainYukGame.values.map((g) => g.route), [
      '/main/cocokkan',
      '/main/memori',
      '/main/bayangan',
      '/main/puzzle',
      '/main/balon',
      '/main/besar-kecil',
    ]);
    expect(MainYukGame.values.map((g) => g.usiaMinimum), [2, 3, 2, 3, 4, 2]);
    expect(MainYukGame.balon.id, 'balon');
  });

  test('tema acak memilih kategori selain tema sebelumnya', () {
    final k = _katalogLima();
    for (var seed = 0; seed < 8; seed++) {
      final p = pilihTema(
        k,
        MainYukTema.acak,
        random: Random(seed),
        hindari: MainYukTema.hewan,
      );
      expect(p.tema, isNot(MainYukTema.hewan));
      expect(p.item, isNotEmpty);
      expect(p.item.every((i) => i.kategori == p.tema.kategori), isTrue);
    }
  });

  test('tema tetap mengembalikan benda kategorinya saja', () {
    final p = pilihTema(_katalogLima(), MainYukTema.buah, random: Random(1));
    expect(p.tema, MainYukTema.buah);
    expect(p.item.map((i) => i.id), ['buah0', 'buah1', 'buah2']);
  });

  test('nomor ronde naik dan unik lintas layar', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final seq = c.read(mainYukRoundSeqProvider.notifier);
    expect(seq.next('puzzle'), 'puzzle-1');
    expect(seq.next('puzzle'), 'puzzle-2');
    expect(seq.next('balon'), 'balon-3');
  });

  test('baris narasi memakai jenis dan id yang benar', () {
    expect(barisHuruf('B', 'be').id, 'b');
    expect(barisHuruf('B', 'be').jenis, 'huruf');
    expect(barisNama('apel', 'Apel').jenis, 'nama');
    expect(barisUi('cocokkanMatch', 'Cocok!').jenis, 'ui');
  });
}
