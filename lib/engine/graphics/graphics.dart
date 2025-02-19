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

extension ConfigurablePaint on Paint {
  void applyConfig(PaintConfig config) {
    isAntiAlias = config.isAntialias;
    filterQuality = config.filterQuality;
  }
}
