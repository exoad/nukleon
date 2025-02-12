import 'package:logging/logging.dart';

final class Public {
  Public._();

  static bool panicOnNullTextures = true;
  static int textureFilter = PublicK.TEXTURE_FILTER_NONE;
  static bool warnOnTextureMapDuplicateSprites = false;
  static Future<void> initialize() async {
    logger.info("Public Resources initialized.");
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
