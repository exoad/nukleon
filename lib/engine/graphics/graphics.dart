import 'dart:ui';

import 'package:shitter/engine/engine.dart';

export "nulls.dart";
export "ui.dart";

extension FragmentShaderExtension on FragmentShader {
  void operator []=(int index, double value) {
    setFloat(index, value);
  }
}

final class G {
  G._();

  static Paint get fasterPainter {
    return Paint()
      ..filterQuality = FilterQuality.values[Public.textureFilter]
      ..isAntiAlias = false;
  }

  static RSTransform rstNoRot(double x, double y, [double scale = 1]) {
    return RSTransform.fromComponents(
        rotation: 0, scale: scale, anchorX: 0, anchorY: 0, translateX: x, translateY: y);
  }
}

final class C {
  C._();

  static const Color magenta = Color.fromARGB(255, 255, 0, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
}

class RenderingHints {
  FilterQuality filterQuality;
  bool isAntialias;
  bool autoCenter;
  SpriteRenderStrategy spriteRenderStrategy;

  static final RenderingHints global = RenderingHints(
      filterQuality: FilterQuality.none, isAntialias: false, autoCenter: true);

  RenderingHints(
      {required this.filterQuality,
      required this.isAntialias,
      this.autoCenter = false,
      this.spriteRenderStrategy = SpriteRenderStrategy.RAW});
}

abstract class ContentRenderer extends CustomPainter {
  final RenderingHints? _config;

  const ContentRenderer({RenderingHints? config}) : _config = config;

  RenderingHints get config => _config ?? RenderingHints.global;
}

enum SpriteRenderStrategy {
  /// Signifies that no transformations should be done by the renderer if the renderer doesn't need to.
  RAW,

  /// Signifies that the renderer should expand the child to fill the remaining space allowed
  FILL;
}

mixin RenderingMixin on ContentRenderer {
  Paint applyConfig(Paint paint) => paint
    ..isAntiAlias = config.isAntialias
    ..filterQuality = config.filterQuality;
}

extension ConfigurablePaint on Paint {
  void applyConfig(RenderingHints config) {
    isAntiAlias = config.isAntialias;
    filterQuality = config.filterQuality;
  }
}
