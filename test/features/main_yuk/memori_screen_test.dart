import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/main_yuk/main_yuk_game.dart';
import 'package:moci/features/main_yuk/memori_screen.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

/// Jeda ketuk: `MociPressable` menolak ketukan dalam 400 ms pada tombol yang
/// sama, sedangkan jam palsu hanya bergerak kalau digeser.
const _jeda = Duration(milliseconds: 500);

String _label(WidgetTester t, int i) => t
    .widget<MociPressable>(find.byKey(MemoriScreen.kartuKey(i)))
    .semanticLabel!;

bool _tertutup(WidgetTester t, int i) => _label(t, i) == 'Kartu tertutup';

/// Membuka layar; halaman masih bergeser masuk, jadi ketukan menunggu 600 ms.
Future<void> _buka(WidgetTester t, {TestEnv? env}) async {
  await pumpApp(t, env: env, initialLocation: '/main/memori');
  await t.pump(const Duration(milliseconds: 600));
}

Future<void> _ketuk(WidgetTester t, TestEnv env, int i) async {
  env.clock.advance(_jeda);
  await t.tap(find.byKey(MemoriScreen.kartuKey(i)));
  await t.pump(const Duration(milliseconds: 450));
}

/// Membuka satu pasangan yang memang tidak sama, lalu mengembalikan indeksnya.
Future<(int, int)> _pasanganSalah(
  WidgetTester t,
  TestEnv env,
  int jumlahKartu,
) async {
  for (var a = 0; a < jumlahKartu; a++) {
    if (!_tertutup(t, a)) continue;
    await _ketuk(t, env, a);
    for (var b = a + 1; b < jumlahKartu; b++) {
      if (!_tertutup(t, b)) continue;
      await _ketuk(t, env, b);
      if (_label(t, b) != _label(t, a)) return (a, b);
      break;
    }
  }
  fail('tidak ada pasangan salah');
}

/// Membuka kartu berpasangan sampai semua pasangan ketemu.
Future<void> _selesaikanMemori(
  WidgetTester t,
  TestEnv env,
  int jumlahKartu,
) async {
  for (var putaran = 0; putaran < jumlahKartu; putaran++) {
    final sisa = [
      for (var i = 0; i < jumlahKartu; i++)
        if (_tertutup(t, i)) i,
    ];
    if (sisa.isEmpty) return;
    final a = sisa.first;
    for (final b in sisa.skip(1)) {
      await _ketuk(t, env, a);
      await _ketuk(t, env, b);
      if (!_tertutup(t, b) && _label(t, b) == _label(t, a)) break;
      await t.pump(const Duration(milliseconds: 1000));
    }
  }
  fail('pasangan tidak ketemu semua');
}

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets(
    'layar memori: empat pasang untuk pemula, delapan kartu tertutup',
    (t) async {
      await _buka(t);
      expect(find.text('Kartu Memori'), findsOneWidget);
      expect(find.text('4 pasang'), findsOneWidget);
      expect(find.byKey(MemoriScreen.kartuKey(7)), findsOneWidget);
      expect(find.byKey(MemoriScreen.kartuKey(8)), findsNothing);
      expect(find.text('Langkah: 0'), findsOneWidget);
    },
  );

  testWidgets('kartu tertutup berlabel tersembunyi', (t) async {
    await _buka(t);
    expect(
      t
          .widget<MociPressable>(find.byKey(MemoriScreen.kartuKey(0)))
          .semanticLabel,
      'Kartu tertutup',
    );
  });

  testWidgets('dua kartu terbuka dan kartu ketiga diabaikan', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    final (a, b) = await _pasanganSalah(t, env, 8);
    final labelA = _label(t, a);
    final labelB = _label(t, b);
    expect(find.text('Langkah: 1'), findsOneWidget);

    final ketiga = [
      for (var i = 0; i < 8; i++)
        if (i != a && i != b && _tertutup(t, i)) i,
    ].first;
    await _ketuk(t, env, ketiga);

    // Kartu ketiga tidak membuka dan tidak menambah langkah.
    expect(find.text('Langkah: 1'), findsOneWidget);
    expect(_label(t, ketiga), 'Kartu tertutup');
    expect(_label(t, a), labelA);
    expect(_label(t, b), labelB);

    // Biarkan penutup otomatis selesai sebelum tes berakhir.
    await t.pump(const Duration(milliseconds: 1000));
  });

  testWidgets('pil delapan pasang mengganti papan', (t) async {
    await _buka(t);
    await t.tap(find.text('8 pasang'));
    await t.pump();
    expect(find.byKey(MemoriScreen.kartuKey(15)), findsOneWidget);
    expect(find.byKey(MemoriScreen.kartuKey(16)), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('delapan pasang dari tema kendaraan tidak overflow', (t) async {
    await _buka(t);
    await t.tap(find.byKey(MemoriScreen.temaKey(MainYukTema.kendaraan)));
    await t.pump();
    await t.tap(find.text('8 pasang'));
    await t.pump();
    expect(t.takeException(), isNull);
  });

  testWidgets('semua pasangan membuka Hebat', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await _selesaikanMemori(t, env, 8);
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
  });
}
