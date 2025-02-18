import 'dart:ui';

import 'package:shitter/game/entities/entities.dart';

final class GeomSurveyor {
  GeomSurveyor._();

  static ({int row, int column}) fromPos(Offset position, double tileSize,
      [double tileSpacing = 0]) {
    return (
      row: position.dy ~/ (tileSize + tileSpacing),
      column: position.dx ~/ (tileSize + tileSpacing)
    );
  }

  static CellLocation posToCellLocation(Offset position, double tileSize,
      [double tileSpacing = 0]) {
    ({int row, int column}) item = fromPos(position, tileSize, tileSpacing);
    return CellLocation(item.row, item.column);
  }
}
