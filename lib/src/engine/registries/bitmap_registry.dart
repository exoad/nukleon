import "dart:ui" as ui;

import "package:equatable/equatable.dart";
import "package:nukleon/src/engine/engine.dart";

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

class BitmapRegistry extends Registry<String, BitmapEntry> {
  BitmapRegistry._() : super();

  static final BitmapRegistry I = BitmapRegistry._();

  void registerEntry(BitmapEntry entry) {
    logger.info("BitMRegistry: Register ${entry.identifier}");
    if (super.map.containsKey(entry.identifier)) {
      logger.warning(
          "BitMRegistry: A bitmap entry already exists with identifier ${entry.identifier}! Is this a mistake?");
    } else {
      logger.info(
          "BitMRegistry: Registered a new bitmap entry: ${entry.identifier} (${entry.image.width}x${entry.image.height})");
    }
    super.map[entry.identifier] = entry;
  }

  ui.Image findImage(String identifier) {
    return super.map[identifier]!.image;
  }

  BitmapEntry find(String identifier) {
    return super.map[identifier]!;
  }

  bool containsEntry(String identifier) {
    return super.map.containsKey(identifier);
  }

  /// Returns a [bool] status depending on the success of the removal process. This value can be ignored.
  bool removeEntry(String identifier) {
    if (containsEntry(identifier)) {
      super.map.remove(identifier);
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return "BitmapRegistry:\n${super.toString()}";
  }
}
