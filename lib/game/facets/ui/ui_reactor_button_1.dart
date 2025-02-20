import 'package:shitter/engine/engine.dart';

@Deprecated("Please don't use thsi shit")
class UIButton1 extends StatefulWidget {
  final AtlasSprite child;
  final SpriteSet<ButtonSpriteStates>? spriteSet;
  final void Function() onPressed;

  const UIButton1(
      {super.key, this.spriteSet, required this.child, required this.onPressed});

  @override
  State<UIButton1> createState() => _ReactorButtonState();
}

@Deprecated("Please dont use this shit")
class _ReactorButtonState extends State<UIButton1> {
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
            transform: Matrix4.identity().toLinearTransformer
          ),
          ButtonSpriteStates.pressed: (
            sprite: const SpriteTextureKey("ui_content",
                spriteName: "Reactor_Button_1_Pressed"),
            transform: Matrix4.translation(Vector3(0, 1, 0)).toLinearTransformer
          ),
        });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => pressed = ButtonSpriteStates.pressed),
        onTapUp: (_) => setState(() => pressed = ButtonSpriteStates.normal),
        child: SpriteWidget(
          <AtlasSprite>[
            spriteSet.resolveTextureKey(<ButtonSpriteStates>{pressed}).findTexture(),
            widget
                .child // ! this might come back to bite me in the ass cuz it redraws both things which is fucking ass
          ],
          transformers: <LinearTransformer>[
            LinearTransformer.identity(),
            spriteSet.resolveTransformation(<ButtonSpriteStates>{pressed}),
          ],
        ));
}
