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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
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
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _SpriteWidgetPainter(sprites, transformers,
            globalTransformer: globalTransformer, config: config));
  }
}

// self implemented cuz the Canvas api doesnt have one lmao and stretching images from an
// atlas needs to be optimized ASF :D
class _NineSpriteWidgetPainter extends ContentRenderer {
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
    double sliceSize2 = _sliceSize * 2;
    double sliceSize3 = _sliceSize * 3;
    // top left
    _corners[0] = 0;
    _corners[1] = 0;
    _corners[2] = _sliceSize;
    _corners[3] = _sliceSize;
    // top right
    _corners[4] = sliceSize2;
    _corners[5] = 0;
    _corners[6] = sliceSize3;
    _corners[7] = _sliceSize;
    // bottom left
    _corners[8] = 0;
    _corners[9] = sliceSize2;
    _corners[10] = _sliceSize;
    _corners[11] = sliceSize3;
    // bottom right
    _corners[12] = sliceSize2;
    _corners[13] = sliceSize2;
    _corners[14] = sliceSize3;
    _corners[15] = sliceSize3;
    // vertical sides
    //  top center
    _horiSides[0] = _sliceSize;
    _horiSides[1] = 0;
    _horiSides[2] = sliceSize2;
    _horiSides[3] = sliceSize2;
    //  bottom center
    _horiSides[4] = _sliceSize;
    _horiSides[5] = sliceSize2;
    _horiSides[6] = sliceSize2;
    _horiSides[7] = sliceSize3;
    // horizontal sides
    //  center left
    _vertSides[0] = 0;
    _vertSides[1] = _sliceSize;
    _vertSides[2] = sliceSize2;
    _vertSides[3] = sliceSize2;
    //  center right
    _vertSides[4] = sliceSize2;
    _vertSides[5] = _sliceSize;
    _vertSides[6] = sliceSize3;
    _vertSides[7] = sliceSize2;
    // center piece
    _center[0] = _sliceSize;
    _center[1] = _sliceSize;
    _center[2] = sliceSize2;
    _center[3] = sliceSize2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = G.fasterPainter;
    if (transformer != null) {
      canvas.transform(transformer!
          .resolve(size, Size(sprite.originalWidth, sprite.originalHeight))
          .storage);
    }
    Rect frame = Rect.fromLTWH(0, 0, size.width, size.height);
    Float32List cornersTransforms = Float32List(_corners.length);
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
    Float32List transformsHoriSides = Float32List(8);
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
    Float32List transformVertiSides = Float32List(8);
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
    Float32List transformCenter = Float32List(4);
    // center
    transformCenter[0] = 1;
    transformCenter[1] = 0;
    transformCenter[2] = horiSideX;
    transformCenter[3] = vertSideY;
    canvas.drawRawAtlas(sprite.image, transformCenter, _center, null, null, frame, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _NineSpriteWidgetPainter) {
      return false;
    } else {
      return oldDelegate._center != _center ||
          oldDelegate._corners != _corners ||
          oldDelegate._horiSides != _horiSides ||
          oldDelegate._vertSides != _vertSides;
    }
  }
}

@immutable
class NineSpriteWidget extends StatelessWidget {
  final AtlasSprite sprite;
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
    return CustomPaint(
      painter: _NineSpriteWidgetPainter(
          sprite: sprite, transformer: transformer, border: border, config: config),
      child: padding == null ? Padding(padding: EdgeInsets.zero, child: child) : child,
    );
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
