import 'package:flutter_test/flutter_test.dart';
import 'package:moci/features/bentuk/bentuk_shape.dart';

import '../../helpers/katalog.dart';

void main() {
  test('semua path katalog terbaca dan berada di kotak 200', () {
    for (final bentuk in katalogUji().bentuk) {
      final path = pathDariSvg(bentuk.path);
      final bounds = path.getBounds();
      expect(bounds.width, greaterThan(20), reason: bentuk.id);
      expect(bounds.height, greaterThan(20), reason: bentuk.id);
      expect(bounds.left, greaterThanOrEqualTo(-0.5), reason: bentuk.id);
      expect(bounds.right, lessThanOrEqualTo(200.5), reason: bentuk.id);
      expect(path.computeMetrics().isEmpty, isFalse, reason: bentuk.id);
    }
    final lingkaran = pathDariSvg(
      'M18 100A82 82 0 1 1 182 100A82 82 0 1 1 18 100Z',
    );
    expect(lingkaran.getBounds().width, closeTo(164, 1));
  });
}
