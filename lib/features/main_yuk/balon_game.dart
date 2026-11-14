import 'dart:math';

import '../../core/prefs/app_prefs.dart';

/// Set huruf untuk anak pemula: hanya huruf yang bentuknya tegas.
const hurufBalonPemula = 'ABCIMOPSU';

/// Set huruf lengkap tanpa Q, V, dan X yang jarang di kata anak.
const hurufBalonPenjelajah = 'ABCDEFGHIJKLMNOPRSTUWYZ';

/// Set huruf menurut tingkat usia.
String setHurufBalon(AgeLevel usia) =>
    usia == AgeLevel.pemula ? hurufBalonPemula : hurufBalonPenjelajah;

/// Ronde satu permainan; lima ronde menuntaskan satu permainan.
const balonRonde = 5;

/// Balon per ronde: target dua kali dan empat pengecoh.
const balonPerRonde = 6;

/// Satu ronde Balon Huruf: huruf target dan isi balon yang teracak.
final class BalonRonde {
  const BalonRonde({required this.target, required this.huruf});

  final String target;
  final List<String> huruf;
}

/// Membuat ronde baru: target acak selain [hindari], lalu empat huruf lain
/// sebagai pengecoh, dua kali target, dan diacak.
BalonRonde buatBalon(AgeLevel usia, {required Random random, String? hindari}) {
  final set = setHurufBalon(usia).split('');
  final kandidat = [
    for (final huruf in set)
      if (huruf != hindari) huruf,
  ];
  final target = kandidat[random.nextInt(kandidat.length)];
  final lain = [
    for (final huruf in set)
      if (huruf != target) huruf,
  ]..shuffle(random);
  return BalonRonde(
    target: target,
    huruf: [target, target, ...lain.take(balonPerRonde - 2)]..shuffle(random),
  );
}

/// Hasil satu ketukan pada balon.
enum BalonStep { pecah, salah, selesai }

/// Aturan main satu ronde: hanya balon huruf target yang pecah.
final class BalonGame {
  BalonGame({required AgeLevel usia, required Random random})
    : _usia = usia,
      _random = random,
      _ronde = buatBalon(usia, random: random);

  final AgeLevel _usia;
  final Random _random;

  final Set<int> _pecah = {};
  BalonRonde _ronde;
  int _skor = 0;

  BalonRonde get ronde => _ronde;
  int get skor => _skor;
  Set<int> get pecah => Set.unmodifiable(_pecah);
  bool get selesai => _skor >= balonRonde;

  BalonStep pilih(int indeks) {
    if (indeks < 0 || indeks >= _ronde.huruf.length) return BalonStep.salah;
    // Balon sudah pecah: ketukan lain menunggu ronde berikutnya.
    if (_pecah.isNotEmpty) return BalonStep.pecah;
    if (_ronde.huruf[indeks] != _ronde.target) return BalonStep.salah;
    _pecah.add(indeks);
    return _skor + 1 >= balonRonde ? BalonStep.selesai : BalonStep.pecah;
  }

  void lanjut() {
    if (_pecah.isEmpty) return;
    _skor += 1;
    _pecah.clear();
    if (selesai) return;
    _ronde = buatBalon(_usia, random: _random, hindari: _ronde.target);
  }
}
