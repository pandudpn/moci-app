import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/mewarnai/galeri_screen.dart';

import '../../helpers/harness.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

void main() {
  testWidgets('galeri: judul, 14 halaman, dan kartu Karyaku', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    expect(find.text('Mewarnai'), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('eskrim')), findsOneWidget);
    expect(find.byKey(GaleriScreen.karyakuKey), findsOneWidget);
    expect(find.text('Kue Ulang Tahun'), findsOneWidget);
  });

  testWidgets('saring hewan menyisakan enam halaman', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    await t.tap(find.byKey(GaleriScreen.tabKey('hewan')));
    await t.pump();
    expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('hantu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('rumah')), findsNothing);
  });

  testWidgets('mengetuk halaman membuka kanvas', (t) async {
    final router = await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    await t.tap(find.byKey(GaleriScreen.kartuKey('ikan')));
    await t.pump();
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai/ikan',
    );
  });

  testWidgets('draf berisi memberi lencana Lanjutkan', (t) async {
    final env = TestEnv();
    await env.json.write('draf/kupu.json', {
      'versi': 1,
      'halaman': 'kupu',
      'isian': {'1': '#FF4B4B'},
      'coretan': {},
      'cap': [],
    });
    await pumpApp(t, env: env, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    expect(find.text('Lanjutkan'), findsOneWidget);
  });

  testWidgets('ganti bahasa mengganti nama halaman', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('Birthday Cake'), findsOneWidget);
    expect(find.text('Kue Ulang Tahun'), findsNothing);
    expect(find.text('Things & Nature'), findsOneWidget);
  });

  testWidgets('nama panjang tidak overflow', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump();
    await t.pump();
    expect(find.text('Kue Ulang Tahun'), findsOneWidget);
    expect(find.text('Dinosaurus'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
