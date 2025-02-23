import 'package:auto_injector/auto_injector.dart';
import 'package:shitter/engine/engine.dart';

export "items/items.dart";
export "ui/ui.dart";
export "tiles/tiles.dart";

abstract class Cell extends ItemDefinition {
  String get canonicalName;

  String get canonicalLabel;

  /// If negative, then this is indestructible
  double get maxHealth => 100;
}

extension FindCell on int {
  Cell findCell() => findItemDefinition(Class.ITEMS) as Cell;
}

enum FacetType {
  BUTTON,
  STATIC;
}

abstract class Facet<T> extends ItemDefinition {
  static final AutoInjector M = AutoInjector(tag: "FacetsModule");

  FacetType get type;

  String get canonicalName;

  @override
  @nonVirtual
  Class get layer => Class.UI;

  EdgeInsets get border => EdgeInsets.zero;

  @override
  @nonVirtual
  SpriteTextureKey sprite() {
    throw "This function is not allowed to be implemented in a Facet. Call 'resolveSpriteTexture(Set<$T> states)'";
  }

  SpriteSet<T> get spriteSet;
}

abstract class StaticFacet extends Facet<void> {
  @nonVirtual
  @override
  FacetType get type => FacetType.STATIC;
}

abstract class ButtonFacet extends Facet<ButtonSpriteStates> {
  @nonVirtual
  @override
  FacetType get type => FacetType.BUTTON;
}
