import "package:shitter/engine/engine.dart";
import "package:shitter/game/classes/classes.dart";
import "package:shitter/game/colors.dart";
import "package:shitter/game/controllers/pointer.dart";
import "package:shitter/game/facets/facets.dart";
import "package:shitter/game/entities/entities.dart";
import "package:shitter/game/game.dart";
import "package:shitter/game/utils/surveyor.dart";

import "dart:ui" as ui;

import "package:provider/provider.dart";
import "package:provider/single_child_widget.dart";

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
                          child: ButtonFacetWidget(
                              facet: Button1(),
                              onPressed: () {
                                Shared.logger.finer("WTF");
                              },
                              child: Text(""))),
                      // child: UIToggleButton1(
                      //     toggled: true,
                      //     onSwitch: (bool active) {
                      //       if (active) {
                      //         PointerBuffer.of(context, listen: false).use();
                      //       } else {
                      //         PointerBuffer.of(context, listen: false).erase();
                      //       }
                      //     })),
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
                                spacing: 6,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text.rich(
                                    TextSpan(children: <InlineSpan>[
                                      TextSpan(
                                          text:
                                              "[${PointerBuffer.of(context).isErasing ? 'ERASE' : 'USE'}]",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Nokia Cellphone FC",
                                              color: PointerBuffer.of(context).isErasing
                                                  ? FadedColors.red
                                                  : FadedColors.green)),
                                      TextSpan(
                                          text:
                                              "  Row ${CellLocationBuffer.of(context).row}, Col ${CellLocationBuffer.of(context).column}",
                                          style:
                                              const TextStyle(color: DefaultColors.gray1))
                                    ]),
                                  ),
                                  SizedBox.square(
                                      dimension: Shared.kTileSize + Shared.kTileSpacing,
                                      child: SpriteWidget(<AtlasSprite>[
                                        TextureRegistry.getTextureSprite(SpriteTextureKey(
                                            "content",
                                            spriteName: "Selector_Border")),
                                        if (PointerBuffer.of(context).primary != null)
                                          ItemsRegistry.I
                                              .findItemDefinition(
                                                  PointerBuffer.of(context).primary!,
                                                  Class.ITEMS)
                                              .sprite()
                                              .findTexture()
                                        else
                                          TextureRegistry.getTextureSprite(
                                              SpriteTextureKey("content",
                                                  spriteName: "Null_Item")),
                                      ], transformers: <LinearTransformer>[])),
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
  late bool panning;

  @override
  void initState() {
    super.initState();
    panning = false;
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (PointerHoverEvent details) {
          ({int row, int column}) item = GeomSurveyor.fromPos(
              details.localPosition, Shared.kTileSize, Shared.kTileSpacing);
          if (GameRoot.I.reactor.isValidLocationRaw(item.row, item.column)) {
            CellLocationBuffer.of(context, listen: false)
                .setLocation(item.row, item.column);
          }
        },
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) => _handleHit(details.localPosition),
          onPanStart: (_) => panning = true,
          onPanCancel: () => panning = false,
          onPanEnd: (_) => panning = false,
          onTapDown: (TapDownDetails details) {
            PointerBuffer.of(context, listen: false).use();
            _handleHit(details.localPosition);
          },
          child: CustomPaint(
            painter: CullingReactorGridPainter(hitLocation: hitLocation),
            isComplex: true,
            willChange: true,
          ),
        ),
      );

  void _handleHit(Offset position) {
    PointerBuffer ptr = PointerBuffer.of(context, listen: false);
    if (ptr.primary != null || ptr.isErasing) {
      CellLocation newHitLocation =
          GeomSurveyor.posToCellLocation(position, Shared.kTileSize, Shared.kTileSpacing);
      if (GameRoot.I.reactor.isValidLocation(newHitLocation) &&
          newHitLocation != lastHitLocation) {
        pressedLocation = position;
        lastHitLocation = hitLocation;
        hitLocation = newHitLocation;
        if (ptr.isErasing || panning || ptr.isUsing) {
          if (GameRoot.I.reactor.safePutCell(hitLocation!, ptr.resolve()!)) {
            setState(() {});
          }
        }
      }
    }
  }
}
