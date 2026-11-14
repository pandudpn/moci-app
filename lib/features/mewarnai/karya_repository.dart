import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/storage/json_store.dart';
import 'mewarnai_model.dart';

/// Membaca dan menulis draf per halaman serta karya di folder aplikasi.
final class KaryaRepository {
  KaryaRepository(this._store, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const drafDir = 'draf';
  static const karyaDir = 'karya';

  final JsonStore _store;
  final DateTime Function() _now;

  Future<KaryaData?> bacaDraf(String halaman) =>
      _bacaBerkas('$drafDir/$halaman.json');

  Future<void> simpanDraf(KaryaData data) =>
      _store.write('$drafDir/${data.halaman}.json', data.toJson());

  Future<void> hapusDraf(String halaman) =>
      _store.delete('$drafDir/$halaman.json');

  Future<Map<String, KaryaData>> daftarDraf() async {
    final hasil = <String, KaryaData>{};
    for (final nama in await _store.list(drafDir)) {
      final data = await _bacaBerkas('$drafDir/$nama');
      if (data != null) hasil[data.halaman] = data;
    }
    return hasil;
  }

  /// Menulis karya beserta PNG-nya, lalu memangkas yang tertua sampai
  /// [batasKarya] berkas.
  Future<Karya> simpanKarya(KaryaData data, Uint8List png, {String? id}) async {
    final waktu = _now();
    final dasar = id ?? 'k${waktu.millisecondsSinceEpoch}';
    var kandidat = dasar;
    var urut = 0;
    while (await _store.read('$karyaDir/$kandidat.json') != null) {
      urut++;
      kandidat = '$dasar-$urut';
    }
    final karya = Karya(
      id: kandidat,
      data: data.copyWith(waktu: waktu),
      png: png,
    );
    await _store.write('$karyaDir/$kandidat.json', {
      ...karya.data.toJson(),
      'id': kandidat,
      'gambar': base64Encode(png),
    });
    await _pangkas();
    return karya;
  }

  Future<List<Karya>> daftarKarya() async {
    final hasil = <Karya>[];
    for (final nama in await _store.list(karyaDir)) {
      final json = await _store.read('$karyaDir/$nama');
      if (json == null) continue;
      final data = KaryaData.fromJson(json);
      if (data.halaman.isEmpty) continue;
      hasil.add(
        Karya(
          id: nama.endsWith('.json')
              ? nama.substring(0, nama.length - 5)
              : nama,
          data: data,
          png: _png(json['gambar']),
        ),
      );
    }
    hasil.sort((a, b) {
      final kiri = a.data.waktu ?? DateTime.fromMillisecondsSinceEpoch(0);
      final kanan = b.data.waktu ?? DateTime.fromMillisecondsSinceEpoch(0);
      return kanan.compareTo(kiri);
    });
    return hasil;
  }

  Future<void> hapusKarya(String id) => _store.delete('$karyaDir/$id.json');

  /// Isi berkas karya apa adanya, untuk tes.
  @visibleForTesting
  Future<Map<String, Object?>?> bacaKaryaJson(String id) =>
      _store.read('$karyaDir/$id.json');

  Future<void> _pangkas() async {
    final daftar = await daftarKarya();
    for (var i = batasKarya; i < daftar.length; i++) {
      await _store.delete('$karyaDir/${daftar[i].id}.json');
    }
  }

  Future<KaryaData?> _bacaBerkas(String path) async {
    final json = await _store.read(path);
    if (json == null) return null;
    final data = KaryaData.fromJson(json);
    return data.halaman.isEmpty ? null : data;
  }

  static Uint8List _png(Object? gambar) {
    if (gambar is! String || gambar.isEmpty) return Uint8List(0);
    try {
      return base64Decode(gambar);
    } on FormatException {
      return Uint8List(0);
    }
  }
}
