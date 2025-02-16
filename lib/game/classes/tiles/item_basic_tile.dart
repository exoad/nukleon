import 'package:project_yellow_cake/engine/engine.dart';

class BasicTile extends ItemDefinition {
  @override
  String get identifier => "class.tiles.basic";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("tiles_content", spriteName: "Basic");
  }

  @override
  Class get layer => Class.TILES;
}
