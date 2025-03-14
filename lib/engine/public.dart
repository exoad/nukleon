import 'dart:math';

import 'package:logging/logging.dart';
import 'package:nukleon/engine/engine.dart';

final class Public {
  Public._();

  static const bool devMode = true;
  static const String version = "1.0.0-closed-beta";
  static const String kVersionDisplayString =
      "$version\nClosed-Beta (${devMode ? "DEV_MODE" : "NORMAL"})\nPerformance and Content are subject to change";

  static bool panicOnNullTextures = true;

  static FilterQuality textureFilter = FilterQuality.none;
  static bool warnOnTextureMapDuplicateSprites = false;
  static bool useLennyFaceOnPanic = true;

  /// The engine will try not to panic if it can. However, this does not mean the program cannot panic.
  static bool preferWarnings = true;
  static final Random random1 = Random(DateTime.now().microsecondsSinceEpoch);
  static Future<void> initialize() async {
    logger.info("Public Resources initialized.");
  }

  static const int panicMessageLength = 64;
  static const String panicMessageWrapIndent = "  ";

  @pragma("vm:prefer-inline")
  static int _debugWrapHandleEdgeCase(Iterable<String>? s) {
    if (s == null) {
      return -1;
    }
    if (s.length == 1) {
      return s.first.length + 1;
    }
    return s.longestString.length + 1;
  }

  /// In regards to #19: https://github.com/exoad/nukleon/issues/19
  static Iterable<String> _wrapperDebugWordWrap(String r) {
    List<String> res = <String>[];
    for (String r in r.split("\n")) {
      res.add(debugWordWrap(r, panicMessageLength, wrapIndent: panicMessageWrapIndent)
          .join("\n"));
    }
    return res;
  }

  static String formatErrorMessage(String message, [String? internal, String? help]) {
    StringBuffer buffer = StringBuffer("\n\n");
    Iterable<String> messageWrapped = _wrapperDebugWordWrap(message);
    Iterable<String>? helpWrapped =
        help == null ? null : _wrapperDebugWordWrap("Help: $help");
    int maxInternalLength = -1;
    StringBuffer? internalStrBuffer;
    if (internal != null) {
      internalStrBuffer = StringBuffer();
      internalStrBuffer.write("\n\n");
      for (String r in internal.split("\n")) {
        Iterable<String> wrapped = _wrapperDebugWordWrap(r);
        internalStrBuffer.write(" ${wrapped.join("\n")}");
        maxInternalLength = max(maxInternalLength, wrapped.longestString.length + 1);
      }
    }
    int maxStripes = (max(_debugWrapHandleEdgeCase(messageWrapped),
                max(_debugWrapHandleEdgeCase(helpWrapped), maxInternalLength)) ~/
            2) +
        2;
    for (int i = 0; i < maxStripes; i++) {
      buffer.write("◢◤");
    }
    buffer.write("\n ${messageWrapped.join("\n")}");
    if (internalStrBuffer != null) {
      buffer
        ..writeln()
        ..writeln();
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
      buffer.write("\n ${helpWrapped!.join("\n")}\n");
    }
    buffer.writeln();
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
  TILES,
  ITEMS,
  INFO,
  OVERLAY,
  UI,
  CHARACTER;
}
