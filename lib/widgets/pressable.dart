import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/layout/moci_stage.dart';
import '../app/theme/moci_colors.dart';
import '../app/theme/moci_motion.dart';
import '../core/audio/audio_providers.dart';
import '../core/audio/sfx.dart';
import '../core/providers.dart';

/// Kotak mainan: bayangan padat tanpa blur lurus ke bawah, turun 5 pt dan
/// mengecil saat disentuh. Bayangan tidak memakan tempat tata letak.
class MociPressable extends ConsumerStatefulWidget {
  const MociPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.color = MociColors.white,
    this.shadowColor,
    this.depth = 7,
    this.borderRadius = const BorderRadius.all(Radius.circular(26)),
    this.semanticLabel,
    this.clickSound = true,
    this.cooldown = MociMotion.tapCooldown,
    this.minTouch,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  /// Bawaan: warna bayangan tema menu saat ini.
  final Color? shadowColor;
  final double depth;
  final BorderRadius borderRadius;
  final String? semanticLabel;
  final bool clickSound;

  /// Ketukan dalam rentang ini sejak ketukan yang diterima terakhir diabaikan.
  final Duration cooldown;

  /// Area sentuh minimal (persegi). Tampilan tetap di tengah dan tidak berubah.
  final double? minTouch;

  @override
  ConsumerState<MociPressable> createState() => _MociPressableState();
}

class _MociPressableState extends ConsumerState<MociPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: MociMotion.press,
  );
  DateTime? _lastTap;

  bool get _enabled => widget.onTap != null;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MociPressable old) {
    super.didUpdateWidget(old);
    // Dimatikan di tengah tekanan (mis. penyimpanan mulai): tekanan dilepas,
    // kalau tidak kotak tertinggal mengecil sampai disentuh lagi.
    if (old.onTap != null && widget.onTap == null) _press.reverse();
  }

  void _down(PointerDownEvent _) {
    if (_enabled) _press.forward();
  }

  void _release() => _press.reverse();

  void _tap() {
    final onTap = widget.onTap;
    if (onTap == null) return;
    final now = ref.read(clockProvider).now();
    final last = _lastTap;
    // Jam perangkat bisa mundur (zona waktu, koreksi NTP); selisih mundur
    // dihitung jeda lewat supaya tombol tidak membeku.
    final since = now.difference(last ?? now);
    if (last != null && since >= Duration.zero && since < widget.cooldown) {
      return;
    }
    _lastTap = now;
    if (widget.clickSound) {
      ref.read(audioServiceProvider).playSfx(Sfx.klik);
    }
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final shadow =
        widget.shadowColor ??
        MenuThemeScope.maybeOf(context)?.shadow ??
        MociColors.neutralShadow;
    Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: Offset(0, widget.depth),
            blurRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );
    box = AnimatedBuilder(
      animation: _press,
      child: box,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_press.value);
        final scale = 1 - (1 - MociMotion.pressScale) * t;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(0, MociMotion.pressDepth * t, 0)
            ..scaleByDouble(scale, scale, 1, 1),
          child: child,
        );
      },
    );
    if (!_enabled) box = Opacity(opacity: 0.5, child: box);
    final min = widget.minTouch;
    if (min != null) {
      box = ConstrainedBox(
        constraints: BoxConstraints(minWidth: min, minHeight: min),
        child: Center(widthFactor: 1, heightFactor: 1, child: box),
      );
    }
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      // Listener, bukan onTapDown: onTapDown baru terpanggil setelah 100 ms,
      // sedangkan tombol harus langsung terasa tertekan.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerUp: (_) => _release(),
        onPointerCancel: (_) => _release(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: box,
        ),
      ),
    );
  }
}
