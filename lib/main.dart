import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app/moci_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MociApp());
}
