import 'package:auto_injector/auto_injector.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:nukleon/src/engine/engine.dart';

export "items/items.dart";
export "ui/ui.dart";
export "tiles/tiles.dart";
export "concepts.dart";

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
  bool get locked =>
      false; // ui facets should be default to this (they should always be able to be styled)

  @override
  @nonVirtual
  SpriteTextureKey sprite() {
    throw "This function is not allowed to be implemented in a Facet. Call 'resolveSpriteTexture(Set<$T> states)'";
  }

  SpriteSet<T> get spriteSet;

  FacetHints get facetHints => FacetHints.normal;
}

@immutable
final class FacetHints with EquatableMixin {
  final BoolList _flags;

  static final FacetHints normal = FacetHints.fromBools();

  static final FacetHints noCenter = FacetHints.fromBools(c: false);

  FacetHints(BoolList flags)
      : _flags = flags,
        assert(flags.length == 9,
            "FacetHints renders a 9 Nine-Slice which can only support 9 flags. In the following order: [c,tl,tr,bl,br,sl,sr,st,sb]");

  FacetHints.fromBools(
      {bool c = true,
      bool tl = true,
      bool tr = true,
      bool bl = true,
      bool br = true,
      bool sl = true,
      bool sr = true,
      bool st = true,
      bool sb = true})
      : _flags = BoolList.of(<bool>[c, tl, tr, bl, br, sl, sr, st, sb]);

  bool get all => corners && horizontalSides && verticalSides && center;

  bool get corners => topLeft && topRight && bottomRight && bottomLeft;

  bool get horizontalSides => sideTop && sideBottom;

  bool get verticalSides => sideLeft && sideRight;

  bool get center => _flags[0];

  bool get topLeft => _flags[1];

  bool get topRight => _flags[2];

  bool get bottomLeft => _flags[3];

  bool get bottomRight => _flags[4];

  bool get sideLeft => _flags[5];

  bool get sideRight => _flags[6];

  bool get sideTop => _flags[7];

  bool get sideBottom => _flags[8];

  int calculateCornerTransforms() {
    int start = 16;
    // not gonna use a loop to maintain cache hits
    if (!topLeft) {
      start -= 4;
    }
    if (!topRight) {
      start -= 4;
    }
    if (!bottomLeft) {
      start -= 4;
    }
    if (!bottomRight) {
      start -= 4;
    }
    return start;
  }

  int calculateVerticalSideTransforms() {
    int start = 8;
    if (!sideLeft) {
      start -= 4;
    }
    if (!sideRight) {
      start -= 4;
    }
    return start;
  }

  int calculateHorizontalSideTransforms() {
    int start = 8;
    if (!sideTop) {
      start -= 4;
    }
    if (!sideTop) {
      start -= 4;
    }
    return start;
  }

  @override
  List<Object?> get props => <Object?>[_flags];
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
