import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:project_yellow_cake/engine/engine.dart";
import "package:project_yellow_cake/game/design/ui/ui_reactor_button_toggle_1.dart";
import "package:project_yellow_cake/game/controllers/pointer.dart";
import "package:project_yellow_cake/game/design/design_ui.dart";
import "package:project_yellow_cake/game/entities/entities.dart";
import "package:project_yellow_cake/game/game.dart";
import "package:project_yellow_cake/game/utils/surveyor.dart";

import "dart:ui" as ui;

import "package:provider/provider.dart";
import "package:provider/single_child_widget.dart";

void main() async {
  Public.textureFilter = PublicK.TEXTURE_FILTER_NONE;
  await GameRoot.I.loadBuiltinItems();
  if (PointerBuffer.kIsHandicapped) {
    Shared.logger.warning("Running in handicapped mode!");
  }
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
      ui.Image atlas = TextureRegistry.getTexture("tiles_content")!.atlasImage;
      for (int i = 0; i < GameRoot.I.reactor.rows; i++) {
        for (int j = 0; j < GameRoot.I.reactor.columns; j++) {
          double x = j * (Shared.kTileSize + Shared.kTileSpacing);
          double y = i * (Shared.kTileSize + Shared.kTileSpacing);
          ItemDefinition definition = GameRoot.I.reactor
              .at(i, j)
              .at(Class.TILES)
              .id
              .findItemDefinition(Class.TILES);
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
        int id = GameRoot.I.reactor.at(i, j).at(Class.ITEMS).id;
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
    final Size size = MediaQuery.sizeOf(context);
    return MaterialApp(
        theme: ThemeData(
            tooltipTheme: TooltipThemeData(
                exitDuration: Duration.zero,
                decoration: const BoxDecoration(borderRadius: BorderRadius.zero))),
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        color: Colors.black,
        home: DefaultTextStyle(
          style:
              const TextStyle(fontFamily: "PixelPlay", color: Colors.white, fontSize: 16),
          child: MultiProvider(
            providers: <SingleChildWidget>[
              ChangeNotifierProvider<PointerBuffer>(
                  create: (BuildContext context) => GameRoot.I.pointerBuffer),
              ChangeNotifierProvider<CellLocationBuffer>(
                  create: (BuildContext context) => GameRoot.I.cellLocationBuffer)
            ],
            builder: (BuildContext context, Widget? widget) => Padding(
              padding: const EdgeInsets.all(Shared.uiPadding),
              child: ColoredBox(
                color: Colors.black,
                child: Row(
                  children: <Widget>[
                    Column(children: <Widget>[
                      Container(
                          height: size.height * 0.4 - (Shared.uiPadding * 2),
                          width: 260,
                          color: Color.fromARGB(255, 56, 61, 74),
                          child: PointerBuffer.kIsHandicapped
                              ? UIToggleButton1(
                                  toggled: true,
                                  onSwitch: (bool active) {
                                    if (active) {
                                      PointerBuffer.of(context, listen: false).use();
                                    } else {
                                      PointerBuffer.of(context, listen: false).erase();
                                    }
                                  })
                              : null),
                      const SizedBox(height: Shared.uiPadding),
                      Container(
                        height: size.height * 0.6 - (Shared.uiPadding * 2),
                        width: 260,
                        color: Color.fromARGB(255, 56, 61, 74),
                        child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.all(Shared.uiGridParentPadding),
                            itemCount: ItemsRegistry.I.registeredItems(Class.ITEMS) - 1,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: Shared.kTileSize,
                                crossAxisSpacing: Shared.uiGridChildPadding,
                                mainAxisSpacing: Shared.uiGridChildPadding),
                            itemBuilder: (BuildContext context, int index) {
                              int trueIndex = index + 1;
                              ItemDefinition item = ItemsRegistry.I
                                  .findItemDefinition(trueIndex, Class.ITEMS);
                              return UIButton1(
                                  child: item.sprite().findTexture(),
                                  onPressed: () {
                                    PointerBuffer.of(context, listen: false).primary =
                                        trueIndex;
                                    logger.info(
                                        "Changed PointerBuffer Primary -> $trueIndex");
                                  });
                            }),
                      ),
                    ]),
                    const SizedBox(width: Shared.uiPadding),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "Row ${CellLocationBuffer.of(context).row}, Col ${CellLocationBuffer.of(context).column}",
                                  ),
                                  SizedBox.square(
                                      dimension: Shared.kTileSize + Shared.kTileSpacing,
                                      child: SpriteWidget(<AtlasSprite>[
                                        ItemsRegistry.I
                                            .findItemDefinition(
                                                PointerBuffer.of(context).primary,
                                                Class.ITEMS)
                                            .sprite()
                                            .findTexture()
                                      ], transformations: <Matrix4>[
                                        Matrix4.identity()
                                      ])),
                                ],
                              )),
                          Positioned(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Container(
                                  height: 200,
                                  color: Colors.transparent,
                                  child: Image.asset(
                                    "assets/shitass.jpeg",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 8, left: 8),
                                  child: _ReactorWidget(),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class _ReactorWidget extends StatefulWidget {
  @override
  State<_ReactorWidget> createState() => _ReactorWidgetState();
}

class _ReactorWidgetState extends State<_ReactorWidget> {
  Offset? pressedLocation;
  CellLocation? hitLocation;
  CellLocation? lastHitLocation;

  @override
  Widget build(BuildContext context) {
    // ! still need to support drag and pressed buttons
    // ! clicking individually on a massive grid is a pain
    return MouseRegion(
      onHover: (PointerHoverEvent details) {
        ({int row, int column}) item = GeomSurveyor.fromPos(
            details.localPosition, Shared.kTileSize, Shared.kTileSpacing);
        CellLocationBuffer.of(context, listen: false).setLocation(item.row, item.column);
      },
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) => _handleHit(details.localPosition),
        onSecondaryTapDown: (TapDownDetails details) {
          if (!PointerBuffer.kIsHandicapped) {
            PointerBuffer.of(context, listen: false).erase();
          }
          _handleHit(details.localPosition);
        },
        onTapDown: (TapDownDetails details) {
          if (!PointerBuffer.kIsHandicapped) {
            PointerBuffer.of(context, listen: false).use();
          }
          _handleHit(details.localPosition);
        },
        child: CustomPaint(painter: CullingReactorGridPainter(hitLocation: hitLocation)),
      ),
    );
  }

  void _handleHit(Offset position) {
    pressedLocation = position;
    lastHitLocation = hitLocation;
    hitLocation =
        GeomSurveyor.posToCellLocation(position, Shared.kTileSize, Shared.kTileSpacing);
    if (GameRoot.I.reactor.safePutCell(
        hitLocation!, CellValue(PointerBuffer.of(context, listen: false).resolve()))) {
      setState(() {});
    }
    Shared.logger.finest(
        "LAST_HIT = $lastHitLocation | NEW_HIT = $hitLocation | DUPLICATE = ${lastHitLocation == hitLocation}");
  }
}
