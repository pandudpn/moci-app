import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

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
import '../../widgets/moci_illustration.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/pressable.dart';
import 'hadiah_controller.dart';
import 'stiker.dart';
import 'stiker_nama.dart';
import 'widgets/hebat_widgets.dart';

const _shadowGold = Color(0xFFF2C94C);
const _white = Color(0xFFFFFFFF);

/// Hebat: hadiah sehabis satu ronde (3 bintang dan stiker baru). Data dari
/// `state.extra as HebatArgs`.
class HebatScreen extends ConsumerWidget {
  const HebatScreen({super.key, required this.args});

  final HebatArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MociStage(
      theme: MenuTheme.hebat,
      tablet: (context) => _HebatStage(args: args),
    );
  }
}

class _HebatStage extends ConsumerStatefulWidget {
  const _HebatStage({required this.args});

  final HebatArgs args;

  @override
  ConsumerState<_HebatStage> createState() => _HebatStageState();
}

class _HebatStageState extends ConsumerState<_HebatStage>
    with TickerProviderStateMixin {
  /// Kartu dan bintang muncul: bintang terakhir selesai di 0,8 + 0,6 detik.
  static const _introDuration = Duration(milliseconds: 1400);
  static const _starDelays = [300, 550, 800];
  static const _starTime = 600;
  static const _starCurve = Cubic(0.3, 1.7, 0.5, 1);
  static const _cardCurve = Cubic(0.3, 1.5, 0.5, 1);

  late final _intro = AnimationController(
    vsync: this,
    duration: _introDuration,
  );
  final _elapsed = ValueNotifier<Duration>(Duration.zero);
  late final Ticker _ticker = createTicker((d) => _elapsed.value = d);
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _greet());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _ticker.stop();
      _intro.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _intro.forward();
      _ticker.start();
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _intro.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  /// Narasi "Hebat!", lalu sorak.
  Future<void> _greet() async {
    if (!mounted) return;
    await ref
        .read(narratorProvider)
        .say(
          NarrationLine(
            jenis: 'ui',
            id: 'hebatGreat',
            text: context.l10n.hebatGreat,
          ),
          ref.read(prefsProvider).lang,
        );
    if (!mounted) return;
    await ref.read(audioServiceProvider).playSfx(Sfx.sorak);
  }

  /// Varian narasi tanpa nama anak dan tanpa nama stiker (D5).
  void _cheer() {
    ref
        .read(narratorProvider)
        .say(
          NarrationLine(
            jenis: 'ui',
            id: 'hebatYay',
            text: context.l10n.hebatYay,
          ),
          ref.read(prefsProvider).lang,
        );
  }

  /// Area sentuh minimal dalam satuan panggung: 64 pt di tablet, 56 pt di HP.
  double _touch(BuildContext context) {
    final scale = context.stageScale;
    return (scale >= 600 / 820 ? 64.0 : 56.0) / scale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final loop = reduced ? null : _elapsed;
    final owned = [
      for (final id in ref.watch(progressProvider.select((p) => p.stickers)))
        if (stickerCatalog.contains(id)) id,
    ];
    final stars = ref.watch(progressProvider.select((p) => p.stars));
    final name = ref.watch(prefsProvider.select((p) => p.childName)).trim();
    final touch = _touch(context);
    final award = widget.args.award;
    final bubble = name.isEmpty ? l10n.hebatBubble : l10n.hebatBubbleName(name);

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 1180,
        height: 820,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(child: HebatBackdrop(elapsed: loop)),
              Positioned(
                right: 30,
                top: 26,
                child: _starPill(l10n, stars, award.stars, loop),
              ),
              Positioned(
                left: 12,
                bottom: 34,
                width: 280,
                child: _moci(l10n, bubble),
              ),
              Positioned(
                left: 300,
                top: 120,
                width: 580,
                height: 600,
                child: _card(l10n, touch, loop),
              ),
              Positioned(
                left: 904,
                top: 250,
                width: 248,
                child: Transform.rotate(
                  angle: 4 * math.pi / 180,
                  child: Semantics(
                    container: true,
                    label:
                        '${l10n.hebatAlbum} ${owned.length} / ${stickerCatalog.length}',
                    excludeSemantics: true,
                    child: HebatAlbum(
                      title: l10n.hebatAlbum,
                      owned: owned.length,
                      total: stickerCatalog.length,
                      recent: owned.sublist(math.max(0, owned.length - 6)),
                      newId: award.sticker,
                      newTag: l10n.hebatNewTag,
                      elapsed: loop,
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

  Widget _starPill(
    AppLocalizations l10n,
    int total,
    int gained,
    ValueListenable<Duration>? loop,
  ) {
    Widget chip = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F8EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Text(
              '+$gained',
              style: MociText.label.copyWith(
                fontSize: 18,
                color: const Color(0xFF157A28),
              ),
            ),
          ),
        ),
      ),
    );
    if (loop != null) {
      final inner = chip;
      chip = HebatLoop(
        elapsed: loop,
        builder: (context, d) =>
            Transform.scale(scale: 1 + .12 * hebatWave(d, 1800), child: inner),
      );
    }
    return Semantics(
      container: true,
      label: l10n.hebatStarsLabel(total, gained),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: _shadowGold, offset: Offset(0, 6)),
          ],
        ),
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HebatStarIcon(size: 38),
                const SizedBox(width: 8),
                Text('$total', style: MociText.title.copyWith(fontSize: 28)),
                const SizedBox(width: 8),
                chip,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gelembung dan Moci: satu area sentuh, satu narasi.
  Widget _moci(AppLocalizations l10n, String bubble) {
    return Semantics(
      container: true,
      button: true,
      label: '$bubble ${l10n.hebatTapHint}',
      onTap: _cheer,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _cheer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 262),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(color: _shadowGold, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const HebatGlyphIcon(HebatGlyph.speaker, size: 28),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              bubble,
                              style: MociText.button.copyWith(
                                fontSize: 24,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: -24,
                    height: 26,
                    child: Center(
                      child: CustomPaint(
                        size: Size(36, 26),
                        painter: _TailPainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            MociMascot(pose: MociPose.senang, size: 250, onTap: _cheer),
          ],
        ),
      ),
    );
  }

  Widget _card(
    AppLocalizations l10n,
    double touch,
    ValueListenable<Duration>? loop,
  ) {
    final award = widget.args.award;
    final sticker = award.sticker;
    final body = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(52),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x382B2350),
                  offset: Offset(0, 36),
                  blurRadius: 60,
                ),
                BoxShadow(color: _shadowGold, offset: Offset(0, 16)),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 110, 40, 0),
            child: Column(
              children: [
                _stars(),
                const SizedBox(height: 10),
                Text(
                  l10n.hebatEarned(award.stars),
                  textAlign: TextAlign.center,
                  style: MociText.button.copyWith(fontSize: 32, height: 1.2),
                ),
                if (sticker != null) ...[
                  const SizedBox(height: 22),
                  _medal(l10n, sticker, loop),
                ],
              ],
            ),
          ),
        ),
        Positioned(left: 0, right: 0, top: -38, child: _ribbon(l10n, loop)),
        Positioned(
          left: 40,
          right: 40,
          bottom: 36 - math.max(0, touch - 78) / 2,
          child: Row(
            children: [
              Expanded(
                child: _button(
                  label: l10n.hebatAgain,
                  touch: touch,
                  color: const Color(0xFFFFF1EC),
                  shadow: const Color(0xFFF7C9A5),
                  textColor: MociColors.ink,
                  glyph: HebatGlyph.replay,
                  glyphFirst: true,
                  onTap: () => context.go(widget.args.replayRoute),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _button(
                  label: l10n.hebatNext,
                  touch: touch,
                  color: MociColors.correct,
                  shadow: MociColors.correctShadow,
                  textColor: _white,
                  glyph: HebatGlyph.arrow,
                  glyphFirst: false,
                  onTap: () => context.go(Routes.beranda),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return AnimatedBuilder(
      animation: _intro,
      child: body,
      builder: (context, child) {
        final p = Interval(
          0,
          600 / _introDuration.inMilliseconds,
          curve: _cardCurve,
        ).transform(_intro.value);
        return Opacity(
          opacity: p.clamp(0.0, 1.0),
          child: Transform.scale(scale: .6 + .4 * p, child: child),
        );
      },
    );
  }

  Widget _ribbon(AppLocalizations l10n, ValueListenable<Duration>? loop) {
    final ribbon = Center(
      child: HebatRibbon(title: l10n.hebatGreat.toUpperCase()),
    );
    if (loop == null) return ribbon;
    return HebatLoop(
      elapsed: loop,
      builder: (context, d) => Transform.rotate(
        angle: (-2 + 4 * hebatWave(d, 6000)) * math.pi / 180,
        child: ribbon,
      ),
    );
  }

  Widget _stars() {
    const sizes = [104.0, 136.0, 104.0];
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            SizedBox(
              key: ValueKey('hebat-star-$i'),
              width: sizes[i],
              height: sizes[i],
              child: AnimatedBuilder(
                animation: _intro,
                builder: (context, child) {
                  final v = Interval(
                    _starDelays[i] / _introDuration.inMilliseconds,
                    (_starDelays[i] + _starTime) /
                        _introDuration.inMilliseconds,
                    curve: _starCurve,
                  ).transform(_intro.value);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(-120 * math.pi / 180 * (1 - v))
                      ..scaleByDouble(v, v, 1, 1),
                    child: child,
                  );
                },
                child: HebatStarIcon(size: sizes[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _medal(
    AppLocalizations l10n,
    String sticker,
    ValueListenable<Duration>? loop,
  ) {
    Widget medal = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EC),
        shape: BoxShape.circle,
        border: Border.all(color: _white, width: 7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E2B2350),
            offset: Offset(0, 8),
            blurRadius: 18,
          ),
          BoxShadow(color: Color(0xFFFFB020), spreadRadius: 4),
        ],
      ),
      child: SizedBox.square(
        dimension: 116,
        child: Center(child: MociIllustration(sticker, size: 84)),
      ),
    );
    if (loop != null) {
      final inner = medal;
      medal = HebatLoop(
        elapsed: loop,
        builder: (context, d) {
          final w = hebatWave(d, 4800);
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ((-6 + 12 * w) * math.pi / 180)
              ..scaleByDouble(1 + .06 * w, 1 + .06 * w, 1, 1),
            child: inner,
          );
        },
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        medal,
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.hebatNewSticker.toUpperCase(),
              style: MociText.label.copyWith(
                color: const Color(0xFFB3235E),
                letterSpacing: .6,
              ),
            ),
            Text(
              stickerName(l10n, sticker),
              style: MociText.title.copyWith(fontSize: 30),
            ),
          ],
        ),
      ],
    );
  }

  Widget _button({
    required String label,
    required double touch,
    required Color color,
    required Color shadow,
    required Color textColor,
    required HebatGlyph glyph,
    required bool glyphFirst,
    required VoidCallback onTap,
  }) {
    final icon = HebatGlyphIcon(glyph, size: 30, color: textColor);
    final text = Text(
      label,
      style: MociText.button.copyWith(fontSize: 26, color: textColor),
    );
    return MociPressable(
      color: color,
      shadowColor: shadow,
      depth: 7,
      borderRadius: BorderRadius.circular(999),
      minTouch: touch,
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox(
        height: 78,
        child: Center(
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (glyphFirst) icon,
                if (glyphFirst) const SizedBox(width: 10),
                text,
                if (!glyphFirst) const SizedBox(width: 10),
                if (!glyphFirst) icon,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ekor gelembung (kanvas 36 x 26): bayangan kuning di bawah, putih di atas.
class _TailPainter extends CustomPainter {
  const _TailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    Path tri(double dy, double bottom) => Path()
      ..moveTo(4, dy)
      ..lineTo(32, dy)
      ..lineTo(18, bottom)
      ..close();
    canvas
      ..drawPath(tri(6, 26), Paint()..color = _shadowGold)
      ..drawPath(tri(0, 20), Paint()..color = _white);
  }

  @override
  bool shouldRepaint(_TailPainter old) => false;
}
