import "package:shitter/engine/engine.dart";
import "package:shitter/game/classes/classes.dart";
import "package:shitter/game/classes/ui/item_border_prototype.dart";
import "package:shitter/game/colors.dart";
import "package:shitter/game/controllers/pointer.dart";
import "package:shitter/game/facets/facets.dart";
import "package:shitter/game/entities/entities.dart";
import "package:shitter/game/facets/static_facet.dart";
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
    Float32List transforms =
        Float32List((GameRoot.I.reactor.rows * GameRoot.I.reactor.columns) * 4);
    Float32List src =
        Float32List((GameRoot.I.reactor.rows * GameRoot.I.reactor.columns) * 4);
    {
      ui.Image atlas = TextureRegistry.getTexture("tiles_content")!.atlasImage;
      for (int i = 0, k = 0; i < GameRoot.I.reactor.rows; i++) {
        for (int j = 0; j < GameRoot.I.reactor.columns; j++, k += 4) {
          final AtlasSprite sprite = GameRoot.I.reactor
              .at(i, j)
              .at(Class.TILES)
              .id
              .findItemDefinition(Class.TILES)
              .sprite()
              .findTexture();
          final int k1 = k + 1;
          final int k2 = k + 2;
          final int k3 = k + 3;
          transforms[k] = Shared.tileInitialZoom;
          transforms[k1] = 0;
          transforms[k2] = j * (Shared.kTileSize + Shared.kTileSpacing);
          transforms[k3] = i * (Shared.kTileSize + Shared.kTileSpacing);
          src[k] = sprite.src.left;
          src[k1] = sprite.src.top;
          src[k2] = sprite.src.right;
          src[k3] = sprite.src.bottom;
        }
      }
      canvas.drawRawAtlas(atlas, transforms, src, null, null,
          Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
    src = Float32List((GameRoot.I.reactor.rows * GameRoot.I.reactor.columns) * 4);
    ui.Image atlas = TextureRegistry.getTexture("content")!.atlasImage;
    for (int i = 0, k = 0; i < GameRoot.I.reactor.rows; i++) {
      for (int j = 0; j < GameRoot.I.reactor.columns; j++, k += 4) {
        int id = GameRoot.I.reactor.at(i, j).at(Class.ITEMS).id;
        if (id != 0) {
          final AtlasSprite sprite =
              id.findItemDefinition(Class.ITEMS).sprite().findTexture();
          final int k1 = k + 1;
          final int k2 = k + 2;
          final int k3 = k + 3;
          src[k] = sprite.src.left;
          src[k1] = sprite.src.top;
          src[k2] = sprite.src.right;
          src[k3] = sprite.src.bottom;
        }
      }
    }
    canvas.drawRawAtlas(atlas, transforms, src, null, null, Offset.zero & size, paint);
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
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xfffffaff),
              surfaceTint: Color(0xffe5c524),
              onPrimary: Color(0xff3a3000),
              primaryContainer: Color(0xffffde3f),
              onPrimaryContainer: Color(0xff736100),
              secondary: Color(0xffffdbcc),
              onSecondary: Color(0xff50240b),
              secondaryContainer: Color(0xffffb693),
              onSecondaryContainer: Color(0xff7a452a),
              tertiary: Color(0xffffc480),
              onTertiary: Color(0xff472a00),
              tertiaryContainer: Color(0xffeea446),
              onTertiaryContainer: Color(0xff643c00),
              error: Color(0xffffb4ab),
              onError: Color(0xff690005),
              errorContainer: Color(0xff93000a),
              onErrorContainer: Color(0xffffdad6),
              surface: Color(0xff16130a),
              onSurface: Color(0xffe9e2d1),
              onSurfaceVariant: Color(0xffcfc6ad),
              outline: Color(0xff989079),
              outlineVariant: Color(0xff4c4733),
              shadow: Color(0xff000000),
              scrim: Color(0xff000000),
              inverseSurface: Color(0xffe9e2d1),
              inversePrimary: Color(0xff6e5d00),
              primaryFixed: Color(0xffffe25e),
              onPrimaryFixed: Color(0xff221b00),
              primaryFixedDim: Color(0xffe5c524),
              onPrimaryFixedVariant: Color(0xff534600),
              secondaryFixed: Color(0xffffdbcb),
              onSecondaryFixed: Color(0xff341000),
              secondaryFixedDim: Color(0xffffb693),
              onSecondaryFixedVariant: Color(0xff6c3a1f),
              tertiaryFixed: Color(0xffffddb9),
              onTertiaryFixed: Color(0xff2b1700),
              tertiaryFixedDim: Color(0xffffb964),
              onTertiaryFixedVariant: Color(0xff663e00),
              surfaceDim: Color(0xff16130a),
              surfaceBright: Color(0xff3d392e),
              surfaceContainerLowest: Color(0xff100e06),
              surfaceContainerLow: Color(0xff1e1b11),
              surfaceContainer: Color(0xff222015),
              surfaceContainerHigh: Color(0xff2d2a1f),
              surfaceContainerHighest: Color(0xff383529),
            ),
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
                          child: Column(
                            children: <Widget>[
                              FilledButton.tonal(
                                  child: Text("INSHALLAH"), onPressed: () {}),
                              ButtonFacetWidget.widget(
                                  facet: Button1(),
                                  onPressed: () {},
                                  child: Text("Amogus"))
                            ],
                          )),
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
                        child: StaticFacetWidget<void>.widget(
                          facet: Facet.M.get<BorderPrototype>(),
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
                                return ButtonFacetWidget(
                                    facet: Button1(),
                                    sprite: item.sprite(),
                                    onPressed: () {
                                      PointerBuffer.of(context, listen: false).primary =
                                          trueIndex;
                                      logger.info(
                                          "Changed PointerBuffer Primary -> $trueIndex");
                                    });
                              }),
                        ),
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
        PointerBuffer.of(context, listen: false).use();
        if ((ptr.isErasing || panning || ptr.isUsing) && ptr.resolve() != null) {
          if (GameRoot.I.reactor.safePutCell(hitLocation!, ptr.resolve()!)) {
            setState(() {});
          }
        }
      }
    }
  }
}
