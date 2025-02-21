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
  late ButtonSpriteStates pressed;

  @override
  void initState() {
    super.initState();
    pressed = widget.initialState ?? ButtonSpriteStates.normal;
  }

  @override
  Widget build(BuildContext context) {
    Set<ButtonSpriteStates> states = <ButtonSpriteStates>{pressed};
    return GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => pressed = ButtonSpriteStates.pressed),
        onTapUp: (_) => setState(() => pressed = ButtonSpriteStates.normal),
        child: NineSpriteWidget(
          border: widget.facet.border,
          sprite: widget.facet.spriteSet.resolveTextureKey(states),
          child: Transform(
              transform: widget.facet.spriteSet
                  .resolveTransformation(states)
                  .resolve(Size.zero, Size.zero),
              child: widget.child),
        ));
  }
}
