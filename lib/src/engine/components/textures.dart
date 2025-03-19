import 'package:nukleon/src/engine/engine.dart';
import "dart:ui" as ui;

extension AddOnsTextureAtlas on TextureAtlas {
  TextureMap toTextureMap(String identifier) => TextureMap.fromAtlas(identifier, this);
}

class TextureMap {
  final String identifier;
  final Map<String, AtlasSprite> _sprites;

  TextureMap(this.identifier,
      {required ui.Image atlasImage, Map<String, AtlasSprite>? sprites})
      : _sprites = sprites ?? <String, AtlasSprite>{};

  factory TextureMap.fromAtlas(String identifier, TextureAtlas atlas) {
    Map<String, AtlasSprite> sprites = <String, AtlasSprite>{};
    for (AtlasSprite sprite in atlas.sprites) {
      sprites[sprite.name] = sprite;
    }
    throw UnimplementedError();
  }

  ui.Image get atlasImage => BitmapRegistry.I.findImage(identifier);

  /// Lookup [SpriteTextureKey.spriteName] for [spriteName]
  AtlasSprite operator [](String spriteName) {
    AtlasSprite? res = _sprites[spriteName];
    if (res == null) {
      if (Public.panicOnNullTextures) {
        panicNow("Could not find sprite_texture '$spriteName' under '$identifier'");
      }
      logger.warning("Null texture for '$spriteName' under '$identifier'");
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

  bool containsSprite(AtlasSprite sprite) => _sprites.containsValue(sprite);

  bool containsKey(String key) => _sprites.containsKey(key);

  Iterable<AtlasSprite> get sprites => _sprites.values;
}
