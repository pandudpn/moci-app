import 'package:flutter/widgets.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_text.dart';
import '../moci_illustration.dart';
import '../pressable.dart';
import 'game_glyphs.dart';

enum AnswerCardState { idle, correct, wrong }

/// Kartu jawaban bergambar. [correct] memberi bingkai hijau dan lencana
/// centang, [wrong] bingkai salmon.
class AnswerCard extends StatelessWidget {
  const AnswerCard({
    super.key,
    this.semanticLabel,
    this.onTap,
    this.illustration,
    this.text,
    this.child,
    this.state = AnswerCardState.idle,
    this.width = 300,
    this.height = 340,
    this.illustrationSize = 210,
    this.accent,
  });

  static const badgeKey = ValueKey('answer-card-badge');

  final String? semanticLabel;
  final VoidCallback? onTap;

  /// Id ilustrasi di `assets/illustrations/`; diabaikan kalau [child] diisi.
  final String? illustration;
  final String? text;

  /// Isi pengganti gambar, misalnya huruf besar atau angka.
  final Widget? child;
  final AnswerCardState state;
  final double width;
  final double height;
  final double illustrationSize;

  /// Warna bingkai saat [state] masih [AnswerCardState.idle].
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final border = switch (state) {
      AnswerCardState.idle => accent ?? MociColors.inkSoft,
      AnswerCardState.correct => MociColors.correct,
      AnswerCardState.wrong => const Color(0xFFF5BCD3),
    };
    final shadow =
        MenuThemeScope.maybeOf(context)?.shadow ?? MociColors.neutralShadow;
    return MociPressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      color: MociColors.white,
      shadowColor: shadow,
      depth: 12,
      borderRadius: const BorderRadius.all(Radius.circular(42)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: border, width: 8),
          borderRadius: const BorderRadius.all(Radius.circular(42)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (child != null)
                    child!
                  else if (illustration != null)
                    MociIllustration(illustration!, size: illustrationSize)
                  else
                    const SizedBox.shrink(),
                  if (text != null) ...[
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        text!,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MociText.title.copyWith(fontSize: 30),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (state == AnswerCardState.correct)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  key: badgeKey,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: border,
                    shape: BoxShape.circle,
                    border: Border.all(color: MociColors.white, width: 4),
                  ),
                  child: const Center(
                    child: GameGlyph(
                      GameGlyphKind.check,
                      size: 24,
                      color: MociColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
