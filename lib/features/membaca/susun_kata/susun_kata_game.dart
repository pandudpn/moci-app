import 'dart:math';

import '../../../core/content/katalog.dart';

/// Kata per level sebelum hadiah.
const rondePerLevel = 5;

/// Level yang punya kolam kata: dua dan tiga suku kata.
const levelTersedia = [2, 3];

/// Hasil satu ketukan keping.
enum SusunKetuk { mengisi, benar, salah, penuh, dipakai }

/// Satu ronde: kata target, empat keping, dan kotak yang sedang terisi.
final class SusunRonde {
  SusunRonde({required this.entry, required this.tiles, required this.slots});

  final KataEntry entry;

  /// Empat keping: suku kata target ditambah pengganggu, sudah diacak.
  final List<String> tiles;

  /// Indeks keping di [tiles] untuk tiap kotak; `null` masih kosong.
  final List<int?> slots;

  bool get lengkap => slots.every((s) => s != null);

  int get terisi => slots.where((s) => s != null).length;

  /// Suku kata yang sudah masuk kotak, urut kotak.
  String get tersusun => [
    for (final s in slots)
      if (s != null) tiles[s],
  ].join();

  String get target => entry.suku.join();

  /// Semua kotak terisi dengan suku kata target pada urutan yang benar.
  bool get benar {
    if (!lengkap) return false;
    for (var i = 0; i < slots.length; i++) {
      if (tiles[slots[i]!] != entry.suku[i]) return false;
    }
    return true;
  }
}

/// Aturan lima ronde Susun Kata, Dart murni tanpa widget.
final class SusunKataGame {
  SusunKataGame({
    required List<KataEntry> kata,
    required Random random,
    int level = 2,
  }) : _kata = List.unmodifiable(kata),
       _random = random,
       _level = level {
    _pastikanLevel(level);
    _ronde = _buatRonde();
  }

  final List<KataEntry> _kata;
  final Random _random;
  int _level;
  int _nomor = 1;
  bool _selesai = false;
  KataEntry? _sebelumnya;
  late SusunRonde _ronde;

  int get level => _level;
  int get nomor => _nomor;
  SusunRonde get ronde => _ronde;
  bool get levelSelesai => _selesai;

  List<KataEntry> get _kolam => [
    for (final e in _kata)
      if (e.level == _level) e,
  ];

  void _pastikanLevel(int level) {
    if (!levelTersedia.contains(level)) {
      throw ArgumentError.value(level, 'level', 'hanya 2 atau 3');
    }
    final kosong = !_kata.any((e) => e.level == level);
    if (kosong) {
      throw ArgumentError.value(level, 'level', 'kolam kata kosong');
    }
  }

  SusunRonde _buatRonde() {
    final kolam = _kolam;
    final beda = [
      for (final e in kolam)
        if (e.item != _sebelumnya?.item) e,
    ];
    final dasar = beda.isEmpty ? kolam : beda;
    final entry = dasar[_random.nextInt(dasar.length)];

    final target = entry.suku.toSet();
    final lain = <String>{};
    for (final e in kolam) {
      if (e.item == entry.item) continue;
      for (final suku in e.suku) {
        if (!target.contains(suku)) lain.add(suku);
      }
    }
    final acak = lain.toList()..shuffle(_random);
    final pengganggu = acak.take(_level == 3 ? 1 : 2);
    final tiles = [...entry.suku, ...pengganggu]..shuffle(_random);
    return SusunRonde(
      entry: entry,
      tiles: tiles,
      slots: List<int?>.filled(entry.suku.length, null),
    );
  }

  /// Mengisi kotak kosong pertama dengan keping [tile].
  SusunKetuk ketuk(int tile) {
    if (tile < 0 || tile >= _ronde.tiles.length) return SusunKetuk.dipakai;
    if (_ronde.slots.contains(tile)) return SusunKetuk.dipakai;
    final kosong = _ronde.slots.indexOf(null);
    if (kosong < 0) return SusunKetuk.penuh;
    _ronde.slots[kosong] = tile;
    if (!_ronde.lengkap) return SusunKetuk.mengisi;
    return _ronde.benar ? SusunKetuk.benar : SusunKetuk.salah;
  }

  /// Mengosongkan kotak tanpa mengganti kata.
  void kosongkan() => _ronde.slots.fillRange(0, _ronde.slots.length, null);

  /// Ronde berikutnya; pada ronde kelima menandai level selesai.
  void berikutnya() {
    if (_nomor >= rondePerLevel) {
      _selesai = true;
      return;
    }
    _sebelumnya = _ronde.entry;
    _nomor++;
    _ronde = _buatRonde();
  }

  void gantiLevel(int level) {
    _pastikanLevel(level);
    _level = level;
    _nomor = 1;
    _selesai = false;
    _sebelumnya = null;
    _ronde = _buatRonde();
  }
}
