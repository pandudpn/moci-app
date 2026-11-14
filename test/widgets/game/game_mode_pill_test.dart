import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/theme/moci_colors.dart';
import 'package:moci/widgets/game/game_mode_pill.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('pil mode: tab aktif putih, tab lain tinta, pilihan diteruskan', (
    t,
  ) async {
    var picked = -1;
    await pumpScreen(
      t,
      GameModePill(
        tabs: const [
          GameModeTab(label: 'Kenali'),
          GameModeTab(label: 'Tulis'),
          GameModeTab(label: 'Ucapkan'),
        ],
        selected: 0,
        onSelected: (i) => picked = i,
        semanticLabel: 'Mode belajar',
        accent: const Color(0xFFE8384F),
      ),
    );
    expect(t.widget<Text>(find.text('Kenali')).style?.color, MociColors.white);
    expect(t.widget<Text>(find.text('Tulis')).style?.color, MociColors.ink);
    await t.tap(find.text('Ucapkan'));
    expect(picked, 2);
  });
}
