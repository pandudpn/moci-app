import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../core/content/coloring.dart';
import 'mewarnai_model.dart';
import 'svg_path.dart';

/// Alat pewarnaan satu halaman: jalur bagian, isi, dan riwayat batalnya.
final class MesinMewarnai extends ChangeNotifier {
  MesinMewarnai({required this.halaman, KaryaData? awal})
    : _data = awal ?? KaryaData.kosong(halaman.id),
      jalur = _jalurUntuk(halaman);

  /// Halaman yang sedang diwarnai; `jalur` di-parse sekali di sini.
  final ColoringPage halaman;
  final List<Path> jalur;

  KaryaData _data;
  AlatMewarnai _alat = AlatMewarnai.kuas;
  UkuranKuas _ukuran = UkuranKuas.sedang;
  String _warna = '#74C0FC';
  String _cap = '';
  int? _terkunci;
  final List<Offset> _aktif = [];
  final Riwayat _riwayat = Riwayat();

  static List<Path> _jalurUntuk(ColoringPage halaman) => [
    for (final bagian in halaman.bagian)
      svgPath(bagian.d)
        ..fillType = bagian.evenOdd
            ? PathFillType.evenOdd
            : PathFillType.nonZero,
  ];

  KaryaData get data => _data;

  AlatMewarnai get alat => _alat;

  UkuranKuas get ukuran => _ukuran;

  String get warna => _warna;

  String get cap => _cap;

  /// Bagian yang dikunci goresan yang sedang berjalan, bila ada.
  int? get bagianTerkunci => _terkunci;

  /// Titik jari goresan aktif; hanya dibaca painter.
  List<Offset> get goresanAktif => _aktif;

  bool get bisaBatal => !_riwayat.kosong;

  int get panjangRiwayat => _riwayat.panjang;

  void pilihAlat(AlatMewarnai alat) {
    if (_alat == alat) return;
    _alat = alat;
    notifyListeners();
  }

  void pilihWarna(String hex) {
    if (_warna == hex) return;
    _warna = hex;
    notifyListeners();
  }

  void pilihUkuran(UkuranKuas ukuran) {
    if (_ukuran == ukuran) return;
    _ukuran = ukuran;
    notifyListeners();
  }

  void pilihCap(String id) {
    if (_cap == id) return;
    _cap = id;
    notifyListeners();
  }

  /// Bagian teratas yang memuat [p]: bagian dengan indeks terbesar menang.
  int? bagianDi(Offset p) {
    for (var i = jalur.length - 1; i >= 0; i--) {
      if (jalur[i].contains(p)) return i;
    }
    return null;
  }

  void mulai(Offset p) {
    switch (_alat) {
      case AlatMewarnai.isi:
        final bagian = bagianDi(p);
        if (bagian != null) _isi(bagian);
      case AlatMewarnai.cap:
        _tempelCap(p);
      case AlatMewarnai.kuas:
      case AlatMewarnai.hapus:
        final bagian = bagianDi(p);
        if (bagian == null) return;
        _terkunci = bagian;
        _aktif
          ..clear()
          ..add(p);
        notifyListeners();
    }
  }

  void geser(Offset p) {
    if (_terkunci == null) return;
    if (_aktif.isNotEmpty && (p - _aktif.last).distance < jarakMinTitik) {
      return;
    }
    _aktif.add(p);
    notifyListeners();
  }

  void akhiri() {
    final bagian = _terkunci;
    if (bagian == null) return;
    final d = coretanDariTitik(_aktif);
    _terkunci = null;
    _aktif.clear();
    if (d.isEmpty) {
      notifyListeners();
      return;
    }
    final hapus = _alat == AlatMewarnai.hapus;
    final coretan = Coretan(
      d: d,
      warna: hapus ? '#FFFFFF' : _warna,
      lebar: hapus ? _ukuran.lebar + tambahanLebarHapus : _ukuran.lebar,
    );
    final peta = Map<int, List<Coretan>>.from(_data.coretan);
    peta[bagian] = [...?_data.coretan[bagian], coretan];
    _data = _data.copyWith(coretan: peta);
    _riwayat.tambah(LangkahCoretan(bagian));
    notifyListeners();
  }

  void batal() {
    final langkah = _riwayat.ambilTerakhir();
    if (langkah == null) return;
    switch (langkah) {
      case LangkahIsi():
        final isian = Map<int, String>.from(_data.isian);
        final sebelum = langkah.sebelum;
        if (sebelum == null) {
          isian.remove(langkah.bagian);
        } else {
          isian[langkah.bagian] = sebelum;
        }
        final coretan = Map<int, List<Coretan>>.from(_data.coretan);
        if (langkah.coretanDihapus.isEmpty) {
          coretan.remove(langkah.bagian);
        } else {
          coretan[langkah.bagian] = langkah.coretanDihapus;
        }
        _data = _data.copyWith(isian: isian, coretan: coretan);
      case LangkahCoretan():
        final sisa = [...?_data.coretan[langkah.bagian]];
        if (sisa.isNotEmpty) sisa.removeLast();
        final coretan = Map<int, List<Coretan>>.from(_data.coretan);
        if (sisa.isEmpty) {
          coretan.remove(langkah.bagian);
        } else {
          coretan[langkah.bagian] = sisa;
        }
        _data = _data.copyWith(coretan: coretan);
      case LangkahCap():
        if (_data.cap.isNotEmpty) {
          _data = _data.copyWith(
            cap: _data.cap.sublist(0, _data.cap.length - 1),
          );
        }
      case LangkahMulaiLagi():
        _data = langkah.sebelum;
    }
    notifyListeners();
  }

  /// Mengosongkan halaman; bisa dibatalkan selama riwayat masih menyimpannya.
  void mulaiLagi() {
    if (!_data.adaIsi) return;
    _riwayat.tambah(LangkahMulaiLagi(_data));
    _data = KaryaData.kosong(_data.halaman);
    notifyListeners();
  }

  void _isi(int bagian) {
    final lama = _data.isian[bagian];
    final tertimpa = _data.coretan[bagian] ?? const <Coretan>[];
    if (lama == _warna && tertimpa.isEmpty) return;
    _riwayat.tambah(
      LangkahIsi(bagian: bagian, sebelum: lama, coretanDihapus: tertimpa),
    );
    final coretan = Map<int, List<Coretan>>.from(_data.coretan)..remove(bagian);
    _data = _data.copyWith(
      isian: Map<int, String>.from(_data.isian)..[bagian] = _warna,
      coretan: coretan,
    );
    notifyListeners();
  }

  void _tempelCap(Offset p) {
    if (_cap.isEmpty) return;
    if (p.dx < 0 ||
        p.dy < 0 ||
        p.dx > kanvasHalaman.width ||
        p.dy > kanvasHalaman.height) {
      return;
    }
    _data = _data.copyWith(
      cap: [
        ..._data.cap,
        CapTempel(cap: _cap, x: _bulat(p.dx), y: _bulat(p.dy)),
      ],
    );
    _riwayat.tambah(const LangkahCap());
    notifyListeners();
  }

  static double _bulat(double nilai) => (nilai * 10).roundToDouble() / 10;
}
