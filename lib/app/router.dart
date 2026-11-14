import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/prefs/prefs_controller.dart';
import '../features/beranda/beranda_screen.dart';
import '../features/orang_tua/gerbang_screen.dart';
import '../features/sambutan/sambutan_screen.dart';
import '../features/segera/coming_soon_screen.dart';
import 'redirect.dart';
import 'splash/splash_screen.dart';
import 'routes.dart';
import 'theme/menu_theme.dart';

export 'redirect.dart';
export 'routes.dart';

/// Gerbang Orang Tua terbuka (sementara, di memori) sampai Area Orang Tua ditutup.
class ParentAccess extends Notifier<bool> {
  @override
  bool build() => false;

  void grant() => state = true;
  void revoke() => state = false;
}

final parentAccessProvider = NotifierProvider<ParentAccess, bool>(
  ParentAccess.new,
);

/// Task 16 menggantinya dengan pembacaan pengatur waktu.
final limitReachedProvider = Provider<bool>((_) => false);

class CurrentPath extends Notifier<String> {
  @override
  String build() => Routes.splash;

  void set(String path) => state = path;
}

final currentPathProvider = NotifierProvider<CurrentPath, String>(
  CurrentPath.new,
);

class _RefreshNotifier extends ChangeNotifier {
  void bump() => notifyListeners();
}

GoRoute _soon(
  String path,
  MenuTheme theme, {
  bool lockBack = false,
  String? title,
}) => GoRoute(
  path: path,
  builder: (context, state) {
    final route = state.uri.path;
    final screen = ComingSoonScreen(
      key: ValueKey(route),
      title: title ?? route,
      theme: theme,
      route: path == Routes.mewarnaiHalaman ? route : path,
    );
    return lockBack ? PopScope(canPop: false, child: screen) : screen;
  },
);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RefreshNotifier();
  ref.listen(
    prefsProvider.select((p) => p.onboarded),
    (_, _) => refresh.bump(),
  );
  ref.listen(limitReachedProvider, (_, _) => refresh.bump());
  ref.listen(parentAccessProvider, (_, _) => refresh.bump());

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      path: state.uri.path,
      onboarded: ref.read(prefsProvider).onboarded,
      limitReached: ref.read(limitReachedProvider),
      parentUnlocked: ref.read(parentAccessProvider),
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) =>
            const PopScope(canPop: false, child: SplashScreen()),
      ),
      GoRoute(
        path: Routes.sambutan,
        builder: (context, state) =>
            const PopScope(canPop: false, child: SambutanScreen()),
      ),
      GoRoute(
        path: Routes.beranda,
        builder: (context, state) =>
            const PopScope(canPop: false, child: BerandaScreen()),
      ),
      _soon(Routes.huruf, MenuTheme.huruf),
      _soon(Routes.hurufTulis, MenuTheme.huruf),
      _soon(Routes.hurufUcapkan, MenuTheme.ucapkan),
      _soon(Routes.angka, MenuTheme.berhitung),
      _soon(Routes.angkaTulis, MenuTheme.berhitung),
      _soon(Routes.hewan, MenuTheme.hewan),
      _soon(Routes.buahSayur, MenuTheme.buahSayur),
      _soon(Routes.warna, MenuTheme.warna),
      _soon(Routes.bentuk, MenuTheme.bentuk),
      _soon(Routes.musik, MenuTheme.musik),
      _soon(Routes.sukuKata, MenuTheme.membaca),
      _soon(Routes.susunKata, MenuTheme.membaca),
      _soon(Routes.kalimat, MenuTheme.membaca),
      _soon(Routes.mainYuk, MenuTheme.mainYuk),
      _soon(Routes.cocokkan, MenuTheme.cocokkan),
      _soon(Routes.memori, MenuTheme.memori),
      _soon(Routes.bayangan, MenuTheme.bayangan),
      _soon(Routes.puzzle, MenuTheme.puzzle),
      _soon(Routes.balon, MenuTheme.balon),
      _soon(Routes.besarKecil, MenuTheme.besarKecil),
      _soon(Routes.mewarnai, MenuTheme.mewarnai),
      _soon(Routes.mewarnaiHalaman, MenuTheme.mewarnai),
      _soon(Routes.karyaku, MenuTheme.karyaku),
      _soon(Routes.hebat, MenuTheme.hebat),
      _soon(Routes.istirahat, MenuTheme.istirahat, lockBack: true),
      _soon(Routes.habis, MenuTheme.istirahat, lockBack: true),
      GoRoute(
        path: Routes.gerbang,
        builder: (context, state) =>
            GerbangScreen(lanjut: state.uri.queryParameters['lanjut']),
      ),
      _soon(Routes.orangTua, MenuTheme.orangTua),
    ],
  );

  void syncPath() {
    // `uri` mengabaikan rute hasil push; `last.matchedLocation` memuatnya,
    // jadi ini rute yang benar-benar tampil.
    final config = router.routerDelegate.currentConfiguration;
    final path = config.isEmpty ? Routes.splash : config.last.matchedLocation;
    if (ref.read(currentPathProvider) != path) {
      ref.read(currentPathProvider.notifier).set(path);
    }
  }

  router.routerDelegate.addListener(syncPath);
  ref.onDispose(() {
    router.routerDelegate.removeListener(syncPath);
    router.dispose();
    refresh.dispose();
  });
  return router;
});
