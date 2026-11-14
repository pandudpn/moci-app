import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';

/// Pemicu "Main lagi" dari layar Hebat untuk layar yang memutar rondenya
/// sendiri.
///
/// `go` ke rute yang sama memakai ulang `State` yang sudah ada, jadi
/// `initState` tidak berjalan lagi dan permainan tetap di keadaan selesai.
/// Dipasang di `initState`, bukan di `build`, supaya layar baru tidak bisa
/// lupa: cukup campurkan mixin ini dan isi [ruteMainLagi] serta [mulaiUlang].
mixin MainLagi<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Rute layar ini, dibandingkan dengan `currentPathProvider`.
  String get ruteMainLagi;

  /// Dipanggil sekali saat rute kembali dari Hebat ke [ruteMainLagi].
  void mulaiUlang();

  @override
  void initState() {
    super.initState();
    ref.listenManual(currentPathProvider, (sebelum, sekarang) {
      if (sebelum != Routes.hebat || sekarang != ruteMainLagi) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) mulaiUlang();
      });
    });
  }
}
