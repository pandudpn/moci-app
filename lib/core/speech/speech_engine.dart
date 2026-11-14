import 'dart:math' as math;

import '../lang.dart';

/// Keadaan pengenal ucapan setelah gerbang izin dan pengecekan bahasa.
enum SpeechStatus {
  /// Pengenalan di perangkat siap untuk bahasa yang dipilih.
  siap,

  /// Orang tua (atau sistem) menolak izin mikrofon.
  izinDitolak,

  /// Perangkat tidak punya pengenalan luring untuk bahasa itu.
  tidakTersedia,
}

/// Satu giliran mendengar.
///
/// [didengar] bernilai benar kalau ada kata yang dikenali; [teks] berisi
/// kata terakhir yang dikenali, atau `null` kalau tidak ada.
final class SpeechTurn {
  const SpeechTurn({required this.didengar, this.teks});

  final bool didengar;
  final String? teks;
}

/// Pengenal ucapan di perangkat. Tidak ada mode yang boleh memakai jaringan.
abstract interface class SpeechEngine {
  Future<bool> hasPermission();
  Future<SpeechStatus> prepare(AppLang lang);

  /// Mendengar paling lama [batas]. `null` berarti pengenalan teks tidak
  /// tersedia untuk bahasa ini (misalnya tidak ada model luring).
  Future<SpeechTurn?> listen({
    required String target,
    required AppLang lang,
    required Duration batas,
  });

  Future<void> stop();
}

/// Teks dinormalkan ke huruf kecil tanpa tanda baca dan spasi ganda.
String _normal(String teks) => teks
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();

/// Cocok kalau teks sama setelah dinormalkan, atau (target empat huruf ke
/// atas) beda satu huruf.
bool kataCocok(String target, String ucapan) {
  final t = _normal(target);
  final u = _normal(ucapan);
  if (t.isEmpty || u.isEmpty) return false;
  if (t == u) return true;
  if (t.length < 4) return false;
  return _jarak(t, u) <= 1;
}

/// Jarak Levenshtein; berhenti di 2 karena hanya 0 dan 1 yang dipakai.
int _jarak(String a, String b) {
  if ((a.length - b.length).abs() > 1) return 2;
  var sebelumnya = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final kini = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final ganti = sebelumnya[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1);
      final hapus = sebelumnya[j] + 1;
      final tambah = kini[j - 1] + 1;
      kini[j] = math.min(ganti, math.min(hapus, tambah));
    }
    sebelumnya = kini;
  }
  return sebelumnya[b.length];
}
