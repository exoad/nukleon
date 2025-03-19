import 'dart:math';

import 'package:nukleon/engine/engine.dart';

double mag(double x, double y) {
  return sqrt((x * x) + (y * y));
}

class FittingTransform {
  FittingTransform._();
  static Matrix4 rectInRectCenter(Size bigger, Size rect2) {
    return Matrix4.identity()
      ..translate((bigger.width - rect2.width) / 2, (bigger.height - rect2.height) / 2);
  }

  static Matrix4 rectInRectBottomCenter(Size bigger, Size rect2) {
    return Matrix4.identity()
      ..translate((bigger.width - rect2.width) / 2, bigger.height - rect2.height);
  }

  static Matrix4 rectInRectScaledBottomCenter(Size bigger, Size rect2) {
    double sf = min(bigger.width / rect2.width, bigger.height / rect2.height);
    return Matrix4.identity()
      ..translate(
          (bigger.width - (rect2.width * sf)) / 2, bigger.height - (rect2.height * sf))
      ..scale(sf, sf);
  }
}

extension FitSize on Size {
  double get area => width * height;
}
