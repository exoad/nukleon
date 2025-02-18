import 'package:shitter/engine/engine.dart';

extension MatrixOpsExt on Matrix4 {
  Matrix4 scaleFromCenter(
      {required double sigmaX,
      required double sigmaY,
      double? childWidth,
      double? childHeight,
      required double parentWidth,
      required double parentHeight}) {
    return Matrix4.translationValues(parentWidth / 2, parentHeight / 2, 0) *
        Matrix4.translationValues(
            -(childWidth ?? parentWidth) / 2, -(childHeight ?? parentHeight) / 2, 0) *
        Matrix4.identity().scaled(sigmaX, sigmaY, 0) *
        this;
  }
}
