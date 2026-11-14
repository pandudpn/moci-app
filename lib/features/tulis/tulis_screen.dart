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
import '../../core/content/angka_kata.dart';
import '../../core/content/content_repository.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/route_mode_pill.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'tracing_board.dart';
import 'tulis_keys.dart';

export 'tulis_keys.dart';

/// Layar Tulis Huruf dan Tulis Angka: satu papan tracing, kisi kunci,
/// krayon, dan bintang untuk kunci yang sudah ditulis.
class TulisScreen extends ConsumerStatefulWidget {
  const TulisScreen({super.key, this.mode = TulisMode.huruf, this.awal});

  static ValueKey<String> keyKey(String k) => ValueKey('tulis-key-$k');

  final TulisMode mode;

  /// Kunci pertama saat layar dibuka; nilai di luar kisi diabaikan.
  final String? awal;

  @override
  ConsumerState<TulisScreen> createState() => _TulisScreenState();
}

class _TulisScreenState extends ConsumerState<TulisScreen> {
  static const _accent = Color(0xFFE8384F);
  static const _accentShadow = Color(0xFFB82A3E);
  static const _soft = Color(0xFFFFF1EC);
  static const _softShadow = Color(0xFFF3C2B3);
  static const _boardScale = 540 / 520;

  late final TulisKeySpec _spec;
  late String _k;
  int _run = 0;
  int _crayon = 0;
  int _goresan = 0;
  bool _selesai = false;

  bool get _angka => widget.mode == TulisMode.angka;

  String get _modul => _angka ? 'angka' : 'huruf';

  @override
  void initState() {
    super.initState();
    _spec = TulisKeySpec.of(widget.mode);
    _k = _spec.keys.contains(widget.awal) ? widget.awal! : _spec.keys.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catatAktivitas();
      _sayStart();
    });
  }

  void _catatAktivitas() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.hurufTulis, {
      'huruf': _k,
    });
  }

  NarrationLine _startLine() => NarrationLine(
    jenis: 'ui',
    id: _angka ? 'tulisSayStartAngka' : 'tulisSayStartHuruf',
    text: _angka
        ? context.l10n.tulisSayStartAngka
        : context.l10n.tulisSayStartHuruf,
  );

  NarrationLine _itemLine() {
    final lang = ref.read(prefsProvider).lang;
    if (_angka) {
      return NarrationLine(
        jenis: 'angka',
        id: _k,
        text: angkaKata(int.parse(_k), lang),
      );
    }
    final entry = ref
        .read(katalogProvider)
        .huruf
        .firstWhere(
          (h) => h.huruf == _k,
          orElse: () => ref.read(katalogProvider).huruf.first,
        );
    return NarrationLine(
      jenis: 'huruf',
      id: _k.toLowerCase(),
      text: entry.of(lang).nama,
    );
  }

  void _say(List<NarrationLine> lines) {
    ref.read(narratorProvider).sayAll(lines, ref.read(prefsProvider).lang);
  }

  void _sayStart() => _say([_startLine(), _itemLine()]);

  void _sayDone() => _say([
    NarrationLine(
      jenis: 'ui',
      id: _angka ? 'tulisSayDoneAngka' : 'tulisSayDoneHuruf',
      text: _angka
          ? context.l10n.tulisSayDoneAngka
          : context.l10n.tulisSayDoneHuruf,
    ),
    _itemLine(),
  ]);

  void _sayListen() => _say([
    _startLine(),
    _itemLine(),
    NarrationLine(jenis: 'ui', id: 'tulisHint', text: context.l10n.tulisHint),
  ]);

  void _pick(String k) {
    if (k != _k) {
      setState(() {
        _k = k;
        _run++;
        _goresan = 0;
        _selesai = false;
      });
    } else {
      setState(() {
        _run++;
        _goresan = 0;
        _selesai = false;
      });
    }
    _catatAktivitas();
    _sayStart();
  }

  void _ulang() {
    setState(() {
      _run++;
      _goresan = 0;
      _selesai = false;
    });
    _sayStart();
  }

  void _lanjut() {
    final keys = _spec.keys;
    final i = keys.indexOf(_k);
    setState(() {
      _k = keys[(i + 1) % keys.length];
      _run++;
      _goresan = 0;
      _selesai = false;
    });
    _catatAktivitas();
    _sayStart();
  }

  void _done() {
    if (_selesai) return;
    setState(() => _selesai = true);
    ref.read(progressProvider.notifier).markItem(_modul, 'ditulis', _k);
    ref.read(audioServiceProvider).playSfx(Sfx.sorak);
    _sayDone();
  }

  void _progress(int goresan, int total) {
    if (!mounted || goresan == _goresan) return;
    setState(() => _goresan = goresan);
  }

  @override
  Widget build(BuildContext context) {
    return MociStage(
      theme: _angka ? MenuTheme.berhitung : MenuTheme.huruf,
      tablet: (context) => _tablet(context),
    );
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    final tracing = ref.watch(
      _angka ? tracingAngkaProvider : tracingHurufProvider,
    );
    final paths = tracing.of(_k);
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: _angka ? l10n.menuAngkaTitle : l10n.hurufTitle,
            trailing: [
              RouteModePill(
                tabs: _tabs(l10n),
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(
          left: 32,
          top: 120,
          child: _card(
            width: 236,
            height: 650,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: Column(
                children: [
                  Text(
                    _angka ? l10n.tulisPickAngka : l10n.tulisPickHuruf,
                    style: MociText.label.copyWith(
                      fontSize: 17,
                      color: MociColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _keyGrid(l10n),
                  const Spacer(),
                  Text(
                    l10n.tulisFollow,
                    textAlign: TextAlign.center,
                    style: MociText.label.copyWith(
                      fontSize: 15,
                      height: 1.25,
                      color: MociColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 290,
          top: 120,
          child: _card(
            width: 600,
            height: 650,
            radius: 40,
            depth: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 30,
                  right: 30,
                  top: 20,
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${l10n.tulisWriteVerb} $_k',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MociText.title.copyWith(
                            fontSize: 30,
                            color: MociColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        '${l10n.tulisLine} '
                        '${l10n.tulisProgress(_goresan + 1, paths.length)}',
                        style: MociText.label.copyWith(
                          fontSize: 18,
                          color: MociColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 30,
                  top: 78,
                  width: 540,
                  height: 540,
                  child: Transform.scale(
                    scale: _boardScale,
                    alignment: Alignment.topLeft,
                    child: TracingBoard(
                      key: ValueKey('$_k-$_run'),
                      paths: paths,
                      ink: tulisCrayons[_crayon],
                      semanticLabel: _angka
                          ? l10n.tulisAreaLabelAngka(_k)
                          : l10n.tulisAreaLabel(_k),
                      onDone: _done,
                      onProgress: _progress,
                    ),
                  ),
                ),
                if (_selesai)
                  Positioned(
                    left: 24,
                    top: 516,
                    width: 552,
                    height: 112,
                    child: _doneBar(l10n),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 912,
          top: 120,
          child: _card(
            width: 236,
            height: 650,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 22,
                  child: Text(
                    l10n.tulisCrayons,
                    textAlign: TextAlign.center,
                    style: MociText.label.copyWith(
                      fontSize: 18,
                      color: MociColors.inkSoft,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 60,
                  child: Column(
                    children: [
                      for (var i = 0; i < tulisCrayons.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _swatch(l10n, i),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 30,
                  right: 30,
                  top: 462,
                  height: 3,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: _soft),
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 486,
                  child: _sideButton(
                    icon: GameGlyphKind.refresh,
                    label: l10n.tulisAgain,
                    onTap: _ulang,
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 562,
                  child: _sideButton(
                    icon: GameGlyphKind.listen,
                    label: l10n.tulisListen,
                    color: const Color(0xFFFFB020),
                    shadowColor: const Color(0xFFE0870B),
                    onTap: _sayListen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<({String label, String route, Widget? icon})> _tabs(
    AppLocalizations l10n,
  ) {
    if (_angka) {
      return [
        (
          label: l10n.menuAngkaTitle,
          route: Routes.angka,
          icon: const GameGlyph(GameGlyphKind.count),
        ),
        (
          label: l10n.hurufWrite,
          route: Routes.angkaTulis,
          icon: const GameGlyph(GameGlyphKind.pencil),
        ),
      ];
    }
    return [
      (
        label: l10n.hurufLearn,
        route: Routes.huruf,
        icon: const GameGlyph(GameGlyphKind.eye),
      ),
      (
        label: l10n.hurufWrite,
        route: Routes.hurufTulis,
        icon: const GameGlyph(GameGlyphKind.pencil),
      ),
      (
        label: l10n.hurufSay,
        route: Routes.hurufUcapkan,
        icon: const GameGlyph(GameGlyphKind.mic),
      ),
    ];
  }

  Widget _card({
    required Widget child,
    double? width,
    double? height,
    double radius = 36,
    double depth = 10,
  }) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [BoxShadow(color: shadow, offset: Offset(0, depth))],
      ),
      child: child,
    );
  }

  Widget _keyGrid(AppLocalizations l10n) {
    final done =
        ref.watch(progressProvider).perkembangan[_modul]?['ditulis'] ??
        const <String>[];
    final rows = <Widget>[];
    for (var i = 0; i < _spec.keys.length; i += _spec.columns) {
      final slice = _spec.keys.sublist(
        i,
        math.min(i + _spec.columns, _spec.keys.length),
      );
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        Row(
          children: [
            for (var j = 0; j < _spec.columns; j++) ...[
              if (j > 0) const SizedBox(width: 8),
              Expanded(
                child: j < slice.length
                    ? _keyButton(l10n, slice[j], done.contains(slice[j]))
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _keyButton(AppLocalizations l10n, String k, bool done) {
    final on = k == _k;
    return SizedBox(
      height: _spec.keyHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: MociPressable(
              key: TulisScreen.keyKey(k),
              onTap: () => _pick(k),
              color: on ? _accent : _soft,
              shadowColor: _softShadow,
              depth: 5,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              semanticLabel: _angka
                  ? l10n.tulisKeyLabelAngka(k)
                  : l10n.tulisKeyLabel(k),
              child: Center(
                child: Text(
                  k,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: _spec.fontSize,
                    fontWeight: FontWeight.w700,
                    color: on ? MociColors.white : MociColors.ink,
                  ),
                ),
              ),
            ),
          ),
          if (done)
            const Positioned(
              right: -4,
              top: -6,
              child: GameGlyph(GameGlyphKind.star, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _swatch(AppLocalizations l10n, int i) {
    final on = i == _crayon;
    final labels = [
      l10n.tulisColor1,
      l10n.tulisColor2,
      l10n.tulisColor3,
      l10n.tulisColor4,
      l10n.tulisColor5,
    ];
    return MociPressable(
      onTap: () => setState(() => _crayon = i),
      color: tulisCrayons[i],
      shadowColor: MociColors.ink.withValues(alpha: 0.18),
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      semanticLabel: labels[i],
      minTouch: 64,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: on ? MociColors.ink : MociColors.white,
            width: 5,
          ),
        ),
      ),
    );
  }

  Widget _sideButton({
    required GameGlyphKind icon,
    required String label,
    required VoidCallback onTap,
    Color color = _soft,
    Color shadowColor = _softShadow,
  }) {
    return MociPressable(
      onTap: onTap,
      color: color,
      shadowColor: shadowColor,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      semanticLabel: label,
      child: SizedBox(
        width: 180,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameGlyph(icon, size: 26),
            const SizedBox(width: 8),
            Text(label, style: MociText.button.copyWith(fontSize: 22)),
          ],
        ),
      ),
    );
  }

  Widget _doneBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color:
                MenuThemeScope.maybeOf(context)?.shadow ??
                MociColors.neutralShadow,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          const GameGlyph(GameGlyphKind.star, size: 40),
          const SizedBox(width: 2),
          const GameGlyph(GameGlyphKind.star, size: 52),
          const SizedBox(width: 2),
          const GameGlyph(GameGlyphKind.star, size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.tulisGreat,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MociText.title.copyWith(fontSize: 36, color: _accent),
            ),
          ),
          MociPressable(
            onTap: _ulang,
            color: _soft,
            shadowColor: _softShadow,
            depth: 5,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            semanticLabel: l10n.tulisWriteAgain,
            minTouch: 64,
            child: const SizedBox(
              width: 64,
              height: 64,
              child: Center(child: GameGlyph(GameGlyphKind.refresh, size: 32)),
            ),
          ),
          const SizedBox(width: 14),
          MociPressable(
            onTap: _lanjut,
            color: _accent,
            shadowColor: _accentShadow,
            depth: 6,
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            semanticLabel: l10n.tulisNext,
            minTouch: 64,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.tulisNext,
                      style: MociText.button.copyWith(color: MociColors.white),
                    ),
                    const SizedBox(width: 6),
                    const GameGlyph(
                      GameGlyphKind.next,
                      size: 26,
                      color: MociColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
