import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/play_timer/play_timer_controller.dart';
import 'package:moci/app/router.dart';
import 'package:moci/app/theme/moci_theme.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_providers.dart';
import 'package:moci/core/audio/audio_session.dart';
import 'package:moci/core/content/content_repository.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/tracing.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/json_store.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:moci/l10n/l10n.dart';

import 'fake_audio.dart';
import 'fake_clock.dart';

/// Katalog asli untuk tes, dibaca sekali per proses tes.
Katalog? _katalog;

Katalog _katalogUji() => _katalog ??= Katalog.fromJson(
  jsonDecode(File(ContentRepository.katalogPath).readAsStringSync()) as Object?,
);

TracingSet? _tracingHurufUji;
TracingSet? _tracingAngkaUji;

TracingSet _tracingUji({required bool angka}) {
  final cache = angka ? _tracingAngkaUji : _tracingHurufUji;
  if (cache != null) return cache;
  final set = TracingSet.fromJson(
    jsonDecode(
      File(
        angka
            ? ContentRepository.tracingAngkaPath
            : ContentRepository.tracingHurufPath,
      ).readAsStringSync(),
    ) as Object?,
  );
  if (angka) {
    _tracingAngkaUji = set;
  } else {
    _tracingHurufUji = set;
  }
  return set;
}

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

/// Penyimpanan uji yang bisa menahan dan menghitung penulisan.
final class GatedKeyValueStore implements KeyValueStore {
  GatedKeyValueStore(this.inner);

  final KeyValueStore inner;

  /// Bila ada, tiap penulisan menunggu gerbang ini dulu.
  Completer<void>? gerbang;

  /// Penulisan yang selalu gagal.
  bool gagal = false;

  /// Jumlah penulisan per kunci, termasuk yang ditahan.
  final tulis = <String, int>{};

  int tulisKe(String key) => tulis[key] ?? 0;

  /// Semua penulisan yang sudah dimulai.
  int get total => tulis.values.fold(0, (a, b) => a + b);

  Future<void> _awal(String key) async {
    tulis[key] = tulisKe(key) + 1;
    final g = gerbang;
    if (g != null) await g.future;
    if (gagal) throw StateError('penyimpanan gagal');
  }

  @override
  String? getString(String key) => inner.getString(key);

  @override
  int? getInt(String key) => inner.getInt(key);

  @override
  bool? getBool(String key) => inner.getBool(key);

  @override
  Future<void> setString(String key, String value) async {
    await _awal(key);
    await inner.setString(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _awal(key);
    await inner.setInt(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _awal(key);
    await inner.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _awal(key);
    await inner.remove(key);
  }

  @override
  Future<void> clear() async {
    await _awal('*');
    await inner.clear();
  }
}

/// Semua dependensi tes sudah palsu: penyimpanan memori, jam tetap, mesin
/// audio siap, katalog aset kosong.
final class TestEnv {
  TestEnv({
    AppLang lang = AppLang.id,
    String childName = '',
    bool onboarded = true,
    LetterMode letterMode = LetterMode.fonik,
    this.progress = const Progress(),
    DateTime? now,
    this.assets = const {},
    this.extraOverrides = const [],
    KeyValueStore? store,
  }) : _lang = lang,
       store = store ?? MemoryKeyValueStore(),
       clock = FakeClock(now ?? DateTime(2026, 11, 14, 10)) {
    this.store
      ..setString('moci.bahasa', lang.name)
      ..setString('moci.nama', childName)
      ..setString('moci.caraBaca', letterMode.name)
      ..setBool('moci.sambutanSelesai', onboarded);
  }

  final AppLang _lang;
  final Progress progress;
  final Set<String> assets;

  /// Override tambahan milik tes (misalnya sumber acak).
  final List<Override> extraOverrides;

  final KeyValueStore store;
  final json = MemoryJsonStore();
  final audio = FakeAudioEngine();
  final tts = FakeDeviceTts();
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
    katalogProvider.overrideWithValue(_katalogUji()),
    tracingHurufProvider.overrideWithValue(_tracingUji(angka: false)),
    tracingAngkaProvider.overrideWithValue(_tracingUji(angka: true)),
    deviceTtsProvider.overrideWithValue(tts),
    audioSessionProvider.overrideWithValue(_NoopAudioSession()),
    playTimerTicksProvider.overrideWithValue(ticks.stream),
    ...extraOverrides,
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

/// Memasang aplikasi utuh (`MociApp`) dan mengembalikan routernya.
Future<GoRouter> pumpApp(
  WidgetTester t, {
  TestEnv? env,
  Size size = tabletSize,
  String? initialLocation,
}) async {
  final e = env ?? TestEnv();
  addTearDown(e.ticks.close);
  useScreen(t, size);
  await t.pumpWidget(
    ProviderScope(overrides: e.overrides, child: const MociApp()),
  );
  await t.pump();
  final router = ProviderScope.containerOf(t.element(find.byType(MociApp)))
      .read(routerProvider);
  if (initialLocation != null) {
    router.go(initialLocation);
    await t.pump();
    await t.pump();
  }
  return router;
}
