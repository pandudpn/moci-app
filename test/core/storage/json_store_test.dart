import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress_repository.dart';
import 'package:moci/core/storage/json_store.dart';

void main() {
  late Directory dir;
  late FileJsonStore store;
  setUp(() {
    dir = Directory.systemTemp.createTempSync('moci');
    store = FileJsonStore(dir);
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('tulis lalu baca', () async {
    await store.write('progress.json', {'versi': 1, 'bintang': 3});
    expect(await store.read('progress.json'), {'versi': 1, 'bintang': 3});
    expect(File('${dir.path}/progress.json.tmp').existsSync(), isFalse);
  });
  test('file .tmp sisa crash diabaikan', () async {
    await store.write('progress.json', {'versi': 1, 'bintang': 5});
    File('${dir.path}/progress.json.tmp')
        .writeAsStringSync('{"versi": 1, "bin');
    expect((await store.read('progress.json'))!['bintang'], 5);
  });
  test('file rusak dipindah, lalu tulis ulang berhasil', () async {
    File('${dir.path}/progress.json')
        .writeAsStringSync('{"versi": 1, "bintang": 2');
    expect(await store.read('progress.json'), isNull);
    expect(
      dir
          .listSync()
          .map((e) => e.path)
          .any((p) => p.contains('progress.json.rusak-')),
      isTrue,
    );
    await store.write('progress.json', {'versi': 1});
    expect(await store.read('progress.json'), {'versi': 1});
  });
  test('isi bukan objek dianggap rusak', () async {
    File('${dir.path}/progress.json').writeAsStringSync('[1, 2]');
    expect(await store.read('progress.json'), isNull);
    expect(
      dir
          .listSync()
          .map((e) => e.path)
          .any((p) => p.contains('progress.json.rusak-')),
      isTrue,
    );
  });
  test('file tidak ada mengembalikan null', () async {
    expect(await store.read('tidak_ada.json'), isNull);
  });
  test('delete menghapus file', () async {
    await store.write('a.json', {'x': 1});
    await store.delete('a.json');
    expect(await store.read('a.json'), isNull);
    await store.delete('a.json');
  });
  test('list dan deleteAll', () async {
    await store.write('karya/b.json', {});
    await store.write('karya/a.json', {});
    expect(await store.list('karya'), ['a.json', 'b.json']);
    await store.deleteAll();
    expect(dir.listSync(), isEmpty);
  });
  test('list folder yang tidak ada kosong', () async {
    expect(await store.list('draf'), isEmpty);
  });
  test('utf-8 terpotong: baca null dan byte asli dikarantina', () async {
    final bytes = [...utf8.encode('{"versi": 1, "nama": "Ba'), 0xC3];
    final asli = File('${dir.path}/progress.json')..writeAsBytesSync(bytes);
    expect(asli.readAsBytesSync(), bytes);
    expect(await store.read('progress.json'), isNull);
    final karantina = dir.listSync().whereType<File>().where(
      (f) => f.path.contains('progress.json.rusak-'),
    );
    expect(karantina, hasLength(1));
    expect(karantina.single.readAsBytesSync(), bytes);
  });
  test('utf-8 terpotong: progres bawaan, bukan galat', () async {
    File('${dir.path}/progress.json')
        .writeAsBytesSync([...utf8.encode('{"versi": 1, "bin'), 0xE2, 0x9C]);
    final progres = await ProgressRepository(store).load();
    expect(progres.stars, 0);
    expect(progres.harian, isEmpty);
  });
}
