import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/facets/facets.dart';

class StaticFacetWidget<T> extends StatelessFacet<T> {
  StaticFacetWidget(
      {super.key,
      super.renderCenter,
      super.renderingHints,
      required super.facet,
      required super.sprite});

  const StaticFacetWidget.widget(
      {super.key,
      required super.facet,
      super.renderCenter,
      super.renderingHints,
      required Widget child})
      : super.widget(widget: child);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: NineSliceScaledPainter(
            sprite: facet.spriteSet.resolveTextureKey(<T>{}).findTexture(),
            renderCenter: renderCenter,
            config: renderingHints,
            child: super.sprite),
        child: super.widget);
  }
}
