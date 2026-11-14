import 'package:flutter/widgets.dart';

import '../theme/menu_theme.dart';
import 'device_layout.dart';

/// Panggung desain: latar penuh layar, isi berukuran dasar yang diskalakan
/// ke area aman perangkat.
class MociStage extends StatefulWidget {
  const MociStage({
    super.key,
    required this.theme,
    required this.tablet,
    this.phone,
    this.textScaleCap = 1.0,
  });

  /// Kunci DecoratedBox latar, untuk tes.
  @visibleForTesting
  static const backgroundKey = ValueKey('moci-stage-background');

  final MenuTheme theme;
  final WidgetBuilder tablet;
  final WidgetBuilder? phone;
  final double textScaleCap;

  @override
  State<MociStage> createState() => _MociStageState();
}

class _MociStageState extends State<MociStage> {
  bool _warned = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screen = mq.size;
    final deviceKind = layoutKindFor(screen);

    final WidgetBuilder builder;
    final LayoutKind kind;
    final Size base;
    if (deviceKind == LayoutKind.phone && widget.phone != null) {
      builder = widget.phone!;
      kind = LayoutKind.phone;
      base = kPhoneBase;
    } else {
      builder = widget.tablet;
      kind = LayoutKind.tablet;
      base = kTabletBase;
      if (deviceKind == LayoutKind.phone && !_warned) {
        _warned = true;
        debugPrint('Layout HP belum didesain: ${widget.theme.name}');
      }
    }

    final fit = fitStage(screen: screen, safe: mq.padding, base: base);
    final textScaler = widget.textScaleCap == 1.0
        ? TextScaler.noScaling
        : mq.textScaler.clamp(maxScaleFactor: widget.textScaleCap);

    return MenuThemeScope(
      theme: widget.theme,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              key: MociStage.backgroundKey,
              decoration: widget.theme.decoration,
            ),
          ),
          Positioned(
            left: fit.origin.dx,
            top: fit.origin.dy,
            width: fit.size.width,
            height: fit.size.height,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox.fromSize(
                size: base,
                child: MediaQuery(
                  data: mq.copyWith(
                    size: base,
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    textScaler: textScaler,
                  ),
                  child: MociLayoutScope(
                    kind: kind,
                    scale: fit.scale,
                    child: Builder(builder: builder),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MociLayoutScope extends InheritedWidget {
  const MociLayoutScope({
    super.key,
    required this.kind,
    required this.scale,
    required super.child,
  });

  final LayoutKind kind;
  final double scale;

  static MociLayoutScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MociLayoutScope>();
    assert(
      scope != null,
      'MociLayoutScope tidak ditemukan; bungkus dengan MociStage.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(MociLayoutScope old) =>
      kind != old.kind || scale != old.scale;
}

extension MociLayoutContext on BuildContext {
  LayoutKind get layoutKind => MociLayoutScope.of(this).kind;
  double get stageScale => MociLayoutScope.of(this).scale;
}

class MenuThemeScope extends InheritedWidget {
  const MenuThemeScope({super.key, required this.theme, required super.child});

  final MenuTheme theme;

  static MenuTheme of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MenuThemeScope>();
    assert(
      scope != null,
      'MenuThemeScope tidak ditemukan; bungkus dengan MociStage.',
    );
    return scope!.theme;
  }

  @override
  bool updateShouldNotify(MenuThemeScope old) => theme != old.theme;
}
