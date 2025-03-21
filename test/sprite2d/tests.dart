import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/engine.dart';

import '../test.dart';

void testSprite2d() {
  t("Invalid sprite atlas", () => SpriteAtlas.parseN("sus", "amogus"), throwsException);
  t("Valid no sprites atlas file", !(SpriteAtlas.parseN("sus", """
hello.png
size: 69, 69
format: 4932849203
filter: Nearest, N
repeat: none
""").file.isIncomplete()), isTrue);
  t("Sprite load reactor_items.atlas completes",
      SpriteAtlas.parseAssetsN("assets/textures/reactor_items.atlas"), completes);
  ta(
      "reactor_items.atlas fileName == reactor_items.png",
      () async => (await SpriteAtlas.parseAssetsN("assets/textures/reactor_items.atlas"))
          .file
          .fileName,
      "reactor_items.png");
  ta(
      "reactor_items.atlas file descriptor is proper",
      () async => !(await SpriteAtlas.parseAssetsN("assets/textures/reactor_items.atlas"))
          .file
          .isIncomplete(),
      isTrue);
  ta(
      "reactor_items.atlas texture descriptors are proper",
      () async => !(await SpriteAtlas.parseAssetsN("assets/textures/reactor_items.atlas"))
          .sprites
          .every((SpriteAtlasSpriteTexture texture) => !texture.isIncomplete()),
      isTrue);
  ta("reactor_items.atlas also loaded into bitmap registry", () async {
    await SpriteAtlas.parseAssetsL("assets/textures/reactor_items.atlas");
    return BitmapRegistry.I.tryFind("reactor_items");
  }, isNotNull);
  ta("reactor_items.atlas texture descriptors are proper", () async {
    await SpriteAtlas.parseAssetsL("assets/textures/reactor_items.atlas");
    return SpriteRegistry.I.tryGetFrom("reactor_items", "Empty_Cell");
  }, isNotNull);
}
