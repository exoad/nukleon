import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:project_yellow_cake/engine/engine.dart';

class ReactorButton extends StatefulWidget {
  final AtlasSprite child;
  final SpriteSet<ButtonSpriteStates>? spriteSet;
  final void Function() onPressed;

  const ReactorButton(
      {super.key, this.spriteSet, required this.child, required this.onPressed});

  @override
  State<ReactorButton> createState() => _ReactorButtonState();
}

class _ReactorButtonState extends State<ReactorButton> {
  late SpriteSet<ButtonSpriteStates> spriteSet;
  ButtonSpriteStates pressed = ButtonSpriteStates.normal;

  @override
  void initState() {
    super.initState();
    spriteSet = widget.spriteSet ??
        SpriteSetMapper<ButtonSpriteStates>(<ButtonSpriteStates, SpriteSetProperty>{
          ButtonSpriteStates.normal: (
            sprite: const SpriteTextureKey("ui_content",
                spriteName: "Reactor_Button_1_Normal"),
            transform: Matrix4.identity()
          ),
          ButtonSpriteStates.pressed: (
            sprite: const SpriteTextureKey("ui_content",
                spriteName: "Reactor_Button_1_Pressed"),
            transform: Matrix4.translation(Vector3(0, 1, 0))
          ),
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => pressed = ButtonSpriteStates.pressed),
        onTapUp: (_) => setState(() => pressed = ButtonSpriteStates.normal),
        child: SpriteWidget(
          <AtlasSprite>[
            spriteSet.resolveTextureKey(<ButtonSpriteStates>{pressed}).findTexture(),
            widget
                .child // ! this might come back to bite me in the ass cuz it redraws both things which is fucking ass
          ],
          transformations: <Matrix4>[
            Matrix4.identity(),
            spriteSet.resolveTransformation(<ButtonSpriteStates>{pressed}),
          ],
        ));
  }
}
