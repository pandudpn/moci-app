@Tags(['golden'])
library;

import 'package:flutter/rendering.dart' show debugDisableShadows;
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/features/hadiah/hadiah_controller.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../helpers/harness.dart';

/// Ilustrasi yang tampil di Hebat, dimuat sebelum diambil gambarnya.
const _illustrations = ['moci-senang', 'kucing', 'bola', 'ikan', 'apel'];

void main() {
  testWidgets('Hebat tablet ID: 27 bintang, stiker baru apel', (t) async {
    // flutter_test mematikan blur bayangan; kartu Hebat punya lapisan lembut.
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    // Gerak dimatikan: keadaan akhir animasi (semua bintang tampil), gambar stabil.
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.runAsync(() async {
      for (final id in _illustrations) {
        await vg.loadPicture(
          AssetBytesLoader('assets/illustrations/$id.svg'),
          null,
        );
      }
    });
    final router = await pumpApp(
      t,
      env: TestEnv(
        progress: const Progress(
          stars: 27,
          stickers: ['kucing', 'bola', 'ikan', 'apel'],
        ),
      ),
      initialLocation: '/',
    );
    router.go(
      '/hebat',
      extra: const HebatArgs(
        award: AwardResult(stars: 3, sticker: 'apel'),
        replayRoute: '/main/balon',
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MociApp),
      matchesGoldenFile('goldens/hebat_tablet_id.png'),
    );
  });
}
