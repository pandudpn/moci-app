import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/prefs/prefs_controller.dart';
import '../../l10n/l10n.dart';
import '../../widgets/pressable.dart';
import 'istirahat_scene.dart';

const _gold = Color(0xFFFFE066);

/// Waktu Habis: batas harian tercapai. Hanya pil "Untuk orang tua" yang
/// bisa dibuka (lewat Gerbang); back sistem diabaikan.
class HabisScreen extends ConsumerStatefulWidget {
  const HabisScreen({super.key});

  @override
  ConsumerState<HabisScreen> createState() => _HabisScreenState();
}

class _HabisScreenState extends ConsumerState<HabisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(narratorProvider)
          .say(
            NarrationLine(
              jenis: 'ui',
              id: 'habisTitle',
              text: context.l10n.habisTitle,
            ),
            ref.read(prefsProvider).lang,
          );
    });
  }

  /// Area sentuh minimal dalam satuan panggung: 64 pt di tablet, 56 pt di HP.
  double _touch(BuildContext context) {
    final scale = context.stageScale;
    return (scale >= 600 / 820 ? 64.0 : 56.0) / scale;
  }

  @override
  Widget build(BuildContext context) {
    return MociStage(theme: MenuTheme.istirahat, tablet: _stage);
  }

  Widget _stage(BuildContext context) {
    final l10n = context.l10n;
    final name = ref.watch(prefsProvider.select((p) => p.childName)).trim();
    final touch = _touch(context);
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
              right: 32,
              top: 26 - (touch - 58).clamp(0, double.infinity) / 2,
              child: _parentsPill(l10n, touch),
            ),
            Positioned(
              left: 620,
              top: 150,
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.habisTitle,
                    style: MociText.title.copyWith(
                      fontSize: 50,
                      height: 1.1,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.habisSub(name.isEmpty ? l10n.childFallbackName : name),
                    style: MociText.body.copyWith(
                      height: 1.4,
                      color: const Color(0xFFE5DEFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _note(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _note(AppLocalizations l10n) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.12),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: CustomPaint(
                size: Size.square(44),
                painter: _ClockPainter(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.habisNote,
                style: MociText.body.copyWith(
                  fontSize: 20,
                  height: 1.35,
                  color: const Color(0xFFF1EDFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parentsPill(AppLocalizations l10n, double touch) {
    return MociPressable(
      color: const Color.fromRGBO(255, 255, 255, 0.14),
      shadowColor: const Color(0x00000000),
      depth: 0,
      minTouch: touch,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: l10n.habisParents,
      onTap: () => context.push(Routes.gerbangLanjut(Routes.orangTua)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.3),
            width: 2,
          ),
        ),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomPaint(
                    size: Size.square(22),
                    painter: _LockPainter(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.habisParents,
                    style: MociText.label.copyWith(
                      fontSize: 18,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Paint _line(double width, Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Gembok garis putih (kanvas 24 x 24), seperti pil prototipe.
class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = _line(2.4, const Color(0xFFFFFFFF));
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(4.5, 10.5, 15, 10),
          const Radius.circular(2.5),
        ),
        p,
      )
      ..drawPath(
        Path()
          ..moveTo(8, 10.5)
          ..lineTo(8, 7.5)
          ..arcToPoint(const Offset(16, 7.5), radius: const Radius.circular(4))
          ..lineTo(16, 10.5),
        p,
      );
  }

  @override
  bool shouldRepaint(_LockPainter old) => false;
}

/// Jam emas (kanvas 24 x 24): lingkaran dan jarum.
class _ClockPainter extends CustomPainter {
  const _ClockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = _line(2, _gold);
    canvas
      ..drawCircle(const Offset(12, 12), 9, p)
      ..drawPath(
        Path()
          ..moveTo(12, 7)
          ..lineTo(12, 12)
          ..lineTo(15, 14),
        p,
      );
  }

  @override
  bool shouldRepaint(_ClockPainter old) => false;
}
