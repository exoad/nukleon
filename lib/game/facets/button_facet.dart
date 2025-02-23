import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

class ButtonFacetWidget extends StatefulWidget {
  final ButtonFacet facet;
  final SpriteTextureKey? child;
  final void Function() onPressed;
  final ButtonSpriteStates? initialState;
  final Widget? widgetChild;
  final bool renderCenter;
  final RenderingHints? renderingHints;

  const ButtonFacetWidget.withSprite(
      {super.key,
      this.initialState,
      required this.facet,
      this.renderCenter = true,
      this.renderingHints,
      required this.onPressed,
      required SpriteTextureKey sprite})
      : widgetChild = null,
        child = sprite;

  const ButtonFacetWidget.withWidget({
    super.key,
    this.renderCenter = true,
    this.initialState,
    required this.facet,
    required this.onPressed,
    this.renderingHints,
    required Widget child,
  })  : child = null,
        widgetChild = child;

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
          renderCenter: widget.renderCenter,
          transformer: widget.facet.spriteSet.resolveTransformation(states),
          border: widget.facet.border,
          config: widget.renderingHints,
          widgetChild: widget.widgetChild,
          sprite: widget.facet.spriteSet.resolveTextureKey(states),
          child: widget.child,
        ));
  }
}
