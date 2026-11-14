import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/hadiah/stiker.dart';

import '../../tool/konten/validasi/laporan.dart';
import '../../tool/validate_content.dart';

/// Menyalin fixture mini ke folder sementara, lalu menambah 30 stiker asli
/// karena aturan `referensi_gambar_ada` juga memeriksa `stickerCatalog`.
Directory siapkan({void Function(Directory root)? rusak}) {
  final root = Directory.systemTemp.createTempSync('konten-uji');
  _salin(Directory('test/tool/fixtures/konten'), root);
  final ilustrasi = Directory('${root.path}/assets/illustrations')
    ..createSync(recursive: true);
  for (final id in stickerCatalog) {
    File('assets/illustrations/$id.svg').copySync('${ilustrasi.path}/$id.svg');
  }
  rusak?.call(root);
  return root;
}

void _salin(Directory asal, Directory tujuan) {
  for (final entri in asal.listSync(recursive: true)) {
    final jalur = entri.path.substring(asal.path.length + 1);
    if (entri is Directory) {
      Directory('${tujuan.path}/$jalur').createSync(recursive: true);
    } else if (entri is File) {
      File(entri.path).copySync('${tujuan.path}/$jalur');
    }
  }
}

void _ganti(Directory root, String jalur, String Function(String) ubah) {
  final file = File('${root.path}/$jalur');
  file.writeAsStringSync(ubah(file.readAsStringSync()));
}

/// Mengubah isi JSON di fixture lalu menulisnya kembali.
void _ubahJson(
  Directory root,
  String jalur,
  void Function(Map<String, Object?> isi) ubah,
) {
  final file = File('${root.path}/$jalur');
  final isi = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  ubah(isi);
  file.writeAsStringSync(jsonEncode(isi));
}

List<String> _pesan(Laporan laporan, String aturan) => [
  for (final catatan in [...laporan.galatList, ...laporan.peringatanList])
    if (catatan.aturan == aturan) catatan.pesan,
];

void main() {
  test('fixture bersih lolos tanpa galat', () async {
    final root = siapkan();
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(laporan.galatList, isEmpty, reason: laporan.ringkasan());
    expect(laporan.adaGalat, isFalse);
  });

  test('gambar yang hilang dilaporkan', () async {
    final root = siapkan(
      rusak: (r) =>
          File('${r.path}/assets/illustrations/apel.svg').deleteSync(),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'referensi_gambar_ada'), contains(contains('apel')));
  });

  test('svg dengan style ditolak', () async {
    final root = siapkan(
      rusak: (r) => _ganti(
        r,
        'assets/illustrations/bola.svg',
        (isi) => isi.replaceFirstMapped(
          RegExp(r'<svg[^>]*>'),
          (tag) => '${tag[0]}<style>.a{}</style>',
        ),
      ),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    final pesan = _pesan(laporan, 'svg_aturan');
    expect(pesan, isNotEmpty);
    expect(pesan.join(), contains('bola'));
  });

  test('tracing dengan perintah Q ditolak', () async {
    final root = siapkan(
      rusak: (r) => _ganti(
        r,
        'assets/tracing/huruf.json',
        (isi) => isi.replaceFirst('"M170 70V450"', '"M10 10Q20 20 30 30"'),
      ),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'tracing_perintah_didukung'), isNotEmpty);
  });

  test('id ganda ditolak', () async {
    final root = siapkan(
      rusak: (r) => _ubahJson(r, 'assets/content/katalog.json', (isi) {
        final item = (isi['item']! as List).cast<Map<String, Object?>>();
        item[1]['id'] = 'apel';
      }),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'id_unik'), isNotEmpty);
  });

  test('suku kata yang tidak menyusun kata ditolak', () async {
    final root = siapkan(
      rusak: (r) => _ubahJson(r, 'assets/content/katalog.json', (isi) {
        final kata = isi['kata']! as Map<String, Object?>;
        final id = (kata['id']! as List).cast<Map<String, Object?>>();
        id.first['suku'] = ['bo', 'le'];
      }),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'kata_utuh'), isNotEmpty);
  });

  test('anggaran ilustrasi ditegakkan', () async {
    final root = siapkan();
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root, batasIlustrasiByte: 10);
    expect(_pesan(laporan, 'anggaran_ilustrasi'), isNotEmpty);
  });

  test('halaman tanpa contoh hanya memperingatkan', () async {
    final root = siapkan(
      rusak: (r) => _ubahJson(r, 'assets/coloring/pages.json', (isi) {
        for (final page
            in (isi['halaman']! as List).cast<Map<String, Object?>>()) {
          page.remove('contoh');
        }
      }),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'mewarnai_contoh'), isNotEmpty);
    expect(laporan.adaGalat, isFalse, reason: laporan.ringkasan());
  });
}
