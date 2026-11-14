import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType;

/// Dialog lebar untuk pemilih halaman dan detail karya: lapisan
/// `rgba(43,35,80,.55)`, panel putih, dan teks dibatasi 1,3x seperti
/// `MociDialog`. Mengetuk di luar panel tidak menutupnya.
Future<T?> showWideDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  double maxWidth = 1020,
  double radius = 36,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: const Color.fromRGBO(43, 35, 80, 0.55),
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
    pageBuilder: (context, _, _) {
      final mq = MediaQuery.of(context);
      return PopScope(
        canPop: false,
        child: MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Material(
                    type: MaterialType.transparency,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(radius),
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
                            child: builder(context),
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
    },
  );
}
