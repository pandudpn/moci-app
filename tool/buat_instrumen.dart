// Membuat 12 bunyi instrumen Main Musik: 8 nada xilofon dan 4 drum.
// Jalankan: fvm dart run tool/buat_instrumen.dart
// Semua berkas milik sendiri; tidak ada sampel pihak ketiga.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:moci/features/musik/instrumen.dart';

const _laju = 24000;
const _duaPi = 2 * pi;

void main() {
  final folder = Directory('assets/audio/instrumen')..createSync(recursive: true);
  for (var i = 0; i < nadaXilo.length; i++) {
    _tulis(nadaXilo[i], _xilo(frekuensiXilo[i]));
  }
  _tulis(bunyiDrum[0], _drum());
  _tulis(bunyiDrum[1], _tepuk());
  _tulis(bunyiDrum[2], _simbal());
  _tulis(bunyiDrum[3], _kerincing());
  stdout.writeln('${daftarInstrumen.length} berkas di ${folder.path}');
}

/// Xilofon: nada dasar berekor 0,42 dtk plus komponen 3,93× yang cepat mati.
Float64List _xilo(double f) {
  final n = (_laju * 1.2).round();
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / _laju;
    final attack = t < 0.006 ? t / 0.006 : 1.0;
    final v =
        0.45 * sin(_duaPi * f * t) * exp(-t / 0.42) +
        0.16 * sin(_duaPi * 3.93 * f * t) * exp(-t / 0.06);
    out[i] = attack * v;
  }
  return out;
}

/// Kick: sinus 165 → 45 Hz dengan envelope 0,95·e^(−t/0,12).
Float64List _drum() {
  final n = (_laju * 0.5).round();
  final out = Float64List(n);
  var fase = 0.0;
  for (var i = 0; i < n; i++) {
    final t = i / _laju;
    final f = t < 0.35 ? 165 + (45 - 165) * (t / 0.35) : 45.0;
    fase += _duaPi * f / _laju;
    out[i] = 0.95 * exp(-t / 0.12) * sin(fase);
  }
  return out;
}

/// Tepuk: derau berpusat 1500 Hz, tiga burst 12 ms, ekor 0,3 dtk.
Float64List _tepuk() {
  final n = (_laju * 0.3).round();
  final derau = _derauBand(n, 1500, 1.0);
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / _laju;
    var env = 0.0;
    for (final mulai in const [0.0, 0.014, 0.028]) {
      if (t >= mulai && t < mulai + 0.012) {
        env = max(env, 0.9 * _naik(0.001, t - mulai, mulai + 0.012 - t));
      }
    }
    if (t >= 0.028) {
      env = max(env, 0.45 * exp(-(t - 0.028) / 0.08));
    }
    out[i] = env * derau[i];
  }
  return out;
}

/// Simbal: derau high-pass 6500 Hz, envelope 0,55·e^(−t/0,32).
Float64List _simbal() {
  final n = (_laju * 1.4).round();
  final derau = _derauHighPass(n, 6500);
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    out[i] = 0.55 * exp(-(i / _laju) / 0.32) * derau[i];
  }
  return out;
}

/// Kerincing: derau high-pass 4500 Hz, attack 30 ms lalu 0,45·e^(−t/0,05).
Float64List _kerincing() {
  final n = (_laju * 0.2).round();
  final derau = _derauHighPass(n, 4500);
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    final t = i / _laju;
    final env = t < 0.03
        ? 0.45 * (t / 0.03)
        : 0.45 * exp(-(t - 0.03) / 0.05);
    out[i] = env * derau[i];
  }
  return out;
}

double _naik(double tepi, double a, double b) {
  final naik = a / tepi;
  final turun = b / tepi;
  return min(1.0, min(naik, turun));
}

/// Derau putih yang dibatasi bandpass RBJ di sekitar [pusat] Hz.
Float64List _derauBand(int n, double pusat, double q) {
  final acak = Random(20261114);
  final w0 = _duaPi * pusat / _laju;
  final alpha = sin(w0) / (2 * q);
  final a0 = 1 + alpha;
  final b0 = alpha / a0;
  final b2 = -alpha / a0;
  final a1 = -2 * cos(w0) / a0;
  final a2 = (1 - alpha) / a0;
  final out = Float64List(n);
  var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0;
  for (var i = 0; i < n; i++) {
    final x0 = acak.nextDouble() * 2 - 1;
    final y0 = b0 * x0 + b2 * x2 - a1 * y1 - a2 * y2;
    out[i] = y0;
    x2 = x1;
    x1 = x0;
    y2 = y1;
    y1 = y0;
  }
  return out;
}

/// Derau high-pass satu kutub di atas [batas] Hz.
Float64List _derauHighPass(int n, double batas) {
  final acak = Random(20261114);
  final rc = 1 / (_duaPi * batas);
  final dtk = 1 / _laju;
  final a = rc / (rc + dtk);
  final out = Float64List(n);
  var xLalu = 0.0, yLalu = 0.0;
  for (var i = 0; i < n; i++) {
    final x = acak.nextDouble() * 2 - 1;
    final y = a * (yLalu + x - xLalu);
    out[i] = y;
    xLalu = x;
    yLalu = y;
  }
  return out;
}

void _tulis(String nama, Float64List sampel) {
  final data = ByteData(44 + sampel.length * 2);
  void ascii(int mulai, String teks) {
    for (var i = 0; i < teks.length; i++) {
      data.setUint8(mulai + i, teks.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + sampel.length * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, _laju, Endian.little);
  data.setUint32(28, _laju * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, sampel.length * 2, Endian.little);
  for (var i = 0; i < sampel.length; i++) {
    final v = sampel[i].clamp(-0.98, 0.98);
    data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
  }
  File(pathInstrumen(nama)).writeAsBytesSync(data.buffer.asUint8List());
}
