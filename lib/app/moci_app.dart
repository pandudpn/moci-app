import 'package:material_ui/material_ui.dart';

class MociApp extends StatelessWidget {
  const MociApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Moci',
      debugShowCheckedModeBanner: false,
      home: SizedBox.shrink(),
    );
  }
}
