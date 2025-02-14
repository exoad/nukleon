import 'package:project_yellow_cake/engine/engine.dart';

final class BlankItem extends ItemDefinition {
  @override
  String get identifier => "class.items.blank";

  @override
  Class get layer => Class.ITEMS;

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return const SpriteTextureKey("content", spriteName: "Blank");
  }
}
