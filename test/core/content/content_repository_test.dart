import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moci/core/content/content_repository.dart';

void main() {
  test('memuat katalog asli dari bundel', () async {
    final katalog = await ContentRepository.loadKatalog(rootBundle);
    expect(katalog.item.length, 107);
    expect(katalog.byId('kucing')!.nama.en, 'Cat');
    expect(katalog.huruf.length, 26);
  });

  test('memuat panduan tulis huruf dan angka', () async {
    final huruf = await ContentRepository.loadTracing(rootBundle, angka: false);
    expect(huruf.glyph.length, 26);
    expect(huruf.kotak, 520);
    final angka = await ContentRepository.loadTracing(rootBundle, angka: true);
    expect(angka.glyph.length, 10);
  });

  test('memuat mewarnai, cap, dan krayon', () async {
    final mewarnai = await ContentRepository.loadColoring(rootBundle);
    expect(mewarnai.halaman.length, 44);
    expect(mewarnai.halaman.where((p) => p.kategori == 'kota').length, 6);
    expect(mewarnai.byId('laut-kepiting')!.nama.en, 'Crab');
    expect(mewarnai.byId('kupu')!.nama.en, 'Butterfly');
    expect((await ContentRepository.loadCap(rootBundle)).length, 8);
    expect((await ContentRepository.loadKrayon(rootBundle)).length, 16);
  });

  test('katalogProvider menolak dibaca sebelum dioverride', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      () => container.read(katalogProvider),
      throwsA(
        predicate<Object>(
          (e) => '$e'.contains('katalogProvider dioverride di runMoci'),
        ),
      ),
    );
  });
}
