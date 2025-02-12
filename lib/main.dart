import "package:flutter/material.dart";
import "package:project_yellow_cake/engine/engine.dart";
import "package:project_yellow_cake/game/entities/entities.dart";
import "package:project_yellow_cake/game/game.dart";

import "dart:ui" as ui;

void main() async {
  Public.textureFilter = PublicK.TEXTURE_FILTER_NONE;
  await GameRoot.I.loadBuiltinItems();
  Shared.logger
      .config("LAYERS: ${ItemsRegistry.I.layers[Layers.OVERLAY.index].values.join(",")}");
  Shared.logger.config("LAYERS_3_0: ${ItemsRegistry.I.layers[Layers.OVERLAY.index][0]}");
  runApp(AppRoot());
}

class CullingReactorGridPainter extends CustomPainter {
  final CellLocation? hitLocation;

  CullingReactorGridPainter({super.repaint, required this.hitLocation});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = G.fasterPainter;
    for (Layers layer in Layers.zeroDrawable) {
      List<RSTransform> transforms = <RSTransform>[];
      List<Rect> src = <Rect>[];
      ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
      for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
        for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
          double x = j * (Shared.kTileSize + Shared.kTileSpacing);
          double y = i * (Shared.kTileSize + Shared.kTileSpacing);
          ItemDefinition definition =
              GameRoot.I.reactor.at(i, j).at(layer).findItemDefinition(layer);
          AtlasSprite sprite = definition.sprite().findTexture();
          transforms.add(RSTransform.fromComponents(
              rotation: 0,
              scale: Shared.tileInitialZoom,
              anchorX: 0,
              anchorY: 0,
              translateX: x,
              translateY: y));
          src.add(sprite.src);
        }
      }
      canvas.drawAtlas(atlas, transforms, src, null, null,
          Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
    for (Layers layer in Layers.zeroNonDrawable) {
      List<RSTransform> transforms = <RSTransform>[];
      List<Rect> src = <Rect>[];
      ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
      for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
        for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
          double x = j * (Shared.kTileSize + Shared.kTileSpacing);
          double y = i * (Shared.kTileSize + Shared.kTileSpacing);
          ItemDefinition definition =
              GameRoot.I.reactor.at(i, j).at(layer).findItemDefinition(layer);
          AtlasSprite sprite = definition.sprite().findTexture();
          transforms.add(RSTransform.fromComponents(
              rotation: 0,
              scale: Shared.tileInitialZoom,
              anchorX: 0,
              anchorY: 0,
              translateX: x,
              translateY: y));
          src.add(sprite.src);
        }
      }
      canvas.drawAtlas(atlas, transforms, src, null, null,
          Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
    // ! HEAT DEMO
    // canvas.drawRect(
    //     Rect.fromLTWH(0, 0, size.width, size.height),
    //     paint
    //       ..color = Colors.red
    //       ..blendMode = BlendMode.overlay);

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
      onSecondaryTapDown: (TapDownDetails details) => _handleHit(false, details),
      onTapDown: (TapDownDetails details) => _handleHit(true, details),
      child: CustomPaint(painter: CullingReactorGridPainter(hitLocation: hitLocation)),
    );
  }

  void _handleHit(bool primary, TapDownDetails details) {
    setState(() {
      pressedLocation = details.localPosition;
      hitLocation = CellLocation(
          pressedLocation!.dy ~/ (Shared.kTileSize + Shared.kTileSpacing),
          pressedLocation!.dx ~/ (Shared.kTileSize + Shared.kTileSpacing),
          Layers.ITEMS);
      GameRoot.I.reactor[hitLocation!] =
          primary || GameRoot.I.pointerBuffer.secondary == null
              ? GameRoot.I.pointerBuffer.primary
              : GameRoot.I.pointerBuffer.secondary!;
    });
  }
}
