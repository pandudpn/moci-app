import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/progress/progress_repository.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/json_store.dart';

import '../../helpers/fake_clock.dart';

final class _SlowStore implements JsonStore {
  final _inner = MemoryJsonStore();
  int active = 0;
  int maxActive = 0;

  @override
  Future<void> write(String path, Map<String, Object?> json) async {
    maxActive = ++active > maxActive ? active : maxActive;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await _inner.write(path, json);
    active--;
  }

  @override
  Future<Map<String, Object?>?> read(String path) => _inner.read(path);

  @override
  Future<void> delete(String path) => _inner.delete(path);

  @override
  Future<List<String>> list(String dir) => _inner.list(dir);

  @override
  Future<void> deleteAll() => _inner.deleteAll();
}

void main() {
  late MemoryJsonStore store;
  late FakeClock clock;
  late ProviderContainer container;

  setUp(() {
    store = MemoryJsonStore();
    clock = FakeClock(DateTime(2026, 11, 14, 9));
    container = ProviderContainer(
      overrides: [
        jsonStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(container.dispose);
  });

  ProgressController ctrl() => container.read(progressProvider.notifier);

  test('addStars menambah total dan harian, tersimpan', () async {
    await ctrl().addStars(3);
    final s = container.read(progressProvider);
    expect(s.stars, 3);
    expect(s.harian['2026-11-14']!.stars, 3);
    final loaded = await ProgressRepository(store).load();
    expect(loaded.toJson(), s.toJson());
  });

  test('addSticker mengabaikan duplikat', () async {
    await ctrl().addSticker('apel');
    await ctrl().addSticker('apel');
    final s = container.read(progressProvider);
    expect(s.stickers, ['apel']);
    expect(s.harian['2026-11-14']!.stickers, 1);
  });

  test('recordKarya menambah hitungan harian', () async {
    await ctrl().recordKarya();
    expect(container.read(progressProvider).harian['2026-11-14']!.karya, 1);
  });

  test('markItem tanpa duplikat', () async {
    await ctrl().markItem('huruf', 'dilihat', 'A');
    await ctrl().markItem('huruf', 'dilihat', 'A');
    final s = container.read(progressProvider);
    expect(s.perkembangan['huruf']!['dilihat'], ['A']);
    expect(s.harian['2026-11-14']!.items['huruf'], ['A']);
  });

  test('setLastActivity menyimpan rute dan param', () async {
    await ctrl().setLastActivity('/huruf/tulis', {'huruf': 'A'});
    final loaded = await ProgressRepository(store).load();
    expect(loaded.lastActivity!.route, '/huruf/tulis');
    expect(loaded.lastActivity!.params, {'huruf': 'A'});
  });

  test('hanya 7 tanggal terakhir disimpan', () async {
    for (var d = 6; d <= 14; d++) {
      final date = '2026-11-${d.toString().padLeft(2, '0')}';
      await ctrl().setPlaySeconds(date, d * 10);
    }
    final keys = container.read(progressProvider).playSeconds.keys.toList()
      ..sort();
    expect(keys, [
      for (var d = 8; d <= 14; d++) '2026-11-${d.toString().padLeft(2, '0')}',
    ]);
    expect(keys.length, 7);
  });

  test('harian lama dibuang saat simpan', () async {
    await ctrl().addStars(1);
    clock.current = DateTime(2026, 11, 22, 9);
    await ctrl().addStars(1);
    expect(container.read(progressProvider).harian.keys, ['2026-11-22']);
  });

  test('dua mutasi cepat tidak saling tumpang', () async {
    final f1 = ctrl().addStars(1);
    final f2 = ctrl().addStars(2);
    await Future.wait([f1, f2]);
    expect(container.read(progressProvider).stars, 3);
    expect((await store.read('progress.json'))!['bintang'], 3);
  });

  test('reset menghapus berkas dan state', () async {
    await ctrl().addStars(3);
    await ctrl().reset();
    expect(await store.read('progress.json'), isNull);
    expect(container.read(progressProvider).stars, 0);
  });

  test('penulisan tidak pernah tumpang tindih', () async {
    final slow = _SlowStore();
    final c = ProviderContainer(
      overrides: [
        jsonStoreProvider.overrideWithValue(slow),
        clockProvider.overrideWithValue(clock),
      ],
    );
    addTearDown(c.dispose);
    final n = c.read(progressProvider.notifier);
    await Future.wait([n.addStars(1), n.addStars(2), n.addStars(3)]);
    expect(slow.maxActive, 1);
    expect((await slow.read('progress.json'))!['bintang'], 6);
  });
}
