import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'game_mode_pill.dart';

/// Pil tab yang tab aktifnya mengikuti rute yang benar-benar tampil.
///
/// Ketukan memakai `pushReplacement` supaya mode berganti tanpa menumpuk
/// riwayat: tombol kembali tetap pulang ke menu sebelumnya.
class RouteModePill extends ConsumerWidget {
  const RouteModePill({
    super.key,
    required this.tabs,
    required this.semanticLabel,
    required this.accent,
  });

  final List<({String label, String route, Widget? icon})> tabs;
  final String semanticLabel;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(currentPathProvider);
    final selected = tabs.indexWhere((tab) => tab.route == path);
    return GameModePill(
      tabs: [
        for (final tab in tabs) GameModeTab(label: tab.label, icon: tab.icon),
      ],
      selected: selected,
      onSelected: (i) => context.pushReplacement(tabs[i].route),
      semanticLabel: semanticLabel,
      accent: accent,
    );
  }
}
