import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/moci_stage.dart';
import 'package:moci/app/theme/menu_theme.dart';
import 'package:moci/core/audio/sfx.dart';
import 'package:moci/widgets/pressable.dart';

import '../helpers/harness.dart';

Widget _host(VoidCallback? onTap, {Duration? cooldown}) => MenuThemeScope(
  theme: MenuTheme.beranda,
  child: Center(
    child: MociPressable(
      key: const Key('p'),
      onTap: onTap,
      cooldown: cooldown ?? const Duration(milliseconds: 400),
      child: const SizedBox(width: 100, height: 100),
    ),
  ),
);

void main() {
  testWidgets('satu ketukan memanggil onTap dan memutar klik', (tester) async {
    final env = TestEnv(assets: {Sfx.klik.asset});
    var taps = 0;
    await pumpScreen(tester, _host(() => taps++), env: env);
    await tester.tap(find.byKey(const Key('p')));
    await tester.pump();
    expect(taps, 1);
    expect(env.audio.plays.map((p) => p.asset), contains(Sfx.klik.asset));
  });

  testWidgets('ditekan: turun 5 pt setelah 120 ms', (tester) async {
    await pumpScreen(tester, _host(() {}));
    final g = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('p'))),
    );
    await tester.pump(); // frame pertama memulai animasi
    await tester.pump(const Duration(milliseconds: 120));
    final t = tester.widget<Transform>(
      find.descendant(
        of: find.byKey(const Key('p')),
        matching: find.byType(Transform),
      ),
    );
    expect(t.transform.getTranslation().y, closeTo(5, 0.01));
    await g.up();
    await tester.pumpAndSettle();
  });

  testWidgets('dua ketukan berjarak 100 ms: sekali', (tester) async {
    final env = TestEnv();
    var taps = 0;
    await pumpScreen(tester, _host(() => taps++), env: env);
    final c = tester.getCenter(find.byKey(const Key('p')));
    await tester.tapAt(c);
    env.clock.advance(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(c);
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('dua ketukan berjarak 500 ms: dua kali', (tester) async {
    final env = TestEnv();
    var taps = 0;
    await pumpScreen(tester, _host(() => taps++), env: env);
    final c = tester.getCenter(find.byKey(const Key('p')));
    await tester.tapAt(c);
    env.clock.advance(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tapAt(c);
    await tester.pump();
    expect(taps, 2);
  });
  testWidgets('jam mundur 1 jam: ketukan tetap diterima', (tester) async {
    final env = TestEnv();
    var taps = 0;
    await pumpScreen(tester, _host(() => taps++), env: env);
    final c = tester.getCenter(find.byKey(const Key('p')));
    await tester.tapAt(c);
    env.clock.advance(const Duration(hours: -1));
    await tester.pump();
    await tester.tapAt(c);
    await tester.pump();
    expect(taps, 2, reason: 'ketukan pertama sesudah jam mundur');
    await tester.tapAt(c);
    await tester.pump();
    expect(taps, 2, reason: 'masih dalam jeda');
    env.clock.advance(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tapAt(c);
    await tester.pump();
    expect(taps, 3);
  });

  testWidgets('onTap null: tidak bereaksi dan diredupkan', (tester) async {
    final env = TestEnv(assets: {Sfx.klik.asset});
    await pumpScreen(tester, _host(null), env: env);
    await tester.tap(find.byKey(const Key('p')));
    await tester.pump();
    expect(env.audio.plays, isEmpty);
    final o = tester.widget<Opacity>(
      find.descendant(
        of: find.byKey(const Key('p')),
        matching: find.byType(Opacity),
      ),
    );
    expect(o.opacity, 0.5);
  });
}
