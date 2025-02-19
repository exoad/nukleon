import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

class ButtonFacetWidget extends StatefulWidget {
  final ButtonFacet facet;
  final Widget child;
  final void Function() onPressed;
  final ButtonSpriteStates? initialState;

  const ButtonFacetWidget(
      {super.key,
      this.initialState,
      required this.facet,
      required this.onPressed,
      required this.child});

  @override
  State<ButtonFacetWidget> createState() => _ButtonFacetWidgetState();
}

class _ButtonFacetWidgetState extends State<ButtonFacetWidget> {
  late ButtonSpriteStates state;

  @override
  void initState() {
    super.initState();
    state = widget.initialState ?? ButtonSpriteStates.normal;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => state = ButtonSpriteStates.pressed),
        onTapUp: (_) => setState(() => state = ButtonSpriteStates.normal),
        child: NineSpriteWidget(
          sprite: widget.facet.spriteSet
              .resolveTextureKey(<ButtonSpriteStates>{state}).findTexture(),
          border: widget.facet.border,
          child: widget.child,
        ));
  }
}

class UIButton1 extends StatefulWidget {
  final AtlasSprite child;
  final SpriteSet<ButtonSpriteStates>? spriteSet;
  final void Function() onPressed;

  const UIButton1(
      {super.key, this.spriteSet, required this.child, required this.onPressed});

  @override
  State<UIButton1> createState() => _ReactorButtonState();
}

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
          transformers: <LinearTransformer>[
            LinearTransformer.identity(),
            spriteSet.resolveTransformation(<ButtonSpriteStates>{pressed}),
          ],
        ));
  }
}
