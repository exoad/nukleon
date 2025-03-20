import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/engine/sprite2d/facets/facets.dart';

class StaticFacetWidget<T> extends StatelessFacet<T> {
  StaticFacetWidget(
      {super.key, super.renderingHints, required super.facet, required super.sprite});

  const StaticFacetWidget.widget(
      {super.key, required super.facet, super.renderingHints, required Widget child})
      : super.widget(widget: child);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: NineSliceScaledPainter(
            facetHints: super.facet.facetHints,
            sprite: facet.spriteSet.resolveTextureKey(<T>{}).findTexture(),
            config: renderingHints,
            child: super.sprite),
        child: super.widget);
  }
}
