import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/mewarnai/galeri_screen.dart';
import 'package:moci/features/mewarnai/mewarnai_providers.dart';

import '../../helpers/harness.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Menekan pil saring, menggeser baris pil kalau labelnya keluar layar.
Future<void> _saring(WidgetTester t, String kategori) async {
  final pil = find.byKey(GaleriScreen.tabKey(kategori));
  await t.ensureVisible(pil);
  await t.pump();
  await t.tap(pil);
  await t.pump();
}

void main() {
  testWidgets('galeri: judul, 44 halaman, enam pil, dan kartu Karyaku', (
    t,
  ) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.text('Mewarnai'), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('eskrim')), findsOneWidget);
    expect(find.text('Kue Ulang Tahun'), findsOneWidget);
    for (final kategori in [
      'semua',
      'hewan',
      'laut',
      'buah',
      'kota',
      'benda',
    ]) {
      expect(find.byKey(GaleriScreen.tabKey(kategori)), findsOneWidget);
    }
    final set = _container(t).read(coloringProvider).value!;
    expect(set.halaman.length, 44);
    expect(set.halaman.where((p) => p.kategori == 'laut').length, 7);
    expect(t.takeException(), isNull);
  });

  testWidgets('saring hewan menyisakan dua belas halaman', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    await _saring(t, 'hewan');
    expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('hantu')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('rumah')), findsNothing);
    final kisi = t.widget<GridView>(find.byType(GridView));
    expect(kisi.childrenDelegate.estimatedChildCount, 13);
  });

  testWidgets('saring kota menyisakan enam halaman', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    await _saring(t, 'kota');
    expect(find.byKey(GaleriScreen.kartuKey('kota-gedung')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('kota-jalan')), findsOneWidget);
    expect(find.byKey(GaleriScreen.kartuKey('kupu')), findsNothing);
    expect(find.byKey(GaleriScreen.karyakuKey), findsOneWidget);
    final kisi = t.widget<GridView>(find.byType(GridView));
    expect(kisi.childrenDelegate.estimatedChildCount, 7);
  });

  testWidgets('kisi bergeser sampai halaman terakhir', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.byKey(GaleriScreen.kartuKey('balon-udara')), findsNothing);
    await t.scrollUntilVisible(
      find.byKey(GaleriScreen.kartuKey('balon-udara')),
      320,
      scrollable: find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      ),
    );
    await t.pump();
    expect(find.byKey(GaleriScreen.kartuKey('balon-udara')), findsOneWidget);
    // Karyaku kartu terakhir, jadi ikut terjangkau setelah kisi bergeser.
    expect(find.byKey(GaleriScreen.karyakuKey), findsOneWidget);
  });

  testWidgets('mengetuk halaman membuka kanvas', (t) async {
    final router = await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    await t.tap(find.byKey(GaleriScreen.kartuKey('ikan')));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai/ikan',
    );
  });

  testWidgets('mengetuk halaman laut membuka kanvas', (t) async {
    final router = await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    await _saring(t, 'laut');
    await t.tap(find.byKey(GaleriScreen.kartuKey('laut-gurita')));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai/laut-gurita',
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
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.text('Lanjutkan'), findsOneWidget);
  });

  testWidgets('ganti bahasa mengganti nama halaman', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('Birthday Cake'), findsOneWidget);
    expect(find.text('Kue Ulang Tahun'), findsNothing);
    expect(find.text('Things & Nature'), findsOneWidget);
  });

  testWidgets('nama panjang tidak overflow', (t) async {
    await pumpApp(t, initialLocation: '/mewarnai');
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.text('Kue Ulang Tahun'), findsOneWidget);
    expect(find.text('Dinosaurus'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
