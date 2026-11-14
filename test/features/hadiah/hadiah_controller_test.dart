import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/progress/progress.dart';
import 'package:moci/core/progress/progress_controller.dart';
import 'package:moci/core/progress/progress_repository.dart';
import 'package:moci/features/hadiah/hadiah_controller.dart';
import 'package:moci/features/hadiah/stiker.dart';

import '../../helpers/harness.dart';

/// Sumber acak yang selalu memilih indeks tertentu (dibatasi ke rentang).
final class _FixedRandom implements Random {
  _FixedRandom(this.index);
  final int index;

  @override
  int nextInt(int max) => index < max ? index : max - 1;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}

ProviderContainer _container({
  Progress progress = const Progress(),
  Random? random,
}) {
  final env = TestEnv(progress: progress);
  final container = ProviderContainer(
    overrides: [
      ...env.overrides,
      if (random != null) hadiahRandomProvider.overrideWithValue(random),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(env.ticks.close);
  return container;
}

/// Tema yang diharapkan per stiker, dari tabel master inventaris-konten.md.
const _temaDiharapkan = {
  'kucing': 'hewan',
  'ikan': 'hewan',
  'singa': 'hewan',
  'gajah': 'hewan',
  'panda': 'hewan',
  'pinguin': 'hewan',
  'apel': 'buah',
  'pisang': 'buah',
  'stroberi': 'buah',
  'semangka': 'buah',
  'nanas': 'buah',
  'buahnaga': 'buah',
  'wortel': 'sayur',
  'tomat': 'sayur',
  'brokoli': 'sayur',
  'jagung': 'sayur',
  'labu': 'sayur',
  'jamur': 'sayur',
  'mobil': 'kendaraan',
  'bus': 'kendaraan',
  'kereta': 'kendaraan',
  'pesawat': 'kendaraan',
  'kapal': 'kendaraan',
  'roket': 'kendaraan',
  'bola': 'benda',
  'balon': 'benda',
  'kado': 'benda',
  'eskrim': 'benda',
  'layang': 'benda',
  'payung': 'benda',
};

void main() {
  group('katalog stiker', () {
    test('30 id unik, urut per tema, 6 per tema', () {
      expect(stickerCatalog, hasLength(30));
      expect(stickerCatalog.toSet(), hasLength(30));
      expect(stickerCatalog.toSet(), _temaDiharapkan.keys.toSet());
      for (final tema in stickerThemes) {
        expect(
          stickerCatalog.where((id) => stickerThemeOf(id) == tema),
          hasLength(6),
          reason: tema,
        );
      }
      // Urut per tema: hewan, buah, sayur, kendaraan, benda.
      expect(
        [for (final id in stickerCatalog) stickerThemeOf(id)],
        [
          for (final tema in stickerThemes)
            for (var i = 0; i < 6; i++) tema,
        ],
      );
      for (final id in stickerCatalog) {
        expect(stickerThemeOf(id), _temaDiharapkan[id], reason: id);
      }
    });

    test('tiap stiker punya SVG dan nama di kedua bahasa', () {
      final id = jsonDecode(File('l10n/app_id.arb').readAsStringSync()) as Map;
      final en = jsonDecode(File('l10n/app_en.arb').readAsStringSync()) as Map;
      for (final s in stickerCatalog) {
        expect(
          File('assets/illustrations/$s.svg').existsSync(),
          isTrue,
          reason: 'SVG $s',
        );
        expect(id['stiker_$s'], isA<String>(), reason: 'stiker_$s (id)');
        expect(en['stiker_$s'], isA<String>(), reason: 'stiker_$s (en)');
      }
    });
  });

  group('finishGame', () {
    test('menambah 3 bintang dan satu stiker dari katalog', () async {
      final c = _container();
      final hasil = await c
          .read(hadiahProvider)
          .finishGame(gameId: 'balon', roundId: 'r1');
      final progress = c.read(progressProvider);
      expect(progress.stars, 3);
      expect(progress.stickers, hasLength(1));
      expect(stickerCatalog, contains(progress.stickers.single));
      expect(hasil.stars, 3);
      expect(hasil.sticker, progress.stickers.single);
    });

    test(
      'roundId yang sama tidak menambah apa pun dan hasilnya sama',
      () async {
        final c = _container();
        final ctrl = c.read(hadiahProvider);
        final a = await ctrl.finishGame(gameId: 'balon', roundId: 'r1');
        final b = await ctrl.finishGame(gameId: 'balon', roundId: 'r1');
        expect(b, same(a));
        final progress = c.read(progressProvider);
        expect(progress.stars, 3);
        expect(progress.stickers, hasLength(1));
      },
    );

    test('panggilan serentak dengan roundId sama dihitung sekali', () async {
      final c = _container();
      final ctrl = c.read(hadiahProvider);
      final results = await Future.wait([
        ctrl.finishGame(gameId: 'balon', roundId: 'r1'),
        ctrl.finishGame(gameId: 'balon', roundId: 'r1'),
      ]);
      expect(results[1], same(results[0]));
      expect(c.read(progressProvider).stars, 3);
      expect(c.read(progressProvider).stickers, hasLength(1));
    });

    test('roundId berbeda memberi hadiah lagi dengan stiker berbeda', () async {
      final c = _container();
      final ctrl = c.read(hadiahProvider);
      final a = await ctrl.finishGame(gameId: 'balon', roundId: 'r1');
      final b = await ctrl.finishGame(gameId: 'balon', roundId: 'r2');
      expect(a.sticker, isNot(b.sticker));
      expect(c.read(progressProvider).stars, 6);
      expect(c.read(progressProvider).stickers, hasLength(2));
    });
    test('roundId sama di game berbeda: dua hadiah', () async {
      final c = _container();
      final ctrl = c.read(hadiahProvider);
      final a = await ctrl.finishGame(gameId: 'hewan', roundId: '1');
      final b = await ctrl.finishGame(gameId: 'angka', roundId: '1');
      expect(a.stars, 3);
      expect(b.stars, 3);
      expect(c.read(progressProvider).stars, 6);
      expect(c.read(progressProvider).stickers, hasLength(2));
    });

    test(
      'stiker dipilih dari yang belum dimiliki lewat Random suntikan',
      () async {
        final c = _container(
          progress: Progress(stickers: [stickerCatalog[0], stickerCatalog[2]]),
          random: _FixedRandom(1),
        );
        final hasil = await c
            .read(hadiahProvider)
            .finishGame(gameId: 'balon', roundId: 'r1');
        // Belum dimiliki: indeks katalog 1, 3, 4, ... -> indeks acak 1 = katalog[3].
        expect(hasil.sticker, stickerCatalog[3]);
      },
    );

    test('29 stiker dimiliki: stiker baru adalah satu-satunya sisa', () async {
      final sisa = stickerCatalog[17];
      final c = _container(
        progress: Progress(
          stars: 10,
          stickers: [
            for (final s in stickerCatalog)
              if (s != sisa) s,
          ],
        ),
      );
      final hasil = await c
          .read(hadiahProvider)
          .finishGame(gameId: 'balon', roundId: 'r1');
      expect(hasil.sticker, sisa);
      expect(c.read(progressProvider).stickers, hasLength(30));
      expect(c.read(progressProvider).stars, 13);
    });

    test(
      '30 stiker dimiliki: tanpa stiker, bintang tetap bertambah 3',
      () async {
        final c = _container(
          progress: const Progress(stars: 4, stickers: stickerCatalog),
        );
        final hasil = await c
            .read(hadiahProvider)
            .finishGame(gameId: 'balon', roundId: 'r1');
        expect(hasil.sticker, isNull);
        expect(hasil.stars, 3);
        expect(c.read(progressProvider).stars, 7);
        expect(c.read(progressProvider).stickers, hasLength(30));
      },
    );

    test('hadiah tersimpan ke berkas progres', () async {
      final env = TestEnv();
      final c = ProviderContainer(overrides: env.overrides);
      addTearDown(c.dispose);
      addTearDown(env.ticks.close);
      await c.read(hadiahProvider).finishGame(gameId: 'balon', roundId: 'r1');
      final disk = await ProgressRepository(env.json).load();
      expect(disk.stars, 3);
      expect(disk.stickers, hasLength(1));
    });
  });
}
