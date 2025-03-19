/// The sprite2d library manages acccounting for sprites loaded from texture atlases as
/// well as providing a very lightweight way to access and find them.
library;

import 'package:equatable/equatable.dart';
import 'package:nukleon/src/engine/engine.dart';

export "sprite_set.dart";

@immutable
class SpriteTextureKey with EquatableMixin {
  final String key;
  final String spriteName;

  const SpriteTextureKey(this.key, {required this.spriteName});

  @override
  String toString() => "SpriteTextKey[$key,$spriteName]";

  AtlasSprite findTexture() => TextureRegistry.getTextureSprite(this);

  @override
  List<Object?> get props => <Object?>[key, spriteName];
}
