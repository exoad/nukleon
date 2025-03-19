import 'package:nukleon/engine/engine.dart';

extension Matrix4SingleTransformation on Matrix4 {
  SingleLinearTransformer get toLinearTransformer => SingleLinearTransformer(this);
}

abstract class LinearTransformer {
  LinearTransformer();

  Matrix4 resolve(Size canvasSize, Size itemSize);

  static ContextAwareTransformer contextAware(Matrix4 Function(Size, Size) resolver) =>
      ContextAwareTransformer(resolver);

  static SingleLinearTransformer single(Matrix4 transformation) =>
      SingleLinearTransformer(transformation);

  static SingleLinearTransformer identity() => single(Matrix4.identity());
}

class ContextAwareTransformer extends LinearTransformer {
  final Matrix4 Function(Size, Size) resolver;

  ContextAwareTransformer(this.resolver);

  @override
  Matrix4 resolve(Size canvasSize, Size itemSize) {
    return resolver(canvasSize, itemSize);
  }
}

class SingleLinearTransformer extends LinearTransformer {
  final Matrix4 transformation;
  SingleLinearTransformer(this.transformation);

  Matrix4 resolveSingle() {
    return resolve(Size.zero, Size.zero);
  }

  @override
  Matrix4 resolve(Size canvasSize, Size itemSize) {
    return transformation;
  }
}
