import 'package:flutter/widgets.dart';

import '../../../app/theme/moci_colors.dart';
import '../../../app/theme/moci_text.dart';
import '../../../widgets/pressable.dart';
import '../beranda_menu.dart';
import 'menu_card_art.dart';

/// Satu kartu menu: gambar di atas, panel putih berjudul di bawah. Ukuran
/// tablet 236 x 214; ukuran HP 156 x 142 dengan gambar diskalakan 0,66 dan
/// panel hanya berjudul.
class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.menu,
    required this.title,
    required this.sub,
    required this.onTap,
    this.compact = false,
  });

  final BerandaMenu menu;
  final String title;
  final String sub;
  final VoidCallback onTap;

  /// Ukuran HP.
  final bool compact;

  static const _tablet = Size(236, 214);
  static const _phone = Size(156, 142);
  static const _artScale = 156 / 236;

  @override
  Widget build(BuildContext context) {
    final size = compact ? _phone : _tablet;
    final radius = compact ? 26.0 : 34.0;
    return MociPressable(
      color: menu.color,
      shadowColor: menu.shadow,
      depth: compact ? 7 : 10,
      borderRadius: BorderRadius.circular(radius),
      semanticLabel: title,
      onTap: onTap,
      child: SizedBox.fromSize(
        size: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ExcludeSemantics(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _Blob(compact: compact, strong: menu == BerandaMenu.warnai),
                Positioned(
                  left: 0,
                  top: 0,
                  width: menuArtSize.width,
                  height: menuArtSize.height,
                  child: compact
                      ? Transform.scale(
                          scale: _artScale,
                          alignment: Alignment.topLeft,
                          child: MenuCardArt(menu),
                        )
                      : MenuCardArt(menu),
                ),
                compact ? _phonePanel() : _tabletPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabletPanel() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: MociText.title.copyWith(
                  fontSize: title.length > 13 ? 20 : 25,
                  height: 1.12,
                ),
              ),
              Text(
                sub,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.clip,
                style: MociText.label.copyWith(
                  fontSize: 14,
                  color: MociColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phonePanel() {
    return Positioned(
      left: 8,
      right: 8,
      bottom: 8,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MociColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MociText.title.copyWith(
                fontSize: title.length > 12 ? 15 : 17,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lingkaran putih pucat di pojok kanan atas.
class _Blob extends StatelessWidget {
  const _Blob({required this.compact, required this.strong});

  final bool compact;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final d = compact ? 100.0 : 150.0;
    return Positioned(
      right: compact ? -30 : -40,
      top: compact ? -36 : -50,
      width: d,
      height: d,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(255, 255, 255, strong ? .25 : .2),
        ),
      ),
    );
  }
}
