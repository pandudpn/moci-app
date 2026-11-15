import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/audio/sfx.dart';

import '../../helpers/fake_audio.dart';

void main() {
  late FakeAudioEngine engine;
  late AudioService svc;

  setUp(() {
    engine = FakeAudioEngine();
    svc = AudioService(
      engine: engine,
      assets: AssetCatalog({
        AudioService.musicAsset,
        Sfx.klik.asset,
        'assets/audio/vo/id/ui_a.m4a',
        'assets/audio/vo/id/ui_b.m4a',
      }),
    );
  });

  test('narasi baru menghentikan narasi lama', () async {
    final a = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    await svc.narrate('assets/audio/vo/id/ui_b.m4a');
    expect(engine.stopped, contains(a));
    expect(engine.plays.last.volume, 1.0);
  });

  test('musik turun ke 0,10 saat narasi lalu kembali 0,25', () async {
    await svc.startMusic();
    final music = engine.plays.single;
    expect((music.volume, music.loop), (0.25, true));
    final n = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    expect(engine.volumes[music.id], 0.10);
    engine.finish(n!);
    await pumpEventQueue();
    expect(engine.volumes[music.id], 0.25);
  });

  test('efek 0,7 dan bisa dimatikan', () async {
    await svc.playSfx(Sfx.klik);
    expect(engine.plays.single.volume, 0.7);
    svc.applySettings(music: true, sfx: false);
    await svc.playSfx(Sfx.klik);
    expect(engine.plays, hasLength(1));
  });

  test('musik dimatikan menghentikan musik', () async {
    await svc.startMusic();
    svc.applySettings(music: false, sfx: true);
    expect(engine.stopped, contains(engine.plays.single.id));
  });

  test('aset tidak ada tidak diputar', () async {
    expect(await svc.narrate('assets/audio/vo/id/ui_tidak_ada.m4a'), isNull);
    expect(engine.plays, isEmpty);
  });

  test('stopAll saat ke latar belakang', () async {
    await svc.startMusic();
    await svc.stopAll();
    expect(engine.stopAllCount, 1);
  });

  test('narasi dilepas setelah selesai', () async {
    final n = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    engine.finish(n!);
    await pumpEventQueue();
    expect(engine.released, contains('assets/audio/vo/id/ui_a.m4a'));
  });

  test('narasi dilepas saat dihentikan', () async {
    await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    await svc.stopNarration();
    expect(engine.released, contains('assets/audio/vo/id/ui_a.m4a'));
  });

  test('musik dilanjutkan ke 0,25 setelah narasi dihentikan', () async {
    await svc.startMusic();
    final music = engine.plays.single;
    await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    await svc.stopNarration();
    expect(engine.volumes[music.id], 0.25);
  });

  test('musik dimulai saat narasi berjalan langsung 0,10', () async {
    await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    await svc.startMusic();
    expect(engine.plays.last.volume, 0.10);
  });

  test('preloadSfx memuat semua efek sekali', () async {
    await svc.preloadSfx();
    // Hanya aset yang ada di katalog yang dimuat.
    expect(engine.preloaded, [Sfx.klik.asset]);
  });

  test('sebelum mesin siap, permintaan putar diabaikan', () async {
    engine.ready = false;
    expect(await svc.narrate('assets/audio/vo/id/ui_a.m4a'), isNull);
    await svc.playSfx(Sfx.klik);
    await svc.startMusic();
    expect(engine.plays, isEmpty);
  });

  test('aset gagal dimuat tidak memicu ducking', () async {
    await svc.startMusic();
    final music = engine.plays.single;
    engine.failing.add('assets/audio/vo/id/ui_a.m4a');
    expect(await svc.narrate('assets/audio/vo/id/ui_a.m4a'), isNull);
    expect(engine.volumes[music.id], 0.25);
  });

  test('stopAll membersihkan ducking dan musik bisa dimulai lagi', () async {
    await svc.startMusic();
    await svc.narrate('assets/audio/vo/id/ui_a.m4a');
    await svc.stopAll();
    await svc.startMusic();
    expect(engine.plays.last.volume, 0.25);
  });

  group('narasi tumpang-tindih', () {
    const a = 'assets/audio/vo/id/ui_a.m4a';

    test(
      'narasi aset sama yang menyusul tidak dimatikan oleh yang basi',
      () async {
        await svc.startMusic();
        final music = engine.plays.single;
        final gate = engine.gates[a] = Completer<void>();
        final first = svc.narrate(a);
        await pumpEventQueue();
        final second = svc.narrate(a);
        await pumpEventQueue();
        gate.complete();
        expect(await first, isNull);
        final id = await second;
        expect(id, isNotNull);
        expect(engine.isLive(id!), isTrue);
        expect(engine.volumes[music.id], 0.10);
        final done = svc.narrationFinished(id);
        engine.finish(id);
        await done;
        await pumpEventQueue();
        expect(engine.volumes[music.id], 0.25);
        expect(engine.released, contains(a));
      },
    );

    test('panggilan yang menyusul selalu menang', () async {
      const b = 'assets/audio/vo/id/ui_b.m4a';
      final lama = await svc.narrate(a);
      // Hentian narasi lama ditahan: panggilan pertama parkir di tengah.
      final gate = engine.stopGates[lama!] = Completer<void>();
      final basi = svc.narrate(b);
      await pumpEventQueue();
      final baru = await svc.narrate(a);
      expect(baru, isNotNull);
      gate.complete();
      expect(await basi, isNull);
      await pumpEventQueue();
      // Yang tersisa hanya narasi terakhir.
      expect(engine.live.values, [a]);
      final selesai = svc.narrationFinished(baru!);
      engine.finish(baru);
      await selesai;
    });
  });

  group('startMusic dengan pemuatan lambat', () {
    late Completer<void> gate;
    setUp(() => gate = engine.gates[AudioService.musicAsset] = Completer());

    test('stopAll saat memuat: musik tidak menyala setelahnya', () async {
      final start = svc.startMusic();
      await pumpEventQueue();
      await svc.stopAll();
      gate.complete();
      await start;
      await pumpEventQueue();
      expect(engine.live, isEmpty);
    });

    test(
      'stopAll lalu startMusic selagi muatan pertama jalan: musik menyala',
      () async {
        final first = svc.startMusic();
        await pumpEventQueue();
        await svc.stopAll();
        final second = svc.startMusic();
        await pumpEventQueue();
        gate.complete();
        await Future.wait([first, second]);
        await pumpEventQueue();
        expect(engine.live.values, [AudioService.musicAsset]);
      },
    );

    test('narasi mulai selama memuat: musik 0,10', () async {
      final start = svc.startMusic();
      await pumpEventQueue();
      await svc.narrate('assets/audio/vo/id/ui_a.m4a');
      gate.complete();
      await start;
      await pumpEventQueue();
      final music = engine.plays.firstWhere((p) => p.loop);
      expect(engine.volumes[music.id], 0.10);
    });

    test('narasi selesai selama memuat: musik 0,25', () async {
      final n = await svc.narrate('assets/audio/vo/id/ui_a.m4a');
      final start = svc.startMusic();
      await pumpEventQueue();
      engine.finish(n!);
      await pumpEventQueue();
      gate.complete();
      await start;
      await pumpEventQueue();
      final music = engine.plays.firstWhere((p) => p.loop);
      expect(engine.volumes[music.id], 0.25);
    });

    test('stopMusic saat memuat: musik tidak menyala', () async {
      final start = svc.startMusic();
      await pumpEventQueue();
      await svc.stopMusic();
      gate.complete();
      await start;
      await pumpEventQueue();
      expect(engine.live, isEmpty);
    });
  });

  group('jeda untuk mendengar', () {
    test(
      'pauseForListening menghentikan musik, resume memulainya lagi',
      () async {
        final engine = FakeAudioEngine();
        final service = AudioService(
          engine: engine,
          assets: AssetCatalog({AudioService.musicAsset}),
        );
        await engine.init();
        await service.startMusic();
        expect(engine.live.values, contains(AudioService.musicAsset));

        await service.pauseForListening();
        expect(engine.live, isEmpty);

        await service.resumeAfterListening();
        expect(engine.live.values, contains(AudioService.musicAsset));
      },
    );

    test('narasi yang dimulai saat jeda tetap jalan, musik tidak', () async {
      final engine = FakeAudioEngine();
      final service = AudioService(
        engine: engine,
        assets: AssetCatalog({
          AudioService.musicAsset,
          'assets/audio/vo/id/ui_a.m4a',
        }),
      );
      await engine.init();
      await service.startMusic();
      await service.pauseForListening();

      await service.narrate('assets/audio/vo/id/ui_a.m4a');
      expect(engine.live.values, ['assets/audio/vo/id/ui_a.m4a']);

      await service.resumeAfterListening();
      expect(engine.live.values, contains(AudioService.musicAsset));
    });

    test('musik tidak dimulai kalau sakelar musik mati', () async {
      final engine = FakeAudioEngine();
      final service = AudioService(
        engine: engine,
        assets: AssetCatalog({AudioService.musicAsset}),
      );
      await engine.init();
      service.applySettings(music: false, sfx: true);
      await service.startMusic();
      await service.pauseForListening();
      await service.resumeAfterListening();
      expect(engine.live, isEmpty);
    });
  });

  testWidgets('kelima efek suara ikut di bundel', (t) async {
    final assets = await AssetCatalog.load(rootBundle);
    for (final s in Sfx.values) {
      expect(assets.has(s.asset), isTrue, reason: s.asset);
    }
  });
}
