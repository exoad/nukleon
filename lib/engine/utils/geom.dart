import 'dart:math';
import 'dart:ui';

double mag(double x, double y) {
  return sqrt((x * x) + (y * y));
}

extension FitSize on Size {
  double get area => width * height;
}
