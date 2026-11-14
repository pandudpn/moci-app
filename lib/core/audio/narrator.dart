import '../lang.dart';
import 'asset_catalog.dart';
import 'audio_service.dart';
import 'dev_tts.dart';

final class NarrationLine {
  const NarrationLine({
    required this.jenis,
    required this.id,
    required this.text,
  });

  /// Awalan berkas rekaman, misalnya `nama` atau `ui`.
  final String jenis;
  final String id;

  /// Teks yang dibacakan TTS dev kalau rekaman belum ada.
  final String text;
}

final class Narrator {
  Narrator({
    required this._audio,
    required this._assets,
    required this._tts,
    required this._allowTts,
  });

  final AudioService _audio;
  final AssetCatalog _assets;
  final DevTts _tts;
  final bool _allowTts;
  int _gen = 0;

  static String pathFor(NarrationLine line, AppLang lang) =>
      'assets/audio/vo/${lang.name}/${line.jenis}_${line.id}.m4a';

  Future<void> say(NarrationLine line, AppLang lang) async {
    final gen = ++_gen;
    await _cancelPlayback();
    if (gen != _gen) return;
    await _play(line, lang, wait: false);
  }

  Future<void> sayAll(List<NarrationLine> lines, AppLang lang) async {
    final gen = ++_gen;
    await _cancelPlayback();
    for (final line in lines) {
      if (gen != _gen) return;
      await _play(line, lang, wait: true);
    }
  }

  Future<void> stop() async {
    _gen++;
    await _cancelPlayback();
  }

  Future<void> _cancelPlayback() async {
    await _audio.stopNarration();
    await _tts.stop();
  }

  Future<void> _play(
    NarrationLine line,
    AppLang lang, {
    required bool wait,
  }) async {
    final path = pathFor(line, lang);
    if (_assets.has(path)) {
      final id = await _audio.narrate(path);
      if (wait && id != null) await _audio.narrationFinished(id);
    } else if (_allowTts) {
      await _tts.speak(line.text, lang);
    }
  }
}
