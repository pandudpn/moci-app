import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/prefs/prefs_controller.dart';
import '../l10n/l10n.dart';
import 'theme/moci_theme.dart';

class MociApp extends ConsumerWidget {
  const MociApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(prefsProvider.select((p) => p.lang));
    return MaterialApp(
      onGenerateTitle: (c) => c.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: mociTheme(),
      locale: Locale(lang.name),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: const SizedBox.shrink(),
    );
  }
}
