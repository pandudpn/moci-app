import 'dart:convert';
import 'dart:io';

import 'package:moci/core/content/content_repository.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/storage/key_value_store.dart';

import 'harness.dart';

Katalog? _katalog;

/// Katalog asli untuk tes, dibaca sekali per proses tes.
Katalog katalogUji() => _katalog ??= Katalog.fromJson(
  jsonDecode(File(ContentRepository.katalogPath).readAsStringSync()) as Object?,
);

/// Lingkungan tes dengan tingkat usia tertentu lewat kunci `moci.usia`.
TestEnv envUsia(AgeLevel level) {
  final store = MemoryKeyValueStore()
    ..setString('moci.usia', switch (level) {
      AgeLevel.pemula => '2-3',
      AgeLevel.penjelajah => '4-5',
      AgeLevel.pembaca => '6-7',
    });
  return TestEnv(store: store);
}
