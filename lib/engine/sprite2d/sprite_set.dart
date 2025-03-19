import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/engine.dart';

/// This is based on [WidgetStateProperty]
abstract class SpriteSet<T> {
  SpriteSet();

  SpriteTextureKey resolveTextureKey(Set<T> states);
  LinearTransformer resolveTransformation(Set<T> states);

  static SpriteSetAll<T> all<T>(SpriteTextureKey value,
          {required LinearTransformer transform}) =>
      SpriteSetAll<T>(value, transform: transform);

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
  SpriteTextureKey resolveTextureKey(Set<T> states) => resolver(states);

  @override
  LinearTransformer resolveTransformation(Set<T> states) => transformationResolver == null
      ? LinearTransformer.identity()
      : transformationResolver!.call(states);
}

@immutable
class SpriteSetAll<T> with EquatableMixin implements SpriteSet<T> {
  final SpriteTextureKey value;
  final LinearTransformer transform;

  const SpriteSetAll(this.value, {required this.transform});

  @override
  SpriteTextureKey resolveTextureKey(Set<T> states) => value;

  @override
  LinearTransformer resolveTransformation(Set<T> states) => transform;

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
  bool operator ==(Object other) =>
      other is SpriteSetMapper<T> && mapEquals(_map, other._map);

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
