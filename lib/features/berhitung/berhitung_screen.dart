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
import '../../core/content/angka_kata.dart';
import '../../core/content/content_repository.dart';
import '../../core/content/katalog.dart';
import '../../core/lang.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../core/progress/progress_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/game/game_glyphs.dart';
import '../../widgets/game/ring_pulse.dart';
import '../../widgets/game/route_mode_pill.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_top_bar.dart';
import '../../widgets/pressable.dart';
import '../../widgets/star_counter.dart';
import 'berhitung_benda.dart';

/// Layar Berhitung 1–50: kartu angka, panel hitung yang diketuk satu per
/// satu, hitung bareng, dan kisi angka per rentang.
class BerhitungScreen extends ConsumerStatefulWidget {
  const BerhitungScreen({super.key, this.awal});

  // Nilai kunci dipisah rentangnya supaya kunci benda, angka, dan rentang
  // tidak pernah bentrok di pohon yang sama.
  static const _itemBase = 100000;
  static const _rangeBase = 200000;

  static ValueKey<int> itemKey(int i) => ValueKey(_itemBase + i);
  static ValueKey<int> numberKey(int n) => ValueKey(n);
  static ValueKey<int> rangeKey(int awal) => ValueKey(_rangeBase + awal);

  /// Angka pertama saat layar dibuka; di luar 1..maks dijepit.
  final String? awal;

  @override
  ConsumerState<BerhitungScreen> createState() => _BerhitungScreenState();
}

class _BerhitungScreenState extends ConsumerState<BerhitungScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFF1C7ED6);
  static const _accentShadow = Color(0xFF1565B0);
  static const _soft = Color(0xFFE7F3FF);
  static const _softShadow = Color(0xFFB7D7F7);

  late int _n;
  int _count = 0;
  Timer? _timer;

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _popScale = CurvedAnimation(
    parent: _pop,
    curve: const Cubic(0.3, 1.6, 0.5, 1),
  );

  AngkaInfo get _angka => ref.read(katalogProvider).angka;

  AppLang get _lang => ref.read(prefsProvider).lang;

  /// Benda untuk angka sekarang, berulang tiap 12 benda seperti prototipe.
  Item get _benda {
    final ids = _angka.benda;
    final id = ids[(_n - 1) % ids.length];
    final items = ref.read(katalogProvider).item;
    return items.firstWhere((i) => i.id == id, orElse: () => items.first);
  }

  String get _nama => _benda.nama.of(_lang);

  /// Benda dalam bentuk yang dipakai judul dan bilah selesai: huruf kecil
  /// untuk Indonesia, jamak untuk Inggris.
  String get _bendaTeks =>
      _lang == AppLang.id ? _nama.toLowerCase() : bendaJamak(_nama, _lang);

  String get _kata => angkaKata(_n, _lang);

  String get _kataKapital =>
      _kata.isEmpty ? _kata : _kata[0].toUpperCase() + _kata.substring(1);

  bool get _selesai => _count >= _n;

  /// Angka pertama pada rentang yang sedang tampil.
  int get _lo => ((_n - 1) ~/ 10) * 10 + 1;

  @override
  void initState() {
    super.initState();
    final angka = int.tryParse(widget.awal ?? '') ?? 1;
    _n = angka.clamp(1, _angka.maks);
    _pop.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _catat();
      _sayAngka(_n);
    });
  }

  @override
  void dispose() {
    _stopTimer();
    _pop.dispose();
    super.dispose();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _catat() {
    ref.read(progressProvider.notifier).setLastActivity(Routes.angka, {
      'angka': '$_n',
    });
    ref.read(progressProvider.notifier).markItem('angka', 'dibaca', '$_n');
  }

  NarrationLine _barisAngka(int n) =>
      NarrationLine(jenis: 'angka', id: '$n', text: angkaKata(n, _lang));

  void _sayAngka(int n) =>
      ref.read(narratorProvider).sayAll([_barisAngka(n)], _lang);

  void _pilih(int n) {
    _stopTimer();
    if (n != _n) {
      setState(() {
        _n = n;
        _count = 0;
      });
      _pop.forward(from: 0);
    } else {
      setState(() => _count = 0);
    }
    _catat();
    _sayAngka(_n);
  }

  void _ketukBenda() {
    if (_selesai) return;
    final c = _count + 1;
    setState(() => _count = c);
    if (c >= _n) {
      _finish();
    } else {
      _sayAngka(c);
    }
  }

  /// Hitungan penuh: sorak, catat, lalu pujian, angka, dan nama bendanya.
  void _finish() {
    ref.read(audioServiceProvider).playSfx(Sfx.sorak);
    ref.read(progressProvider.notifier).markItem('angka', 'dihitung', '$_n');
    ref.read(narratorProvider).sayAll([
      NarrationLine(
        jenis: 'ui',
        id: 'angkaDoneSay',
        text: context.l10n.angkaDoneSay,
      ),
      _barisAngka(_n),
      NarrationLine(jenis: 'nama', id: _benda.id, text: _nama),
    ], _lang);
  }

  void _hitungBareng() {
    _stopTimer();
    setState(() => _count = 0);
    final total = _n;
    final step = total <= 10 ? 700 : (total <= 20 ? 450 : 260);
    _timer = Timer.periodic(Duration(milliseconds: step), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final c = _count + 1;
      setState(() => _count = c);
      if (c >= total) {
        _stopTimer();
        _finish();
        return;
      }
      // Angka panjang dibacakan tiap sepuluh saja supaya tidak menumpuk.
      if (total <= 20 || c % 10 == 0) _sayAngka(c);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(prefsProvider.select((p) => p.lang), (_, _) => _sayAngka(_n));
    ref.watch(prefsProvider.select((p) => p.lang));
    return MociStage(theme: MenuTheme.berhitung, tablet: _tablet);
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
            title: l10n.angkaTitle,
            trailing: [
              RouteModePill(
                tabs: [
                  (
                    label: l10n.angkaCount,
                    route: Routes.angka,
                    icon: const GameGlyph(GameGlyphKind.count),
                  ),
                  (
                    label: l10n.hurufWrite,
                    route: Routes.angkaTulis,
                    icon: const GameGlyph(GameGlyphKind.pencil),
                  ),
                ],
                semanticLabel: l10n.modeSemantic,
                accent: _accent,
              ),
              StarCounter(semanticLabelOf: l10n.berandaStarsLabel),
            ],
          ),
        ),
        Positioned(left: 50, top: 124, child: _numberCard(l10n)),
        Positioned(left: 436, top: 124, child: _panel(l10n)),
        Positioned(left: 50, top: 640, width: 1086, child: _ranges(l10n)),
        Positioned(left: 156, top: 708, width: 868, child: _numbers(l10n)),
      ],
    );
  }

  Widget _card({required double width, required double height}) {
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(44),
        boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 14))],
      ),
    );
  }

  Widget _numberCard(AppLocalizations l10n) {
    final ukuran = _n < 10 ? 240.0 : 200.0;
    final kataSize = _kataKapital.length > 18
        ? 34.0
        : _kataKapital.length > 11
        ? 40.0
        : 52.0;
    return SizedBox(
      width: 360,
      height: 490,
      child: Stack(
        children: [
          _card(width: 360, height: 490),
          Positioned(
            left: 0,
            right: 0,
            top: 18,
            height: 260,
            child: MociPressable(
              onTap: () => _sayAngka(_n),
              color: const Color(0x00000000),
              shadowColor: const Color(0x00000000),
              depth: 0,
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              semanticLabel: l10n.angkaNumber(_n),
              child: Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(_popScale),
                  child: Text(
                    '$_n',
                    style: TextStyle(
                      fontFamily: MociFonts.fredoka,
                      fontSize: ukuran,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      color: _accent,
                      shadows: const [
                        Shadow(color: Color(0xFFCFE6FF), offset: Offset(0, 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 286,
            height: 100,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _kataKapital,
                  maxLines: 1,
                  style: MociText.title.copyWith(
                    fontSize: kataSize,
                    color: MociColors.ink,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 132,
            top: 392,
            width: 96,
            height: 96,
            child: RingPulse(
              size: 96,
              color: const Color(0xFFFFB020),
              child: MociPressable(
                onTap: () => _sayAngka(_n),
                color: const Color(0xFFFFB020),
                shadowColor: const Color(0xFFE0870B),
                depth: 8,
                borderRadius: const BorderRadius.all(Radius.circular(48)),
                semanticLabel: l10n.angkaListen,
                minTouch: 64,
                child: const SizedBox(
                  width: 96,
                  height: 96,
                  child: Center(
                    child: GameGlyph(GameGlyphKind.listen, size: 48),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(AppLocalizations l10n) {
    return SizedBox(
      width: 700,
      height: 490,
      child: Stack(
        children: [
          _card(width: 700, height: 490),
          ClipRRect(
            borderRadius: BorderRadius.circular(44),
            child: Stack(
              children: [
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 110,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFFEAF6E4)),
                  ),
                ),
                Positioned(
                  left: 28,
                  right: 28,
                  top: 22,
                  height: 54,
                  child: Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.angkaCountPrompt(_bendaTeks),
                            maxLines: 1,
                            style: MociText.title.copyWith(
                              fontSize: 28,
                              color: MociColors.ink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _autoButton(l10n),
                      const SizedBox(width: 12),
                      _countPill(),
                    ],
                  ),
                ),
                Positioned(
                  left: 24,
                  top: 96,
                  width: 652,
                  height: 370,
                  child: Center(child: _grid(l10n)),
                ),
                if (_selesai)
                  Positioned(
                    left: 50,
                    bottom: 20,
                    width: 600,
                    height: 66,
                    child: _doneBar(l10n),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _autoButton(AppLocalizations l10n) {
    return MociPressable(
      onTap: _hitungBareng,
      color: _soft,
      shadowColor: _softShadow,
      depth: 4,
      borderRadius: const BorderRadius.all(Radius.circular(27)),
      semanticLabel: l10n.angkaAuto,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GameGlyph(
                GameGlyphKind.play,
                size: 24,
                color: Color(0xFF1265B5),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.angkaAuto,
                style: MociText.button.copyWith(
                  fontSize: 19,
                  color: const Color(0xFF1265B5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _countPill() {
    return Semantics(
      liveRegion: true,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Center(
          child: Text(
            '$_count / $_n',
            style: MociText.button.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: MociColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _doneBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: MociColors.ink,
        borderRadius: BorderRadius.circular(33),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GameGlyph(
            GameGlyphKind.star,
            size: 36,
            color: MociColors.starFill,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.angkaDone(_kata, _bendaTeks),
                maxLines: 1,
                style: MociText.button.copyWith(
                  fontSize: 26,
                  color: MociColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _grid(AppLocalizations l10n) {
    final g = hitungGrid(_n);
    final rows = <Widget>[];
    for (var start = 0; start < _n; start += g.columns) {
      final end = math.min(start + g.columns, _n);
      if (rows.isNotEmpty) rows.add(SizedBox(height: g.gap));
      rows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = start; i < end; i++) ...[
              if (i > start) SizedBox(width: g.gap),
              _item(l10n, i, g.size),
            ],
          ],
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  Widget _item(AppLocalizations l10n, int i, double size) {
    final counted = i < _count;
    final badge = size >= 90
        ? 44.0
        : size >= 50
        ? 26.0
        : 24.0;
    return Semantics(
      button: true,
      label: counted ? '${i + 1}' : l10n.angkaTapIt,
      child: GestureDetector(
        key: BerhitungScreen.itemKey(i),
        behavior: HitTestBehavior.opaque,
        onTap: _ketukBenda,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: counted ? 0.55 : 1,
                  duration: const Duration(milliseconds: 400),
                  curve: const Cubic(0.3, 1.6, 0.5, 1),
                  child: MociIllustration(_benda.id, size: size),
                ),
              ),
              if (counted)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: badge,
                    height: badge,
                    decoration: BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: MociColors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontFamily: MociFonts.fredoka,
                          fontSize: badge >= 40
                              ? 22
                              : badge >= 26
                              ? 13
                              : 12,
                          fontWeight: FontWeight.w700,
                          color: MociColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ranges(AppLocalizations l10n) {
    final rentang = _angka.rentang;
    return Semantics(
      container: true,
      label: l10n.angkaRange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final r in rentang) ...[
            if (r != rentang.first) const SizedBox(width: 10),
            _rangePill(r),
          ],
        ],
      ),
    );
  }

  Widget _rangePill((int, int) r) {
    final on = r.$1 == _lo;
    return MociPressable(
      key: BerhitungScreen.rangeKey(r.$1),
      onTap: () => _pilih(r.$1),
      color: on ? _accent : MociColors.white,
      shadowColor: on ? _accentShadow : _softShadow,
      depth: 5,
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      semanticLabel: '${r.$1}–${r.$2}',
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Text(
              '${r.$1}–${r.$2}',
              style: MociText.button.copyWith(
                fontSize: 22,
                color: on ? MociColors.white : MociColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numbers(AppLocalizations l10n) {
    return Semantics(
      container: true,
      label: l10n.angkaPick,
      child: Row(
        children: [
          for (var k = 0; k < 10; k++) ...[
            if (k > 0) const SizedBox(width: 12),
            Expanded(child: _numberCell(l10n, _lo + k)),
          ],
        ],
      ),
    );
  }

  Widget _numberCell(AppLocalizations l10n, int v) {
    final on = v == _n;
    return MociPressable(
      key: BerhitungScreen.numberKey(v),
      onTap: () => _pilih(v),
      color: on ? _accent : MociColors.white,
      shadowColor: on ? _accentShadow : _softShadow,
      depth: 6,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      semanticLabel: l10n.angkaNumber(v),
      child: SizedBox(
        height: 76,
        child: Center(
          child: Text(
            '$v',
            style: TextStyle(
              fontFamily: MociFonts.fredoka,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: on ? MociColors.white : MociColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
