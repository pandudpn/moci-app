/// Satu catatan validasi: nama aturan dan pesannya.
final class Catatan {
  const Catatan(this.aturan, this.pesan);

  final String aturan;
  final String pesan;

  @override
  String toString() => '$aturan: $pesan';
}

/// Hasil satu putaran validasi konten.
///
/// Aturan yang lolos dicatat lewat [ok] supaya ringkasannya menyebut cakupan
/// yang diperiksa, bukan hanya yang bermasalah.
final class Laporan {
  final List<Catatan> _galat = [];
  final List<Catatan> _peringatan = [];
  final List<Catatan> _lolos = [];

  List<Catatan> get galatList => List.unmodifiable(_galat);
  List<Catatan> get peringatanList => List.unmodifiable(_peringatan);
  List<Catatan> get lolosList => List.unmodifiable(_lolos);

  bool get adaGalat => _galat.isNotEmpty;

  void ok(String aturan, String pesan) => _lolos.add(Catatan(aturan, pesan));

  void peringatan(String aturan, String pesan) =>
      _peringatan.add(Catatan(aturan, pesan));

  void galat(String aturan, String pesan) => _galat.add(Catatan(aturan, pesan));

  /// Ringkasan untuk terminal: jumlah, lalu setiap galat dan peringatan.
  String ringkasan() {
    final baris = <String>[
      '${_galat.length} galat, ${_peringatan.length} peringatan, '
          '${_lolos.length} aturan lolos',
      for (final g in _galat) 'GALAT ${g.aturan}: ${g.pesan}',
      for (final p in _peringatan) 'PERINGATAN ${p.aturan}: ${p.pesan}',
    ];
    return baris.join('\n');
  }
}
