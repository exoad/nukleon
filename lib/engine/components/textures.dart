import 'package:equatable/equatable.dart';
import 'package:shitter/engine/engine.dart';
import "dart:ui" as ui;

@immutable
class SpriteTextureKey with EquatableMixin {
  final String key;
  final String spriteName;

  const SpriteTextureKey(this.key, {required this.spriteName});

  @override
  String toString() {
    return "SpriteTextKey[$key,$spriteName]";
  }

  AtlasSprite findTexture() {
    return TextureRegistry.getTextureSprite(this);
  }

  @override
  List<Object?> get props => <Object?>[key, spriteName];
}

/// This is based on [WidgetStateProperty]
abstract class SpriteSet<T> {
  SpriteSet();

  SpriteTextureKey resolveTextureKey(Set<T> states);

  LinearTransformer resolveTransformation(Set<T> states);

  static SpriteSetAll all(SpriteTextureKey value,
          {required LinearTransformer transform}) =>
      SpriteSetAll(value, transform: transform);

  static SpriteSetMapper<T> fromMap<T>(Map<T, SpriteSetProperty> map) =>
      SpriteSetMapper<T>(map);

  static SpriteSetResolver<T> resolveWith<T>(SpriteTextureKey Function(Set<T>) resolver,
          {LinearTransformer Function(Set<T>)? transformationResolver}) =>
      SpriteSetResolver<T>(resolver, transformationResolver);
}

class SpriteSetResolver<T> implements SpriteSet<T> {
  final SpriteTextureKey Function(Set<T>) resolver;
  final LinearTransformer Function(Set<T>)? transformationResolver;

  SpriteSetResolver(this.resolver, this.transformationResolver);

  @override
  SpriteTextureKey resolveTextureKey(Set<T> states) {
    return resolver(states);
  }

  @override
  LinearTransformer resolveTransformation(Set<T> states) {
    return LinearTransformer.single(transformationResolver == null
        ? Matrix4.identity()
        : transformationResolver!.call(states) as Matrix4);
  }
}

@immutable
class SpriteSetAll with EquatableMixin implements SpriteSet<dynamic> {
  final SpriteTextureKey value;
  final LinearTransformer transform;

  const SpriteSetAll(this.value, {required this.transform});

  @override
  SpriteTextureKey resolveTextureKey(Set<dynamic> states) {
    return value;
  }

  @override
  LinearTransformer resolveTransformation(Set<dynamic> states) {
    return transform;
  }

  @override
  List<Object?> get props => <Object?>[value, transform];
}

typedef SpriteSetProperty = ({SpriteTextureKey sprite, LinearTransformer transform});

@immutable
class SpriteSetMapper<T> extends SpriteSet<T> {
  final Map<T, SpriteSetProperty> _map;

  SpriteSetMapper(Map<T, SpriteSetProperty> map) : _map = map;

  @override
  SpriteTextureKey resolveTextureKey(Set<T> states) {
    for (MapEntry<T, SpriteSetProperty> entry in _map.entries) {
      if (states.contains(entry.key)) {
        return entry.value.sprite;
      }
    }
    try {
      // ignore: cast_from_null_always_fails
      return null as SpriteTextureKey;
    } on TypeError {
      panicNow("This SpriteSet cannot resolve states: $states.",
          details: "None of the provided mapping states matched these states.",
          help: "Consider fixing the states to resolve to at least one value!");
      throw "...";
    }
  }

  @override
  int get hashCode => _map.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SpriteSetMapper<T> && mapEquals(_map, other._map);
  }

  @override
  LinearTransformer resolveTransformation(Set<T> states) {
    for (MapEntry<T, SpriteSetProperty> entry in _map.entries) {
      if (states.contains(entry.key)) {
        return entry.value.transform;
      }
    }
    try {
      // ignore: cast_from_null_always_fails
      return null as LinearTransformer;
    } on TypeError {
      panicNow("This SpriteSet cannot resolve states: $states.",
          details: "None of the provided mapping states matched these states.",
          help: "Consider fixing the states to resolve to at least one value!");
      throw "...";
    }
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

  bool containsSprite(AtlasSprite sprite) {
    return _sprites.containsValue(sprite);
  }

  bool containsKey(String key) {
    return _sprites.containsKey(key);
  }

  Iterable<AtlasSprite> get sprites => _sprites.values;
}
