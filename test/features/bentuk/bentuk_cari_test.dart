import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/bentuk/bentuk_screen.dart';
import 'package:moci/features/bentuk/bentuk_shape.dart';

import '../../helpers/harness.dart';
import '../../helpers/katalog.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/bentuk?mode=cari',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

String _targetDariSoal(WidgetTester t) {
  final soal = t.widget<Text>(find.byKey(BentukScreen.questionKey)).data!;
  final inti = soal.replaceFirst('Mana ', '').replaceFirst('Where is the ', '');
  final nama = inti.substring(0, inti.length - 1);
  return nama[0].toUpperCase() + nama.substring(1);
}

Future<void> _jawabBenar(WidgetTester t) async {
  final nama = _targetDariSoal(t);
  final bentuk = katalogUji().bentuk.firstWhere(
    (b) => b.nama.id == nama || b.nama.en == nama,
  );
  await t.tap(find.byKey(BentukScreen.optionKey(bentuk.id)));
  await t.pump(const Duration(milliseconds: 1300));
}

void main() {
  testWidgets('membuka cari: soal, 3 opsi pemula, narasi', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/bentuk?mode=cari&bentuk=persegi');
    expect(find.text('Mana persegi?'), findsOneWidget);
    expect(find.byType(BentukShape), findsNWidgets(3));
    expect(env.tts.spoken.map((e) => e.$1), ['Mana', 'Persegi']);
  });

  testWidgets('salah tidak menambah kemajuan', (t) async {
    await _open(t, lokasi: '/bentuk?mode=cari&bentuk=persegi');
    final salah = katalogUji().bentuk
        .where((b) => b.id != 'persegi')
        .firstWhere(
          (b) => find.byKey(BentukScreen.optionKey(b.id)).evaluate().isNotEmpty,
        );
    await t.tap(find.byKey(BentukScreen.optionKey(salah.id)));
    await t.pump(const Duration(milliseconds: 1300));
    expect(find.text('Mana persegi?'), findsOneWidget);
    expect(find.byKey(BentukScreen.checkKey('persegi')), findsNothing);
  });

  testWidgets('enam ronde selesai: hadiah tiga bintang dan layar Hebat', (
    t,
  ) async {
    final env = TestEnv();
    final router = await pumpApp(
      t,
      env: env,
      initialLocation: '/bentuk?mode=cari',
    );
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      await _jawabBenar(t);
    }
    expect(find.text('Hebat! Semua bentuk ketemu!'), findsOneWidget);
    await t.tap(find.byKey(BentukScreen.prizeKey));
    await t.pump();
    await t.runAsync(() => Future<void>.delayed(Duration.zero));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/hebat',
    );
    expect(_progress(t).stars, 3);
    expect(find.text('Kamu dapat 3 bintang!'), findsOneWidget);
  });

  testWidgets('ambil hadiah dua kali tetap tiga bintang', (t) async {
    final env = TestEnv();
    final router = await pumpApp(
      t,
      env: env,
      initialLocation: '/bentuk?mode=cari',
    );
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      await _jawabBenar(t);
    }
    await t.tap(find.byKey(BentukScreen.prizeKey));
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.byKey(BentukScreen.prizeKey), warnIfMissed: false);
    await t.pump();
    await t.runAsync(() => Future<void>.delayed(Duration.zero));
    await t.pump();
    expect(_progress(t).stars, 3);
    final hebat = router.routerDelegate.currentConfiguration.matches
        .where((m) => m.matchedLocation == '/hebat')
        .length;
    expect(hebat, 1);
  });

  testWidgets('main lagi mengosongkan kemajuan', (t) async {
    await _open(t);
    for (var i = 0; i < 6; i++) {
      await _jawabBenar(t);
    }
    await t.tap(find.byKey(BentukScreen.againKey));
    await t.pump();
    expect(find.text('Hebat! Semua bentuk ketemu!'), findsNothing);
    expect(find.byKey(BentukScreen.questionKey), findsOneWidget);
  });

  testWidgets('pilihan mengikuti level usia', (t) async {
    await _open(t, env: envUsia(AgeLevel.pembaca));
    expect(find.byType(BentukShape), findsNWidgets(6));
  });
}
