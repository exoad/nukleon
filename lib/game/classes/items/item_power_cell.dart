import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/classes/classes.dart';

class UraniumCell extends Cell {
  @override
  String get identifier => "class.items.uranium_fuel_cell";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("content", spriteName: "Reactor_Cell_Uranium");
  }

  @override
  String get canonicalLabel => "Uranium Fuel Cell";

  @override
  String get canonicalName => "Uranium Fuel Cell";

  @override
  Class get layer => Class.ITEMS;
}

class UraniumEnhancedCell extends Cell {
  @override
  String get identifier => "game.uranium_enhanced_fuel_cell";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("content", spriteName: "Reactor_Cell_Uranium_Enhanced");
  }

  @override
  String get canonicalLabel => "Uranium Fuel Cell (but better)";

  @override
  String get canonicalName => "Enhanced Uranium Fuel Cell";

  @override
  Class get layer => Class.ITEMS;
}
