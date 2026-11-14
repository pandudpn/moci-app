import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/bentuk/bentuk_screen.dart';

import '../../helpers/harness.dart';
import '../../helpers/katalog.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/bentuk',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('membuka: lingkaran, 5 kartu untuk pemula, narasi nama', (
    t,
  ) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.text('Bentuk'), findsOneWidget);
    expect(find.text('Lingkaran'), findsWidgets);
    expect(find.text('Tidak punya sudut'), findsOneWidget);
    expect(find.byKey(BentukScreen.shapeKey('hati')), findsOneWidget);
    expect(find.byKey(BentukScreen.shapeKey('segilima')), findsNothing);
    expect(find.byKey(BentukScreen.countKey), findsNothing);
    expect(env.tts.spoken.map((e) => e.$1), ['Lingkaran']);
  });

  testWidgets('kisi mengikuti level usia', (t) async {
    await _open(t, env: envUsia(AgeLevel.penjelajah), lokasi: '/bentuk');
    expect(find.byKey(BentukScreen.shapeKey('segilima')), findsNothing);
    expect(find.byKey(BentukScreen.shapeKey('belahketupat')), findsOneWidget);
    await _open(t, env: envUsia(AgeLevel.pembaca), lokasi: '/bentuk');
    expect(find.byKey(BentukScreen.shapeKey('segilima')), findsOneWidget);
    expect(find.byKey(BentukScreen.shapeKey('segienam')), findsOneWidget);
  });

  testWidgets('hitung sudut menandai satu per satu lalu membacakan fakta', (
    t,
  ) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/bentuk?bentuk=persegi');
    await t.tap(find.byKey(BentukScreen.countKey));
    await t.pump(const Duration(milliseconds: 800));
    expect(find.byKey(BentukScreen.markKey(0)), findsOneWidget);
    expect(find.byKey(BentukScreen.markKey(1)), findsNothing);
    await t.pump(const Duration(milliseconds: 2400));
    expect(find.byKey(BentukScreen.markKey(3)), findsOneWidget);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['satu', 'dua', 'tiga', 'empat']),
    );
    expect(env.tts.spoken.last.$1, contains('Persegi punya 4 sisi'));
  });

  testWidgets('bintang memakai hitung ujung', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/bentuk?bentuk=bintang');
    expect(find.text('5 ujung'), findsOneWidget);
    expect(find.text('Hitung ujung'), findsOneWidget);
    env.tts.spoken.clear();
    await t.tap(find.byKey(BentukScreen.hearKey));
    await t.pump();
    expect(env.tts.spoken.map((e) => e.$1), [
      'Bintang',
      'Bintang punya 5 ujung yang lancip.',
    ]);
  });

  testWidgets('ganti bahasa mengganti nama dan chip', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/bentuk?bentuk=persegi');
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Square'), findsWidgets);
    expect(find.text('4 sides'), findsOneWidget);
    expect(find.text('4 corners'), findsOneWidget);
  });

  testWidgets('lanjutkan membuka bentuk terakhir', (t) async {
    await _open(t, lokasi: '/bentuk?bentuk=segitiga');
    expect(find.text('Segitiga'), findsWidgets);
    expect(find.text('3 sisi'), findsOneWidget);
  });
}
