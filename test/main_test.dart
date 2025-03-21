import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/engine.dart';

import 'scene2d/tests.dart';
import 'sprite2d/tests.dart';

void main() async {
  await Engine.initializeEngine(initializeTextureRegistry: false);
  group("Scene2d", testScene2d);
  group("Sprite2d", testSprite2d);
}
