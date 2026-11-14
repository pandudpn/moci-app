import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/tracing.dart';

import '../../tool/konten/ekspor_prototipe.dart';

Map<String, Object?> _baca(Directory out, String path) =>
    jsonDecode(File('${out.path}/$path').readAsStringSync())
        as Map<String, Object?>;

void main() {
  late Directory out;
  late EksporHasil h;

  setUpAll(() async {
    out = Directory.systemTemp.createTempSync('ekspor');
    h = await eksporPrototipe(
      prototipe: Directory('docs/design/prototype'),
      keluaran: out,
    );
  });

  tearDownAll(() => out.deleteSync(recursive: true));

  test('jumlah sesuai inventaris', () {
    final k = Katalog.fromJson(_baca(out, 'content/katalog.json'));
    expect(k.item.length, 107);
    expect(k.item.where((i) => i.hewan != null).length, 42);
    expect(k.byKategori('buah').length, 21);
    expect(k.byKategori('sayur').length, 14);
    expect(k.byKategori('kendaraan').length, 9);
    expect(k.byKategori('benda').length, 17);
    expect(k.byKategori('lain').length, 4);
    expect(k.item.where((i) => i.warna != null).length, 81);
    expect(
      (k.warna.length, k.bentuk.length, k.huruf.length, k.kalimat.length),
      (11, 10, 26, 18),
    );
    expect((k.kata.id.length, k.kata.en.length), (71, 33));
    expect((k.ucapkan.id.length, k.ucapkan.en.length), (5, 5));
    expect(k.sukuKata.contoh['id']!.length, 41);
    expect(k.byId('paprika')!.nama.en, 'Bell Pepper');
    expect(k.byId('eskrim')!.nama.id, 'Es Krim');
    expect(k.warna.map((w) => w.id), containsAll(['merahmuda', 'abu']));
    expect(k.huruf.firstWhere((e) => e.huruf == 'X').en.kata, 'Box');
    final t = TracingSet.fromJson(_baca(out, 'tracing/huruf.json'));
    expect(t.glyph.keys.length, 26);
    expect(t.glyph['A'], [
      'M260 70L130 450',
      'M260 70L390 450',
      'M176 315H344',
    ]);
    final c = ColoringSet.fromJson(_baca(out, 'coloring/pages.json'));
    expect(c.halaman.length, 14);
    expect(c.halaman.fold<int>(0, (s, p) => s + p.bagian.length), 294);
    expect(c.halaman.first.id, 'kupu');
    expect(c.halaman.first.contoh.length, 17);
    expect(h.glyphCount, 36);
    expect(h.strokeCount, 63);
  });

  test('id unik dan gambar mengikuti id', () {
    final k = Katalog.fromJson(_baca(out, 'content/katalog.json'));
    final ids = k.item.map((i) => i.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final item in k.item) {
      expect(item.gambar, 'illustrations/${item.id}.svg');
      expect(item.nama.id, isNotEmpty, reason: item.id);
      expect(item.nama.en, isNotEmpty, reason: item.id);
      expect(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$').hasMatch(item.id), isTrue);
    }
  });

  test('data hewan dan suku kata ikut', () {
    final k = Katalog.fromJson(_baca(out, 'content/katalog.json'));
    final kucing = k.byId('kucing')!;
    expect(kucing.hewan!.kelompok, 'rumah');
    expect(kucing.hewan!.bunyi.id, 'Meong!');
    expect(kucing.sukuKata.id, ['ku', 'cing']);
    expect(kucing.sukuKata.en, isNull);
    expect(k.byId('paprika')!.sukuKata.en, isNull);
    expect(k.angka.maks, 50);
    expect(k.angka.rentang, [(1, 10), (11, 20), (21, 30), (31, 40), (41, 50)]);
    expect(k.angka.benda.length, 12);
    expect(k.angka.benda.first, 'apel');
    final bintang = k.bentuk.firstWhere((b) => b.id == 'bintang');
    expect((bintang.jenis, bintang.sudut, bintang.sisi), ('star', 5, 0));
    final persegi = k.bentuk.firstWhere((b) => b.id == 'persegi');
    expect((persegi.jenis, persegi.sudut, persegi.sisi), ('poly', 4, 4));
  });

  test('angka tracing dan cap krayon', () {
    final t = TracingSet.fromJson(_baca(out, 'tracing/angka.json'));
    expect(t.glyph.keys.length, 10);
    expect(t.glyph['1'], ['M200 140L275 70V450']);
    final cap = (jsonDecode(
      File('${out.path}/coloring/cap.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>().map(Cap.fromJson).toList();
    expect(cap.length, 8);
    expect(cap.first.id, 'moci');
    expect(cap[1].id, 'moci-senang');
    expect(cap.map((c) => c.id), containsAll(['apel', 'eskrim']));
    final krayon = (jsonDecode(
      File('${out.path}/coloring/krayon.json').readAsStringSync(),
    ) as List).cast<Map<String, Object?>>().map(Krayon.fromJson).toList();
    expect(krayon.length, 16);
    expect(krayon.first.hex, '#FF4B4B');
  });

  test('contoh mewarnai kupu dan karya demo', () {
    final c = ColoringSet.fromJson(_baca(out, 'coloring/pages.json'));
    expect(c.halaman.map((p) => p.id), [
      'kupu',
      'ikan',
      'kucing',
      'gajah',
      'dino',
      'hantu',
      'rumah',
      'mobil',
      'bunga',
      'roket',
      'kapal',
      'kue',
      'pelangi',
      'eskrim',
    ]);
    final kupu = c.byId('kupu')!;
    expect(kupu.contoh[0], '#BDE7FF');
    expect(c.byId('ikan')!.contoh, isNotEmpty);
    expect(c.byId('rumah')!.contoh, isNotEmpty);
    expect(c.byId('pelangi')!.contoh, isNotEmpty);
    expect(c.byId('kucing')!.contoh, isEmpty);
    expect(kupu.bagian.any((b) => b.detail.isNotEmpty), isTrue);
    expect(kupu.bagian.first.d, 'M0 0H800V600H0Z');
  });

  test('tulisan berkas stabil', () {
    final isi = File('${out.path}/content/katalog.json').readAsStringSync();
    expect(isi.endsWith('\n'), isTrue);
    expect(isi.split('\n')[1].startsWith(' "'), isTrue);
  });

  test('huruf memakai gambar katalog dan dua bahasa', () {
    final k = Katalog.fromJson(_baca(out, 'content/katalog.json'));
    final a = k.huruf.first;
    expect((a.huruf, a.id.kata, a.en.kata), ('A', 'Apel', 'Apple'));
    expect((a.id.gambar, a.en.gambar), ('apel', 'apel'));
    expect(k.huruf.firstWhere((e) => e.huruf == 'V').en.gambar, 'vas');
  });
}
