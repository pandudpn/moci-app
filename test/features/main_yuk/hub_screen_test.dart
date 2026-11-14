import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/main_yuk/hub_screen.dart';
import 'package:moci/features/main_yuk/main_yuk_game.dart';
import 'package:moci/widgets/star_counter.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('hub: enam kartu, lencana usia, dan bintang', (t) async {
    await pumpApp(t, initialLocation: '/main');
    expect(find.text('Main Yuk!'), findsOneWidget);
    expect(find.text('Pilih permainan'), findsOneWidget);
    for (final g in MainYukGame.values) {
      expect(find.byKey(HubScreen.cardKey(g)), findsOneWidget);
    }
    expect(find.text('Cocokkan Gambar'), findsOneWidget);
    expect(find.text('Kartu Memori'), findsOneWidget);
    expect(find.text('Besar & Kecil'), findsOneWidget);
    expect(find.text('Usia 2+'), findsNWidgets(3));
    expect(find.text('Usia 3+'), findsNWidgets(2));
    expect(find.text('Usia 4+'), findsOneWidget);
    expect(find.byType(StarCounter), findsOneWidget);
  });

  testWidgets('hub: ketuk kartu membacakan judul lalu membuka rutenya', (
    t,
  ) async {
    final env = TestEnv();
    final router = await pumpApp(t, env: env, initialLocation: '/main');
    await t.tap(find.byKey(HubScreen.cardKey(MainYukGame.memori)));
    await t.pump();
    await t.pump();
    expect(env.tts.spoken.single.$1, 'Kartu Memori');
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/main/memori',
    );
  });

  testWidgets('hub: kembali ke Beranda', (t) async {
    final router = await pumpApp(t, initialLocation: '/main');
    // Rute masuk lewat transisi Material; semantiknya baru terlihat setelah
    // transisi selesai.
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.bySemanticsLabel('Kembali ke beranda'));
    await t.pump();
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/',
    );
  });

  testWidgets('hub: ganti bahasa mengganti subjudul dan lencana', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main');
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text("Let's Play!"), findsOneWidget);
    expect(find.text('Pick a game'), findsOneWidget);
    expect(find.text('Ages 2+'), findsNWidgets(3));
  });

  testWidgets('hub: kartu tidak overflow di HP 844 x 390', (t) async {
    await pumpApp(t, initialLocation: '/main', size: phoneSize);
    expect(
      find.byKey(HubScreen.cardKey(MainYukGame.besarKecil)),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
}
