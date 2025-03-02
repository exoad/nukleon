import 'package:nukleon/engine/engine.dart';

final class ItemsRegistry {
  static final ItemsRegistry I = ItemsRegistry._();

  /// The indices represents the layer
  final Map<Class, Map<int, ItemDefinition>> _items;
  final Map<Class, Map<String, int>> _identifiersRemap;

  ItemsRegistry._()
      : _items = Map<Class, Map<int, ItemDefinition>>.fromIterables(
            Class.values, <Map<int, ItemDefinition>>[
          for (int i = 0; i < Class.values.length; i++) <int, ItemDefinition>{}
        ]),
        _identifiersRemap = Map<Class, Map<String, int>>.fromIterables(
            Class.values, <Map<String, int>>[
          for (int i = 0; i < Class.values.length; i++) <String, int>{}
        ]);

  int get totalRegisteredItems {
    int l = 0;
    for (Map<int, ItemDefinition> def in _items.values) {
      l += def.length;
    }
    return l;
  }

  int registeredItems(Class layer) => _items[layer]!.length;

  Map<int, ItemDefinition> operator [](Class layer) => _items[layer]!;

  /// Avoid modification at all costs
  Map<Class, Map<int, ItemDefinition>> get allClasses => _items;

  void _checkInvariance<E extends ItemDefinition>(
      E? item, Class layer, String? identifier) {
    if (item != null) {
      if ((!_items[layer]!.containsValue(item) &&
              _identifiersRemap[layer]!.containsKey(item.identifier)) ||
          (_items[layer]!.containsValue(item) &&
              !_identifiersRemap[layer]!.containsKey(item.identifier))) {
        panicNow(
            "INVARIANCE ENCOUNTERED\nItems_$layer=${_items[layer]}\nIdentifiersRemap=$_identifiersRemap",
            details:
                "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.");
      }
    }
    if (identifier != null) {
      bool c = _items[layer]!
          .values
          .any((ItemDefinition definition) => definition.identifier == identifier);
      if ((!c && _identifiersRemap[layer]!.containsKey(identifier)) ||
          (c && !_identifiersRemap[layer]!.containsKey(identifier))) {
        panicNow(
            "INVARIANCE ENCOUNTERED\nItems_$layer=${_items[layer]}\nIdentifiersRemap=$_identifiersRemap",
            details:
                "Invariance encountered inside of ItemsRegistry. This is highly unlikely to happen, so this is a major error.");
      }
    }
  }

  void addItemDefinition<E extends ItemDefinition>(int id, Class layer, E item) {
    if (_identifiersRemap[layer]!.containsKey(item.identifier) ||
        containsOfType(E.runtimeType, layer)) {
      panicNow(
          "Cannot add an item with a duplicate identifier/type: ${item.identifier} ($E)",
          details:
              "Duplicate item identifier ${item.identifier} with duplicate at ${_identifiersRemap[layer]![item.identifier]} (Layer $layer)");
    }
    if (_items[layer]!.containsKey(id)) {
      if (_items[layer]![id]!.locked) {
        logger.severe(
            "Cannot replace item definition at $id.$layer (${_items[layer]![id]!.identifier}) with ${item.identifier} because it is locked)");
      } else {
        String original = _items[layer]![id]!.identifier;
        _items[layer]![id] = item;
        _identifiersRemap[layer]![item.identifier] = id;
        logger.fine(
            "Replaced item definition at $id.$layer ($original with ${item.identifier})");
      }
    } else {
      _items[layer]![id] = item;
      _identifiersRemap[layer]![item.identifier] = id;
      logger.fine("Loaded new item definition at $id.$layer -> ${item.identifier}");
    }
    if (id == 0 && layer != Class.TILES) {
      logger.warning(
          "[DANGEROUS OPTION] It can be confusing to set the empty layer other than backdrops [0=0].");
    }
  }

  bool containsOfType(Type type, Class layer) =>
      _items[layer]!.values.any((ItemDefinition item) => item.runtimeType == type);

  /// Based on a runtime type referring to each object's [Object.runtimeType] and uses that to find that
  /// registered Item. This is not very versatile, so please avoid using this method! (*￣3￣)╭
  T? findOfType<T extends ItemDefinition>(Type type, Class layer) {
    assert(T.runtimeType == type,
        "Type invariance for finding of type '${T.runtimeType}' to $type");
    for (ItemDefinition item in _items[layer]!.values) {
      if (item.runtimeType == type) {
        return item as T;
      }
    }
    return null;
  }

  bool containsID(int id, Class layer) => _items[layer]!.containsKey(id);

  bool containsItemDefinition<E extends ItemDefinition>(Class layer, E item) {
    _checkInvariance<E>(item, layer, null);
    return _items[layer]!.containsValue(item);
  }

  bool containsIdentifier(String identifier, Class layer) {
    _checkInvariance<ItemDefinition>(null, layer, identifier);
    return _identifiersRemap[layer]!.containsKey(identifier);
  }

  /// When calling this, make sure to place a check to call [containsID] !
  E findItemDefinition<E extends ItemDefinition>(int id, Class layer) {
    if (!_items[layer]!.containsKey(id)) {
      panicNow("Could not find ItemDefinition id '$id' on layer $layer");
    }
    return _items[layer]![id]! as E;
  }

  int findID<E extends ItemDefinition>(E item, Class layer) {
    _checkInvariance<E>(item, layer, null);
    return _identifiersRemap[layer]![item.identifier]!;
  }

  int findIDByIdentifier(String identifier, Class layer) {
    _checkInvariance<ItemDefinition>(null, layer, identifier);
    return _identifiersRemap[layer]![identifier]!;
  }
}

extension ItemID on int {
  ItemDefinition findItemDefinition(Class layer) {
    if (!ItemsRegistry.I.containsID(this, layer)) {
      panicNow(
          "For ItemDefinition id=$this on $layer is not in the item registry so it does not have an ItemDefinition!",
          help: "Register it to the ItemRegistry first.");
    }
    return ItemsRegistry.I.findItemDefinition(this, layer);
  }
}

@immutable
abstract class ItemDefinition {
  const ItemDefinition();

  String get identifier;

  Class get layer;

  SpriteTextureKey sprite();

  /// Determines if this is a locked item and should have any further modifications in the [ItemRegistry] be restricted or locked down.
  bool get locked;
}
