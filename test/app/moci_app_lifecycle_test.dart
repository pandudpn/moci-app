import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_providers.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/audio/audio_session.dart';
import 'package:moci/core/providers.dart';
import 'package:moci/core/storage/key_value_store.dart';

import '../helpers/fake_audio.dart';

final class _FakeSession implements AudioSessionConfigurator {
  int calls = 0;

  @override
  Future<void> usePlayback() async => calls++;
}

void main() {
  testWidgets('resume mengaktifkan ulang sesi playback lalu memulai musik', (
    tester,
  ) async {
    final engine = FakeAudioEngine();
    final session = _FakeSession();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
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
    expect(session.calls, 1); // boot

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
    expect(engine.plays.where((p) => p.loop), hasLength(1));
  });
}
