import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/game.dart';

class ReactorEntity {
  final List<List<int>> _grid;

  ReactorEntity(
      {required int rows,
      required int columns,
      int Function(int row, int column)? generator})
      : _grid = List<List<int>>.generate(
            rows,
            (int i) => List<int>.generate(
                columns, (int j) => generator != null ? generator(i, j) : 0));

  /// Returns an item definition ID that can be looked up in [ItemsRegistry]
  int at(int row, int column) {
    if (row < 0 || row >= _grid.length || column < 0 || column >= _grid[row].length) {
      panicNow(
          "Invalid indices: row=$row, column=$column. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[row][column];
  }

  int operator [](CellLocation location) {
    if (location.$1 < 0 ||
        location.$1 >= _grid.length ||
        location.$2 < 0 ||
        location.$1 >= _grid[location.$1].length) {
      panicNow(
          "Invalid indices: row=${location.$1}, column=${location.$1}. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    return _grid[location.$1][location.$2];
  }

  void operator []=(CellLocation location, int value) {
    if (location.$1 < 0 ||
        location.$1 >= _grid.length ||
        location.$2 < 0 ||
        location.$1 >= _grid[location.$1].length) {
      panicNow(
          "Invalid indices: row=${location.$1}, column=${location.$1}. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    _grid[location.$1][location.$2] = value;
    Shared.logger.fine("Reactor set ${location.$1},${location.$2} to $value");
  }

  void setAt(int value, {required int row, required int column}) {
    if (row < 0 || row >= _grid.length || column < 0 || column >= _grid[row].length) {
      panicNow(
          "Invalid indices: row=$row, column=$column. Grid size is ${_grid.length}x${_grid.isNotEmpty ? _grid[0].length : 0}.");
    }
    _grid[row][column] = value;
  }

  int get size => _grid.length * _grid[0].length;

  int get rows => _grid.length;

  int get columns => _grid[0].length;
}

/// [$1] is the row. [$2] is the column
typedef CellLocation = (int row, int column);
