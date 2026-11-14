import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress.dart';

void main() {
  final spec = <String, Object?>{
    'versi': 1,
    'bintang': 27,
    'stiker': ['apel', 'moci-senang'],
    'kegiatanTerakhir': {
      'rute': '/huruf/tulis',
      'param': {'huruf': 'A'},
    },
    'waktuBermain': {'2026-11-14': 1260},
    'perkembangan': {
      'huruf': {
        'dilihat': ['A', 'B'],
        'ditulis': ['A'],
      },
    },
  };

  test('dateKey mengisi nol di depan', () {
    expect(dateKey(DateTime(2026, 3, 5, 23, 59)), '2026-03-05');
  });

  test('fromJson membaca contoh spec', () {
    final p = Progress.fromJson(spec);
    expect(p.stars, 27);
    expect(p.stickers, ['apel', 'moci-senang']);
    expect(p.lastActivity!.route, '/huruf/tulis');
    expect(p.lastActivity!.params, {'huruf': 'A'});
    expect(p.playSeconds, {'2026-11-14': 1260});
    expect(p.perkembangan['huruf']!['dilihat'], ['A', 'B']);
  });

  test('toJson memuat versi dan stabil setelah dibaca ulang', () {
    final json = Progress.fromJson(spec).toJson();
    expect(json['versi'], 1);
    expect(Progress.fromJson(json).toJson(), json);
  });

  test('harian dibaca dan ditulis', () {
    final p = Progress.fromJson({
      'harian': {
        '2026-11-14': {
          'bintang': 9,
          'stiker': 1,
          'karya': 1,
          'item': {
            'huruf': ['A', 'B'],
          },
        },
      },
    });
    final d = p.harian['2026-11-14']!;
    expect([d.stars, d.stickers, d.karya], [9, 1, 1]);
    expect(d.items['huruf'], ['A', 'B']);
    expect(Progress.fromJson(p.toJson()).toJson(), p.toJson());
  });

  test('field hilang atau salah tipe memakai bawaan', () {
    expect(Progress.fromJson({}).stars, 0);
    expect(Progress.fromJson({'versi': 1, 'bintang': 'banyak'}).stars, 0);
    final p = Progress.fromJson({
      'versi': 7,
      'stiker': 'x',
      'kegiatanTerakhir': 5,
      'waktuBermain': {'2026-11-14': 'lama'},
    });
    expect(p.stickers, isEmpty);
    expect(p.lastActivity, isNull);
    expect(p.playSeconds, isEmpty);
  });

  test('param non-string dibuang', () {
    final p = Progress.fromJson({
      'kegiatanTerakhir': {
        'rute': '/a',
        'param': {'x': 1, 'y': 'z'},
      },
    });
    expect(p.lastActivity!.params, {'y': 'z'});
  });

  test('copyWith bisa menghapus kegiatan terakhir', () {
    const p = Progress(lastActivity: LastActivity('/huruf'));
    expect(p.copyWith().lastActivity, isNotNull);
    expect(p.copyWith(lastActivity: null).lastActivity, isNull);
  });

  test('hitungan negatif di berkas dijepit ke nol', () {
    final p = Progress.fromJson({
      'bintang': -4,
      'harian': {
        '2026-11-14': {'bintang': -1, 'stiker': -2, 'karya': -3},
      },
    });
    expect(p.stars, 0);
    final d = p.harian['2026-11-14']!;
    expect([d.stars, d.stickers, d.karya], [0, 0, 0]);
  });
}
