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
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/pressable.dart';
import '../hadiah/main_lagi.dart';
import 'game_scaffold.dart';
import 'main_yuk_game.dart';
import 'memori_game.dart';

const _accent = Color(0xFF3B5BDB);
const _openBorder = Color(0xFFD3E3FF);
const _flip = Duration(milliseconds: 300);
const _tutupJeda = Duration(milliseconds: 950);

/// Tengah kisi kartu; kisi selalu empat kolom.
const _kisiTengah = 590.0;
const _kisiAtas = 188.0;

/// Kartu Memori: buka dua kartu dan temukan pasangan gambarnya.
class MemoriScreen extends ConsumerStatefulWidget {
  const MemoriScreen({super.key});

  static const restartKey = ValueKey('memori-restart');
  static const langkahKey = ValueKey('memori-langkah');

  static ValueKey<int> kartuKey(int i) => ValueKey(i);

  static ValueKey<MainYukTema> temaKey(MainYukTema t) => ValueKey(t);

  @override
  ConsumerState<MemoriScreen> createState() => _MemoriScreenState();
}

class _MemoriScreenState extends ConsumerState<MemoriScreen>
    with MainLagi<MemoriScreen> {
  MainYukTema _tema = MainYukTema.hewan;
  late int _pasangan;
  late MemoriSesi _sesi;
  late String _roundId;
  bool _selesai = false;

  /// Penutup dua kartu salah; dibatalkan saat ronde berganti atau layar tutup.
  Timer? _tutupTimer;

  @override
  void initState() {
    super.initState();
    _pasangan = memoriPasangan(ref.read(prefsProvider).ageLevel);
    _rondeBaru(tema: _tema);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Nomor ronde tidak boleh mengubah provider saat pohon sedang dibangun.
      _roundId = _nomorRonde();
      ref.read(progressProvider.notifier).setLastActivity(Routes.memori);
      _say([_instLine()]);
      _say([_temaLine()]);
    });
  }

  @override
  void dispose() {
    _tutupTimer?.cancel();
    super.dispose();
  }

  ({double w, double h, double gap}) get _ukuran => switch (_pasangan) {
    4 => (w: 210.0, h: 230.0, gap: 20.0),
    6 => (w: 190.0, h: 186.0, gap: 20.0),
    _ => (w: 146.0, h: 140.0, gap: 16.0),
  };

  void _rondeBaru({required MainYukTema tema, MainYukTema? sebelumnya}) {
    _tutupTimer?.cancel();
    _sesi = MemoriSesi(
      buatMemori(
        ref.read(katalogProvider),
        pasangan: _pasangan,
        tema: tema,
        random: ref.read(gameRandomProvider),
        sebelumnya: sebelumnya,
      ),
    );
    _selesai = false;
  }

  String _nomorRonde() =>
      ref.read(mainYukRoundSeqProvider.notifier).next(MainYukGame.memori.id);

  void _mulaiRonde({required MainYukTema tema, MainYukTema? sebelumnya}) {
    _rondeBaru(tema: tema, sebelumnya: sebelumnya);
    _roundId = _nomorRonde();
  }

  void _gantiPasangan(int n) {
    setState(() {
      _pasangan = n;
      _mulaiRonde(tema: _tema);
    });
  }

  void _gantiTema(MainYukTema tema) {
    setState(() {
      final sebelumnya = _sesi.ronde.tema;
      _tema = tema;
      _mulaiRonde(
        tema: tema,
        sebelumnya: tema == MainYukTema.acak ? sebelumnya : null,
      );
    });
  }

  void _gambarBaru() {
    setState(() {
      _mulaiRonde(tema: _tema, sebelumnya: _sesi.ronde.tema);
    });
  }

  NarrationLine _instLine() => barisUi('memoriInst', context.l10n.memoriInst);

  NarrationLine _temaLine() =>
      barisUi(_tema.labelKey, _tema.label(context.l10n));

  String _namaItem(String id) {
    final item = ref.read(katalogProvider).byId(id);
    return item?.nama.of(ref.read(prefsProvider).lang) ?? id;
  }

  NarrationLine _namaLine(int i) {
    final id = _sesi.ronde.deck[i];
    return barisNama(id, _namaItem(id));
  }

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _buka(int i) {
    final step = _sesi.buka(i);
    switch (step) {
      case MemoriStep.abaikan:
        return;
      case MemoriStep.terbuka:
        _say([_namaLine(i)]);
        setState(() {});
      case MemoriStep.sepasang:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([_namaLine(i), _pasanganLine()]);
        setState(() {});
      case MemoriStep.selesai:
        ref.read(audioServiceProvider).playSfx(Sfx.benar);
        _say([_namaLine(i), _pasanganLine()]);
        setState(() {});
        _selesaikanRonde();
      case MemoriStep.salah:
        ref.read(audioServiceProvider).playSfx(Sfx.salahLembut);
        _tutupTimer?.cancel();
        _tutupTimer = Timer(_tutupJeda, () {
          if (!mounted) return;
          setState(_sesi.tutup);
        });
        setState(() {});
    }
  }

  NarrationLine _pasanganLine() =>
      barisUi('memoriPair', context.l10n.memoriPair);

  void _selesaikanRonde() {
    if (_selesai) return;
    _selesai = true;
    unawaited(
      selesaikanRonde(
        context,
        ref,
        gameId: MainYukGame.memori.id,
        roundId: _roundId,
        replayRoute: Routes.memori,
      ),
    );
  }

  @override
  String get ruteMainLagi => Routes.memori;

  @override
  void mulaiUlang() => setState(() => _mulaiRonde(tema: _tema));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GameScaffold(
      theme: MenuTheme.memori,
      title: l10n.memoriTitle,
      trailing: [
        GameModePill(
          tabs: [
            for (final n in const [4, 6, 8])
              GameModeTab(label: l10n.mainYukPairs(n)),
          ],
          selected: _pasangan ~/ 2 - 2,
          onSelected: (i) => _gantiPasangan((i + 2) * 2),
          semanticLabel: l10n.gameLevel,
          accent: _accent,
        ),
        _pilLangkah(l10n),
        MociPressable(
          key: MemoriScreen.restartKey,
          onTap: _gambarBaru,
          semanticLabel: l10n.memoriRestart,
          depth: 6,
          borderRadius: const BorderRadius.all(Radius.circular(22)),
          minTouch: 64,
          child: const SizedBox(
            width: 64,
            height: 64,
            child: Center(child: GameGlyph(GameGlyphKind.refresh, size: 30)),
          ),
        ),
      ],
      children: [
        _barisTema(l10n),
        for (var i = 0; i < _sesi.ronde.deck.length; i++) _kartu(i),
      ],
    );
  }

  Widget _pilLangkah(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return DecoratedBox(
      key: MemoriScreen.langkahKey,
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
              l10n.mainYukMoves(_sesi.langkah),
              style: MociText.label.copyWith(color: MociColors.ink),
            ),
          ),
        ),
      ),
    );
  }

  Widget _barisTema(AppLocalizations l10n) {
    return Positioned(
      left: 32,
      right: 32,
      top: 116,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.memoriTema, style: MociText.label.copyWith(color: _accent)),
          const SizedBox(width: 16),
          for (final tema in MainYukTema.pilihan) ...[
            MociPressable(
              key: MemoriScreen.temaKey(tema),
              onTap: () => _gantiTema(tema),
              semanticLabel: tema.label(l10n),
              color: _tema == tema ? _accent : MociColors.white,
              depth: 5,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              minTouch: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      tema.label(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MociText.label.copyWith(
                        color: _tema == tema
                            ? MociColors.white
                            : MociColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (tema != MainYukTema.pilihan.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _kartu(int i) {
    final id = _sesi.ronde.deck[i];
    final ukuran = _ukuran;
    final kolom = i % 4;
    final baris = i ~/ 4;
    final lebarKisi = 4 * ukuran.w + 3 * ukuran.gap;
    final kiri = _kisiTengah - lebarKisi / 2 + kolom * (ukuran.w + ukuran.gap);
    final atas = _kisiAtas + baris * (ukuran.h + ukuran.gap);
    final terbuka = _sesi.terbuka.contains(i) || _sesi.ketemu.contains(id);
    return Positioned(
      left: kiri,
      top: atas,
      width: ukuran.w,
      height: ukuran.h,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: terbuka ? 1 : 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : _flip,
        builder: (context, t, _) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values((t - 0.5).abs() * 2, 1, 1),
          child: _mukaKartu(i, id, terbuka, ukuran),
        ),
      ),
    );
  }

  Widget _mukaKartu(
    int i,
    String id,
    bool terlihat,
    ({double w, double h, double gap}) ukuran,
  ) {
    final l10n = context.l10n;
    final warna = _warnaTema(_sesi.ronde.tema);
    final ketemu = _sesi.ketemu.contains(id);
    return MociPressable(
      key: MemoriScreen.kartuKey(i),
      onTap: () => _buka(i),
      semanticLabel: terlihat ? _namaItem(id) : l10n.memoriHidden,
      color: warna.face,
      shadowColor: warna.shadow,
      depth: 8,
      borderRadius: const BorderRadius.all(Radius.circular(26)),
      child: Container(
        decoration: BoxDecoration(
          color: terlihat ? MociColors.white : null,
          borderRadius: const BorderRadius.all(Radius.circular(26)),
          border: terlihat
              ? Border.all(
                  color: ketemu ? MociColors.correct : _openBorder,
                  width: 6,
                )
              : null,
        ),
        child: Center(
          child: terlihat
              ? MociIllustration(
                  id,
                  size: (ukuran.w < ukuran.h ? ukuran.w : ukuran.h) * 0.66,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [_Titik(), SizedBox(width: 12), _Titik()],
                ),
        ),
      ),
    );
  }
}

/// Dua titik putih penanda kartu tertutup.
class _Titik extends StatelessWidget {
  const _Titik();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(color: MociColors.white, shape: BoxShape.circle),
    child: SizedBox(width: 16, height: 16),
  );
}

/// Warna muka kartu per tema; ronde selalu menyimpan tema terpilih, `acak`
/// hanya jaring pengaman.
({Color face, Color shadow}) _warnaTema(MainYukTema tema) => switch (tema) {
  MainYukTema.buah => (
    face: const Color(0xFFFF6B6B),
    shadow: const Color(0xFFE04848),
  ),
  MainYukTema.sayur => (
    face: const Color(0xFF5FD068),
    shadow: const Color(0xFF3BAA45),
  ),
  MainYukTema.kendaraan => (
    face: const Color(0xFF3BA4FF),
    shadow: const Color(0xFF1C7ED6),
  ),
  MainYukTema.benda => (
    face: const Color(0xFF9775FA),
    shadow: const Color(0xFF7048E8),
  ),
  MainYukTema.acak || MainYukTema.hewan => (
    face: const Color(0xFF22C1C3),
    shadow: const Color(0xFF129A9C),
  ),
};
