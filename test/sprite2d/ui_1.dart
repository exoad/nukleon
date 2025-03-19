import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/engine/sprite2d/sprite_atlas.dart';

void main() async {
  await Engine.initializeEngine(initializeTextureRegistry: false);
  SpriteAtlas.parseAndLoadFromAssets("assets/images/textures/icons_content.atlas");
}
