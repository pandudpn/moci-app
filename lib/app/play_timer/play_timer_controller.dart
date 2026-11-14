import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress.dart';
import '../../core/progress/progress_controller.dart';
import '../../core/providers.dart';
import '../router.dart';
import 'play_timer.dart';

/// Detak pengatur waktu. Tes menggantinya dengan detak manual.
final playTimerTicksProvider = Provider<Stream<void>>(
  (_) => Stream.periodic(const Duration(seconds: 1)),
);

final playTimerProvider = NotifierProvider<PlayTimerController, PlayTimerState>(
  PlayTimerController.new,
);

/// Detik terhitung antara dua simpanan ke `progress.json`.
const _saveEverySeconds = 30;

/// Menghitung waktu bermain (D14): hanya saat aplikasi terbuka di depan dan
/// rute saat ini rute bermain. Disimpan per tanggal.
class PlayTimerController extends Notifier<PlayTimerState> {
  late DateTime _lastTick;
  int _unsaved = 0;

  @override
  PlayTimerState build() {
    final now = ref.read(clockProvider).now();
    _lastTick = now;
    _unsaved = 0;

    final sub = ref.read(playTimerTicksProvider).listen((_) => _onTick());
    final lifecycle = AppLifecycleListener(onPause: _persist, onHide: _persist);
    ref.onDispose(() {
      sub.cancel();
      lifecycle.dispose();
    });
    // Batas dan pengingat berubah: hitung ulang saat itu juga, jadi
    // menaikkan batas langsung membuka blokir.
    ref.listen(
      prefsProvider.select((p) => (p.dailyLimitMinutes, p.restReminder)),
      (_, _) =>
          state = _apply(ref.read(clockProvider).now(), Duration.zero, false),
    );

    final date = dateKey(now);
    return _apply(
      now,
      Duration.zero,
      false,
      from: PlayTimerState(
        date: date,
        secondsToday: _stored(date),
        secondsSinceRest: 0,
        restDue: false,
        limitReached: false,
      ),
    );
  }

  int _stored(String date) => ref.read(progressProvider).playSeconds[date] ?? 0;

  PlayTimerState _apply(
    DateTime now,
    Duration elapsed,
    bool counting, {
    PlayTimerState? from,
  }) {
    final prefs = ref.read(prefsProvider);
    return tickPlayTimer(
      from ?? state,
      now: now,
      elapsed: elapsed,
      counting: counting,
      limitMinutes: prefs.dailyLimitMinutes,
      restReminder: prefs.restReminder,
      storedSecondsFor: _stored,
    );
  }

  /// Aplikasi di depan. `null` (awal jalan, tes) dianggap di depan.
  bool get _resumed {
    final s = WidgetsBinding.instance.lifecycleState;
    return s == null || s == AppLifecycleState.resumed;
  }

  void _onTick() {
    final clock = ref.read(clockProvider);
    final now = clock.now();
    final elapsed = now.difference(_lastTick);
    _lastTick = now;

    final counting =
        _resumed &&
        routeKindOf(ref.read(currentPathProvider)) == RouteKind.play;
    final prev = state;
    final next = _apply(now, elapsed, counting);

    if (next.date != prev.date) {
      // Hari berganti: simpan hasil akhir hari lama.
      ref
          .read(progressProvider.notifier)
          .setPlaySeconds(prev.date, prev.secondsToday);
      _unsaved = 0;
    } else {
      _unsaved += next.secondsToday - prev.secondsToday;
    }
    state = next;
    if (_unsaved >= _saveEverySeconds) _persist();
  }

  void _persist() {
    if (_unsaved == 0) return;
    _unsaved = 0;
    ref
        .read(progressProvider.notifier)
        .setPlaySeconds(state.date, state.secondsToday);
  }

  /// Istirahat selesai: hitung 20 menit berikutnya dari nol.
  void restTaken() {
    state = state.copyWith(secondsSinceRest: 0, restDue: false);
  }
}
