import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'progress.dart';
import 'progress_repository.dart';

final initialProgressProvider = Provider<Progress>((_) => const Progress());

final progressProvider = NotifierProvider<ProgressController, Progress>(
  ProgressController.new,
);

class ProgressController extends Notifier<Progress> {
  late ProgressRepository _repo;
  Future<void> _queue = Future.value();

  @override
  Progress build() {
    _repo = ProgressRepository(ref.read(jsonStoreProvider));
    return ref.read(initialProgressProvider);
  }

  String get _today => dateKey(ref.read(clockProvider).now());

  Progress _prune(Progress p) {
    final limit = dateKey(
      ref.read(clockProvider).now().subtract(const Duration(days: 6)),
    );
    bool keep(String k) => k.compareTo(limit) >= 0;
    return p.copyWith(
      playSeconds: {
        for (final e in p.playSeconds.entries)
          if (keep(e.key)) e.key: e.value,
      },
      harian: {
        for (final e in p.harian.entries)
          if (keep(e.key)) e.key: e.value,
      },
    );
  }

  /// Menerapkan perubahan ke state lalu menyimpan lewat antrean berurutan.
  Future<void> _commit(Progress Function(Progress) change) {
    final next = _prune(change(state));
    state = next;
    return _enqueue(() => _repo.save(next));
  }

  Future<void> _enqueue(Future<void> Function() job) {
    final result = _queue.then((_) => job());
    // Kegagalan satu simpanan tidak boleh memutus antrean.
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  DayStats _day(Progress p) => p.harian[_today] ?? const DayStats();

  Progress _withDay(Progress p, DayStats d) =>
      p.copyWith(harian: {...p.harian, _today: d});

  Future<void> setLastActivity(
    String route, [
    Map<String, String> params = const {},
  ]) => _commit((p) => p.copyWith(lastActivity: LastActivity(route, params)));

  Future<void> addStars(int n) => _commit((p) {
    final d = _day(p);
    return _withDay(
      p.copyWith(stars: p.stars + n),
      d.copyWith(stars: d.stars + n),
    );
  });

  Future<void> addSticker(String id) {
    if (state.stickers.contains(id)) return _enqueue(() async {});
    return _commit((p) {
      final d = _day(p);
      return _withDay(
        p.copyWith(stickers: [...p.stickers, id]),
        d.copyWith(stickers: d.stickers + 1),
      );
    });
  }

  Future<void> recordKarya() => _commit((p) {
    final d = _day(p);
    return _withDay(p, d.copyWith(karya: d.karya + 1));
  });

  Future<void> markItem(String modul, String metric, String itemId) {
    final already =
        (state.perkembangan[modul]?[metric] ?? const []).contains(itemId) &&
        (_day(state).items[modul] ?? const []).contains(itemId);
    if (already) return _enqueue(() async {});
    return _commit((p) {
      final modulMap = p.perkembangan[modul] ?? const <String, List<String>>{};
      final metricList = modulMap[metric] ?? const <String>[];
      final perk = {
        ...p.perkembangan,
        modul: {
          ...modulMap,
          metric: metricList.contains(itemId)
              ? metricList
              : [...metricList, itemId],
        },
      };
      final d = _day(p);
      final dayList = d.items[modul] ?? const <String>[];
      final items = {
        ...d.items,
        modul: dayList.contains(itemId) ? dayList : [...dayList, itemId],
      };
      return _withDay(p.copyWith(perkembangan: perk), d.copyWith(items: items));
    });
  }

  Future<void> setPlaySeconds(String date, int seconds) => _commit(
    (p) => p.copyWith(playSeconds: {...p.playSeconds, date: seconds}),
  );

  Future<void> reset() {
    state = const Progress();
    return _enqueue(_repo.delete);
  }
}
