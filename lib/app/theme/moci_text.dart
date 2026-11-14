import 'package:flutter/widgets.dart';

import 'moci_colors.dart';

abstract final class MociFonts {
  static const fredoka = 'Fredoka';
  static const nunito = 'Nunito';
}

abstract final class MociText {
  static const title = TextStyle(
    fontFamily: MociFonts.fredoka,
    fontWeight: FontWeight.w700,
    fontSize: 46,
    color: MociColors.ink,
  );
  static const button = TextStyle(
    fontFamily: MociFonts.fredoka,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: MociColors.ink,
  );
  static const body = TextStyle(
    fontFamily: MociFonts.nunito,
    fontWeight: FontWeight.w800,
    fontSize: 23,
    color: MociColors.ink,
  );
  static const label = TextStyle(
    fontFamily: MociFonts.nunito,
    fontWeight: FontWeight.w800,
    fontSize: 17,
    color: MociColors.ink,
  );
  static const bigNumber = TextStyle(
    fontFamily: MociFonts.fredoka,
    fontWeight: FontWeight.w700,
    fontSize: 240,
    color: MociColors.ink,
  );
}
