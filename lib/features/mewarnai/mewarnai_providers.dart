import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../core/content/coloring.dart';
import '../../core/content/content_repository.dart';
import '../../core/providers.dart';
import 'karya_repository.dart';
import 'mewarnai_model.dart';

/// Membaca aset tanpa cache lama.
///
/// `rootBundle` menyimpan Future hasil `loadString`, dan Future itu terikat ke
/// zona tempat ia dibuat. Tanpa `evict`, pembacaan berikutnya (tes kedua dan
/// seterusnya) menunggu Future yang zona-nya sudah mati.
Future<T> _muatAset<T>(
  String path,
  Future<T> Function(AssetBundle bundle) baca,
) {
  rootBundle.evict(path);
  return baca(rootBundle);
}

/// 14 halaman mewarnai dari bundel aset.
final coloringProvider = FutureProvider<ColoringSet>(
  (ref) =>
      _muatAset(ContentRepository.coloringPath, ContentRepository.loadColoring),
);

/// 16 krayon dari bundel aset.
final krayonProvider = FutureProvider<List<Krayon>>(
  (ref) =>
      _muatAset(ContentRepository.krayonPath, ContentRepository.loadKrayon),
);

/// 8 stiker dari bundel aset.
final capProvider = FutureProvider<List<Cap>>(
  (ref) => _muatAset(ContentRepository.capPath, ContentRepository.loadCap),
);

/// Stiker yang sudah di-decode jadi gambar siap gambar di kanvas.
final capPictureProvider = FutureProvider<Map<String, PictureInfo>>((
  ref,
) async {
  final cap = await ref.watch(capProvider.future);
  final hasil = <String, PictureInfo>{};
  for (final item in cap) {
    hasil[item.id] = await vg.loadPicture(
      AssetBytesLoader('assets/illustrations/${item.id}.svg'),
      null,
    );
  }
  return hasil;
});

/// Karya tersimpan dan draf per halaman.
final class KaryaState {
  const KaryaState({
    this.siap = false,
    this.karya = const [],
    this.draf = const {},
  });

  final bool siap;
  final List<Karya> karya;
  final Map<String, KaryaData> draf;

  KaryaData? drafUntuk(String halaman) => draf[halaman];
}

final class KaryaController extends Notifier<KaryaState> {
  KaryaRepository get _repo => KaryaRepository(ref.read(jsonStoreProvider));

  @override
  KaryaState build() => const KaryaState();

  /// Membaca semua karya dan draf sekali; panggilan berikutnya tidak membaca
  /// ulang.
  Future<void> muat() async {
    if (state.siap) return;
    final karya = await _repo.daftarKarya();
    final draf = await _repo.daftarDraf();
    state = KaryaState(siap: true, karya: karya, draf: draf);
  }

  Future<Karya> simpanKarya(KaryaData data, Uint8List png) async {
    final karya = await _repo.simpanKarya(data, png);
    state = KaryaState(
      siap: state.siap,
      karya: await _repo.daftarKarya(),
      draf: state.draf,
    );
    return karya;
  }

  Future<void> simpanDraf(KaryaData data) async {
    await _repo.simpanDraf(data);
    state = KaryaState(
      siap: state.siap,
      karya: state.karya,
      draf: {...state.draf, data.halaman: data},
    );
  }

  Future<void> hapusKarya(String id) async {
    await _repo.hapusKarya(id);
    state = KaryaState(
      siap: state.siap,
      karya: [
        for (final karya in state.karya)
          if (karya.id != id) karya,
      ],
      draf: state.draf,
    );
  }
}

final karyaProvider = NotifierProvider<KaryaController, KaryaState>(
  KaryaController.new,
);
