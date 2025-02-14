import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/classes/classes.dart';

class BasicTile extends Cell {
  @override
  String get identifier => "class.tiles.basic";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("tiles_content", spriteName: "Basic");
  }

  @override
  String get canonicalName => "";

  @override
  String get canonicalLabel => "";

  @override
  Class get layer => Class.TILES;
}
