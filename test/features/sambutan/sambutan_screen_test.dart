import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';

import '../../helpers/harness.dart';

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 500));
}

/// Membuka `/sambutan` dan menunggu transisi rute selesai (tanpa
/// `pumpAndSettle`: Moci beranimasi terus).
Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  Size size = tabletSize,
}) async {
  final router = await pumpApp(
    t,
    env: env ?? TestEnv(onboarded: false),
    size: size,
    initialLocation: '/sambutan',
  );
  await _settle(t);
  return router;
}

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Router<Object>)));

void main() {
  testWidgets('alur lengkap menyimpan prefs dan membuka Beranda', (t) async {
    final env = TestEnv(onboarded: false);
    final router = await _open(t, env: env);
    await t.tap(find.text('English'));
    await t.pump();
    expect(find.text("Let's Go!"), findsOneWidget);
    await t.enterText(find.byType(TextField), '  Raka  ');
    await t.pump();
    await t.tap(find.textContaining('6–7'));
    await t.pump();
    await t.tap(find.text("Let's Go!"));
    await _settle(t);
    final p = _container(t).read(prefsProvider);
    expect(
      (p.lang, p.childName, p.ageLevel, p.onboarded),
      (AppLang.en, 'Raka', AgeLevel.pembaca, true),
    );
    expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    expect(env.tts.spoken.last, ("Let's Go!", AppLang.en));
  });

  testWidgets('nama 25 karakter tersimpan 20 karakter', (t) async {
    final env = TestEnv(onboarded: false);
    await _open(t, env: env);
    await t.enterText(find.byType(TextField), 'a' * 25);
    await t.pump();
    await t.tap(find.text('Ayo Mulai!'));
    await _settle(t);
    expect(_container(t).read(prefsProvider).childName, 'a' * 20);
  });

  testWidgets('usia bawaan 2-3 pemula', (t) async {
    final env = TestEnv(onboarded: false);
    await _open(t, env: env);
    await t.tap(find.text('Ayo Mulai!'));
    await _settle(t);
    expect(_container(t).read(prefsProvider).ageLevel, AgeLevel.pemula);
  });

  testWidgets('gelembung Moci: teman bila kosong, nama bila ada', (t) async {
    await _open(t);
    expect(find.text('Hai, teman!'), findsOneWidget);
    await t.enterText(find.byType(TextField), '   ');
    await t.pump();
    expect(find.text('Hai, teman!'), findsOneWidget);
    await t.enterText(find.byType(TextField), ' Raka ');
    await t.pump();
    expect(find.text('Hai, Raka!'), findsOneWidget);
    await t.tap(find.text('English'));
    await t.pump();
    expect(find.text('Hi, Raka!'), findsOneWidget);
  });

  testWidgets('kartu bahasa menarasikan nama bahasanya', (t) async {
    final env = TestEnv(onboarded: false);
    await _open(t, env: env);
    await t.tap(find.text('English'));
    await t.pump();
    expect(env.tts.spoken.last, ('English', AppLang.en));
    await t.tap(find.text('Bahasa Indonesia'));
    await t.pump();
    expect(env.tts.spoken.last, ('Bahasa Indonesia', AppLang.id));
    expect(find.text('Ayo Mulai!'), findsOneWidget);
  });

  testWidgets('mengetuk Moci: sambutanSay saat nama kosong', (t) async {
    final env = TestEnv(onboarded: false);
    await _open(t, env: env);
    await t.tap(find.bySemanticsLabel('Moci'));
    await t.pump();
    expect(env.tts.spoken.last, ('Halo! Aku Moci. Siapa namamu?', AppLang.id));
  });

  testWidgets('mengetuk Moci: sambutanHalo saat nama terisi (D5)', (t) async {
    final env = TestEnv(onboarded: false);
    await _open(t, env: env);
    await t.enterText(find.byType(TextField), 'Raka');
    await t.pump();
    await t.tap(find.bySemanticsLabel('Moci'));
    await t.pump();
    expect(env.tts.spoken.last, ('Halo! Aku Moci.', AppLang.id));
  });

  testWidgets('back sistem dikunci', (t) async {
    await _open(t);
    final pop = t.widget<PopScope>(find.byType(PopScope).first);
    expect(pop.canPop, isFalse);
  });

  group('keyboard', () {
    Future<void> check(WidgetTester t, Size size, double kbHeight) async {
      await _open(t, size: size);
      final before = t.getRect(find.byType(TextField));
      t.view.viewInsets = FakeViewPadding(bottom: kbHeight);
      addTearDown(t.view.resetViewInsets);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      final r = t.getRect(find.byType(TextField));
      expect(r.top, greaterThanOrEqualTo(0));
      expect(r.bottom, lessThanOrEqualTo(size.height - kbHeight));
      expect(r.top, lessThan(before.top));
    }

    testWidgets('HP: kolom nama di atas keyboard', (t) async {
      await check(t, phoneSize, 200);
    });

    testWidgets('iPad: kolom nama di atas keyboard', (t) async {
      await check(t, tabletSize, 400);
    });

    testWidgets('tanpa keyboard tidak ada pergeseran', (t) async {
      await _open(t);
      final r = t.getRect(find.byType(TextField));
      expect(r.top, greaterThan(400));
      expect(r.bottom, lessThan(560));
    });
  });
}
