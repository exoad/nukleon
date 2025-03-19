import 'package:nukleon/src/engine/engine.dart';

class BasicTile extends ItemDefinition {
  @override
  String get identifier => "class.tiles.basic";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("tiles_content", spriteName: "Basic_Tile");
  }

  @override
  Class get layer => Class.TILES;
}
