import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../../app/layout/moci_stage.dart';
import '../../app/play_timer/play_timer_controller.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import 'istirahat_scene.dart';

/// Lama istirahat (D8): 20 detik, lalu kembali sendiri ke layar tadi.
const istirahatSeconds = 20;

/// Langkah aktif untuk sisa waktu [left] detik: 0, 1, atau 2.
int istirahatStepFor(int left) => left > 13
    ? 0
    : left > 6
    ? 1
    : 2;

const _soft = Color(0xFFE5DEFF);
const _gold = Color(0xFFFFD43B);
const _ink = Color(0xFF2B2350);

/// Istirahat 20 detik: hitung mundur, tiga langkah yang dibacakan, tanpa
/// tombol lewati dan tanpa pil orang tua (D13).
class IstirahatScreen extends ConsumerStatefulWidget {
  const IstirahatScreen({super.key});

  @override
  ConsumerState<IstirahatScreen> createState() => _IstirahatScreenState();
}

class _IstirahatScreenState extends ConsumerState<IstirahatScreen> {
  int _left = istirahatSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = context.l10n;
      ref.read(narratorProvider).sayAll([
        _line('istirahatTitle', l10n.istirahatTitle),
        _line('istirahatStep1', l10n.istirahatStep1),
      ], ref.read(prefsProvider).lang);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  NarrationLine _line(String id, String text) =>
      NarrationLine(jenis: 'ui', id: id, text: text);

  void _tick() {
    final before = istirahatStepFor(_left);
    setState(() => _left--);
    if (_left <= 0) {
      _finish();
      return;
    }
    final step = istirahatStepFor(_left);
    if (step != before) {
      final l10n = context.l10n;
      final (id, text) = step == 1
          ? ('istirahatStep2', l10n.istirahatStep2)
          : ('istirahatStep3', l10n.istirahatStep3);
      ref
          .read(narratorProvider)
          .say(_line(id, text), ref.read(prefsProvider).lang);
    }
  }

  void _finish() {
    _timer?.cancel();
    final l10n = context.l10n;
    // Narasi tidak dihentikan: terus berbunyi di layar yang dikembalikan.
    ref
        .read(narratorProvider)
        .say(
          _line('istirahatDoneTitle', l10n.istirahatDoneTitle),
          ref.read(prefsProvider).lang,
        );
    ref.read(playTimerProvider.notifier).restTaken();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.beranda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MociStage(theme: MenuTheme.istirahat, tablet: _stage);
  }

  Widget _stage(BuildContext context) {
    final l10n = context.l10n;
    final step = istirahatStepFor(_left);
    final steps = [
      (StepIconKind.look, l10n.istirahatStep1),
      (StepIconKind.blink, l10n.istirahatStep2),
      (StepIconKind.stretch, l10n.istirahatStep3),
    ];
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: 1180,
        height: 820,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: IstirahatScene()),
            Positioned(
              left: 620,
              top: 150,
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.istirahatTitle,
                    style: MociText.title.copyWith(
                      fontSize: 50,
                      height: 1.1,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.istirahatSub,
                    style: MociText.body.copyWith(height: 1.4, color: _soft),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      _ring(l10n),
                      const SizedBox(width: 26),
                      Expanded(
                        child: Column(
                          children: [
                            for (var i = 0; i < steps.length; i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              _stepRow(steps[i].$1, steps[i].$2, i == step),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(AppLocalizations l10n) {
    return Semantics(
      label: l10n.istirahatTimer(_left),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: 150,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _RingPainter(_left / istirahatSeconds),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_left',
                    style: MociText.title.copyWith(
                      fontSize: 54,
                      height: 1,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Text(
                    l10n.istirahatSecs,
                    style: MociText.label.copyWith(fontSize: 15, color: _soft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepRow(StepIconKind icon, String text, bool active) {
    return Opacity(
      opacity: active ? 1 : 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, active ? 0.2 : 0.07),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? _gold
                        : const Color.fromRGBO(255, 255, 255, 0.16),
                  ),
                  child: SizedBox.square(
                    dimension: 46,
                    child: Center(
                      child: CustomPaint(
                        size: const Size.square(26),
                        painter: StepIcon(
                          icon,
                          active ? _ink : const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: MociText.body.copyWith(
                      fontSize: 19,
                      height: 1.2,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cincin 150 px: jalur redup dan busur kuning sebesar [fraction], mulai dari atas.
class _RingPainter extends CustomPainter {
  const _RingPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: 62);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = const Color.fromRGBO(255, 255, 255, 0.2);
    canvas.drawCircle(rect.center, 62, base);
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * fraction,
      false,
      base
        ..color = _gold
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
