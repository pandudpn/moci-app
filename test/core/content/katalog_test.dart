import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/content/tracing.dart';
import 'package:moci/core/lang.dart';

void main() {
  test('entri kucing persis seperti contoh spec', () {
    const json = <String, Object?>{
      'id': 'kucing',
      'kategori': 'hewan',
      'nama': {'id': 'Kucing', 'en': 'Cat'},
      'gambar': 'illustrations/kucing.svg',
      'warna': 'oranye',
      'hewan': {
        'kelompok': 'rumah',
        'bunyi': {'id': 'Meong!', 'en': 'Meow!'},
        'fakta': {
          'id': 'Kucing suka tidur dan bermain.',
          'en': 'Cats love to nap and play.',
        },
      },
      'sukuKata': {
        'id': ['ku', 'cing'],
        'en': null,
      },
    };
    final item = Item.fromJson(json);
    expect(item.nama.of(AppLang.en), 'Cat');
    expect(item.hewan!.bunyi.of(AppLang.id), 'Meong!');
    expect(item.sukuKata.id, ['ku', 'cing']);
    expect(item.sukuKata.en, isNull);
    expect(item.toJson(), json);
  });

  test('90 suku kata berurutan', () {
    final s = SukuKataInfo.fromJson(const {
      'konsonan': 'bcdfghjklmnprstwyz',
      'vokal': ['a', 'i', 'u', 'e', 'o'],
      'contoh': {'id': <String, Object?>{}, 'en': <String, Object?>{}},
    });
    expect(s.semua.length, 90);
    expect(s.semua.take(6), ['ba', 'bi', 'bu', 'be', 'bo', 'ca']);
    expect(s.semua.last, 'zo');
  });

  test('field kosong tidak ditulis, sukuKata dan waktu tetap null', () {
    final item = Item.fromJson(const {
      'id': 'bola',
      'kategori': 'benda',
      'nama': {'id': 'Bola', 'en': 'Ball'},
      'gambar': 'illustrations/bola.svg',
      'sukuKata': {
        'id': ['bo', 'la'],
        'en': ['ba', 'll'],
      },
    });
    expect(item.toJson().containsKey('warna'), isFalse);
    expect(item.toJson().containsKey('hewan'), isFalse);
    expect(item.toJson()['sukuKata'], {
      'id': ['bo', 'la'],
      'en': ['ba', 'll'],
    });

    final kalimat = KalimatEntry.fromJson(const {
      'id': 'bola',
      'teks': {'id': 'Ini bola.', 'en': 'This is a ball.'},
      'gambar': 'illustrations/bola.svg',
    });
    expect(kalimat.waktu, (id: null, en: null));
    expect(kalimat.toJson()['waktu'], {'id': null, 'en': null});
  });

  test('huruf memilih bahasa', () {
    final huruf = HurufEntry.fromJson(const {
      'huruf': 'X',
      'id': {
        'kata': 'Xilofon',
        'gambar': 'xilofon',
        'bunyi': 'ks',
        'nama': 'eks',
      },
      'en': {'kata': 'Box', 'gambar': 'kado', 'bunyi': 'ks', 'nama': 'ex'},
    });
    expect(huruf.of(AppLang.id).kata, 'Xilofon');
    expect(huruf.of(AppLang.en).kata, 'Box');
    expect(huruf.toJson()['en'], {
      'kata': 'Box',
      'gambar': 'kado',
      'bunyi': 'ks',
      'nama': 'ex',
    });
  });

  test('bentuk menyimpan sudut, sisi, dan jenis', () {
    final bentuk = BentukEntry.fromJson(const {
      'id': 'bintang',
      'nama': {'id': 'Bintang', 'en': 'Star'},
      'warna': '#FFD43B',
      'gelap': '#F2A900',
      'path': 'M100 18L124 76Z',
      'wajahX': 100,
      'wajahY': 118,
      'wajahSkala': 0.85,
      'sudutTitik': [
        [100.0, 18.0],
        [124.0, 76.0],
      ],
      'jenis': 'star',
      'sisi': 0,
      'sudut': 5,
      'fakta': {
        'id': 'Bintang punya lima ujung.',
        'en': 'A star has five tips.',
      },
    });
    expect(bentuk.sudut, 5);
    expect(bentuk.sisi, 0);
    expect(bentuk.wajahSkala, 0.85);
    expect(bentuk.sudutTitik.first, (100.0, 18.0));
    expect(bentuk.toJson()['sudutTitik'], [
      [100.0, 18.0],
      [124.0, 76.0],
    ]);
  });

  test('katalog memuat dan mencari', () {
    final katalog = Katalog.fromJson(const {
      'versi': 1,
      'item': [
        {
          'id': 'apel',
          'kategori': 'buah',
          'nama': {'id': 'Apel', 'en': 'Apple'},
          'gambar': 'illustrations/apel.svg',
          'sukuKata': {
            'id': ['a', 'pel'],
            'en': ['ap', 'ple'],
          },
        },
        {
          'id': 'wortel',
          'kategori': 'sayur',
          'nama': {'id': 'Wortel', 'en': 'Carrot'},
          'gambar': 'illustrations/wortel.svg',
          'sukuKata': {
            'id': ['wor', 'tel'],
            'en': null,
          },
        },
      ],
      'huruf': <Object?>[],
      'angka': {
        'maks': 50,
        'rentang': [
          [1, 10],
        ],
        'benda': ['apel'],
      },
      'warna': <Object?>[],
      'bentuk': <Object?>[],
      'sukuKata': {
        'konsonan': 'b',
        'vokal': ['a'],
        'contoh': {
          'id': {
            'ba': {'item': 'badak', 'kata': 'Badak'},
          },
        },
      },
      'kata': {
        'id': [
          {
            'item': 'apel',
            'kata': 'Apel',
            'suku': ['a', 'pel'],
          },
        ],
        'en': <Object?>[],
      },
      'kalimat': <Object?>[],
      'ucapkan': {'id': <Object?>[], 'en': <Object?>[]},
    });
    expect(katalog.item.length, 2);
    expect(katalog.byId('apel')!.nama.of(AppLang.id), 'Apel');
    expect(katalog.byId('naga'), isNull);
    expect(katalog.byKategori('sayur').map((i) => i.id), ['wortel']);
    expect(katalog.angka.rentang, [(1, 10)]);
    expect(katalog.sukuKata.contoh['id']!['ba'], (
      item: 'badak',
      kata: 'Badak',
    ));
    expect(katalog.kata.id.single.level, 2);
    expect(
      katalog.toJson()['item'],
      katalog.item.map((i) => i.toJson()).toList(),
    );
  });

  test('halaman mewarnai bolak balik utuh', () {
    final set = ColoringSet.fromJson(const {
      'versi': 1,
      'kanvas': [800, 600],
      'halaman': [
        {
          'id': 'kupu',
          'kategori': 'hewan',
          'nama': {'id': 'Kupu-kupu', 'en': 'Butterfly'},
          'bagian': [
            {'d': 'M0 0H800V600H0Z'},
            {
              'd': 'M34 80H126Z',
              'evenOdd': true,
              'detail': [
                ['M1 2L3 4', '', 6.0],
                ['M5 6L7 8', '#2B2350', 0.0],
              ],
            },
          ],
          'contoh': {'1': '#FFD43B'},
        },
      ],
    });
    final page = set.halaman.single;
    expect(set.kanvas, [800, 600]);
    expect(page.bagian.length, 2);
    expect(page.bagian.first.evenOdd, isFalse);
    expect(page.bagian.last.evenOdd, isTrue);
    expect(page.bagian.last.detail.first.w, 6.0);
    expect(page.bagian.last.detail.first.fill, '');
    expect(page.contoh, {1: '#FFD43B'});
    expect(set.toJson()['halaman'], [page.toJson()]);
    expect((page.toJson()['contoh'] as Map), {'1': '#FFD43B'});
  });

  test('tracing menyimpan kotak dan goresan', () {
    final set = TracingSet.fromJson(const {
      'versi': 1,
      'kotak': 520,
      'glyph': {
        'A': ['M260 70L130 450', 'M260 70L390 450'],
      },
    });
    expect(set.kotak, 520);
    expect(set.glyph['A'], ['M260 70L130 450', 'M260 70L390 450']);
    expect(set.toJson(), {
      'versi': 1,
      'kotak': 520,
      'glyph': {
        'A': ['M260 70L130 450', 'M260 70L390 450'],
      },
    });
  });

  test('cap dan krayon', () {
    expect(
      Cap.fromJson(const {
        'id': 'moci',
        'nama': {'id': 'Moci', 'en': 'Moci'},
      }).toJson(),
      {
        'id': 'moci',
        'nama': {'id': 'Moci', 'en': 'Moci'},
      },
    );
    expect(
      Krayon.fromJson(const {
        'hex': '#FF4B4B',
        'nama': {'id': 'Merah', 'en': 'Red'},
      }).nama.of(AppLang.en),
      'Red',
    );
  });

  test('bilingual memilih bahasa', () {
    const b = Bilingual('Kucing', 'Cat');
    expect(b.of(AppLang.id), 'Kucing');
    expect(b.of(AppLang.en), 'Cat');
    expect(Bilingual.fromJson(const {'id': 'a'}).en, '');
  });
}
