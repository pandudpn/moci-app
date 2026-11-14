import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import 'game_mode_pill.dart';

/// Pil mode yang berpindah rute dengan `pushReplacement`, jadi riwayat mode
/// tidak menumpuk dan tombol kembali tetap menuju Beranda.
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
    final selected = tabs.indexWhere((t) => t.route == path);
    return GameModePill(
      tabs: [for (final t in tabs) GameModeTab(label: t.label, icon: t.icon)],
      selected: selected,
      onSelected: (i) => context.pushReplacement(tabs[i].route),
      semanticLabel: semanticLabel,
      accent: accent,
    );
  }
}
