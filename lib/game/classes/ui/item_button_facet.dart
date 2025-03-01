import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

class Button1 extends ButtonFacet {
  static final Button1 _i = Button1._();

  Button1._();

  factory Button1() => _i;

  @override
  String get canonicalName => "Button Type 1";

  @override
  String get identifier => "class.ui.button_1";

  @override
  bool get locked => true;

  @override
  EdgeInsets get border => EdgeInsets.symmetric(vertical: 4, horizontal: 8);

  @override
  SpriteSet<ButtonSpriteStates> get spriteSet =>
      SpriteSet.resolveWith<ButtonSpriteStates>(
          (Set<ButtonSpriteStates> states) =>
              states.first == ButtonSpriteStates.normal || states.isEmpty
                  ? SpriteTextureKey("ui_content", spriteName: "Button_Facet_1_Normal")
                  : SpriteTextureKey("ui_content", spriteName: "Button_Facet_1_Pressed"),
          transformationResolver: (Set<ButtonSpriteStates> states) =>
              states.first == ButtonSpriteStates.normal
                  ? LinearTransformer.identity()
                  : LinearTransformer.single(Matrix4.translationValues(0, 1, 0)));
}
