import 'dart:async';

import 'package:moci/core/lang.dart';
import 'package:moci/core/speech/mic_level_meter.dart';
import 'package:moci/core/speech/speech_engine.dart';

/// Pengenal ucapan palsu: hasil giliran dan status diatur tes.
final class FakeSpeechEngine implements SpeechEngine {
  SpeechStatus status = SpeechStatus.siap;
  SpeechTurn? turn = const SpeechTurn(didengar: true, teks: 'apel');
  bool hasPermissionValue = true;

  /// Kata target tiap panggilan [listen], urut.
  final targets = <String>[];

  /// Bahasa dan batas tiap panggilan [listen], urut.
  final languages = <AppLang>[];
  final limits = <Duration>[];

  int prepareCount = 0;
  int listenCount = 0;
  int stopCount = 0;

  /// Bila diisi, [listen] menunggu sampai gerbang diselesaikan.
  Completer<void>? gate;

  @override
  Future<bool> hasPermission() async => hasPermissionValue;

  @override
  Future<SpeechStatus> prepare(AppLang lang) async {
    prepareCount++;
    return status;
  }

  @override
  Future<SpeechTurn?> listen({
    required String target,
    required AppLang lang,
    required Duration batas,
  }) async {
    listenCount++;
    targets.add(target);
    languages.add(lang);
    limits.add(batas);
    final g = gate;
    if (g != null) await g.future;
    return turn;
  }

  @override
  Future<void> stop() async => stopCount++;
}

/// Pengukur level suara palsu: hasil giliran diatur tes.
final class FakeMicLevelMeter implements MicLevelMeter {
  bool hasil = false;
  bool availableValue = true;

  int listenCount = 0;
  int stopCount = 0;
  final limits = <Duration>[];

  @override
  Future<bool> get available async => availableValue;

  @override
  Future<bool> listen({required Duration batas}) async {
    listenCount++;
    limits.add(batas);
    return hasil;
  }

  @override
  Future<void> stop() async => stopCount++;
}
