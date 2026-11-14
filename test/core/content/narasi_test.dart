import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/narasi.dart';
import 'package:moci/core/lang.dart';

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()),
);

Object? _arb(String bahasa) =>
    jsonDecode(File('l10n/app_$bahasa.arb').readAsStringSync());

List<BarisNarasi> _narasi() {
  final id = bacaArbNarasi(_arb('id'));
  final en = bacaArbNarasi(_arb('en'));
  return narasiDiharapkan(
    _katalog(),
    arbId: id.teks,
    arbEn: en.teks,
    kunciNarasi: {...id.kunci, ...en.kunci},
  );
}

BarisNarasi _satu(
  List<BarisNarasi> narasi, {
  required AppLang bahasa,
  required String jenis,
  required String id,
}) => narasi.singleWhere(
  (b) => b.bahasa == bahasa && b.jenis == jenis && b.id == id,
);

void main() {
  test('nama item ada dalam dua bahasa', () {
    final narasi = _narasi();
    final id = _satu(narasi, bahasa: AppLang.id, jenis: 'nama', id: 'kucing');
    expect(id.teks, 'Kucing');
    expect(id.path, 'assets/audio/vo/id/nama_kucing.m4a');
    final en = _satu(narasi, bahasa: AppLang.en, jenis: 'nama', id: 'kucing');
    expect(en.teks, 'Cat');
    expect(en.path, 'assets/audio/vo/en/nama_kucing.m4a');
  });

  test('angka 0-50 berjumlah 51 baris per bahasa', () {
    final narasi = _narasi();
    for (final bahasa in AppLang.values) {
      expect(
        narasi.where((b) => b.bahasa == bahasa && b.jenis == 'angka').length,
        51,
        reason: 'jumlah baris angka bahasa ${bahasa.name}',
      );
    }
    final duaPuluhSatu = narasi.singleWhere(
      (b) => b.bahasa == AppLang.id && b.path.endsWith('/angka_21.m4a'),
    );
    expect(duaPuluhSatu.teks, 'dua puluh satu');
  });

  test('fonik b memakai bunyi pendek dan bercatatan', () {
    final narasi = _narasi();
    final b = _satu(narasi, bahasa: AppLang.id, jenis: 'fonik', id: 'b');
    expect(b.teks, 'beh');
    expect(b.catatan, startsWith('bunyi pendek'));
    final nama = _satu(narasi, bahasa: AppLang.id, jenis: 'huruf', id: 'b');
    expect(nama.teks, 'be');
    expect(nama.catatan, 'nama huruf');
  });

  test('tidak ada path ganda', () {
    final narasi = _narasi();
    final jalur = [for (final b in narasi) b.path];
    final ganda = <String>{
      for (final p in jalur)
        if (jalur.where((l) => l == p).length > 1) p,
    };
    expect(ganda, isEmpty);
  });

  test('setiap bahasa punya lebih dari 500 baris', () {
    final narasi = _narasi();
    for (final bahasa in AppLang.values) {
      expect(
        narasi.where((b) => b.bahasa == bahasa).length,
        greaterThan(500),
        reason: 'jumlah narasi bahasa ${bahasa.name}',
      );
    }
  });

  test('kunci ARB bernarasi menjadi baris ui', () {
    final narasi = _narasi();
    final baris = _satu(
      narasi,
      bahasa: AppLang.id,
      jenis: 'ui',
      id: 'sambutanHalo',
    );
    expect(baris.teks, 'Halo! Aku Moci.');
    expect(baris.path, 'assets/audio/vo/id/ui_sambutanHalo.m4a');
  });

  test('suku kata unik huruf kecil dari kisi, kata, dan ucapkan', () {
    final narasi = _narasi();
    final suku = {
      for (final b in narasi)
        if (b.bahasa == AppLang.id && b.jenis == 'suku') b.id,
    };
    expect(suku, containsAll(['ba', 'bo', 'la', 'ku', 'cing']));
    expect(suku.where((s) => s != s.toLowerCase()), isEmpty);
  });
}
