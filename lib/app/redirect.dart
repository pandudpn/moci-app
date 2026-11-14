import 'routes.dart';

/// Aturan redirect murni. `null` berarti tetap di [path].
String? resolveRedirect({
  required String path,
  required bool onboarded,
  required bool limitReached,
  required bool parentUnlocked,
}) {
  if (path == Routes.splash) return null;
  if (!onboarded && path != Routes.sambutan) return Routes.sambutan;
  if (onboarded && path == Routes.sambutan) return Routes.beranda;
  if (path == Routes.orangTua && !parentUnlocked) {
    return Routes.gerbangLanjut(Routes.orangTua);
  }
  if (limitReached &&
      path != Routes.habis &&
      path != Routes.gerbang &&
      path != Routes.orangTua) {
    return Routes.habis;
  }
  if (path == Routes.habis && !limitReached) return Routes.beranda;
  return null;
}
