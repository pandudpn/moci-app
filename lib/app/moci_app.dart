import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/audio/audio_providers.dart';
import '../core/prefs/prefs_controller.dart';
import '../l10n/l10n.dart';
import 'theme/moci_theme.dart';

class MociApp extends ConsumerStatefulWidget {
  const MociApp({super.key});

  @override
  ConsumerState<MociApp> createState() => _MociAppState();
}

class _MociAppState extends ConsumerState<MociApp> {
  late final AppLifecycleListener _lifecycle;

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
    if (!mounted) return;
    if (ref.read(prefsProvider).music) {
      ref.read(audioServiceProvider).startMusic();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    return MaterialApp(
      onGenerateTitle: (c) => c.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: mociTheme(),
      locale: Locale(lang.name),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const SizedBox.shrink(),
    );
  }
}
