import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

import '../app/layout/device_layout.dart';
import '../app/theme/moci_text.dart';
import 'pressable.dart';

/// Dialog Moci, mengikuti `Karyaku.dc.html`: lapisan `rgba(43,35,80,.55)` dan
/// panel putih berradius 40. Mengetuk di luar panel tidak menutupnya, dan
/// tombol back sistem juga tidak; penutupnya tombol di [actions].
abstract final class MociDialog {
  static const _scrim = Color.fromRGBO(43, 35, 80, 0.55);

  /// Tinggi tombol dialog dan area sentuh minimalnya (tablet 64, HP 56).
  static double minTouchFor(BuildContext context) =>
      layoutKindFor(MediaQuery.sizeOf(context)) == LayoutKind.tablet ? 64 : 56;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    required List<Widget> actions,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: _scrim,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (context, _, _) => PopScope(
        canPop: false,
        child: _MociDialogPanel(actions: actions, child: child),
      ),
    );
  }
}

class _MociDialogPanel extends StatelessWidget {
  const _MociDialogPanel({required this.child, required this.actions});

  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      // Di luar panggung: teks tetap ikut sistem sampai 1,3x seperti layarnya.
      data: mq.copyWith(textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3)),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          offset: Offset(0, 20),
                          blurRadius: 50,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(26),
                      child: Semantics(
                        scopesRoute: true,
                        explicitChildNodes: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            child,
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: [
                                for (final a in actions)
                                  SizedBox(
                                    width: actions.length > 1 ? 240 : null,
                                    child: a,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol dialog: tinggi 66, radius 22, bayangan padat 7 (Karyaku).
class MociDialogButton extends StatelessWidget {
  const MociDialogButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    required this.shadowColor,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color shadowColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return MociPressable(
      color: color,
      shadowColor: shadowColor,
      depth: 7,
      minTouch: MociDialog.minTouchFor(context),
      borderRadius: BorderRadius.circular(22),
      semanticLabel: label,
      onTap: onTap,
      child: SizedBox(
        height: 66,
        child: Center(
          child: ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label,
                  maxLines: 1,
                  style: MociText.button.copyWith(
                    fontSize: 21,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
