import "dart:ui" as ui;

import "package:equatable/equatable.dart";
import "package:nukleon/engine/engine.dart";

@immutable
class BitmapEntry with EquatableMixin {
  final String identifier;
  final ui.Image image;

  const BitmapEntry(this.identifier, this.image);

  @override
  List<Object?> get props => <Object?>[identifier, image];

  @override
  String toString() {
    return "BitmapEntry[$identifier,${image.width}*${image.height}]";
  }
}

class BitmapRegistry {
  final Map<String, ui.Image> _cache;

  BitmapRegistry._() : _cache = <String, ui.Image>{};

  static final BitmapRegistry I = BitmapRegistry._();

  void registerEntry(BitmapEntry entry) {
    logger.info("BitMRegistry: Register ${entry.identifier}");
    if (_cache.containsKey(entry.identifier)) {
      logger.warning(
          "BitMRegistry: A bitmap entry already exists with identifier ${entry.identifier}! Is this a mistake?");
    } else {
      logger.info(
          "BitMRegistry: Registered a new bitmap entry: ${entry.identifier} (${entry.image.width}x${entry.image.height})");
    }
    _cache[entry.identifier] = entry.image;
  }

  ui.Image find(String identifier) {
    return _cache[identifier]!;
  }

  bool containsEntry(String identifier) {
    return _cache.containsKey(identifier);
  }

  /// Returns a [bool] status depending on the success of the removal process. This value can be ignored.
  bool removeEntry(String identifier) {
    if (containsEntry(identifier)) {
      _cache.remove(identifier);
      return true;
    }
    return false;
  }
}
