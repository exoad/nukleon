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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: GestureDetector(
                  onTap: widget.onPressed,
                  onTapDown: (_) => setState(() => pressed = ButtonSpriteStates.pressed),
                  onTapUp: (_) => setState(() => pressed = ButtonSpriteStates.normal),
                  child: NineSpriteWidget(
                    sprite: widget.facet.spriteSet
                        .resolveTextureKey(<ButtonSpriteStates>{pressed}),
                    border: widget.facet.border,
                    child: widget.child,
                  )),
            ));
  }
}
