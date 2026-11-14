import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/router.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_motion.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/pressable.dart';
import '../hadiah/main_lagi.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';
import 'puzzle_game.dart';

const _border = Color(0xFFF2C57C);
const _borderAktif = Color(0xFFE0870B);
const _isiSlot = Color(0x1AFFB020);
const _trayBorder = Color(0xFFFFE3B3);

/// Puzzle: susun satu ilustrasi dari 4, 6, atau 9 keping.
class PuzzleScreen extends ConsumerStatefulWidget {
  const PuzzleScreen({super.key});

  static const boardKey = ValueKey('puzzle-board');
  static const countKey = ValueKey('puzzle-count');
  static const otherKey = ValueKey('puzzle-other');

  static ValueKey<int> slotKey(int i) => ValueKey(i);

  static ValueKey<int> pieceKey(int i) => ValueKey(-i - 1);

  @override
  ConsumerState<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends ConsumerState<PuzzleScreen>
    with SingleTickerProviderStateMixin, MainLagi<PuzzleScreen> {
  late PuzzleGame _game;
  late String _roundId;
  bool _selesai = false;

  late final _goyang = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );

  @override
  void initState() {
    super.initState();
    _game = PuzzleGame(
      katalog: ref.read(katalogProvider),
      usia: ref.read(prefsProvider).ageLevel,
      random: ref.read(gameRandomProvider),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.puzzle);
      _say([_instLine()]);
    });
  }

  @override
  void dispose() {
    _goyang.dispose();
    super.dispose();
  }

  String _nomorRonde() =>
      ref.read(mainYukRoundSeqProvider.notifier).next(MainYukGame.puzzle.id);

  NarrationLine _instLine() => barisUi('puzzleInst', context.l10n.puzzleInst);

  String _namaGambar() {
    final item = ref.read(katalogProvider).byId(_game.gambar);
    return item?.nama.of(ref.read(prefsProvider).lang) ?? _game.gambar;
  }

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _ketukKeping(int keping) {
    _game.pilih(keping);
    setState(() {});
    _say([barisUi('puzzleTipPlace', context.l10n.puzzleTipPlace)]);
  }

  void _letak(int slot) {
    switch (_game.letak(slot)) {
      case PuzzleStep.pilih:
        return;
      case PuzzleStep.pas:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([barisUi('puzzleFits', context.l10n.puzzleFits)]);
        setState(() {});
      case PuzzleStep.salah:
        ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
        _goyang.forward(from: 0);
        _say([barisUi('puzzleNo', context.l10n.puzzleNo)]);
        setState(() {});
      case PuzzleStep.selesai:
        _say([
          barisUi('puzzleDone', context.l10n.puzzleDone),
          barisNama(_game.gambar, _namaGambar()),
        ]);
        setState(() {});
        _selesaikanRonde();
    }
  }

  void _puzzleLain() {
    setState(() {
      _game.ulang();
      _roundId = _nomorRonde();
      _selesai = false;
    });
  }

  void _selesaikanRonde() {
    if (_selesai) return;
    _selesai = true;
    unawaited(
      selesaikanRonde(
        context,
        ref,
        gameId: MainYukGame.puzzle.id,
        roundId: _roundId,
        replayRoute: Routes.puzzle,
      ),
    );
  }

  @override
  String get ruteMainLagi => Routes.puzzle;

  @override
  void mulaiUlang() => _puzzleLain();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GameScaffold(
      theme: MenuTheme.puzzle,
      title: l10n.puzzleTitle,
      trailing: [
        _pilHitungan(l10n),
        MociPressable(
          key: PuzzleScreen.otherKey,
          onTap: _puzzleLain,
          semanticLabel: l10n.puzzleOther,
          depth: 6,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          minTouch: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GameGlyph(GameGlyphKind.refresh, size: 26),
                  const SizedBox(width: 10),
                  Text(l10n.puzzleOther, style: MociText.label),
                ],
              ),
            ),
          ),
        ),
      ],
      children: [_papan(l10n), _baki(l10n), _petunjuk(l10n)],
    );
  }

  Widget _pilHitungan(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return DecoratedBox(
      key: PuzzleScreen.countKey,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 64,
          child: Center(
            child: Text(
              l10n.puzzlePieces(_game.terpasang.length, _game.jumlah),
              style: MociText.label,
            ),
          ),
        ),
      ),
    );
  }

  Widget _papan(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    final lebar = puzzleSisi / _game.kolom;
    final tinggi = puzzleSisi / _game.baris;
    return Positioned(
      left: 60,
      top: 128,
      width: puzzleSisi,
      height: puzzleSisi,
      child: AnimatedBuilder(
        animation: _goyang,
        builder: (context, child) {
          final t = _goyang.value;
          final geser = math.sin(t * math.pi * 6) * 10 * (1 - t);
          return Transform.translate(offset: Offset(geser, 0), child: child);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MociColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(26)),
            boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 10))],
          ),
          child: Semantics(
            container: true,
            label: l10n.puzzleBoard,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(26)),
              child: Stack(
                key: PuzzleScreen.boardKey,
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.16,
                      child: MociIllustration(_game.gambar, size: puzzleSisi),
                    ),
                  ),
                  for (var i = 0; i < _game.jumlah; i++)
                    Positioned(
                      left: (i % _game.kolom) * lebar,
                      top: (i ~/ _game.kolom) * tinggi,
                      width: lebar,
                      height: tinggi,
                      child: _slot(i, lebar, tinggi, l10n),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slot(int i, double lebar, double tinggi, AppLocalizations l10n) {
    if (_game.terpasang.contains(i)) {
      return _potongan(i, lebar, tinggi, 1, null);
    }
    final terpilih = _game.dipilih != null;
    // Node semantik sendiri: tanpa `container`, label tempat menempel ke
    // papan dan tes tidak bisa menemukannya satu per satu.
    return Semantics(
      container: true,
      button: true,
      label: l10n.puzzleSpot(i + 1),
      child: GestureDetector(
        key: PuzzleScreen.slotKey(i),
        behavior: HitTestBehavior.opaque,
        onTap: () => _letak(i),
        child: CustomPaint(
          // Garis di atas isi slot; `painter` akan tertutup warnanya.
          foregroundPainter: _SlotPainter(
            warna: terpilih ? _borderAktif : _border,
          ),
          child: const ColoredBox(color: _isiSlot),
        ),
      ),
    );
  }

  Widget _baki(AppLocalizations l10n) {
    final lebar = puzzleSisi / _game.kolom * 0.9;
    final tinggi = puzzleSisi / _game.baris * 0.9;
    return Positioned(
      left: 600,
      top: 128,
      width: 520,
      height: 480,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB3FFFFFF),
          borderRadius: const BorderRadius.all(Radius.circular(26)),
          border: Border.all(color: _trayBorder, width: 3),
        ),
        child: Padding(
          // Sembilan keping 144 pt butuh 464 pt; sisa tinggi baki hanya 464.
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (final keping in _game.urutan)
                MociPressable(
                  key: PuzzleScreen.pieceKey(keping),
                  onTap: () => _ketukKeping(keping),
                  semanticLabel: l10n.puzzlePiece(keping + 1),
                  color: MociColors.white,
                  depth: 6,
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  child: SizedBox(
                    width: lebar,
                    height: tinggi,
                    child: _potongan(
                      keping,
                      lebar,
                      tinggi,
                      lebar / (puzzleSisi / _game.kolom),
                      null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Potongan gambar: bagian [slot] dari ilustrasi, diskalakan [skala] kali.
  Widget _potongan(
    int slot,
    double lebar,
    double tinggi,
    double skala,
    Key? key,
  ) {
    final x = slot % _game.kolom;
    final y = slot ~/ _game.kolom;
    return SizedBox(
      key: key,
      width: lebar,
      height: tinggi,
      child: ClipRect(
        child: Transform.scale(
          scale: skala,
          alignment: Alignment.topLeft,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: puzzleSisi,
            maxWidth: puzzleSisi,
            minHeight: puzzleSisi,
            maxHeight: puzzleSisi,
            child: Transform.translate(
              offset: Offset(
                -x * (puzzleSisi / _game.kolom),
                -y * (puzzleSisi / _game.baris),
              ),
              child: MociIllustration(_game.gambar, size: puzzleSisi),
            ),
          ),
        ),
      ),
    );
  }

  Widget _petunjuk(AppLocalizations l10n) {
    final memilih = _game.dipilih != null;
    return Positioned(
      left: 60,
      top: 636,
      child: Row(
        children: [
          Text(
            memilih ? l10n.puzzleHintPlace : l10n.puzzleHintPick,
            style: MociText.body.copyWith(color: MociColors.inkSoft),
          ),
          const SizedBox(width: 16),
          const MociMascot(size: 56, idle: true),
        ],
      ),
    );
  }
}

/// Bingkai putus-putus penanda tempat keping.
class _SlotPainter extends CustomPainter {
  const _SlotPainter({required this.warna});

  final Color warna;

  @override
  void paint(Canvas canvas, Size size) {
    final kuas = Paint()
      ..color = warna
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(10)),
      );
    for (final metric in path.computeMetrics()) {
      var jarak = 0.0;
      while (jarak < metric.length) {
        final akhir = math.min(jarak + 12, metric.length);
        canvas.drawPath(metric.extractPath(jarak, akhir), kuas);
        jarak += 22;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SlotPainter old) => old.warna != warna;
}
