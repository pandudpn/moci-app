import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';
export 'panggilan.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
