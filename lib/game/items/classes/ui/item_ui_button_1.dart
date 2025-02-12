import 'package:project_yellow_cake/engine/engine.dart';

class ReactorButton1 extends ItemDefinition {
  @override
  String get identifier => "game.ui_button_1";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("content", spriteName: "Reactor_Button_1");
  }

  @override
  Class get layer => Class.UI;
}
