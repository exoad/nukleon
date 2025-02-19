import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';
import 'package:shitter/game/game.dart';

@immutable
class ReactorSlot {
  final Map<Class, CellValue> _class;

  ReactorSlot([Map<Class, CellValue>? initial])
      : _class = Map<Class, CellValue>.fromIterables(
            Class.values,
            List<CellValue>.filled(Class.values.length, CellValue.emptiness,
                growable: false));

  CellValue at(Class layer) {
    return _class[
        layer]!; // non nullable enum type assures us that the result will at least produce a numerical typing
  }

  CellValue operator [](Class layer) {
    return at(layer);
  }

  void setAt(Class layer, CellValue value) {
    _class[layer] = value;
  }

  void operator []=(Class layer, CellValue value) {
    _class[layer] = value;
  }

  @override
  bool operator ==(Object other) {
    return other is ReactorSlot && mapEquals(other._class, _class);
  }

  @override
  int get hashCode {
    return _class.hashCode;
  }
}

class ReactorEntity {
  final List<List<ReactorSlot>> _grid;

  ReactorEntity(
      {required int rows,
      required int columns,
      ReactorSlot Function(int row, int column)? generator})
      : _grid = List<List<ReactorSlot>>.generate(
            rows,
            (int i) => List<ReactorSlot>.generate(
                columns, (int j) => generator != null ? generator(i, j) : ReactorSlot()));

  /// Returns an item definition ID that can be looked up in [ItemsRegistry]
  ReactorSlot at(int row, int column) {
    if (!isValidLocationRaw(row, column)) {
      panicNow(
          "Invalid indices: row=$row, column=$column. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[row][column];
  }

  List<ReactorSlot> allOnLayer(Class layer) {
    return _grid[layer.index];
  }

  @Deprecated("dont use this shit")
  CellValue operator [](CellLocation location) {
    if (!isValidLocation(location)) {
      panicNow(
          "Invalid indices: row=${location.row}, column=${location.row}, layer=Class.ITEMS. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[location.row][location.column][Class.ITEMS];
  }

  bool safePut(CellLocation location, CellValue value, Class layer,
      [bool forced = false]) {
    if (!isValidLocation(location)) {
      return false;
    }
    if (!_grid[location.row][location.column][layer].isEqual(value) || forced) {
      _grid[location.row][location.column][layer] = value;
      Shared.logger.fine(
          "Reactor set ${location.row},${location.column},$layer to $value (${value.id.findItemDefinition(layer).identifier})");
      return true;
    }
    return false;
  }

  bool isValidLocation(CellLocation location) {
    return location.row >= 0 &&
        location.row < _grid.length &&
        location.column >= 0 &&
        location.row < _grid[location.row].length;
  }

  bool isValidLocationRaw(int row, int column) {
    return row >= 0 && row < _grid.length && column >= 0 && row < _grid[row].length;
  }

  /// Similar in functionality to the `[]=` operator, but does not panic when the [location] is out of bounds.
  /// If the operation is successful, this function returns `true` else it will return `false`.
  ///
  /// If [forced] is set to `true`, it will update the value even if there is no change.
  bool safePutCell(CellLocation location, CellValue value, [bool forced = false]) {
    return safePut(location, value, Class.ITEMS, forced);
  }

  int get size => _grid.length * _grid[0].length;

  int get rows => _grid.length;

  int get columns => _grid[0].length;
}

@immutable
class CellLocation with EquatableMixin {
  final int row;
  final int column;

  const CellLocation(this.row, this.column)
      : assert(row >= 0, "Reactor Cell of Row=$row is not possible!"),
        assert(column >= 0, "Reactor Cell of Column=$column is not possible!");

  CellValue findInRector([ReactorEntity? instance]) {
    return (instance ?? GameRoot.I.reactor).at(row, column)[Class.ITEMS];
  }

  @override
  String toString() {
    return "CellLoc[Row=$row,Col=$column]";
  }

  @override
  List<Object?> get props => <Object?>[row, column];
}

class CellValue {
  static CellValue get emptiness {
    return CellValue(0);
  }

  final int id;
  double itemHealth;

  CellValue(this.id, {double? itemHealth}) : itemHealth = id.findCell().maxHealth;

  @override
  String toString() {
    return "$id@[Health=$itemHealth]";
  }

  bool isEqual(CellValue other) {
    return other.id == id && other.itemHealth == itemHealth;
  }
}
