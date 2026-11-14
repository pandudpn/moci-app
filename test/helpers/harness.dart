import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/app/theme/moci_theme.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_providers.dart';
import 'package:moci/core/audio/audio_session.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/json_store.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:moci/l10n/l10n.dart';

import 'fake_audio.dart';
import 'fake_clock.dart';

const tabletSize = Size(1180, 820);
const phoneSize = Size(844, 390);

/// Mengatur ukuran layar tes (piksel logis, rasio 1.0).
void useScreen(WidgetTester t, Size s, {EdgeInsets padding = EdgeInsets.zero}) {
  t.view.devicePixelRatio = 1.0;
  t.view.physicalSize = s;
  t.view.padding = FakeViewPadding(
    left: padding.left,
    top: padding.top,
    right: padding.right,
    bottom: padding.bottom,
  );
  t.view.viewPadding = t.view.padding;
  addTearDown(() {
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
    t.view.resetPadding();
    t.view.resetViewPadding();
  });
}

final class _NoopAudioSession implements AudioSessionConfigurator {
  @override
  Future<void> usePlayback() async {}
}

/// Semua dependensi tes sudah palsu: penyimpanan memori, jam tetap, mesin
/// audio siap, katalog aset kosong.
final class TestEnv {
  TestEnv({
    AppLang lang = AppLang.id,
    String childName = '',
    bool onboarded = true,
    this.progress = const Progress(),
    DateTime? now,
    this.assets = const {},
  }) : _lang = lang,
       clock = FakeClock(now ?? DateTime(2026, 11, 14, 10)) {
    store
      ..setString('moci.bahasa', lang.name)
      ..setString('moci.nama', childName)
      ..setBool('moci.sambutanSelesai', onboarded);
  }

  final AppLang _lang;
  final Progress progress;
  final Set<String> assets;

  final store = MemoryKeyValueStore();
  final json = MemoryJsonStore();
  final audio = FakeAudioEngine();
  final tts = FakeDevTts();
  final FakeClock clock;
  final ticks = StreamController<void>.broadcast();

  List<Override> get overrides => [
    keyValueStoreProvider.overrideWithValue(store),
    jsonStoreProvider.overrideWithValue(json),
    clockProvider.overrideWithValue(clock),
    deviceLocaleProvider.overrideWithValue(Locale(_lang.name)),
    initialProgressProvider.overrideWithValue(progress),
    audioEngineProvider.overrideWithValue(audio),
    assetCatalogProvider.overrideWithValue(AssetCatalog(assets)),
    devTtsProvider.overrideWithValue(tts),
    audioSessionProvider.overrideWithValue(_NoopAudioSession()),
  ];
}

/// Memasang [screen] dengan tema, l10n, dan penyimpanan palsu.
Future<void> pumpScreen(
  WidgetTester t,
  Widget screen, {
  TestEnv? env,
  Size size = tabletSize,
}) async {
  final e = env ?? TestEnv();
  addTearDown(e.ticks.close);
  useScreen(t, size);
  await t.pumpWidget(
    ProviderScope(
      overrides: e.overrides,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: mociTheme(),
          locale: Locale(ref.watch(prefsProvider.select((p) => p.lang)).name),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: screen,
        ),
      ),
    ),
  );
}
