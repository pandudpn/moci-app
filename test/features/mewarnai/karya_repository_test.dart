import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/storage/json_store.dart';
import 'package:moci/features/mewarnai/karya_repository.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';

KaryaRepository _repo(MemoryJsonStore store, DateTime now) =>
    KaryaRepository(store, now: () => now);

const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A];

void main() {
  test('draf ditulis satu berkas per halaman', () async {
    final store = MemoryJsonStore();
    final repo = _repo(store, DateTime(2026, 11, 14, 10));
    await repo.simpanDraf(
      const KaryaData(halaman: 'kupu', isian: {1: '#FF4B4B'}),
    );
    final json = await store.read('draf/kupu.json');
    expect(json!['versi'], 1);
    expect(json['halaman'], 'kupu');
    expect((await repo.bacaDraf('kupu'))!.isian[1], '#FF4B4B');
    expect(await store.list('draf'), ['kupu.json']);
  });

  test('draf per halaman tidak saling menimpa', () async {
    final repo = _repo(MemoryJsonStore(), DateTime(2026, 11, 14, 10));
    await repo.simpanDraf(
      const KaryaData(halaman: 'kupu', isian: {1: '#FF4B4B'}),
    );
    await repo.simpanDraf(
      const KaryaData(halaman: 'ikan', isian: {2: '#1C7ED6'}),
    );
    expect((await repo.bacaDraf('kupu'))!.isian[1], '#FF4B4B');
    expect((await repo.bacaDraf('ikan'))!.isian[2], '#1C7ED6');
    expect((await repo.daftarDraf()).keys.toList(), ['ikan', 'kupu']);
  });

  test('karya menyimpan PNG base64 dan waktu', () async {
    final repo = _repo(MemoryJsonStore(), DateTime(2026, 11, 14, 10));
    final karya = await repo.simpanKarya(
      const KaryaData(halaman: 'kupu'),
      Uint8List.fromList(_png),
    );
    expect(karya.id, startsWith('k'));
    final json = await repo.bacaKaryaJson(karya.id);
    expect(json!['id'], karya.id);
    expect(base64Decode(json['gambar'] as String), _png);
    expect(json['waktu'], startsWith('2026-11-14T10:00'));
    expect(karya.png, _png);
  });

  test('karya terbaru lebih dulu', () async {
    final store = MemoryJsonStore();
    final pagi = _repo(store, DateTime(2026, 11, 14, 8));
    final sore = _repo(store, DateTime(2026, 11, 14, 16));
    await pagi.simpanKarya(const KaryaData(halaman: 'kupu'), Uint8List(0));
    await sore.simpanKarya(const KaryaData(halaman: 'ikan'), Uint8List(0));
    expect((await sore.daftarKarya()).map((k) => k.data.halaman), [
      'ikan',
      'kupu',
    ]);
  });

  test('karya ketiga belas menghapus yang tertua', () async {
    final store = MemoryJsonStore();
    final repo = _repo(store, DateTime(2026, 11, 14, 8));
    var hari = 1;
    for (var i = 0; i < 13; i++) {
      await KaryaRepository(
        store,
        now: () => DateTime(2026, 11, hari++),
      ).simpanKarya(
        KaryaData(halaman: 'kupu', isian: {i: '#FF4B4B'}),
        Uint8List(0),
      );
    }
    final daftar = await repo.daftarKarya();
    expect(daftar.length, 12);
    expect(await store.list('karya'), hasLength(12));
    expect(daftar.last.data.isian[1], '#FF4B4B');
  });

  test('berkas rusak tidak membuat galat', () async {
    final store = MemoryJsonStore();
    await store.write('draf/kupu.json', {'versi': 1});
    await store.write('karya/x.json', {'versi': 1, 'halaman': 7});
    final repo = _repo(store, DateTime(2026, 11, 14, 10));
    expect(await repo.bacaDraf('kupu'), isNull);
    expect(await repo.daftarKarya(), isEmpty);
  });

  test('dua simpan pada milidetik yang sama tidak saling menimpa', () async {
    final store = MemoryJsonStore();
    final repo = _repo(store, DateTime(2026, 11, 14, 10));
    final satu = await repo.simpanKarya(
      const KaryaData(halaman: 'kupu'),
      Uint8List(0),
    );
    final dua = await repo.simpanKarya(
      const KaryaData(halaman: 'ikan'),
      Uint8List(0),
    );
    expect(dua.id, '${satu.id}-1');
    expect(await store.list('karya'), hasLength(2));
    expect((await repo.daftarKarya()).map((k) => k.data.halaman).toSet(), {
      'kupu',
      'ikan',
    });
  });

  test('hapus karya menghapus berkasnya', () async {
    final store = MemoryJsonStore();
    final repo = _repo(store, DateTime(2026, 11, 14, 10));
    final k = await repo.simpanKarya(
      const KaryaData(halaman: 'kupu'),
      Uint8List(0),
    );
    await repo.hapusKarya(k.id);
    expect(await store.list('karya'), isEmpty);
  });
}
