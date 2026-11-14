import 'package:flutter_test/flutter_test.dart';
import 'package:moci/widgets/game/game_glyphs.dart';
import 'package:moci/widgets/game/mic_button.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('tombol mikrofon: dua cincin saat mendengar', (t) async {
    await pumpScreen(
      t,
      MicButton(
        phase: MicPhase.listening,
        onTap: () {},
        semanticLabel: 'Moci mendengarkan',
      ),
    );
    expect(find.byKey(MicButton.ringsKey), findsNWidgets(2));
  });

  testWidgets('tombol mikrofon: centang saat berhasil', (t) async {
    await pumpScreen(
      t,
      MicButton(phase: MicPhase.good, onTap: () {}, semanticLabel: 'Bagus'),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is GameGlyph && w.kind == GameGlyphKind.check,
      ),
      findsOneWidget,
    );
  });
}
