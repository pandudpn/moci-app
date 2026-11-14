import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/audio/narrator.dart';
import 'package:moci/widgets/game/game_instruction.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('kotak instruksi membacakan baris narasi', (t) async {
    final env = TestEnv();
    await pumpScreen(
      t,
      GameInstruction(
        title: 'Hitung bareng',
        text: 'Ketuk benda satu per satu',
        semanticLabel: 'Instruksi',
        narration: const [
          NarrationLine(jenis: 'ui', id: 'angkaAutoSay', text: 'Hitung bareng'),
        ],
        listenLabel: 'Dengar instruksi',
      ),
      env: env,
    );
    await t.tap(find.byKey(GameInstruction.listenKey));
    expect(env.tts.spoken.single.$1, 'Hitung bareng');
  });

  testWidgets('tanpa narasi tidak ada tombol dengar', (t) async {
    await pumpScreen(
      t,
      const GameInstruction(title: 'A', text: 'B', semanticLabel: 'Instruksi'),
    );
    expect(find.byKey(GameInstruction.listenKey), findsNothing);
  });
}
