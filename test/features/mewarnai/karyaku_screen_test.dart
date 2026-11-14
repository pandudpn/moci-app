import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/mewarnai/karyaku_screen.dart';

import '../../helpers/harness.dart';

Future<void> _tulisKarya(
  TestEnv env,
  String id,
  String halaman, {
  int hari = 14,
  String gambar = '',
}) => env.json.write('karya/$id.json', {
  'versi': 1,
  'id': id,
  'halaman': halaman,
  'isian': {'1': '#FF4B4B'},
  'coretan': {},
  'cap': [],
  'waktu': '2026-11-${hari.toString().padLeft(2, '0')}T10:00:00.000',
  'gambar': gambar,
});

Future<void> _bukaKaryaku(WidgetTester t, TestEnv env) async {
  await pumpApp(t, env: env, initialLocation: '/karyaku');
  // pumpApp hanya memompa dua frame: halaman masih di tengah transisi masuk.
  await t.pump(const Duration(milliseconds: 600));
}

Future<void> _bukaKarya(WidgetTester t, String id) async {
  await t.tap(find.byKey(KaryakuScreen.cardKey(id)));
  await t.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('kosong: ajakan mewarnai', (t) async {
    await _bukaKaryaku(t, TestEnv());
    expect(find.text('Karyaku'), findsOneWidget);
    expect(find.byKey(KaryakuScreen.emptyKey), findsOneWidget);
    expect(find.text('Belum ada karya'), findsOneWidget);
  });

  testWidgets('tiga karya: hitungan, nama, dan urutan', (t) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu', hari: 12);
    await _tulisKarya(env, 'k2', 'ikan', hari: 13);
    await _tulisKarya(env, 'k3', 'rumah', hari: 14);
    await _bukaKaryaku(t, env);
    expect(find.text('3 karya'), findsOneWidget);
    expect(find.byKey(KaryakuScreen.cardKey('k3')), findsOneWidget);
    expect(find.text('Rumah'), findsOneWidget);
  });

  testWidgets('buka karya: pratinjau besar dan tutup', (t) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu');
    await _bukaKaryaku(t, env);
    await _bukaKarya(t, 'k1');
    expect(find.text('Warnai lagi'), findsOneWidget);
    await t.tap(find.text('Tutup'));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Warnai lagi'), findsNothing);
  });

  testWidgets('hapus dua langkah', (t) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu');
    await _bukaKaryaku(t, env);
    await _bukaKarya(t, 'k1');
    await t.tap(find.text('Hapus'));
    await t.pump();
    expect(find.text('Yakin hapus?'), findsOneWidget);
    // Tombol yang sama berganti label; ketukan berulang kena jeda 400 ms.
    env.clock.advance(const Duration(milliseconds: 500));
    await t.tap(find.text('Yakin hapus?'));
    await t.pump(const Duration(milliseconds: 300));
    expect(await env.json.list('karya'), isEmpty);
    expect(find.byKey(KaryakuScreen.emptyKey), findsOneWidget);
  });

  testWidgets('warnai lagi menyalin karya ke draf lalu membuka kanvas', (
    t,
  ) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu');
    final router = await pumpApp(t, env: env, initialLocation: '/karyaku');
    await t.pump(const Duration(milliseconds: 600));
    await _bukaKarya(t, 'k1');
    await t.tap(find.text('Warnai lagi'));
    await t.pump(const Duration(milliseconds: 600));
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/mewarnai/kupu',
    );
    final draf = await env.json.read('draf/kupu.json');
    expect((draf!['isian'] as Map)['1'], '#FF4B4B');
  });

  testWidgets('hapus karya tidak menghapus draf', (t) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu');
    await env.json.write('draf/kupu.json', {
      'versi': 1,
      'halaman': 'kupu',
      'isian': {'2': '#1C7ED6'},
      'coretan': {},
      'cap': [],
    });
    await _bukaKaryaku(t, env);
    await _bukaKarya(t, 'k1');
    await t.tap(find.text('Hapus'));
    await t.pump();
    env.clock.advance(const Duration(milliseconds: 500));
    await t.tap(find.text('Yakin hapus?'));
    await t.pump(const Duration(milliseconds: 300));
    expect(await env.json.read('draf/kupu.json'), isNotNull);
  });

  testWidgets('dua belas karya dan hitungannya', (t) async {
    final env = TestEnv();
    for (var i = 0; i < 12; i++) {
      await _tulisKarya(env, 'k$i', 'kupu', hari: i + 1);
    }
    await _bukaKaryaku(t, env);
    expect(find.text('12 karya'), findsOneWidget);
    await t.drag(find.byType(GridView), const Offset(0, -600));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  testWidgets('gambar rusak jatuh ke pratinjau dari data', (t) async {
    final env = TestEnv();
    await _tulisKarya(env, 'k1', 'kupu', gambar: 'bukan-png');
    await _bukaKaryaku(t, env);
    expect(find.byKey(KaryakuScreen.cardKey('k1')), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
