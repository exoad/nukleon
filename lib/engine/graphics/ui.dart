import 'package:flutter/widgets.dart';
import 'package:project_yellow_cake/engine/engine.dart';

class UIButton extends StatelessWidget {
  final Widget child;
  final void Function() onPressed;

  const UIButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
            decoration: BoxDecoration(color: Color.fromARGB(255, 118, 128, 155)),
            child: child));
  }
}

final class _SpriteWidgetPainter extends CustomPainter {
  AtlasSprite sprite;

  _SpriteWidgetPainter(this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    // ! might need to optimize this more
    // ! preferring drawImageRect is bad
    // ! we should instead prefer to use drawAtlas but we cant really do that if that is at all even
    // ! even more performant for just drawing a single image
    AtlasSprite buttonSprite = TextureRegistry.getTextureSprite(
        SpriteTextureKey("content", spriteName: "Reactor_Button"));
    canvas.drawImageRect(
        buttonSprite.image,
        buttonSprite.src,
        Rect.fromLTWH(0, 0, size.width, size.height),
        buttonSprite.paint
          ..filterQuality = FilterQuality.none
          ..isAntiAlias = false);
    canvas.drawImageRect(
        sprite.image,
        sprite.src,
        Rect.fromLTWH(0, 0, size.width, size.height),
        sprite.paint
          ..filterQuality = FilterQuality.none
          ..isAntiAlias = false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SpriteWidget extends StatelessWidget {
  final AtlasSprite sprite;

  const SpriteWidget(this.sprite, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SpriteWidgetPainter(sprite));
  }
}
