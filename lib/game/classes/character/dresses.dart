import 'package:nukleon/engine/engine.dart';

class DressesUniform1 extends ItemDefinition {
  @override
  String get identifier => "game.character.dresses.uniform_1";

  @override
  Class get layer => Class.CHARACTER;

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("character", spriteName: "uniform_1");
  }
}
