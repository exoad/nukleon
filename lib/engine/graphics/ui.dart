import 'package:flutter/material.dart';
import 'package:shitter/engine/engine.dart';

@immutable
final class _SpriteWidgetPainter extends CustomPainter {
  final List<AtlasSprite> sprites;
  final List<LinearTransformer>? transformations;
  final LinearTransformer? globalTransformer;

  const _SpriteWidgetPainter(this.sprites, this.transformations,
      [this.globalTransformer]);

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
              sprites[i].paint
                ..filterQuality = FilterQuality.none
                ..isAntiAlias = false);
        }
      } else {
        for (int i = 0; i < sprites.length; i++) {
          canvas.drawImageRect(
              sprites[i].image,
              sprites[i].src,
              Rect.fromLTWH(0, 0, size.width, size.height),
              sprites[i].paint
                ..filterQuality = FilterQuality.none
                ..isAntiAlias = false);
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

  const SpriteWidget(this.sprites,
      {super.key, this.transformers, this.globalTransformer});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _SpriteWidgetPainter(sprites, transformers, globalTransformer));
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
