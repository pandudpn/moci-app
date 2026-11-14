import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/mewarnai/svg_path.dart';

void main() {
  test('perintah M L H V ditutup Z', () {
    final p = svgPath('M0 0L40 0H80V40Z');
    expect(p.getBounds(), const Rect.fromLTRB(0, 0, 80, 40));
    expect(p.contains(const Offset(40, 20)), isTrue);
  });

  test('banyak pasangan setelah M menjadi garis', () {
    final p = svgPath('M0 0 40,0 40 40');
    expect(p.getBounds(), const Rect.fromLTRB(0, 0, 40, 40));
    expect(p.contains(const Offset(35, 20)), isTrue);
    expect(p.contains(const Offset(10, 30)), isFalse);
  });

  test('kurva C dan Q dihaluskan', () {
    expect(
      svgPath('M0 0C0 60 100 60 100 0').getBounds().height,
      closeTo(45, 2),
    );
    expect(svgPath('M0 0Q50 100 100 0').getBounds().height, closeTo(50, 2));
  });

  test('busur A membentuk lingkaran penuh', () {
    final p = svgPath('M34 80A46 46 0 1 0 126 80A46 46 0 1 0 34 80Z');
    expect(p.getBounds().width, closeTo(92, 1));
    expect(p.getBounds().height, closeTo(92, 1));
    expect(p.contains(const Offset(80, 80)), isTrue);
    expect(p.contains(const Offset(20, 80)), isFalse);
  });

  test('perintah tak dikenal ditolak', () {
    expect(() => svgPath('M0 0S10 10 20 0'), throwsFormatException);
  });
}
