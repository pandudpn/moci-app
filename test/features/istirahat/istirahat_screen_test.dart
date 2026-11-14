import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:moci/core/lang.dart';

import '../../helpers/harness.dart';

/// Membuka `/istirahat` di atas `/hewan` dan mengembalikan routernya.
Future<GoRouter> _open(WidgetTester t, TestEnv env, {Size? size}) async {
  final router = await pumpApp(
    t,
    env: env,
    initialLocation: '/',
    size: size ?? tabletSize,
  );
  router.push('/hewan');
  await t.pump(const Duration(milliseconds: 600));
  router.push('/istirahat');
  await t.pump(const Duration(milliseconds: 600));
  await t.pump(); // rute yang baru didorong baru tampil setelah satu frame lagi
  return router;
}

void main() {
  testWidgets('langkah aktif berganti di detik ke-0, 7, dan 14', (t) async {
    final env = TestEnv();
    await _open(t, env);

    bool active(String text) {
      final box = t.widget<Opacity>(
        find
            .ancestor(of: find.text(text), matching: find.byType(Opacity))
            .first,
      );
      return box.opacity == 1;
    }

    expect(find.text('Istirahat sebentar, yuk!'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(active('Lihat jauh ke luar jendela'), isTrue);
    expect(active('Kedip-kedip 10 kali'), isFalse);

    await t.pump(const Duration(seconds: 7));
    expect(find.text('13'), findsOneWidget);
    expect(active('Kedip-kedip 10 kali'), isTrue);
    expect(active('Lihat jauh ke luar jendela'), isFalse);

    await t.pump(const Duration(seconds: 7));
    expect(find.text('6'), findsOneWidget);
    expect(active('Regangkan tangan ke atas'), isTrue);
    expect(active('Kedip-kedip 10 kali'), isFalse);

    await t.pump(const Duration(seconds: 7));
    await t.pump(const Duration(milliseconds: 600));
  });

  testWidgets('tiap langkah dinarasikan saat mulai', (t) async {
    final env = TestEnv();
    await _open(t, env);
    // Baris pertama milik layar /hewan di bawahnya (nama hewan).
    expect(env.tts.spoken.skip(1), [
      ('Istirahat sebentar, yuk!', AppLang.id),
      ('Lihat jauh ke luar jendela', AppLang.id),
    ]);

    await t.pump(const Duration(seconds: 7));
    expect(env.tts.spoken.last, ('Kedip-kedip 10 kali', AppLang.id));
    await t.pump(const Duration(seconds: 7));
    expect(env.tts.spoken.last, ('Regangkan tangan ke atas', AppLang.id));
    await t.pump(const Duration(seconds: 6));
    expect(env.tts.spoken.last, ('Sudah segar lagi!', AppLang.id));
    await t.pump(const Duration(milliseconds: 600));
  });

  testWidgets('tanpa tombol lewati dan tanpa pil orang tua', (t) async {
    final env = TestEnv();
    await _open(t, env);
    expect(find.text('Lanjut main'), findsNothing);
    expect(find.text('Untuk orang tua'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Sisa waktu istirahat: 20 detik',
      ),
      findsOneWidget,
    );
    await t.pump(const Duration(seconds: 20));
    await t.pump(const Duration(milliseconds: 600));
  });

  testWidgets('back sistem tidak menutup Istirahat', (t) async {
    final env = TestEnv();
    final router = await _open(t, env);
    await t.binding.handlePopRoute();
    await t.pump(const Duration(milliseconds: 600));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/istirahat',
    );
    await t.pump(const Duration(seconds: 20));
    await t.pump(const Duration(milliseconds: 600));
  });
}
