import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/tulis/tracing_board.dart';
import 'package:moci/features/tulis/tulis_screen.dart';

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

/// Satu goresan angka 1: dua segmen.
Future<void> _trace1(WidgetTester t) async {
  await _trace(t, const Offset(200, 140), const Offset(275, 70));
  await _trace(t, const Offset(275, 70), const Offset(275, 450));
}

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

void main() {
  testWidgets('layar tulis angka: 10 kunci, dua kolom, mulai dari 2', (
    t,
  ) async {
    await pumpApp(t, initialLocation: '/angka/tulis');
    expect(find.text('Angka'), findsOneWidget);
    expect(find.text('Tulis angka 2'), findsOneWidget);
    expect(find.text('Garis 1 dari 1'), findsOneWidget);
    expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths.length, 1);
    expect(t.getSize(find.byKey(TulisScreen.keyKey('0'))).height, 74);
  });

  testWidgets('angka 0 punya jalur', (t) async {
    await pumpApp(t, initialLocation: '/angka/tulis');
    await t.tap(find.byKey(TulisScreen.keyKey('0')));
    await t.pump();
    expect(find.text('Tulis angka 0'), findsOneWidget);
    expect(t.widget<TracingBoard>(find.byType(TracingBoard)).paths, isNotEmpty);
  });

  testWidgets('menyelesaikan angka 1 menandai kunci', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/angka/tulis');
    await t.tap(find.byKey(TulisScreen.keyKey('1')));
    await t.pump();
    await _trace1(t);
    expect(find.text('Hebat!'), findsOneWidget);
    expect(_progress(t).perkembangan['angka']!['ditulis'], ['1']);
  });

  testWidgets('kunci yang selesai tetap berbintang setelah layar dibuka lagi', (
    t,
  ) async {
    final env = TestEnv(
      progress: const Progress(
        perkembangan: {
          'angka': {
            'ditulis': ['1'],
          },
        },
      ),
    );
    await pumpApp(t, env: env, initialLocation: '/angka/tulis');
    expect(find.byKey(TulisScreen.starKey('1')), findsOneWidget);
    expect(find.byKey(TulisScreen.starKey('3')), findsNothing);
  });

  testWidgets('ganti bahasa mengganti label', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/angka/tulis');
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('Write the number 2'), findsOneWidget);
  });

  testWidgets('lanjutkan membuka angka terakhir', (t) async {
    await pumpApp(t, initialLocation: '/angka/tulis?angka=7');
    expect(find.text('Tulis angka 7'), findsOneWidget);
  });
}
