import 'bilingual.dart';

/// Satu halaman mewarnai: bagian yang bisa diwarnai dan contoh warnanya.
final class ColoringPage {
  const ColoringPage({
    required this.id,
    required this.kategori,
    required this.nama,
    required this.bagian,
    this.contoh = const {},
  });

  factory ColoringPage.fromJson(Object? value) {
    final map = _map(value);
    return ColoringPage(
      id: _str(map['id']),
      kategori: _str(map['kategori']),
      nama: Bilingual.fromJson(map['nama']),
      bagian: [
        for (final e in _list(map['bagian'])) ColoringRegion.fromJson(e),
      ],
      contoh: {
        for (final e in _map(map['contoh']).entries)
          ?int.tryParse(e.key): _str(e.value),
      },
    );
  }

  final String id;
  final String kategori;
  final Bilingual nama;
  final List<ColoringRegion> bagian;

  /// Warna contoh per indeks bagian, untuk halaman yang sudah punya contoh.
  final Map<int, String> contoh;

  Map<String, Object?> toJson() => {
    'id': id,
    'kategori': kategori,
    'nama': nama.toJson(),
    'bagian': [for (final e in bagian) e.toJson()],
    'contoh': {for (final e in contoh.entries) '${e.key}': e.value},
  };
}

/// Satu bagian tertutup pada halaman mewarnai, plus garis detailnya.
final class ColoringRegion {
  const ColoringRegion({
    required this.d,
    this.evenOdd = false,
    this.detail = const [],
  });

  factory ColoringRegion.fromJson(Object? value) {
    final map = _map(value);
    return ColoringRegion(
      d: _str(map['d']),
      evenOdd: map['evenOdd'] == true,
      detail: [
        for (final e in _list(map['detail']))
          if (e is List && e.length >= 3)
            (d: _str(e[0]), fill: _str(e[1]), w: _double(e[2])),
      ],
    );
  }

  final String d;
  final bool evenOdd;
  final List<({String d, String fill, double w})> detail;

  Map<String, Object?> toJson() => {
    'd': d,
    if (evenOdd) 'evenOdd': true,
    'detail': [
      for (final e in detail) [e.d, e.fill, e.w],
    ],
  };
}

/// Semua halaman mewarnai beserta ukuran kanvasnya.
final class ColoringSet {
  const ColoringSet({
    this.versi = 1,
    this.kanvas = const [800, 600],
    this.halaman = const [],
  });

  factory ColoringSet.fromJson(Object? value) {
    final map = _map(value);
    return ColoringSet(
      versi: _int(map['versi']),
      kanvas: _ints(map['kanvas']),
      halaman: [
        for (final e in _list(map['halaman'])) ColoringPage.fromJson(e),
      ],
    );
  }

  final int versi;
  final List<int> kanvas;
  final List<ColoringPage> halaman;

  ColoringPage? byId(String id) {
    for (final page in halaman) {
      if (page.id == id) return page;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
    'versi': versi,
    'kanvas': kanvas,
    'halaman': [for (final e in halaman) e.toJson()],
  };
}

/// Stiker yang bisa ditempel di karya mewarnai.
final class Cap {
  const Cap({required this.id, required this.nama});

  factory Cap.fromJson(Object? value) {
    final map = _map(value);
    return Cap(id: _str(map['id']), nama: Bilingual.fromJson(map['nama']));
  }

  final String id;
  final Bilingual nama;

  Map<String, Object?> toJson() => {'id': id, 'nama': nama.toJson()};
}

/// Satu krayon di kotak warna mewarnai.
final class Krayon {
  const Krayon({required this.hex, required this.nama});

  factory Krayon.fromJson(Object? value) {
    final map = _map(value);
    return Krayon(hex: _str(map['hex']), nama: Bilingual.fromJson(map['nama']));
  }

  final String hex;
  final Bilingual nama;

  Map<String, Object?> toJson() => {'hex': hex, 'nama': nama.toJson()};
}

String _str(Object? value) => value is String ? value : '';

int _int(Object? value) => value is num ? value.toInt() : 0;

double _double(Object? value) => value is num ? value.toDouble() : 0;

List<int> _ints(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is num) e.toInt(),
      ]
    : const <int>[];

List<Object?> _list(Object? value) => value is List ? value : const <Object?>[];

Map<String, Object?> _map(Object? value) => value is Map
    ? {
        for (final e in value.entries)
          if (e.key is String) e.key as String: e.value,
      }
    : const <String, Object?>{};
