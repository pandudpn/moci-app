import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../core/content/coloring.dart';
import '../../../core/prefs/prefs_controller.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/pressable.dart';
import '../mewarnai_model.dart';
import '../mewarnai_providers.dart';
import 'page_thumbnail.dart';

const _aktif = Color(0xFFFFF1D6);

/// Pemilih gambar: 14 halaman dalam kisi 5 kolom, halaman aktif ditandai.
class PagePickerDialog extends ConsumerWidget {
  const PagePickerDialog({
    super.key,
    required this.halamanAktif,
    required this.onPick,
  });

  final String halamanAktif;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final set = ref.watch(coloringProvider).value;
    final karya = ref.watch(karyaProvider);
    if (set == null) return const SizedBox.shrink();
    return SizedBox(
      width: 968,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mewarnaiPickPage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MociText.title.copyWith(fontSize: 34),
                ),
              ),
              const SizedBox(width: 16),
              _TombolTutup(label: l10n.mewarnaiClose),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: set.halaman.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 167,
            ),
            itemBuilder: (context, i) {
              final page = set.halaman[i];
              return _Kartu(
                page: page,
                nama: page.nama.of(lang),
                aktif: page.id == halamanAktif,
                draf: karya.drafUntuk(page.id),
                onTap: () => onPick(page.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Kartu extends StatelessWidget {
  const _Kartu({
    required this.page,
    required this.nama,
    required this.aktif,
    required this.draf,
    required this.onTap,
  });

  final ColoringPage page;
  final String nama;
  final bool aktif;
  final KaryaData? draf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      onTap: onTap,
      color: aktif ? _aktif : MociColors.white,
      shadowColor: const Color(0xFFE0D6BC),
      borderRadius: BorderRadius.circular(20),
      semanticLabel: nama,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            PageThumbnail(
              halaman: page,
              data: draf ?? KaryaData.kosong(page.id),
              width: 172,
              height: 129,
            ),
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Text(
                nama,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: MociText.label.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolTutup extends StatelessWidget {
  const _TombolTutup({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      onTap: () => Navigator.of(context).pop(),
      shadowColor: const Color(0xFFE0D6BC),
      borderRadius: BorderRadius.circular(999),
      semanticLabel: label,
      child: const SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: CustomPaint(size: Size.square(26), painter: _IkonTutup()),
        ),
      ),
    );
  }
}

/// Silang penutup dialog pada kanvas 24 × 24.
class _IkonTutup extends CustomPainter {
  const _IkonTutup();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * k
      ..strokeCap = StrokeCap.round
      ..color = MociColors.ink;
    canvas.drawLine(Offset(6 * k, 6 * k), Offset(18 * k, 18 * k), garis);
    canvas.drawLine(Offset(18 * k, 6 * k), Offset(6 * k, 18 * k), garis);
  }

  @override
  bool shouldRepaint(_IkonTutup old) => false;
}
