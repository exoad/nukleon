import 'package:flame/cache.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shitter/engine/public.dart';
import 'package:shitter/engine/registries/textures_registries.dart';

export "public.dart";
export "registries/registries.dart";
export "utils/utils.dart";
export "graphics/graphics.dart";
export "components/components.dart";
export "package:flutter/material.dart" hide Route, OverlayRoute;
export "package:flutter/services.dart";
export "package:flutter/foundation.dart";
export "package:flame/components.dart";

typedef TextureAtlas = TexturePackerAtlas;
typedef AtlasSprite = TexturePackerSprite;

Future<void> initializeEngine([Level loggingLevel = Level.ALL]) async {
  hierarchicalLoggingEnabled = true;
  logger.level = loggingLevel;
  logger.onRecord.listen((LogRecord record) {
    final String built =
        "ENGINE_[${record.level.name.padRight(7)}]: ${record.time.year}-${record.time.month}-${record.time.day}, ${record.time.hour}:${record.time.minute}:${record.time.millisecond}: ${record.message}";
    print(built);
  });
  logger.info("Initializing the engine...");
  WidgetsFlutterBinding.ensureInitialized();
  await Public.initialize();
  await TextureRegistry.initialize();
  if (!Public.panicOnNullTextures &&
      (TextureRegistry.getTexture("internal.atlas") == null ||
          TextureRegistry.getTexture("internal.atlas")!.containsKey("Null_Texture") !=
              false)) {
    logger.warning(
        "Continuing with NO_PANIC and no Null_Texture can produce undefined behavior!");
  }
  logger.info("Engine initialized!");
}

@pragma("vm:prefer-inline")
void panicNow(String label, {String? details, String? help}) {
  logger.severe(
      "[[ !! Engine Panicked ${Public.useLennyFaceOnPanic ? 'ಠ╭╮ಠ' : ''} !! ]] '$label'");
  throw Public.formatErrorMessage(label, details, help);
}

@pragma("vm:prefer-inline")
void panicIf(bool condition, {required String label, String? details, String? help}) {
  if (condition) {
    panicNow(label, details: details, help: help);
  }
}

extension MoreFuncsSprite on AtlasSprite {
  Size get size => src.size;
}

class TextureAtlasLoader {
  TextureAtlasLoader._();

  static Future<TextureAtlas> loadAssetsAtlas(String path,
          {Images? images, bool useOriginalSize = true}) async =>
      await TextureAtlas.load(path, images: images, useOriginalSize: useOriginalSize);
}
