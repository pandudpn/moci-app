import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/widgets/moci_mascot.dart';

Widget _host(Widget child, {bool disableAnimations = false}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Center(child: child),
    ),
  );
}

void main() {
  testWidgets('pose biasa tampil di ukuran 64 dan 184 tanpa exception', (
    tester,
  ) async {
    for (final size in [64.0, 184.0]) {
      await tester.pumpWidget(_host(MociMascot(size: size)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(MociMascot)), Size(size, size));
    }
  });

  testWidgets('mengetuk memanggil onTap sekali', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(MociMascot(onTap: () => taps++)));
    await tester.tap(find.byType(MociMascot));
    await tester.pump(const Duration(milliseconds: 100));
    expect(taps, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('animasi berjalan bila diizinkan', (tester) async {
    await tester.pumpWidget(_host(const MociMascot()));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('gerak dikurangi: tanpa animasi, onTap tetap terpanggil', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(MociMascot(onTap: () => taps++), disableAnimations: true),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    await tester.tap(find.byType(MociMascot));
    await tester.pump();
    expect(taps, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('idle false tidak menjalankan animasi berulang', (tester) async {
    await tester.pumpWidget(_host(const MociMascot(idle: false)));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('gambar maskot punya lapisan repaint sendiri', (tester) async {
    await tester.pumpWidget(_host(const MociMascot()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(
        of: find.byType(MociMascot),
        matching: find.byType(RepaintBoundary),
      ),
      findsWidgets,
    );
  });
}
