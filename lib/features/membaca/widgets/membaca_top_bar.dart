import 'package:flutter/widgets.dart';

import '../../../app/routes.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/game/route_mode_pill.dart';
import '../../../widgets/moci_back_button.dart';
import '../../../widgets/moci_top_bar.dart';

const membacaAccent = Color(0xFFE0661A);

/// Tiga tab mode membaca, dipakai bilah atas dan tes.
List<({String label, String route, Widget? icon})> membacaTabs(
  AppLocalizations l10n,
) => [
  (label: l10n.membacaSukuKata, route: Routes.sukuKata, icon: null),
  (label: l10n.membacaSusunKata, route: Routes.susunKata, icon: null),
  (label: l10n.membacaKalimat, route: Routes.kalimat, icon: null),
];

/// Bilah atas ketiga layar Ayo Membaca: kembali, judul, dan pil mode.
class MembacaTopBar extends StatelessWidget {
  const MembacaTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MociTopBar(
      leading: MociBackButton(semanticLabel: l10n.commonBack),
      title: l10n.membacaTitle,
      trailing: [
        RouteModePill(
          tabs: membacaTabs(l10n),
          semanticLabel: l10n.membacaModes,
          accent: membacaAccent,
        ),
      ],
    );
  }
}
