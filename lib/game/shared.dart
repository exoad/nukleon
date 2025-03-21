import 'package:logging/logging.dart';
import 'package:nukleon/engine/engine.dart';

const String ffBold = "Motorola Screentype";

final class Thematic {
  Thematic._();

  static const Color fg1 = Color.fromARGB(255, 217, 208, 176);
  static const Color sh1 = Color.fromARGB(255, 51, 48, 37);
}

final class Shared {
  Shared._();

  static const num version = 1.0;

  static const int reactorRows = 12;
  static const int reactorColumns = 24;
  static const double tileInitialZoom = 1;

  /// Resort to using [kTileSize] since that one has additional calculations to make sure it is a true size (AKA its a magic number)
  static const double tileSize = 32;

  /// Resort to using [kTileSpacing] since that one has additional calculations to make sure it is a true size (AKA its a magic number)
  static const double tileSpacing = 0;
  static const double kTileSize = tileSize * tileInitialZoom;
  static const double kTileSpacing = tileSpacing * tileInitialZoom;

  static const double uiPadding = 8.0;
  static const double uiGridParentPadding = 10;
  static const double uiGridChildPadding = 10;

  /// Game side logger
  static final Logger logger = Logger("Game");

  static Future<void> initialize() async {
    Shared.logger.level = Level.ALL;
    Shared.logger.onRecord.listen((LogRecord record) {
      final String built =
          "GAME___[${record.level.name.padRight(7)}]: ${record.time.year}-${record.time.month}-${record.time.day}, ${record.time.hour}:${record.time.minute}:${record.time.millisecond}: ${record.message}";
      print(built);
    });
    await SpriteAtlas.parseAssetsL("assets/textures/reactor_items.atlas");
    await SpriteAtlas.parseAssetsL("assets/textures/ui_content.atlas");
    await SpriteAtlas.parseAssetsL("assets/textures/tiles.atlas");
    await SpriteAtlas.parseAssetsL("assets/textures/icons_content.atlas");
    await SpriteAtlas.parseAssetsL("assets/textures/concept_ui.atlas");
    await SpriteAtlas.parseAssetsL("assets/textures/character.atlas");
    Shared.logger.info("Shared Resources initialized.");
  }
}
