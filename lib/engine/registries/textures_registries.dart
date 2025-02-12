import 'package:project_yellow_cake/engine/engine.dart';

class TextureRegistry {
  final Map<String, TextureMap> _texturesCache;
  final Map<String, TextureMap> _coreCache;

  TextureRegistry._()
      : _texturesCache = <String, TextureMap>{},
        _coreCache = <String, TextureMap>{};

  static Future<void> initialize() async {
    I._coreCache["internal"] =
        (await TextureAtlasLoader.loadAssetsAtlas("textures/internal.atlas"))
            .toTextureMap("core.internal");
    logger.fine("Loaded core.internal textures");
  }

  static final TextureRegistry I = TextureRegistry._();

  static bool coreCacheHas(String key) {
    return I._coreCache.containsKey(key);
  }

  static bool publicCacheHas(String key) {
    return I._texturesCache.containsKey(key);
  }

  /// A decipherable [key] that is used as a placeholder for textures.
  ///
  /// Commonly used is an ORG ID.
  static TextureMap? getTexture(
    String key,
  ) {
    TextureMap? res = I._texturesCache[key];
    if (res == null) {
      logger.warning("Failed to find texture $key");
      if (Public.panicOnNullTextures) {
        panicNow("Null texture: $key");
      }
    }
    return res;
  }

  static AtlasSprite getTextureSprite(SpriteTextureKey key) {
    TextureMap? res = getTexture(key.key);
    if (res == null) {
      logger.warning("Cannot find '${key.spriteName}' on texture '${key.key}'.");
      return nullTextureSprite;
    }
    return res[key.spriteName];
  }

  /// Please note that [path] is not a key
  static Future<void> registerNLoadTexture(
      {required String atlasPath,
      required String mapKey,
      required String mapIdentifier}) async {
    TextureAtlas atlas = await TextureAtlasLoader.loadAssetsAtlas(atlasPath);
    TextureMap map = TextureMap(mapIdentifier, atlasImage: atlas.sprites[0].image);
    for (AtlasSprite sprite in atlas.sprites) {
      map[sprite.name] = sprite;
      logger.finer("Loaded sprite: ${sprite.name} under $mapIdentifier ($atlasPath)");
    }
  }

  /// A decipherable [key] that is used as a placeholder for textures.
  ///
  /// Commonly used is an ORG ID.
  static void registerTextureMap(String key, TextureMap image) {
    I._texturesCache[key] = image;
    for (AtlasSprite sprite in I._texturesCache[key]!.sprites) {
      logger.finer("Registered texture sprite: '${sprite.name}' [${sprite.index}]");
    }
  }

  static AtlasSprite get nullTextureSprite {
    if (!I._coreCache["internal"]!.containsKey("Null_Texture")) {
      panicNow(
          "FAILURE TO FIND NULL_TEXTURE. THIS IS NOT ALLOWED."); // cannot avoid panicking here
    }
    return I._coreCache["internal"]![
        "Null_Texture"]; // any kind of null error is most likely due to something else
  }
}
