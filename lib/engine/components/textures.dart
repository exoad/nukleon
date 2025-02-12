import 'package:project_yellow_cake/engine/engine.dart';
import "dart:ui" as ui;

class SpriteTextureKey {
  final String key;
  final String spriteName;

  SpriteTextureKey(this.key, {required this.spriteName});

  @override
  String toString() {
    return "SpriteTextKey[$key,$spriteName]";
  }

  AtlasSprite findTexture() {
    return TextureRegistry.getTextureSprite(this);
  }
}

extension AddOnsTextureAtlas on TextureAtlas {
  TextureMap toTextureMap(String identifier) => TextureMap.fromAtlas(identifier, this);
}

class TextureMap {
  final String identifier;
  final ui.Image _atlasImage;
  final Map<String, AtlasSprite> _sprites;

  TextureMap(this.identifier,
      {required ui.Image atlasImage, Map<String, AtlasSprite>? sprites})
      : _sprites = sprites ?? <String, AtlasSprite>{},
        _atlasImage = atlasImage;

  factory TextureMap.fromAtlas(String identifier, TextureAtlas atlas) {
    Map<String, AtlasSprite> sprites = <String, AtlasSprite>{};
    for (AtlasSprite sprite in atlas.sprites) {
      sprites[sprite.name] = sprite;
    }
    return TextureMap(identifier, sprites: sprites, atlasImage: atlas.sprites[0].image);
  }

  ui.Image get atlasImage => _atlasImage;

  /// Lookup [SpriteTextureKey.spriteName] for [spriteName]
  AtlasSprite operator [](String spriteName) {
    AtlasSprite? res = _sprites[spriteName];
    if (res == null) {
      if (Public.panicOnNullTextures) {
        panicNow("Could not find sprite_texture '$spriteName' under '$identifier'");
      }
      logger.warning("Null texutere for '$spriteName' under '$identifier'");
      return TextureRegistry.nullTextureSprite;
    }
    return res;
  }

  void operator []=(String spriteName, AtlasSprite sprite) {
    if (containsKey(spriteName) && Public.warnOnTextureMapDuplicateSprites) {
      logger.warning("Duplicate sprite key '$spriteName' texture_map '$identifier'");
    }
    _sprites[spriteName] = sprite;
  }

  bool containsSprite(AtlasSprite sprite) {
    return _sprites.containsValue(sprite);
  }

  bool containsKey(String key) {
    return _sprites.containsKey(key);
  }

  Iterable<AtlasSprite> get sprites => _sprites.values;
}
