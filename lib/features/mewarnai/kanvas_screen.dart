import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_graphics/vector_graphics.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/content/coloring.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/pressable.dart';
import 'mewarnai_engine.dart';
import 'mewarnai_model.dart';
import 'mewarnai_providers.dart';
import 'widgets/coloring_canvas.dart';
import 'widgets/tool_bar.dart';

/// Layar mewarnai satu halaman: kanvas sentuh, panel alat, batal, dan draf
/// otomatis.
class KanvasScreen extends ConsumerStatefulWidget {
  const KanvasScreen({super.key, required this.halaman});

  final String halaman;

  static const canvasKey = ValueKey('kanvas-canvas');
  static const toolbarKey = ValueKey('kanvas-toolbar');
  static const undoKey = ValueKey('kanvas-undo');
  static const clearKey = ValueKey('kanvas-clear');

  static ValueKey<AlatMewarnai> toolKey(AlatMewarnai alat) =>
      MewarnaiToolBar.toolKey(alat);

  static ValueKey<UkuranKuas> sizeKey(UkuranKuas ukuran) =>
      MewarnaiToolBar.sizeKey(ukuran);

  static ValueKey<String> crayonKey(String hex) =>
      MewarnaiToolBar.crayonKey(hex);

  static ValueKey<String> capKey(String id) => MewarnaiToolBar.capKey(id);

  @override
  ConsumerState<KanvasScreen> createState() => _KanvasScreenState();
}

class _KanvasScreenState extends ConsumerState<KanvasScreen> {
  MesinMewarnai? _mesin;
  KaryaController? _karya;
  Timer? _draf;
  bool _dialihkan = false;

  AlatMewarnai? _alatLalu;
  UkuranKuas? _ukuranLalu;
  String? _warnaLalu;
  String? _capLalu;
  int? _terkunciLalu;
  int _riwayatLalu = 0;
  KaryaData? _dataLalu;
  bool _kotor = false;

  @override
  void initState() {
    super.initState();
    _karya = ref.read(karyaProvider.notifier);
    unawaited(_karya!.muat());
    // Ditulis setelah frame pertama: `setLastActivity` mengubah provider dan
    // tidak boleh berjalan saat pohon widget sedang dibangun.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref
            .read(progressProvider.notifier)
            .setLastActivity('${Routes.mewarnai}/${widget.halaman}'),
      );
    });
  }

  @override
  void dispose() {
    _draf?.cancel();
    final mesin = _mesin;
    if (mesin != null) {
      mesin.removeListener(_berubah);
      _tulisDraf();
      mesin.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    final set = ref.watch(coloringProvider).value;
    final karya = ref.watch(karyaProvider);
    final krayon = ref.watch(krayonProvider).value ?? const <Krayon>[];
    final cap = ref.watch(capProvider).value ?? const <Cap>[];
    final capGambar =
        ref.watch(capPictureProvider).value ?? const <String, PictureInfo>{};

    if (set != null && set.byId(widget.halaman) == null) {
      _alihkanKeGaleri();
      return const SizedBox.shrink();
    }
    final page = set?.byId(widget.halaman);
    if (page == null || !karya.siap) return const SizedBox.shrink();

    final mesin = _mesinUntuk(page, karya);
    final nama = page.nama.of(lang);
    return MociStage(
      theme: MenuTheme.mewarnai,
      tablet: (context) => Stack(
        children: [
          Positioned(
            left: 24,
            right: 24,
            top: 20,
            child: _bilahAtas(context, mesin, nama, l10n),
          ),
          Positioned(
            left: 24,
            top: 108,
            child: ColoringCanvas(
              key: KanvasScreen.canvasKey,
              mesin: mesin,
              cap: capGambar,
              semanticLabel: l10n.mewarnaiCanvasLabel(nama),
            ),
          ),
          Positioned(
            left: 908,
            top: 108,
            child: MewarnaiToolBar(
              key: KanvasScreen.toolbarKey,
              alat: mesin.alat,
              ukuran: mesin.ukuran,
              warna: mesin.warna,
              krayon: krayon,
              cap: cap,
              idCap: mesin.cap,
              onAlat: _pilihAlat,
              onUkuran: (u) => mesin.pilihUkuran(u),
              onWarna: _pilihWarna,
              onCap: _pilihCap,
            ),
          ),
          Positioned(
            left: 24,
            top: 772,
            child: SizedBox(
              width: 864,
              child: Row(
                children: [
                  const MociMascot(size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _petunjuk(mesin.alat, l10n),
                      style: MociText.label.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF6B5F99),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bilahAtas(
    BuildContext context,
    MesinMewarnai mesin,
    String nama,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        MociBackButton(
          semanticLabel: l10n.mewarnaiBackGaleri,
          onTap: () => context.go(Routes.mewarnai),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            nama,
            style: MociText.title.copyWith(fontSize: 40),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        MociPressable(
          key: KanvasScreen.undoKey,
          onTap: mesin.bisaBatal ? () => mesin.batal() : null,
          shadowColor: MenuTheme.mewarnai.shadow,
          borderRadius: BorderRadius.circular(999),
          depth: 5,
          semanticLabel: l10n.mewarnaiUndo,
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CustomPaint(
                    size: Size.square(26),
                    painter: _IkonBatal(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.mewarnaiUndo,
                    style: MociText.button.copyWith(fontSize: 21),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        MociPressable(
          key: KanvasScreen.clearKey,
          onTap: mesin.data.adaIsi ? _mulaiLagi : null,
          shadowColor: MenuTheme.mewarnai.shadow,
          borderRadius: BorderRadius.circular(999),
          depth: 5,
          semanticLabel: l10n.mewarnaiClear,
          child: const SizedBox(
            width: 58,
            height: 58,
            child: Center(
              child: CustomPaint(
                size: Size.square(28),
                painter: _IkonMulaiLagi(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  MesinMewarnai _mesinUntuk(ColoringPage page, KaryaState karya) {
    final ada = _mesin;
    if (ada != null) return ada;
    final draf = karya.drafUntuk(page.id);
    final mesin = MesinMewarnai(halaman: page, awal: draf)
      ..addListener(_berubah);
    _ingat(mesin);
    return _mesin = mesin;
  }

  /// Hanya perubahan isi, alat, warna, ukuran, kunci bagian, atau riwayat yang
  /// membangun ulang widget. Gerakan jari cukup menggambar ulang painter.
  void _berubah() {
    final mesin = _mesin;
    if (mesin == null) return;
    // Objek data baru berarti isi halaman berubah: draf perlu ditulis walau
    // hasilnya kosong (misalnya setelah Batal menghapus satu-satunya isian).
    final berisi = !identical(_dataLalu, mesin.data);
    if (berisi) {
      _kotor = true;
      _jadwalkanDraf();
    }
    final beda =
        berisi ||
        _alatLalu != mesin.alat ||
        _ukuranLalu != mesin.ukuran ||
        _warnaLalu != mesin.warna ||
        _capLalu != mesin.cap ||
        _terkunciLalu != mesin.bagianTerkunci ||
        _riwayatLalu != mesin.panjangRiwayat;
    if (!beda) return;
    _ingat(mesin);
    if (mounted) setState(() {});
  }

  void _ingat(MesinMewarnai mesin) {
    _alatLalu = mesin.alat;
    _ukuranLalu = mesin.ukuran;
    _warnaLalu = mesin.warna;
    _capLalu = mesin.cap;
    _terkunciLalu = mesin.bagianTerkunci;
    _riwayatLalu = mesin.panjangRiwayat;
    _dataLalu = mesin.data;
  }

  void _jadwalkanDraf() {
    _draf?.cancel();
    _draf = Timer(const Duration(milliseconds: 600), _tulisDraf);
  }

  void _tulisDraf() {
    final mesin = _mesin;
    if (mesin == null || !_kotor) return;
    unawaited(_karya?.simpanDraf(mesin.data));
  }

  void _pilihAlat(AlatMewarnai alat) {
    final mesin = _mesin;
    if (mesin == null) return;
    mesin.pilihAlat(alat);
    final l10n = context.l10n;
    _say(switch (alat) {
      AlatMewarnai.kuas => ('mewarnaiHintBrush', l10n.mewarnaiHintBrush),
      AlatMewarnai.isi => ('mewarnaiHintFill', l10n.mewarnaiHintFill),
      AlatMewarnai.hapus => ('mewarnaiHintErase', l10n.mewarnaiHintErase),
      AlatMewarnai.cap => ('mewarnaiHintCap', l10n.mewarnaiHintCap),
    });
  }

  void _pilihWarna(String hex) {
    final mesin = _mesin;
    if (mesin == null) return;
    mesin.pilihWarna(hex);
    // Krayon hanya berarti untuk kuas: pilihannya mengembalikan alat.
    if (mesin.alat == AlatMewarnai.hapus || mesin.alat == AlatMewarnai.cap) {
      mesin.pilihAlat(AlatMewarnai.kuas);
    }
  }

  void _pilihCap(String id) {
    final mesin = _mesin;
    if (mesin == null) return;
    mesin.pilihCap(id);
    mesin.pilihAlat(AlatMewarnai.cap);
  }

  void _mulaiLagi() {
    _mesin?.mulaiLagi();
    _say(('mewarnaiSayClear', context.l10n.mewarnaiSayClear));
  }

  void _say((String, String) baris) {
    final lang = ref.read(prefsProvider).lang;
    unawaited(
      ref.read(narratorProvider).sayAll([
        NarrationLine(jenis: 'ui', id: baris.$1, text: baris.$2),
      ], lang),
    );
  }

  String _petunjuk(AlatMewarnai alat, AppLocalizations l10n) => switch (alat) {
    AlatMewarnai.kuas => l10n.mewarnaiHintBrush,
    AlatMewarnai.isi => l10n.mewarnaiHintFill,
    AlatMewarnai.hapus => l10n.mewarnaiHintErase,
    AlatMewarnai.cap => l10n.mewarnaiHintCap,
  };

  void _alihkanKeGaleri() {
    if (_dialihkan) return;
    _dialihkan = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(Routes.mewarnai);
    });
  }
}

/// Ikon batal dari prototipe pada kanvas 24 × 24.
class _IkonBatal extends CustomPainter {
  const _IkonBatal();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(9 * k, 14 * k)
      ..lineTo(4 * k, 9 * k)
      ..lineTo(9 * k, 4 * k)
      ..moveTo(4 * k, 9 * k)
      ..lineTo(14 * k, 9 * k)
      ..arcToPoint(
        Offset(14 * k, 21 * k),
        radius: Radius.circular(6 * k),
        clockwise: true,
      )
      ..lineTo(11 * k, 21 * k);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = MociColors.ink,
    );
  }

  @override
  bool shouldRepaint(_IkonBatal old) => false;
}

/// Ikon tong sampah dari prototipe pada kanvas 24 × 24.
class _IkonMulaiLagi extends CustomPainter {
  const _IkonMulaiLagi();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final garis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = MociColors.ink;
    final path = Path()
      ..moveTo(4 * k, 7 * k)
      ..lineTo(20 * k, 7 * k)
      ..moveTo(9 * k, 7 * k)
      ..lineTo(9 * k, 4 * k)
      ..lineTo(15 * k, 4 * k)
      ..lineTo(15 * k, 7 * k)
      ..moveTo(6 * k, 7 * k)
      ..lineTo(7 * k, 20 * k)
      ..lineTo(17 * k, 20 * k)
      ..lineTo(18 * k, 7 * k)
      ..moveTo(10 * k, 11 * k)
      ..lineTo(10 * k, 17 * k)
      ..moveTo(14 * k, 11 * k)
      ..lineTo(14 * k, 17 * k);
    canvas.drawPath(path, garis);
  }

  @override
  bool shouldRepaint(_IkonMulaiLagi old) => false;
}
