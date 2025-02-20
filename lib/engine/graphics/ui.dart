import 'package:shitter/engine/engine.dart';
import 'package:shitter/engine/utils/geom.dart' as geom;

@immutable
final class _SpriteWidgetPainter extends ContentRenderer {
  final List<AtlasSprite> sprites;
  final List<LinearTransformer>? transformations;
  final LinearTransformer? globalTransformer;

  const _SpriteWidgetPainter(this.sprites, this.transformations,
      {this.globalTransformer, super.config});

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
      if (transformations != null) {
        for (int i = 0; i < sprites.length; i++) {
          if (transformations!.within(i)) {
            canvas.transform(transformations![i]
                .resolve(size, Size(sprites[i].originalWidth, sprites[i].originalHeight))
                .storage);
          }
          canvas.drawImageRect(
              sprites[i].image,
              sprites[i].src,
              Rect.fromLTWH(0, 0, size.width, size.height),
              sprites[i].paint..applyConfig(config));
        }
      } else {
        for (int i = 0; i < sprites.length; i++) {
          canvas.drawImageRect(
              sprites[i].image,
              sprites[i].src,
              Rect.fromLTWH(0, 0, size.width, size.height),
              sprites[i].paint..applyConfig(config));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

@immutable
class SpriteWidget extends StatelessWidget {
  final List<AtlasSprite> sprites;
  final List<LinearTransformer>? transformers;
  final LinearTransformer? globalTransformer;
  final PaintConfig? config;

  const SpriteWidget(this.sprites,
      {super.key, this.transformers, this.globalTransformer, this.config});

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: _SpriteWidgetPainter(sprites, transformers,
          globalTransformer: globalTransformer, config: config));
}

// self implemented cuz the Canvas api doesnt have one lmao and stretching images from an
// atlas needs to be optimized ASF :D
class _NineSpriteWidgetPainter extends ContentRenderer with RenderingMixin {
  final AtlasSprite sprite;
  final LinearTransformer? transformer;
  final EdgeInsets border;
  late final Float32List _corners;
  final Float32List _horiSides;
  final Float32List _vertSides;
  final Float32List _center;
  final double _sliceSize;

  _NineSpriteWidgetPainter(
      {required this.sprite,
      required this.transformer,
      required this.border,
      super.config})
      : _sliceSize = sprite.src.width / 3,
        _corners = Float32List(16),
        _horiSides = Float32List(8),
        _vertSides = Float32List(8),
        _center = Float32List(4) {
    final double sliceSize1X = _sliceSize + sprite.src.topLeft.dx;
    final double sliceSize1Y = _sliceSize + sprite.src.topLeft.dy;
    final double sliceSize2X = sliceSize1X + _sliceSize;
    final double sliceSize2Y = sliceSize1Y + _sliceSize;
    // top left
    _corners[0] = sprite.src.topLeft.dx;
    _corners[1] = sprite.src.topLeft.dy;
    _corners[2] = sliceSize1X;
    _corners[3] = sliceSize1Y;
    // top right
    _corners[4] = sliceSize2X;
    _corners[5] = sprite.src.topLeft.dy;
    _corners[6] = sprite.src.topRight.dx;
    _corners[7] = sliceSize1Y;
    // bottom left
    _corners[8] = sprite.src.topLeft.dx;
    _corners[9] = sliceSize2Y;
    _corners[10] = sliceSize1X;
    _corners[11] = sprite.src.bottomRight.dy;
    // bottom right
    _corners[12] = sliceSize2X;
    _corners[13] = sliceSize2Y;
    _corners[14] = sprite.src.bottomRight.dx;
    _corners[15] = sprite.src.bottomRight.dy;
    // top center
    _horiSides[0] = sliceSize1X;
    _horiSides[1] = sprite.src.topLeft.dy;
    _horiSides[2] = sliceSize2X;
    _horiSides[3] = sliceSize1X;
    // bottom center
    _horiSides[4] = sliceSize1X;
    _horiSides[5] = sliceSize2Y;
    _horiSides[6] = sliceSize2X;
    _horiSides[7] = sprite.src.bottomCenter.dy;
    // center left
    _vertSides[0] = sprite.src.topLeft.dx;
    _vertSides[1] = sliceSize1Y;
    _vertSides[2] = sliceSize1X;
    _vertSides[3] = sliceSize2Y;
    // center right
    _vertSides[4] = sliceSize2X;
    _vertSides[5] = sliceSize1Y;
    _vertSides[6] = sprite.src.centerRight.dx;
    _vertSides[7] = sliceSize2Y;
    // center piece
    _center[0] = sliceSize1X;
    _center[1] = sliceSize1Y;
    _center[2] = sliceSize2X;
    _center[3] = sliceSize2Y;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = applyConfig(G.fasterPainter);
    if (transformer != null) {
      canvas.transform(transformer!
          .resolve(size, Size(sprite.originalWidth, sprite.originalHeight))
          .storage);
    }
    final Rect frame = Offset.zero & size;
    final Float32List cornersTransforms = Float32List(_corners.length);
    final double cornerWidth = size.width - _sliceSize;
    final double cornerHeight = size.height - _sliceSize;
    // top left
    cornersTransforms[0] = 1;
    cornersTransforms[1] = 0;
    cornersTransforms[2] = 0;
    cornersTransforms[3] = 0;
    // top right
    cornersTransforms[4] = 1;
    cornersTransforms[5] = 0;
    cornersTransforms[6] = cornerWidth;
    cornersTransforms[7] = 0;
    // bottom left
    cornersTransforms[8] = 1;
    cornersTransforms[9] = 0;
    cornersTransforms[10] = 0;
    cornersTransforms[11] = cornerHeight;
    // bottom right
    cornersTransforms[12] = 1;
    cornersTransforms[13] = 0;
    cornersTransforms[14] = cornerWidth;
    cornersTransforms[15] = cornerHeight;
    canvas.drawRawAtlas(sprite.image, cornersTransforms, _corners, null, null, frame, p);
    canvas.save();
    final double horiSideScale =
        geom.mag(size.width - 2 * _sliceSize, _sliceSize) / geom.mag(_sliceSize, 0);
    final double horiSideX = _sliceSize / horiSideScale;
    canvas.scale(horiSideScale, 1);
    final Float32List transformsHoriSides = Float32List(8);
    // top center
    transformsHoriSides[0] = 1;
    transformsHoriSides[1] = 0;
    transformsHoriSides[2] = horiSideX;
    transformsHoriSides[3] = 0;
    // bottom center
    transformsHoriSides[4] = 1;
    transformsHoriSides[5] = 0;
    transformsHoriSides[6] = horiSideX;
    transformsHoriSides[7] = size.height - _sliceSize;
    canvas.drawRawAtlas(
        sprite.image, transformsHoriSides, _horiSides, null, null, frame, p);
    canvas.restore();
    canvas.save();
    final double vertSideScale =
        geom.mag(_sliceSize, size.height - 2 * _sliceSize) / geom.mag(0, _sliceSize);
    final double vertSideY = _sliceSize / vertSideScale;
    canvas.scale(1, vertSideScale);
    final Float32List transformVertiSides = Float32List(8);
    // center left
    transformVertiSides[0] = 1;
    transformVertiSides[1] = 0;
    transformVertiSides[2] = 0;
    transformVertiSides[3] = vertSideY;
    // center right
    transformVertiSides[4] = 1;
    transformVertiSides[5] = 0;
    transformVertiSides[6] = size.width - _sliceSize;
    transformVertiSides[7] = vertSideY;
    canvas.drawRawAtlas(
        sprite.image, transformVertiSides, _vertSides, null, null, frame, p);
    canvas.restore();
    canvas.scale(horiSideScale, vertSideScale);
    final Float32List transformCenter = Float32List(4);
    // center
    transformCenter[0] = 1;
    transformCenter[1] = 0;
    transformCenter[2] = horiSideX;
    transformCenter[3] = vertSideY;
    canvas.drawRawAtlas(sprite.image, transformCenter, _center, null, null, frame, p);
  }

  @override
  bool shouldRepaint(covariant ContentRenderer oldDelegate) {
    if (oldDelegate is! _NineSpriteWidgetPainter) {
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
  final SpriteTextureKey sprite;
  final Widget child;
  final EdgeInsets border;
  final EdgeInsets? padding;
  final LinearTransformer? transformer;
  final PaintConfig? config;

  const NineSpriteWidget(
      {super.key,
      required this.sprite,
      required this.child,
      required this.border,
      this.padding,
      this.transformer,
      this.config});

  @override
  Widget build(BuildContext context) {
    logger.config("Sprite Key -> ${sprite.spriteName}");
    return SizedBox(
      child: CustomPaint(
        painter: _NineSpriteWidgetPainter(
            sprite: sprite.findTexture(),
            transformer: transformer,
            border: border,
            config: config),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
