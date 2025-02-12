import 'package:project_yellow_cake/game/game.dart';

class PointerBuffer {
  int _primary;
  int? _secondary;

  PointerBuffer(int primary, [int? secondary])
      : _primary = primary,
        _secondary = secondary ?? 0;

  int get primary => _primary;

  int? get secondary => _secondary;

  set primary(int primary) {
    _primary = primary;
    Shared.logger.finer("Pointer Buffer Primary=$_primary");
  }

  set secondary(int? secondary) {
    _secondary = secondary;
    Shared.logger.finer("Pointer Buffer Secondary=$_secondary");
  }

  bool get hasSecondary => _secondary == null;

  @override
  String toString() {
    return "PtrBuff[$_primary,$_secondary]";
  }
}
