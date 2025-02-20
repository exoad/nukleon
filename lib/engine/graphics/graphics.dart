import 'package:shitter/engine/engine.dart';

export "nulls.dart";
export "ui.dart";

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

class PaintConfig {
  FilterQuality filterQuality;
  bool isAntialias;

  static final PaintConfig global =
      PaintConfig(filterQuality: FilterQuality.none, isAntialias: false);

  PaintConfig({required this.filterQuality, required this.isAntialias});
}

abstract class ContentRenderer extends CustomPainter {
  final PaintConfig? _config;

  const ContentRenderer({PaintConfig? config}) : _config = config;

  PaintConfig get config => _config ?? PaintConfig.global;
}

mixin RenderingMixin on ContentRenderer {
  Paint applyConfig(Paint paint) => paint
    ..isAntiAlias = config.isAntialias
    ..filterQuality = config.filterQuality;
}

extension ConfigurablePaint on Paint {
  void applyConfig(PaintConfig config) {
    isAntiAlias = config.isAntialias;
    filterQuality = config.filterQuality;
  }
}
