import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/facets/facets.dart';

class ButtonFacetWidget extends StatefulFacet<ButtonSpriteStates> {
  final void Function() onPressed;
  final ButtonSpriteStates? initialState;

  ButtonFacetWidget(
      {super.key,
      super.renderingHints,
      required super.facet,
      required super.sprite,
      this.initialState,
      required this.onPressed});

  const ButtonFacetWidget.widget(
      {super.key,
      required super.facet,
      required this.onPressed,
      this.initialState,
      super.renderingHints,
      required Widget child})
      : super.widget(widget: child);

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
        child: NineSpriteWidget.resolved(
          facetHints: widget.facet.facetHints,
          transformer: widget.facet.spriteSet.resolveTransformation(states),
          border: widget.facet.border,
          config: widget.renderingHints,
          widgetChild: widget.widget,
          sprite: widget.facet.spriteSet.resolveTextureKey(states).findTexture(),
          child: widget.sprite,
        ));
  }
}
