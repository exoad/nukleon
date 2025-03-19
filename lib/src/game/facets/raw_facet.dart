// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:nukleon/src/engine/engine.dart';
import 'package:nukleon/src/game/classes/classes.dart';

class RawFacet<T extends ItemDefinition> extends StatelessWidget {
  final Facet<T> facet;
  const RawFacet({
    super.key,
    required this.facet,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: SingleSpritePainter(sprite: facet.sprite()));
  }
}
