import 'package:flutter/widgets.dart';

import '../beranda_menu.dart';

/// Rail kartu menu: dua baris, diisi per kolom, hanya bisa digulir mendatar
/// dan tanpa scrollbar.
class MenuRail extends StatelessWidget {
  const MenuRail({
    super.key,
    required this.cardWidth,
    required this.cardHeight,
    required this.gap,
    required this.padding,
    required this.itemBuilder,
  });

  final double cardWidth;
  final double cardHeight;
  final double gap;
  final EdgeInsets padding;
  final Widget Function(BuildContext context, BerandaMenu menu) itemBuilder;

  @override
  Widget build(BuildContext context) {
    const menus = BerandaMenu.values;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < menus.length; i += 2) ...[
              if (i > 0) SizedBox(width: gap),
              SizedBox(
                width: cardWidth,
                child: Column(
                  children: [
                    SizedBox(
                      height: cardHeight,
                      child: itemBuilder(context, menus[i]),
                    ),
                    SizedBox(height: gap),
                    SizedBox(
                      height: cardHeight,
                      child: itemBuilder(context, menus[i + 1]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
