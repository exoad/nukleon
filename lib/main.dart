import "package:flutter/material.dart";
import "package:project_yellow_cake/engine/engine.dart";
import "package:project_yellow_cake/game/design/design_ui.dart";
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
    Paint paint = G.fasterPainter;
    {
      List<RSTransform> transforms = <RSTransform>[];
      List<Rect> src = <Rect>[];
      ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
      for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
        for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
          double x = j * (Shared.kTileSize + Shared.kTileSpacing);
          double y = i * (Shared.kTileSize + Shared.kTileSpacing);
          ItemDefinition definition =
              GameRoot.I.reactor.at(i, j).at(Class.TILES).findItemDefinition(Class.TILES);
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
    List<RSTransform> transforms = <RSTransform>[];
    List<Rect> src = <Rect>[];
    ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
    for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
      for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
        int id = GameRoot.I.reactor.at(i, j).at(Class.ITEMS);
        if (id != 0) {
          ItemDefinition definition = id.findItemDefinition(Class.ITEMS);
          double x = j * (Shared.kTileSize + Shared.kTileSpacing);
          double y = i * (Shared.kTileSize + Shared.kTileSpacing);
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
    }
    canvas.drawAtlas(atlas, transforms, src, null, null,
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // ! HEAT DEMO
    // canvas.drawRect(
    //     Rect.fromLTWH(0, 0, size.width, size.height),
    //     paint
    //       ..color = Colors.red
    //       ..blendMode = BlendMode.overlay);
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
        return Padding(
          padding: const EdgeInsets.all(Shared.uiPadding),
          child: ColoredBox(
            color: Colors.black,
            child: Row(
              children: <Widget>[
                Column(children: <Widget>[
                  Container(
                      height: MediaQuery.sizeOf(context).height * 0.4 -
                          (Shared.uiPadding * 2),
                      width: 260,
                      color: Color.fromARGB(255, 56, 61, 74)),
                  const SizedBox(height: Shared.uiPadding),
                  Container(
                    height:
                        MediaQuery.sizeOf(context).height * 0.6 - (Shared.uiPadding * 2),
                    width: 260,
                    color: Color.fromARGB(255, 56, 61, 74),
                    child: GridView.builder(
                        padding: const EdgeInsets.all(Shared.uiGridParentPadding),
                        itemCount: ItemsRegistry.I.registeredItems(Class.ITEMS) - 1,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: Shared.kTileSize,
                            crossAxisSpacing: Shared.uiGridChildPadding,
                            mainAxisSpacing: Shared.uiGridChildPadding),
                        itemBuilder: (BuildContext context, int index) {
                          int trueIndex = index + 1;
                          return ReactorButton(
                              child: ItemsRegistry.I
                                  .findItemDefinition(trueIndex, Class.ITEMS)
                                  .sprite()
                                  .findTexture(),
                              onPressed: () {});
                        }),
                  ),
                ]),
                const SizedBox(width: Shared.uiPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 200,
                        color: Colors.transparent,
                        child: Image.asset("assets/shitass.jpeg", fit: BoxFit.fill,),
                      ),
                      Expanded(
                          child: _ReactorWidget(
                        constraints: constraints,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    // ! still need to support drag and pressed buttons
    // ! clicking individually on a massive grid is a pain
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
          Class.ITEMS);
      GameRoot.I.reactor[hitLocation!] =
          primary || GameRoot.I.pointerBuffer.secondary == null
              ? GameRoot.I.pointerBuffer.primary
              : GameRoot.I.pointerBuffer.secondary!;
    });
  }
}
