import 'package:flutter/animation.dart';

abstract final class MociMotion {
  static const press = Duration(milliseconds: 120);
  static const double pressDepth = 5.0;
  static const double pressScale = 0.97;
  static const popIn = Duration(milliseconds: 450);
  static const popCurve = Cubic(0.3, 1.6, 0.5, 1);
  static const shake = Duration(milliseconds: 450);
  static const tapCooldown = Duration(milliseconds: 400);
}
