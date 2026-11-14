import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum LayoutKind { tablet, phone }

const Size kTabletBase = Size(1180, 820);
const Size kPhoneBase = Size(844, 390);

/// Tablet kalau sisi terpendek layar >= 600 dp.
LayoutKind layoutKindFor(Size screen) =>
    screen.shortestSide >= 600 ? LayoutKind.tablet : LayoutKind.phone;

class StageFit {
  const StageFit({
    required this.scale,
    required this.origin,
    required this.size,
  });

  final double scale;
  final Offset origin;
  final Size size;
}

/// Skala proporsional [base] ke area aman, dipusatkan di dalamnya.
///
/// Inset bawah tidak mengurangi tinggi: indikator home hanya garis tipis di
/// atas panggung, dan desain sudah punya margin bawahnya sendiri. Notch,
/// Dynamic Island, dan lubang kamera (kiri, kanan, atas) tetap dihormati.
StageFit fitStage({
  required Size screen,
  required EdgeInsets safe,
  required Size base,
}) {
  final avail = Size(
    screen.width - safe.left - safe.right,
    screen.height - safe.top,
  );
  final scale = math.min(avail.width / base.width, avail.height / base.height);
  final size = Size(base.width * scale, base.height * scale);
  final origin = Offset(
    safe.left + (avail.width - size.width) / 2,
    safe.top + (avail.height - size.height) / 2,
  );
  return StageFit(scale: scale, origin: origin, size: size);
}
