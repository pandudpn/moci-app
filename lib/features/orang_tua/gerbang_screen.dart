import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../../app/layout/moci_stage.dart';
import '../../app/router.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_motion.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/content/narasi.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/moci_illustration.dart';
import '../../widgets/number_keypad.dart';
import '../../widgets/pressable.dart';
import 'gerbang_game.dart';
import 'widgets/gerbang_icons.dart';

/// Sumber acak soal gerbang. Tes menggantinya dengan `Random(seed)`.
final gateRandomProvider = Provider<Random>((ref) => Random());

const _panelShadow = Color(0xFF1F1846);
const _softKey = Color(0xFFF4F1FA);
const _softKeyShadow = Color(0xFFDCD5EE);
const _purple = Color(0xFF7048E8);
const _green = Color(0xFF157A28);
const _red = Color(0xFFC92A2A);

/// Jeda dari jawaban salah sampai soal baru muncul.
const _retryDelay = Duration(milliseconds: 1000);

/// Gerbang Orang Tua: soal perkalian dengan papan angka. Jawaban benar
/// membuka tujuan [lanjut], atau mengembalikan `true` ke pemanggil.
class GerbangScreen extends ConsumerStatefulWidget {
  const GerbangScreen({super.key, this.lanjut});

  /// Tujuan setelah masuk (query `lanjut`); `null` berarti `pop(true)`.
  final String? lanjut;

  @override
  ConsumerState<GerbangScreen> createState() => _GerbangScreenState();
}

class _GerbangScreenState extends ConsumerState<GerbangScreen>
    with TickerProviderStateMixin {
  late GateState _s;
  Timer? _retryTimer;

  late final _shake = AnimationController(
    vsync: this,
    duration: MociMotion.shake,
  );
  late final _lockPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  /// Satu putaran 7,8 detik = 3 putaran kelip (2,6 s) = 2,6 putaran melayang
  /// (3 s), jadi keduanya bisa memakai satu pengendali.
  late final _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7800),
  );

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    final rng = ref.read(gateRandomProvider);
    _s = GateState(nextGateQuestion(rng), '', GateStatus.idle);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sayHelp();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      _ambient.stop();
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _shake.dispose();
    _lockPop.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _sayHelp() {
    final l10n = context.l10n;
    final prefs = ref.read(prefsProvider);
    ref
        .read(narratorProvider)
        .say(
          NarrationLine(
            jenis: 'ui',
            id: idNarasiPanggilan('gerbangHelpSay', prefs.panggilan.name),
            text: l10n.gerbangHelpSay(panggilanTeks(prefs.panggilan, l10n)),
          ),
          prefs.lang,
        );
  }

  void _digit(int d) {
    final next = gateDigit(_s, d);
    if (identical(next, _s)) return;
    setState(() => _s = next);
    switch (next.status) {
      case GateStatus.bad:
        if (!_still) _shake.forward(from: 0);
        _retryTimer?.cancel();
        _retryTimer = Timer(_retryDelay, _showRetryQuestion);
      case GateStatus.ok:
        _lockPop.value = 0;
        if (_still) {
          _lockPop.value = 1;
        } else {
          _lockPop.forward();
        }
      case GateStatus.idle || GateStatus.retry:
        break;
    }
  }

  void _delete() {
    final next = gateDelete(_s);
    if (identical(next, _s)) return;
    setState(() => _s = next);
  }

  void _showRetryQuestion() {
    if (!mounted) return;
    setState(() {
      _s = gateNewQuestion(
        _s,
        ref.read(gateRandomProvider),
      ).copyWith(status: GateStatus.retry);
    });
  }

  void _newQuestion() {
    _retryTimer?.cancel();
    setState(() => _s = gateNewQuestion(_s, ref.read(gateRandomProvider)));
  }

  void _enter() {
    ref.read(parentAccessProvider.notifier).grant();
    final lanjut = widget.lanjut;
    if (lanjut == null) {
      context.pop(true);
      return;
    }
    final tujuan = tujuanLanjut(lanjut);
    if (tujuan == null) {
      // Tujuan tak dikenal (tautan luar, salah ketik): jangan dibuka.
      context.go(Routes.beranda);
      return;
    }
    context.pushReplacement(tujuan);
  }

  void _cancel() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      context.go(Routes.beranda);
    }
  }

  /// Area sentuh minimal dalam satuan panggung: 64 pt di tablet, 56 pt di HP,
  /// dihitung dari skala panggung (HP memakai desain tablet yang diperkecil).
  double _touch(BuildContext context) {
    final scale = context.stageScale;
    return (scale >= 600 / 820 ? 64.0 : 56.0) / scale;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: MociStage(
        theme: MenuTheme.gerbang,
        // Sama dengan area orang tua: teks sistem boleh membesar sampai 1,3×.
        textScaleCap: 1.3,
        tablet: _stage,
      ),
    );
  }

  Widget _stage(BuildContext context) {
    final l10n = context.l10n;
    final touch = _touch(context);
    final panggilan = panggilanTeks(
      ref.watch(prefsProvider.select((p) => p.panggilan)),
      l10n,
    );
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 1180,
        height: 820,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(painter: DotsPainter()),
              ),
            ),
            _sparkle(236, 60, 22, const Color(0xFFFFE066), 0),
            _sparkle(640, 48, 16, MociColors.white, -1.1),
            _sparkle(1100, 70, 20, const Color(0xFFFFE066), -0.6),
            _sparkle(90, 300, 16, MociColors.white, -1.8),
            _sparkle(1150, 760, 18, MociColors.white, -0.3),
            Positioned(
              left: 30,
              top: 26 - max(0, touch - 64) / 2,
              child: _cancelButton(l10n, touch),
            ),
            Positioned(
              left: 22,
              bottom: 40,
              width: 262,
              child: _help(l10n, touch, panggilan),
            ),
            Positioned(
              left: 300,
              top: 118,
              width: 846,
              height: 590,
              child: _panel(l10n, touch),
            ),
            Positioned(
              left: 300,
              top: 740,
              width: 846,
              child: Text(
                l10n.gerbangNote,
                textAlign: TextAlign.center,
                style: MociText.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD9D2F5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kelip 2,6 s dengan jeda negatif [delay] (detik), seperti prototipe.
  Widget _sparkle(double x, double y, double size, Color color, double delay) {
    return Positioned(
      left: x,
      top: y,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _ambient,
          builder: (context, child) {
            if (_still) return child!;
            final seconds = _ambient.value * 7.8 + delay;
            final phase = ((seconds / 2.6) % 1 + 1) % 1;
            final w = (1 - cos(phase * 2 * pi)) / 2; // 0 -> 1 -> 0
            return Opacity(
              opacity: 0.35 + 0.65 * w,
              child: Transform.scale(scale: 0.75 + 0.35 * w, child: child),
            );
          },
          child: CustomPaint(
            size: Size.square(size),
            painter: SparklePainter(color),
          ),
        ),
      ),
    );
  }

  Widget _cancelButton(AppLocalizations l10n, double touch) {
    return MociPressable(
      depth: 6,
      minTouch: touch,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: l10n.gerbangCancel,
      onTap: _cancel,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 26),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomPaint(
                  size: Size.square(28),
                  painter: GateIcon.back(color: MociColors.ink),
                ),
                const SizedBox(width: 10),
                Text(l10n.gerbangCancel, style: MociText.button),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _help(AppLocalizations l10n, double touch, String panggilan) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 250),
          child: MociPressable(
            depth: 6,
            minTouch: touch,
            borderRadius: BorderRadius.circular(24),
            semanticLabel: l10n.gerbangHelp(panggilan),
            onTap: _sayHelp,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomPaint(
                          size: Size.square(26),
                          painter: GateIcon.speaker(color: _purple),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            l10n.gerbangHelp(panggilan),
                            style: MociText.button.copyWith(
                              fontSize: 22,
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
                  child: Center(
                    child: CustomPaint(
                      size: Size(36, 26),
                      painter: BubbleTailPainter(
                        fill: MociColors.white,
                        shadow: _panelShadow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _sayHelp,
          child: ExcludeSemantics(
            child: AnimatedBuilder(
              animation: _ambient,
              builder: (context, child) {
                if (_still) return child!;
                final phase = (_ambient.value * 7.8 / 3) % 1;
                final w = (1 - cos(phase * 2 * pi)) / 2;
                return Transform.translate(
                  offset: Offset(0, -8 * w),
                  child: child,
                );
              },
              child: const MociIllustration('moci', size: 200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(AppLocalizations l10n, double touch) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MociColors.white,
        borderRadius: BorderRadius.circular(44),
        boxShadow: const [
          BoxShadow(color: _panelShadow, offset: Offset(0, 14)),
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 30),
            blurRadius: 60,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 48,
            top: 44,
            width: 404,
            child: _question(l10n, touch),
          ),
          Positioned(
            left: 474,
            top: 60,
            bottom: 60,
            width: 4,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFF1EEF9),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
          Positioned(
            right: 48,
            top: 104,
            child: NumberKeypad(onDigit: _digit, onDelete: _delete),
          ),
        ],
      ),
    );
  }

  Widget _question(AppLocalizations l10n, double touch) {
    final ok = _s.status == GateStatus.ok;
    final bad = _s.status == GateStatus.bad;
    final q = _s.q;
    final (message, messageColor) = switch (_s.status) {
      GateStatus.ok => (l10n.gerbangOk, _green),
      GateStatus.bad => (l10n.gerbangBad, _red),
      GateStatus.retry => (l10n.gerbangRetry, const Color(0xFF5B3FC4)),
      GateStatus.idle => (l10n.gerbangHint, MociColors.inkSoft),
    };
    final title = MociText.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lock(ok),
        const SizedBox(height: 18),
        Text(
          l10n.gerbangTitle,
          style: title.copyWith(fontSize: 40, height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.gerbangSub,
          style: MociText.label.copyWith(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5B5480),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 26),
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(
            offset: Offset(bad ? _shakeOffset(_shake.value) : 0, 0),
            child: child,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: l10n.gerbangTimes(q.a, q.b),
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${q.a} × ${q.b} =',
                      style: title.copyWith(fontSize: 64, height: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _digitBox(0),
                const SizedBox(width: 12),
                _digitBox(1),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: MociText.label.copyWith(fontSize: 19, color: messageColor),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            MociPressable(
              color: _softKey,
              shadowColor: _softKeyShadow,
              depth: 6,
              minTouch: touch,
              borderRadius: BorderRadius.circular(999),
              semanticLabel: l10n.gerbangNewQ,
              onTap: _newQuestion,
              child: SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 22),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CustomPaint(
                          size: Size.square(26),
                          painter: GateIcon.refresh(color: MociColors.ink),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.gerbangNewQ,
                          style: MociText.button.copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (ok) _PopIn(child: _enterButton(l10n, touch)),
          ],
        ),
      ],
    );
  }

  Widget _enterButton(AppLocalizations l10n, double touch) {
    return MociPressable(
      color: MociColors.correct,
      shadowColor: MociColors.correctShadow,
      depth: 6,
      minTouch: touch,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: l10n.gerbangEnter,
      onTap: _enter,
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.only(left: 28, right: 24),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.gerbangEnter,
                  style: MociText.button.copyWith(color: MociColors.white),
                ),
                const SizedBox(width: 8),
                const CustomPaint(
                  size: Size.square(28),
                  painter: GateIcon.next(color: MociColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lock(bool ok) {
    final curve = const Cubic(0.3, 1.7, 0.5, 1);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ok ? const Color(0xFFE6F8EA) : const Color(0xFFFFF1D6),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: ok ? const Color(0xFFB5E2BF) : const Color(0xFFF2D49A),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: 88,
          child: Center(
            child: AnimatedBuilder(
              animation: _lockPop,
              builder: (context, child) {
                if (!ok) return child!;
                final t = curve.transform(_lockPop.value);
                return Transform.rotate(
                  angle: -10 * pi / 180 * (1 - t),
                  child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
                );
              },
              child: CustomPaint(
                size: const Size.square(48),
                painter: ok
                    ? const GateIcon.lockOpen()
                    : const GateIcon.lockClosed(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _digitBox(int i) {
    final ok = _s.status == GateStatus.ok;
    final bad = _s.status == GateStatus.bad;
    final value = i < _s.input.length ? _s.input[i] : '';
    final (Color border, Color bg) = ok
        ? (MociColors.correct, const Color(0xFFE6F8EA))
        : bad
        ? (_red, const Color(0xFFFFF0F0))
        : i == _s.input.length
        ? (_purple, const Color(0xFFF8F6FD))
        : (const Color(0xFFE3DDF0), const Color(0xFFF8F6FD));
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border, width: 4),
        ),
        child: SizedBox(
          width: 76,
          height: 96,
          child: Center(
            child: Text(
              value,
              style: MociText.title.copyWith(fontSize: 56, height: 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Goyang 450 ms: 0, -12, 10, -7, 4, 0 pada 0/20/40/60/80/100 persen.
double _shakeOffset(double t) {
  const stops = [0.0, -12.0, 10.0, -7.0, 4.0, 0.0];
  final x = (t.clamp(0.0, 1.0)) * 5;
  final i = x.floor().clamp(0, 4);
  final f = Curves.easeInOut.transform(x - i);
  return stops[i] + (stops[i + 1] - stops[i]) * f;
}

/// Muncul membesar memantul (450 ms). Gerak dikurangi: langsung tampil.
class _PopIn extends StatefulWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: MociMotion.popIn);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = MociMotion.popCurve.transform(_c.value);
        return Opacity(
          opacity: _c.value.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
        );
      },
    );
  }
}
