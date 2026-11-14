import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../audio/audio_session.dart';
import '../lang.dart';
import 'speech_engine.dart';

final speechEngineProvider = Provider<SpeechEngine>(
  (_) => SpeechToTextEngine(),
);

/// Pengenal ucapan `speech_to_text` yang selalu meminta mode di perangkat.
///
/// Tidak ada jalur yang boleh memakai pengenalan jaringan: `onDevice` selalu
/// benar, dan galat jaringan atau bahasa yang tidak didukung dijawab `null`
/// supaya layar bisa beralih ke pengukur level suara.
final class SpeechToTextEngine implements SpeechEngine {
  SpeechToTextEngine({SpeechToText? plugin, AudioSessionConfigurator? session})
    : _plugin = plugin ?? SpeechToText(),
      _session = session ?? const MethodChannelAudioSession();

  static const _cadangan = Duration(milliseconds: 300);

  /// Galat yang berarti pengenalan teks tidak tersedia untuk bahasa ini.
  static const _galatTidakTersedia = {
    'error_network',
    'error_language_not_supported',
    'error_server',
    'error_audio',
    'error_client',
  };

  /// Galat yang berarti giliran selesai tanpa kata yang cocok.
  static const _galatTanpaKata = {'error_no_match', 'error_speech_timeout'};

  final SpeechToText _plugin;
  final AudioSessionConfigurator _session;

  bool _siap = false;
  Completer<SpeechTurn?>? _aktif;
  String? _teksTerakhir;
  String? _galat;

  @override
  Future<bool> hasPermission() async {
    try {
      return await _plugin.hasPermission;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<SpeechStatus> prepare(AppLang lang) async {
    if (!await hasPermission()) return SpeechStatus.izinDitolak;
    if (!_siap) {
      final bool ok;
      try {
        ok = await _plugin.initialize(onError: _onError, onStatus: _onStatus);
      } catch (_) {
        return SpeechStatus.tidakTersedia;
      }
      if (!ok) return SpeechStatus.tidakTersedia;
      _siap = true;
    }
    return await _adaBahasa(lang)
        ? SpeechStatus.siap
        : SpeechStatus.tidakTersedia;
  }

  /// Lokal yang tidak bisa dibaca dianggap ada: [listen] tetap akan menjawab
  /// `null` kalau pengenalan ternyata tidak tersedia.
  Future<bool> _adaBahasa(AppLang lang) async {
    try {
      final locales = await _plugin.locales();
      final kode = lang == AppLang.en ? 'en' : 'id';
      return locales.any((l) => l.localeId.toLowerCase().startsWith(kode));
    } catch (_) {
      return true;
    }
  }

  @override
  Future<SpeechTurn?> listen({
    required String target,
    required AppLang lang,
    required Duration batas,
  }) async {
    await stop();
    final selesai = Completer<SpeechTurn?>();
    _aktif = selesai;
    _teksTerakhir = null;
    _galat = null;
    final timer = Timer(batas + _cadangan, () {
      final teks = _teksTerakhir;
      _tutup(
        teks == null
            ? const SpeechTurn(didengar: false)
            : SpeechTurn(didengar: true, teks: teks),
      );
    });
    try {
      final mulai = await _plugin.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          onDevice: true,
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
          contextualPhrases: [target],
          localeId: lang == AppLang.en ? 'en_US' : 'id_ID',
          listenFor: batas,
        ),
      );
      if (mulai != true) _tutup(null);
    } catch (_) {
      _tutup(null);
    }
    final hasil = await selesai.future;
    timer.cancel();
    try {
      await _plugin.stop();
    } catch (_) {
      // Sudah berhenti.
    }
    // Mikrofon selesai: sesi audio kembali ke playback untuk narasi dan musik.
    await _session.usePlayback();
    return hasil;
  }

  @override
  Future<void> stop() async {
    final aktif = _aktif;
    if (aktif != null && !aktif.isCompleted) {
      final teks = _teksTerakhir;
      _tutup(
        teks == null
            ? const SpeechTurn(didengar: false)
            : SpeechTurn(didengar: true, teks: teks),
      );
    }
    _aktif = null;
    try {
      await _plugin.stop();
    } catch (_) {
      // Belum pernah mulai.
    }
  }

  void _onResult(SpeechRecognitionResult hasil) {
    final teks = hasil.recognizedWords.trim();
    if (teks.isNotEmpty) _teksTerakhir = teks;
    if (!hasil.finalResult) return;
    _tutup(
      teks.isEmpty
          ? const SpeechTurn(didengar: false)
          : SpeechTurn(didengar: true, teks: teks),
    );
  }

  void _onError(SpeechRecognitionError galat) {
    _galat = galat.errorMsg;
    if (_galatTidakTersedia.contains(_galat)) {
      _tutup(null);
      return;
    }
    if (_galatTanpaKata.contains(_galat)) {
      _tutup(const SpeechTurn(didengar: false));
      return;
    }
    final teks = _teksTerakhir;
    _tutup(
      teks == null
          ? const SpeechTurn(didengar: false)
          : SpeechTurn(didengar: true, teks: teks),
    );
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      final aktif = _aktif;
      if (aktif == null || aktif.isCompleted) return;
      // Galat sudah menentukan hasilnya; status hanya menutup giliran kosong.
      if (_galat != null) return;
      final teks = _teksTerakhir;
      _tutup(
        teks == null
            ? const SpeechTurn(didengar: false)
            : SpeechTurn(didengar: true, teks: teks),
      );
    }
  }

  void _tutup(SpeechTurn? hasil) {
    final aktif = _aktif;
    if (aktif == null || aktif.isCompleted) return;
    aktif.complete(hasil);
  }
}
