@Tags(['golden'])
library;

import 'package:flutter/rendering.dart' show debugDisableShadows;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/app/router.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../helpers/harness.dart';

/// Ilustrasi yang tampil di Area Orang Tua, dimuat sebelum diambil gambarnya.
const _illustrations = ['moci', 'kucing', 'apel', 'buku', 'karyaku'];

List<String> _ids(int n, String prefix) => [
  for (var i = 0; i < n; i++) '$prefix$i',
];

void main() {
  testWidgets('Area Orang Tua tablet ID', (t) async {
    // flutter_test mematikan blur bayangan; kartu punya lapisan lembut.
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
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
        progress: Progress(
          harian: {
            '2026-11-14': DayStats(
              stars: 9,
              stickers: 1,
              karya: 1,
              items: {
                'huruf': _ids(12, 'h'),
                'angka': _ids(7, 'a'),
                'hewan': _ids(6, 'w'),
                'buahSayur': _ids(4, 'b'),
                'membaca': _ids(2, 's'),
                'mewarnai': _ids(3, 'm'),
              },
            ),
          },
          playSeconds: const {'2026-11-14': 1080},
        ),
      ),
      initialLocation: '/',
    );
    ProviderScope.containerOf(t.element(find.byType(MociApp)))
        .read(parentAccessProvider.notifier)
        .grant();
    router.go(Routes.orangTua);
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    await expectLater(
      find.byType(MociApp),
      matchesGoldenFile('goldens/orang_tua_tablet_id.png'),
    );
  });
}
