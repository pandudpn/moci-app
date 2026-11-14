import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coloring.dart';
import 'katalog.dart';
import 'tracing.dart';

/// Memuat isi yang ikut terpasang di aplikasi dari bundel aset.
///
/// Tidak ada unduhan saat aplikasi berjalan: semua berkas sudah ada di bundel,
/// dan pemuat ini hanya membaca serta mengubahnya menjadi model.
final class ContentRepository {
  const ContentRepository._();

  static const katalogPath = 'assets/content/katalog.json';
  static const tracingHurufPath = 'assets/tracing/huruf.json';
  static const tracingAngkaPath = 'assets/tracing/angka.json';
  static const coloringPath = 'assets/coloring/pages.json';
  static const capPath = 'assets/coloring/cap.json';
  static const krayonPath = 'assets/coloring/krayon.json';

  static Future<Katalog> loadKatalog(AssetBundle bundle) async =>
      Katalog.fromJson(await _json(bundle, katalogPath));

  static Future<TracingSet> loadTracing(
    AssetBundle bundle, {
    required bool angka,
  }) async => TracingSet.fromJson(
    await _json(bundle, angka ? tracingAngkaPath : tracingHurufPath),
  );

  static Future<ColoringSet> loadColoring(AssetBundle bundle) async =>
      ColoringSet.fromJson(await _json(bundle, coloringPath));

  static Future<List<Cap>> loadCap(AssetBundle bundle) async {
    final nilai = await _json(bundle, capPath);
    return nilai is List
        ? [for (final e in nilai) Cap.fromJson(e)]
        : const <Cap>[];
  }

  static Future<List<Krayon>> loadKrayon(AssetBundle bundle) async {
    final nilai = await _json(bundle, krayonPath);
    return nilai is List
        ? [for (final e in nilai) Krayon.fromJson(e)]
        : const <Krayon>[];
  }

  static Future<Object?> _json(AssetBundle bundle, String path) async =>
      jsonDecode(await bundle.loadString(path)) as Object?;
}

/// Katalog isi. Diisi `runMoci` sebelum aplikasi dijalankan.
final katalogProvider = Provider<Katalog>(
  (ref) => throw UnimplementedError('katalogProvider dioverride di runMoci'),
);

/// Panduan menulis huruf. Diisi `runMoci` sebelum aplikasi dijalankan.
final tracingHurufProvider = Provider<TracingSet>(
  (ref) =>
      throw UnimplementedError('tracingHurufProvider dioverride di runMoci'),
);

/// Panduan menulis angka. Diisi `runMoci` sebelum aplikasi dijalankan.
final tracingAngkaProvider = Provider<TracingSet>(
  (ref) =>
      throw UnimplementedError('tracingAngkaProvider dioverride di runMoci'),
);
