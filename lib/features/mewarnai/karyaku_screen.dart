import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/coloring.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import 'mewarnai_model.dart';
import 'mewarnai_providers.dart';
import 'widgets/karya_card.dart';
import 'widgets/karya_detail_dialog.dart';

const _petunjuk = Color(0xFF8A6A1F);

/// Karyaku: kisi 12 karya tersimpan, dengan pratinjau dan hapus dua langkah.
class KaryakuScreen extends ConsumerStatefulWidget {
  const KaryakuScreen({super.key});

  static ValueKey<String> cardKey(String id) => ValueKey('karyaku-$id');

  static const emptyKey = ValueKey('karyaku-empty');

  @override
  ConsumerState<KaryakuScreen> createState() => _KaryakuScreenState();
}

class _KaryakuScreenState extends ConsumerState<KaryakuScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(karyaProvider.notifier).muat());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final karya = ref.watch(karyaProvider);
    final set = ref.watch(coloringProvider).value;
    return MociStage(
      theme: MenuTheme.karyaku,
      tablet: (context) => Stack(
        children: [
          MociTopBar(
            leading: MociBackButton(
              semanticLabel: l10n.mewarnaiBackGaleri,
              onTap: () => context.go(Routes.mewarnai),
            ),
            title: l10n.mewarnaiKaryaku,
            trailing: [
              if (karya.karya.isNotEmpty) _PilJumlah(karya.karya.length),
            ],
          ),
          if (karya.karya.isNotEmpty) ...[
            Positioned(
              left: 70,
              top: 116,
              child: Text(
                l10n.mewarnaiKaryakuHint,
                style: MociText.label.copyWith(fontSize: 19, color: _petunjuk),
              ),
            ),
            Positioned(
              left: 70,
              top: 160,
              width: 1070,
              height: 620,
              child: _kisi(karya.karya, set, lang, l10n),
            ),
          ] else if (karya.siap)
            Positioned.fill(child: _kosong(l10n)),
        ],
      ),
    );
  }

  Widget _kisi(
    List<Karya> daftar,
    ColoringSet? set,
    AppLang lang,
    AppLocalizations l10n,
  ) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: daftar.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 40,
        mainAxisSpacing: 34,
        mainAxisExtent: 290,
      ),
      itemBuilder: (context, i) {
        final karya = daftar[i];
        final page = set?.byId(karya.data.halaman);
        final nama = page?.nama.of(lang) ?? karya.data.halaman;
        return KaryaCard(
          key: KaryakuScreen.cardKey(karya.id),
          karya: karya,
          halaman: page,
          nama: nama,
          index: i,
          label: l10n.mewarnaiViewArt(nama),
          onTap: () => _buka(karya, page, nama),
        );
      },
    );
  }

  Future<void> _buka(Karya karya, ColoringPage? page, String nama) async {
    final aksi = await KaryaDetailDialog.show(
      context,
      karya: karya,
      halaman: page,
      nama: nama,
    );
    if (!mounted) return;
    switch (aksi) {
      case KaryaAksi.warnaiLagi:
        await ref.read(karyaProvider.notifier).simpanDraf(karya.data);
        if (!mounted) return;
        context.push('${Routes.mewarnai}/${karya.data.halaman}');
      case KaryaAksi.hapus:
        await ref.read(karyaProvider.notifier).hapusKarya(karya.id);
        if (!mounted) return;
        unawaited(ref.read(audioServiceProvider).playSfx(Sfx.klik));
      case KaryaAksi.tutup || null:
        return;
    }
  }

  Widget _kosong(AppLocalizations l10n) {
    return Center(
      child: Column(
        key: KaryakuScreen.emptyKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MociMascot(size: 220),
          const SizedBox(height: 18),
          Text(
            l10n.mewarnaiKaryakuEmpty,
            style: MociText.title.copyWith(fontSize: 44),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 620,
            child: Text(
              l10n.mewarnaiKaryakuEmptyHint,
              textAlign: TextAlign.center,
              style: MociText.body.copyWith(
                fontSize: 22,
                height: 1.4,
                color: const Color(0xFF6B5F99),
              ),
            ),
          ),
          const SizedBox(height: 24),
          MociButton(
            label: l10n.mewarnaiPickPage,
            kind: MociButtonKind.accent,
            height: 72,
            onTap: () => context.go(Routes.mewarnai),
          ),
        ],
      ),
    );
  }
}

/// Pil jumlah karya di kanan bilah atas.
class _PilJumlah extends StatelessWidget {
  const _PilJumlah(this.jumlah);

  final int jumlah;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      label: l10n.mewarnaiKaryaCount(jumlah),
      container: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: Color(0xFFF2D27A), offset: Offset(0, 6)),
            ],
          ),
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 22, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MociIllustration('karyaku', size: 32),
                  const SizedBox(width: 10),
                  Text(
                    l10n.mewarnaiKaryaCount(jumlah),
                    style: MociText.label.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
