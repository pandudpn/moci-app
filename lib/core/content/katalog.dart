import '../lang.dart';
import 'bilingual.dart';

/// Satu benda isi: gambar, nama, dan data tambahan per jenisnya.
///
/// `sukuKata` menyimpan pemenggalan untuk Susun Kata; bahasanya boleh kosong
/// kalau kata di prototipe tidak ada.
final class Item {
  const Item({
    required this.id,
    required this.kategori,
    required this.nama,
    required this.gambar,
    this.warna,
    this.hewan,
    this.sukuKata = (id: null, en: null),
  });

  factory Item.fromJson(Object? value) {
    final map = _map(value);
    final suku = _map(map['sukuKata']);
    return Item(
      id: _str(map['id']),
      kategori: _str(map['kategori']),
      nama: Bilingual.fromJson(map['nama']),
      gambar: _str(map['gambar']),
      warna: map['warna'] is String ? map['warna'] as String : null,
      hewan: map['hewan'] == null ? null : HewanInfo.fromJson(map['hewan']),
      sukuKata: (
        id: _stringsOrNull(suku['id']),
        en: _stringsOrNull(suku['en']),
      ),
    );
  }

  final String id;
  final String kategori;
  final Bilingual nama;
  final String gambar;
  final String? warna;
  final HewanInfo? hewan;
  final ({List<String>? id, List<String>? en}) sukuKata;

  Map<String, Object?> toJson() => {
    'id': id,
    'kategori': kategori,
    'nama': nama.toJson(),
    'gambar': gambar,
    if (warna != null) 'warna': warna,
    if (hewan != null) 'hewan': hewan!.toJson(),
    'sukuKata': {'id': sukuKata.id, 'en': sukuKata.en},
  };
}

/// Data suara dan fakta untuk benda berkategori hewan.
final class HewanInfo {
  const HewanInfo({
    required this.kelompok,
    required this.bunyi,
    required this.fakta,
  });

  factory HewanInfo.fromJson(Object? value) {
    final map = _map(value);
    return HewanInfo(
      kelompok: _str(map['kelompok']),
      bunyi: Bilingual.fromJson(map['bunyi']),
      fakta: Bilingual.fromJson(map['fakta']),
    );
  }

  final String kelompok;
  final Bilingual bunyi;
  final Bilingual fakta;

  Map<String, Object?> toJson() => {
    'kelompok': kelompok,
    'bunyi': bunyi.toJson(),
    'fakta': fakta.toJson(),
  };
}

/// Satu huruf: contoh kata dan gambarnya per bahasa.
final class HurufEntry {
  const HurufEntry({required this.huruf, required this.id, required this.en});

  factory HurufEntry.fromJson(Object? value) {
    final map = _map(value);
    return HurufEntry(
      huruf: _str(map['huruf']),
      id: HurufBahasa.fromJson(map['id']),
      en: HurufBahasa.fromJson(map['en']),
    );
  }

  final String huruf;
  final HurufBahasa id;
  final HurufBahasa en;

  HurufBahasa of(AppLang lang) => lang == AppLang.en ? en : id;

  Map<String, Object?> toJson() => {
    'huruf': huruf,
    'id': id.toJson(),
    'en': en.toJson(),
  };
}

/// Contoh kata satu huruf dalam satu bahasa.
final class HurufBahasa {
  const HurufBahasa({
    required this.kata,
    required this.gambar,
    required this.bunyi,
    required this.nama,
  });

  factory HurufBahasa.fromJson(Object? value) {
    final map = _map(value);
    return HurufBahasa(
      kata: _str(map['kata']),
      gambar: _str(map['gambar']),
      bunyi: _str(map['bunyi']),
      nama: _str(map['nama']),
    );
  }

  final String kata;
  final String gambar;
  final String bunyi;
  final String nama;

  Map<String, Object?> toJson() => {
    'kata': kata,
    'gambar': gambar,
    'bunyi': bunyi,
    'nama': nama,
  };
}

/// Batas hitung dan benda yang dipakai layar Berhitung.
final class AngkaInfo {
  const AngkaInfo({
    this.maks = 50,
    this.rentang = const [],
    this.benda = const [],
  });

  factory AngkaInfo.fromJson(Object? value) {
    final map = _map(value);
    return AngkaInfo(
      maks: _int(map['maks']),
      rentang: [
        for (final rentang in _list(map['rentang']))
          if (rentang is List && rentang.length >= 2)
            (_int(rentang[0]), _int(rentang[1])),
      ],
      benda: _strings(map['benda']),
    );
  }

  final int maks;
  final List<(int, int)> rentang;
  final List<String> benda;

  Map<String, Object?> toJson() => {
    'maks': maks,
    'rentang': [
      for (final rentang in this.rentang) [rentang.$1, rentang.$2],
    ],
    'benda': benda,
  };
}

/// Satu warna dengan teks dan garis yang tetap terbaca di atasnya.
final class WarnaEntry {
  const WarnaEntry({
    required this.id,
    required this.nama,
    required this.hex,
    required this.teks,
    required this.garis,
  });

  factory WarnaEntry.fromJson(Object? value) {
    final map = _map(value);
    return WarnaEntry(
      id: _str(map['id']),
      nama: Bilingual.fromJson(map['nama']),
      hex: _str(map['hex']),
      teks: _str(map['teks']),
      garis: _str(map['garis']),
    );
  }

  final String id;
  final Bilingual nama;
  final String hex;
  final String teks;
  final String garis;

  Map<String, Object?> toJson() => {
    'id': id,
    'nama': nama.toJson(),
    'hex': hex,
    'teks': teks,
    'garis': garis,
  };
}

/// Satu bentuk geometri beserta titik sudut dan wajahnya.
final class BentukEntry {
  const BentukEntry({
    required this.id,
    required this.nama,
    required this.warna,
    required this.gelap,
    required this.path,
    required this.wajahX,
    required this.wajahY,
    required this.wajahSkala,
    required this.sudutTitik,
    required this.jenis,
    required this.sisi,
    required this.sudut,
    required this.fakta,
  });

  factory BentukEntry.fromJson(Object? value) {
    final map = _map(value);
    return BentukEntry(
      id: _str(map['id']),
      nama: Bilingual.fromJson(map['nama']),
      warna: _str(map['warna']),
      gelap: _str(map['gelap']),
      path: _str(map['path']),
      wajahX: _double(map['wajahX']),
      wajahY: _double(map['wajahY']),
      wajahSkala: _double(map['wajahSkala']),
      sudutTitik: [
        for (final titik in _list(map['sudutTitik']))
          if (titik is List && titik.length >= 2)
            (_double(titik[0]), _double(titik[1])),
      ],
      jenis: _str(map['jenis']),
      sisi: _int(map['sisi']),
      sudut: _int(map['sudut']),
      fakta: Bilingual.fromJson(map['fakta']),
    );
  }

  final String id;
  final Bilingual nama;
  final String warna;
  final String gelap;
  final String path;
  final double wajahX;
  final double wajahY;
  final double wajahSkala;
  final List<(double, double)> sudutTitik;
  final String jenis;
  final int sisi;
  final int sudut;
  final Bilingual fakta;

  Map<String, Object?> toJson() => {
    'id': id,
    'nama': nama.toJson(),
    'warna': warna,
    'gelap': gelap,
    'path': path,
    'wajahX': wajahX,
    'wajahY': wajahY,
    'wajahSkala': wajahSkala,
    'sudutTitik': [
      for (final titik in sudutTitik) [titik.$1, titik.$2],
    ],
    'jenis': jenis,
    'sisi': sisi,
    'sudut': sudut,
    'fakta': fakta.toJson(),
  };
}

/// Kisi suku kata dan contoh katanya.
final class SukuKataInfo {
  const SukuKataInfo({
    required this.konsonan,
    required this.vokal,
    required this.contoh,
  });

  factory SukuKataInfo.fromJson(Object? value) {
    final map = _map(value);
    final contoh = _map(map['contoh']);
    return SukuKataInfo(
      konsonan: _str(map['konsonan']),
      vokal: _strings(map['vokal']),
      contoh: {
        for (final bahasa in contoh.entries)
          bahasa.key: {
            for (final suku in _map(bahasa.value).entries)
              suku.key: (
                item: _str(_map(suku.value)['item']),
                kata: _str(_map(suku.value)['kata']),
              ),
          },
      },
    );
  }

  final String konsonan;
  final List<String> vokal;
  final Map<String, Map<String, ({String item, String kata})>> contoh;

  /// Semua suku kata hasil kisi konsonan × vokal, urut seperti di prototipe.
  List<String> get semua => [
    for (final k in konsonan.split(''))
      for (final v in vokal) '$k$v',
  ];

  Map<String, Object?> toJson() => {
    'konsonan': konsonan,
    'vokal': vokal,
    'contoh': {
      for (final bahasa in contoh.entries)
        bahasa.key: {
          for (final suku in bahasa.value.entries)
            suku.key: {'item': suku.value.item, 'kata': suku.value.kata},
        },
    },
  };
}

/// Daftar kata Susun Kata per bahasa, berurutan seperti prototipe.
final class KataInfo {
  const KataInfo({this.id = const [], this.en = const []});

  factory KataInfo.fromJson(Object? value) {
    final map = _map(value);
    return KataInfo(
      id: [for (final e in _list(map['id'])) KataEntry.fromJson(e)],
      en: [for (final e in _list(map['en'])) KataEntry.fromJson(e)],
    );
  }

  final List<KataEntry> id;
  final List<KataEntry> en;

  Map<String, Object?> toJson() => {
    'id': [for (final e in id) e.toJson()],
    'en': [for (final e in en) e.toJson()],
  };
}

/// Satu kata Susun Kata beserta pemenggalannya.
final class KataEntry {
  const KataEntry({required this.item, required this.kata, required this.suku});

  factory KataEntry.fromJson(Object? value) {
    final map = _map(value);
    return KataEntry(
      item: _str(map['item']),
      kata: _str(map['kata']),
      suku: _strings(map['suku']),
    );
  }

  final String item;
  final String kata;
  final List<String> suku;

  /// Tingkat kesulitan: jumlah suku kata.
  int get level => suku.length;

  Map<String, Object?> toJson() => {'item': item, 'kata': kata, 'suku': suku};
}

/// Satu kalimat Baca Bersama.
final class KalimatEntry {
  const KalimatEntry({
    required this.id,
    required this.teks,
    required this.gambar,
    this.waktu = (id: null, en: null),
  });

  factory KalimatEntry.fromJson(Object? value) {
    final map = _map(value);
    final waktu = _map(map['waktu']);
    return KalimatEntry(
      id: _str(map['id']),
      teks: Bilingual.fromJson(map['teks']),
      gambar: _str(map['gambar']),
      waktu: (id: _numbersOrNull(waktu['id']), en: _numbersOrNull(waktu['en'])),
    );
  }

  final String id;
  final Bilingual teks;
  final String gambar;
  final ({List<double>? id, List<double>? en}) waktu;

  Map<String, Object?> toJson() => {
    'id': id,
    'teks': teks.toJson(),
    'gambar': gambar,
    'waktu': {'id': waktu.id, 'en': waktu.en},
  };
}

/// Daftar kata Ucapkan per bahasa.
final class UcapkanInfo {
  const UcapkanInfo({this.id = const [], this.en = const []});

  factory UcapkanInfo.fromJson(Object? value) {
    final map = _map(value);
    return UcapkanInfo(
      id: [for (final e in _list(map['id'])) UcapkanEntry.fromJson(e)],
      en: [for (final e in _list(map['en'])) UcapkanEntry.fromJson(e)],
    );
  }

  final List<UcapkanEntry> id;
  final List<UcapkanEntry> en;

  Map<String, Object?> toJson() => {
    'id': [for (final e in id) e.toJson()],
    'en': [for (final e in en) e.toJson()],
  };
}

/// Satu kata Ucapkan: kata, suku kata besar, dan gambarnya.
final class UcapkanEntry {
  const UcapkanEntry({
    required this.kata,
    required this.suku,
    required this.gambar,
  });

  factory UcapkanEntry.fromJson(Object? value) {
    final map = _map(value);
    return UcapkanEntry(
      kata: _str(map['kata']),
      suku: _strings(map['suku']),
      gambar: _str(map['gambar']),
    );
  }

  final String kata;
  final List<String> suku;
  final String gambar;

  Map<String, Object?> toJson() => {
    'kata': kata,
    'suku': suku,
    'gambar': gambar,
  };
}

/// Seluruh isi katalog, dibaca sekali dari `assets/content/katalog.json`.
final class Katalog {
  const Katalog({
    this.versi = 0,
    this.item = const [],
    this.huruf = const [],
    this.angka = const AngkaInfo(),
    this.warna = const [],
    this.bentuk = const [],
    this.sukuKata = const SukuKataInfo(konsonan: '', vokal: [], contoh: {}),
    this.kata = const KataInfo(),
    this.kalimat = const [],
    this.ucapkan = const UcapkanInfo(),
  });

  factory Katalog.fromJson(Object? value) {
    final map = _map(value);
    return Katalog(
      versi: _int(map['versi']),
      item: [for (final e in _list(map['item'])) Item.fromJson(e)],
      huruf: [for (final e in _list(map['huruf'])) HurufEntry.fromJson(e)],
      angka: AngkaInfo.fromJson(map['angka']),
      warna: [for (final e in _list(map['warna'])) WarnaEntry.fromJson(e)],
      bentuk: [for (final e in _list(map['bentuk'])) BentukEntry.fromJson(e)],
      sukuKata: SukuKataInfo.fromJson(map['sukuKata']),
      kata: KataInfo.fromJson(map['kata']),
      kalimat: [
        for (final e in _list(map['kalimat'])) KalimatEntry.fromJson(e),
      ],
      ucapkan: UcapkanInfo.fromJson(map['ucapkan']),
    );
  }

  final int versi;
  final List<Item> item;
  final List<HurufEntry> huruf;
  final AngkaInfo angka;
  final List<WarnaEntry> warna;
  final List<BentukEntry> bentuk;
  final SukuKataInfo sukuKata;
  final KataInfo kata;
  final List<KalimatEntry> kalimat;
  final UcapkanInfo ucapkan;

  Item? byId(String id) {
    for (final entri in item) {
      if (entri.id == id) return entri;
    }
    return null;
  }

  Iterable<Item> byKategori(String kategori) =>
      item.where((entri) => entri.kategori == kategori);

  Map<String, Object?> toJson() => {
    'versi': versi,
    'item': [for (final e in item) e.toJson()],
    'huruf': [for (final e in huruf) e.toJson()],
    'angka': angka.toJson(),
    'warna': [for (final e in warna) e.toJson()],
    'bentuk': [for (final e in bentuk) e.toJson()],
    'sukuKata': sukuKata.toJson(),
    'kata': kata.toJson(),
    'kalimat': [for (final e in kalimat) e.toJson()],
    'ucapkan': ucapkan.toJson(),
  };
}

String _str(Object? value) => value is String ? value : '';

int _int(Object? value) => value is num ? value.toInt() : 0;

double _double(Object? value) => value is num ? value.toDouble() : 0;

List<String> _strings(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is String) e,
      ]
    : const <String>[];

List<String>? _stringsOrNull(Object? value) =>
    value is List ? _strings(value) : null;

List<double>? _numbersOrNull(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is num) e.toDouble(),
      ]
    : null;

List<Object?> _list(Object? value) => value is List ? value : const <Object?>[];

Map<String, Object?> _map(Object? value) => value is Map
    ? {
        for (final e in value.entries)
          if (e.key is String) e.key as String: e.value,
      }
    : const <String, Object?>{};
