import 'dart:convert';
import 'dart:ui' as ui;

import "package:path/path.dart" as path;

import 'package:nukleon/engine/engine.dart';

final class SpriteAtlasTextureFile {
  String name;
  Vector2 size;
  String repeat;
  List<String> filter;
  String format;
  String fileName;

  SpriteAtlasTextureFile(
      {required this.name,
      required this.size,
      required this.repeat,
      required this.filter,
      required this.fileName,
      required this.format});

  SpriteAtlasTextureFile.none()
      : name = "",
        size = Vector2.all(double.nan),
        repeat = "",
        fileName = "",
        filter = <String>[],
        format = "";

  bool isIncomplete() =>
      name.isEmpty ||
      size.isNaN ||
      repeat.isEmpty ||
      fileName.isEmpty ||
      filter.isEmpty ||
      format.isEmpty;

  @override
  String toString() {
    return "_PTXTFILE[$name,$size,$repeat,$filter,$format,$fileName]";
  }
}

final class SpriteAtlasSpriteTexture {
  String name;
  Vector2 offset;
  Vector2 xy;
  Vector2 size;
  int index;

  SpriteAtlasSpriteTexture(
      {required this.name,
      required this.xy,
      required this.size,
      required this.offset,
      required this.index});

  SpriteAtlasSpriteTexture.none()
      : name = "",
        xy = Vector2.all(double.nan),
        size = Vector2.all(double.nan),
        offset = Vector2.all(double.nan),
        index = -1;

  Rect get src => Rect.fromPoints(xy.toOffset(), (xy + size).toOffset());

  bool isIncomplete() =>
      name.isEmpty || xy.isNaN || size.isNaN || offset.isNaN || index == -1;

  @override
  String toString() {
    return "_PTXTSPRITE[$name,$src,$offset,$index]";
  }
}

class Sprite {
  static final Map<String, Sprite> registry = <String, Sprite>{};

  final Rect src;
  final String textureIdentifier;

  const Sprite(this.src, this.textureIdentifier);

  Sprite.fromComponents(this.textureIdentifier,
      {required Vector2 srcPosition, required Size srcSize})
      : src = Rect.fromLTWH(srcPosition.x, srcPosition.y, srcSize.width, srcSize.height);

  ui.Image get texture => BitmapRegistry.I.find(textureIdentifier);
}

final class SpriteAtlas {
  SpriteAtlas._();

  static (String key, String value) _breakLine(String line) {
    List<String> k = line.trim().split(":");
    return (k.first.trim(), k.last.trim());
  }

  /// Parses the sprites as well as load the base sprite texture files into the bitmap registry.
  static Future<void> parseAndLoadFromAssets(String assets) async {
    final String content = await rootBundle.loadString(assets);
    final List<SpriteAtlasSpriteTexture> sprites = <SpriteAtlasSpriteTexture>[];
    final Iterator<String> iterator = LineSplitter.split(content).iterator;
    SpriteAtlasTextureFile? file;
    SpriteAtlasSpriteTexture? texture;
    int loopSentinel = 0;
    int loopSentinel2 = 0; // for each individual sprite
    int i = 0; // represents line number
    while (iterator.moveNext()) {
      i++;
      String line = iterator.current;
      if (line.isNotEmpty) {
        if (file == null) {
          file = SpriteAtlasTextureFile.none();
          file.fileName = line.trim();
          file.name = path.basename(file.fileName).split(".").first;
        } else {
          if (loopSentinel > 4) {
            panicNow("SPRITE2D: Invalid Assets_Atlas file '$assets'.",
                details: "Loop Sentinel reached $loopSentinel on Line $i >>'$line'",
                help:
                    "This atlas file is invalid. Must only have properties: size, format, filter, repeat");
          } else if (file.isIncomplete()) {
            final (String, String) pageProperty = _breakLine(line);
            switch (pageProperty.$1) {
              case "size":
                final List<String> wh = pageProperty.$2.split(",");
                file.size = Vector2(double.parse(wh[0]), double.parse(wh[1]));
              case "format":
                file.format = pageProperty.$2;
              case "filter":
                final List<String> ft = pageProperty.$2.split(",");
                file.filter
                  ..add(ft[0].trim())
                  ..add(ft[1]
                      .trim()); // assuming its only two elements, which it should be (same with the size setting above)
              case "repeat":
                file.repeat = pageProperty.$2;
            }
            loopSentinel++;
          } else {
            if (texture == null) {
              texture = SpriteAtlasSpriteTexture.none();
              texture.name = line.trim();
            } else {
              if (loopSentinel2 > 6) {
                // probably isnt as helpful for debugging lol. but we will cross that bridge if the debugging manifest isnt useful later :)
                panicNow("SPRITE2D: Invalid Assets_Atlas Sprite '$assets'.",
                    details:
                        "Loop Sentinel 2 reached $loopSentinel2 on Line $i >>'$line'",
                    help:
                        "This sprite is invalid. Must only have properties: rotate, orig, index, offset, size, xy");
              } else if (texture.isIncomplete()) {
                final (String, String) pageProperty = _breakLine(line.trim());
                switch (pageProperty.$1) {
                  case "rotate":
                    // ignore
                    break;
                  case "orig":
                    //ignore
                    break;
                  case "index":
                    texture.index = int.parse(pageProperty.$2);
                  case "offset":
                    final List<String> offset = pageProperty.$2.split(",");
                    texture.offset = Vector2(
                        double.parse(offset[0].trim()), double.parse(offset[1].trim()));
                  case "size":
                    final List<String> size = pageProperty.$2.split(",");
                    texture.size = Vector2(
                        double.parse(size[0].trim()), double.parse(size[1].trim()));
                    logger.finest("SZ: $size");
                  case "xy":
                    final List<String> xy = pageProperty.$2.split(",");
                    texture.xy =
                        Vector2(double.parse(xy[0].trim()), double.parse(xy[1].trim()));
                    logger.finest("XY: $xy");
                }
                loopSentinel2++;
              }
              if (loopSentinel2 == 6) {
                sprites.add(texture);
                texture = null;
              }
            }
          }
        }
      }
    }
    logger.finest("HI $file");
    logger.finest("BYE $sprites");
  }
}
