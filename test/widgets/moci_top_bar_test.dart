import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/widgets/moci_top_bar.dart';

import '../helpers/harness.dart';

const _long =
    'Area Orang Tua dan Pengaturan Harian yang Judulnya Jauh Lebih Panjang';

void main() {
  testWidgets('judul panjang: satu baris dengan elipsis, tanpa luberan', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, child: MociTopBar(title: _long)),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(_long));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(
      tester.getSize(find.text(_long)).width,
      lessThanOrEqualTo(320),
      reason: 'judul tidak melebar melewati bilah',
    );
  });
}
