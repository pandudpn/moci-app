import 'package:material_ui/material_ui.dart';

import 'theme/moci_theme.dart';

class MociApp extends StatelessWidget {
  const MociApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moci',
      debugShowCheckedModeBanner: false,
      theme: mociTheme(),
      home: const SizedBox.shrink(),
    );
  }
}
