import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Jam gerak suasana: satu ticker untuk semua lapisan di satu layar.
///
/// Dengan gerak dikurangi (`MediaQuery.disableAnimations`) ticker tidak jalan
/// sama sekali, jadi layar tampil persis seperti versi diamnya.
class AmbientMotion extends StatefulWidget {
  const AmbientMotion({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientMotion> createState() => _AmbientMotionState();
}

class _AmbientMotionState extends State<AmbientMotion>
    with SingleTickerProviderStateMixin {
  late final _clock = AmbientClock(createTicker(_tick));
  bool _moving = false;

  void _tick(Duration elapsed) =>
      _clock.advance(elapsed.inMicroseconds / Duration.microsecondsPerSecond);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final moving = !MediaQuery.disableAnimationsOf(context);
    if (moving == _moving) return;
    _moving = moving;
    if (moving) {
      _clock.start();
    } else {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      AmbientScope(clock: _clock, moving: _moving, child: widget.child);
}

/// Detik berjalan sejak layar dibuka; memberi tahu pendengarnya tiap tick.
class AmbientClock extends ChangeNotifier implements ValueListenable<double> {
  AmbientClock(this._ticker);

  final Ticker _ticker;
  double _value = 0;

  @override
  double get value => _value;

  void start() {
    if (!_ticker.isActive) _ticker.start();
  }

  /// Dipanggil saat build; cukup sunyikan nilai, jangan beri tahu pendengar
  /// (membangun ulang di tengah build akan gagal). Lapisan yang bergerak
  /// berganti sendiri lewat [AmbientScope].
  void stop() {
    if (_ticker.isActive) _ticker.stop();
    _value = 0;
  }

  void advance(double seconds) {
    _value = seconds;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    _ticker.dispose();
    super.dispose();
  }
}

class AmbientScope extends InheritedWidget {
  const AmbientScope({
    super.key,
    required this.clock,
    required this.moving,
    required super.child,
  });

  final ValueListenable<double> clock;
  final bool moving;

  static AmbientScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AmbientScope>();

  @override
  bool updateShouldNotify(AmbientScope old) =>
      clock != old.clock || moving != old.moving;
}

/// Satu lapisan yang ikut jam suasana. Tanpa gerak, [child] tampil apa adanya.
class AmbientLayer extends StatelessWidget {
  const AmbientLayer({super.key, required this.builder, required this.child});

  /// [seconds] = detik berjalan; [child] sudah dibungkus lapisan repaint.
  final Widget Function(BuildContext context, double seconds, Widget child)
  builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = AmbientScope.maybeOf(context);
    if (scope == null || !scope.moving) return child;
    return AnimatedBuilder(
      animation: scope.clock,
      // Lapisan repaint di dalam Transform: gambar di-cache, yang bergerak
      // hanya posisinya.
      child: RepaintBoundary(child: child),
      builder: (context, cached) =>
          builder(context, scope.clock.value, cached!),
    );
  }
}

/// Geser awan (px) pada detik [t]. Awan mulai di [startX] — posisi diamnya —
/// lalu meluncur ke kanan; setelah lewat [to] ia muncul lagi di [from].
double driftOffset({
  required double startX,
  required double from,
  required double to,
  required double period,
  required double t,
}) {
  final span = to - from;
  final travelled = (startX - from + span * ((t / period) % 1)) % span;
  return from + travelled - startX;
}

/// Naik-turun 0 → -[amplitude] → 0 tiap [period] detik (keyframes bob).
double bobOffset({
  required double t,
  required double amplitude,
  required double period,
  double delay = 0,
}) {
  final p = ((t + delay) / period) % 1;
  final w = p < .5 ? p * 2 : (1 - p) * 2;
  return -amplitude * Curves.easeInOut.transform(w);
}

/// Kelip bintang: opacity 0,35 → 1 dan skala 0,75 → 1,1 tiap [period] detik.
({double opacity, double scale}) twinkleAt({
  required double t,
  required double period,
  double delay = 0,
}) {
  final p = ((t + delay) / period) % 1;
  final w = (1 - math.cos(p * 2 * math.pi)) / 2;
  return (opacity: .35 + .65 * w, scale: .75 + .35 * w);
}

/// Goyang gelembung -2° → 2° tiap [period] detik. Fasenya digeser seperempat
/// putaran supaya bingkai pertama tepat 0°, sama dengan versi diam.
double wobbleAngle({required double t, required double period}) {
  final p = ((t / period) + .25) % 1;
  final w = p < .5 ? p * 2 : (1 - p) * 2;
  final eased = Curves.easeInOut.transform(w);
  return (-2 + 4 * eased) * math.pi / 180;
}

/// Sudut putar matahari (radian) pada detik [t].
double sunAngle({required double t, required double period}) =>
    (t / period) % 1 * 2 * math.pi;
