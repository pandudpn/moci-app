import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layout/moci_stage.dart';
import '../../app/routes.dart';
import '../../app/theme/menu_theme.dart';
import '../../core/progress/progress_controller.dart';
import '../../widgets/moci_back_button.dart';
import '../../widgets/moci_mascot.dart';
import '../../widgets/moci_top_bar.dart';

/// Layar sementara untuk rute yang belum dibangun.
class ComingSoonScreen extends ConsumerStatefulWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.theme,
    required this.route,
  });

  final String title;
  final MenuTheme theme;
  final String route;

  @override
  ConsumerState<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends ConsumerState<ComingSoonScreen> {
  @override
  void initState() {
    super.initState();
    // Beranda dan Hebat bukan kegiatan yang bisa dilanjutkan.
    final isActivity =
        routeKindOf(widget.route) == RouteKind.play &&
        widget.route != Routes.beranda &&
        widget.route != Routes.hebat;
    if (isActivity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(progressProvider.notifier).setLastActivity(widget.route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body(BuildContext _) => Column(
      children: [
        MociTopBar(
          leading: widget.route == Routes.beranda
              ? null
              : const MociBackButton(),
          title: widget.title,
        ),
        const Expanded(child: Center(child: MociMascot())),
      ],
    );
    return MociStage(theme: widget.theme, tablet: body, phone: body);
  }
}
