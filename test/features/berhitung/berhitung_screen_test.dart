import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/berhitung/berhitung_screen.dart';

import '../../helpers/harness.dart';

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Membuka layar lalu menuntaskan transisi rute; tanpa itu kontrol di sisi
/// kanan masih tergeser keluar layar. Tanpa `pumpAndSettle` karena maskot
/// beranimasi terus.
Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/angka',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('membuka: angka 1, kata Satu, satu apel', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.text('1'), findsWidgets);
    expect(find.text('Satu'), findsOneWidget);
    expect(find.text('Ayo hitung apel!'), findsOneWidget);
    expect(find.text('0 / 1'), findsOneWidget);
    expect(env.tts.spoken.first.$1, 'satu');
  });

  testWidgets('mengetuk benda menyelesaikan hitungan dan mencatat', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    await t.tap(find.byKey(BerhitungScreen.itemKey(0)));
    await t.pump();
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('Ada satu apel!'), findsOneWidget);
    expect(_progress(t).perkembangan['angka']!['dihitung'], ['1']);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Hebat, hitungannya benar!', 'satu', 'Apel']),
    );
  });

  testWidgets('rentang dan angka: 41–50 memilih lima puluh', (t) async {
    await _open(t);
    await t.tap(find.byKey(BerhitungScreen.rangeKey(41)));
    await t.pump();
    await t.tap(find.byKey(BerhitungScreen.numberKey(50)));
    await t.pump();
    expect(find.text('Lima puluh'), findsOneWidget);
    expect(find.byKey(BerhitungScreen.itemKey(49)), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('hitung bareng berhenti saat angka berganti', (t) async {
    await _open(t);
    await t.tap(find.byKey(BerhitungScreen.numberKey(3)));
    await t.pump();
    await t.tap(find.text('Hitung bareng'));
    await t.pump(const Duration(milliseconds: 700));
    await t.tap(find.byKey(BerhitungScreen.numberKey(5)));
    await t.pump(const Duration(milliseconds: 1400));
    expect(find.text('0 / 5'), findsOneWidget);
  });

  testWidgets('ganti bahasa mengganti kata bilangan', (t) async {
    final env = TestEnv();
    await _open(t, env: env);
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump();
    expect(find.text('One'), findsOneWidget);
    expect(find.text("Let's count the apples!"), findsOneWidget);
    expect(find.text("Let's count the apple!"), findsNothing);
  });

  testWidgets('50 benda dan kata panjang tidak overflow', (t) async {
    await _open(t);
    await t.tap(find.byKey(BerhitungScreen.rangeKey(41)));
    await t.pump();
    await t.tap(find.byKey(BerhitungScreen.numberKey(50)));
    await t.pump();
    expect(find.text('Lima puluh'), findsOneWidget);
    expect(find.byKey(BerhitungScreen.itemKey(49)), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('lanjutkan membuka angka terakhir', (t) async {
    await _open(t, lokasi: '/angka?angka=15');
    expect(find.text('Lima belas'), findsOneWidget);
    expect(find.text('0 / 15'), findsOneWidget);
  });
}
