import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/items/classes/classes.dart';

class EmptyCell extends Cell {
  @override
  String get identifier => "game.empty_cell";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("content", spriteName: "Empty_Cell");
  }

  @override
  String get canonicalName => "Empty";

  @override
  String get canonicalLabel => "Nothing here...";

  @override
  Class get layer => Class.BACKDROPS;
}
