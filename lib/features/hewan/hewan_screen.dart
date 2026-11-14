import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'hewan_isi.dart';

/// Dunia Hewan: 42 hewan dalam lima kelompok, kartu fakta, papan nama,
/// gelembung bunyi, dan rail hewan.
class HewanScreen extends ConsumerStatefulWidget {
  const HewanScreen({super.key, this.awal});

  static const imageKey = ValueKey<String>('hewan-image');
  static const factKey = ValueKey<String>('hewan-fact');
  static const hearNameKey = ValueKey<String>('hewan-hear-name');
  static const hearSoundKey = ValueKey<String>('hewan-hear-sound');
  static const prevKey = ValueKey<String>('hewan-prev');
  static const nextKey = ValueKey<String>('hewan-next');

  static ValueKey<String> groupKey(HewanKelompok k) =>
      ValueKey('hewan-group-${k.id}');

  static ValueKey<String> tileKey(String id) => ValueKey('hewan-tile-$id');

  /// Hewan pertama saat layar dibuka; nilai di luar katalog diabaikan.
  final String? awal;

  @override
  ConsumerState<HewanScreen> createState() => _HewanScreenState();
}

class _HewanScreenState extends ConsumerState<HewanScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF2F9E44);
  static const _accentShadow = Color(0xFF1E7A33);
  static const _softShadow = Color(0xFF9FD3A0);
  static const _soundRed = Color(0xFFE8384F);
  static const _boardBrown = Color(0xFFA9744F);
  static const _boardShadow = Color(0xFF7A5236);

  static final _bounce = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.16,
      ).chain(CurveTween(curve: const Cubic(0.3, 1.6, 0.5, 1))),
      weight: 55,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.16,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
  ]);

  HewanKelompok? _kelompok;
  late String _id;
  late final AnimationController _bubble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  Katalog get _katalog => ref.read(katalogProvider);

  AppLang get _lang => ref.read(prefsProvider).lang;

  List<Item> get _daftar => hewanTampil(_katalog, kelompok: _kelompok);

  Item get _item => hewanById(_katalog, _id)!;

  int get _nomor {
    final i = _daftar.indexWhere((e) => e.id == _id);
    return i < 0 ? 1 : i + 1;
  }

  @override
  void initState() {
    super.initState();
    _id = hewanById(_katalog, widget.awal)!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _sayNama();
    });
  }

  @override
  void dispose() {
    _bubble.dispose();
    super.dispose();
  }

  void _catat() {
    final progress = ref.read(progressProvider.notifier);
    progress.setLastActivity(Routes.hewan, {'hewan': _id});
    progress.markItem('hewan', 'dilihat', _id);
  }

  void _sayNama() => ref.read(narratorProvider).sayAll([
    NarrationLine(jenis: 'nama', id: _id, text: _item.nama.of(_lang)),
  ], _lang);

  void _sayFakta() => ref.read(narratorProvider).sayAll([
    NarrationLine(jenis: 'fakta', id: _id, text: faktaHewan(_item, _lang)),
  ], _lang);

  /// Berkas rekaman diputar apa adanya kalau ada; tanpa berkas, tiruan bunyi
  /// katalog dibacakan TTS.
  void _suara() {
    final path = pathSuaraHewan(_id);
    if (ref.read(assetCatalogProvider).has(path)) {
      ref.read(audioServiceProvider).narrate(path);
      return;
    }
    ref.read(narratorProvider).sayAll([
      NarrationLine(jenis: 'bunyi', id: _id, text: bunyiHewan(_item, _lang)),
    ], _lang);
  }

  void _ketukGambar() {
    if (!MediaQuery.disableAnimationsOf(context)) _bubble.forward(from: 0);
    _suara();
  }

  void _pilihKelompok(HewanKelompok? k) {
    final daftar = hewanTampil(_katalog, kelompok: k);
    if (daftar.isEmpty) return;
    setState(() {
      _kelompok = k;
      _id = daftar.first.id;
    });
    _catat();
    _sayNama();
  }

  void _geser(int arah) {
    final daftar = _daftar;
    final i = daftar.indexWhere((e) => e.id == _id);
    final next = daftar[(i + arah) % daftar.length];
    setState(() => _id = next.id);
    _catat();
    _sayNama();
  }

  void _pilih(String id) {
    if (id == _id) {
      _sayNama();
      return;
    }
    setState(() => _id = id);
    _catat();
    _sayNama();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(prefsProvider.select((p) => p.lang), (_, _) => _sayNama());
    ref.watch(prefsProvider.select((p) => p.lang));
    ref.watch(katalogProvider);
    return MociStage(theme: MenuTheme.hewan, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    final item = _item;
    final nama = item.nama.of(_lang);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.menuHewanTitle,
            trailing: [
              _counter(l10n),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(
          left: 32,
          right: 32,
          top: 112,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _groupPill(l10n.hewanGroupAll, null, null),
              for (final k in HewanKelompok.values)
                _groupPill(_label(k, l10n), k, HewanScreen.groupKey(k)),
            ],
          ),
        ),
        Positioned(left: 44, top: 196, width: 300, child: _factCard(l10n)),
        Positioned(
          left: 400,
          top: 500,
          child: IgnorePointer(
            child: SizedBox(
              width: 400,
              height: 64,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF5FC456).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 440,
          top: 196,
          child: MociPressable(
            key: HewanScreen.imageKey,
            onTap: _ketukGambar,
            color: const Color(0x00000000),
            shadowColor: const Color(0x00000000),
            depth: 0,
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            semanticLabel: '$nama${l10n.hewanTapHint}',
            child: MociIllustration(item.id, size: 320),
          ),
        ),
        Positioned(
          left: 712,
          top: 176,
          child: ScaleTransition(
            scale: _bubble.drive(_bounce),
            child: _bubbleBox(bunyiHewan(item, _lang)),
          ),
        ),
        Positioned(left: 400, top: 520, width: 400, child: _nameBoard(nama)),
        Positioned(left: 888, top: 268, width: 256, child: _controls(l10n)),
        Positioned(left: 0, top: 636, right: 0, height: 168, child: _rail()),
      ],
    );
  }

  String _label(HewanKelompok k, AppLocalizations l10n) => switch (k) {
    HewanKelompok.rumah => l10n.hewanGroupRumah,
    HewanKelompok.liar => l10n.hewanGroupLiar,
    HewanKelompok.reptil => l10n.hewanGroupReptil,
    HewanKelompok.air => l10n.hewanGroupAir,
    HewanKelompok.kecil => l10n.hewanGroupKecil,
  };

  Widget _counter(AppLocalizations l10n) {
    final total = _daftar.length;
    return Semantics(
      container: true,
      label: l10n.hewanCounterLabel(_nomor, total),
      excludeSemantics: true,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: _softShadow, offset: Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Text(
            '$_nomor / $total',
            style: const TextStyle(
              fontFamily: MociFonts.fredoka,
              fontWeight: FontWeight.w700,
              fontSize: 30,
              color: MociColors.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _groupPill(String label, HewanKelompok? k, Key? key) {
    final aktif = k == null ? _kelompok == null : _kelompok == k;
    return MociPressable(
      key: key ?? const ValueKey<String>('hewan-group-all'),
      onTap: () => _pilihKelompok(k),
      color: aktif ? _accent : MociColors.white,
      shadowColor: aktif ? _accentShadow : _softShadow,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      semanticLabel: label,
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: MociFonts.nunito,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: aktif ? MociColors.white : MociColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _factCard(AppLocalizations l10n) {
    return Container(
      key: HewanScreen.factKey,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: const [BoxShadow(color: _softShadow, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.hewanDidYou,
            style: const TextStyle(
              fontFamily: MociFonts.nunito,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: Color(0xFF6B5F99),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            faktaHewan(_item, _lang),
            style: const TextStyle(
              fontFamily: MociFonts.nunito,
              fontWeight: FontWeight.w800,
              fontSize: 23,
              height: 1.3,
              color: MociColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          MociPressable(
            onTap: _sayFakta,
            color: const Color(0xFFFFF3BF),
            shadowColor: const Color(0xFFF2D27A),
            depth: 4,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            semanticLabel: l10n.commonListen,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GameGlyph(GameGlyphKind.listen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    l10n.commonListen,
                    style: const TextStyle(
                      fontFamily: MociFonts.nunito,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: MociColors.ink,
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

  Widget _bubbleBox(String bunyi) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 340),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
            decoration: BoxDecoration(
              color: MociColors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: MociColors.neutralShadow,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                bunyi,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontWeight: FontWeight.w700,
                  fontSize: ukuranBunyiHewan(bunyi),
                  height: 1.05,
                  color: _soundRed,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: -22,
            child: SizedBox(
              width: 40,
              height: 30,
              child: CustomPaint(painter: const _BubbleTail()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameBoard(String nama) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220, maxWidth: 400),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
            decoration: BoxDecoration(
              color: _boardBrown,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: _boardShadow, offset: Offset(0, 7)),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                nama,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontWeight: FontWeight.w700,
                  fontSize: ukuranNamaHewan(nama),
                  height: 1.05,
                  color: MociColors.white,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 2; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 53),
                width: 14,
                height: 24,
                color: _boardShadow,
              ),
          ],
        ),
      ],
    );
  }

  Widget _controls(AppLocalizations l10n) {
    return Column(
      children: [
        _roundAction(
          key: HewanScreen.hearNameKey,
          label: l10n.hewanHearName,
          color: const Color(0xFFFFB020),
          shadow: const Color(0xFFE0870B),
          textColor: MociColors.ink,
          onTap: _sayNama,
        ),
        const SizedBox(height: 16),
        _roundAction(
          key: HewanScreen.hearSoundKey,
          label: l10n.hewanHearSound,
          color: const Color(0xFF26A03B),
          shadow: const Color(0xFF1E8A31),
          textColor: MociColors.white,
          onTap: _suara,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _arrow(
                key: HewanScreen.prevKey,
                label: l10n.hewanPrev,
                putar: true,
                onTap: () => _geser(-1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _arrow(
                key: HewanScreen.nextKey,
                label: l10n.hewanNext,
                putar: false,
                onTap: () => _geser(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roundAction({
    required Key key,
    required String label,
    required Color color,
    required Color shadow,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return MociPressable(
      key: key,
      onTap: onTap,
      color: color,
      shadowColor: shadow,
      depth: 8,
      borderRadius: const BorderRadius.all(Radius.circular(40)),
      semanticLabel: label,
      minTouch: 64,
      child: SizedBox(
        width: 256,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameGlyph(GameGlyphKind.listen, size: 30, color: textColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w600,
                fontSize: 23,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow({
    required Key key,
    required String label,
    required bool putar,
    required VoidCallback onTap,
  }) {
    return MociPressable(
      key: key,
      onTap: onTap,
      color: MociColors.white,
      shadowColor: _softShadow,
      depth: 7,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      semanticLabel: label,
      child: SizedBox(
        height: 70,
        child: Center(
          child: RotatedBox(
            quarterTurns: putar ? 2 : 0,
            child: const GameGlyph(GameGlyphKind.next, size: 34),
          ),
        ),
      ),
    );
  }

  Widget _rail() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(44, 10, 44, 24),
      child: Row(
        children: [
          for (final item in _daftar) ...[
            _tile(item),
            const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }

  Widget _tile(Item item) {
    final aktif = item.id == _id;
    return MociPressable(
      key: HewanScreen.tileKey(item.id),
      onTap: () => _pilih(item.id),
      color: MociColors.white,
      shadowColor: aktif ? const Color(0xFFE0870B) : _softShadow,
      depth: 7,
      borderRadius: const BorderRadius.all(Radius.circular(56)),
      semanticLabel: item.nama.of(_lang),
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: aktif ? const Color(0xFFFFB020) : MociColors.white,
            width: 6,
          ),
        ),
        child: Center(child: MociIllustration(item.id, size: 84)),
      ),
    );
  }
}

class _BubbleTail extends CustomPainter {
  const _BubbleTail();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(6, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = MociColors.white);
  }

  @override
  bool shouldRepaint(_BubbleTail old) => false;
}
