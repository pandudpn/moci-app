import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/content/coloring.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'mewarnai_model.dart';
import 'mewarnai_providers.dart';
import 'widgets/page_thumbnail.dart';

/// Warna pita kartu, bergiliran menurut urutan halaman.
const _pita = [
  Color(0xFFFF8FB1),
  Color(0xFF74C0FC),
  Color(0xFF8CE99A),
  Color(0xFFFFD43B),
  Color(0xFFB197FC),
];

/// Putaran pita, juga bergiliran.
const _putaran = [-4.0, 3.0, -2.0, 5.0, -5.0];

const _pilAktif = Color(0xFFFFC233);
const _hijau = Color(0xFF26A03B);
const _ungu = Color(0xFF7048E8);
const _petunjuk = Color(0xFF6B5F99);
const _bayanganKaryaku = Color(0xFFE0A100);

/// Galeri 14 halaman mewarnai dan kartu Karyaku.
class GaleriScreen extends ConsumerStatefulWidget {
  const GaleriScreen({super.key});

  static ValueKey<String> kartuKey(String id) => ValueKey('galeri-kartu-$id');

  static ValueKey<String> tabKey(String kategori) =>
      ValueKey('galeri-tab-$kategori');

  static const karyakuKey = ValueKey('galeri-karyaku');

  @override
  ConsumerState<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends ConsumerState<GaleriScreen> {
  String _saring = 'semua';

  @override
  void initState() {
    super.initState();
    ref.read(karyaProvider.notifier).muat();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final karya = ref.watch(karyaProvider);
    final set = ref.watch(coloringProvider).value;
    return MociStage(
      theme: MenuTheme.mewarnai,
      tablet: (context) => Stack(
        children: [
          MociTopBar(
            leading: MociBackButton(onTap: () => context.go(Routes.beranda)),
            title: l10n.menuWarnaiTitle,
            trailing: [
              Semantics(
                label: l10n.mewarnaiFilter,
                container: true,
                child: Row(
                  children: [
                    _pil('semua', l10n.mewarnaiTabSemua),
                    const SizedBox(width: 10),
                    _pil('hewan', l10n.mewarnaiTabHewan),
                    const SizedBox(width: 10),
                    _pil('benda', l10n.mewarnaiTabBenda),
                  ],
                ),
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
          if (set != null)
            Positioned(
              left: 36,
              top: 132,
              width: 1108,
              height: 600,
              child: _kisi(set, karya, lang, l10n),
            ),
          Positioned(
            left: 36,
            bottom: 26,
            child: Row(
              children: [
                const MociMascot(size: 52),
                const SizedBox(width: 12),
                Text(
                  l10n.mewarnaiHintPick,
                  style: MociText.label.copyWith(
                    fontSize: 18,
                    color: _petunjuk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pil(String kategori, String label) {
    final aktif = _saring == kategori;
    return MociPressable(
      key: GaleriScreen.tabKey(kategori),
      onTap: () => setState(() => _saring = kategori),
      color: aktif ? _pilAktif : MociColors.white,
      shadowColor: MenuTheme.mewarnai.shadow,
      borderRadius: BorderRadius.circular(28),
      depth: 5,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              label,
              style: MociText.button.copyWith(fontSize: 20),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _kisi(
    ColoringSet set,
    KaryaState karya,
    AppLang lang,
    AppLocalizations l10n,
  ) {
    final halaman = [
      for (final page in set.halaman)
        if (_saring == 'semua' || page.kategori == _saring) page,
    ];
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 26,
        mainAxisSpacing: 22,
        mainAxisExtent: 185,
      ),
      itemCount: halaman.length + 1,
      itemBuilder: (context, i) {
        if (i == halaman.length) return _kartuKaryaku(karya, l10n);
        return _kartuHalaman(halaman[i], karya, lang, l10n, i);
      },
    );
  }

  Widget _kartuHalaman(
    ColoringPage page,
    KaryaState karya,
    AppLang lang,
    AppLocalizations l10n,
    int index,
  ) {
    final nama = page.nama.of(lang);
    final lanjut = karya.drafUntuk(page.id)?.adaIsi ?? false;
    return MociPressable(
      key: GaleriScreen.kartuKey(page.id),
      onTap: () => context.push('${Routes.mewarnai}/${page.id}'),
      shadowColor: MenuTheme.mewarnai.shadow,
      borderRadius: BorderRadius.circular(24),
      semanticLabel: l10n.mewarnaiOpenPage(nama),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                PageThumbnail(
                  halaman: page,
                  data: KaryaData.kosong(page.id).copyWith(isian: page.contoh),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 22,
                  child: Center(
                    child: Text(
                      nama,
                      style: MociText.title.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(left: -6, top: -10, child: _pitaKartu(index)),
            if (lanjut)
              Positioned(
                right: 2,
                top: 2,
                child: _lencana(l10n.mewarnaiContinue, _hijau),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kartuKaryaku(KaryaState karya, AppLocalizations l10n) {
    return MociPressable(
      key: GaleriScreen.karyakuKey,
      onTap: () => context.push(Routes.karyaku),
      shadowColor: _bayanganKaryaku,
      borderRadius: BorderRadius.circular(24),
      semanticLabel: l10n.mewarnaiOpenKaryaku(karya.karya.length),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 184,
                  height: 138,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: MociColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFF1EAD8),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: MociIllustration('karyaku', size: 120),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 22,
                  child: Center(
                    child: Text(
                      l10n.mewarnaiKaryaku,
                      style: MociText.title.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              left: -6,
              top: -10,
              child: _Pita(color: _pitaWarna),
            ),
            if (karya.karya.isNotEmpty)
              Positioned(
                right: 2,
                top: 2,
                child: _lencana(
                  l10n.mewarnaiKaryaCount(karya.karya.length),
                  _ungu,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _pitaWarna = Color(0xFFFFD43B);

Widget _pitaKartu(int index) => _Pita(
  color: _pita[index % _pita.length],
  putaran: _putaran[index % _putaran.length],
);

Widget _lencana(String teks, Color warna) => DecoratedBox(
  decoration: BoxDecoration(
    color: warna,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    child: Text(
      teks,
      style: MociText.label.copyWith(fontSize: 13, color: MociColors.white),
      maxLines: 1,
    ),
  ),
);

/// Pita kecil di sudut kartu, seperti selotip.
class _Pita extends StatelessWidget {
  const _Pita({required this.color, this.putaran = -4});

  final Color color;
  final double putaran;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: putaran * 0.017453292519943295,
      child: Container(
        width: 74,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
