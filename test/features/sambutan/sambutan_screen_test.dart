import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/app_prefs.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/storage/key_value_store.dart';
import 'package:moci/features/sambutan/sambutan_screen.dart';

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

    Future<void> keyboardOn(WidgetTester t, double kbHeight) async {
      t.view.viewInsets = FakeViewPadding(bottom: kbHeight);
      addTearDown(t.view.resetViewInsets);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
    }

    /// Menggeser isi ke atas dengan jari, dari titik yang aman di dalam kartu.
    Future<void> dragUp(WidgetTester t, Offset from) async {
      await t.dragFrom(from, const Offset(0, -420));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
    }

    Future<void> checkScroll(
      WidgetTester t,
      Size size,
      double kbHeight,
      Offset from,
    ) async {
      final env = TestEnv(onboarded: false);
      await _open(t, env: env, size: size);
      await keyboardOn(t, kbHeight);
      final limit = size.height - kbHeight;
      final field = t.getRect(find.byType(TextField));
      expect(field.top, greaterThanOrEqualTo(0));
      expect(field.bottom, lessThanOrEqualTo(limit));
      final cta = find.text('Ayo Mulai!');
      expect(
        t.getRect(cta).bottom,
        greaterThan(limit),
        reason: 'tombol masih tertutup keyboard sebelum digulir',
      );

      await dragUp(t, from);
      final scrolled = t.getRect(cta);
      expect(scrolled.top, greaterThanOrEqualTo(0));
      expect(scrolled.bottom, lessThanOrEqualTo(limit));

      await t.tap(cta);
      await _settle(t);
      expect(_container(t).read(prefsProvider).onboarded, isTrue);
    }

    testWidgets('HP: menggulir sampai tombol terlihat lalu bisa ditap', (
      t,
    ) async {
      await checkScroll(t, phoneSize, 200, const Offset(400, 90));
    });

    testWidgets('iPad: menggulir sampai tombol terlihat lalu bisa ditap', (
      t,
    ) async {
      await checkScroll(t, tabletSize, 400, const Offset(885, 150));
    });

    testWidgets('tanpa keyboard: geser tidak menggeser isi', (t) async {
      await _open(t);
      final before = t.getRect(find.byType(TextField));
      await t.dragFrom(const Offset(885, 150), const Offset(0, -200));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(t.getRect(find.byType(TextField)), before);
    });
  });

  // Tanpa router: penulisan yang tertahan tidak boleh mengalihkan layar
  // selagi diuji, dan `context.go` sesudahnya memang tidak dipanggil.
  testWidgets('selagi menyimpan: ketukan kedua dan ganti bahasa diabaikan', (
    t,
  ) async {
    final gate = GatedKeyValueStore(MemoryKeyValueStore());
    final env = TestEnv(onboarded: false, store: gate);
    await pumpScreen(t, const SambutanScreen(), env: env);
    await t.pump(const Duration(milliseconds: 500));
    gate.tulis.clear(); // hitungan mulai dari sini, tanpa 3 tulisan benih
    gate.gerbang = Completer<void>();
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(find.text('Ayo Mulai!'));
    await t.pump();
    expect(gate.total, 1, reason: 'penulisan pertama sudah berjalan');

    // Jeda tombol sudah lewat: yang menahan ketukan kedua adalah penjaga.
    env.clock.advance(const Duration(seconds: 1));
    await t.tap(find.text('Ayo Mulai!'));
    await t.pump();
    expect(gate.total, 1, reason: 'hanya sekali simpan');

    await t.tap(find.text('English'));
    await t.pump();
    expect(
      find.text('Ayo Mulai!'),
      findsOneWidget,
      reason: 'bahasa tidak berganti selagi menyimpan',
    );
  });

  testWidgets('gagal menyimpan: tidak melempar dan tetap di layar', (t) async {
    final gate = GatedKeyValueStore(MemoryKeyValueStore());
    final env = TestEnv(onboarded: false, store: gate);
    gate.gagal = true;
    await pumpScreen(t, const SambutanScreen(), env: env);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('Ayo Mulai!'), findsOneWidget);
    await t.tap(find.text('Ayo Mulai!'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(t.takeException(), isNull);
    expect(find.text('Ayo Mulai!'), findsOneWidget);
  });

  testWidgets('ketukan di luar kolom nama melepas fokus', (t) async {
    await _open(t);
    await t.enterText(find.byType(TextField), 'Raka');
    await t.pump();
    final focus = t.widget<EditableText>(find.byType(EditableText)).focusNode;
    expect(focus.hasFocus, isTrue);
    await t.tapAt(const Offset(20, 20));
    await t.pump();
    expect(focus.hasFocus, isFalse);
  });
}
