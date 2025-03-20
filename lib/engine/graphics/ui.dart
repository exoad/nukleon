import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/engine/utils/geom.dart' as geom;
import 'package:nukleon/game/classes/classes.dart';
import 'package:nukleon/game/shared.dart';

/// Drawing a single sprite. Decently performant for a single one
final class SingleSpritePainter extends ContentRenderer with RenderingMixin {
  final AtlasSprite sprite;
  final LinearTransformer? transformer;

  SingleSpritePainter({super.config, required SpriteTextureKey sprite, this.transformer})
      : sprite = sprite.findTexture();

  @override
  void paint(Canvas canvas, Size size) {
    if (transformer != null) {
      canvas.transform(transformer!.resolve(size, sprite.size).storage);
    }
    canvas.drawRawAtlas(
        sprite.image,
        Float32List(4)
          ..[0] = Shared.tileInitialZoom
          ..[1] = 0
          ..[2] = 0
          ..[3] = 0,
        Float32List(4)
          ..[0] = sprite.src.left
          ..[1] = sprite.src.top
          ..[2] = sprite.src.right
          ..[3] = sprite.src.bottom,
        null,
        null,
        Offset.zero & size,
        applyConfig(G.fasterPainter));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! SingleSpritePainter) {
      return false;
    } else {
      return oldDelegate.sprite != sprite;
    }
  }
}

class SingleSpriteWidget extends StatelessWidget {
  final SpriteTextureKey sprite;
  final LinearTransformer? transformer;
  final Widget? child;

  const SingleSpriteWidget(
      {super.key, required this.sprite, this.transformer, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: SingleSpritePainter(sprite: sprite, transformer: transformer),
        child: child);
  }
}

@immutable
final class SpriteWidgetPainter extends ContentRenderer {
  final List<AtlasSprite> sprites;
  final List<LinearTransformer>? transformations;
  final LinearTransformer? globalTransformer;

  SpriteWidgetPainter(
      {super.config,
      required List<SpriteTextureKey> sprites,
      required this.transformations,
      required this.globalTransformer})
      : sprites = sprites.map((SpriteTextureKey key) => key.findTexture()).toList();

  @override
  void paint(Canvas canvas, Size size) {
    if (sprites.isNotEmpty) {
      // ! might need to optimize this more
      // ! preferring drawImageRect is bad
      // ! we should instead prefer to use drawAtlas but we cant really do that if that is at all even
      // ! even more performant for just drawing a single image
      if (globalTransformer != null) {
        canvas.transform(globalTransformer!.resolve(size, size).storage);
      }
      if (transformations != null || transformations!.isNotEmpty) {
        for (int i = 0; i < sprites.length; i++) {
          if (transformations!.within(i)) {
            canvas.save();
            canvas.transform(transformations![i].resolve(size, sprites[i].size).storage);
            canvas.drawRawAtlas(
                sprites[i].image,
                Float32List(4)
                  ..[0] = Shared.tileInitialZoom
                  ..[1] = 0
                  ..[2] = 0
                  ..[3] = 0,
                Float32List(4)
                  ..[0] = sprites[i].src.left
                  ..[1] = sprites[i].src.top
                  ..[2] = sprites[i].src.right
                  ..[3] = sprites[i].src.bottom,
                null,
                null,
                Offset.zero & size,
                sprites[i].paint..applyConfig(config));
            canvas.restore();
          } else {
            canvas.drawRawAtlas(
                sprites[i].image,
                Float32List(4)
                  ..[0] = Shared.tileInitialZoom
                  ..[1] = 0
                  ..[2] = 0
                  ..[3] = 0,
                Float32List(4)
                  ..[0] = sprites[i].src.left
                  ..[1] = sprites[i].src.top
                  ..[2] = sprites[i].src.right
                  ..[3] = sprites[i].src.bottom,
                null,
                null,
                Offset.zero & size,
                sprites[i].paint..applyConfig(config));
          }
        }
      } else {
        for (int i = 0; i < sprites.length; i++) {
          canvas.drawRawAtlas(
              sprites[i].image,
              Float32List(4)
                ..[0] = Shared.tileInitialZoom
                ..[1] = 0
                ..[2] = 0
                ..[3] = 0,
              Float32List(4)
                ..[0] = sprites[i].src.left
                ..[1] = sprites[i].src.top
                ..[2] = sprites[i].src.right
                ..[3] = sprites[i].src.bottom,
              null,
              null,
              Offset.zero & size,
              sprites[i].paint..applyConfig(config));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is SpriteWidgetPainter &&
        (oldDelegate.globalTransformer != globalTransformer ||
            oldDelegate.sprites != sprites ||
            oldDelegate.transformations != transformations);
  }
}

@immutable
class SpriteWidget extends StatelessWidget {
  final List<SpriteTextureKey> spriteKeys;
  final List<LinearTransformer>? transformers;
  final LinearTransformer? globalTransformer;

  const SpriteWidget(this.spriteKeys,
      {super.key, this.transformers, this.globalTransformer});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: SpriteWidgetPainter(
            sprites: spriteKeys,
            transformations: transformers,
            globalTransformer: globalTransformer));
  }
}

// self implemented cuz the Canvas api doesnt have one lmao and stretching images from an
// atlas needs to be optimized ASF :D
class NineSliceScaledPainter extends ContentRenderer with RenderingMixin {
  final AtlasSprite sprite;
  final AtlasSprite? child;
  final EdgeInsets? border;
  final LinearTransformer? transformer;
  late final Float32List? _corners;
  final Float32List? _horiSides;
  final Float32List? _vertSides;
  final Float32List? _center;
  final FacetHints facetHints;
  final Float32List? _childRect;
  final double _sliceSize;

  NineSliceScaledPainter(
      {required this.sprite,
      this.transformer,
      super.config,
      this.child,
      required this.facetHints,
      this.border})
      : _sliceSize = sprite.src.width / 3,
        _corners = facetHints.corners
            ? Float32List(facetHints.calculateCornerTransforms())
            : null,
        _horiSides = facetHints.horizontalSides
            ? Float32List(facetHints.calculateHorizontalSideTransforms())
            : null,
        _vertSides = facetHints.verticalSides
            ? Float32List(facetHints.calculateVerticalSideTransforms())
            : null,
        _center = facetHints.center ? Float32List(4) : null,
        _childRect = child == null ? null : Float32List(4) {
    final double sliceSize1X = _sliceSize + sprite.src.topLeft.dx;
    final double sliceSize1Y = _sliceSize + sprite.src.topLeft.dy;
    final double sliceSize2X = sliceSize1X + _sliceSize;
    final double sliceSize2Y = sliceSize1Y + _sliceSize;
    int i = 0;
    if (facetHints.corners) {
      if (facetHints.topLeft) {
        // top left
        _corners![i++] = sprite.src.topLeft.dx;
        _corners[i++] = sprite.src.topLeft.dy;
        _corners[i++] = sliceSize1X;
        _corners[i++] = sliceSize1Y;
      }
      if (facetHints.topRight) {
        // top right
        _corners![i++] = sliceSize2X;
        _corners[i++] = sprite.src.topLeft.dy;
        _corners[i++] = sprite.src.topRight.dx;
        _corners[i++] = sliceSize1Y;
      }
      if (facetHints.bottomLeft) {
        // bottom left
        _corners![i++] = sprite.src.topLeft.dx;
        _corners[i++] = sliceSize2Y;
        _corners[i++] = sliceSize1X;
        _corners[i++] = sprite.src.bottomRight.dy;
      }
      if (facetHints.bottomRight) {
        // bottom right
        _corners![i++] = sliceSize2X;
        _corners[i++] = sliceSize2Y;
        _corners[i++] = sprite.src.bottomRight.dx;
        _corners[i++] = sprite.src.bottomRight.dy;
      }
    }
    i = 0;
    if (facetHints.horizontalSides) {
      if (facetHints.sideTop) {
        // top center
        _horiSides![i++] = sliceSize1X;
        _horiSides[i++] = sprite.src.topLeft.dy;
        _horiSides[i++] = sliceSize2X;
        _horiSides[i++] = sliceSize1Y;
      }
      if (facetHints.sideBottom) {
        // bottom center
        _horiSides![i++] = sliceSize1X;
        _horiSides[i++] = sliceSize2Y;
        _horiSides[i++] = sliceSize2X;
        _horiSides[i++] = sprite.src.bottomCenter.dy;
      }
    }
    i = 0;
    if (facetHints.verticalSides) {
      if (facetHints.sideLeft) {
        // center left
        _vertSides![i++] = sprite.src.topLeft.dx;
        _vertSides[i++] = sliceSize1Y;
        _vertSides[i++] = sliceSize1X;
        _vertSides[i++] = sliceSize2Y;
      }
      if (facetHints.sideRight) {
        // center right
        _vertSides![i++] = sliceSize2X;
        _vertSides[i++] = sliceSize1Y;
        _vertSides[i++] = sprite.src.centerRight.dx;
        _vertSides[i++] = sliceSize2Y;
      }
    }
    if (facetHints.center) {
      // center piece
      _center![0] = sliceSize1X;
      _center[1] = sliceSize1Y;
      _center[2] = sliceSize2X;
      _center[3] = sliceSize2Y;
    }
    // child
    if (child != null) {
      _childRect![0] = child!.src.left;
      _childRect[1] = child!.src.top;
      _childRect[2] = child!.src.right;
      _childRect[3] = child!.src.bottom;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = applyConfig(G.fasterPainter);
    final Rect frame = Offset.zero & size;
    if (facetHints.corners) {
      final Float32List cornersTransforms = Float32List(_corners!.length);
      final double cornerWidth = size.width - _sliceSize;
      final double cornerHeight = size.height - _sliceSize;
      int i = 0;
      if (facetHints.topLeft) {
        // top left
        cornersTransforms[i++] = 1;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = 0;
      }
      if (facetHints.topRight) {
        // top right
        cornersTransforms[i++] = 1;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = cornerWidth;
        cornersTransforms[i++] = 0;
      }
      if (facetHints.bottomLeft) {
        // bottom left
        cornersTransforms[i++] = 1;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = cornerHeight;
      }
      if (facetHints.bottomRight) {
        // bottom right
        cornersTransforms[i++] = 1;
        cornersTransforms[i++] = 0;
        cornersTransforms[i++] = cornerWidth;
        cornersTransforms[i++] = cornerHeight;
      }
      // here the `i` value should be the same as the one int he constructor at this point, if not, its prob logical bugs
      canvas.drawRawAtlas(
          sprite.image, cornersTransforms, _corners, null, null, frame, p);
    }
    final double horiSideScale =
        geom.mag(size.width - 2 * _sliceSize, _sliceSize) / geom.mag(_sliceSize, 0);
    final double horiSideX = _sliceSize / horiSideScale;
    if (facetHints.horizontalSides) {
      canvas.save();
      canvas.scale(horiSideScale, 1);
      final Float32List transformsHoriSides = Float32List(8);
      int i = 0;
      if (facetHints.sideTop) {
        // top center
        transformsHoriSides[i++] = 1;
        transformsHoriSides[i++] = 0;
        transformsHoriSides[i++] = horiSideX;
        transformsHoriSides[i++] = 0;
      }
      if (facetHints.sideBottom) {
        // bottom center
        transformsHoriSides[i++] = 1;
        transformsHoriSides[i++] = 0;
        transformsHoriSides[i++] = horiSideX;
        transformsHoriSides[i++] = size.height - _sliceSize;
      }
      canvas.drawRawAtlas(
          sprite.image, transformsHoriSides, _horiSides!, null, null, frame, p);
      canvas.restore();
    }
    final double vertSideScale =
        geom.mag(_sliceSize, size.height - 2 * _sliceSize) / geom.mag(0, _sliceSize);
    final double vertSideY = _sliceSize / vertSideScale;
    if (facetHints.verticalSides) {
      canvas.save();
      canvas.scale(1, vertSideScale);
      final Float32List transformVertiSides = Float32List(8);
      int i = 0;
      if (facetHints.sideLeft) {
        // center left
        transformVertiSides[i++] = 1;
        transformVertiSides[i++] = 0;
        transformVertiSides[i++] = 0;
        transformVertiSides[i++] = vertSideY;
      }
      if (facetHints.sideRight) {
        // center right
        transformVertiSides[i++] = 1;
        transformVertiSides[i++] = 0;
        transformVertiSides[i++] = size.width - _sliceSize;
        transformVertiSides[i++] = vertSideY;
      }
      canvas.drawRawAtlas(
          sprite.image, transformVertiSides, _vertSides!, null, null, frame, p);
      canvas.restore();
    }
    canvas.save();
    canvas.scale(horiSideScale, vertSideScale);
    if (facetHints.center) {
      final Float32List transformCenter = Float32List(4);
      // center
      transformCenter[0] = 1;
      transformCenter[1] = 0;
      transformCenter[2] = horiSideX;
      transformCenter[3] = vertSideY;
      canvas.drawRawAtlas(sprite.image, transformCenter, _center!, null, null, frame, p);
    }
    canvas.restore();
    if (child != null) {
      if (transformer != null) {
        canvas.transform(transformer!.resolve(size, sprite.size).storage);
      }
      canvas.transform(Matrix4.translationValues((size.width - sprite.size.width) / 2,
              (size.height - sprite.size.height) / 2, 0)
          .storage);
      canvas.drawRawAtlas(
          child!.image,
          Float32List(4)
            ..[0] = 1
            ..[1] = 0
            ..[2] = 0
            ..[3] = 0,
          _childRect!,
          null,
          null,
          frame,
          p);
    }
  }

  @override
  bool shouldRepaint(covariant ContentRenderer oldDelegate) {
    if (oldDelegate is! NineSliceScaledPainter) {
      return false;
    } else {
      return oldDelegate._center != _center ||
          oldDelegate._corners != _corners ||
          oldDelegate._horiSides != _horiSides ||
          oldDelegate._vertSides != _vertSides ||
          oldDelegate.sprite.src != sprite.src;
    }
  }
}

class NineSpriteWidget extends StatelessWidget {
  final AtlasSprite sprite;
  final AtlasSprite? child;
  final EdgeInsets border;
  final Widget? widgetChild;
  final LinearTransformer? transformer;
  final RenderingHints? config;
  final FacetHints facetHints;

  NineSpriteWidget(
      {super.key,
      required SpriteTextureKey sprite,
      SpriteTextureKey? child,
      this.border = EdgeInsets.zero,
      this.widgetChild,
      required this.facetHints,
      this.transformer,
      this.config})
      : assert(onlyOneNull(widgetChild, child),
            "Specify either only a [sprite] ($child) or a [widget] ($widgetChild) for a nine slice scaling widget!"),
        sprite = sprite.findTexture(),
        child = child?.findTexture();

  const NineSpriteWidget.resolved(
      {super.key,
      required this.sprite,
      this.child,
      this.border = EdgeInsets.zero,
      required this.facetHints,
      this.widgetChild,
      this.transformer,
      this.config});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NineSliceScaledPainter(
        sprite: sprite,
        transformer: transformer,
        config: config,
        facetHints: facetHints,
        child: child,
        border: border,
      ),
      child: widgetChild != null
          ? Padding(padding: border, child: widgetChild)
          : SizedBox(
              width: border.horizontal,
              height: border.vertical,
            ),
    );
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
