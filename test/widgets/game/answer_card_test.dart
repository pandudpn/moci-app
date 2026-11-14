import 'package:flutter_test/flutter_test.dart';
import 'package:moci/widgets/game/answer_card.dart';
import 'package:moci/widgets/moci_illustration.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('kartu jawaban: gambar, label, ketukan, dan tanda benar', (
    t,
  ) async {
    var taps = 0;
    await pumpScreen(
      t,
      AnswerCard(
        illustration: 'apel',
        text: 'Apel',
        semanticLabel: 'Apel',
        onTap: () => taps++,
        state: AnswerCardState.correct,
      ),
    );
    expect(find.byType(MociIllustration), findsOneWidget);
    expect(find.byKey(AnswerCard.badgeKey), findsOneWidget);
    await t.tap(find.text('Apel'));
    expect(taps, 1);
  });
}
