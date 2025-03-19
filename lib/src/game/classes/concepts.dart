import 'package:nukleon/src/engine/engine.dart';
import 'package:nukleon/src/game/classes/classes.dart';

class ButtonFacetConcept1 extends ButtonFacet {
  @override
  String get canonicalName => "Button Facet Concept 1";

  @override
  String get identifier => "game.concepts.button1";

  @override
  SpriteSet<ButtonSpriteStates> get spriteSet => SpriteSetAll<ButtonSpriteStates>(
      const SpriteTextureKey("concept_ui", spriteName: "Concept_Button_1"),
      transform: LinearTransformer.identity());
}
