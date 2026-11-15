import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/buah_sayur/buah_screen.dart';
import 'package:moci/widgets/game/answer_card.dart';

import '../../helpers/harness.dart';
import '../../helpers/katalog.dart';

Progress _progress(WidgetTester t) => _container(t).read(progressProvider);

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

/// Membuka layar lalu menuntaskan transisi rute; tanpa itu kontrol di sisi
/// kanan masih tergeser keluar layar.
Future<void> _open(
  WidgetTester t, {
  TestEnv? env,
  String lokasi = '/buah-sayur',
}) async {
  await pumpApp(t, env: env, initialLocation: lokasi);
  await t.pump(const Duration(milliseconds: 600));
}

/// Menuntaskan animasi setelah pilihan berganti sebelum mengetuk lagi.
Future<void> _geser(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  testWidgets('membuka: mode Tebak, soal apel, tiga kartu, narasi', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    expect(find.text('Buah & Sayur'), findsOneWidget);
    expect(find.byType(AnswerCard), findsNWidgets(3));
    expect(find.text('APEL'), findsOneWidget);
    expect(
      t.widgetList<AnswerCard>(find.byType(AnswerCard)).map((c) => c.text),
      everyElement(isNull),
    );
    expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
    expect(env.tts.spoken.map((e) => e.$1), ['Mana yang', 'Apel']);
  });

  testWidgets('jawaban salah tidak memajukan soal', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    final salah = t
        .widgetList<AnswerCard>(find.byType(AnswerCard))
        .firstWhere((c) => c.key != BuahScreen.optionKey('apel'));
    await t.tap(find.byWidget(salah));
    await t.pump();
    expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
    expect(
      t
          .widgetList<AnswerCard>(find.byType(AnswerCard))
          .any((c) => c.state == AnswerCardState.wrong),
      isTrue,
    );
    expect(find.text('Betul! Itu Apel!'), findsNothing);
    expect(env.tts.spoken.last.$1, 'Bukan, coba lagi ya!');
  });

  testWidgets('jawaban benar mencatat dan menampilkan bilah', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    await t.tap(find.byKey(BuahScreen.optionKey('apel')));
    await t.pump();
    expect(find.text('Betul! Itu Apel!'), findsOneWidget);
    expect(_progress(t).perkembangan['buahSayur']!['ditebak'], ['apel']);
    expect(env.tts.spoken.map((e) => e.$1).toList(), contains('Betul!'));
  });

  testWidgets('lanjut hanya memajukan satu soal', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    await t.tap(find.byKey(BuahScreen.optionKey('apel')));
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.byKey(BuahScreen.nextKey));
    await t.pump();
    expect(find.byKey(BuahScreen.questionKey(2)), findsOneWidget);
    expect(find.text('Betul! Itu Apel!'), findsNothing);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(BuahScreen.nextKey), findsNothing);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byKey(BuahScreen.questionKey(2)), findsOneWidget);
  });

  testWidgets('kenali: 35 kartu, tag, dan catatan dilihat', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?mode=kenali');
    expect(find.byType(AnswerCard), findsNothing);
    expect(find.byKey(BuahScreen.cardKey('apel')), findsOneWidget);
    expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
    expect(find.text('Apel'), findsNothing);
    expect(find.text('BUAH'), findsWidgets);
    expect(find.text('SAYUR'), findsWidgets);
    await t.tap(find.byKey(BuahScreen.cardKey('apel')));
    await t.pump();
    expect(_progress(t).perkembangan['buahSayur']!['dilihat'], ['apel']);
    expect(env.tts.spoken.last.$1, 'Apel');
  });

  testWidgets('kategori sayur menyaring kenali dan memulai tebak', (t) async {
    await _open(t, lokasi: '/buah-sayur?mode=kenali');
    await t.tap(find.byKey(BuahScreen.categoryKey('sayur')));
    await _geser(t);
    expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
    expect(find.byKey(BuahScreen.cardKey('apel')), findsNothing);
    await t.tap(find.text('Tebak'));
    await _geser(t);
    expect(find.byKey(BuahScreen.questionKey(1)), findsOneWidget);
    final sayur = {
      for (final item in katalogUji().item)
        if (item.kategori == 'sayur') item.nama.of(AppLang.id),
    };
    final kartu = t.widgetList<AnswerCard>(find.byType(AnswerCard));
    expect(kartu, hasLength(3));
    expect(kartu.every((c) => sayur.contains(c.semanticLabel)), isTrue);
    expect(kartu.map((c) => c.text), everyElement(isNull));
  });

  testWidgets('ganti bahasa mengganti pertanyaan dan tag', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await _geser(t);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('APPLE'), findsOneWidget);
    expect(find.text('Fruits & Veggies'), findsOneWidget);
    await t.tap(find.text('Learn'));
    await _geser(t);
    expect(find.text('FRUIT'), findsWidgets);
  });

  testWidgets('kartu buah panjang tidak overflow', (t) async {
    await _open(t, lokasi: '/buah-sayur?mode=kenali');
    _container(t).read(prefsProvider.notifier).setLang(AppLang.en);
    await t.pump(const Duration(milliseconds: 100));
    await t.tap(find.byKey(BuahScreen.categoryKey('sayur')));
    await _geser(t);
    expect(t.takeException(), isNull);
    expect(find.byKey(BuahScreen.cardKey('paprika')), findsOneWidget);
  });

  testWidgets('lanjutkan membuka buah dan mode terakhir', (t) async {
    await _open(t, lokasi: '/buah-sayur?buah=wortel&mode=kenali');
    expect(find.text('Wortel'), findsNothing);
    expect(find.byKey(BuahScreen.cardKey('wortel')), findsOneWidget);
  });

  testWidgets('kartu hanya gambar, nama tetap di label dan narasi', (t) async {
    final env = TestEnv();
    await _open(t, env: env, lokasi: '/buah-sayur?buah=apel&mode=tebak');
    final kartu = t.widgetList<AnswerCard>(find.byType(AnswerCard));
    expect(kartu.map((c) => c.text), everyElement(isNull));
    expect(kartu.map((c) => c.semanticLabel), contains('Apel'));
    await t.tap(find.byKey(BuahScreen.optionKey('apel')));
    await t.pump();
    expect(env.tts.spoken.map((e) => e.$1), contains('Apel'));

    await t.tap(find.text('Kenali'));
    await _geser(t);
    final nama = {
      for (final item in katalogUji().item)
        if (item.kategori == 'buah' || item.kategori == 'sayur')
          item.nama.of(AppLang.id),
    };
    expect(
      find.byWidgetPredicate((w) => w is Text && nama.contains(w.data)),
      findsNothing,
    );
  });
}
