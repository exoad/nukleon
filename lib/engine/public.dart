import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:project_yellow_cake/engine/utils/extern.dart';

final class Public {
  Public._();

  static bool panicOnNullTextures = true;
  static int textureFilter = PublicK.TEXTURE_FILTER_NONE;
  static bool warnOnTextureMapDuplicateSprites = false;
  static Future<void> initialize() async {
    logger.info("Public Resources initialized.");
  }

  static const int panicMessageLength = 64;
  static const String panicMessageWrapIndent = "  ";

  static String formatErrorMessage(String message, [String? internal, String? help]) {
    StringBuffer buffer = StringBuffer("\n\n");
    Iterable<String> messageWrapped =
        debugWordWrap(message, panicMessageLength, wrapIndent: panicMessageWrapIndent);
    Iterable<String>? helpWrapped = help == null
        ? null
        : debugWordWrap("Help: $help", panicMessageLength,
            wrapIndent: panicMessageWrapIndent);
    int maxInternalLength = -1;
    StringBuffer? internalStrBuffer;
    if (internal != null) {
      internalStrBuffer = StringBuffer();
      internalStrBuffer.write("\n\n");
      for (String r in internal.split("\n")) {
        Iterable<String> wrapped =
            debugWordWrap(r, panicMessageLength, wrapIndent: panicMessageWrapIndent);
        internalStrBuffer.write(" ${wrapped.join("\n")}");
        maxInternalLength = max(maxInternalLength, wrapped.longestString.length + 1);
      }
    }
    int maxStripes = max(messageWrapped.length + 1,
                max(helpWrapped?.length ?? -1, maxInternalLength)) ~/
            2 +
        2;
    for (int i = 0; i < maxStripes; i++) {
      buffer.write("◢◤");
    }
    buffer.write("\n\n ${messageWrapped.join("\n")}");
    if (internalStrBuffer != null) {
      buffer.writeln("\n");
      for (int i = 0; i < maxStripes * 2 - 1; i++) {
        buffer.write("▱");
      }
      buffer.write(internalStrBuffer.toString());
      internalStrBuffer.clear();
    }
    if (help != null) {
      buffer.writeln();
      for (int i = 0; i < maxStripes * 2 - 1; i++) {
        buffer.write("▱");
      }
      buffer.write("\n ${helpWrapped!.join("\n")}\n\n");
    } else {
      buffer.writeln("\n");
    }
    for (int i = 0; i < maxStripes; i++) {
      buffer.write("◢◤");
    }
    buffer.write("\n\n");
    return buffer.toString();
  }
}

final Logger logger = Logger("Engine");

final class PublicK {
  static const int TEXTURE_FILTER_NONE = 0;
  static const int TEXTURE_FILTER_LOW = 1;
  static const int TEXTURE_FILTER_MEDIUM = 2;
  static const int TEXTURE_FILTER_HIGH = 3;
}

enum Class {
  BACKDROPS,
  ITEMS,
  INFO,
  OVERLAY,
  UI;

  static Class get baseLayer {
    return ITEMS;
  }

  static List<Class> get zeroNonDrawable {
    return const <Class>[ITEMS, INFO, OVERLAY];
  }

  static List<Class> get zeroDrawable {
    return const <Class>[BACKDROPS];
  }
}
