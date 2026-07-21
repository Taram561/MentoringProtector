import 'package:flutter/widgets.dart';

abstract final class Spacing {
  static const double xs  = 4;
  static const double s   = 8;
  static const double m   = 12;
  static const double l   = 16;
  static const double xl  = 24;
  static const double xxl = 32;

  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: l, vertical: m);

  static const EdgeInsets screenPadding = EdgeInsets.all(l);

  static const EdgeInsets sheetPadding =
      EdgeInsets.fromLTRB(l, 0, l, l);
}

