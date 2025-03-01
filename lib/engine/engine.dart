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

final class Engine {
  Engine._();

  static Future<void> initializeEngine([Level loggingLevel = Level.ALL]) async {
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

  static void bootstrap<E extends Widget>(E entry) {
    runApp(E != GameEntry ? GameEntry(entry) : entry);
  }
}

class GameEntry extends StatelessWidget {
  final Widget child;
  const GameEntry(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xfffffaff),
              surfaceTint: Color(0xffe5c524),
              onPrimary: Color(0xff3a3000),
              primaryContainer: Color(0xffffde3f),
              onPrimaryContainer: Color(0xff736100),
              secondary: Color(0xffffdbcc),
              onSecondary: Color(0xff50240b),
              secondaryContainer: Color(0xffffb693),
              onSecondaryContainer: Color(0xff7a452a),
              tertiary: Color(0xffffc480),
              onTertiary: Color(0xff472a00),
              tertiaryContainer: Color(0xffeea446),
              onTertiaryContainer: Color(0xff643c00),
              error: Color(0xffffb4ab),
              onError: Color(0xff690005),
              errorContainer: Color(0xff93000a),
              onErrorContainer: Color(0xffffdad6),
              surface: Color(0xff16130a),
              onSurface: Color(0xffe9e2d1),
              onSurfaceVariant: Color(0xffcfc6ad),
              outline: Color(0xff989079),
              outlineVariant: Color(0xff4c4733),
              shadow: Color(0xff000000),
              scrim: Color(0xff000000),
              inverseSurface: Color(0xffe9e2d1),
              inversePrimary: Color(0xff6e5d00),
              primaryFixed: Color(0xffffe25e),
              onPrimaryFixed: Color(0xff221b00),
              primaryFixedDim: Color(0xffe5c524),
              onPrimaryFixedVariant: Color(0xff534600),
              secondaryFixed: Color(0xffffdbcb),
              onSecondaryFixed: Color(0xff341000),
              secondaryFixedDim: Color(0xffffb693),
              onSecondaryFixedVariant: Color(0xff6c3a1f),
              tertiaryFixed: Color(0xffffddb9),
              onTertiaryFixed: Color(0xff2b1700),
              tertiaryFixedDim: Color(0xffffb964),
              onTertiaryFixedVariant: Color(0xff663e00),
              surfaceDim: Color(0xff16130a),
              surfaceBright: Color(0xff3d392e),
              surfaceContainerLowest: Color(0xff100e06),
              surfaceContainerLow: Color(0xff1e1b11),
              surfaceContainer: Color(0xff222015),
              surfaceContainerHigh: Color(0xff2d2a1f),
              surfaceContainerHighest: Color(0xff383529),
            ),
            tooltipTheme: TooltipThemeData(
                exitDuration: Duration.zero,
                decoration: const BoxDecoration(borderRadius: BorderRadius.zero))),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        color: Colors.black,
        home: DefaultTextStyle(
            style: const TextStyle(
                fontFamily: "PixelPlay", color: Colors.white, fontSize: 16),
            child: child));
  }
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
