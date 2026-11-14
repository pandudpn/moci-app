import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/routes.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/features/membaca/kalimat/kalimat_screen.dart';
import 'package:moci/features/membaca/kalimat/kalimat_word.dart';
import 'package:moci/widgets/game/answer_card.dart';

import '../../helpers/harness.dart';

void main() {
  testWidgets('membuka: kalimat pertama dan kata pertama menyala', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('Ini'), findsOneWidget);
    expect(find.text('bola.'), findsOneWidget);
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(0))).sorot,
      isTrue,
    );
    expect(env.tts.spoken.map((e) => e.$1), [
      'Ketuk kata untuk mendengarnya',
      'Ini bola.',
    ]);
  });
  testWidgets('baca bersama menyalakan kata mengikuti waktu', (t) async {
    await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.bacaKey));
    await t.pump();
    await t.pump(const Duration(milliseconds: 700));
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot,
      isTrue,
    );
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(0))).sorot,
      isFalse,
    );
    await t.pump(const Duration(milliseconds: 900));
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot,
      isFalse,
    );
  });
  testWidgets('mengetuk kata membacakan kata itu', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    env.tts.spoken.clear();
    await t.tap(find.byKey(KalimatScreen.kataKey(1)));
    await t.pump();
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot,
      isTrue,
    );
    expect(env.tts.spoken.single.$1, 'bola');
  });
  testWidgets('kalimat berikutnya mengganti teks dan mencatat', (t) async {
    await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.nextKey));
    await t.pump();
    await t.pump();
    expect(find.text('2 / 18'), findsOneWidget);
    expect(find.text('Kucing'), findsOneWidget);
    expect(find.text('tidur.'), findsOneWidget);
  });
  testWidgets('kalimat tak dikenal kembali ke kalimat pertama', (t) async {
    await pumpApp(t, initialLocation: '${Routes.kalimat}?kalimat=tidak-ada');
    expect(find.text('1 / 18'), findsOneWidget);
    expect(find.text('Ini'), findsOneWidget);
  });
  testWidgets('tebak gambar: salah lalu benar', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    await t.tap(find.text('Tebak gambar'));
    await t.pump();
    expect(find.byType(AnswerCard), findsNWidgets(3));
    expect(find.byKey(KalimatScreen.gambarBesarKey), findsNothing);
    final salah = t
        .widgetList<AnswerCard>(find.byType(AnswerCard))
        .firstWhere((c) => c.illustration != 'bola');
    await t.tap(find.byWidget(salah));
    await t.pump();
    expect(find.byKey(AnswerCard.badgeKey), findsNothing);
    expect(env.tts.spoken.last.$1, 'Bukan yang itu. Coba lagi!');
    await t.pump(const Duration(milliseconds: 450));
    final benar = t
        .widgetList<AnswerCard>(find.byType(AnswerCard))
        .firstWhere((c) => c.illustration == 'bola');
    await t.tap(find.byWidget(benar));
    await t.pump();
    await t.pump();
    expect(find.byKey(AnswerCard.badgeKey), findsOneWidget);
    expect(find.byKey(KalimatScreen.gambarBesarKey), findsOneWidget);
    expect(env.tts.spoken.last.$1, 'Ini bola.');
  });
  testWidgets('ganti bahasa saat karaoke menghentikan sorotan', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.kalimat);
    await t.tap(find.byKey(KalimatScreen.bacaKey));
    await t.pump(const Duration(milliseconds: 700));
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    await t.pump();
    expect(find.text('This'), findsOneWidget);
    expect(env.tts.spoken.last.$2, AppLang.en);
    await t.pump(const Duration(milliseconds: 400));
    expect(
      t.widget<KalimatWord>(find.byKey(KalimatScreen.kataKey(1))).sorot,
      isFalse,
    );
  });
  testWidgets('kalimat panjang EN tidak overflow', (t) async {
    await pumpApp(t, initialLocation: '${Routes.kalimat}?kalimat=gajah');
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text('trunk.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.kalimat);
    await t.tap(find.text('Suku Kata'));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      Routes.sukuKata,
    );
  });
}
