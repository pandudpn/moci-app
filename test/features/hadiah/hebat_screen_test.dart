import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moci/app/theme/moci_theme.dart';
import 'package:moci/core/audio/sfx.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/features/hadiah/hadiah_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/hadiah/stiker.dart';
import 'package:moci/l10n/l10n.dart';
import 'package:moci/widgets/moci_mascot.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

const _delapan = [
  'kucing',
  'bola',
  'ikan',
  'singa',
  'gajah',
  'panda',
  'pinguin',
  'apel',
];

TestEnv _env({
  AppLang lang = AppLang.id,
  String childName = '',
  Progress? progress,
}) => TestEnv(
  lang: lang,
  childName: childName,
  assets: {Sfx.sorak.asset},
  progress: progress ?? const Progress(stars: 27, stickers: _delapan),
);

const _args = HebatArgs(
  award: AwardResult(stars: 3, sticker: 'apel'),
  replayRoute: '/main/balon',
);

Future<GoRouter> _open(
  WidgetTester t, {
  TestEnv? env,
  Size size = tabletSize,
  HebatArgs? args = _args,
  bool settle = true,
}) async {
  final router = await pumpApp(
    t,
    env: env ?? _env(),
    size: size,
    initialLocation: '/',
  );
  router.go('/hebat', extra: args);
  await t.pump();
  await t.pump(const Duration(milliseconds: 100));
  // Masuk-nya kartu dan bintang selesai, dan Beranda di bawahnya sudah dilepas.
  if (settle) await t.pump(const Duration(milliseconds: 1500));
  return router;
}

String _top(GoRouter r) =>
    r.routerDelegate.currentConfiguration.last.matchedLocation;

double _scale(WidgetTester t, int star) => t
    .widget<Transform>(
      find
          .descendant(
            of: find.byKey(ValueKey('hebat-star-$star')),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform
    .getColumn(0)
    .length;

final _moci = find.descendant(
  of: find.byType(HebatScreen),
  matching: find.byType(MociMascot),
);

void main() {
  testWidgets('teks utama ID: judul, bintang, stiker baru, album', (t) async {
    await _open(t);
    expect(find.text('HEBAT!'), findsOneWidget);
    expect(find.text('Kamu dapat 3 bintang!'), findsOneWidget);
    expect(find.text('STIKER BARU'), findsOneWidget);
    expect(find.text('Apel'), findsOneWidget);
    expect(find.text('ALBUM STIKER'), findsOneWidget);
    expect(find.text('8 / 30'), findsOneWidget);
    expect(find.text('BARU'), findsOneWidget);
    expect(find.text('Main lagi'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    // Pil bintang: total dari progres, tambahan dari hadiah.
    expect(find.text('27'), findsOneWidget);
    expect(find.text('+3'), findsOneWidget);
    expect(find.bySemanticsLabel('27 bintang, bertambah 3'), findsOneWidget);
  });

  testWidgets('teks utama EN', (t) async {
    await _open(t, env: _env(lang: AppLang.en));
    expect(find.text('GREAT JOB!'), findsOneWidget);
    expect(find.text('You earned 3 stars!'), findsOneWidget);
    expect(find.text('NEW STICKER'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('STICKER BOOK'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('Play more'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('saat dibuka: narasi hebatGreat lalu sorak', (t) async {
    final env = _env();
    await _open(t, env: env);
    expect(env.tts.spoken.first, ('Hebat!', AppLang.id));
    expect(
      env.audio.plays.where((p) => p.asset == Sfx.sorak.asset),
      hasLength(1),
    );
  });

  testWidgets('bintang muncul berurutan 0,3 / 0,55 / 0,8 detik', (t) async {
    await _open(t, settle: false);
    // Layar sudah berjalan 100 ms: belum ada bintang yang mulai.
    for (var i = 0; i < 3; i++) {
      expect(_scale(t, i), 0, reason: 'bintang $i di 100 ms');
    }
    await t.pump(const Duration(milliseconds: 250)); // 350 ms
    expect(_scale(t, 0), greaterThan(0));
    expect(_scale(t, 1), 0);
    expect(_scale(t, 2), 0);
    await t.pump(const Duration(milliseconds: 300)); // 650 ms
    expect(_scale(t, 1), greaterThan(0));
    expect(_scale(t, 2), 0);
    await t.pump(const Duration(milliseconds: 200)); // 850 ms
    expect(_scale(t, 2), greaterThan(0));
    await t.pump(const Duration(milliseconds: 700)); // 1550 ms
    for (var i = 0; i < 3; i++) {
      expect(_scale(t, i), closeTo(1, 1e-6), reason: 'bintang $i selesai');
    }
  });

  testWidgets('mengetuk Moci: narasi hebatYay tanpa nama anak (D5)', (t) async {
    final env = _env(childName: 'Budi');
    await _open(t, env: env);
    // Teks di layar memakai nama.
    expect(find.text('Yeay, Budi berhasil!'), findsOneWidget);
    env.tts.spoken.clear();
    await t.tap(_moci, warnIfMissed: false);
    await t.pump();
    expect(env.tts.spoken, [
      (
        'Yeay, kamu berhasil! Kamu dapat tiga bintang dan stiker baru!',
        AppLang.id,
      ),
    ]);
    expect(env.tts.spoken.single.$1, isNot(contains('Budi')));
    expect(env.tts.spoken.single.$1, isNot(contains('Apel')));
  });

  testWidgets('mengetuk gelembung Moci juga menarasikan, sekali', (t) async {
    final env = _env();
    await _open(t, env: env);
    env.tts.spoken.clear();
    await t.tap(find.text('Yeay, kamu berhasil!'));
    await t.pump();
    expect(env.tts.spoken, hasLength(1));
  });

  testWidgets('tanpa stiker baru: tanpa medali, album 30 / 30', (t) async {
    await _open(
      t,
      env: _env(progress: const Progress(stars: 27, stickers: stickerCatalog)),
      args: const HebatArgs(
        award: AwardResult(stars: 3),
        replayRoute: '/main/balon',
      ),
    );
    expect(find.text('STIKER BARU'), findsNothing);
    expect(find.text('BARU'), findsNothing);
    expect(find.text('30 / 30'), findsOneWidget);
    expect(find.text('Kamu dapat 3 bintang!'), findsOneWidget);
  });

  testWidgets('"Main lagi" menuju rute permainan', (t) async {
    final router = await _open(t);
    await t.tap(find.text('Main lagi'));
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/main/balon');
  });

  testWidgets('"Lanjut" menuju Beranda', (t) async {
    final router = await _open(t);
    await t.tap(find.text('Lanjut'));
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/');
  });

  testWidgets('ketukan ganda cepat di "Lanjut" hanya satu navigasi', (t) async {
    var menujuBeranda = 0;
    final env = _env();
    addTearDown(env.ticks.close);
    useScreen(t, tabletSize);
    final router = GoRouter(
      initialLocation: '/hebat',
      initialExtra: _args,
      redirect: (context, state) {
        if (state.uri.path == '/') menujuBeranda++;
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        GoRoute(
          path: '/hebat',
          builder: (_, state) => HebatScreen(args: state.extra! as HebatArgs),
        ),
      ],
    );
    addTearDown(router.dispose);
    await t.pumpWidget(
      ProviderScope(
        overrides: env.overrides,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: mociTheme(),
            locale: Locale(ref.watch(prefsProvider.select((p) => p.lang)).name),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            routerConfig: router,
          ),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 100));
    expect(menujuBeranda, 0);
    final lanjut = find.text('Lanjut');
    await t.tap(lanjut);
    await t.tap(lanjut);
    await t.pump(const Duration(milliseconds: 600));
    expect(menujuBeranda, 1);
  });

  testWidgets('/hebat tanpa HebatArgs dialihkan ke Beranda', (t) async {
    final router = await _open(t, args: null);
    await t.pump(const Duration(milliseconds: 600));
    expect(_top(router), '/');
    expect(find.text('HEBAT!'), findsNothing);
  });

  for (final (name, size, min) in [
    ('tablet', tabletSize, 64.0),
    ('HP', phoneSize, 56.0),
  ]) {
    testWidgets('area sentuh tombol dan Moci minimal $min di $name', (t) async {
      await _open(t, size: size);
      for (final label in ['Main lagi', 'Lanjut']) {
        final rect = t.getRect(find.widgetWithText(MociPressable, label));
        expect(rect.width, greaterThanOrEqualTo(min - 0.01), reason: label);
        expect(rect.height, greaterThanOrEqualTo(min - 0.01), reason: label);
      }
      final moci = t.getRect(_moci);
      expect(moci.width, greaterThanOrEqualTo(min - 0.01));
      expect(moci.height, greaterThanOrEqualTo(min - 0.01));
    });
  }
}
