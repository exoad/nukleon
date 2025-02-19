import 'package:flutter/material.dart';
import 'package:shitter/engine/engine.dart';

@immutable
final class _SpriteWidgetPainter extends CustomPainter {
  final List<AtlasSprite> sprites;
  final List<LinearTransformer>? transformations;
  final LinearTransformer? globalTransformer;
  final bool antialias;
  final FilterQuality filterQuality;

  const _SpriteWidgetPainter(this.sprites, this.transformations,
      {this.globalTransformer,
      this.antialias = false,
      this.filterQuality = FilterQuality.none});

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
                ..filterQuality = filterQuality
                ..isAntiAlias = antialias);
        }
      } else {
        for (int i = 0; i < sprites.length; i++) {
          canvas.drawImageRect(
              sprites[i].image,
              sprites[i].src,
              Rect.fromLTWH(0, 0, size.width, size.height),
              sprites[i].paint
                ..filterQuality = filterQuality
                ..isAntiAlias = antialias);
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
  final bool antialias;
  final FilterQuality filterQuality;

  const SpriteWidget(this.sprites,
      {super.key,
      this.transformers,
      this.globalTransformer,
      this.antialias = true,
      this.filterQuality = FilterQuality.none});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: _SpriteWidgetPainter(sprites, transformers,
            globalTransformer: globalTransformer,
            antialias: antialias,
            filterQuality: filterQuality));
  }
}

class _NineSpriteWidgetPainter extends CustomPainter {
  final AtlasSprite sprite;
  final LinearTransformer? transformer;
  final bool antialias;
  final EdgeInsets border;
  final FilterQuality filterQuality;

  _NineSpriteWidgetPainter(
      {required this.sprite,
      required this.transformer,
      required this.antialias,
      required this.border,
      required this.filterQuality});

  @override
  void paint(Canvas canvas, Size size) {
    if (transformer != null) {
      canvas.transform(transformer!
          .resolve(size, Size(sprite.originalWidth, sprite.originalHeight))
          .storage);
    }
    canvas.drawImageNine(
        sprite.image,
        Rect.fromLTWH(
            border.left,
            border.top,
            sprite.originalWidth - border.right - border.left,
            sprite.originalHeight - border.bottom - border.top),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..isAntiAlias = antialias
          ..filterQuality = filterQuality);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class NineSpriteWidget extends StatelessWidget {
  final AtlasSprite sprite;
  final Widget child;
  final EdgeInsets border;
  final EdgeInsets? padding;
  final LinearTransformer? transformer;
  final bool antialias;
  final FilterQuality filterQuality;

  const NineSpriteWidget(
      {super.key,
      required this.sprite,
      required this.child,
      required this.border,
      this.padding,
      this.transformer,
      this.antialias = true,
      this.filterQuality = FilterQuality.none});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NineSpriteWidgetPainter(
          sprite: sprite,
          transformer: transformer,
          antialias: antialias,
          border: border,
          filterQuality: filterQuality),
      child: padding == null ? Padding(padding: padding!, child: child) : child,
    );
  }
}

enum ButtonSpriteStates {
  pressed,
  normal;
}
