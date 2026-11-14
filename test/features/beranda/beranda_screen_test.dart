import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/app/theme/moci_metrics.dart';
import 'package:moci/core/audio/audio_service.dart';
import 'package:moci/core/audio/sfx.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/features/beranda/beranda_menu.dart';
import 'package:moci/features/beranda/beranda_screen.dart';
import 'package:moci/features/beranda/widgets/continue_card.dart';

import '../../helpers/harness.dart';

const _titlesId = {
  BerandaMenu.huruf: 'Kenal Huruf',
  BerandaMenu.angka: 'Berhitung',
  BerandaMenu.hewan: 'Dunia Hewan',
  BerandaMenu.buah: 'Buah & Sayur',
  BerandaMenu.baca: 'Ayo Membaca',
  BerandaMenu.main: 'Main Yuk!',
  BerandaMenu.warnai: 'Mewarnai',
  BerandaMenu.warna: 'Warna',
  BerandaMenu.bentuk: 'Bentuk',
  BerandaMenu.musik: 'Main Musik',
};

/// Rute teratas, termasuk rute hasil `push` (`uri` mengabaikannya).
RouteMatchBase _top(GoRouter r) => r.routerDelegate.currentConfiguration.last;

/// URI lengkap (dengan query) rute teratas hasil `push`.
Uri _topUri(GoRouter r) {
  final top = _top(r);
  return top is ImperativeRouteMatch
      ? top.matches.uri
      : r.routerDelegate.currentConfiguration.uri;
}

/// Tanpa `pumpAndSettle`: Moci beranimasi terus.
Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(milliseconds: 500));
}

Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  Size size = tabletSize,
}) async {
  final router = await pumpApp(
    t,
    env: env ?? TestEnv(),
    size: size,
    initialLocation: '/',
  );
  await _settle(t);
  return router;
}

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(BerandaScreen)));

Future<void> _tapMenu(WidgetTester t, BerandaMenu m) async {
  final card = find.byKey(ValueKey('menu-${m.name}'));
  await t.scrollUntilVisible(
    card,
    200,
    scrollable: find.descendant(
      of: find.byType(BerandaScreen),
      matching: find.byType(Scrollable),
    ),
  );
  await t.tap(card);
  await t.pump(const Duration(milliseconds: 100));
}

void _pressTests() {
  group('tombol ID/EN: efek tekan', () {
    testWidgets('klik sfx sekali per ketukan', (t) async {
      final env = TestEnv(assets: {Sfx.klik.asset});
      await _open(t, env: env);
      await t.tap(find.byKey(const ValueKey('lang-en')));
      await t.pump(const Duration(milliseconds: 100));
      expect(
        env.audio.plays.where((p) => p.asset == Sfx.klik.asset),
        hasLength(1),
      );
    });

    testWidgets('ditekan: visual EN turun 5 dan mengecil 0,97', (t) async {
      await _open(t);
      final en = find.byKey(const ValueKey('lang-en'));
      final g = await t.startGesture(t.getCenter(en));
      await t.pump();
      await t.pump(const Duration(milliseconds: 120));
      final tr = t.widget<Transform>(
        find.descendant(of: en, matching: find.byType(Transform)).first,
      );
      final m = tr.transform;
      expect(m.getTranslation().y, closeTo(5, 0.01));
      expect(m.storage[0], closeTo(0.97, 0.001));
      // Hanya setengah EN yang bergerak, bukan sakelar utuh.
      final id = find.byKey(const ValueKey('lang-id'));
      final idTr = t.widget<Transform>(
        find.descendant(of: id, matching: find.byType(Transform)).first,
      );
      expect(idTr.transform.getTranslation().y, 0);
      await g.up();
      await t.pump(const Duration(milliseconds: 200));
    });

    testWidgets('dua ketukan dalam jeda: narasi sekali', (t) async {
      final env = TestEnv();
      await _open(t, env: env);
      final en = find.byKey(const ValueKey('lang-en'));
      await t.tap(en);
      await t.pump(const Duration(milliseconds: 50));
      await t.tap(en);
      await t.pump(const Duration(milliseconds: 50));
      expect(env.tts.spoken.where((s) => s.$1 == 'English'), hasLength(1));
    });
  });
}

void main() {
  _pressTests();
  _targetTests();

  for (final (name, size) in [('tablet', tabletSize), ('HP', phoneSize)]) {
    group('kartu menu ($name)', () {
      for (final m in BerandaMenu.values) {
        testWidgets('${m.name}: membuka ${m.route} dan membacakan judulnya', (
          t,
        ) async {
          final env = TestEnv();
          final router = await _open(t, env: env, size: size);
          await _tapMenu(t, m);
          expect(_top(router).matchedLocation, m.route);
          expect(env.tts.spoken.last.$1, _titlesId[m]);
          expect(env.tts.spoken.last.$2, AppLang.id);
        });
      }
    });
  }

  testWidgets('kartu menu berurutan per kolom: dua baris', (t) async {
    await _open(t);
    final order = [
      for (final m in BerandaMenu.values)
        t.getTopLeft(find.byKey(ValueKey('menu-${m.name}'))),
    ];
    // (huruf, angka), (hewan, buah), ... : x sama dalam satu kolom.
    for (var i = 0; i < order.length; i += 2) {
      expect(order[i].dx, order[i + 1].dx);
      expect(order[i].dy, lessThan(order[i + 1].dy));
    }
    expect(order[2].dx, greaterThan(order[0].dx));
  });

  testWidgets('sapaan: Adik bila nama kosong', (t) async {
    await _open(t);
    expect(find.text('Hai, Adik!'), findsOneWidget);
    expect(find.text('Mau main apa hari ini?'), findsOneWidget);
  });

  testWidgets('sapaan EN dengan nama', (t) async {
    await _open(
      t,
      env: TestEnv(lang: AppLang.en, childName: 'Raka'),
    );
    expect(find.text('Hi, Raka!'), findsOneWidget);
  });

  testWidgets('sapaan HP hanya satu baris', (t) async {
    await _open(t, size: phoneSize);
    expect(find.text('Hai, Adik!'), findsOneWidget);
    expect(find.text('Mau main apa hari ini?'), findsNothing);
  });

  testWidgets('mengetuk Moci membacakan berandaSay tanpa nama (D5)', (t) async {
    final env = TestEnv(childName: 'Raka');
    await _open(t, env: env);
    await t.tap(find.byKey(const ValueKey('beranda-moci')));
    await t.pump(const Duration(milliseconds: 100));
    expect(env.tts.spoken.last, (
      'Hai! Aku Moci. Mau main apa hari ini?',
      AppLang.id,
    ));
    expect(find.text('Hai, Raka!'), findsOneWidget);
  });

  testWidgets('tanpa lastActivity kartu Lanjutkan tidak ada (D6)', (t) async {
    await _open(t);
    expect(find.byType(ContinueCard), findsNothing);
  });

  for (final (name, size) in [('tablet', tabletSize), ('HP', phoneSize)]) {
    testWidgets('Lanjutkan ($name): judul menu, mengetuknya membuka /hewan', (
      t,
    ) async {
      final router = await _open(
        t,
        size: size,
        env: TestEnv(
          progress: const Progress(lastActivity: LastActivity('/hewan')),
        ),
      );
      final card = find.byType(ContinueCard);
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('Dunia Hewan')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('LANJUTKAN')),
        findsOneWidget,
      );
      await t.tap(card);
      await t.pump(const Duration(milliseconds: 100));
      expect(_top(router).matchedLocation, '/hewan');
    });
  }

  testWidgets('Lanjutkan membawa params sebagai query', (t) async {
    final router = await _open(
      t,
      env: TestEnv(
        progress: const Progress(
          lastActivity: LastActivity('/huruf/tulis', {'huruf': 'A'}),
        ),
      ),
    );
    // Tanpa entri khusus, judul menu induk (/huruf) dipakai.
    expect(
      find.descendant(
        of: find.byType(ContinueCard),
        matching: find.text('Kenal Huruf'),
      ),
      findsOneWidget,
    );
    await t.tap(find.byType(ContinueCard));
    await t.pump(const Duration(milliseconds: 100));
    expect(_top(router).matchedLocation, '/huruf/tulis');
    expect(_topUri(router).queryParameters, {'huruf': 'A'});
  });

  testWidgets('Lanjutkan disembunyikan bila rute tidak dikenal', (t) async {
    await _open(
      t,
      env: TestEnv(
        progress: const Progress(lastActivity: LastActivity('/entah')),
      ),
    );
    expect(find.byType(ContinueCard), findsNothing);
  });

  testWidgets('mengetuk EN: bahasa berganti, judul berganti, EN dibacakan', (
    t,
  ) async {
    final env = TestEnv();
    await _open(t, env: env);
    expect(find.text('Kenal Huruf'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('lang-en')));
    await t.pump(const Duration(milliseconds: 100));
    expect(_container(t).read(prefsProvider).lang, AppLang.en);
    expect(find.text('Letters'), findsOneWidget);
    expect(env.tts.spoken.last, ('English', AppLang.en));
    await t.tap(find.byKey(const ValueKey('lang-id')));
    await t.pump(const Duration(milliseconds: 100));
    expect(env.tts.spoken.last, ('Bahasa Indonesia', AppLang.id));
    expect(find.text('Kenal Huruf'), findsOneWidget);
  });

  testWidgets('mengetuk Orang Tua membuka gerbang dengan lanjut=/orang-tua', (
    t,
  ) async {
    final router = await _open(t);
    await t.tap(find.byKey(const ValueKey('parents-button')));
    await t.pump(const Duration(milliseconds: 100));
    expect(_top(router).matchedLocation, '/gerbang');
    expect(_topUri(router).queryParameters['lanjut'], '/orang-tua');
  });

  testWidgets('label semantik bintang, ID dan EN (plural)', (t) async {
    final handle = t.ensureSemantics();
    await _open(t, env: TestEnv(progress: const Progress(stars: 24)));
    expect(find.bySemanticsLabel('24 bintang'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('lang-en')));
    await _settle(t);
    expect(find.bySemanticsLabel('24 stars'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('label semantik 1 bintang (EN)', (t) async {
    final handle = t.ensureSemantics();
    await _open(
      t,
      env: TestEnv(lang: AppLang.en, progress: const Progress(stars: 1)),
    );
    expect(find.bySemanticsLabel('1 star'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('back sistem di Beranda ditelan, tetap di /', (t) async {
    final router = await _open(t);
    expect(await t.binding.handlePopRoute(), isTrue);
    await t.pump();
    expect(_top(router).matchedLocation, '/');
  });

  testWidgets('musik latar mulai setelah frame pertama bila musik nyala', (
    t,
  ) async {
    final env = TestEnv(assets: {AudioService.musicAsset});
    await _open(t, env: env);
    expect(env.audio.plays.map((p) => p.asset), [AudioService.musicAsset]);
  });

  testWidgets('musik mati: tidak ada yang diputar', (t) async {
    final env = TestEnv(assets: {AudioService.musicAsset});
    env.store.setBool('moci.musik', false);
    await _open(t, env: env);
    expect(env.audio.plays, isEmpty);
  });

  testWidgets('musik gagal dimulai: tidak melempar, dicatat', (t) async {
    final env = TestEnv(assets: {AudioService.musicAsset});
    env.audio.gagalPlay = true;
    final logs = <String>[];
    final lama = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) {
      if (m != null) logs.add(m);
    };
    addTearDown(() => debugPrint = lama);
    await _open(t, env: env);
    await t.pump();
    expect(t.takeException(), isNull);
    expect(logs.where((l) => l.contains('musik latar')), isNotEmpty);
  });

  testWidgets('tombol Orang Tua tablet: tepi kanan 32 pt', (t) async {
    await _open(t);
    final r = t.getRect(find.byKey(const ValueKey('parents-button')));
    expect(r.right, tabletSize.width - MociSize.edgeTablet);
  });
}

void _expectMin(WidgetTester t, Finder f, double min, String what) {
  final s = t.getSize(f);
  expect(s.width, greaterThanOrEqualTo(min), reason: '$what lebar');
  expect(s.height, greaterThanOrEqualTo(min), reason: '$what tinggi');
}

void _targetTests() {
  for (final (name, size, min) in [
    ('tablet', tabletSize, 64.0),
    ('HP', phoneSize, 56.0),
  ]) {
    group('area sentuh ($name)', () {
      testWidgets('semua target interaktif minimal $min', (t) async {
        await _open(
          t,
          size: size,
          env: TestEnv(
            progress: const Progress(lastActivity: LastActivity('/hewan')),
          ),
        );
        for (final key in [
          'lang-id',
          'lang-en',
          'parents-button',
          'beranda-moci',
        ]) {
          _expectMin(t, find.byKey(ValueKey(key)), min, key);
        }
        for (final m in BerandaMenu.values) {
          _expectMin(t, find.byKey(ValueKey('menu-${m.name}')), min, m.name);
        }
        _expectMin(t, find.byType(ContinueCard), min, 'lanjutkan');
      });

      testWidgets('ketukan di luar visual tetapi dalam area minimal', (
        t,
      ) async {
        final router = await _open(t, size: size);
        final dy = min / 2 - 1;
        await t.tapAt(
          t.getCenter(find.byKey(const ValueKey('lang-en'))) + Offset(0, dy),
        );
        await t.pump(const Duration(milliseconds: 100));
        expect(_container(t).read(prefsProvider).lang, AppLang.en);
        await t.tapAt(
          t.getCenter(find.byKey(const ValueKey('lang-id'))) + Offset(0, -dy),
        );
        await t.pump(const Duration(milliseconds: 100));
        expect(_container(t).read(prefsProvider).lang, AppLang.id);
        await t.tapAt(
          t.getCenter(find.byKey(const ValueKey('parents-button'))) +
              Offset(0, dy),
        );
        await t.pump(const Duration(milliseconds: 100));
        expect(_top(router).matchedLocation, '/gerbang');
      });
    });
  }
}
