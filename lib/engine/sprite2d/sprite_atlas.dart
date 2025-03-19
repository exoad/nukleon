import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/utils/images.dart';
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

@immutable
class Sprite with EquatableMixin {
  /// Represents where this sprite is located on the texture atlas
  final Rect src;

  /// A strict rule of which texture atlas this sprite should pull from
  final String textureAtlas;

  /// The identifier is used not only to identify this Sprite, but also used to identify the texture it belongs to.
  final String identifier;

  const Sprite(this.textureAtlas, this.src, this.identifier);

  Sprite.fromComponents(this.identifier, this.textureAtlas,
      {required Vector2 srcPosition, required Size srcSize})
      : src = Rect.fromLTWH(srcPosition.x, srcPosition.y, srcSize.width, srcSize.height);

  ui.Image get texture => BitmapRegistry.I.find(identifier);

  @override
  String toString() {
    return "Sprite2D '$identifier'::'$textureAtlas' [${src.topLeft} -- ${src.bottomRight}]";
  }

  @override
  List<Object?> get props => <Object?>[src, identifier];
}

final class SpriteRegistry {
  final Map<String, Set<Sprite>> _map;

  SpriteRegistry._() : _map = <String, Set<Sprite>>{};

  static final SpriteRegistry I = SpriteRegistry._();

  bool hasAtlas(String atlas) {
    return _map.containsKey(atlas);
  }

  bool doesAtlasHave(String atlas, String identifier) {
    return _map.containsKey(atlas) &&
        _map[atlas]!.any((Sprite sprite) => sprite.identifier == identifier);
  }

  void register(String atlas) {
    if (_map.containsKey(atlas) && _map[atlas]!.isNotEmpty) {
      logger.warning(
          "The Sprite Registry will clear $atlas because it already existed with ${_map[atlas]!.length} sprites");
      _map[atlas]!.clear();
    } else {
      _map[atlas] = <Sprite>{};
    }
  }

  Sprite getFrom(String atlas, String identifier) {
    if (!_map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    for (Sprite r in _map[atlas]!) {
      if (r.identifier == identifier) {
        return r;
      }
    }
    panicNow("Could not find sprite '$identifier' under $atlas.");
    throw "";
  }

  void addTo(String atlas, Sprite sprite) {
    if (!_map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    _map[atlas]!.add(sprite);
  }

  void addAllTo(String atlas, Iterable<Sprite> sprite) {
    if (!_map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    _map[atlas]!.addAll(sprite);
  }

  Set<Sprite> getAll(String atlas) {
    if (!_map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    return _map[atlas]!;
  }
}

final class SpriteAtlasRaw {
  final SpriteAtlasTextureFile file;
  final List<SpriteAtlasSpriteTexture> sprites;

  SpriteAtlasRaw({required this.file, required this.sprites});
}

/// Any functions that are suffixed with 'N' means it will return a raw parsed data format using [SpriteAtlasRaw]
/// which is just a glorified record.
///
/// The 'N' also means it is **NOT REIFIED** meaning that no type checking or proper data validity is accounted for.
/// This means a `size` property can have a single [int] value instead of a proper `width, height` format.
///
/// If you need reified functions, use functions that are suffixed with 'R'.
///
/// However, the two above functions do not load the image into the [BitmapRegistry] which is required by the engine to
/// actually use the textures. To make the engine auto load the images pointed to by the atlas sprites, you need to
/// call functions prefixed with 'L' (which stands for Load). These functions will also perform reification in order to
/// actually load the images and bitmap data.
final class SpriteAtlas {
  SpriteAtlas._();

  static (String key, String value) _breakLine(String line) {
    List<String> k = line.trim().split(":");
    return (k.first.trim(), k.last.trim());
  }

  static SpriteAtlasRaw parseN(String key, String content) {
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
            panicNow("SPRITE2D: Invalid Assets_Atlas file '$key'.",
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
                panicNow("SPRITE2D: Invalid Assets_Atlas Sprite '$key'.",
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
                  case "xy":
                    final List<String> xy = pageProperty.$2.split(",");
                    texture.xy =
                        Vector2(double.parse(xy[0].trim()), double.parse(xy[1].trim()));
                }
                loopSentinel2++;
              }
              if (loopSentinel2 == 6) {
                sprites.add(texture);
                texture = null;
                loopSentinel2 = 0;
              }
            }
          }
        }
      }
    }
    if (file == null || file.isIncomplete()) {
      panicNow("SPRITE2D: Failed to parse Asset_Atlas '$key'");
    }
    return SpriteAtlasRaw(
        file: file! /*shldnt be null here :) but dart requires the bang!*/,
        sprites: sprites);
  }

  /// Parses the sprites as well as load the base sprite texture files into the bitmap registry.
  static Future<SpriteAtlasRaw> parseAssetsN(String assets) async {
    return parseN(assets, await rootBundle.loadString(assets));
  }

  /// If [dontLoadIfEmpty] is `true`, this function will not load the atlas texture if there are no subsequent sprites mapped to it.
  static Future<void> parseAssetsR(String assets, [bool dontLoadIfEmpty = true]) async {
    SpriteAtlasRaw atlas = await parseAssetsN(assets);
    if (!dontLoadIfEmpty) {
      BitmapRegistry.I.registerEntry(BitmapEntry(
          atlas.file.name,
          await ImagesUtil.readAssetImage(
              "${path.dirname(assets)}${Platform.pathSeparator}${atlas.file.fileName}")));
    }
  }
}
