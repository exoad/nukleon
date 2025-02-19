import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/entities/entities.dart';
import 'package:shitter/game/game.dart';
import 'package:provider/provider.dart';

/// Primary is always an element to place
/// Secondary is always an erasing element
class PointerBuffer with ChangeNotifier {
  bool _usePrimary;
  int? _primary;
  final int _secondary;

  PointerBuffer([int? primary])
      : _primary = primary,
        _secondary = 0,
        _usePrimary = primary == null ? false : true;

  bool get isUsing => _usePrimary;

  bool get isErasing => !isUsing;

  void use([int? newPrimary]) {
    _usePrimary = true;
    // if (newPrimary != null) {
    //   primary = newPrimary;
    // }
    // * this part helps with an auto use mode
    Shared.logger.finer("PointerBuffer USE");
    notifyListeners();
  }

  void swap() => isUsing ? erase() : use();

  void erase() {
    _usePrimary = false;
    Shared.logger.finer("PointerBuffer ERASE");
    notifyListeners();
  }

  CellValue? resolve() {
    if (primary != null) {
      int id = isUsing ? primary! : secondary;
      return CellValue(id);
    }
    return null;
  }

  int? get primary => _primary;

  int get secondary => _secondary;

  set primary(int? p) {
    _primary = p;
    Shared.logger.finer("PointerBuffer Use=$_primary");
    notifyListeners();
  }

  @override
  String toString() {
    return "PtrBuffer[$_primary,$_secondary]";
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
