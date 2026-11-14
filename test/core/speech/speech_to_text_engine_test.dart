import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/speech/speech_engine.dart';
import 'package:moci/core/speech/speech_to_text_engine.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Plugin `SpeechToText` palsu: mencatat urutan panggilan dan menjawab sesuai
/// keadaan yang diatur tes. `initialize` adalah satu-satunya jalur yang
/// memunculkan dialog izin sistem, jadi urutannya yang dipaku.
final class _PluginPalsu implements SpeechToText {
  _PluginPalsu({this.izin = false, this.berhasil = true});

  bool izin;
  bool berhasil;
  final urutan = <String>[];
  int initializeCount = 0;

  @override
  Future<bool> get hasPermission async {
    urutan.add('hasPermission');
    return izin;
  }

  @override
  Future<bool> initialize({
    SpeechErrorListener? onError,
    SpeechStatusListener? onStatus,
    debugLogging = false,
    Duration finalTimeout = SpeechToText.defaultFinalTimeout,
    List<SpeechConfigOption>? options,
  }) async {
    urutan.add('initialize');
    initializeCount++;
    return berhasil;
  }

  @override
  Future<List<LocaleName>> locales() async {
    urutan.add('locales');
    return [LocaleName('id_ID', 'Indonesia'), LocaleName('en_US', 'English')];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} tidak dipakai');
}

void main() {
  test(
    'prepare memanggil initialize sebelum memutuskan izin ditolak',
    () async {
      // Perangkat bersih: izin belum pernah ditentukan, jadi `hasPermission`
      // masih salah sampai dialog sistem muncul.
      final plugin = _PluginPalsu(izin: false, berhasil: false);
      final engine = SpeechToTextEngine(plugin: plugin);

      expect(await engine.prepare(AppLang.id), SpeechStatus.izinDitolak);
      expect(plugin.urutan.first, 'initialize');
      expect(plugin.initializeCount, 1);
    },
  );

  test('initialize gagal tanpa izin: izin ditolak', () async {
    final plugin = _PluginPalsu(izin: false, berhasil: false);
    final engine = SpeechToTextEngine(plugin: plugin);

    expect(await engine.prepare(AppLang.id), SpeechStatus.izinDitolak);
  });

  test('initialize gagal tapi izin ada: pengenalan tidak tersedia', () async {
    final plugin = _PluginPalsu(izin: true, berhasil: false);
    final engine = SpeechToTextEngine(plugin: plugin);

    expect(await engine.prepare(AppLang.id), SpeechStatus.tidakTersedia);
  });

  test('initialize berhasil dan izin ada: siap', () async {
    final plugin = _PluginPalsu(izin: true);
    final engine = SpeechToTextEngine(plugin: plugin);

    expect(await engine.prepare(AppLang.id), SpeechStatus.siap);
    expect(plugin.urutan.first, 'initialize');
  });

  test('izin dicabut setelah initialize: izin ditolak', () async {
    final plugin = _PluginPalsu(izin: true);
    final engine = SpeechToTextEngine(plugin: plugin);

    plugin.izin = false;
    expect(await engine.prepare(AppLang.id), SpeechStatus.izinDitolak);
  });
}
