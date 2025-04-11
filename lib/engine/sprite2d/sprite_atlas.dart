import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/utils/geom.dart';
import 'package:nukleon/engine/utils/images.dart';
import "package:path/path.dart" as path;

import 'package:nukleon/engine/engine.dart';

final class SpriteAtlasTextureFile {
  String name;
  Vector2 size;
  List<String> filter;
  String format;
  String fileName;

  SpriteAtlasTextureFile(
      {required this.name,
      required this.size,
      required this.filter,
      required this.fileName,
      required this.format});

  SpriteAtlasTextureFile.none()
      : name = "",
        size = Vector2.all(double.nan),
        fileName = "",
        filter = <String>[],
        format = "";

  bool isIncomplete() =>
      name.isEmpty || size.isNaN || fileName.isEmpty || filter.isEmpty || format.isEmpty;

  @override
  String toString() {
    return "_PTXTFILE[$name,$size,$filter,$format,$fileName]";
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

  bool isIncomplete() => name.isEmpty || xy.isNaN || size.isNaN || offset.isNaN || index == -1;

  @override
  String toString() {
    return "_PTXTSPRITE[$name,$src,$offset,$index]";
  }
}

final class SpriteAtlasRegistry extends Registry<String, SpriteAtlas>
    with SimpleRegistryMixin<String, SpriteAtlas> {
  SpriteAtlasRegistry._() : super();

  static final SpriteAtlasRegistry I = SpriteAtlasRegistry._();

  @override
  String toString() {
    return "SpriteAtlasRegistry:\n${super.toString()}";
  }
}

final class SpriteRegistry extends Registry<String, Set<Sprite>> {
  SpriteRegistry._() : super();

  static final SpriteRegistry I = SpriteRegistry._();

  bool hasAtlas(String atlas) {
    return super.map.containsKey(atlas);
  }

  bool doesAtlasHave(String atlas, String identifier) {
    return super.map.containsKey(atlas) &&
        super.map[atlas]!.any((Sprite sprite) => sprite.identifier == identifier);
  }

  void wipeAtlas(String atlas) {
    if (super.map.containsKey(atlas)) {
      super.map[atlas]!.clear();
    } else {
      logger.warning("SpriteRegistry cannot wipe an unregistered atlas '$atlas'");
    }
  }

  void register(String atlas) {
    if (super.map.containsKey(atlas) && super.map[atlas]!.isNotEmpty) {
      logger.warning(
          "The Sprite Registry will clear $atlas because it already existed with ${super.map[atlas]!.length} sprites");
      super.map[atlas]!.clear();
    } else {
      super.map[atlas] = <Sprite>{};
      logger.finer("SpriteRegistered NEW_ATLAS $atlas");
    }
  }

  Sprite getFrom(String atlas, String identifier) {
    if (!super.map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    for (Sprite r in super.map[atlas]!) {
      if (r.identifier == identifier) {
        return r;
      }
    }
    panicNow("Could not find sprite '$identifier' under $atlas.",
        details: "$atlas has: \n${super.map[atlas]}");
    throw "";
  }

  Sprite? tryGetFrom(String atlas, String identifier) {
    for (Sprite r in super.map[atlas]!) {
      if (r.identifier == identifier) {
        return r;
      }
    }
    return null;
  }

  void addTo(String atlas, Sprite sprite) {
    if (!super.map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    logger.finer("SpriteRegistry ADD to $atlas -> $sprite");
    super.map[atlas]!.add(sprite);
  }

  void addAllTo(String atlas, Iterable<Sprite> sprite) {
    if (!super.map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    logger.finer("SpriteRegistry ADD to $atlas -> $sprite");
    super.map[atlas]!.addAll(sprite);
  }

  Set<Sprite> getAll(String atlas) {
    if (!super.map.containsKey(atlas)) {
      panicNow("SpriteRegistry does not have an atlas '$atlas'",
          help: "Maybe Register/Load the atlas first?");
    }
    return super.map[atlas]!;
  }

  @override
  String toString() {
    return "SpriteRegistry:\n${super.toString()}";
  }
}

enum SpritePageFilter {
  NEAREST,
  LINEAR,
  MIPMAP,

  /// nearest nearest
  MIPMAP_NN,

  /// linear nearest
  MIPMAP_LN,

  /// nearest linear
  MIPMAP_NL,

  /// linear linear
  MIPMAP_LL;
}

enum SpriteFileEncoding {
  RGBA8888,
  RGBA4444,
  RGB888,
  RGB565,
  ALPHA;
}

final class SpriteAtlasRaw {
  final SpriteAtlasTextureFile file;
  final List<SpriteAtlasSpriteTexture> sprites;

  SpriteAtlasRaw({required this.file, required this.sprites});
}

/// The class itself represents a fully reified definition of a Sprite Atlas. To get a reified option, see below.
///
/// ** FOR READING A SPRITE ATLAS FILE**
///
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
@immutable
final class SpriteAtlas with EquatableMixin {
  final String fileName;
  final String identifier;
  final Size size;
  final SpritePageFilter minFilter;
  final SpritePageFilter magFilter;
  final SpriteFileEncoding encoding;

  const SpriteAtlas(
      {required this.fileName,
      required this.identifier,
      required this.size,
      required this.minFilter,
      required this.magFilter,
      required this.encoding});

  SpriteAtlas.fromRaw(SpriteAtlasRaw raw)
      : fileName = raw.file.fileName,
        identifier = raw.file.name,
        size = raw.file.size.toSize(),
        encoding = SpriteFileEncoding.values.firstWhere(
            (SpriteFileEncoding encoding) => raw.file.format.equalsIgnoreCase(encoding.name)),
        magFilter = SpritePageFilter.values.firstWhere(
            (SpritePageFilter filter) => filter.name.equalsIgnoreCase(raw.file.filter[1]),
            orElse: () => SpritePageFilter.NEAREST),
        minFilter = SpritePageFilter.values.firstWhere(
            (SpritePageFilter filter) => filter.name.equalsIgnoreCase(raw.file.filter[0]),
            orElse: () => SpritePageFilter.NEAREST);

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
          if (loopSentinel > 5) {
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
                // ignored
                break;
            }
            loopSentinel++;
          } else {
            if (texture == null) {
              texture = SpriteAtlasSpriteTexture.none();
              texture.name = line.trim();
            } else {
              // if (loopSentinel2 > 7) {
              //   // probably isnt as helpful for debugging lol. but we will cross that bridge if the debugging manifest isnt useful later :)
              //   panicNow("SPRITE2D: Invalid Assets_Atlas Sprite '$key'.",
              //       details:
              //           "Loop Sentinel 2 reached $loopSentinel2 on Line $i >>'$line'",
              //       help:
              //           "This sprite is invalid. Must only have properties: rotate, orig, index, offset, size, xy");
              // } else
              if (texture.isIncomplete()) {
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
                    texture.offset =
                        Vector2(double.parse(offset[0].trim()), double.parse(offset[1].trim()));
                  case "size":
                    final List<String> size = pageProperty.$2.split(",");
                    texture.size =
                        Vector2(double.parse(size[0].trim()), double.parse(size[1].trim()));
                  case "xy":
                    final List<String> xy = pageProperty.$2.split(",");
                    texture.xy = Vector2(double.parse(xy[0].trim()), double.parse(xy[1].trim()));
                }
                loopSentinel2++;
              }
              if (!texture.isIncomplete()) {
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
        file: file! /*shldnt be null here :) but dart requires the bang!*/, sprites: sprites);
  }

  /// Parses the sprites as well as load the base sprite texture files into the bitmap registry.
  static Future<SpriteAtlasRaw> parseAssetsN(String assets) async {
    if (!Argus.isValidAsset(assets)) {
      panicNow("SPRITE2D: '$assets' is not a valid assets file.",
          help: "Make sure everything is spelled correctly ;)");
    }
    return parseN(assets, await rootBundle.loadString(assets));
  }

  /// If [dontLoadIfEmpty] is `true`, this function will not load the atlas texture if there are no subsequent sprites mapped to it.
  /// Everything is mapped to [SpriteRegistry] and [BitmapRegistry]
  static Future<void> parseAssetsL(String assets, [bool dontLoadIfEmpty = true]) async {
    SpriteAtlasRaw atlas = await parseAssetsN(assets);
    if (!dontLoadIfEmpty || atlas.sprites.isNotEmpty) {
      BitmapRegistry.I.registerEntry(BitmapEntry(
          atlas.file.name,
          await ImagesUtil.readAssetImage(
              "${path.dirname(assets)}/${atlas.file.fileName}"))); // O_o might be an issue with the path separator idk, hardcoded path separator is yikes.
      SpriteRegistry.I.register(atlas.file.name);
      for (SpriteAtlasSpriteTexture texture in atlas.sprites) {
        SpriteRegistry.I.addTo(atlas.file.name, Sprite(atlas.file.name, texture.src, texture.name));
      }
    } else {
      logger.warning("Empty sprite atlas $assets, ignoring...");
    }
  }

  @override
  List<Object?> get props => <Object>[
        fileName,
        identifier,
        magFilter,
        minFilter,
        encoding,
        size,
      ];
}
