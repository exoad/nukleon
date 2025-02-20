import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

class Button1 extends ButtonFacet {
  @override
  String get canonicalName => "Button Type 1";

  @override
  String get identifier => "class.ui.button_1";

  @override
  bool get locked => true;

  @override
  EdgeInsets get border => EdgeInsets.all(2);

  @override
  SpriteSet<ButtonSpriteStates> get spriteSet {
    return SpriteSet.resolveWith<ButtonSpriteStates>((Set<ButtonSpriteStates> states) =>
        states.first == ButtonSpriteStates.normal
            ? SpriteTextureKey("ui_content", spriteName: "Button_Facet_1_Normal")
            : SpriteTextureKey("ui_content", spriteName: "Button_Facet_1_Pressed"));
  }
}

@Deprecated("Please use Button1 Class")
class ReactorButton1Normal extends ItemDefinition {
  @override
  String get identifier => "class.ui.button_1#normal";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("ui_content", spriteName: "Reactor_Button_1_Normal");
  }

  @override
  Class get layer => Class.UI;
}

@Deprecated("Please use Button1 Class")
class ReactorButton1Pressed extends ItemDefinition {
  @override
  String get identifier => "class.ui.button_1#pressed";

  @override
  bool get locked => true;

  @override
  SpriteTextureKey sprite() {
    return SpriteTextureKey("ui_content", spriteName: "Reactor_Button_1_Pressed");
  }

  @override
  Class get layer => Class.UI;
}
