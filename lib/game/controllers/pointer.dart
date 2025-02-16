import 'package:flutter/material.dart';
import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/entities/entities.dart';
import 'package:project_yellow_cake/game/game.dart';
import 'package:provider/provider.dart';

class PointerBuffer with ChangeNotifier {
  int _primary;
  int? _secondary;
  int _gridRow;
  int _gridCol;

  PointerBuffer(int primary, [int? secondary, int? gridRow, int? gridCold])
      : _primary = primary,
        _secondary = secondary ?? 0,
        _gridCol = gridCold ?? -1,
        _gridRow = gridRow ?? -1;

  int get primary => _primary;

  int get gridRow => _gridRow;

  int get gridCol => _gridCol;

  int? get secondary => _secondary;

  set gridRow(int gridRow) {
    _gridRow = gridRow;
    Shared.logger.finer("Pointer Buffer GridRow=$_gridRow");
    notifyListeners();
  }

  set gridCol(int gridCol) {
    _gridCol = gridCol;
    Shared.logger.finer("Pointer Buffer GridCol=$_gridCol");
    notifyListeners();
  }

  set primary(int primary) {
    _primary = primary;
    Shared.logger.finer("Pointer Buffer Primary=$_primary");
    notifyListeners();
  }

  set secondary(int? secondary) {
    _secondary = secondary;
    Shared.logger.finer("Pointer Buffer Secondary=$_secondary");
    notifyListeners();
  }

  bool get hasSecondary => _secondary == null;

  @override
  String toString() {
    return "PtrBuff[$_primary,$_secondary]";
  }

  static PointerBuffer of(BuildContext context, {bool listen = true}) {
    return Provider.of<PointerBuffer>(context, listen: listen);
  }
}

class CellLocationBuffer with ChangeNotifier {
  int _row = 0;
  int _column = 0;

  int get row => _row;

  int get column => _column;

  set row(int v) {
    _row = v;
    notifyListeners();
  }

  set column(int v) {
    _column = v;
    notifyListeners();
  }

  void setLocation(int r, int c) {
    if (r != row || c != column) {
      _row = r;
      _column = c;
      notifyListeners();
    }
  }

  CellLocation get cellLocation => CellLocation(row, column);

  static CellLocationBuffer of(BuildContext context, {bool listen = true}) {
    return Provider.of<CellLocationBuffer>(context, listen: listen);
  }
}
