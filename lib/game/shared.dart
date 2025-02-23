import 'package:logging/logging.dart';
import 'package:shitter/engine/engine.dart';

final class Shared {
  Shared._();

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

  static const String textureAtlasLocation = "textures/content.atlas";
  static const String uiTextureAtlasLocation = "textures/ui_content.atlas";
  static const String tilesTextureAtlasLocation = "textures/tiles_content.atlas";
  static const String iconsTextureAtlasLocation = "textures/icons_content.atlas";

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
    TextureRegistry.registerTextureMap(
        "ui_content",
        (await TextureAtlasLoader.loadAssetsAtlas(uiTextureAtlasLocation))
            .toTextureMap("ui_content"));
    TextureRegistry.registerTextureMap(
        "tiles_content",
        (await TextureAtlasLoader.loadAssetsAtlas(tilesTextureAtlasLocation))
            .toTextureMap("tiles_content"));
    TextureRegistry.registerTextureMap(
        "icons_content",
        (await TextureAtlasLoader.loadAssetsAtlas(iconsTextureAtlasLocation))
            .toTextureMap("icons_content"));
    // reactorItemsTexture = await TextureAtlasLoader.loadAssetsAtlas(textureAtlasLocation);
    Shared.logger.info("Shared Resources initialized.");
  }
}
