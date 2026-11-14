import 'routes.dart';

/// Aturan redirect murni. `null` berarti tetap di [path].
///
/// Garis miring di ujung path dinormalkan lebih dulu, jadi `/orang-tua/`
/// mengikuti aturan yang sama dengan `/orang-tua`.
String? resolveRedirect({
  required String path,
  required bool onboarded,
  required bool limitReached,
  required bool parentUnlocked,
}) {
  final p = _rapikan(path);
  if (p == Routes.splash) return null;
  if (!onboarded && p != Routes.sambutan) return Routes.sambutan;
  if (onboarded && p == Routes.sambutan) return Routes.beranda;
  if (p == Routes.orangTua && !parentUnlocked) {
    return Routes.gerbangLanjut(Routes.orangTua);
  }
  if (limitReached &&
      p != Routes.habis &&
      p != Routes.gerbang &&
      p != Routes.orangTua) {
    return Routes.habis;
  }
  if (p == Routes.habis && !limitReached) return Routes.beranda;
  return null;
}

/// Membuang garis miring di ujung. Beranda (`/`) tetap `/`.
String _rapikan(String path) {
  var p = path;
  while (p.length > 1 && p.endsWith('/')) {
    p = p.substring(0, p.length - 1);
  }
  return p;
}
