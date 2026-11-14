import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_text.dart';
import '../../../core/content/coloring.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/moci_dialog.dart';
import '../mewarnai_model.dart';
import '../mewarnai_painter.dart';
import 'wide_dialog.dart';

/// Pilihan pengguna di dialog detail karya.
enum KaryaAksi { warnaiLagi, hapus, tutup }

/// Detail satu karya: pratinjau 720 × 540 dan panel aksi 210.
class KaryaDetailDialog extends StatefulWidget {
  const KaryaDetailDialog({
    super.key,
    required this.karya,
    required this.halaman,
    required this.nama,
  });

  final Karya karya;
  final ColoringPage? halaman;
  final String nama;

  /// Membuka dialog dan mengembalikan aksi yang dipilih.
  static Future<KaryaAksi?> show(
    BuildContext context, {
    required Karya karya,
    required ColoringPage? halaman,
    required String nama,
  }) {
    return showWideDialog<KaryaAksi>(
      context,
      maxWidth: 1008,
      radius: 40,
      builder: (context) =>
          KaryaDetailDialog(karya: karya, halaman: halaman, nama: nama),
    );
  }

  @override
  State<KaryaDetailDialog> createState() => _KaryaDetailDialogState();
}

class _KaryaDetailDialogState extends State<KaryaDetailDialog> {
  bool _yakin = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final halaman = widget.halaman;
    return SizedBox(
      height: 540,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 720,
            height: 540,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF3EBD6), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: halaman == null
                    ? Center(
                        child: Text(
                          widget.nama,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: MociText.title.copyWith(fontSize: 32),
                        ),
                      )
                    : ColoringView(
                        halaman: halaman,
                        data: widget.karya.data,
                        width: 716,
                        height: 536,
                        radius: 20,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 26),
          SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 4),
                Text(
                  widget.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MociText.title.copyWith(fontSize: 32, height: 1.1),
                ),
                const SizedBox(height: 12),
                MociDialogButton(
                  label: l10n.mewarnaiColorAgain,
                  color: const Color(0xFF26A03B),
                  shadowColor: const Color(0xFF1E8A31),
                  textColor: const Color(0xFFFFFFFF),
                  onTap: () => Navigator.of(context).pop(KaryaAksi.warnaiLagi),
                ),
                const SizedBox(height: 14),
                MociDialogButton(
                  label: _yakin
                      ? l10n.mewarnaiDeleteConfirm
                      : l10n.mewarnaiDelete,
                  color: _yakin
                      ? const Color(0xFFE8384F)
                      : const Color(0xFFFFFFFF),
                  shadowColor: _yakin
                      ? const Color(0xFFB82A3E)
                      : const Color(0xFFF5C2C7),
                  textColor: _yakin
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFC92A2A),
                  onTap: () {
                    if (!_yakin) {
                      setState(() => _yakin = true);
                      return;
                    }
                    Navigator.of(context).pop(KaryaAksi.hapus);
                  },
                ),
                const Spacer(),
                MociDialogButton(
                  label: l10n.mewarnaiClose,
                  color: const Color(0xFFFFF7E0),
                  shadowColor: const Color(0xFFF2D27A),
                  textColor: const Color(0xFF2B2350),
                  onTap: () => Navigator.of(context).pop(KaryaAksi.tutup),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
