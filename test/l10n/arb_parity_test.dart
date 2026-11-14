import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final id = _read('l10n/app_id.arb');
  final en = _read('l10n/app_en.arb');

  test('himpunan kunci sama persis', () {
    expect(_keys(en), _keys(id));
  });

  test('placeholder setiap kunci sama', () {
    for (final k in _keys(id)) {
      final pId =
          ((id['@$k'] as Map?)?['placeholders'] as Map?)?.keys.toSet() ??
          <String>{};
      final pEn =
          ((en['@$k'] as Map?)?['placeholders'] as Map?)?.keys.toSet() ??
          <String>{};
      expect(pEn, pId, reason: 'placeholder $k');
    }
  });

  test('tidak ada nilai kosong', () {
    for (final arb in [id, en]) {
      for (final k in _keys(arb)) {
        expect((arb[k] as String).trim(), isNotEmpty, reason: k);
      }
    }
  });

  test('penanda narasi sama di kedua file', () {
    bool narasi(Map<String, dynamic> arb, String k) =>
        (arb['@$k'] as Map?)?['description'] == 'narasi';
    for (final k in _keys(id)) {
      expect(narasi(en, k), narasi(id, k), reason: 'narasi $k');
    }
  });
}
