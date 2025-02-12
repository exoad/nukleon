import 'package:project_yellow_cake/engine/engine.dart';

final class ItemsRegistry {
  static final ItemsRegistry I = ItemsRegistry._();

  /// The indices represents the layer
  final List<Map<int, ItemDefinition>> _items;
  final List<Map<String, int>> _identifiersRemap;

  ItemsRegistry._()
      : _items = List<Map<int, ItemDefinition>>.filled(
            Layers.values.length, <int, ItemDefinition>{}),
        _identifiersRemap =
            List<Map<String, int>>.filled(Layers.values.length, <String, int>{});

  int get totalRegisteredItems {
    int l = 0;
    for (int i = 0; i < _items.length; i++) {
      l += _items[i].length;
    }
    return l;
  }

  Map<int, ItemDefinition> operator [](Layers layer) {
    return _items[layer.index];
  }

  /// Avoid modification at all costs
  List<Map<int, ItemDefinition>> get layers => _items;

  void _checkInvariance<E extends ItemDefinition>(
      E? item, Layers layer, String? identifier) {
    if (item != null) {
      if ((!_items[layer.index].containsValue(item) &&
              _identifiersRemap[layer.index].containsKey(item.identifier)) ||
          (_items[layer.index].containsValue(item) &&
              !_identifiersRemap[layer.index].containsKey(item.identifier))) {
        logger.severe(
            "INVARIANCE ENCOUNTERED\nItems_$layer=${_items[layer.index]}\nIdentifiersRemap=$_identifiersRemap");
        throw "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.";
      }
    }
    if (identifier != null) {
      bool c = _items[layer.index]
          .values
          .any((ItemDefinition definition) => definition.identifier == identifier);
      if ((!c && _identifiersRemap[layer.index].containsKey(identifier)) ||
          (c && !_identifiersRemap[layer.index].containsKey(identifier))) {
        logger.severe(
            "INVARIANCE ENCOUNTERED\nItems_$layer=${_items[layer.index]}\nIdentifiersRemap=$_identifiersRemap");
        throw "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.";
      }
    }
  }

  void addItemDefinition<E extends ItemDefinition>(int id, Layers layer, E item) {
    if (_identifiersRemap[layer.index].containsKey(item.identifier)) {
      logger.severe("Cannot add an item with a duplicate identifier: ${item.identifier}");
      throw "Duplicate item identifier ${item.identifier} with duplicate at ${_identifiersRemap[layer.index][item.identifier]} (Layer $layer)";
    }
    if (_items[layer.index].containsKey(id)) {
      if (_items[layer.index][id]!.locked) {
        logger.severe(
            "Cannot replace item definition at $id.$layer (${_items[layer.index][id]!.identifier}) with ${item.identifier} because it is locked)");
      } else {
        String original = _items[layer.index][id]!.identifier;
        _items[layer.index][id] = item;
        _identifiersRemap[layer.index][item.identifier] = id;
        logger.fine(
            "Replaced item definition at $id.$layer ($original with ${item.identifier})");
      }
    } else {
      _items[layer.index][id] = item;
      _identifiersRemap[layer.index][item.identifier] = id;
      logger.fine("Loaded new item definition at $id.$layer -> ${item.identifier}");
    }
  }

  bool containsID(int id) {
    return _items.within(id);
  }

  bool containsItemDefinition<E extends ItemDefinition>(Layers layer, E item) {
    _checkInvariance<E>(item, layer, null);
    return _items[layer.index].containsValue(item);
  }

  bool containsIdentifier(String identifier, Layers layer) {
    _checkInvariance<ItemDefinition>(null, layer, identifier);
    return _identifiersRemap[layer.index].containsKey(identifier);
  }

  /// When calling this, make sure to place a check to call [containsID]
  E findItemDefinition<E extends ItemDefinition>(int id, Layers layer) {
    if (!_items[layer.index].containsKey(id)) {
      panicNow("Could not find ItemDefinition id '$id' on layer $layer");
    }
    return _items[layer.index][id]! as E;
  }

  int findID<E extends ItemDefinition>(E item, Layers layer) {
    _checkInvariance<E>(item, layer, null);
    return _identifiersRemap[layer.index][item.identifier]!;
  }

  int findIDByIdentifier(String identifier, Layers layer) {
    _checkInvariance<ItemDefinition>(null, layer, identifier);
    return _identifiersRemap[layer.index][identifier]!;
  }
}

extension ItemID on int {
  ItemDefinition findItemDefinition(Layers layer) {
    if (!ItemsRegistry.I.containsID(this)) {
      panicNow(
          "ItemRegstry $this is not in the item registry so it does not have an ItemDefinition! Register it first");
    }
    return ItemsRegistry.I.findItemDefinition(this, layer);
  }
}

abstract class ItemDefinition {
  String get identifier;

  Layers get layer;

  SpriteTextureKey sprite();

  /// Determines if this is a locked item and should have any further modifications in the [ItemRegistry] be restricted or locked down.
  bool get locked;

  int get id {
    if (!ItemsRegistry.I.containsIdentifier(identifier, layer)) {
      panicNow(
          "This item $identifier is not in the item registry so it does not have an ID! Register it first");
    }
    return ItemsRegistry.I.findIDByIdentifier(identifier, layer);
  }
}
