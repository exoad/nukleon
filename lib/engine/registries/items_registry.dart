import 'package:project_yellow_cake/engine/components/textures.dart';
import 'package:project_yellow_cake/engine/engine.dart';

final class ItemsRegistry {
  static final ItemsRegistry I = ItemsRegistry._();
  final Map<int, ItemDefinition> _items;
  final Map<String, int> _identifiersRemap;

  ItemsRegistry._()
      : _items = <int, ItemDefinition>{},
        _identifiersRemap = <String, int>{};

  int get totalRegisteredItems => _items.length;

  void _checkInvariance<E extends ItemDefinition>(E? item, String? identifier) {
    if (item != null) {
      if ((!_items.containsValue(item) &&
              _identifiersRemap.containsKey(item.identifier)) ||
          (_items.containsValue(item) &&
              !_identifiersRemap.containsKey(item.identifier))) {
        logger.severe(
            "INVARIANCE ENCOUNTERED\nItems=$_items\nIdentifiersRemap=$_identifiersRemap");
        throw "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.";
      }
    }

    if (identifier != null) {
      bool c = _items.values
          .any((ItemDefinition definition) => definition.identifier == identifier);
      if ((!c && _identifiersRemap.containsKey(identifier)) ||
          (c && !_identifiersRemap.containsKey(identifier))) {
        logger.severe(
            "INVARIANCE ENCOUNTERED\nItems=$_items\nIdentifiersRemap=$_identifiersRemap");
        throw "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.";
      }
    }
  }

  void addItemDefinition<E extends ItemDefinition>(int id, E item) {
    if (_identifiersRemap.containsKey(item.identifier)) {
      logger.severe("Cannot add an item with a duplicate identifier: ${item.identifier}");
      throw "Duplicate item identifier ${item.identifier} with duplicate at ${_identifiersRemap[item.identifier]}";
    }
    if (_items.containsKey(id)) {
      if (_items[id]!.locked) {
        logger.severe(
            "Cannot replace item definition at $id (${_items[id]!.identifier}) with ${item.identifier} because it is locked");
      } else {
        String original = _items[id]!.identifier;
        _items[id] = item;
        _identifiersRemap[item.identifier] = id;
        logger
            .fine("Replaced item definition at $id ($original with ${item.identifier})");
      }
    } else {
      _items[id] = item;
      _identifiersRemap[item.identifier] = id;
      logger.fine("Loaded new item definition at $id -> ${item.identifier}");
    }
  }

  bool containsID(int id) {
    return _items.containsKey(id);
  }

  bool containsItemDefinition<E extends ItemDefinition>(E item) {
    _checkInvariance<E>(item, null);
    return _items.containsValue(item);
  }

  bool containsIdentifier(String identifier) {
    _checkInvariance<ItemDefinition>(null, identifier);
    return _identifiersRemap.containsKey(identifier);
  }

  /// When calling this, make sure to place a check to call [containsID]
  E findItemDefinition<E extends ItemDefinition>(int id) {
    return _items[id]! as E;
  }

  int findID<E extends ItemDefinition>(E item) {
    _checkInvariance<E>(item, null);
    return _identifiersRemap[item.identifier]!;
  }

  int findIDByIdentifier(String identifier) {
    _checkInvariance<ItemDefinition>(null, identifier);
    return _identifiersRemap[identifier]!;
  }
}

extension ItemID on int {
  ItemDefinition findItemDefinition() {
    if (!ItemsRegistry.I.containsID(this)) {
      panicNow(
          "ItemRegstry $this is not in the item registry so it does not have an ItemDefinition! Register it first");
    }
    return ItemsRegistry.I.findItemDefinition(this);
  }
}

abstract class ItemDefinition {
  String get identifier;

  SpriteTextureKey sprite();

  /// Determines if this is a locked item and should have any further modifications in the [ItemRegistry] be restricted or locked down.
  bool get locked;

  int get id {
    if (!ItemsRegistry.I.containsIdentifier(identifier)) {
      panicNow(
          "This item $identifier is not in the item registry so it does not have an ID! Register it first");
    }
    return ItemsRegistry.I.findIDByIdentifier(identifier);
  }
}
