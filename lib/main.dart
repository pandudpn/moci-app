import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app/moci_app.dart';

void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final entry in const {
      'Fredoka': 'assets/fonts/OFL-Fredoka.txt',
      'Nunito': 'assets/fonts/OFL-Nunito.txt',
    }.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks([entry.key], text);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _registerFontLicenses();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MociApp());
}
