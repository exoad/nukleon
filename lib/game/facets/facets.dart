import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/classes.dart';

export "package:shitter/game/facets/button_facet.dart";

abstract class StatelessFacet<T> extends StatelessWidget {
  final RenderingHints? renderingHints;
  final bool renderCenter;
  final Facet<T> facet;
  final AtlasSprite? sprite;
  final Widget? widget;

  StatelessFacet(
      {super.key,
      this.renderCenter = true,
      this.renderingHints,
      required this.facet,
      required SpriteTextureKey sprite})
      : sprite = sprite.findTexture(),
        widget = null;

  const StatelessFacet.widget(
      {super.key,
      required this.facet,
      this.renderingHints,
      this.renderCenter = true,
      required Widget this.widget})
      : sprite = null;
}

abstract class StatefulFacet<T> extends StatefulWidget {
  final RenderingHints? renderingHints;
  final bool renderCenter;
  final Facet<T> facet;
  final AtlasSprite? sprite;
  final Widget? widget;

  StatefulFacet(
      {super.key,
      this.renderCenter = true,
      this.renderingHints,
      required this.facet,
      required SpriteTextureKey sprite})
      : sprite = sprite.findTexture(),
        widget = null;

  const StatefulFacet.widget(
      {super.key,
      required this.facet,
      this.renderingHints,
      this.renderCenter = true,
      required Widget this.widget})
      : sprite = null;
}
