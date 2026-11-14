import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/moci_colors.dart';
import '../../app/theme/moci_motion.dart';
import '../../app/theme/moci_text.dart';
import '../../core/audio/audio_providers.dart';
import '../../core/audio/narrator.dart';
import '../../core/prefs/prefs_controller.dart';
import '../pressable.dart';
import 'game_glyphs.dart';

/// Kotak instruksi permainan: judul, keterangan, dan tombol dengar yang
/// hanya muncul kalau ada baris narasi.
class GameInstruction extends ConsumerWidget {
  const GameInstruction({
    super.key,
    required this.title,
    required this.text,
    required this.semanticLabel,
    this.narration = const [],
    this.listenLabel,
    this.titleColor,
  });

  static const listenKey = ValueKey('game-instruction-listen');

  final String title;
  final String text;
  final String semanticLabel;
  final List<NarrationLine> narration;

  /// Label tombol dengar; wajib diisi kalau [narration] tidak kosong.
  final String? listenLabel;
  final Color? titleColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: MociText.title.copyWith(
                    fontSize: 36,
                    color: titleColor ?? MociColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: MociText.label.copyWith(
                    fontSize: 18,
                    color: MociColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          if (narration.isNotEmpty) ...[
            const SizedBox(width: 14),
            MociPressable(
              key: listenKey,
              onTap: () => ref
                  .read(narratorProvider)
                  .sayAll(narration, ref.read(prefsProvider).lang),
              color: const Color(0xFFFFB020),
              shadowColor: const Color(0xFFE0870B),
              depth: 5,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              semanticLabel: listenLabel,
              clickSound: false,
              cooldown: const Duration(milliseconds: 200),
              minTouch: MociMotion.pressDepth + 64,
              child: const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: GameGlyph(GameGlyphKind.listen, size: 32)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
