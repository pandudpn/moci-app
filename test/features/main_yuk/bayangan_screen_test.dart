import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/content/content_repository.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/main_yuk/bayangan_screen.dart';
import 'package:moci/widgets/game/answer_card.dart';
import 'package:moci/widgets/game/progress_dots.dart';
import 'package:moci/widgets/moci_illustration.dart';

import '../../helpers/harness.dart';

/// Id target dibaca dari ilustrasi bayangan (kunci `targetKey`).
String _target(WidgetTester t) =>
    t.widget<MociIllustration>(find.byKey(BayanganScreen.targetKey)).id;

/// Id semua pilihan, dibaca dari kunci `pilihanKey` tiap AnswerCard.
List<String> _pilihan(WidgetTester t) => [
  for (final w in t.widgetList<AnswerCard>(find.byType(AnswerCard)))
    (w.key! as ValueKey<String>).value,
];

String _nama(WidgetTester t, String id) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(katalogProvider)
        .byId(id)!
        .nama
        .of(AppLang.id);

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar bayangan: tiga pilihan dan bayangan misteri', (t) async {
    // Label ilustrasi dan bayangan hanya ada di pohon semantik.
    final semantics = t.ensureSemantics();
    await pumpApp(t, initialLocation: '/main/bayangan');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Tebak Bayangan'), findsOneWidget);
    expect(find.text('Bayangan siapa ini?'), findsOneWidget);
    expect(find.byType(AnswerCard), findsNWidgets(3));
    expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
    expect(find.byKey(BayanganScreen.skorKey), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('pembaca memakai empat pilihan', (t) async {
    final env = TestEnv();
    env.store.setString('moci.usia', '6-7');
    await pumpApp(t, env: env, initialLocation: '/main/bayangan');
    expect(find.byType(AnswerCard), findsNWidgets(4));
  });

  testWidgets('jawaban benar membuka warna dan maju setelah 1500 ms', (
    t,
  ) async {
    // Label ilustrasi dan bayangan hanya ada di pohon semantik.
    final semantics = t.ensureSemantics();
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main/bayangan');
    await t.pump(const Duration(milliseconds: 600));
    final target = _target(t);
    await t.tap(find.byKey(BayanganScreen.pilihanKey(target)));
    await t.pump();
    expect(
      t.widget<AnswerCard>(find.byKey(BayanganScreen.pilihanKey(target))).state,
      AnswerCardState.correct,
    );
    expect(find.bySemanticsLabel(_nama(t, target)), findsWidgets);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Betul! Itu', _nama(t, target)]),
    );
    await t.pump(const Duration(milliseconds: 1600));
    expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
    expect(t.widget<ProgressDots>(find.byType(ProgressDots)).current, 1);
    semantics.dispose();
  });

  testWidgets('pilihan salah tetap di ronde yang sama', (t) async {
    // Label ilustrasi dan bayangan hanya ada di pohon semantik.
    final semantics = t.ensureSemantics();
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main/bayangan');
    await t.pump(const Duration(milliseconds: 600));
    final target = _target(t);
    final salah = _pilihan(t).firstWhere((id) => id != target);
    await t.tap(find.byKey(BayanganScreen.pilihanKey(salah)));
    await t.pump();
    expect(
      t.widget<AnswerCard>(find.byKey(BayanganScreen.pilihanKey(salah))).state,
      AnswerCardState.wrong,
    );
    expect(find.bySemanticsLabel('Bayangan misteri'), findsOneWidget);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder(['Bukan yang itu, itu', _nama(t, salah)]),
    );
    semantics.dispose();
  });

  testWidgets('enam jawaban benar membuka Hebat', (t) async {
    await pumpApp(t, initialLocation: '/main/bayangan');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      await t.tap(find.byKey(BayanganScreen.pilihanKey(_target(t))));
      await t.pump(const Duration(milliseconds: 1600));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
  });

  testWidgets('Main lagi dari Hebat memulai ronde baru', (t) async {
    await pumpApp(t, initialLocation: '/main/bayangan');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      await t.tap(find.byKey(BayanganScreen.pilihanKey(_target(t))));
      await t.pump(const Duration(milliseconds: 1600));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    await t.tap(find.text('Main lagi'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    // Transisi keluar Hebat masih berjalan; satu jeda lagi sampai layar ini
    // kembali terpasang.
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.byType(HebatScreen), findsNothing);
    expect(t.widget<ProgressDots>(find.byType(ProgressDots)).current, 0);
    for (var i = 0; i < 6; i++) {
      await t.tap(find.byKey(BayanganScreen.pilihanKey(_target(t))));
      await t.pump(const Duration(milliseconds: 1600));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 6);
  });
}
