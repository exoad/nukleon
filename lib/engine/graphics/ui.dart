import 'package:flutter/material.dart';
import 'package:project_yellow_cake/engine/engine.dart';

@immutable
final class _SpriteWidgetPainter extends CustomPainter {
  final List<AtlasSprite> sprites;
  final List<Matrix4> transformations;

  const _SpriteWidgetPainter(this.sprites, this.transformations);

  @override
  void paint(Canvas canvas, Size size) {
    if (sprites.isNotEmpty) {
      // ! might need to optimize this more
      // ! preferring drawImageRect is bad
      // ! we should instead prefer to use drawAtlas but we cant really do that if that is at all even
      // ! even more performant for just drawing a single image
      for (int i = 0; i < sprites.length; i++) {
        canvas.transform(transformations[i].storage);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

@immutable
class SpriteWidget extends StatelessWidget {
  final List<AtlasSprite> sprites;
  final List<Matrix4> transformations;

  const SpriteWidget(this.sprites, {super.key, required this.transformations})
      : assert(sprites.length <= transformations.length,
            "Sprite count must be less than or equal to transformations count (${sprites.length} <= ${transformations.length}). If you don't want a sprite to move, use [Matrix4.identity()].");

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SpriteWidgetPainter(sprites, transformations));
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
