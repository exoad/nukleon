import 'package:logging/logging.dart';
import 'package:project_yellow_cake/engine/engine.dart';

final class Shared {
  Shared._();

  static const int reactorRows = 12;
  static const int reactorColumns = 24;
  static const double tileInitialZoom = 1;
  static const double tileSize = 32;
  static const double tileSpacing = 0;
  static const double kTileSize = tileSize * tileInitialZoom;
  static const double kTileSpacing = tileSpacing * tileInitialZoom;

  static const String textureAtlasLocation = "textures/content.atlas";

  /// Game side logger
  static final Logger logger = Logger("Game");

  static Future<void> initialize() async {
    Shared.logger.level = Level.ALL;
    Shared.logger.onRecord.listen((LogRecord record) {
      final String built =
          "GAME___[${record.level.name.padRight(7)}]: ${record.time.year}-${record.time.month}-${record.time.day}, ${record.time.hour}:${record.time.minute}:${record.time.millisecond}: ${record.message}";
      print(built);
    });
    TextureRegistry.registerTextureMap(
        "content",
        (await TextureAtlasLoader.loadAssetsAtlas(textureAtlasLocation))
            .toTextureMap("content"));
    // reactorItemsTexture = await TextureAtlasLoader.loadAssetsAtlas(textureAtlasLocation);
    Shared.logger.info("Shared Resources initialized.");
  }
}
