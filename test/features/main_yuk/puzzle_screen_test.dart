import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';

import '../../helpers/harness.dart';

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar puzzle: empat keping dan baki', (t) async {
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/main/puzzle');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Puzzle'), findsOneWidget);
    expect(find.text('0 / 4 potongan'), findsOneWidget);
    expect(find.bySemanticsLabel('Potongan 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Tempat 4'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('papan 2 x 2 untuk pemula, 3 x 3 untuk pembaca', (t) async {
    final semantics = t.ensureSemantics();
    final env = TestEnv();
    env.store.setString('moci.usia', '6-7');
    await pumpApp(t, env: env, initialLocation: '/main/puzzle');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.bySemanticsLabel('Tempat 9'), findsOneWidget);
    expect(find.text('0 / 9 potongan'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('ketuk keping lalu tempatnya memasang gambar', (t) async {
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/main/puzzle');
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.bySemanticsLabel('Potongan 1'));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.bySemanticsLabel('Tempat 1'));
    await t.pump(const Duration(milliseconds: 450));
    expect(find.text('1 / 4 potongan'), findsOneWidget);
    expect(find.bySemanticsLabel('Potongan 1'), findsNothing);
    semantics.dispose();
  });

  testWidgets('empat keping membuka Hebat', (t) async {
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/main/puzzle');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 1; i <= 4; i++) {
      await t.tap(find.bySemanticsLabel('Potongan $i'));
      await t.pump(const Duration(milliseconds: 450));
      await t.tap(find.bySemanticsLabel('Tempat $i'));
      await t.pump(const Duration(milliseconds: 450));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
    semantics.dispose();
  });

  testWidgets('tempat salah tetap menampilkan keping di baki', (t) async {
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/main/puzzle');
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.bySemanticsLabel('Potongan 1'));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.bySemanticsLabel('Tempat 2'));
    await t.pump();
    expect(find.text('0 / 4 potongan'), findsOneWidget);
    expect(find.bySemanticsLabel('Potongan 1'), findsOneWidget);
    semantics.dispose();
  });
}
