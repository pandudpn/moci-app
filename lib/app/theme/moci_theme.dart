import 'package:material_ui/material_ui.dart';

import 'moci_colors.dart';
import 'moci_text.dart';

ThemeData mociTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: MociFonts.nunito,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(seedColor: MociColors.sky),
    // Umpan balik tekan memakai MociPressable, bukan ripple Material.
    splashFactory: NoSplash.splashFactory,
  );
}
