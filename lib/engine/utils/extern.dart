import 'package:flame/components.dart';
import 'package:project_yellow_cake/engine/engine.dart';

extension DebuggableSprite on Sprite {
  String get richString {
    return "Sprite$hashCode[Src=${src.left.toStringAsFixed(1)}, ${src.top.toStringAsFixed(1)}, ${src.right.toStringAsFixed(1)}, ${src.bottom.toStringAsFixed(1)}]";
  }
}

extension DebuggableTextureAtlasSprite on AtlasSprite {
  String get richString {
    return "Sprite '$name' $index [Offset=($offsetX, $offsetY), Size=($originalWidth,$originalHeight),${packedWidth != originalWidth || packedHeight != originalHeight ? 'PSize=($packedWidth,$packedHeight),' : ""} Src=$src"
        "]";
  }
}

class DataModel {
  const DataModel();
}
