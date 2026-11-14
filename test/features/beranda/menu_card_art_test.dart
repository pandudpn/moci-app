import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/beranda/beranda_menu.dart';
import 'package:moci/features/beranda/widgets/menu_card_art.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('gambar kartu yang bergerak punya lapisan repaint sendiri', (
    tester,
  ) async {
    for (final menu in [BerandaMenu.huruf, BerandaMenu.angka]) {
      await pumpScreen(
        tester,
        Center(
          child: SizedBox.fromSize(size: menuArtSize, child: MenuCardArt(menu)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        find.descendant(
          of: find.byType(MenuCardArt),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
        reason: '$menu',
      );
      expect(tester.takeException(), isNull);
    }
  });
}
