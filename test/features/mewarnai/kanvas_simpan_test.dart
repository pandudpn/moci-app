import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/mewarnai/kanvas_screen.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';
import 'package:moci/features/mewarnai/widgets/coloring_canvas.dart';

import '../../helpers/harness.dart';

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)));

List<String> _diwarnai(WidgetTester t) =>
    _container(t)
        .read(progressProvider)
        .perkembangan['mewarnai']?['diwarnai'] ??
    const [];

Future<void> _buka(WidgetTester t, TestEnv env) async {
  await pumpApp(t, env: env, initialLocation: '/mewarnai/kupu');
  // pumpApp hanya memompa dua frame: halaman masih di tengah transisi masuk.
  await t.pump(const Duration(milliseconds: 600));
}

/// `Picture.toImage` di dalam ekspor PNG hanya selesai di zona async nyata,
/// jadi alur Simpan perlu diberi kesempatan sebelum diperiksa.
Future<void> _selesaikan(WidgetTester t) async {
  for (var i = 0; i < 8; i++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await t.pump(const Duration(milliseconds: 16));
  }
}

Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft +
    Offset(x, y) * skalaLayar;

void main() {
  testWidgets('simpan menulis karya dengan PNG dan mencatat progres', (
    t,
  ) async {
    final env = TestEnv();
    await _buka(t, env);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
    await t.pump();
    await t.tapAt(_kanvas(t, 400, 100));
    await t.pump();
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    final files = await env.json.list('karya');
    expect(files, hasLength(1));
    final json = await env.json.read('karya/${files.single}');
    expect(base64Decode(json!['gambar'] as String).sublist(0, 4), [
      0x89,
      0x50,
      0x4E,
      0x47,
    ]);
    expect(json['halaman'], 'kupu');
    expect(find.byKey(KanvasScreen.toastKey), findsOneWidget);
    expect(
      env.tts.spoken.map((e) => e.$1),
      contains('Tersimpan! Bagus sekali!'),
    );
    expect(_diwarnai(t), ['kupu']);
  });

  testWidgets('menekan simpan dua kali hanya membuat satu karya', (t) async {
    final env = TestEnv();
    await _buka(t, env);
    await t.tap(find.byKey(KanvasScreen.saveKey));
    // MociPressable mengabaikan ketukan berulang dalam 400 ms; jam uji diam.
    env.clock.advance(const Duration(milliseconds: 500));
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    expect(await env.json.list('karya'), hasLength(1));
  });

  testWidgets('simpan menyertakan goresan terakhir', (t) async {
    final env = TestEnv();
    await _buka(t, env);
    final g = await t.startGesture(_kanvas(t, 10, 10));
    await g.moveTo(_kanvas(t, 60, 10));
    await t.pump(const Duration(milliseconds: 16));
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await g.up();
    await _selesaikan(t);
    final files = await env.json.list('karya');
    final json = await env.json.read('karya/${files.single}');
    expect((json!['coretan'] as Map).values, isNotEmpty);
  });

  testWidgets('toast hilang setelah 1800 ms', (t) async {
    final env = TestEnv();
    await _buka(t, env);
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    expect(find.byKey(KanvasScreen.toastKey), findsOneWidget);
    await t.pump(const Duration(milliseconds: 1800));
    expect(find.byKey(KanvasScreen.toastKey), findsNothing);
  });

  testWidgets('simpan tidak menghapus draf', (t) async {
    final env = TestEnv();
    await _buka(t, env);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
    await t.pump();
    await t.tapAt(_kanvas(t, 400, 100));
    await t.pump(const Duration(milliseconds: 700));
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    expect(await env.json.read('draf/kupu.json'), isNotNull);
  });

  testWidgets('pemilih gambar berpindah halaman', (t) async {
    final env = TestEnv();
    final router = await pumpApp(
      t,
      env: env,
      initialLocation: '/mewarnai/kupu',
    );
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.text('Gambar'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Pilih gambar'), findsOneWidget);
    await t.tap(find.text('Ikan'));
    await t.pump(const Duration(milliseconds: 600));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai/ikan',
    );
  });

  testWidgets('simpan dua halaman menghasilkan dua karya', (t) async {
    final env = TestEnv();
    await _buka(t, env);
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    await t.tap(find.text('Gambar'));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Ikan'));
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byKey(KanvasScreen.saveKey));
    await _selesaikan(t);
    expect(await env.json.list('karya'), hasLength(2));
  });
}
