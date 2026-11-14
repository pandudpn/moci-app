import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/audio/sfx.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/game_mode_pill.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import 'musik_audio.dart';
import 'musik_lagu.dart';

enum MusikMode { xilofon, drum }

/// Main Musik: xilofon delapan nada dengan dua lagu dan drum empat bunyi.
class MusikScreen extends ConsumerStatefulWidget {
  const MusikScreen({super.key, this.awal, this.awalLagu});

  static const listenKey = ValueKey<String>('musik-listen');
  static const followKey = ValueKey<String>('musik-follow');
  static const beatKey = ValueKey<String>('musik-beat');

  static ValueKey<int> barKey(int nada) => ValueKey<int>(nada);

  static ValueKey<String> padKey(String nama) => ValueKey('musik-pad-$nama');

  static ValueKey<String> songKey(String id) => ValueKey('musik-song-$id');

  /// `?alat=xilofon|drum`; nilai tak dikenal jatuh ke xilofon.
  final String? awal;

  /// `?lagu=twinkle|mary`; nilai tak dikenal jatuh ke lagu pertama.
  final String? awalLagu;

  @override
  ConsumerState<MusikScreen> createState() => _MusikScreenState();
}

class _MusikScreenState extends ConsumerState<MusikScreen> {
  static const _accent = Color(0xFFF06595);
  static const _accentDark = Color(0xFFC2255C);
  static const _soft = Color(0xFFFFF0F6);
  static const _border = Color(0xFFF8C4D9);
  static const _label = Color(0xFFA6567A);
  static const _hint = Color(0xFF8A4D69);
  static const _rail = Color(0xFFC8875A);
  static const _railDark = Color(0xFF9C6239);

  static const _warnaBatang = [
    Color(0xFFFF6B6B),
    Color(0xFFFF922B),
    Color(0xFFFFD43B),
    Color(0xFF51CF66),
    Color(0xFF20C997),
    Color(0xFF339AF0),
    Color(0xFF5C7CFA),
    Color(0xFF9775FA),
  ];
  static const _gelapBatang = [
    Color(0xFFE03E3E),
    Color(0xFFE8590C),
    Color(0xFFF59F00),
    Color(0xFF2F9E44),
    Color(0xFF0CA678),
    Color(0xFF1971C2),
    Color(0xFF3B5BDB),
    Color(0xFF6741D9),
  ];
  static const _nadaNama = ['do', 're', 'mi', 'fa', 'sol', 'la', 'si', 'do'];

  late MusikMode _mode;
  late Lagu _lagu;
  late final MusikAudio _audio;
  final _timers = <Timer>[];
  bool _playing = false;
  bool _beating = false;
  IkutiLagu? _ikuti;
  Timer? _celeTimer;
  bool _cele = false;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(musikAudioProvider);
    _mode = widget.awal == 'drum' ? MusikMode.drum : MusikMode.xilofon;
    _lagu = daftarLagu.firstWhere(
      (l) => l.id == widget.awalLagu,
      orElse: () => daftarLagu.first,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_audio.preload());
      _catat();
    });
  }

  @override
  void dispose() {
    _batal();
    _celeTimer?.cancel();
    unawaited(_audio.berhenti());
    super.dispose();
  }

  void _catat() => ref.read(progressProvider.notifier).setLastActivity(
    Routes.musik,
    {'alat': _mode.name, 'lagu': _lagu.id},
  );

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);

  void _batal() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void _pilihMode(MusikMode m) {
    if (m == _mode) return;
    _batal();
    unawaited(_audio.berhenti());
    _celeTimer?.cancel();
    setState(() {
      _mode = m;
      _playing = false;
      _beating = false;
      _ikuti = null;
      _cele = false;
    });
    _catat();
  }

  void _pilihLagu(Lagu lagu) {
    _batal();
    unawaited(_audio.berhenti());
    _celeTimer?.cancel();
    setState(() {
      _lagu = lagu;
      _playing = false;
      _beating = false;
      _ikuti = null;
      _cele = false;
    });
    _catat();
  }

  void _dengar() {
    _batal();
    unawaited(_audio.berhenti());
    if (_playing) {
      setState(() => _playing = false);
      return;
    }
    setState(() {
      _playing = true;
      _ikuti = null;
      _cele = false;
    });
    final jadwal = jadwalLagu(_lagu);
    for (final nada in jadwal) {
      _timers.add(
        Timer(Duration(milliseconds: nada.ms), () {
          unawaited(_audio.bunyikan('xilo-${nada.nada + 1}'));
        }),
      );
    }
    _timers.add(
      Timer(Duration(milliseconds: jadwal.last.ms + 200), () {
        if (!mounted) return;
        setState(() => _playing = false);
      }),
    );
  }

  void _ikutiLagu() {
    if (_ikuti != null) {
      setState(() => _ikuti = null);
      return;
    }
    _batal();
    unawaited(_audio.berhenti());
    setState(() {
      _ikuti = IkutiLagu(_lagu);
      _playing = false;
      _cele = false;
    });
  }

  void _batang(int i) {
    unawaited(_audio.bunyikan('xilo-${i + 1}'));
    final ikuti = _ikuti;
    if (ikuti == null) return;
    if (!ikuti.cocok(i)) return;
    if (!ikuti.selesai) {
      setState(() {});
      return;
    }
    setState(() {
      _ikuti = null;
      _cele = true;
    });
    ref.read(audioServiceProvider).playSfx(Sfx.sorak);
    _say([
      NarrationLine(
        jenis: 'ui',
        id: 'musikSongDone',
        text: context.l10n.musikSongDone,
      ),
    ]);
    _celeTimer?.cancel();
    _celeTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() => _cele = false);
    });
  }

  void _ketukPad(String nama) => unawaited(_audio.bunyikan(nama));

  void _irama() {
    _batal();
    unawaited(_audio.berhenti());
    if (_beating) {
      setState(() => _beating = false);
      return;
    }
    setState(() {
      _beating = true;
      _playing = false;
    });
    final irama = iramaDrum();
    for (final ketuk in irama) {
      _timers.add(
        Timer(Duration(milliseconds: ketuk.ms), () {
          unawaited(_audio.bunyikan(ketuk.nama));
        }),
      );
    }
    _timers.add(
      Timer(Duration(milliseconds: irama.last.ms + 500), () {
        if (!mounted) return;
        setState(() => _beating = false);
      }),
    );
  }

  String _judulLagu(Lagu lagu, AppLocalizations l10n) => switch (lagu.id) {
    'twinkle' => l10n.musikTwinkle,
    'mary' => l10n.musikMary,
    _ => lagu.nama,
  };

  String _labelPad(String nama, AppLocalizations l10n) => switch (nama) {
    'drum-drum' => l10n.musikPadDrum,
    'drum-tepuk' => l10n.musikPadClap,
    'drum-simbal' => l10n.musikPadCymbal,
    _ => l10n.musikPadShaker,
  };

  @override
  Widget build(BuildContext context) {
    ref.watch(prefsProvider.select((p) => p.lang));
    return MociStage(theme: MenuTheme.musik, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.menuMusikTitle,
            trailing: [
              GameModePill(
                tabs: [
                  GameModeTab(label: l10n.musikXylophone),
                  GameModeTab(label: l10n.musikDrum),
                ],
                selected: _mode.index,
                onSelected: (i) => _pilihMode(MusikMode.values[i]),
                semanticLabel: l10n.musikModes,
                accent: _accent,
              ),
            ],
          ),
        ),
        if (_mode == MusikMode.xilofon) ...[
          Positioned(left: 40, top: 118, child: _barLagu(l10n)),
          Positioned(left: 40, top: 230, child: _papanXilo(l10n)),
        ] else
          Positioned(left: 40, top: 230, child: _papanDrum(l10n)),
      ],
    );
  }

  Widget _barLagu(AppLocalizations l10n) {
    final mengikuti = _ikuti != null;
    final labelIkuti = mengikuti
        ? l10n.musikFollowingCount(_ikuti!.posisi + 1, _lagu.nada.length)
        : l10n.musikFollow;
    return Container(
      width: 1100,
      height: 88,
      padding: const EdgeInsets.fromLTRB(26, 0, 16, 0),
      decoration: const BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
        boxShadow: [BoxShadow(color: _border, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Text(
            l10n.musikSongLabel,
            style: const TextStyle(
              fontFamily: MociFonts.nunito,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: 0.5,
              color: _label,
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            container: true,
            label: l10n.musikSongsLabel,
            child: Row(
              children: [
                for (var i = 0; i < daftarLagu.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _pilLagu(daftarLagu[i], l10n),
                ],
              ],
            ),
          ),
          const Spacer(),
          MociPressable(
            key: MusikScreen.listenKey,
            onTap: _dengar,
            color: _accent,
            shadowColor: _accentDark,
            depth: 6,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            semanticLabel: _playing ? l10n.musikStop : l10n.commonListen,
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _playing
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: MociColors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      : const GameGlyph(
                          GameGlyphKind.play,
                          size: 24,
                          color: MociColors.white,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    _playing ? l10n.musikStop : l10n.commonListen,
                    style: const TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                      color: MociColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          MociPressable(
            key: MusikScreen.followKey,
            onTap: _ikutiLagu,
            color: mengikuti ? MociColors.correct : MociColors.white,
            shadowColor: mengikuti ? MociColors.correctShadow : _border,
            depth: 6,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            semanticLabel: labelIkuti,
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: mengikuti ? null : Border.all(color: _border, width: 3),
              ),
              child: Center(
                child: Text(
                  labelIkuti,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: MociFonts.fredoka,
                    fontWeight: FontWeight.w600,
                    fontSize: 21,
                    color: mengikuti ? MociColors.white : MociColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilLagu(Lagu lagu, AppLocalizations l10n) {
    final aktif = lagu.id == _lagu.id;
    return MociPressable(
      key: MusikScreen.songKey(lagu.id),
      onTap: () => _pilihLagu(lagu),
      color: aktif ? MociColors.ink : _soft,
      shadowColor: aktif ? const Color(0xFF16112F) : _border,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      semanticLabel: _judulLagu(lagu, l10n),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              _judulLagu(lagu, l10n),
              maxLines: 1,
              style: TextStyle(
                fontFamily: MociFonts.fredoka,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: aktif ? MociColors.white : MociColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _papanXilo(AppLocalizations l10n) {
    final berikut = _ikuti?.berikut ?? -1;
    return Container(
      width: 1100,
      height: 562,
      decoration: const BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.all(Radius.circular(44)),
        boxShadow: [
          BoxShadow(color: _border, offset: Offset(0, 12)),
          BoxShadow(
            color: Color(0x142B2350),
            offset: Offset(0, 24),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _rel(136),
          _rel(398),
          for (var i = 0; i < 8; i++) _batangXilo(i, l10n),
          if (berikut >= 0)
            Positioned(
              left: _x(berikut) + 28,
              top: _y(berikut) - 54,
              child: Transform.rotate(
                angle: math.pi / 2,
                child: const GameGlyph(
                  GameGlyphKind.next,
                  size: 44,
                  color: MociColors.ink,
                ),
              ),
            ),
          if (_cele)
            Positioned(
              left: 290,
              top: 20,
              child: Container(
                width: 520,
                height: 70,
                decoration: BoxDecoration(
                  color: MociColors.ink,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GameGlyph(
                      GameGlyphKind.star,
                      size: 28,
                      color: MociColors.mociYellow,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        l10n.musikSongDone,
                        maxLines: 1,
                        style: const TextStyle(
                          fontFamily: MociFonts.fredoka,
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: MociColors.white,
                        ),
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

  Widget _rel(double atas) => Positioned(
    left: 44,
    right: 44,
    top: atas,
    height: 28,
    child: const DecoratedBox(
      decoration: BoxDecoration(
        color: _rail,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [BoxShadow(color: _railDark, offset: Offset(0, 6))],
      ),
    ),
  );

  double _x(int i) => 66 + i * 124;

  double _tinggi(int i) => 470 - i * 24;

  double _y(int i) => (562 - _tinggi(i)) / 2 - 6;

  Widget _batangXilo(int i, AppLocalizations l10n) {
    final tinggi = _tinggi(i);
    return Positioned(
      left: _x(i),
      top: _y(i),
      child: MociPressable(
        key: MusikScreen.barKey(i),
        onTap: () => _batang(i),
        color: _warnaBatang[i],
        shadowColor: _gelapBatang[i],
        depth: 10,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        semanticLabel: l10n.musikNote(_nadaNama[i], i + 1),
        child: SizedBox(
          width: 100,
          height: tinggi,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _titik(),
                  Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontFamily: MociFonts.nunito,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: MociColors.white,
                    ),
                  ),
                  Text(
                    _nadaNama[i],
                    style: const TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: MociColors.white,
                    ),
                  ),
                  _titik(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titik() => Container(
    width: 20,
    height: 20,
    decoration: const BoxDecoration(
      color: MociColors.white,
      shape: BoxShape.circle,
    ),
  );

  Widget _papanDrum(AppLocalizations l10n) {
    const pad = <(String, Color, Color)>[
      ('drum-drum', Color(0xFFFF6B6B), Color(0xFFE03E3E)),
      ('drum-tepuk', Color(0xFFFFB020), Color(0xFFE0870B)),
      ('drum-simbal', Color(0xFF339AF0), Color(0xFF1971C2)),
      ('drum-kerincing', Color(0xFF51CF66), Color(0xFF2F9E44)),
    ];
    return Container(
      width: 1100,
      height: 562,
      decoration: const BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.all(Radius.circular(44)),
        boxShadow: [
          BoxShadow(color: _border, offset: Offset(0, 12)),
          BoxShadow(
            color: Color(0x142B2350),
            offset: Offset(0, 24),
            blurRadius: 40,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 50,
            top: 90,
            child: Row(
              children: [
                for (var i = 0; i < pad.length; i++) ...[
                  if (i > 0) const SizedBox(width: 40),
                  _padDrum(pad[i], l10n),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 400,
            child: Column(
              children: [
                MociPressable(
                  key: MusikScreen.beatKey,
                  onTap: _irama,
                  color: MociColors.ink,
                  shadowColor: const Color(0xFF16112F),
                  depth: 8,
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  semanticLabel: _beating ? l10n.musikStop : l10n.musikBeat,
                  child: Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _beating
                            ? Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: MociColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              )
                            : const GameGlyph(
                                GameGlyphKind.play,
                                size: 28,
                                color: MociColors.white,
                              ),
                        const SizedBox(width: 12),
                        Text(
                          _beating ? l10n.musikStop : l10n.musikBeat,
                          style: const TextStyle(
                            fontFamily: MociFonts.fredoka,
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            color: MociColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 760,
                  child: Text(
                    l10n.musikDrumHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: MociFonts.nunito,
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                      height: 1.4,
                      color: _hint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _padDrum((String, Color, Color) data, AppLocalizations l10n) {
    final (nama, warna, gelap) = data;
    final label = _labelPad(nama, l10n);
    return MociPressable(
      key: MusikScreen.padKey(nama),
      onTap: () => _ketukPad(nama),
      color: warna,
      shadowColor: gelap,
      depth: 12,
      borderRadius: const BorderRadius.all(Radius.circular(56)),
      semanticLabel: label,
      child: SizedBox(
        width: 240,
        height: 300,
        child: ExcludeSemantics(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: Color(0x47FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    label.characters.first,
                    style: const TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontWeight: FontWeight.w700,
                      fontSize: 72,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                  color: MociColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
