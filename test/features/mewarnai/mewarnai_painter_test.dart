import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';
import 'package:moci/features/mewarnai/mewarnai_painter.dart';

ColoringPage _duaBagian() => const ColoringPage(
  id: 'uji',
  kategori: 'benda',
  nama: Bilingual('Uji', 'Test'),
  bagian: [
    ColoringRegion(d: 'M0 0H100V100H0Z'),
    ColoringRegion(d: 'M200 0H400V100H200Z'),
  ],
);

/// `decodeImageFromList` di SDK ini memakai callback, bukan Future.
Future<Image> _gambar(Uint8List bytes) async {
  final codec = await instantiateImageCodec(bytes);
  return (await codec.getNextFrame()).image;
}

void main() {
  testWidgets('ekspor PNG 300 x 225 dengan tanda berkas PNG', (t) async {
    final bytes = await t.runAsync(
      () => renderKaryaPng(
        halaman: _duaBagian(),
        data: const KaryaData(halaman: 'uji', isian: {0: '#FF4B4B'}),
      ),
    );
    expect(bytes!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    final img = await t.runAsync(() => _gambar(bytes));
    expect((img!.width, img.height), (300, 225));
  });

  testWidgets('ekspor PNG memotong coretan ke bagiannya', (t) async {
    const halaman = ColoringPage(
      id: 'uji',
      kategori: 'benda',
      nama: Bilingual('Uji', 'Test'),
      bagian: [
        ColoringRegion(d: 'M0 0H400V600H0Z'),
        ColoringRegion(d: 'M400 0H800V600H400Z'),
      ],
    );
    const data = KaryaData(
      halaman: 'uji',
      isian: {1: '#1C7ED6'},
      coretan: {
        0: [Coretan(d: 'M50 300L600 300', warna: '#FF4B4B', lebar: 26)],
      },
    );
    final bytes = await t.runAsync(
      () => renderKaryaPng(halaman: halaman, data: data),
    );
    final img = await t.runAsync(() => _gambar(bytes!));
    final raw = await t.runAsync(
      () => img!.toByteData(format: ImageByteFormat.rawRgba),
    );
    int merah(int x, int y) {
      final o = (y * 300 + x) * 4;
      return raw!.buffer.asUint8List()[o];
    }

    // Skala 300 / 800 = 0,375. Batas bagian 0/1 di x = 400 unit = 150 px.
    expect(merah(40, 112), greaterThan(200));
    expect(merah(170, 112), lessThan(120));
    expect(
      raw!.buffer.asUint8List()[(112 * 300 + 170) * 4 + 2],
      greaterThan(180),
    );
  });
}
