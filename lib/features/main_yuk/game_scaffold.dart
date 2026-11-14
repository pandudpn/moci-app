import 'package:flutter/widgets.dart';

import '../../app/layout/device_layout.dart';
import '../../app/layout/moci_stage.dart';
import '../../app/theme/menu_theme.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_top_bar.dart';

/// Kerangka semua layar permainan Main Yuk: panggung bertema, bilah atas
/// dengan tombol kembali, lalu isi yang ditata layar di atasnya.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.theme,
    required this.title,
    this.trailing = const [],
    required this.children,
  });

  static const barKey = ValueKey('game-top-bar');

  final MenuTheme theme;
  final String title;
  final List<Widget> trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return MociStage(
      theme: theme,
      tablet: (context) => SizedBox.fromSize(
        size: kTabletBase,
        child: Stack(
          children: [
            Positioned(
              key: barKey,
              left: 0,
              right: 0,
              top: 0,
              child: MociTopBar(
                leading: const MociBackButton(),
                title: title,
                trailing: trailing,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}
