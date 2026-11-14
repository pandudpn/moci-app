import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/content/content_repository.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/main_yuk/balon_game.dart';
import 'package:moci/features/main_yuk/balon_screen.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

/// Huruf target dari kotak huruf di bilah atas.
String _hurufTarget(WidgetTester t) => t
    .widget<Text>(
      find.descendant(
        of: find.byKey(BalonScreen.targetKey),
        matching: find.byType(Text),
      ),
    )
    .data!;

String _labelBalon(WidgetTester t, int i) =>
    t.widget<MociPressable>(find.byKey(BalonScreen.balonKey(i))).semanticLabel!;

/// Indeks balon yang hurufnya sama dengan target.
int _indeksTarget(WidgetTester t) {
  final target = _hurufTarget(t);
  for (var i = 0; i < 6; i++) {
    if (_labelBalon(t, i).endsWith(target)) return i;
  }
  fail('tidak ada balon huruf $target');
}

/// Indeks balon yang hurufnya bukan target.
int _indeksSalah(WidgetTester t) {
  final target = _hurufTarget(t);
  for (var i = 0; i < 6; i++) {
    if (!_labelBalon(t, i).endsWith(target)) return i;
  }
  fail('semua balon huruf $target');
}

/// Nama huruf menurut katalog, sama dengan teks narasi `huruf_<huruf>`.
String _namaHuruf(WidgetTester t, String huruf) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(katalogProvider)
        .huruf
        .firstWhere((e) => e.huruf == huruf)
        .of(AppLang.id)
        .nama;

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar balon: enam balon dan target di bilah atas', (t) async {
    await pumpApp(t, initialLocation: '/main/balon');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Balon Huruf'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      expect(find.byKey(BalonScreen.balonKey(i)), findsOneWidget);
    }
    expect(find.byKey(BalonScreen.targetKey), findsOneWidget);
    expect(find.text('Pecahkan balon huruf'), findsOneWidget);
  });

  testWidgets('pemula hanya memakai sembilan huruf', (t) async {
    await pumpApp(t, initialLocation: '/main/balon');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      final label = _labelBalon(t, i);
      final huruf = label.split(' ').last;
      expect(hurufBalonPemula.contains(huruf), isTrue, reason: label);
    }
  });

  testWidgets('balon salah bergoyang dan target tetap sama', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main/balon');
    await t.pump(const Duration(milliseconds: 600));
    final target = _hurufTarget(t);
    final salah = _indeksSalah(t);
    await t.tap(find.byKey(BalonScreen.balonKey(salah)));
    await t.pump();
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder([
        'Ups, itu huruf',
        _namaHuruf(t, _labelBalon(t, salah).split(' ').last),
      ]),
    );
    expect(_hurufTarget(t), target);
  });

  testWidgets('lima huruf benar membuka Hebat', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main/balon');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 5; i++) {
      // Jam palsu tidak bergerak sendiri; balon yang sama dipakai lagi di
      // ronde berikutnya dan `MociPressable` menolak ketukan dalam 400 ms.
      env.clock.advance(const Duration(milliseconds: 500));
      await t.tap(find.byKey(BalonScreen.balonKey(_indeksTarget(t))));
      await t.pump(const Duration(milliseconds: 1100));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
  });
}
