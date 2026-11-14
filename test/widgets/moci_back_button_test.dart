import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/moci_stage.dart';
import 'package:moci/app/theme/menu_theme.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/widgets/moci_back_button.dart';

import '../helpers/harness.dart';

const _host = MenuThemeScope(
  theme: MenuTheme.huruf,
  child: Align(alignment: Alignment.topLeft, child: MociBackButton()),
);

void main() {
  testWidgets('ukuran 76 x 76; bayangan tidak memakan tempat', (tester) async {
    await pumpScreen(tester, _host);
    expect(tester.getSize(find.byType(MociBackButton)), const Size(76, 76));
  });

  testWidgets('label semantik mengikuti bahasa', (tester) async {
    await pumpScreen(tester, _host);
    expect(find.bySemanticsLabel('Kembali ke beranda'), findsOneWidget);
    await pumpScreen(tester, _host, env: TestEnv(lang: AppLang.en));
    expect(find.bySemanticsLabel('Back to home'), findsOneWidget);
  });

  testWidgets('onTap khusus dipanggil', (tester) async {
    var n = 0;
    await pumpScreen(
      tester,
      MenuThemeScope(
        theme: MenuTheme.huruf,
        child: Align(
          alignment: Alignment.topLeft,
          child: MociBackButton(onTap: () => n++),
        ),
      ),
    );
    await tester.tap(find.byType(MociBackButton));
    await tester.pump();
    expect(n, 1);
  });
}
