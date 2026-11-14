import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/audio/audio_providers.dart';
import '../core/prefs/prefs_controller.dart';
import '../l10n/l10n.dart';
import 'play_timer/play_timer_controller.dart';
import 'router.dart';
import 'theme/moci_theme.dart';

class MociApp extends ConsumerStatefulWidget {
  const MociApp({super.key});

  @override
  ConsumerState<MociApp> createState() => _MociAppState();
}

class _MociAppState extends ConsumerState<MociApp> {
  late final AppLifecycleListener _lifecycle;

  /// Istirahat sudah dibuka untuk `restDue` yang sedang berlaku.
  bool _restOpened = false;

  @override
  void initState() {
    super.initState();
    // Panggilan telepon masuk memicu inactive -> hidden mulai iOS.
    _lifecycle = AppLifecycleListener(
      onHide: _silence,
      onPause: _silence,
      onResume: _resume,
    );
    // Setelah frame pertama, supaya splash muncul tanpa menunggu mesin audio.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(audioBootProvider);
    });
  }

  void _silence() {
    ref.read(audioServiceProvider).stopAll();
    ref.read(narratorProvider).stop();
  }

  Future<void> _resume() async {
    // iOS: sesi harus diaktifkan lagi setelah interupsi (telepon, Siri).
    await ref.read(audioSessionProvider).usePlayback();
    // Aplikasi bisa sudah ke latar lagi selama menunggu sesi.
    if (!mounted ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    if (ref.read(prefsProvider).music) {
      unawaited(ref.read(audioServiceProvider).resumeMusic());
    }
  }

  /// Membuka Istirahat bila sudah waktunya, anak sedang di rute bermain, dan
  /// batas harian belum tercapai (Waktu Habis menang atas Istirahat).
  void _maybeRest() {
    if (!mounted) return;
    final timer = ref.read(playTimerProvider);
    if (!timer.restDue) {
      _restOpened = false;
      return;
    }
    if (_restOpened || timer.limitReached) return;
    final path = ref.read(currentPathProvider);
    if (routeKindOf(path) != RouteKind.play) return;
    _restOpened = true;
    ref.read(routerProvider).push(Routes.istirahat);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    ref.listen(playTimerProvider, (_, _) => _maybeRest());
    // Istirahat yang tertunda (anak di area orang tua, atau batas baru
    // dinaikkan) dibuka begitu anak kembali ke rute bermain. Ditunda satu
    // microtask: perubahan path datang dari notifikasi delegasi router.
    ref.listen(currentPathProvider, (before, after) {
      // Istirahat keluar dari tumpukan dengan cara apa pun (selesai, atau
      // dialihkan ke Waktu Habis): istirahat berikutnya boleh membuka lagi.
      if (before == Routes.istirahat && after != Routes.istirahat) {
        _restOpened = false;
      }
      scheduleMicrotask(_maybeRest);
    });
    return MaterialApp.router(
      onGenerateTitle: (c) => c.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: mociTheme(),
      locale: Locale(lang.name),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
