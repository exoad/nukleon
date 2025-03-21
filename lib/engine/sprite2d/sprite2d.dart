/// The sprite2d library manages acccounting for sprites loaded from texture atlases as
/// well as providing a very lightweight way to access and find them.
library;

import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/engine.dart';
export "package:nukleon/engine/sprite2d/facets/facets.dart";

export "sprite_set.dart";
export "sprite_atlas.dart";

@immutable
class Sprite with EquatableMixin {
  /// Represents where this sprite is located on the texture atlas
  final Rect src;

  /// A strict rule of which texture atlas this sprite should pull from
  final String textureAtlas;

  /// The identifier is used not only to identify this Sprite, but also used to identify the texture it belongs to.
  final String identifier;

  const Sprite(this.textureAtlas, this.src, this.identifier);

  Sprite.fromComponents(this.identifier, this.textureAtlas,
      {required Vector2 srcPosition, required Size srcSize})
      : src = Rect.fromLTWH(srcPosition.x, srcPosition.y, srcSize.width, srcSize.height);

  ui.Image get texture => BitmapRegistry.I.findImage(identifier);

  @override
  String toString() {
    return "Sprite2D '$identifier'::'$textureAtlas' [${src.topLeft} -- ${src.bottomRight}]";
  }

  @override
  List<Object?> get props => <Object?>[src, identifier];
}

@immutable
class SpriteTextureKey with EquatableMixin {
  final String key;
  final String spriteName;

  const SpriteTextureKey(this.key, {required this.spriteName});

  @override
  String toString() => "SpriteTextKey[$key,$spriteName]";

  Sprite findTexture() => SpriteRegistry.I.getFrom(key, spriteName);

  @override
  List<Object?> get props => <Object?>[key, spriteName];
}
