import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/play_timer/play_timer_controller.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_providers.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/audio/audio_session.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/json_store.dart';
import 'package:moci/core/storage/key_value_store.dart';

import '../helpers/fake_audio.dart';

final class _FakeSession implements AudioSessionConfigurator {
  int calls = 0;

  @override
  Future<void> usePlayback() async => calls++;
}

Future<(FakeAudioEngine, _FakeSession)> _pumpApp(WidgetTester tester) async {
  final engine = FakeAudioEngine();
  final session = _FakeSession();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        jsonStoreProvider.overrideWithValue(MemoryJsonStore()),
        playTimerTicksProvider.overrideWithValue(const Stream<void>.empty()),
        audioEngineProvider.overrideWithValue(engine),
        audioSessionProvider.overrideWithValue(session),
        devTtsProvider.overrideWithValue(FakeDevTts()),
        assetCatalogProvider.overrideWithValue(
          const AssetCatalog({AudioService.musicAsset}),
        ),
      ],
      child: const MociApp(),
    ),
  );
  await tester.pump();
  return (engine, session);
}

void _pauseAndResume(WidgetTester tester) {
  final b = tester.binding;
  b.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  b.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  b.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  b.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  b.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

void main() {
  testWidgets('resume tidak memulai musik yang belum pernah diminta', (
    tester,
  ) async {
    final (engine, session) = await _pumpApp(tester);
    _pauseAndResume(tester);
    await tester.pump();
    await tester.pump();
    expect(session.calls, 2);
    expect(engine.plays.where((p) => p.loop), isEmpty);
  });

  testWidgets('resume mengaktifkan ulang sesi lalu melanjutkan musik', (
    tester,
  ) async {
    final (engine, session) = await _pumpApp(tester);
    expect(session.calls, 1); // boot
    // Beranda meminta musik (R4).
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MociApp)),
    );
    await container.read(audioServiceProvider).startMusic();
    await tester.pump();
    expect(engine.plays.where((p) => p.loop), hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(engine.stopAllCount, greaterThan(0));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();
    expect(session.calls, 2);
    expect(engine.plays.where((p) => p.loop), hasLength(2));
  });
}
