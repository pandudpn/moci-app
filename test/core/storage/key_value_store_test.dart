import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/storage/json_store.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('MemoryKeyValueStore', () {
    late MemoryKeyValueStore store;
    setUp(() => store = MemoryKeyValueStore());

    test('simpan dan baca tiga tipe', () async {
      await store.setString('moci.a', 'x');
      await store.setInt('moci.b', 7);
      await store.setBool('moci.c', true);
      expect(store.getString('moci.a'), 'x');
      expect(store.getInt('moci.b'), 7);
      expect(store.getBool('moci.c'), true);
      expect(store.getString('moci.tidakAda'), isNull);
    });
    test('remove dan clear', () async {
      await store.setString('moci.a', 'x');
      await store.setInt('moci.b', 7);
      await store.remove('moci.a');
      expect(store.getString('moci.a'), isNull);
      expect(store.getInt('moci.b'), 7);
      await store.clear();
      expect(store.getInt('moci.b'), isNull);
    });
  });

  group('SharedPrefsKeyValueStore', () {
    test('clear hanya menghapus kunci moci.', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({'lain': 'tetap'});
      final store = await SharedPrefsKeyValueStore.open();
      await store.setString('moci.bahasa', 'id');
      await store.setInt('moci.n', 2);
      await store.setBool('moci.f', true);
      expect(store.getString('moci.bahasa'), 'id');
      await store.clear();
      expect(store.getString('moci.bahasa'), isNull);
      expect(store.getInt('moci.n'), isNull);
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      expect(prefs.getString('lain'), 'tetap');
    });
  });

  group('MemoryJsonStore', () {
    late MemoryJsonStore store;
    setUp(() => store = MemoryJsonStore());

    test('tulis lalu baca', () async {
      await store.write('progress.json', {'versi': 1, 'bintang': 3});
      expect(await store.read('progress.json'), {'versi': 1, 'bintang': 3});
    });
    test('file tidak ada mengembalikan null', () async {
      expect(await store.read('x.json'), isNull);
    });
    test('delete', () async {
      await store.write('a.json', {'x': 1});
      await store.delete('a.json');
      expect(await store.read('a.json'), isNull);
    });
    test('list dan deleteAll', () async {
      await store.write('karya/b.json', {});
      await store.write('karya/a.json', {});
      expect(await store.list('karya'), ['a.json', 'b.json']);
      await store.deleteAll();
      expect(await store.list('karya'), isEmpty);
    });
  });
}
