import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/routes.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/content/katalog.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/membaca/membaca_providers.dart';
import 'package:moci/features/membaca/susun_kata/susun_kata_screen.dart';
import 'package:moci/features/membaca/susun_kata/susun_tile.dart';
import 'package:moci/widgets/moci_illustration.dart';

import '../../helpers/harness.dart';
import '../../helpers/harness.dart' as harness;

/// Aplikasi utuh, lalu tunggu transisi rute selesai sebelum mengetuk.
Future<GoRouter> pumpApp(
  WidgetTester t, {
  TestEnv? env,
  String? initialLocation,
}) async {
  final router = await harness.pumpApp(
    t,
    env: env,
    initialLocation: initialLocation,
  );
  await t.pump(const Duration(milliseconds: 600));
  return router;
}

Katalog _katalog() => Katalog.fromJson(
  jsonDecode(File('assets/content/katalog.json').readAsStringSync()) as Object?,
);

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

String _item(WidgetTester t) =>
    t.widget<MociIllustration>(find.byType(MociIllustration)).id;

Future<void> _ketukSuku(WidgetTester t, String suku) async {
  final finder = find.byWidgetPredicate(
    (w) => w is SusunTile && w.suku == suku && !w.used,
  );
  await t.tap(finder.first);
  await t.pump();
}

Future<void> _selesaikanKata(WidgetTester t, AppLang lang) async {
  final item = _item(t);
  final entry = (lang == AppLang.en ? _katalog().kata.en : _katalog().kata.id)
      .firstWhere((e) => e.item == item);
  for (final suku in entry.suku) {
    await _ketukSuku(t, suku);
  }
}

/// Lima kata satu level sampai layar Hebat terbuka.
Future<void> _limaKata(WidgetTester t) async {
  for (var i = 0; i < 5; i++) {
    await _selesaikanKata(t, AppLang.id);
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(SusunKataScreen.nextKey));
    if (i == 4) {
      await t.tap(find.byKey(SusunKataScreen.nextKey), warnIfMissed: false);
    }
    await t.pump();
    await t.pump();
  }
  for (var i = 0; i < 10; i++) {
    await t.pump();
  }
}

void main() {
  testWidgets('membuka: level 2, empat keping, dua kotak, dan narasi', (
    t,
  ) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    expect(find.text('2 suku kata'), findsOneWidget);
    expect(find.byType(SusunTile), findsNWidgets(4));
    expect(find.byKey(SusunKataScreen.slotKey(0)), findsOneWidget);
    expect(find.byKey(SusunKataScreen.slotKey(1)), findsOneWidget);
    expect(env.tts.spoken.first.$1, 'Ketuk suku kata secara berurutan');
    expect(t.takeException(), isNull);
  });
  testWidgets('menyusun kata dengan benar menandai suku kata', (t) async {
    // Sumber acak tetap: kata yang terundi sama di setiap jalan.
    final env = TestEnv(
      extraOverrides: [membacaRandomProvider.overrideWithValue(Random(1))],
    );
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    final item = _item(t);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == item);
    await _selesaikanKata(t, AppLang.id);
    await t.pump();
    expect(find.byKey(SusunKataScreen.nextKey), findsOneWidget);
    // Kata di luar kisi (misalnya "ular") tidak mencatat suku kata apa pun.
    final dicatat = _progress(t).perkembangan['membaca']?['dibaca'] ?? const [];
    for (final suku in entry.suku) {
      if (_katalog().sukuKata.semua.contains(suku)) {
        expect(dicatat, contains(suku));
      }
    }
    expect(env.tts.spoken.map((e) => e.$1), contains('Betul!'));
  });
  testWidgets('keping salah mengosongkan kotak', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == _item(t));
    final salah = t
        .widgetList<SusunTile>(find.byType(SusunTile))
        .firstWhere((w) => !entry.suku.contains(w.suku));
    await t.tap(find.byKey(SusunKataScreen.tileKey(salah.index)));
    await t.pump();
    await _ketukSuku(t, entry.suku.first);
    expect(find.text('Ups, belum tepat. Coba lagi!'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1200));
    expect(
      find.descendant(
        of: find.byKey(SusunKataScreen.slotKey(0)),
        matching: find.text('?'),
      ),
      findsOneWidget,
    );
  });
  testWidgets('level 3 punya tiga kotak dan satu pengganggu', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.byKey(SusunKataScreen.levelKey(3)));
    await t.pump();
    expect(find.byType(SusunTile), findsNWidgets(4));
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsOneWidget);
    final entry = _katalog().kata.id.firstWhere((e) => e.item == _item(t));
    expect(entry.level, 3);
    expect(t.takeException(), isNull);
  });
  testWidgets('level 3 dan kata panjang tidak overflow', (t) async {
    await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.byKey(SusunKataScreen.levelKey(3)));
    await t.pump();
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(t.takeException(), isNull);
  });
  testWidgets('ganti bahasa mengganti kolam kata', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    await t.pump();
    expect(_katalog().kata.en.any((e) => e.item == _item(t)), isTrue);
    expect(env.tts.spoken.last.$2, AppLang.en);
  });
  testWidgets('lima kata selesai membuka Hebat sekali', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.susunKata);
    await _limaKata(t);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      Routes.hebat,
    );
    // Pita Hebat menampilkan judul dalam huruf kapital.
    expect(find.text('HEBAT!'), findsOneWidget);
    expect(_progress(t).stars, 3);
    expect(_progress(t).stickers.length, 1);
    await t.pump(const Duration(milliseconds: 500));
    expect(_progress(t).stars, 3);
  });

  testWidgets('Main lagi dari Hebat memulai ronde pertama', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: Routes.susunKata);
    await _limaKata(t);
    expect(find.text('HEBAT!'), findsOneWidget);
    await t.tap(find.text('Main lagi'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    // Transisi keluar Hebat masih berjalan; satu jeda lagi sampai layar ini
    // kembali terpasang.
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(find.text('HEBAT!'), findsNothing);
    // Keping ronde lama sudah terpakai semua; ronde baru memasang keping baru
    // dan tombol "Lanjut" belum ada.
    expect(find.byKey(SusunKataScreen.nextKey), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(SusunKataScreen.slotKey(0)),
        matching: find.text('?'),
      ),
      findsOneWidget,
    );
    // Jam palsu tidak ikut maju oleh pump: nomor ronde dihitung dari jam,
    // jadi ronde kedua harus memakai waktu yang berbeda supaya hadiahnya baru.
    env.clock.advance(const Duration(seconds: 5));
    await _limaKata(t);
    expect(find.text('HEBAT!'), findsOneWidget);
    expect(_progress(t).stars, 6);
  });

  testWidgets('lanjutkan membuka level terakhir', (t) async {
    await pumpApp(t, initialLocation: '${Routes.susunKata}?level=3');
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsOneWidget);
  });
  testWidgets('kueri level tidak dikenal kembali ke level 2', (t) async {
    await pumpApp(t, initialLocation: '${Routes.susunKata}?level=9');
    expect(find.byKey(SusunKataScreen.slotKey(1)), findsOneWidget);
    expect(find.byKey(SusunKataScreen.slotKey(2)), findsNothing);
  });
  testWidgets('pil mode berpindah rute', (t) async {
    final router = await pumpApp(t, initialLocation: Routes.susunKata);
    await t.tap(find.text('Kalimat'));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      Routes.kalimat,
    );
  });
}
