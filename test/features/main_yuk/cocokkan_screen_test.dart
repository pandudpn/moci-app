import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/prefs/prefs_controller.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/main_yuk/cocokkan_game.dart';
import 'package:moci/features/main_yuk/cocokkan_screen.dart';
import 'package:moci/widgets/pressable.dart';

import '../../helpers/harness.dart';

Future<void> _buka(WidgetTester t, {TestEnv? env}) async {
  await pumpApp(t, env: env, initialLocation: '/main/cocokkan');
  // Halaman masih bergeser masuk; tap dan ukuran baru tepat setelah selesai.
  await t.pump(const Duration(milliseconds: 600));
}

String _label(WidgetTester t, CocokkanSisi s, int i) => t
    .widget<MociPressable>(find.byKey(CocokkanScreen.kartuKey(s, i)))
    .semanticLabel!;

int _cariKartu(WidgetTester t, CocokkanSisi s, String label) {
  for (
    var i = 0;
    find.byKey(CocokkanScreen.kartuKey(s, i)).evaluate().isNotEmpty;
    i++
  ) {
    if (_label(t, s, i) == label) return i;
  }
  fail('tidak ada kartu ${s.name} "$label"');
}

Future<void> _ketukPasangan(WidgetTester t, CocokkanSisi s, int i) async {
  final label = _label(t, s, i);
  await t.tap(find.byKey(CocokkanScreen.kartuKey(s, i)));
  await t.pump(const Duration(milliseconds: 450));
  final lain = s == CocokkanSisi.kiri ? CocokkanSisi.kanan : CocokkanSisi.kiri;
  await t.tap(
    find.byKey(CocokkanScreen.kartuKey(lain, _cariKartu(t, lain, label))),
  );
  await t.pump(const Duration(milliseconds: 450));
}

Future<void> _selesaikan(WidgetTester t, int jumlah) async {
  for (var i = 0; i < jumlah; i++) {
    await _ketukPasangan(t, CocokkanSisi.kiri, i);
  }
}

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar cocokkan: tiga pasang, tema buah, dan instruksi', (
    t,
  ) async {
    await _buka(t);
    expect(find.text('Cocokkan!'), findsOneWidget);
    expect(find.text('Cocokkan Buah yang Sama'), findsOneWidget);
    expect(find.text('3 pasang'), findsOneWidget);
    expect(find.byKey(CocokkanScreen.boardKey), findsOneWidget);
    expect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, 2)),
      findsOneWidget,
    );
  });

  testWidgets('ketuk dua gambar sama menggambar garis dan bicara', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    final nama = _label(t, CocokkanSisi.kiri, 0);
    await _ketukPasangan(t, CocokkanSisi.kiri, 0);
    expect(find.byKey(CocokkanScreen.garisKey(0)), findsOneWidget);
    expect(
      env.tts.spoken.map((e) => e.$1),
      containsAllInOrder([nama, 'Cocok!']),
    );
  });

  testWidgets('garis mengikuti jari sampai kartu pasangannya', (t) async {
    await _buka(t);
    final dari = t.getRect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)),
    );
    final pasangan = _cariKartu(
      t,
      CocokkanSisi.kanan,
      _label(t, CocokkanSisi.kiri, 0),
    );
    final ke = t.getRect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, pasangan)),
    );
    final g = await t.startGesture(dari.center);
    await g.moveTo(Offset.lerp(dari.center, ke.center, 0.5)!);
    await t.pump();
    expect(find.byKey(CocokkanScreen.garisJariKey), findsOneWidget);
    await g.moveTo(ke.center);
    await g.up();
    await t.pump();
    expect(find.byKey(CocokkanScreen.garisKey(0)), findsOneWidget);
  });

  testWidgets('lepas di luar kartu tidak mencocokkan', (t) async {
    await _buka(t);
    final dari = t.getRect(
      find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)),
    );
    final g = await t.startGesture(dari.center);
    await g.moveTo(dari.center + const Offset(-150, 0));
    await g.up();
    await t.pump();
    expect(find.byKey(CocokkanScreen.garisKey(0)), findsNothing);
  });

  testWidgets('pasangan salah memanggil narasi coba lagi', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    final salah =
        _label(t, CocokkanSisi.kanan, 0) == _label(t, CocokkanSisi.kiri, 0)
        ? 1
        : 0;
    await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 0)));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, salah)));
    await t.pump();
    expect(env.tts.spoken.last.$1, 'Ups, coba lagi ya!');
    expect(find.text('Pilih satu gambar!'), findsOneWidget);
  });

  testWidgets('semua pasang membuka Hebat dan memberi tiga bintang', (t) async {
    await _buka(t);
    await _selesaikan(t, 3);
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
    expect(_progress(t).stickers, hasLength(1));
  });

  testWidgets('ketukan kedua pada pasangan terakhir tidak menambah hadiah', (
    t,
  ) async {
    await _buka(t);
    await _selesaikan(t, 2);
    final nama = _label(t, CocokkanSisi.kiri, 2);
    final kanan = _cariKartu(t, CocokkanSisi.kanan, nama);
    await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kiri, 2)));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, kanan)));
    await t.pump(const Duration(milliseconds: 450));
    await t.tap(find.byKey(CocokkanScreen.kartuKey(CocokkanSisi.kanan, kanan)));
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
  });

  testWidgets('Main lagi dari Hebat memberi ronde baru dan hadiah baru', (
    t,
  ) async {
    final env = TestEnv();
    await _buka(t, env: env);
    await _selesaikan(t, 3);
    await t.pump();
    // Tombol Hebat muncul setelah animasi kartu selesai.
    await t.pump(const Duration(milliseconds: 1600));
    await t.tap(find.text('Main lagi'));
    await t.pump(const Duration(milliseconds: 600));
    // Ronde baru dimulai dari callback pasca-frame; satu pump lagi untuk
    // membangun ulang kartunya.
    await t.pump();
    expect(find.text('Cocokkan!'), findsOneWidget);
    await _selesaikan(t, 3);
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 6);
  });

  testWidgets('ganti bahasa mengganti judul tema', (t) async {
    final env = TestEnv();
    await _buka(t, env: env);
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(prefsProvider.notifier)
        .setLang(AppLang.en);
    await t.pump();
    expect(find.text('Match the same fruits'), findsOneWidget);
  });
}
