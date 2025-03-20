import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/engine/sprite2d/sprite_atlas.dart';

import '../test.dart';

void testSprite2d() {
  Engine.initializeEngine(initializeTextureRegistry: false);
  t("Invalid sprite atlas", () => SpriteAtlas.parseN("sus", "amogus"), throwsException);
  t("Valid no sprites atlas file", !(SpriteAtlas.parseN("sus", """
hello.png
size: 69, 69
format: 4932849203
filter: Nearest, N
repeat: none
""").file.isIncomplete()), true);
  t("Sprite load reactor_items.atlas completes",
      SpriteAtlas.parseAssetsN("assets/images/textures/reactor_items.atlas"), completes);
  ta(
      "reactor_items.atlas fileName == reactor_items.png",
      () async =>
          (await SpriteAtlas.parseAssetsN("assets/images/textures/reactor_items.atlas"))
              .file
              .fileName,
      "reactor_items.png");
  ta(
      "reactor_items.atlas file descriptor is proper",
      () async =>
          !(await SpriteAtlas.parseAssetsN("assets/images/textures/reactor_items.atlas"))
              .file
              .isIncomplete(),
      true);
  ta(
      "reactor_items.atlas texture descriptors are proper",
      () async =>
          !(await SpriteAtlas.parseAssetsN("assets/images/textures/reactor_items.atlas"))
              .sprites
              .every((SpriteAtlasSpriteTexture texture) => !texture.isIncomplete()),
      true);
  ta("reactor_items.atlas also loaded into bitmap registry", () async {
    await SpriteAtlas.parseAssetsL("assets/images/textures/reactor_items.atlas");
    return BitmapRegistry.I.tryFind("reactor_items");
  }, isNotNull);
}
