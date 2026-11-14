import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/moci_stage.dart';
import 'package:moci/app/theme/menu_theme.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/widgets/star_counter.dart';

import '../helpers/harness.dart';

void main() {
  testWidgets('menampilkan jumlah bintang', (tester) async {
    await pumpScreen(
      tester,
      const MenuThemeScope(
        theme: MenuTheme.huruf,
        child: Center(child: StarCounter()),
      ),
      env: TestEnv(progress: const Progress(stars: 27)),
    );
    expect(find.text('27'), findsOneWidget);
    expect(tester.getSize(find.byType(StarCounter)).height, 64);
  });
}
