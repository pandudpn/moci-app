import '../../app/routes.dart';
import '../../core/progress/progress.dart';
import '../../l10n/l10n.dart';
import 'beranda_menu.dart';

typedef ContinueLabelBuilder = String Function(
  AppLocalizations l10n,
  Map<String, String> params,
);

/// Subjudul kartu Lanjutkan menurut rute. Di sini baru judul tiap menu;
/// rencana fitur menambahkan entri yang lebih spesifik, misalnya
/// "Tulis huruf {huruf}".
final Map<String, ContinueLabelBuilder> continueLabels = {
  for (final m in BerandaMenu.values) m.route: (l10n, _) => m.title(l10n),
  Routes.huruf: (l10n, params) {
    final huruf = params['huruf'];
    return huruf == null || huruf.isEmpty
        ? l10n.menuHurufTitle
        : l10n.berandaContinueHuruf(huruf);
  },
  Routes.hurufTulis: (l10n, params) {
    final huruf = params['huruf'];
    return huruf == null || huruf.isEmpty
        ? l10n.menuHurufTitle
        : l10n.berandaContinueTulisHuruf(huruf);
  },
  Routes.angkaTulis: (l10n, params) {
    final angka = params['angka'];
    return angka == null || angka.isEmpty
        ? l10n.menuAngkaTitle
        : l10n.berandaContinueTulisAngka(angka);
  },
};

/// Subjudul untuk [activity], atau `null` bila rutenya bukan bagian menu mana
/// pun (kartu Lanjutkan lalu disembunyikan).
String? continueLabel(AppLocalizations l10n, LastActivity activity) {
  final builder = continueLabels[activity.route];
  if (builder != null) return builder(l10n, activity.params);
  return BerandaMenu.parentOf(activity.route)?.title(l10n);
}
