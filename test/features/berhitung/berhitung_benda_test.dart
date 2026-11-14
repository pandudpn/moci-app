import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/features/berhitung/berhitung_benda.dart';

void main() {
  test('jamak EN mengikuti prototipe', () {
    expect(bendaJamak('apel', AppLang.id), 'apel');
    expect(bendaJamak('Apple', AppLang.en), 'apples');
    expect(bendaJamak('Fish', AppLang.en), 'fish');
    expect(bendaJamak('Strawberry', AppLang.en), 'strawberries');
    expect(bendaJamak('Butterfly', AppLang.en), 'butterflies');
    expect(bendaJamak('Cupcake', AppLang.en), 'cupcakes');
  });

  test('kisi hitung untuk 1, 10, 20, dan 50', () {
    expect(hitungGrid(1), (columns: 1, size: 130.0, gap: 22.0));
    expect(hitungGrid(10), (columns: 5, size: 96.0, gap: 22.0));
    expect(hitungGrid(20), (columns: 10, size: 54.0, gap: 10.0));
    expect(hitungGrid(50), (columns: 10, size: 46.0, gap: 10.0));
  });
}
