import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/features/hadiah/hebat_screen.dart';
import 'package:moci/features/main_yuk/besar_kecil_screen.dart';
import 'package:moci/widgets/game/progress_dots.dart';

import '../../helpers/harness.dart';

/// Indeks gambar yang paling besar atau paling kecil, dibaca dari ukuran
/// widget dan kata tanya di `askKey`.
int _indeksJawaban(WidgetTester t) {
  final besar = find
      .descendant(
        of: find.byKey(BesarKecilScreen.askKey),
        matching: find.text('BESAR'),
      )
      .evaluate()
      .isNotEmpty;
  final ukuran = [
    for (
      var i = 0;
      find.byKey(BesarKecilScreen.ukuranKey(i)).evaluate().isNotEmpty;
      i++
    )
      t.getSize(find.byKey(BesarKecilScreen.ukuranKey(i))).width,
  ];
  var pilih = 0;
  for (var i = 1; i < ukuran.length; i++) {
    if (besar ? ukuran[i] > ukuran[pilih] : ukuran[i] < ukuran[pilih]) {
      pilih = i;
    }
  }
  return pilih;
}

Progress _progress(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(progressProvider);

void main() {
  testWidgets('layar besar & kecil: tiga ukuran dan pertanyaan', (t) async {
    await pumpApp(t, initialLocation: '/main/besar-kecil');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.text('Besar & Kecil'), findsOneWidget);
    expect(find.text('Mana yang paling'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(BesarKecilScreen.ukuranKey(i)), findsOneWidget);
    }
    expect(find.byType(ProgressDots), findsOneWidget);
  });

  testWidgets('pembaca memakai empat ukuran', (t) async {
    final env = TestEnv();
    env.store.setString('moci.usia', '6-7');
    await pumpApp(t, env: env, initialLocation: '/main/besar-kecil');
    await t.pump(const Duration(milliseconds: 600));
    expect(find.byKey(BesarKecilScreen.ukuranKey(3)), findsOneWidget);
  });

  testWidgets('enam jawaban benar membuka Hebat', (t) async {
    final env = TestEnv();
    await pumpApp(t, env: env, initialLocation: '/main/besar-kecil');
    await t.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 6; i++) {
      // Jam palsu tidak bergerak sendiri; posisi yang sama dipakai lagi di
      // ronde berikutnya dan tombol menolak ketukan dalam 400 ms.
      env.clock.advance(const Duration(milliseconds: 500));
      await t.tap(find.byKey(BesarKecilScreen.ukuranKey(_indeksJawaban(t))));
      await t.pump(const Duration(milliseconds: 1400));
    }
    await t.pump();
    await t.pump();
    expect(find.byType(HebatScreen), findsOneWidget);
    expect(_progress(t).stars, 3);
  });
}
