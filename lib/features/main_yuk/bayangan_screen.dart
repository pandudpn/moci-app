import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/router.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/content/content_repository.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/answer_card.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/progress_dots.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/pressable.dart';
import '../hadiah/main_lagi.dart';
import 'bayangan_game.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';

const _accent = Color(0xFF9775FA);
const _ground = Color(0xFFEEE8FF);
const _lanjutJeda = Duration(milliseconds: 1500);

/// Tebak Bayangan: tebak gambar dari bayangannya, enam ronde sekali main.
class BayanganScreen extends ConsumerStatefulWidget {
  const BayanganScreen({super.key});

  static const targetKey = ValueKey('bayangan-target');
  static const skorKey = ValueKey('bayangan-skor');

  static ValueKey<String> pilihanKey(String id) => ValueKey(id);

  @override
  ConsumerState<BayanganScreen> createState() => _BayanganScreenState();
}

class _BayanganScreenState extends ConsumerState<BayanganScreen>
    with MainLagi<BayanganScreen> {
  late BayanganGame _game;
  late String _roundId;
  bool _selesai = false;

  @override
  String get ruteMainLagi => Routes.bayangan;

  @override
  void mulaiUlang() => setState(_mainBaru);

  void _mainBaru() {
    _game = BayanganGame(
      katalog: ref.read(katalogProvider),
      usia: ref.read(prefsProvider).ageLevel,
      random: ref.read(gameRandomProvider),
    );
    _roundId = _nomorRonde();
    _selesai = false;
  }

  /// Jeda sebelum ronde berikutnya; dibatalkan saat layar ditutup.
  Timer? _lanjutTimer;

  @override
  void initState() {
    super.initState();
    _game = BayanganGame(
      katalog: ref.read(katalogProvider),
      usia: ref.read(prefsProvider).ageLevel,
      random: ref.read(gameRandomProvider),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.bayangan);
      _say([_instLine()]);
      _say([_askLine(), _namaLine(_game.ronde.target)]);
    });
  }

  @override
  void dispose() {
    _lanjutTimer?.cancel();
    super.dispose();
  }

  String _nomorRonde() =>
      ref.read(mainYukRoundSeqProvider.notifier).next(MainYukGame.bayangan.id);

  String _nama(String id) {
    final item = ref.read(katalogProvider).byId(id);
    return item?.nama.of(ref.read(prefsProvider).lang) ?? id;
  }

  NarrationLine _instLine() =>
      barisUi('bayanganInst', context.l10n.bayanganInst);

  NarrationLine _askLine() => barisUi('bayanganAsk', context.l10n.bayanganAsk);

  NarrationLine _namaLine(String id) => barisNama(id, _nama(id));

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _tanya() => _say([_askLine()]);

  void _pilih(String id) {
    if (_game.pilih(id)) {
      ref.read(audioServiceProvider).playSfx(Sfx.benar);
      _say([
        barisUi('bayanganYes', context.l10n.bayanganYes),
        _namaLine(_game.ronde.target),
      ]);
      setState(() {});
      _lanjutTimer?.cancel();
      _lanjutTimer = Timer(_lanjutJeda, _lanjut);
      return;
    }
    // Ronde sudah terbuka: ketukan lain tidak diberi umpan balik.
    if (!_game.salah.contains(id)) return;
    ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
    _say([barisUi('bayanganNo', context.l10n.bayanganNo), _namaLine(id)]);
    setState(() {});
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
        gameId: MainYukGame.bayangan.id,
        roundId: _roundId,
        replayRoute: Routes.bayangan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ronde = _game.ronde;
    final nama = _nama(ronde.target);
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    final empat = ronde.pilihan.length > 3;
    final lebar = empat ? 200.0 : 230.0;
    final tinggi = empat ? 180.0 : 200.0;
    final jarak = empat ? 24.0 : 32.0;
    final lebarBaris =
        ronde.pilihan.length * lebar + (ronde.pilihan.length - 1) * jarak;
    return GameScaffold(
      theme: MenuTheme.bayangan,
      title: l10n.bayanganTitle,
      trailing: [_pilKemajuan(l10n, shadow)],
      children: [
        Positioned(
          left: 40,
          top: 120,
          width: 1100,
          height: 410,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: MociColors.white,
              borderRadius: const BorderRadius.all(Radius.circular(44)),
              boxShadow: [
                BoxShadow(color: shadow, offset: const Offset(0, 12)),
              ],
            ),
          ),
        ),
        _tombolTanya(l10n),
        Positioned(
          left: 390,
          top: 452,
          width: 320,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _ground,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Positioned(
          left: 400,
          top: 160,
          width: 300,
          height: 300,
          child: Opacity(
            opacity: 0.78,
            child: MociIllustration(
              ronde.target,
              key: BayanganScreen.targetKey,
              size: 300,
              silhouette: !_game.terbuka,
              semanticLabel: _game.terbuka ? nama : l10n.bayanganShadow,
            ),
          ),
        ),
        if (_game.terbuka) _pilNama(nama),
        for (var i = 0; i < ronde.pilihan.length; i++)
          Positioned(
            left: (1180 - lebarBaris) / 2 + i * (lebar + jarak),
            top: 566,
            child: _opsi(ronde.pilihan[i], lebar, tinggi),
          ),
      ],
    );
  }

  Widget _pilKemajuan(AppLocalizations l10n, Color shadow) => DecoratedBox(
    key: BayanganScreen.skorKey,
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
              l10n.bayanganProgress,
              style: MociText.label.copyWith(color: MociColors.inkSoft),
            ),
            const SizedBox(width: 14),
            ProgressDots(
              count: bayanganRonde,
              current: _game.skor,
              semanticLabel: l10n.bayanganProgress,
              activeColor: _accent,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tombolTanya(AppLocalizations l10n) => Positioned(
    left: 68,
    top: 146,
    width: 300,
    child: MociPressable(
      onTap: _tanya,
      semanticLabel: l10n.bayanganAsk,
      depth: 6,
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: _accent, shape: BoxShape.circle),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: GameGlyph(
                    GameGlyphKind.listen,
                    size: 30,
                    color: MociColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.bayanganAsk,
              textAlign: TextAlign.center,
              style: MociText.title.copyWith(fontSize: 34),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _pilNama(String nama) => Positioned(
    left: 740,
    top: 270,
    width: 360,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.correct,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: MociColors.correctShadow,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 84,
          child: Center(
            child: Text(
              nama,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: MociText.title.copyWith(
                fontSize: 34,
                color: MociColors.white,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _opsi(String id, double lebar, double tinggi) {
    final state = id == _game.ronde.target && _game.terbuka
        ? AnswerCardState.correct
        : _game.salah.contains(id)
        ? AnswerCardState.wrong
        : AnswerCardState.idle;
    return AnswerCard(
      key: BayanganScreen.pilihanKey(id),
      onTap: () => _pilih(id),
      illustration: id,
      semanticLabel: _nama(id),
      state: state,
      width: lebar,
      height: tinggi,
      illustrationSize: 150,
      accent: _accent,
    );
  }
}
