import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/tulis/tracing_board.dart';
import 'package:moci/features/tulis/tracing_engine.dart';
import 'package:moci/widgets/moci_mascot.dart';

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

Offset Function(Offset) _papan(WidgetTester t) {
  final r = t.getRect(find.byKey(TracingBoard.surfaceKey));
  return (v) =>
      Offset(r.left + v.dx * r.width / 520, r.top + v.dy * r.height / 520);
}

TracingBoardState _keadaan(WidgetTester t) =>
    t.state<TracingBoardState>(find.byType(TracingBoard));

TracingPainter _tintaStatis(WidgetTester t) =>
    t.widget<CustomPaint>(find.byKey(TracingBoard.staticLayerKey)).painter!
        as TracingPainter;

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
  testWidgets('tinta goresan terakhir tetap ada setelah selesai', (t) async {
    var done = 0;
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M0 0L100 0'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis huruf O',
            onDone: () => done++,
          ),
        ),
      ),
    );
    expect(_tintaStatis(t).goresanBertinta, 0);
    await _trace(t, Offset.zero, const Offset(100, 0));
    expect(done, 1);
    expect(_keadaan(t).session.selesai, isTrue);
    expect(_keadaan(t).session.goresanSelesai, 1);
    expect(_tintaStatis(t).goresanBertinta, 1);
  });

  testWidgets('semua goresan bertinta setelah huruf dua goresan', (t) async {
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M0 0L100 0', 'M0 100L100 100'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis huruf L',
          ),
        ),
      ),
    );
    await _trace(t, Offset.zero, const Offset(100, 0));
    expect(_tintaStatis(t).goresanBertinta, 1);
    await _trace(t, const Offset(0, 100), const Offset(100, 100));
    expect(_keadaan(t).session.selesai, isTrue);
    expect(_tintaStatis(t).goresanBertinta, 2);
  });

  testWidgets('sapuan cepat tiga gerakan sampai ujung', (t) async {
    var done = 0;
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M260 70L260 450'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis angka 1',
            onDone: () => done++,
          ),
        ),
      ),
    );
    final p = _papan(t);
    final g = await t.startGesture(p(const Offset(260, 70)));
    for (final y in [200.0, 330.0, 450.0]) {
      await g.moveTo(p(Offset(260, y)));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await t.pump(const Duration(milliseconds: 100));
    expect(done, 1);
  });

  testWidgets('enam puluh gerakan naik terus tanpa lompat', (t) async {
    await pumpScreen(
      t,
      Center(
        child: SizedBox(
          width: 520,
          height: 520,
          child: TracingBoard(
            paths: const ['M260 70L260 450'],
            ink: const Color(0xFFE8384F),
            semanticLabel: 'Area menulis angka 1',
          ),
        ),
      ),
    );
    final p = _papan(t);
    final g = await t.startGesture(p(const Offset(260, 70)));
    var goresan = _keadaan(t).session.goresan;
    var sebelumnya = _keadaan(t).session.jarakTinta;
    for (var i = 1; i <= 55; i++) {
      await g.moveTo(p(Offset(260, 70 + 380 * i / 60)));
      await t.pump(const Duration(milliseconds: 16));
      final sesi = _keadaan(t).session;
      expect(sesi.goresan, goresan);
      expect(sesi.jarakTinta, greaterThanOrEqualTo(sebelumnya));
      expect(sesi.jarakTinta - sebelumnya, lessThanOrEqualTo(lompatanMaju));
      sebelumnya = sesi.jarakTinta;
    }
    expect(sebelumnya, greaterThan(300));
    // Moci mengikuti ujung tinta saat jari menempel.
    final moci = t.getRect(find.byType(MociMascot));
    expect(moci.center.dy, closeTo(p(Offset(260, 70)).dy + sebelumnya, 2));
    await g.up();
    await t.pump(const Duration(milliseconds: 100));
  });
}
