/// Ekspor sekali jalan dari snapshot prototipe ke `assets/` (keputusan K1).
///
/// Jalankan dengan `fvm dart run tool/konten/ekspor_prototipe.dart` dari akar
/// repo. Hasilnya di-commit, lalu diedit langsung; kalau desain berubah,
/// perubahannya dibawa manual ke JSON, bukan dengan menjalankan ulang ekspor.
library;

import 'dart:convert';
import 'dart:io';

import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/tracing.dart';
import 'package:moci/core/lang.dart';

import 'js_literal.dart';

/// Jumlah per dataset hasil ekspor.
final class EksporHasil {
  const EksporHasil({
    required this.item,
    required this.huruf,
    required this.warna,
    required this.bentuk,
    required this.kataId,
    required this.kataEn,
    required this.kalimat,
    required this.glyphCount,
    required this.strokeCount,
    required this.halaman,
    required this.regionCount,
    required this.cap,
    required this.krayon,
  });

  final int item;
  final int huruf;
  final int warna;
  final int bentuk;
  final int kataId;
  final int kataEn;
  final int kalimat;
  final int glyphCount;
  final int strokeCount;
  final int halaman;
  final int regionCount;
  final int cap;
  final int krayon;
}

/// Urutan kategori di katalog: tema prototipe lalu `lain` (K4).
const _urutanKategori = [
  'buah',
  'sayur',
  'hewan',
  'kendaraan',
  'benda',
  'lain',
];

/// Id warna prototipe yang dirapikan (K3).
const _idWarna = {'merah muda': 'merahmuda', 'abu-abu': 'abu'};

/// Nama kanonis untuk id yang bentrok di prototipe (K2) dan empat benda di
/// luar tema game (K4).
const _namaTetap = <String, ({String id, String en})>{
  'paprika': (id: 'Paprika', en: 'Bell Pepper'),
  'kado': (id: 'Kado', en: 'Gift'),
  'eskrim': (id: 'Es Krim', en: 'Ice Cream'),
  'hujan': (id: 'Hujan', en: 'Rain'),
  'onde': (id: 'Onde-onde', en: 'Sesame Ball'),
  'vas': (id: 'Vas', en: 'Vase'),
  'sarang': (id: 'Sarang', en: 'Nest'),
};

/// Gambar yang bukan isi katalog, dipakai stiker dan ikon Karyaku.
const _gambarLuar = {
  'moci': '0b224341bbd230f2dd731c560e41d4cb',
  'moci-senang': 'c6f764abf556b8252c9552e7fa94a90d',
  'karyaku': '4061ab5bce10e62e630528c89ad08553',
};

Future<void> main() async {
  final hasil = await eksporPrototipe(
    prototipe: Directory('docs/design/prototype'),
    keluaran: Directory('assets'),
  );
  stdout.writeln(
    'item ${hasil.item} · huruf ${hasil.huruf} · warna ${hasil.warna} · '
    'bentuk ${hasil.bentuk} · kata ${hasil.kataId}/${hasil.kataEn} · '
    'kalimat ${hasil.kalimat} · glyph ${hasil.glyphCount} '
    '(${hasil.strokeCount} goresan) · halaman ${hasil.halaman} '
    '(${hasil.regionCount} bagian) · cap ${hasil.cap} · '
    'krayon ${hasil.krayon}',
  );
}

/// Membaca snapshot [prototipe] dan menulis enam berkas JSON ke [keluaran].
Future<EksporHasil> eksporPrototipe({
  required Directory prototipe,
  required Directory keluaran,
}) async {
  final sumber = _Sumber(prototipe);

  final tema = _obj(_literal(sumber, 'Memori.dc.html', 'this._pool =', 127));
  final hewanRows = _rows(_literal(sumber, 'Hewan.dc.html', 'this._d =', 171));
  final buahRows = _rows(_literal(sumber, 'Buah.dc.html', 'this._d =', 169));
  final warnaPicRows = _rows(
    _literal(sumber, 'Warna.dc.html', 'this._p =', 152),
  );
  final warnaRows = _rows(_literal(sumber, 'Warna.dc.html', 'return', 156));
  final angkaPool = _rows(_literal(sumber, 'Angka.dc.html', 'this._p =', 148));
  final angkaRentang = _rows(
    _literal(sumber, 'Angka.dc.html', 'var ranges =', 224),
  );
  final hurufImg = _obj(_literal(sumber, 'Huruf.dc.html', 'var img =', 150));
  final hurufEn = _rows(
    _literal(sumber, 'Huruf.dc.html', "lang === 'en' ?", 162),
  );
  final hurufId = _rows(_literal(sumber, 'Huruf.dc.html', '] : [', 170));
  final bentukRows = _rows(_literal(sumber, 'Bentuk.dc.html', 'return', 190));
  final sukuRows = _obj(_literal(sumber, 'SukuKata.dc.html', 'this._d =', 137));
  final kataRows = _obj(_literal(sumber, 'Kata.dc.html', 'this._w =', 148));
  final kalimatRows = _rows(
    _literal(sumber, 'Kalimat.dc.html', 'this._d =', 147),
  );
  final glyphRows = _obj(_literal(sumber, 'Tulis.dc.html', 'return', 275));
  final halamanList = _list(
    _literal(sumber, 'Mewarnai.dc.html', 'this._pd =', 180),
  );
  final capRows = _rows(_literal(sumber, 'Mewarnai.dc.html', 'return', 245));
  final krayonRows = _rows(
    _literal(sumber, 'Mewarnai.dc.html', 'var pal =', 335),
  );
  final karya = _obj(_literal(sumber, 'Karyaku.dc.html', 'this._d =', 141));
  final galeriRows = _rows(_literal(sumber, 'Galeri.dc.html', 'var P =', 106));

  // Indeks blob → id dari semua dataset, lalu gambar non-katalog.
  final indeks = _Indeks();
  final namaTema = <String, ({String id, String en})>{};
  final urutanTema = <String, List<String>>{};
  for (final entry in tema.entries) {
    final ids = urutanTema.putIfAbsent(entry.key, () => []);
    for (final row in _rows(entry.value)) {
      final id = _s(row[0]);
      indeks.tambah(_s(row[3]), id);
      ids.add(id);
      namaTema[id] = (id: _s(row[1]), en: _s(row[2]));
    }
  }
  final namaLain = <String, ({String id, String en})>{};
  for (final rows in [hewanRows, buahRows, warnaPicRows, angkaPool]) {
    for (final row in rows) {
      final id = _s(row[0]);
      indeks.tambah(_s(row[3]), id);
      namaLain.putIfAbsent(id, () => (id: _s(row[1]), en: _s(row[2])));
    }
  }
  for (final entry in hurufImg.entries) {
    indeks.tambah(_s(entry.value), entry.key);
  }
  if (indeks.blobKeId.length != 107) {
    throw StateError(
      'indeks blob berisi ${indeks.blobKeId.length} id, seharusnya 107',
    );
  }
  for (final entry in _gambarLuar.entries) {
    indeks.tambah(entry.value, entry.key);
  }

  Bilingual namaItem(String id) {
    final tetap = _namaTetap[id];
    if (tetap != null) return Bilingual(tetap.id, tetap.en);
    final dariTema = namaTema[id];
    if (dariTema != null) return Bilingual(dariTema.id, dariTema.en);
    final lain = namaLain[id];
    if (lain != null) return Bilingual(lain.id, lain.en);
    throw StateError('nama untuk "$id" tidak ada di prototipe');
  }

  final warnaTag = <String, String>{
    for (final row in warnaPicRows)
      _s(row[0]): _idWarna[_s(row[4])] ?? _s(row[4]),
  };
  final hewanInfo = <String, HewanInfo>{
    for (final row in hewanRows)
      _s(row[0]): HewanInfo(
        kelompok: _s(row[4]),
        bunyi: Bilingual(_s(row[5]), _s(row[6])),
        fakta: Bilingual(_s(row[7]), _s(row[8])),
      ),
  };
  final sukuKataData =
      <String, Map<String, ({String kata, List<String> suku})>>{
        'id': {
          for (final row in _rows(kataRows['id']))
            _s(row[0]): (kata: _s(row[1]), suku: _strings(row[2])),
        },
        'en': {
          for (final row in _rows(kataRows['en']))
            _s(row[0]): (kata: _s(row[1]), suku: _strings(row[2])),
        },
      };

  List<String>? sukuUntuk(String id, AppLang lang, Bilingual nama) {
    final data = sukuKataData[lang == AppLang.en ? 'en' : 'id']![id];
    if (data == null) return null;
    return data.kata.toLowerCase() == nama.of(lang).toLowerCase()
        ? data.suku
        : null;
  }

  // Empat benda di luar tema game, urut seperti peta gambar Huruf (K4).
  final idLain = [
    for (final k in hurufImg.keys)
      if (!namaTema.containsKey(k)) k,
  ];

  final item = <Item>[];
  for (final kategori in _urutanKategori) {
    for (final id in kategori == 'lain' ? idLain : urutanTema[kategori]!) {
      final nama = namaItem(id);
      item.add(
        Item(
          id: id,
          kategori: kategori,
          nama: nama,
          gambar: 'illustrations/$id.svg',
          warna: warnaTag[id],
          hewan: hewanInfo[id],
          sukuKata: (
            id: sukuUntuk(id, AppLang.id, nama),
            en: sukuUntuk(id, AppLang.en, nama),
          ),
        ),
      );
    }
  }
  if (item.length != 107) {
    throw StateError('katalog berisi ${item.length} item, seharusnya 107');
  }

  final huruf = <HurufEntry>[
    for (var i = 0; i < hurufEn.length; i++)
      _huruf(hurufEn[i], hurufId[i], hurufImg, indeks),
  ];

  final rentang = [for (final row in angkaRentang) (_i(row[0]), _i(row[1]))];
  final angka = AngkaInfo(
    maks: rentang.last.$2,
    rentang: rentang,
    benda: [for (final row in angkaPool) _s(row[0])],
  );

  final warna = [
    for (final row in warnaRows)
      WarnaEntry(
        id: _idWarna[_s(row[0])] ?? _s(row[0]),
        nama: Bilingual(_s(row[1]), _s(row[2])),
        hex: _s(row[3]),
        teks: _s(row[4]),
        garis: _s(row[5]),
      ),
  ];

  final bentuk = [
    for (final row in bentukRows)
      BentukEntry(
        id: _s(row[0]),
        nama: Bilingual(_s(row[1]), _s(row[2])),
        warna: _s(row[3]),
        gelap: _s(row[4]),
        path: _s(row[5]),
        wajahX: _d(row[6]),
        wajahY: _d(row[7]),
        wajahSkala: _d(row[8]),
        sudutTitik: [
          for (final titik in _rows(row[9])) (_d(titik[0]), _d(titik[1])),
        ],
        jenis: _s(row[10]),
        sisi: _s(row[10]) == 'poly' ? _rows(row[9]).length : 0,
        sudut: _rows(row[9]).length,
        fakta: Bilingual(_s(row[11]), _s(row[12])),
      ),
  ];

  final contohSuku = <String, Map<String, ({String item, String kata})>>{
    for (final bahasa in sukuRows.entries) bahasa.key: {},
  };
  for (final bahasa in sukuRows.entries) {
    for (final entry in _obj(bahasa.value).entries) {
      final row = _list(entry.value);
      contohSuku[bahasa.key]![entry.key] = (item: _s(row[0]), kata: _s(row[1]));
    }
  }
  final sukuKata = SukuKataInfo(
    konsonan: 'bcdfghjklmnprstwyz',
    vokal: const ['a', 'i', 'u', 'e', 'o'],
    contoh: contohSuku,
  );

  final kata = KataInfo(
    id: [
      for (final row in _rows(kataRows['id']))
        KataEntry(item: _s(row[0]), kata: _s(row[1]), suku: _strings(row[2])),
    ],
    en: [
      for (final row in _rows(kataRows['en']))
        KataEntry(item: _s(row[0]), kata: _s(row[1]), suku: _strings(row[2])),
    ],
  );

  final kalimat = [
    for (final row in kalimatRows)
      KalimatEntry(
        id: _s(row[0]),
        teks: Bilingual(_s(row[1]), _s(row[2])),
        gambar: 'illustrations/${indeks.id(_s(row[3]))}.svg',
      ),
  ];

  UcapkanEntry ucapkanDari(Object? nilai) {
    final map = _obj(nilai);
    final blob = _s(map['img']).replaceFirst('/_blob/', '');
    return UcapkanEntry(
      kata: _s(map['w']),
      suku: _strings(map['syl']),
      gambar: 'illustrations/${indeks.id(blob)}.svg',
    );
  }

  final ucapkanBruto = _ucapkan(sumber);
  final ucapkan = UcapkanInfo(
    id: [for (final e in ucapkanBruto.id) ucapkanDari(e)],
    en: [for (final e in ucapkanBruto.en) ucapkanDari(e)],
  );

  final hurufGlyph = <String, List<String>>{};
  final angkaGlyph = <String, List<String>>{};
  for (final entry in glyphRows.entries) {
    final goresan = _strings(entry.value);
    if (RegExp(r'^[A-Z]$').hasMatch(entry.key)) {
      hurufGlyph[entry.key] = goresan;
    } else {
      angkaGlyph[entry.key] = goresan;
    }
  }
  final hurufTracing = TracingSet(versi: 1, kotak: 520, glyph: hurufGlyph);
  final angkaTracing = TracingSet(versi: 1, kotak: 520, glyph: angkaGlyph);

  final contohKarya = <String, Map<int, String>>{};
  for (final karyaRow in _list(karya['demo'])) {
    final demo = _obj(karyaRow);
    final fills = _obj(demo['fills']);
    if (fills.isEmpty) continue;
    contohKarya[_s(demo['pid'])] = {
      for (final entry in fills.entries)
        ?int.tryParse(entry.key): _s(entry.value),
    };
  }
  final halamanData = <String, Map<String, Object?>>{
    for (final page in halamanList) _s(_obj(page)['id']): _obj(page),
  };
  final halaman = <ColoringPage>[];
  for (final galeri in galeriRows) {
    final id = _s(galeri[0]);
    final data = halamanData[id];
    if (data == null) {
      throw StateError('halaman mewarnai "$id" tidak ada di Mewarnai');
    }
    halaman.add(_halaman(id: id, data: data, contohKarya: contohKarya));
  }

  final cap = [
    for (final row in capRows)
      Cap(
        id: indeks.id(_s(row[0]).replaceFirst('/_blob/', '')),
        nama: _namaCap(row, item, indeks),
      ),
  ];
  final krayon = [
    for (final row in krayonRows)
      Krayon(hex: _s(row[0]), nama: Bilingual(_s(row[1]), _s(row[2]))),
  ];

  final katalog = Katalog(
    versi: 1,
    item: item,
    huruf: huruf,
    angka: angka,
    warna: warna,
    bentuk: bentuk,
    sukuKata: sukuKata,
    kata: kata,
    kalimat: kalimat,
    ucapkan: ucapkan,
  );

  final berkas = <String, Object?>{
    'content/katalog.json': katalog.toJson(),
    'tracing/huruf.json': hurufTracing.toJson(),
    'tracing/angka.json': angkaTracing.toJson(),
    'coloring/pages.json': ColoringSet(
      versi: 1,
      kanvas: const [800, 600],
      halaman: halaman,
    ).toJson(),
    'coloring/cap.json': [for (final e in cap) e.toJson()],
    'coloring/krayon.json': [for (final e in krayon) e.toJson()],
  };
  for (final entry in berkas.entries) {
    final file = File('${keluaran.path}/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent(' ').convert(entry.value)}\n',
    );
  }

  return EksporHasil(
    item: item.length,
    huruf: huruf.length,
    warna: warna.length,
    bentuk: bentuk.length,
    kataId: kata.id.length,
    kataEn: kata.en.length,
    kalimat: kalimat.length,
    glyphCount: hurufGlyph.length + angkaGlyph.length,
    strokeCount:
        hurufGlyph.values.fold(0, (n, g) => n + g.length) +
        angkaGlyph.values.fold(0, (n, g) => n + g.length),
    halaman: halaman.length,
    regionCount: halaman.fold(0, (n, p) => n + p.bagian.length),
    cap: cap.length,
    krayon: krayon.length,
  );
}

HurufEntry _huruf(
  Object? barisEn,
  Object? barisId,
  Map<String, Object?> hurufImg,
  _Indeks indeks,
) {
  final en = _list(barisEn);
  final id = _list(barisId);
  if (_s(en[0]) != _s(id[0])) {
    throw StateError('huruf ${_s(en[0])} dan ${_s(id[0])} tidak sejajar');
  }
  HurufBahasa bahasa(List<Object?> row) => HurufBahasa(
    kata: _s(row[1]),
    gambar: indeks.id(_s(hurufImg[_s(row[2])])),
    bunyi: _s(row[3]),
    nama: _s(row[5]),
  );
  return HurufEntry(huruf: _s(en[0]), id: bahasa(id), en: bahasa(en));
}

/// Halaman mewarnai dari data Mewarnai, diurutkan seperti Galeri (K8).
ColoringPage _halaman({
  required String id,
  required Map<String, Object?> data,
  required Map<String, Map<int, String>> contohKarya,
}) {
  final nama = _list(data['n']);
  final bagian = [
    for (final region in _list(data['r']))
      ColoringRegion(
        d: _s(_obj(region)['d']),
        evenOdd: _i(_obj(region)['e']) == 1,
        detail: [
          for (final detail in _rows(_obj(region)['x']))
            (d: _s(detail[0]), fill: _s(detail[1]), w: _d(detail[2])),
        ],
      ),
  ];
  final demo = _obj(data['demo']);
  final contoh = demo.isNotEmpty
      ? {
          for (final entry in demo.entries)
            ?int.tryParse(entry.key): _s(entry.value),
        }
      : contohKarya[id] ?? const <int, String>{};
  return ColoringPage(
    id: id,
    kategori: _s(data['c']),
    nama: Bilingual(_s(nama[0]), _s(nama[1])),
    bagian: bagian,
    contoh: contoh,
  );
}

/// Nama stiker memakai nama katalog kalau id-nya benda katalog (K2).
Bilingual _namaCap(Object? baris, List<Item> item, _Indeks indeks) {
  final row = _list(baris);
  final id = indeks.id(_s(row[0]).replaceFirst('/_blob/', ''));
  for (final entri in item) {
    if (entri.id == id) return entri.nama;
  }
  return Bilingual(_s(row[1]), _s(row[2]));
}

({List<Object?> id, List<Object?> en}) _ucapkan(_Sumber sumber) {
  final isi = sumber
      .potongan('Ucapkan.dc.html', 174, 190)
      .replaceAll("B + '", "'");
  final en = <Object?>[];
  final id = <Object?>[];
  var fase = '';
  for (final baris in isi.split('\n')) {
    if (baris.contains("lang === 'en' ?")) {
      fase = 'en';
      continue;
    }
    if (baris.trimLeft().startsWith('] : [')) {
      fase = 'id';
      continue;
    }
    final awal = baris.indexOf('{');
    if (fase.isEmpty || awal < 0) continue;
    final nilai = parseJsLiteral(baris, awal).$1;
    (fase == 'en' ? en : id).add(nilai);
  }
  return (id: id, en: en);
}

Object? _literal(_Sumber sumber, String nama, String penanda, int dariBaris) =>
    sumber.literal(nama, penanda, dariBaris: dariBaris);

final class _Sumber {
  _Sumber(this.dir);

  final Directory dir;
  final Map<String, String> _cache = {};

  String teks(String nama) => _cache.putIfAbsent(
    nama,
    () => File('${dir.path}/$nama').readAsStringSync(),
  );

  /// Literal JS pertama sesudah [penanda] yang muncul pada atau sesudah
  /// [dariBaris].
  Object? literal(String nama, String penanda, {int dariBaris = 1}) {
    final isi = teks(nama);
    final awal = _offsetBaris(isi, dariBaris);
    final at = isi.indexOf(penanda, awal);
    if (at < 0) {
      throw StateError('$nama: penanda "$penanda" tidak ada');
    }
    // Penanda yang berakhir dengan "[" atau "{" sudah memuat awal literal.
    final akhirPenanda = penanda[penanda.length - 1];
    final geser = akhirPenanda == '[' || akhirPenanda == '{' ? 1 : 0;
    return parseJsLiteral(isi, at + penanda.length - geser).$1;
  }

  /// Potongan berkas dari baris [dari] sampai sebelum baris [sampai].
  String potongan(String nama, int dari, int sampai) {
    final isi = teks(nama);
    return isi.substring(_offsetBaris(isi, dari), _offsetBaris(isi, sampai));
  }

  int _offsetBaris(String isi, int baris) {
    var offset = 0;
    for (var i = 1; i < baris; i++) {
      final next = isi.indexOf('\n', offset);
      if (next < 0) return isi.length;
      offset = next + 1;
    }
    return offset;
  }
}

final class _Indeks {
  final Map<String, String> blobKeId = {};

  void tambah(String blob, String id) {
    if (blob.isEmpty || id.isEmpty) return;
    final lama = blobKeId[blob];
    if (lama != null && lama != id) {
      throw StateError('blob $blob dipakai "$lama" dan "$id"');
    }
    blobKeId[blob] = id;
  }

  String id(String blob) {
    final hasil = blobKeId[blob];
    if (hasil == null) {
      throw StateError('blob "$blob" tidak ada di dataset prototipe');
    }
    return hasil;
  }
}

String _s(Object? value) => value is String ? value : '';

int _i(Object? value) => value is num ? value.toInt() : 0;

double _d(Object? value) => value is num ? value.toDouble() : 0;

List<String> _strings(Object? value) => value is List
    ? [
        for (final e in value)
          if (e is String) e,
      ]
    : const <String>[];

List<Object?> _list(Object? value) =>
    value is List ? value.cast<Object?>() : const <Object?>[];

List<List<Object?>> _rows(Object? value) =>
    value is List ? [for (final e in value) _list(e)] : const <List<Object?>>[];

Map<String, Object?> _obj(Object? value) => value is Map
    ? {
        for (final e in value.entries)
          if (e.key is String) e.key as String: e.value,
      }
    : const <String, Object?>{};
