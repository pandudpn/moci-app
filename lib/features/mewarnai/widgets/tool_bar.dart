import 'package:flutter/widgets.dart';

import '../../../app/theme/menu_theme.dart';
import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/content/coloring.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/moci_illustration.dart';
import '../../../widgets/pressable.dart';
import '../mewarnai_model.dart';
import 'alat_icon.dart';
import 'crayon_button.dart';

/// Panel alat 248 × 648: 4 alat, 3 ukuran kuas, lalu 16 krayon atau 8 stiker.
class MewarnaiToolBar extends StatelessWidget {
  const MewarnaiToolBar({
    super.key,
    required this.alat,
    required this.ukuran,
    required this.warna,
    required this.krayon,
    required this.cap,
    required this.idCap,
    required this.onAlat,
    required this.onUkuran,
    required this.onWarna,
    required this.onCap,
  });

  final AlatMewarnai alat;
  final UkuranKuas ukuran;
  final String warna;
  final List<Krayon> krayon;
  final List<Cap> cap;
  final String idCap;
  final ValueChanged<AlatMewarnai> onAlat;
  final ValueChanged<UkuranKuas> onUkuran;
  final ValueChanged<String> onWarna;
  final ValueChanged<String> onCap;

  static ValueKey<AlatMewarnai> toolKey(AlatMewarnai alat) => ValueKey(alat);

  static ValueKey<UkuranKuas> sizeKey(UkuranKuas ukuran) => ValueKey(ukuran);

  static ValueKey<String> crayonKey(String hex) => ValueKey(hex);

  static ValueKey<String> capKey(String id) => ValueKey(id);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tanpaUkuran = alat == AlatMewarnai.isi || alat == AlatMewarnai.cap;
    return SizedBox(
      width: 248,
      height: 648,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: MenuTheme.mewarnai.shadow,
              offset: const Offset(0, 10),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Semantics(
                label: l10n.mewarnaiTools,
                container: true,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _alat(context, AlatMewarnai.kuas),
                        const SizedBox(width: 10),
                        _alat(context, AlatMewarnai.isi),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _alat(context, AlatMewarnai.hapus),
                        const SizedBox(width: 10),
                        _alat(context, AlatMewarnai.cap),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: l10n.mewarnaiBrushSize,
                container: true,
                child: Opacity(
                  opacity: tanpaUkuran ? 0.4 : 1,
                  child: Row(
                    children: [
                      for (final (i, u) in UkuranKuas.values.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _ukuranTombol(
                            context,
                            u,
                            [10.0, 18.0, 28.0][i],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Semantics(
                  label: alat == AlatMewarnai.cap
                      ? l10n.mewarnaiCaps
                      : l10n.mewarnaiCrayons,
                  container: true,
                  child: alat == AlatMewarnai.cap
                      ? _kisiCap(context)
                      : _kisiKrayon(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _alat(BuildContext context, AlatMewarnai a) {
    final l10n = context.l10n;
    final aktif = alat == a;
    final nama = switch (a) {
      AlatMewarnai.kuas => l10n.mewarnaiToolBrush,
      AlatMewarnai.isi => l10n.mewarnaiToolFill,
      AlatMewarnai.hapus => l10n.mewarnaiToolErase,
      AlatMewarnai.cap => l10n.mewarnaiToolCap,
    };
    return Expanded(
      child: MociPressable(
        key: toolKey(a),
        onTap: () => onAlat(a),
        color: aktif ? const Color(0xFFFFD43B) : const Color(0xFFFFF8E1),
        shadowColor: aktif ? const Color(0xFFE0A100) : const Color(0xFFF2E2B0),
        borderRadius: BorderRadius.circular(20),
        depth: 5,
        clickSound: false,
        semanticLabel: nama,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlatIcon(
                a,
                size: alat == AlatMewarnai.cap ? 26 : 28,
                warna: a == AlatMewarnai.hapus
                    ? MociColors.white
                    : warnaDariHex(warna),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  nama,
                  style: MociText.label.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ukuranTombol(BuildContext context, UkuranKuas u, double titik) {
    final nama = switch (u) {
      UkuranKuas.kecil => context.l10n.mewarnaiBrushSmall,
      UkuranKuas.sedang => context.l10n.mewarnaiBrushMedium,
      UkuranKuas.besar => context.l10n.mewarnaiBrushBig,
    };
    final aktif = ukuran == u;
    final tanpaUkuran = alat == AlatMewarnai.isi || alat == AlatMewarnai.cap;
    return MociPressable(
      key: sizeKey(u),
      onTap: tanpaUkuran ? null : () => onUkuran(u),
      color: aktif ? const Color(0xFFFFF1D6) : MociColors.white,
      shadowColor: aktif ? const Color(0xFFF2D27A) : const Color(0xFFEFE7D2),
      borderRadius: BorderRadius.circular(16),
      depth: 4,
      clickSound: false,
      semanticLabel: nama,
      child: SizedBox(
        height: 48,
        child: Center(
          child: Container(
            width: titik,
            height: titik,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: alat == AlatMewarnai.hapus
                  ? MociColors.white
                  : warnaDariHex(warna),
              border: Border.all(color: MociColors.ink, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kisiKrayon(BuildContext context) => GridView.builder(
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 6,
      mainAxisSpacing: 8,
      mainAxisExtent: 96,
    ),
    itemCount: krayon.length,
    itemBuilder: (context, i) {
      final k = krayon[i];
      return CrayonButton(
        key: crayonKey(k.hex),
        hex: k.hex,
        nama: k.nama.id,
        selected: k.hex == warna,
        onTap: () => onWarna(k.hex),
      );
    },
  );

  Widget _kisiCap(BuildContext context) => GridView.builder(
    padding: EdgeInsets.zero,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 8,
      mainAxisExtent: 94,
    ),
    itemCount: cap.length,
    itemBuilder: (context, i) {
      final item = cap[i];
      final aktif = item.id == idCap;
      return MociPressable(
        key: capKey(item.id),
        onTap: () => onCap(item.id),
        color: aktif ? const Color(0xFFFFF1D6) : const Color(0xFFFFF8E1),
        shadowColor: aktif ? const Color(0xFFF2D27A) : const Color(0xFFF2E2B0),
        borderRadius: BorderRadius.circular(22),
        depth: 5,
        clickSound: false,
        semanticLabel: item.nama.id,
        child: SizedBox(
          height: 94,
          child: Center(child: MociIllustration(item.id, size: 70)),
        ),
      );
    },
  );
}
