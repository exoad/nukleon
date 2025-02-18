import 'package:flutter/widgets.dart';
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
