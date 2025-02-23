import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

class BorderPrototype extends StaticFacet {
  @override
  String get canonicalName => "Border Proto";

  @override
  String get identifier => "game.experimental.border";

  @override
  bool get locked => false;

  @override
  SpriteSet<void> get spriteSet =>
      SpriteSetAll(SpriteTextureKey("ui_content", spriteName: "Border_Prototype"),
          transform: LinearTransformer.identity());

  @override
  FacetHints get facetHints => FacetHints.noCenter;
}
