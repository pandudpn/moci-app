import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/device_layout.dart';
import 'package:moci/app/layout/moci_stage.dart';
import 'package:moci/app/theme/menu_theme.dart';

void setScreen(
  WidgetTester tester,
  Size size, {
  FakeViewPadding? padding,
  double textScale = 1.0,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  if (padding != null) tester.view.padding = padding;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

Widget host(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

const probe = Key('probe');

void main() {
  testWidgets('1024x768: tablet base, centered, background fills screen', (
    tester,
  ) async {
    setScreen(tester, const Size(1024, 768));
    late Size seen;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) {
            seen = MediaQuery.sizeOf(c);
            return const SizedBox.expand(key: probe);
          },
        ),
      ),
    );
    expect(seen, kTabletBase);
    final tl = tester.getTopLeft(find.byKey(probe));
    expect(tl.dx, closeTo(0, 0.5));
    expect(tl.dy, closeTo(28.2, 0.5));
    final bg = find.byKey(MociStage.backgroundKey);
    expect(tester.getSize(bg), const Size(1024, 768));
  });

  testWidgets('844x390 without phone builder falls back to tablet base', (
    tester,
  ) async {
    setScreen(tester, const Size(844, 390));
    final printed = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    addTearDown(() => debugPrint = original);
    late Size seen;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) {
            seen = MediaQuery.sizeOf(c);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(seen, kTabletBase);
    await tester.pump();
    expect(
      printed.where((m) => m.startsWith('Layout HP belum didesain')),
      hasLength(1),
    );
  });

  testWidgets('844x390 with phone builder uses phone base and kind', (
    tester,
  ) async {
    setScreen(tester, const Size(844, 390));
    late Size seen;
    late LayoutKind kind;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) => const SizedBox.expand(),
          phone: (c) {
            seen = MediaQuery.sizeOf(c);
            kind = c.layoutKind;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(seen, kPhoneBase);
    expect(kind, LayoutKind.phone);
  });

  testWidgets('left notch padding 47 keeps content at x >= 47', (tester) async {
    setScreen(
      tester,
      const Size(844, 390),
      padding: const FakeViewPadding(left: 47, right: 47),
    );
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) => const SizedBox.expand(),
          phone: (c) => const SizedBox.expand(key: probe),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(probe)).dx,
      greaterThanOrEqualTo(47 - 0.01),
    );
  });

  testWidgets('1180x820 dengan inset bawah 20 mengisi layar penuh', (
    tester,
  ) async {
    setScreen(
      tester,
      const Size(1180, 820),
      padding: const FakeViewPadding(bottom: 20),
    );
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) => const SizedBox.expand(key: probe),
        ),
      ),
    );
    expect(tester.getTopLeft(find.byKey(probe)), Offset.zero);
    expect(tester.getSize(find.byKey(probe)), kTabletBase);
  });

  testWidgets('HP: notch tetap dihormati walau ada inset bawah', (
    tester,
  ) async {
    setScreen(
      tester,
      const Size(844, 390),
      padding: const FakeViewPadding(left: 47, right: 47, bottom: 21),
    );
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) => const SizedBox.expand(),
          phone: (c) => const SizedBox.expand(key: probe),
        ),
      ),
    );
    final tl = tester.getTopLeft(find.byKey(probe));
    expect(tl.dx, closeTo(47, 0.5));
    expect(tl.dy, closeTo(21.7, 0.5));
  });

  testWidgets('system text scale 2.0 with cap 1.3 gives 13', (tester) async {
    setScreen(tester, const Size(1180, 820), textScale: 2.0);
    late TextScaler s;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          textScaleCap: 1.3,
          tablet: (c) {
            s = MediaQuery.textScalerOf(c);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(s.scale(10), closeTo(13, 1e-6));
  });

  testWidgets('system text scale 2.0 with default cap gives 10', (
    tester,
  ) async {
    setScreen(tester, const Size(1180, 820), textScale: 2.0);
    late TextScaler s;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) {
            s = MediaQuery.textScalerOf(c);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(s.scale(10), 10);
  });

  testWidgets('system text scale 0.8 with default cap gives 10', (
    tester,
  ) async {
    setScreen(tester, const Size(1180, 820), textScale: 0.8);
    late TextScaler s;
    await tester.pumpWidget(
      host(
        MociStage(
          theme: MenuTheme.beranda,
          tablet: (c) {
            s = MediaQuery.textScalerOf(c);
            return const SizedBox.expand();
          },
        ),
      ),
    );
    expect(s.scale(10), 10);
  });
}
