// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/classes/classes.dart';

class RawFacet<T extends ItemDefinition> extends StatelessWidget {
  final Facet<T> facet;
  const RawFacet({
    super.key,
    required this.facet,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: SingleSpritePainter(sprite: facet.sprite().findTexture()));
  }
}
