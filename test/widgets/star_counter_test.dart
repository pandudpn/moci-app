import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/moci_stage.dart';
import 'package:moci/app/theme/menu_theme.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:material_ui/material_ui.dart' show showDialog;
import 'package:moci/widgets/moci_button.dart';
import 'package:moci/widgets/pressable.dart';
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

  testWidgets('tanpa MenuThemeScope (rute dialog) tidak melempar', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StarCounter(),
                  MociPressable(onTap: () {}, child: const SizedBox(width: 50)),
                  MociButton(
                    label: 'Ok',
                    kind: MociButtonKind.light,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(StarCounter), findsOneWidget);
    expect(find.byType(MociButton), findsOneWidget);
  });

  test('bintang memakai path prototipe, diskalakan 40 -> 38', () {
    final b = starPath(const Size(38, 38)).getBounds();
    expect(b.left, closeTo(3.1 * 0.95, 0.01));
    expect(b.right, closeTo(36.9 * 0.95, 0.01));
    expect(b.top, closeTo(3 * 0.95, 0.01));
    expect(b.bottom, closeTo(35.1 * 0.95, 0.01));
  });
}
