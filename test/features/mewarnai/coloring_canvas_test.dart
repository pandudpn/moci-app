import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/bilingual.dart';
import 'package:moci/core/content/coloring.dart';
import 'package:moci/features/mewarnai/mewarnai_engine.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';
import 'package:moci/features/mewarnai/widgets/coloring_canvas.dart';

import '../../helpers/harness.dart';

ColoringPage _duaBagian() => const ColoringPage(
  id: 'uji',
  kategori: 'benda',
  nama: Bilingual('Uji', 'Test'),
  bagian: [
    ColoringRegion(d: 'M0 0H100V100H0Z'),
    ColoringRegion(d: 'M200 0H400V100H200Z'),
  ],
);

Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft +
    Offset(x, y) * skalaLayar;

void main() {
  testWidgets('ketuk dengan alat isi mewarnai bagian', (t) async {
    final mesin = MesinMewarnai(halaman: _duaBagian())
      ..pilihAlat(AlatMewarnai.isi);
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 864,
          height: 648,
          child: ColoringCanvas(
            mesin: mesin,
            cap: const {},
            semanticLabel: 'Gambar untuk diwarnai',
          ),
        ),
      ),
    );
    expect(
      t.getSize(find.byKey(ColoringCanvas.surfaceKey)),
      const Size(864, 648),
    );
    await t.tapAt(_kanvas(t, 10, 10));
    expect(mesin.data.isian[0], '#74C0FC');
    expect(mesin.data.isian[1], isNull);
  });

  testWidgets('geser kuas mencatat satu coretan', (t) async {
    final mesin = MesinMewarnai(halaman: _duaBagian());
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 864,
          height: 648,
          child: ColoringCanvas(
            mesin: mesin,
            cap: const {},
            semanticLabel: 'Kanvas',
          ),
        ),
      ),
    );
    final g = await t.startGesture(_kanvas(t, 10, 10));
    for (var i = 1; i <= 8; i++) {
      await g.moveTo(_kanvas(t, 10 + i * 10, 10));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await t.pump();
    expect(mesin.data.coretan[0], hasLength(1));
    expect(mesin.data.coretan[1], isNull);
  });
}
