import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/mewarnai/kanvas_screen.dart';
import 'package:moci/features/mewarnai/mewarnai_model.dart';
import 'package:moci/features/mewarnai/widgets/coloring_canvas.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

Offset _kanvas(WidgetTester t, double x, double y) =>
    t.getRect(find.byKey(ColoringCanvas.surfaceKey)).topLeft +
    Offset(x, y) * skalaLayar;

Future<void> _buka(
  WidgetTester t, {
  TestEnv? env,
  String halaman = 'kupu',
}) async {
  await pumpApp(t, env: env, initialLocation: '/mewarnai/$halaman');
  // pumpApp hanya memompa dua frame: halaman masih di tengah transisi masuk,
  // dan aset mewarnai perlu satu frame lagi setelah dibaca.
  await t.pump(const Duration(milliseconds: 600));
  await t.pump();
}

bool _bisaBatal(WidgetTester t) =>
    t.widget<MociPressable>(find.byKey(KanvasScreen.undoKey)).onTap != null;

void main() {
  testWidgets('kanvas: judul, 864 x 648, 16 krayon, dan 4 alat', (t) async {
    await _buka(t);
    expect(find.text('Kupu-kupu'), findsOneWidget);
    expect(t.getSize(find.byKey(KanvasScreen.canvasKey)), const Size(864, 648));
    expect(
      t.getSize(find.byKey(KanvasScreen.toolbarKey)),
      const Size(248, 648),
    );
    for (final hex in ['#FF4B4B', '#FF922B', '#FFD43B', '#FFFFFF']) {
      expect(find.byKey(KanvasScreen.crayonKey(hex)), findsOneWidget);
    }
    for (final a in AlatMewarnai.values) {
      expect(find.byKey(KanvasScreen.toolKey(a)), findsOneWidget);
    }
    expect(find.byKey(KanvasScreen.crayonKey('#123456')), findsNothing);
  });

  testWidgets('isi memakai warna krayon dan menulis draf', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await t.tap(find.byKey(KanvasScreen.crayonKey('#FF4B4B')));
    await t.pump();
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
    await t.pump();
    await t.tapAt(_kanvas(t, 400, 100));
    await t.pump(const Duration(milliseconds: 700));
    final json = await env.json.read('draf/kupu.json');
    expect(json, isNotNull);
    expect((json!['isian'] as Map).values, contains('#FF4B4B'));
  });

  testWidgets('halaman kota: isi satu bagian tidak mengubah bagian lain', (
    t,
  ) async {
    final env = TestEnv();
    await _buka(t, env: env, halaman: 'kota-gedung');
    expect(find.text('Gedung Kota'), findsOneWidget);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
    await t.pump();
    // Titik tengah matahari; bagian lain di halaman ini tetap putih.
    await t.tapAt(_kanvas(t, 700, 92));
    await t.pump(const Duration(milliseconds: 700));
    final json = await env.json.read('draf/kota-gedung.json');
    final isian = (json!['isian'] as Map).cast<String, Object?>();
    expect(isian, {'1': '#74C0FC'});
  });
  testWidgets('batal mengembalikan isian dan mulai lagi bisa dibatalkan', (
    t,
  ) async {
    final env = TestEnv();
    await _buka(t, env: env);
    expect(_bisaBatal(t), isFalse);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.isi)));
    await t.pump();
    await t.tapAt(_kanvas(t, 400, 100));
    await t.pump();
    expect(_bisaBatal(t), isTrue);
    await t.tap(find.byKey(KanvasScreen.undoKey));
    await t.pump(const Duration(milliseconds: 700));
    expect(((await env.json.read('draf/kupu.json'))!['isian'] as Map), isEmpty);
    await t.tapAt(_kanvas(t, 400, 100));
    await t.pump();
    await t.tap(find.byKey(KanvasScreen.clearKey));
    await t.pump(const Duration(milliseconds: 700));
    expect(((await env.json.read('draf/kupu.json'))!['isian'] as Map), isEmpty);
    // MociPressable mengabaikan ketukan berulang dalam 400 ms; jam uji diam.
    env.clock.advance(const Duration(milliseconds: 500));
    await t.tap(find.byKey(KanvasScreen.undoKey));
    await t.pump(const Duration(milliseconds: 700));
    expect(
      ((await env.json.read('draf/kupu.json'))!['isian'] as Map),
      isNotEmpty,
    );
    expect(find.text('Ayo mulai dari awal!'), findsNothing);
  });

  testWidgets('membuka lagi memuat draf halaman', (t) async {
    final env = TestEnv();
    await env.json.write('draf/ikan.json', {
      'versi': 1,
      'halaman': 'ikan',
      'isian': {'2': '#1C7ED6'},
      'coretan': {},
      'cap': [],
    });
    await _buka(t, env: env, halaman: 'ikan');
    expect(find.text('Ikan'), findsOneWidget);
    final mesin = t.widget<ColoringCanvas>(find.byType(ColoringCanvas)).mesin;
    expect(mesin.data.isian[2], '#1C7ED6');
    expect(_bisaBatal(t), isFalse);
  });

  testWidgets('ukuran kuas besar menulis coretan 44 unit', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await t.tap(find.byKey(KanvasScreen.sizeKey(UkuranKuas.besar)));
    await t.pump();
    final g = await t.startGesture(_kanvas(t, 10, 10));
    for (var i = 1; i <= 6; i++) {
      await g.moveTo(_kanvas(t, 10 + i * 8, 10));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await t.pump(const Duration(milliseconds: 700));
    final json = await env.json.read('draf/kupu.json');
    final coretan = (json!['coretan'] as Map).values.first as List;
    expect((coretan.first as Map)['lebar'], 44);
  });

  testWidgets('hapus memakai kuas putih 54 unit', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.hapus)));
    await t.pump();
    await t.tap(find.byKey(KanvasScreen.sizeKey(UkuranKuas.besar)));
    await t.pump();
    final g = await t.startGesture(_kanvas(t, 10, 10));
    await g.moveTo(_kanvas(t, 50, 10));
    await t.pump(const Duration(milliseconds: 16));
    await g.up();
    await t.pump(const Duration(milliseconds: 700));
    final json = await env.json.read('draf/kupu.json');
    final coretan = (json!['coretan'] as Map).values.first as List;
    expect((coretan.first as Map)['warna'], '#FFFFFF');
    expect((coretan.first as Map)['lebar'], 54);
  });

  testWidgets('stiker ditempel di kanvas dan tersimpan di draf', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await t.tap(find.byKey(KanvasScreen.toolKey(AlatMewarnai.cap)));
    await t.pump();
    await t.tap(find.byKey(KanvasScreen.capKey('moci-senang')));
    await t.pump();
    await t.tapAt(_kanvas(t, 640, 410));
    await t.pump(const Duration(milliseconds: 700));
    final json = await env.json.read('draf/kupu.json');
    expect((json!['cap'] as List).single, {
      'cap': 'moci-senang',
      'x': 640.0,
      'y': 410.0,
    });
  });

  testWidgets('halaman tak dikenal kembali ke galeri', (t) async {
    final router = await pumpApp(t, initialLocation: '/mewarnai/entah');
    // Transisi selesai dulu agar pengalihan ke galeri tidak tertahan.
    await t.pump(const Duration(milliseconds: 600));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai',
    );
  });
}
