import 'package:project_yellow_cake/engine/engine.dart';

class ReactorButton1Normal extends ItemDefinition {
  @override
  String get identifier => "game.ui_button_1#normal";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("ui_content", spriteName: "Reactor_Button_1_Normal");
  }

  @override
  Class get layer => Class.UI;
}

class ReactorButton1Pressed extends ItemDefinition {
  @override
  String get identifier => "game.ui_button_1#pressed";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("ui_content", spriteName: "Reactor_Button_1_Pressed");
  }

  @override
  Class get layer => Class.UI;
}
