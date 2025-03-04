import 'package:logging/logging.dart';
import 'package:nukleon/engine/engine.dart';

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

  static const String textureAtlasLocation = "textures/reactor_items.atlas";
  static const String uiTextureAtlasLocation = "textures/ui_content.atlas";
  static const String tilesTextureAtlasLocation = "textures/tiles.atlas";
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
    TextureRegistry.registerTextureMaps(<String, TextureMap>{
      "content": (await TextureAtlasLoader.loadAssetsAtlas(textureAtlasLocation))
          .toTextureMap("content"),
      "ui_content": (await TextureAtlasLoader.loadAssetsAtlas(uiTextureAtlasLocation))
          .toTextureMap("ui_content"),
      "tiles_content":
          (await TextureAtlasLoader.loadAssetsAtlas(tilesTextureAtlasLocation))
              .toTextureMap("tiles_content"),
      "icons_content":
          (await TextureAtlasLoader.loadAssetsAtlas(iconsTextureAtlasLocation))
              .toTextureMap("icons_content"),
      "concept_ui":
          (await TextureAtlasLoader.loadAssetsAtlas("textures/concept_ui.atlas"))
              .toTextureMap("concept_ui")
    });
    // reactorItemsTexture = await TextureAtlasLoader.loadAssetsAtlas(textureAtlasLocation);
    Shared.logger.info("Shared Resources initialized.");
  }
}
