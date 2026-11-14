import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/theme/moci_colors.dart';
import 'package:moci/widgets/game/progress_dots.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('titik kemajuan: aktif lebih lebar, yang lewat hijau', (t) async {
    await pumpScreen(
      t,
      const ProgressDots(count: 5, current: 2, semanticLabel: 'Kemajuan'),
    );
    expect(t.getSize(find.byKey(ProgressDots.dotKey(2))).width, 30);
    expect(t.getSize(find.byKey(ProgressDots.dotKey(1))).width, 12);
    expect(
      (t.widget<DecoratedBox>(find.byKey(ProgressDots.dotKey(1))).decoration
              as BoxDecoration)
          .color,
      MociColors.correct,
    );
  });
}
