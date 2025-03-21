/// The Nukleon game engine and game logic handler layer. It is responsible for providing a very
/// generalizable layer for creating 2D graphics as well as handling multimedia items including
/// audio, images, and shaders.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'package:nukleon/engine/graphics/graphics.dart';
import 'package:nukleon/engine/public.dart';
import 'package:nukleon/engine/utils/argus.dart';
export "dart:io";
export "graphics/graphics.dart";
export "package:flutter/foundation.dart";
export "package:flutter/material.dart" hide Route, OverlayRoute;
export "package:flutter/services.dart";
export "package:nukleon/engine/components/apollo/apollo.dart";
export "package:nukleon/engine/components/hermes/hermes.dart";
export "package:nukleon/engine/graphics/nulls.dart";
export "package:nukleon/engine/graphics/ui.dart";
export "package:nukleon/engine/registries/items_registry.dart";
export "package:vector_math/vector_math.dart" hide Colors, Matrix4;
export "public.dart";
export "registries/registries.dart";
export "sprite2d/sprite_set.dart";
export "utils/utils.dart";
export 'package:meta/meta.dart';
export 'sprite2d/sprite2d.dart';
export "utils/argus.dart";

final class Engine {
  Engine._();

  static Future<void> initializeEngine(
      {Level loggingLevel = Level.ALL, bool initializeTextureRegistry = true}) async {
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
    await Argus.initialize();
    // if (initializeTextureRegistry) {
    //   if (!Public.panicOnNullTextures &&
    //       (TextureRegistry.getTexture("internal.atlas") == null ||
    //           TextureRegistry.getTexture("internal.atlas")!.containsKey("Null_Texture") !=
    //               false)) {
    //     logger.warning(
    //         "Continuing with NO_PANIC and no Null_Texture can produce undefined behavior!");
    //   }
    // }
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
            fontFamily: "PixelPlay",
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xfffffaff),
              surfaceTint: Color(0xffe5c524),
              onPrimary: Color.fromARGB(255, 0, 0, 0),
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
            tooltipTheme: const TooltipThemeData(
                exitDuration: Duration.zero,
                decoration: BoxDecoration(borderRadius: BorderRadius.zero))),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        color: Colors.black,
        home: DefaultTextStyle(
            style: const TextStyle(
                fontFamily: "PixelPlay", color: Colors.white, fontSize: 16),
            child: Stack(children: <Widget>[
              Positioned.fill(child: child),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                    decoration: BoxDecoration(
                        color: C.black.withAlpha(200),
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(0)),
                    padding: const EdgeInsets.all(4),
                    child: const Text.rich(
                      TextSpan(
                          text: Public.kVersionDisplayString,
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                      textAlign: TextAlign.right,
                    )),
              )
            ])));
  }
}

@pragma("vm:prefer-inline")
void panicNow(String label, {String? details, String? help}) {
  logger.severe(
      "[[ !! Engine Panicked ${Public.useLennyFaceOnPanic ? 'ಠ╭╮ಠ' : ''} !! ]] '$label'");
  throw Exception(Public.formatErrorMessage(label, details, help));
}

@pragma("vm:prefer-inline")
void panicIf(bool condition, {required String label, String? details, String? help}) {
  if (condition) {
    panicNow(label, details: details, help: help);
  }
}

String get kPlatformSeparator {
  return Platform.isWindows
      ? "\\"
      : "/"; // just hardcoded so if you built your own OS and kernel which doesnt use this, good luck :<
}
