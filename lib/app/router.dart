import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/prefs/prefs_controller.dart';
import '../features/beranda/beranda_screen.dart';
import '../features/berhitung/berhitung_screen.dart';
import '../features/hadiah/hadiah_controller.dart';
import '../features/hadiah/hebat_screen.dart';
import '../features/huruf/huruf_screen.dart';
import '../features/main_yuk/balon_screen.dart';
import '../features/main_yuk/bayangan_screen.dart';
import '../features/main_yuk/besar_kecil_screen.dart';
import '../features/main_yuk/cocokkan_screen.dart';
import '../features/main_yuk/hub_screen.dart';
import '../features/main_yuk/memori_screen.dart';
import '../features/main_yuk/puzzle_screen.dart';
import '../features/orang_tua/gerbang_screen.dart';
import '../features/orang_tua/orang_tua_screen.dart';
import '../features/sambutan/sambutan_screen.dart';
import '../features/istirahat/habis_screen.dart';
import '../features/istirahat/istirahat_screen.dart';
import '../features/mewarnai/galeri_screen.dart';
import '../features/mewarnai/kanvas_screen.dart';
import '../features/mewarnai/karyaku_screen.dart';
import '../features/segera/coming_soon_screen.dart';
import '../features/tulis/tulis_screen.dart';
import '../features/ucapkan/ucapkan_screen.dart';
import '../features/membaca/suku_kata/suku_kata_screen.dart';
import '../features/membaca/susun_kata/susun_kata_screen.dart';
import '../features/membaca/kalimat/kalimat_screen.dart';
import 'play_timer/play_timer_controller.dart';
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

/// Batas harian sudah tercapai (dari pengatur waktu).
final limitReachedProvider = Provider<bool>(
  (ref) => ref.watch(playTimerProvider.select((s) => s.limitReached)),
);

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

GoRoute _soon(String path, MenuTheme theme, {String? title}) => GoRoute(
  path: path,
  builder: (context, state) {
    final route = state.uri.path;
    return ComingSoonScreen(
      key: ValueKey(route),
      title: title ?? route,
      theme: theme,
      route: path == Routes.mewarnaiHalaman ? route : path,
    );
  },
);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RefreshNotifier();
  ref.listen(
    prefsProvider.select((p) => p.onboarded),
    (_, _) => refresh.bump(),
  );
  // Refresh memproses ulang lokasi dasar dan menjatuhkan push imperatif. Saat
  // Area Orang Tua terbuka (akses diberikan), mengubah batas harian di sana
  // tidak boleh mengusir orang tua; keluarnya lewat `go`, yang menjalankan
  // redirect dengan batas terbaru (ke Waktu Habis atau Beranda).
  ref.listen(limitReachedProvider, (_, _) {
    if (!ref.read(parentAccessProvider)) refresh.bump();
  });
  // Akses orang tua sengaja tidak me-refresh router: refresh menjatuhkan push imperatif.

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => resolveRedirect(
      path: state.uri.path,
      onboarded: ref.read(prefsProvider).onboarded,
      limitReached: ref.read(limitReachedProvider),
      parentUnlocked: ref.read(parentAccessProvider),
    ),
    // Path tak dikenal (tautan lama, salah ketik) tidak memakai halaman galat
    // bawaan yang berbahasa Inggris: kembali ke Beranda.
    onException: (context, state, router) => router.go(Routes.beranda),
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
      GoRoute(
        path: Routes.huruf,
        builder: (context, state) =>
            HurufScreen(awal: state.uri.queryParameters['huruf']),
      ),
      GoRoute(
        path: Routes.hurufTulis,
        builder: (context, state) =>
            TulisScreen(awal: state.uri.queryParameters['huruf']),
      ),
      GoRoute(
        path: Routes.hurufUcapkan,
        builder: (context, state) =>
            UcapkanScreen(awal: state.uri.queryParameters['kata']),
      ),
      GoRoute(
        path: Routes.angka,
        builder: (context, state) =>
            BerhitungScreen(awal: state.uri.queryParameters['angka']),
      ),
      GoRoute(
        path: Routes.angkaTulis,
        builder: (context, state) => TulisScreen(
          mode: TulisMode.angka,
          awal: state.uri.queryParameters['angka'],
        ),
      ),
      _soon(Routes.hewan, MenuTheme.hewan),
      _soon(Routes.buahSayur, MenuTheme.buahSayur),
      _soon(Routes.warna, MenuTheme.warna),
      _soon(Routes.bentuk, MenuTheme.bentuk),
      _soon(Routes.musik, MenuTheme.musik),
      GoRoute(
        path: Routes.sukuKata,
        builder: (context, state) =>
            SukuKataScreen(awal: state.uri.queryParameters['huruf']),
      ),
      GoRoute(
        path: Routes.susunKata,
        builder: (context, state) =>
            SusunKataScreen(awal: state.uri.queryParameters['level']),
      ),
      GoRoute(
        path: Routes.kalimat,
        builder: (context, state) =>
            KalimatScreen(awal: state.uri.queryParameters['kalimat']),
      ),
      GoRoute(
        path: Routes.mainYuk,
        builder: (context, state) => const HubScreen(),
      ),
      GoRoute(
        path: Routes.cocokkan,
        builder: (context, state) => const CocokkanScreen(),
      ),
      GoRoute(
        path: Routes.memori,
        builder: (context, state) => const MemoriScreen(),
      ),
      GoRoute(
        path: Routes.bayangan,
        builder: (context, state) => const BayanganScreen(),
      ),
      GoRoute(
        path: Routes.puzzle,
        builder: (context, state) => const PuzzleScreen(),
      ),
      GoRoute(
        path: Routes.balon,
        builder: (context, state) => const BalonScreen(),
      ),
      GoRoute(
        path: Routes.besarKecil,
        builder: (context, state) => const BesarKecilScreen(),
      ),
      GoRoute(
        path: Routes.mewarnai,
        builder: (context, state) => const GaleriScreen(),
      ),
      GoRoute(
        path: Routes.mewarnaiHalaman,
        builder: (context, state) => KanvasScreen(
          key: ValueKey(state.pathParameters['halaman']),
          halaman: state.pathParameters['halaman']!,
        ),
      ),
      GoRoute(
        path: Routes.karyaku,
        builder: (context, state) => const KaryakuScreen(),
      ),
      GoRoute(
        path: Routes.hebat,
        // Tanpa HebatArgs (pemulihan dingin, tautan salah): kembali ke Beranda.
        redirect: (context, state) =>
            state.extra is HebatArgs ? null : Routes.beranda,
        builder: (context, state) =>
            HebatScreen(args: state.extra! as HebatArgs),
      ),
      GoRoute(
        path: Routes.istirahat,
        builder: (context, state) =>
            const PopScope(canPop: false, child: IstirahatScreen()),
      ),
      GoRoute(
        path: Routes.habis,
        builder: (context, state) =>
            const PopScope(canPop: false, child: HabisScreen()),
      ),
      GoRoute(
        path: Routes.gerbang,
        builder: (context, state) =>
            GerbangScreen(lanjut: state.uri.queryParameters['lanjut']),
      ),
      GoRoute(
        path: Routes.orangTua,
        builder: (context, state) => const OrangTuaScreen(),
      ),
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
