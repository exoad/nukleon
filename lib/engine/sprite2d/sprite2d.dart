import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/engine.dart';

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
