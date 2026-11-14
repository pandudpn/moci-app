import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/speech/mic_level_meter.dart';

void main() {
  test('suara cukup setelah enam sampel berurutan di atas ambang', () {
    expect(suaraCukup([0, 0.2, 0.2, 0.2, 0.2, 0.2]), isFalse);
    expect(suaraCukup([0, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]), isTrue);
  });

  test('sampel terpisah tidak dihitung', () {
    expect(
      suaraCukup([0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3, 0.01, 0.3]),
      isFalse,
    );
  });

  test('ambang 0,12', () {
    expect(suaraCukup(List.filled(6, 0.11)), isFalse);
    expect(suaraCukup(List.filled(6, 0.12)), isTrue);
  });

  test('noop selalu tidak tersedia', () async {
    const meter = NoopMicLevelMeter();
    expect(await meter.available, isFalse);
    expect(await meter.listen(batas: const Duration(seconds: 1)), isFalse);
  });
}
