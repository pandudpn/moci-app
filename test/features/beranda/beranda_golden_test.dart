@Tags(['golden'])
library;

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:moci/app/moci_app.dart';
import 'package:moci/core/lang.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../helpers/harness.dart';

/// Semua ilustrasi yang tampil di Beranda, dimuat sebelum diambil gambarnya.
const _illustrations = [
  'sapi',
  'kucing',
  'wortel',
  'apel',
  'buku',
  'nanas',
  'karyaku',
  'xilofon',
  'balon',
  'bola',
];

Future<void> _golden(
  WidgetTester t,
  String file, {
  required TestEnv env,
  required Size size,
}) async {
  // Gerak dimatikan: Moci dan kartu diam, gambar stabil.
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
  await pumpApp(t, env: env, size: size, initialLocation: '/');
  await t.pump(const Duration(milliseconds: 500));
  await expectLater(find.byType(MociApp), matchesGoldenFile('goldens/$file'));
}

void main() {
  final progress = const Progress(
    stars: 24,
    lastActivity: LastActivity('/hewan'),
  );

  testWidgets('Beranda tablet ID', (t) async {
    await _golden(
      t,
      'beranda_tablet_id.png',
      size: tabletSize,
      env: TestEnv(childName: 'Raka', progress: progress),
    );
  });

  testWidgets('Beranda tablet EN', (t) async {
    await _golden(
      t,
      'beranda_tablet_en.png',
      size: tabletSize,
      env: TestEnv(lang: AppLang.en, childName: 'Raka', progress: progress),
    );
  });

  testWidgets('Beranda HP ID', (t) async {
    await _golden(
      t,
      'beranda_hp_id.png',
      size: phoneSize,
      env: TestEnv(childName: 'Raka', progress: progress),
    );
  });
}
