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
}
