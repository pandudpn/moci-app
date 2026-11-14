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
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/app_prefs.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/route_mode_pill.dart';
import '../../widgets/game/ring_pulse.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';

/// Layar Kenal Huruf: huruf besar-kecil, contoh kata bergambar, dua pil
/// cara baca, dan kisi A–Z.
class HurufScreen extends ConsumerStatefulWidget {
  const HurufScreen({super.key, this.awal});

  static const letterKey = ValueKey<String>('huruf-letter');
  static const wordKey = ValueKey<String>('huruf-word');
  static const alphabetKey = ValueKey<String>('huruf-alphabet');
  static const listenKey = ValueKey<String>('huruf-listen');
  static const prevKey = ValueKey<String>('huruf-prev');
  static const nextKey = ValueKey<String>('huruf-next');

  static ValueKey<String> alphabetCellKey(String huruf) =>
      ValueKey('huruf-cell-$huruf');

  /// Huruf pertama saat layar dibuka; nilai di luar A–Z diabaikan.
  final String? awal;

  @override
  ConsumerState<HurufScreen> createState() => _HurufScreenState();
}

class _HurufScreenState extends ConsumerState<HurufScreen>
    with TickerProviderStateMixin {
  static const _accent = Color(0xFFE8384F);
  static const _accentShadow = Color(0xFFB82A3E);
  static const _soft = Color(0xFFFFF1EC);
  static const _softShadow = Color(0xFFF3C2B3);

  late String _k;
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _popScale = CurvedAnimation(
    parent: _pop,
    curve: const Cubic(0.3, 1.6, 0.5, 1),
  );

  List<HurufEntry> get _daftar => ref.read(katalogProvider).huruf;

  int get _idx => _daftar.indexWhere((h) => h.huruf == _k);

  HurufEntry get _entry => _daftar[_idx < 0 ? 0 : _idx];

  AppLang get _lang => ref.read(prefsProvider).lang;

  HurufBahasa get _bahasa => _entry.of(_lang);

  @override
  void initState() {
    super.initState();
    final awal = widget.awal?.toUpperCase();
    _k = awal != null && _hurufAwal(awal) ? awal : 'A';
    // Huruf langsung tampil penuh; pop hanya saat huruf berganti.
    _pop.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _sayAll();
    });
  }

  bool _hurufAwal(String k) => RegExp(r'^[A-Z]$').hasMatch(k);

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _catat() {
    ref.read(progressProvider.notifier).markItem('huruf', 'dibaca', _k);
    ref.read(progressProvider.notifier).setLastActivity(Routes.huruf, {
      'huruf': _k,
    });
  }

  NarrationLine _modeLine() =>
      ref.read(prefsProvider).letterMode == LetterMode.fonik
      ? NarrationLine(jenis: 'fonik', id: _k.toLowerCase(), text: _bahasa.bunyi)
      : NarrationLine(jenis: 'huruf', id: _k.toLowerCase(), text: _bahasa.nama);

  NarrationLine _wordLine() =>
      NarrationLine(jenis: 'contoh', id: _k.toLowerCase(), text: _bahasa.kata);

  void _say(List<NarrationLine> lines) =>
      ref.read(narratorProvider).sayAll(lines, _lang);

  void _sayAll() => _say([_modeLine(), _wordLine()]);

  /// Suara pil bunyi selalu bunyi, pil nama selalu nama, apa pun cara baca
  /// yang dipilih orang tua.
  void _saySound() => _say([
    NarrationLine(jenis: 'fonik', id: _k.toLowerCase(), text: _bahasa.bunyi),
  ]);

  void _sayName() => _say([
    NarrationLine(jenis: 'huruf', id: _k.toLowerCase(), text: _bahasa.nama),
  ]);

  void _pilih(String k) {
    if (k == _k) return;
    setState(() => _k = k);
    _pop.forward(from: 0);
    _catat();
    _sayAll();
  }

  void _geser(int arah) {
    final list = _daftar;
    final i = (_idx + arah) % list.length;
    _pilih(list[i < 0 ? i + list.length : i].huruf);
  }

  @override
  Widget build(BuildContext context) {
    // Teks, contoh kata, locale, dan narasi ikut bahasa baru tanpa memulai
    // ulang aplikasi.
    ref.listen(prefsProvider.select((p) => p.lang), (_, _) => _sayAll());
    ref.watch(prefsProvider.select((p) => p.lang));
    return MociStage(theme: MenuTheme.huruf, tablet: _tablet);
  }

  Widget _tablet(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MociTopBar(
            leading: const MociBackButton(),
            title: l10n.hurufTitle,
            trailing: [
              RouteModePill(
                tabs: [
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
                ],
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(left: 170, top: 134, child: _card(l10n)),
        Positioned(
          left: 48,
          top: 296,
          child: _arrow(
            key: HurufScreen.prevKey,
            label: l10n.hurufPrev,
            arah: -1,
          ),
        ),
        Positioned(
          left: 1036,
          top: 296,
          child: _arrow(
            key: HurufScreen.nextKey,
            label: l10n.hurufNext,
            arah: 1,
          ),
        ),
        Positioned(left: 178, top: 630, width: 824, child: _alphabet(l10n)),
        Positioned(left: 14, top: 664, child: const MociMascot(size: 150)),
      ],
    );
  }

  Widget _card(AppLocalizations l10n) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return Container(
      width: 840,
      height: 420,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 14))],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 30,
            top: 22,
            child: Text(
              '${_idx + 1} / ${_daftar.length}',
              style: MociText.label.copyWith(color: MociColors.inkSoft),
            ),
          ),
          Positioned(
            left: 24,
            top: 14,
            width: 390,
            height: 266,
            child: _letter(l10n),
          ),
          Positioned(left: 34, top: 288, width: 370, child: _pills(l10n)),
          Positioned(
            left: 420,
            top: 50,
            width: 4,
            height: 290,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFE3DA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 436,
            top: 18,
            width: 380,
            height: 346,
            child: _word(l10n),
          ),
          Positioned(
            left: 370,
            top: 370,
            width: 100,
            height: 100,
            child: RingPulse(
              size: 100,
              color: const Color(0xFFFFB020),
              child: MociPressable(
                key: HurufScreen.listenKey,
                onTap: _sayAll,
                color: const Color(0xFFFFB020),
                shadowColor: const Color(0xFFE0870B),
                depth: 8,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                semanticLabel: l10n.hurufListen,
                minTouch: 64,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: GameGlyph(GameGlyphKind.listen, size: 52),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _letter(AppLocalizations l10n) {
    final petunjuk = ref.watch(
      prefsProvider.select(
        (p) => p.letterMode == LetterMode.fonik
            ? l10n.hurufTapHint
            : l10n.hurufTapHintName,
      ),
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1).animate(_popScale),
      child: MociPressable(
        key: HurufScreen.letterKey,
        onTap: () => _say([_modeLine()]),
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        depth: 0,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        semanticLabel: l10n.hurufLetterLabel(_k, petunjuk),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _k,
                style: TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontSize: 196,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: _accent,
                  shadows: const [
                    Shadow(color: Color(0xFFFFD0C4), offset: Offset(0, 10)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 42),
                child: Text(
                  _k.toLowerCase(),
                  style: const TextStyle(
                    fontFamily: MociFonts.fredoka,
                    fontSize: 150,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Color(0xFF1C8CF0),
                    shadows: [
                      Shadow(color: Color(0xFFCFE6FF), offset: Offset(0, 8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pills(AppLocalizations l10n) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(
            color: const Color(0xFFFFE3DA),
            shadow: _softShadow,
            fg: const Color(0xFFA61E33),
            label: l10n.hurufSound,
            value: _bahasa.bunyi,
            semanticLabel: l10n.hurufSoundAria(_k, _bahasa.bunyi),
            onTap: _saySound,
          ),
          const SizedBox(width: 12),
          _pill(
            color: const Color(0xFFE7F3FF),
            shadow: const Color(0xFFB7D7F7),
            fg: const Color(0xFF1265B5),
            label: l10n.hurufName,
            value: _bahasa.nama,
            semanticLabel: l10n.hurufNameAria(_k),
            onTap: _sayName,
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required Color color,
    required Color shadow,
    required Color fg,
    required String label,
    required String value,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    return MociPressable(
      onTap: onTap,
      color: color,
      shadowColor: shadow,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      semanticLabel: semanticLabel,
      minTouch: 54,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 18, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GameGlyph(GameGlyphKind.listen, size: 24, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: MociText.button.copyWith(fontSize: 22, color: fg),
              ),
              Text(
                ' $value',
                style: MociText.button.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _word(AppLocalizations l10n) {
    final kata = _bahasa.kata;
    final at = kata.toLowerCase().indexOf(_k.toLowerCase());
    final i = at < 0 ? 0 : at;
    final size = kata.length > 9
        ? 44.0
        : kata.length > 6
        ? 54.0
        : 66.0;
    return MociPressable(
      key: HurufScreen.wordKey,
      onTap: () => _say([_wordLine()]),
      color: const Color(0x00000000),
      shadowColor: const Color(0x00000000),
      depth: 0,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      semanticLabel: kata,
      child: Stack(
        children: [
          Positioned(
            left: 60,
            top: 10,
            width: 260,
            height: 260,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _soft,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 70,
            top: 6,
            width: 240,
            height: 240,
            child: _Bob(child: MociIllustration(_bahasa.gambar, size: 240)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 264,
            height: 82,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: kata.substring(0, i)),
                    TextSpan(
                      text: kata.substring(i, i + 1),
                      style: const TextStyle(color: _accent),
                    ),
                    TextSpan(text: kata.substring(i + 1)),
                  ],
                ),
                maxLines: 1,
                style: TextStyle(
                  fontFamily: MociFonts.fredoka,
                  fontSize: size,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: MociColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow({required Key key, required String label, required int arah}) {
    return MociPressable(
      key: key,
      onTap: () => _geser(arah),
      color: MociColors.white,
      depth: 8,
      borderRadius: const BorderRadius.all(Radius.circular(48)),
      semanticLabel: label,
      minTouch: 96,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Center(
          child: Transform.rotate(
            angle: arah < 0 ? math.pi : 0,
            child: const GameGlyph(
              GameGlyphKind.next,
              size: 44,
              color: _accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _alphabet(AppLocalizations l10n) {
    final list = _daftar;
    return Semantics(
      container: true,
      label: l10n.hurufGridLabel,
      child: Column(
        key: HurufScreen.alphabetKey,
        children: [
          for (var baris = 0; baris < 2; baris++) ...[
            if (baris > 0) const SizedBox(height: 10),
            Row(
              children: [
                for (var kol = 0; kol < 13; kol++) ...[
                  if (kol > 0) const SizedBox(width: 8),
                  SizedBox(
                    width: 56,
                    height: 54,
                    child: kol + baris * 13 < list.length
                        ? _letterCell(l10n, list[kol + baris * 13].huruf)
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _letterCell(AppLocalizations l10n, String huruf) {
    final on = huruf == _k;
    return MociPressable(
      key: HurufScreen.alphabetCellKey(huruf),
      onTap: () => _pilih(huruf),
      color: on ? _accent : MociColors.white,
      shadowColor: on ? _accentShadow : _softShadow,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      semanticLabel: '${l10n.hurufLetter} $huruf',
      child: Center(
        child: Text(
          huruf,
          style: TextStyle(
            fontFamily: MociFonts.fredoka,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: on ? MociColors.white : MociColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Gambar contoh kata yang mengangguk pelan; diam saat gerak dikurangi.
class _Bob extends StatefulWidget {
  const _Bob({required this.child});

  final Widget child;

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -10 * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
    );
  }
}
