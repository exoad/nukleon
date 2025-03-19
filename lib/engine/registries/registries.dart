/// Some globally defined registries that are used not only in the game partition
/// but also in the engine partition for managing sprites, etc..
library;

import 'package:meta/meta.dart';
import 'package:nukleon/engine/engine.dart';

export "items_registry.dart";
export "textures_registries.dart";
export "bitmap_registry.dart";

abstract class Registry<K, V> {
  @protected
  final Map<K, V> map;

  Registry() : map = <K, V>{};

  /// Checks whether [key] exists in this registry.
  bool containsKey(K key) => map.containsKey(key);

  /// How many items lives in this registry.
  int get size => map.length;

  @override
  @mustBeOverridden
  String toString() {
    return map.toString();
  }
}

/// Some premade basic functionality you can just mixin with any [Registry] child.
mixin SimpleRegistryMixin<K, V> on Registry<K, V> {
  void deleteElement(K key) {
    if (map.containsKey(key)) {
      map.remove(key);
    }
  }

  void register(K key, V value) {
    map[key] = value;
  }

  /// If [key] is not present in this [Registry], then we make it point to a value, otherwise ignore.
  void tryRegistry(K key, V value) {
    map.putIfAbsent(key, () => value);
  }

  V find(K key) {
    if (!map.containsKey(key)) {
      panicNow("Cannot resolve $key to point to anything in $runtimeType",
          help: "Maybe register $key first?");
    }
    return map[key]!;
  }

  V? tryFind(K key) {
    return map[key];
  }
}
