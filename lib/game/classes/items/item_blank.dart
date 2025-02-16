import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/classes/classes.dart';

final class BlankItem extends Cell {
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

  @override
  int? get preferredID => 0;

  @override
  String get canonicalLabel => "";

  @override
  String get canonicalName => "Emptiness";

  @override
  double get maxHealth => 0;
}
