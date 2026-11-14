import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/layout/device_layout.dart';

void main() {
  test('jenis layout dari sisi terpendek', () {
    expect(layoutKindFor(const Size(1180, 820)), LayoutKind.tablet);
    expect(layoutKindFor(const Size(960, 600)), LayoutKind.tablet);
    expect(layoutKindFor(const Size(844, 390)), LayoutKind.phone);
    expect(layoutKindFor(const Size(915, 412)), LayoutKind.phone);
  });

  void check(
    Size screen,
    EdgeInsets safe,
    Size base,
    double scale,
    Offset origin,
  ) {
    final f = fitStage(screen: screen, safe: safe, base: base);
    expect(f.scale, closeTo(scale, 1e-3));
    expect(f.origin.dx, closeTo(origin.dx, 0.1));
    expect(f.origin.dy, closeTo(origin.dy, 0.1));
  }

  test(
    'iPad 11 inci pas',
    () => check(
      const Size(1180, 820),
      EdgeInsets.zero,
      kTabletBase,
      1.0,
      Offset.zero,
    ),
  );
  test(
    'iPad pas: inset bawah tidak mengecilkan panggung',
    () => check(
      const Size(1180, 820),
      const EdgeInsets.only(bottom: 20),
      kTabletBase,
      1.0,
      Offset.zero,
    ),
  );
  test(
    'iPad pas: bilah status atas tetap dihormati',
    () => check(
      const Size(1180, 820),
      const EdgeInsets.only(top: 24, bottom: 20),
      kTabletBase,
      796 / 820,
      const Offset(17.3, 24),
    ),
  );
  test(
    'iPad 4:3: pita atas-bawah',
    () => check(
      const Size(1024, 768),
      EdgeInsets.zero,
      kTabletBase,
      0.8678,
      const Offset(0, 28.2),
    ),
  );
  test(
    'tablet 16:10: pita kiri-kanan',
    () => check(
      const Size(1280, 800),
      EdgeInsets.zero,
      kTabletBase,
      0.9756,
      const Offset(64.4, 0),
    ),
  );
  test(
    'iPhone dengan notch kiri-kanan',
    () => check(
      const Size(844, 390),
      const EdgeInsets.symmetric(horizontal: 47),
      kPhoneBase,
      0.8886,
      const Offset(47, 21.7),
    ),
  );
}
