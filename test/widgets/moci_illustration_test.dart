import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/widgets/moci_illustration.dart';
import 'package:vector_graphics/vector_graphics.dart';

const _ids = [
  'kucing', 'ikan', 'singa', 'gajah', 'panda', 'pinguin', 'apel', 'pisang',
  'stroberi', 'semangka', 'nanas', 'buahnaga', 'wortel', 'tomat', 'brokoli',
  'jagung', 'labu', 'jamur', 'mobil', 'bus', 'kereta', 'pesawat', 'kapal',
  'roket', 'bola', 'balon', 'kado', 'eskrim', 'layang', 'payung', 'sapi',
  'buku', 'xilofon', 'karyaku', 'moci', 'moci-senang', 'moci-tidur', //
];

void main() {
  test('semua ilustrasi ada sebagai berkas', () {
    for (final id in _ids) {
      expect(
        File('assets/illustrations/$id.svg').existsSync(),
        isTrue,
        reason: id,
      );
    }
  });

  testWidgets('MociIllustration merender apel (transformer berjalan)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: MociIllustration('apel', size: 80)),
      ),
    );
    await tester.runAsync(
      () => vg.loadPicture(
        const AssetBytesLoader('assets/illustrations/apel.svg'),
        null,
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(MociIllustration)), const Size(80, 80));
    expect(find.byType(VectorGraphic), findsOneWidget);
  });

  testWidgets('silhouette memasang filter warna', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: MociIllustration('apel', silhouette: true),
      ),
    );
    final g = tester.widget<VectorGraphic>(find.byType(VectorGraphic));
    expect(g.colorFilter, isNotNull);
  });
}
