import "package:flutter/material.dart";
import "package:project_yellow_cake/engine/engine.dart";
import "package:project_yellow_cake/game/entities/entities.dart";
import "package:project_yellow_cake/game/game.dart";

import "dart:ui" as ui;

void main() async {
  Public.textureFilter = PublicK.TEXTURE_FILTER_NONE;
  await GameRoot.I.loadBuiltinItems();
  runApp(AppRoot());
}

class CullingReactorGridPainter extends CustomPainter {
  final CellLocation? hitLocation;

  CullingReactorGridPainter({super.repaint, required this.hitLocation});

  @override
  void paint(Canvas canvas, Size size) {
    Shared.logger.fine("Hit$hashCode: < ${hitLocation?.$1} , ${hitLocation?.$2} >");
    Paint paint = G.fasterPainter;
    List<RSTransform> transforms = <RSTransform>[];
    List<Rect> src = <Rect>[];
    ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
    for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
      for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
        double x = j * (Shared.kTileSize + Shared.kTileSpacing);
        double y = i * (Shared.kTileSize + Shared.kTileSpacing);
        AtlasSprite sprite =
            GameRoot.I.reactor.at(i, j).findItemDefinition().sprite().findTexture();
        transforms.add(RSTransform.fromComponents(
            rotation: 0,
            scale: Shared.tileInitialZoom,
            anchorX: 0,
            anchorY: 0,
            translateX: x,
            translateY: y));
        // src.add(Rect.fromLTWH(
        //     sprite.offsetX, sprite.offsetY, sprite.packedWidth, sprite.packedHeight));
        src.add(sprite.src);
      }
    }
    canvas.drawAtlas(atlas, transforms, src, null, null,
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // if (pressedLocation != null) {
    //   Paint redPaint = Paint()..color = Colors.red;
    //   canvas.drawRect(
    //       Rect.fromCenter(
    //           center: pressedLocation!,
    //           width: Shared.kTileSize,
    //           height: Shared.kTileSize),
    //       redPaint);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      debugShowWidgetInspector: false,
      showPerformanceOverlay: true,
      color: Colors.black,
      builder: (BuildContext context, _) =>
          LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: <Widget>[
            Container(width: 260, height: double.infinity, color: Colors.transparent),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(height: 200, color: Colors.transparent),
                  Expanded(
                      child: _ReactorWidget(
                    constraints: constraints,
                  )),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ReactorWidget extends StatefulWidget {
  final BoxConstraints constraints;

  const _ReactorWidget({required this.constraints});

  @override
  State<_ReactorWidget> createState() => _ReactorWidgetState();
}

class _ReactorWidgetState extends State<_ReactorWidget> {
  Offset? pressedLocation;
  CellLocation? hitLocation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        setState(() {
          pressedLocation = details.localPosition;
          hitLocation = (
            pressedLocation!.dy ~/ (Shared.kTileSize + Shared.kTileSpacing),
            pressedLocation!.dx ~/ (Shared.kTileSize + Shared.kTileSpacing)
          );
          GameRoot.I.reactor[hitLocation!] =
              GameRoot.I.reactor[hitLocation!] == 0 ? 1 : 0;
        });
      },
      child: CustomPaint(painter: CullingReactorGridPainter(hitLocation: hitLocation)),
    );
  }
}
