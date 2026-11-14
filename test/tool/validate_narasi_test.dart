import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/hadiah/stiker.dart';

import '../../tool/konten/validasi/laporan.dart';
import '../../tool/validate_content.dart';

const _headerLisensi = 'file,sumber,URL,lisensi,tanggal unduh,catatan';

/// Menyalin fixture mini ke folder sementara, lalu menambah 30 stiker asli
/// supaya aturan `referensi_gambar_ada` juga lolos.
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

File _tulis(Directory root, String jalur, String isi) {
  final file = File('${root.path}/$jalur');
  file.parent.createSync(recursive: true);
  return file..writeAsStringSync(isi);
}

List<String> _pesan(Laporan laporan, String aturan) => [
  for (final catatan in [...laporan.galatList, ...laporan.peringatanList])
    if (catatan.aturan == aturan) catatan.pesan,
];

List<String> _galat(Laporan laporan, String aturan) => [
  for (final catatan in laporan.galatList)
    if (catatan.aturan == aturan) catatan.pesan,
];

void main() {
  test('audio yang belum direkam hanya memperingatkan di mode biasa', () async {
    final root = siapkan();
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_pesan(laporan, 'narasi_lengkap'), isNotEmpty);
    expect(_galat(laporan, 'narasi_lengkap'), isEmpty);
    expect(laporan.adaGalat, isFalse, reason: laporan.ringkasan());
  });

  test('mode rilis menggagalkan narasi yang belum direkam', () async {
    final root = siapkan();
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root, rilis: true);
    expect(_galat(laporan, 'narasi_lengkap'), isNotEmpty);
    expect(_galat(laporan, 'suara_hewan_lengkap'), isNotEmpty);
  });

  test('naskah memuat semua baris yang belum direkam', () async {
    final root = siapkan();
    addTearDown(() => root.deleteSync(recursive: true));
    final naskah = File('${root.path}/build/naskah.csv');
    final laporan = await validasiKonten(root: root, naskahKeluar: naskah);
    expect(laporan.adaGalat, isFalse, reason: laporan.ringkasan());
    final isi = naskah.readAsLinesSync();
    expect(isi.first, 'file,bahasa,teks,catatan');
    expect(isi, contains('vo/id/nama_apel.m4a,id,Apel,'));
    expect(isi, contains('vo/en/nama_apel.m4a,en,Apple,'));
    expect(isi, contains('vo/id/nama_kucing.m4a,id,Kucing,'));
    expect(isi, isNot(contains('assets/audio/vo/id/nama_apel.m4a')));
  });

  test('narasi yang sudah direkam tidak masuk naskah', () async {
    final root = siapkan(
      rusak: (r) => _tulis(r, 'assets/audio/vo/id/nama_apel.m4a', ''),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final naskah = File('${root.path}/build/naskah.csv');
    await validasiKonten(root: root, naskahKeluar: naskah);
    expect(
      naskah.readAsLinesSync(),
      isNot(contains('vo/id/nama_apel.m4a,id,Apel,')),
    );
  });

  test('teks dengan koma dikutip di naskah', () async {
    final root = siapkan(
      rusak: (r) => _ubahJson(r, 'assets/content/katalog.json', (isi) {
        final kalimat = (isi['kalimat']! as List).cast<Map<String, Object?>>();
        final teks = kalimat.first['teks']! as Map<String, Object?>;
        teks['id'] = 'Ini bola, ya.';
      }),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final naskah = File('${root.path}/build/naskah.csv');
    await validasiKonten(root: root, naskahKeluar: naskah);
    final isi = naskah.readAsLinesSync();
    expect(
      isi,
      contains(
        'vo/id/kalimat_bola.m4a,id,"Ini bola, ya.",'
        'tempo pelan; waktu mulai tiap kata dicatat untuk karaoke',
      ),
    );
  });

  test(
    'audio eksternal tanpa baris lisensi adalah galat di mode biasa',
    () async {
      final root = siapkan(
        rusak: (r) => _tulis(r, 'assets/audio/hewan/kucing.m4a', ''),
      );
      addTearDown(() => root.deleteSync(recursive: true));
      final laporan = await validasiKonten(root: root);
      expect(
        _pesan(laporan, 'lisensi_audio_lengkap').join(),
        contains('kucing'),
      );
      expect(laporan.adaGalat, isTrue);
    },
  );

  test('baris CC0 dan Milik sendiri meloloskan lisensi', () async {
    final root = siapkan(
      rusak: (r) {
        _tulis(r, 'assets/audio/hewan/kucing.m4a', '');
        _tulis(r, 'assets/audio/sfx/klik.wav', '');
        _tulis(
          r,
          'assets/audio/LICENSES.csv',
          '$_headerLisensi\n'
              'hewan/kucing.m4a,Freesound,https://example.test/1,CC0,'
              '2026-11-14,\n'
              'sfx/klik.wav,Rekaman sendiri,,Milik sendiri,2026-11-14,\n',
        );
      },
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    expect(_galat(laporan, 'lisensi_audio_lengkap'), isEmpty);
    expect([
      for (final catatan in laporan.lolosList) catatan.aturan,
    ], contains('lisensi_audio_lengkap'));
  });

  test('lisensi Pixabay dan CC BY 4.0 ditolak', () async {
    final root = siapkan(
      rusak: (r) {
        _tulis(r, 'assets/audio/musik/latar.wav', '');
        _tulis(r, 'assets/audio/instrumen/gitar.wav', '');
        _tulis(
          r,
          'assets/audio/LICENSES.csv',
          '$_headerLisensi\n'
              'musik/latar.wav,Pixabay,https://example.test/2,Pixabay,'
              '2026-11-14,\n'
              'instrumen/gitar.wav,Freesound,https://example.test/3,'
              'CC BY 4.0,2026-11-14,\n',
        );
      },
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root);
    final pesan = _galat(laporan, 'lisensi_audio_lengkap').join('/');
    expect(pesan, contains('Pixabay'));
    expect(pesan, contains('CC BY 4.0'));
    expect(laporan.adaGalat, isTrue);
  });

  test('anggaran audio ditegakkan', () async {
    final root = siapkan(
      rusak: (r) => _tulis(r, 'assets/audio/vo/id/nama_apel.m4a', 'x' * 64),
    );
    addTearDown(() => root.deleteSync(recursive: true));
    final laporan = await validasiKonten(root: root, batasAudioByte: 10);
    expect(_pesan(laporan, 'anggaran_audio'), isNotEmpty);
  });
}
