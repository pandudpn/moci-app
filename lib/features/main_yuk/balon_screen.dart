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
import '../../widgets/pressable.dart';
import '../hadiah/main_lagi.dart';
import 'balon_game.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';

/// Ukuran balon dan enam posisinya di panggung tablet.
const _balonLebar = 150.0;
const _balonTinggi = 236.0;
const _slotBalon = [
  Offset(60, 400),
  Offset(240, 270),
  Offset(420, 430),
  Offset(600, 290),
  Offset(780, 440),
  Offset(960, 300),
];

/// Pasangan warna balon: muka dan bayangannya.
const _warnaBalon = [
  (Color(0xFFFF6B6B), Color(0xFFE03E3E)),
  (Color(0xFFFFB020), Color(0xFFE0870B)),
  (Color(0xFF22C1C3), Color(0xFF129A9C)),
  (Color(0xFF9775FA), Color(0xFF7048E8)),
  (Color(0xFF51CF66), Color(0xFF2F9E44)),
  (Color(0xFFF06595), Color(0xFFC2255C)),
];

const _ledakanDurasi = Duration(milliseconds: 400);
const _lanjutJeda = Duration(milliseconds: 1000);

/// Balon Huruf: pecahkan balon yang hurufnya sama dengan yang disebut Moci.
class BalonScreen extends ConsumerStatefulWidget {
  const BalonScreen({super.key});

  static const targetKey = ValueKey('balon-target');
  static const progressKey = ValueKey('balon-progress');

  static ValueKey<int> balonKey(int i) => ValueKey(i);

  @override
  ConsumerState<BalonScreen> createState() => _BalonScreenState();
}

class _BalonScreenState extends ConsumerState<BalonScreen>
    with TickerProviderStateMixin, MainLagi<BalonScreen> {
  late BalonGame _game;
  late String _roundId;
  bool _selesai = false;

  late final _apung = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );
  late final _goyang = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );

  /// Jeda sebelum ronde berikutnya; dibatalkan saat layar ditutup.
  Timer? _lanjutTimer;

  @override
  void initState() {
    super.initState();
    _game = BalonGame(
      usia: ref.read(prefsProvider).ageLevel,
      random: ref.read(gameRandomProvider),
    );
    _apung.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.balon);
      _say([_instLine()]);
      _say([_askLine(), _hurufLine(_game.ronde.target)]);
    });
  }

  @override
  void dispose() {
    _lanjutTimer?.cancel();
    _apung.dispose();
    _goyang.dispose();
    super.dispose();
  }

  String _nomorRonde() =>
      ref.read(mainYukRoundSeqProvider.notifier).next(MainYukGame.balon.id);

  String _namaHuruf(String huruf) {
    for (final entry in ref.read(katalogProvider).huruf) {
      if (entry.huruf == huruf) {
        return entry.of(ref.read(prefsProvider).lang).nama;
      }
    }
    return huruf;
  }

  NarrationLine _instLine() => barisUi('balonInst', context.l10n.balonInst);

  NarrationLine _askLine() => barisUi('balonAsk', context.l10n.balonAsk);

  NarrationLine _hurufLine(String huruf) =>
      barisHuruf(huruf, _namaHuruf(huruf));

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _tanya() => _say([_askLine(), _hurufLine(_game.ronde.target)]);

  void _pilih(int i) {
    switch (_game.pilih(i)) {
      case BalonStep.salah:
        ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
        _goyang.forward(from: 0);
        _say([
          barisUi('balonNo', context.l10n.balonNo),
          _hurufLine(_game.ronde.huruf[i]),
        ]);
        setState(() {});
      case BalonStep.pecah:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([
          barisUi('balonYes', context.l10n.balonYes),
          _hurufLine(_game.ronde.target),
        ]);
        setState(() {});
        _lanjutTimer?.cancel();
        _lanjutTimer = Timer(_lanjutJeda, _lanjut);
      case BalonStep.selesai:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([
          barisUi('balonYes', context.l10n.balonYes),
          _hurufLine(_game.ronde.target),
        ]);
        setState(() {});
        _lanjutTimer?.cancel();
        _lanjutTimer = Timer(_lanjutJeda, _lanjut);
    }
  }

  void _lanjut() {
    if (!mounted) return;
    _game.lanjut();
    setState(() {});
    if (_game.selesai) _selesaikanRonde();
  }

  void _selesaikanRonde() {
    if (_selesai) return;
    _selesai = true;
    unawaited(
      selesaikanRonde(
        context,
        ref,
        gameId: MainYukGame.balon.id,
        roundId: _roundId,
        replayRoute: Routes.balon,
      ),
    );
  }

  @override
  String get ruteMainLagi => Routes.balon;

  @override
  void mulaiUlang() => setState(_mainBaru);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GameScaffold(
      theme: MenuTheme.balon,
      title: l10n.balonTitle,
      trailing: [_tombolTanya(l10n), _pilKemajuan(l10n)],
      children: [for (var i = 0; i < _slotBalon.length; i++) _balon(i, l10n)],
    );
  }

  void _mainBaru() {
    _game = BalonGame(
      usia: ref.read(prefsProvider).ageLevel,
      random: ref.read(gameRandomProvider),
    );
    _roundId = _nomorRonde();
    _selesai = false;
  }

  Widget _tombolTanya(AppLocalizations l10n) {
    return MociPressable(
      onTap: _tanya,
      semanticLabel: l10n.balonAsk,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.balonAsk, style: MociText.title.copyWith(fontSize: 28)),
            const SizedBox(width: 12),
            DecoratedBox(
              key: BalonScreen.targetKey,
              decoration: BoxDecoration(
                color: const Color(0xFF22C1C3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 58,
                height: 58,
                child: Center(
                  child: Text(
                    _game.ronde.target,
                    style: MociText.title.copyWith(
                      fontSize: 34,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pilKemajuan(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return DecoratedBox(
      key: BalonScreen.progressKey,
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
                l10n.balonProgress,
                style: MociText.label.copyWith(color: MociColors.inkSoft),
              ),
              const SizedBox(width: 14),
              ProgressDots(
                count: balonRonde,
                current: _game.skor,
                semanticLabel: l10n.balonProgress,
                activeColor: const Color(0xFF22C1C3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balon(int i, AppLocalizations l10n) {
    final posisi = _slotBalon[i];
    final pecah = _game.pecah.contains(i);
    final diam = MediaQuery.disableAnimationsOf(context);
    final (muka, bayangan) = _warnaBalon[i];
    Widget isi = pecah
        ? _ledakan(i, muka)
        : MociPressable(
            key: BalonScreen.balonKey(i),
            onTap: () => _pilih(i),
            semanticLabel: l10n.balonLabel(_game.ronde.huruf[i]),
            color: muka,
            shadowColor: bayangan,
            depth: 10,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: SizedBox(
              width: _balonLebar,
              height: _balonTinggi,
              child: Center(
                child: Text(
                  _game.ronde.huruf[i],
                  style: MociText.bigNumber.copyWith(
                    fontSize: 68,
                    color: MociColors.white,
                    shadows: const [
                      Shadow(color: Color(0x33000000), offset: Offset(0, 4)),
                    ],
                  ),
                ),
              ),
            ),
          );
    if (pecah || diam) {
      return Positioned(
        left: posisi.dx,
        top: posisi.dy,
        width: _balonLebar,
        height: _balonTinggi,
        child: isi,
      );
    }
    final fase = i / _slotBalon.length;
    return Positioned(
      left: posisi.dx,
      top: posisi.dy,
      width: _balonLebar,
      height: _balonTinggi,
      child: AnimatedBuilder(
        animation: _goyang,
        builder: (context, child) {
          final goyang = _goyang.value;
          final geser = math.sin(goyang * math.pi * 6) * 10 * (1 - goyang);
          return Transform.translate(
            offset: Offset(goyang > 0 ? geser : 0, 0),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _apung,
          builder: (context, child) {
            final t = (_apung.value + fase) % 1;
            final naik = math.sin(t * math.pi * 2) * 14;
            return Transform.translate(offset: Offset(0, naik), child: child);
          },
          child: isi,
        ),
      ),
    );
  }

  /// Ledakan bintang 400 ms pengganti balon yang pecah.
  Widget _ledakan(int i, Color warna) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey('balon-pecah-$i'),
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : _ledakanDurasi,
        builder: (context, t, _) => Opacity(
          opacity: 1 - t,
          child: Center(
            child: Transform.scale(
              scale: 0.6 + t,
              child: GameGlyph(GameGlyphKind.star, size: 90, color: warna),
            ),
          ),
        ),
      ),
    );
  }
}
