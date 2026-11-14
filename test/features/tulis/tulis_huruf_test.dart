import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/tulis/tracing_board.dart';
import 'package:moci/features/tulis/tulis_keys.dart';

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

/// Tiga goresan huruf A.
Future<void> _traceA(WidgetTester t) async {
  await _trace(t, const Offset(260, 70), const Offset(130, 450));
  await _trace(t, const Offset(260, 70), const Offset(390, 450));
  await _trace(t, const Offset(176, 315), const Offset(344, 315));
}

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar tulis huruf: kunci, papan A, dan progres goresan', (
    t,
  ) async {
    await pumpApp(t, initialLocation: '/huruf/tulis');
    expect(find.text('Huruf'), findsOneWidget);
    expect(find.text('Tulis A'), findsOneWidget);
    expect(find.text('Garis 1 dari 3'), findsOneWidget);
    expect(find.byType(TracingBoard), findsOneWidget);
    expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths.length, 3);
  });

  testWidgets('menyelesaikan A memberi bilah Hebat dan mencatat sekali', (
    t,
  ) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/huruf/tulis');
    await _traceA(t);
    expect(find.text('Hebat!'), findsOneWidget);
    expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
    await t.tap(find.text('Lanjut'));
    await t.pump();
    expect(find.text('Tulis B'), findsOneWidget);
    expect(find.text('Garis 1 dari 3'), findsOneWidget);
    expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
  });

  testWidgets('kunci baru mengulang goresan dan mencatat sekali', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/huruf/tulis');
    await _traceA(t);
    await t.tap(find.text('Lanjut'));
    await t.pump();
    // A tidak lagi terpilih: gerakan tidak memajukan B.
    await _traceA(t);
    expect(find.text('Hebat!'), findsNothing);
    expect(_progress(t).perkembangan['huruf']!['ditulis'], ['A']);
  });

  testWidgets('krayon mengubah tinta papan', (t) async {
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/huruf/tulis');
    // Transisi rute harus selesai dulu; selama animasi semantik rute baru
    // belum masuk pohon.
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.bySemanticsLabel('Krayon biru'));
    await t.pump();
    expect(
      t.widget<TracingBoard>(find.byType(TracingBoard)).ink,
      tulisCrayons[1],
    );
    semantics.dispose();
  });
  testWidgets('kartu Lanjutkan memakai subjudul tulis huruf', (t) async {
    final env = TestEnv(
      progress: const Progress(
        lastActivity: LastActivity('/huruf/tulis', {'huruf': 'A'}),
      ),
    );
    await pumpApp(t, env: env, initialLocation: '/');
    expect(find.text('Tulis huruf A'), findsOneWidget);
  });

  testWidgets('lanjutkan membuka huruf terakhir', (t) async {
    await pumpApp(t, initialLocation: '/huruf/tulis?huruf=Z');
    expect(find.text('Tulis Z'), findsOneWidget);
    expect(find.text('Garis 1 dari 1'), findsOneWidget);
  });
}
