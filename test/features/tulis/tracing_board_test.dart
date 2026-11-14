import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/tulis/tracing_board.dart';

import '../../helpers/harness.dart';

Future<void> _trace(WidgetTester t, Offset a, Offset b) async {
  final r = t.getRect(find.byKey(TracingBoard.surfaceKey));
  Offset p(Offset v) =>
      Offset(r.left + v.dx * r.width / 520, r.top + v.dy * r.height / 520);
  final g = await t.startGesture(p(a));
  for (var i = 1; i <= 20; i++) {
    await g.moveTo(p(Offset.lerp(a, b, i / 20)!));
    await t.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await t.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('mengikuti jalur menyelesaikan goresan', (t) async {
    var done = 0, strokes = 0, wrong = 0;
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M0 0L100 0'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis huruf A',
            onStrokeDone: (_) => strokes++,
            onDone: () => done++,
            onWrongStart: () => wrong++,
          ),
        ),
      ),
    );
    await _trace(t, Offset.zero, const Offset(100, 0));
    expect((strokes, done, wrong), (1, 1, 0));
  });

  testWidgets('mulai jauh dari titik pandu tidak memajukan goresan', (t) async {
    var done = 0, wrong = 0;
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M0 0L100 0'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis',
            onDone: () => done++,
            onWrongStart: () => wrong++,
          ),
        ),
      ),
    );
    await _trace(t, const Offset(400, 400), const Offset(400, 200));
    expect((wrong, done), (1, 0));
  });

  testWidgets('kunci baru mengulang dari goresan pertama', (t) async {
    var progress = <int>[];
    Widget board(String key) => Center(
      child: SizedBox(
        width: 520,
        height: 520,
        child: TracingBoard(
          key: ValueKey(key),
          paths: const ['M0 0L100 0'],
          ink: const Color(0xFFE8384F),
          semanticLabel: 'Area menulis',
          onProgress: (i, _) => progress.add(i),
        ),
      ),
    );
    await pumpScreen(t, board('a'));
    await _trace(t, Offset.zero, const Offset(100, 0));
    // Guide satu goresan: tidak ada goresan berikutnya yang dilaporkan.
    expect(progress.last, 0);
    await pumpScreen(t, board('b'));
    expect(progress.sublist(progress.length - 2), [0, 0]);
    expect(t.takeException(), isNull);
  });
}
