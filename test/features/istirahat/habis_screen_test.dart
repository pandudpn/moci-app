import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/orang_tua/gerbang_screen.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

/// Batas 30 menit (bawaan) sudah terpakai: membuka `/` dialihkan ke Waktu Habis.
Future<GoRouter> _open(
  WidgetTester t, {
  String childName = '',
  AppLang lang = AppLang.id,
  Size size = tabletSize,
}) async {
  final env = TestEnv(
    childName: childName,
    lang: lang,
    progress: const Progress(playSeconds: {'2026-11-14': 1800}),
  );
  final router = await pumpApp(t, env: env, initialLocation: '/', size: size);
  await t.pump(const Duration(milliseconds: 600));
  expect(
    router.routerDelegate.currentConfiguration.last.matchedLocation,
    '/habis',
  );
  return router;
}

void main() {
  testWidgets('judul, subjudul dengan sebutan Adik, dan catatan', (t) async {
    await _open(t);
    expect(find.text('Waktu main hari ini sudah habis'), findsOneWidget);
    expect(
      find.text('Sampai besok, Adik! Moci juga mau tidur dulu.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Orang tua bisa mengubah batas waktu harian di Area Orang Tua.',
      ),
      findsOneWidget,
    );
    expect(find.text('Untuk orang tua'), findsOneWidget);
  });

  testWidgets('memakai nama anak dan bahasa EN', (t) async {
    await _open(t, childName: 'Budi', lang: AppLang.en);
    expect(
      find.text('See you tomorrow, Budi! Moci is going to sleep too.'),
      findsOneWidget,
    );
    expect(find.text('For grown-ups'), findsOneWidget);
  });

  testWidgets('judul dinarasikan sekali tanpa nama (D5)', (t) async {
    final env = TestEnv(
      childName: 'Budi',
      progress: const Progress(playSeconds: {'2026-11-14': 1800}),
    );
    await pumpApp(t, env: env, initialLocation: '/');
    await t.pump(const Duration(milliseconds: 600));
    expect(env.tts.spoken, [('Waktu main hari ini sudah habis', AppLang.id)]);
  });

  testWidgets('pil orang tua membuka Gerbang menuju Area Orang Tua', (t) async {
    final router = await _open(t);
    await t.tap(find.text('Untuk orang tua'));
    await t.pump(const Duration(milliseconds: 600));
    await t.pump();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/gerbang',
    );
    expect(
      t.widget<GerbangScreen>(find.byType(GerbangScreen)).lanjut,
      '/orang-tua',
    );
  });

  for (final (name, size, min) in [
    ('tablet', tabletSize, 64.0),
    ('HP', phoneSize, 56.0),
  ]) {
    testWidgets('area sentuh pil orang tua minimal $min di $name', (t) async {
      await _open(t, size: size);
      final rect = t.getRect(find.byType(MociPressable));
      expect(rect.width, greaterThanOrEqualTo(min - 0.01));
      expect(rect.height, greaterThanOrEqualTo(min - 0.01));
    });
  }
}
