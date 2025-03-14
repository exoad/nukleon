import "dart:ui" as ui;
import 'package:nukleon/engine/engine.dart';

final class ImagesUtil {
  ImagesUtil._();

  /// Found with the help from the image package's documentation/tutorial page
  static Future<ui.Image> readAssetPNG(String asset) async {
    final ui.ImageDescriptor id = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(
            (await rootBundle.load(asset)).buffer.asUint8List()));
    return (await (await id.instantiateCodec(
                targetHeight: id.height, targetWidth: id.width))
            .getNextFrame())
        .image;
  }
}
