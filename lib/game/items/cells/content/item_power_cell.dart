import 'package:project_yellow_cake/engine/components/textures.dart';
import 'package:project_yellow_cake/game/items/cells/cells.dart';

class ReactorCell extends Cell {
  @override
  String get identifier => "game.power_cell";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("content", spriteName: "Power_Cell");
  }

  @override
  String get canonicalLabel => "Power Cell";

  @override
  String get canonicalName => "A cell";
}
