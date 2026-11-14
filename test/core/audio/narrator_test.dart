import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/audio/asset_catalog.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/audio/narrator.dart';
import 'package:moci/core/lang.dart';

import '../../helpers/fake_audio.dart';

const _kucing = NarrationLine(jenis: 'nama', id: 'kucing', text: 'Cat');
const _anjing = NarrationLine(jenis: 'nama', id: 'anjing', text: 'Dog');
const _kucingPath = 'assets/audio/vo/en/nama_kucing.m4a';
const _anjingPath = 'assets/audio/vo/en/nama_anjing.m4a';

void main() {
  late FakeAudioEngine engine;
  late FakeDevTts tts;

  Narrator build(Set<String> paths, {bool allowTts = true}) {
    final catalog = AssetCatalog(paths);
    return Narrator(
      audio: AudioService(engine: engine, assets: catalog),
      assets: catalog,
      tts: tts,
      allowTts: allowTts,
    );
  }

  setUp(() {
    engine = FakeAudioEngine();
    tts = FakeDevTts();
  });

  test('memutar rekaman kalau ada, tanpa TTS', () async {
    await build({_kucingPath}).say(_kucing, AppLang.en);
    expect(engine.plays.single.asset, _kucingPath);
    expect(tts.spoken, isEmpty);
  });

  test('tanpa rekaman dan TTS diizinkan: TTS bicara', () async {
    await build({}).say(_kucing, AppLang.en);
    expect(tts.spoken, [('Cat', AppLang.en)]);
    expect(engine.plays, isEmpty);
  });

  test('tanpa rekaman dan TTS tidak diizinkan: diam', () async {
    await build({}, allowTts: false).say(_kucing, AppLang.en);
    expect(tts.spoken, isEmpty);
    expect(engine.plays, isEmpty);
  });

  test('sayAll menunggu klip sebelumnya selesai', () async {
    final n = build({_kucingPath, _anjingPath});
    final done = n.sayAll([_kucing, _anjing], AppLang.en);
    await pumpEventQueue();
    expect(engine.plays.map((p) => p.asset), [_kucingPath]);
    engine.finish(engine.plays.first.id);
    await pumpEventQueue();
    expect(engine.plays.map((p) => p.asset), [_kucingPath, _anjingPath]);
    engine.finish(engine.plays.last.id);
    await done;
  });

  test('stop membatalkan urutan yang berjalan', () async {
    final n = build({_kucingPath, _anjingPath});
    final done = n.sayAll([_kucing, _anjing], AppLang.en);
    await pumpEventQueue();
    await n.stop();
    await done;
    expect(engine.plays, hasLength(1));
    expect(tts.stopCount, greaterThan(0));
  });

  test('say baru membatalkan urutan lama', () async {
    final n = build({_kucingPath, _anjingPath});
    final done = n.sayAll([_kucing, _anjing], AppLang.en);
    await pumpEventQueue();
    await n.say(_anjing, AppLang.en);
    await done;
    expect(engine.plays.map((p) => p.asset), [_kucingPath, _anjingPath]);
  });

  test('sayAll tanpa rekaman: TTS berurutan tanpa menunggu', () async {
    await build({}).sayAll([_kucing, _anjing], AppLang.en);
    expect(tts.spoken, [('Cat', AppLang.en), ('Dog', AppLang.en)]);
  });

  test(
    'sayAll tumpang-tindih pada rekaman sama: yang baru tetap bunyi',
    () async {
      final n = build({_kucingPath});
      final gate = engine.gates[_kucingPath] = Completer<void>();
      final f1 = n.sayAll([_kucing], AppLang.en);
      await pumpEventQueue();
      final f2 = n.sayAll([_kucing], AppLang.en);
      await pumpEventQueue();
      gate.complete();
      await f1;
      await pumpEventQueue();
      expect(engine.live.values, [_kucingPath]);
      engine.finish(engine.live.keys.single);
      await f2;
    },
  );
}
