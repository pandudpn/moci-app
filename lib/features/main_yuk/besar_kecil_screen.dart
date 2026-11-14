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
import '../../widgets/game/progress_dots.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/pressable.dart';
import 'besar_kecil_game.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';

const _accent = Color(0xFF5FD068);
const _akbar = Color(0xFFE8590C);
const _kecil = Color(0xFF1C7ED6);
const _tanah = Color(0xFFD3F9D8);

/// Tinggi kartu permainan; dasar gambar diletakkan di [besarKecilDasar].
const _kartuLebar = 1100.0;
const _kartuTinggi = 548.0;

/// Garis dasar gambar di dalam kartu.
const besarKecilDasar = 478.0;

const _lanjutJeda = Duration(milliseconds: 1300);

/// Besar & Kecil: ketuk gambar yang paling besar atau paling kecil.
class BesarKecilScreen extends ConsumerStatefulWidget {
  const BesarKecilScreen({super.key});

  static const askKey = ValueKey('besar-kecil-ask');
  static const progressKey = ValueKey('besar-kecil-progress');

  static ValueKey<int> ukuranKey(int i) => ValueKey(i);

  @override
  ConsumerState<BesarKecilScreen> createState() => _BesarKecilScreenState();
}

class _BesarKecilScreenState extends ConsumerState<BesarKecilScreen>
    with SingleTickerProviderStateMixin {
  late BesarKecilGame _game;
  late String _roundId;
  bool _selesai = false;
  bool _benar = false;

  late final _goyang = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );

  /// Jeda sebelum ronde berikutnya; dibatalkan saat layar ditutup.
  Timer? _lanjutTimer;

  @override
  void initState() {
    super.initState();
    _game = _gameBaru();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.besarKecil);
      _say([_instLine()]);
      _say([_whichLine(), _arahLine()]);
    });
  }

  @override
  void dispose() {
    _lanjutTimer?.cancel();
    _goyang.dispose();
    super.dispose();
  }

  BesarKecilGame _gameBaru() => BesarKecilGame(
    katalog: ref.read(katalogProvider),
    usia: ref.read(prefsProvider).ageLevel,
    random: ref.read(gameRandomProvider),
  );

  String _nomorRonde() => ref
      .read(mainYukRoundSeqProvider.notifier)
      .next(MainYukGame.besarKecil.id);

  String _nama(String id) {
    final item = ref.read(katalogProvider).byId(id);
    return item?.nama.of(ref.read(prefsProvider).lang) ?? id;
  }

  NarrationLine _instLine() =>
      barisUi('besarKecilInst', context.l10n.besarKecilInst);

  NarrationLine _whichLine() =>
      barisUi('besarKecilWhich', context.l10n.besarKecilWhich);

  NarrationLine _arahLine() => barisUi(
    _game.ronde.termuda ? 'besarKecilBigSay' : 'besarKecilSmallSay',
    _game.ronde.termuda
        ? context.l10n.besarKecilBigSay
        : context.l10n.besarKecilSmallSay,
  );

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _tanyaLagi() => _say([_whichLine(), _arahLine()]);

  void _pilih(int i) {
    if (!_game.pilih(i)) {
      ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
      _goyang.forward(from: 0);
      _say([barisUi('besarKecilNo', context.l10n.besarKecilNo)]);
      return;
    }
    ref.read(audioServiceProvider).playSfx(Sfx.benar);
    _say([barisUi('besarKecilYes', context.l10n.besarKecilYes), _arahLine()]);
    setState(() => _benar = true);
    _lanjutTimer?.cancel();
    _lanjutTimer = Timer(_lanjutJeda, _lanjut);
  }

  void _lanjut() {
    if (!mounted) return;
    setState(() {
      _game.lanjut();
      _benar = false;
    });
    if (_game.selesai) _selesaikanRonde();
  }

  void _mainBaru() {
    setState(() {
      _game = _gameBaru();
      _roundId = _nomorRonde();
      _selesai = false;
      _benar = false;
    });
  }

  void _selesaikanRonde() {
    if (_selesai) return;
    _selesai = true;
    unawaited(
      selesaikanRonde(
        context,
        ref,
        gameId: MainYukGame.besarKecil.id,
        roundId: _roundId,
        replayRoute: Routes.besarKecil,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Kembali dari Hebat lewat `go` memakai state layar ini lagi; permainan
    // sebelumnya sudah selesai dan harus dimulai dari awal.
    ref.listen(currentPathProvider, (sebelum, sekarang) {
      if (sebelum == Routes.hebat && sekarang == Routes.besarKecil) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mainBaru();
        });
      }
    });
    return GameScaffold(
      theme: MenuTheme.besarKecil,
      title: l10n.besarKecilTitle,
      trailing: [_pilKemajuan(l10n)],
      children: [_barTanya(l10n), _kartu(l10n)],
    );
  }

  Widget _pilKemajuan(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return DecoratedBox(
      key: BesarKecilScreen.progressKey,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.besarKecilProgress,
                style: MociText.label.copyWith(color: MociColors.inkSoft),
              ),
              const SizedBox(width: 14),
              ProgressDots(
                count: besarKecilRonde,
                current: _game.skor,
                semanticLabel: l10n.besarKecilProgress,
                activeColor: _accent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _barTanya(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    final besar = _game.ronde.termuda;
    return Positioned(
      left: 40,
      top: 120,
      width: _kartuLebar,
      height: 92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              MociPressable(
                onTap: _tanyaLagi,
                semanticLabel: l10n.besarKecilWhich,
                color: _accent,
                shadowColor: const Color(0xFF3BAA45),
                depth: 5,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Center(
                    child: GameGlyph(
                      GameGlyphKind.listen,
                      size: 30,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                l10n.besarKecilWhich,
                style: MociText.title.copyWith(fontSize: 38),
              ),
              const SizedBox(width: 14),
              // Kunci di pembungkus pil: tes mencari teks BESAR/KECIL di
              // dalamnya, bukan teks itu sendiri.
              DecoratedBox(
                key: BesarKecilScreen.askKey,
                decoration: BoxDecoration(
                  color: besar ? _akbar : _kecil,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: (besar ? _akbar : _kecil).withValues(alpha: 0.4),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        besar ? l10n.besarKecilBig : l10n.besarKecilSmall,
                        style: MociText.title.copyWith(
                          fontSize: 36,
                          color: MociColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text('?', style: MociText.title.copyWith(fontSize: 38)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kartu(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    final ukuran = _game.ronde.ukuran;
    final n = ukuran.length;
    return Positioned(
      left: 40,
      top: 236,
      width: _kartuLebar,
      height: _kartuTinggi,
      child: AnimatedBuilder(
        animation: _goyang,
        builder: (context, child) {
          final t = _goyang.value;
          final geser = math.sin(t * math.pi * 6) * 12 * (1 - t);
          return Transform.translate(offset: Offset(geser, 0), child: child);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MociColors.white,
            borderRadius: const BorderRadius.all(Radius.circular(44)),
            boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(44)),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 96,
                  child: const ColoredBox(color: _tanah),
                ),
                for (var i = 0; i < n; i++)
                  Positioned(
                    left: _kartuLebar / (n + 1) * (i + 1) - ukuran[i] / 2,
                    top: besarKecilDasar - ukuran[i],
                    child: _gambar(i, ukuran[i], l10n),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gambar(int i, double ukuran, AppLocalizations l10n) {
    final ronde = _game.ronde;
    final benar = _benar && ronde.ukuran[i] == ronde.jawaban;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        MociPressable(
          key: BesarKecilScreen.ukuranKey(i),
          onTap: () => _pilih(i),
          semanticLabel: l10n.besarKecilLabel(
            _nama(ronde.gambar),
            ukuran.round(),
          ),
          color: MociColors.white,
          shadowColor: const Color(0x00000000),
          depth: 0,
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          child: SizedBox(
            width: ukuran,
            height: ukuran,
            child: Center(
              child: MociIllustration(ronde.gambar, size: ukuran * 0.92),
            ),
          ),
        ),
        if (benar)
          Positioned(
            right: -6,
            top: -6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MociColors.correct,
                shape: BoxShape.circle,
                border: Border.all(color: MociColors.white, width: 4),
              ),
              child: const SizedBox(
                width: 54,
                height: 54,
                child: Center(
                  child: GameGlyph(
                    GameGlyphKind.check,
                    size: 28,
                    color: MociColors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
