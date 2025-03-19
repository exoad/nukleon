import "package:flutter_animate/flutter_animate.dart";
import "package:nukleon/src/client/client.dart";
import "package:nukleon/src/engine/engine.dart";
import "package:nukleon/src/engine/utils/geom.dart";
import "package:nukleon/src/game/classes/classes.dart";
import "package:nukleon/src/game/classes/ui/item_border_prototype.dart";
import "package:nukleon/src/game/colors.dart";

import "package:nukleon/src/game/controllers/pointer.dart";
import "package:nukleon/src/game/facets/facets.dart";
import "package:nukleon/src/game/entities/entities.dart";
import "package:nukleon/src/game/facets/static_facet.dart";
import "package:nukleon/src/game/game.dart";
import "package:nukleon/src/game/stages/routes/main_menu.dart";
import "package:nukleon/src/game/stages/stages.dart";
import "package:nukleon/src/game/utils/surveyor.dart";

import "package:nukleon/src/game/stages/scenes.dart" as scenes;

import "dart:ui" as ui;

import "package:provider/provider.dart";
import "package:provider/single_child_widget.dart";

int i = 0;
void main() async {
  Public.textureFilter = FilterQuality.none;
  await Engine.initializeEngine();
  await Apollo.initialize();
  await GameRoot.I.loadBuiltinItems();
  await Client.initialize();
  GameRoot.I.soundConfig.volume = 0.7;
  ApolloRegistry.I.load("assets/audio/tones/1.wav");
  ApolloRegistry.I.load("assets/audio/tones/2.wav");
  Engine.bootstrap(const GameStage());
  Stage2D.I.create(0, const MainMenuStage());
  Stage2D.I.create(
      1,
      scenes.ClickToContinue(
          subScene: const scenes.Textual(children: <InlineSpan>[
            TextSpan(
                text: "Summer, June 1, 1987",
                style: TextStyle(fontSize: 32, fontFamily: ffBold)),
          ]),
          buttonText: "Next",
          onPressed: () => Stage2D.I.goto(2)));
  Stage2D.I.create(
      2,
      scenes.Paranoid(
        onEnter: () => HermesAsync.delayed(
            () => Apollo.quickTTS("Good Morning"), const Duration(milliseconds: 300)),
        child: scenes.ClickToContinue(
          buttonText: "Next",
          onPressed: () => Stage2D.I.goto(3),
          subScene: scenes.CinematicImagery(
              top: SpriteWidget(
                const <SpriteTextureKey>[
                  SpriteTextureKey("character", spriteName: "uniform_1"),
                  SpriteTextureKey("character", spriteName: "head_1"),
                ],
                transformers: <LinearTransformer>[
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter),
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter)
                ],
              ).animate(autoPlay: true).shakeY(
                  delay: const Duration(milliseconds: 300),
                  hz: 4.2,
                  duration: const Duration(milliseconds: 750)),
              bottom: "Good Morning Citizen 115."),
        ),
      ));
  Stage2D.I.create(
      3,
      scenes.ClickToContinue(
          buttonText: "Next",
          onPressed: () => Stage2D.I.goto(4),
          subScene: scenes.CinematicImagery(
              top: SpriteWidget(
                const <SpriteTextureKey>[
                  SpriteTextureKey("character", spriteName: "uniform_1"),
                  SpriteTextureKey("character", spriteName: "head_1"),
                ],
                transformers: <LinearTransformer>[
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter),
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter)
                ],
              ).animate(autoPlay: true).shakeY(
                  delay: const Duration(milliseconds: 300),
                  hz: 4.2,
                  duration: const Duration(milliseconds: 750)),
              bottom: "You have been selected for mandatory duties.")));
  Stage2D.I.create(
      4,
      scenes.ClickToContinue(
          buttonText: "Next",
          onPressed: () => Stage2D.I.goto(5),
          subScene: scenes.CinematicImagery(
              top: SpriteWidget(
                const <SpriteTextureKey>[
                  SpriteTextureKey("character", spriteName: "uniform_1"),
                  SpriteTextureKey("character", spriteName: "head_1"),
                ],
                transformers: <LinearTransformer>[
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter),
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter)
                ],
              ).animate(autoPlay: true).shakeY(
                  delay: const Duration(milliseconds: 300),
                  hz: 4.2,
                  duration: const Duration(milliseconds: 1250)),
              bottom:
                  "As a citizen of Province-4, you have been appointed\nthe new Nuclear Directorate of Facility-42.")));
  Stage2D.I.create(
      5,
      scenes.ClickToContinue(
          buttonText: "Next",
          onPressed: () => Stage2D.I.goto(6),
          subScene: scenes.CustomCinematicImagery(
              top: SpriteWidget(
                const <SpriteTextureKey>[
                  SpriteTextureKey("character", spriteName: "uniform_1"),
                  SpriteTextureKey("character", spriteName: "head_1"),
                ],
                transformers: <LinearTransformer>[
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter),
                  LinearTransformer.contextAware(
                      FittingTransform.rectInRectScaledBottomCenter)
                ],
              ).animate(autoPlay: true).shakeY(
                  delay: const Duration(milliseconds: 300),
                  hz: 4.2,
                  duration: const Duration(milliseconds: 750)),
              bottom: Column(
                children: <Widget>[
                  const Text("Temporary habitation has been provided."),
                  const SizedBox(height: 10),
                  const Text(
                    "We expect max adherence and success from you.",
                    style: TextStyle(fontSize: 30, fontFamily: ffBold),
                  )
                      .animate(autoPlay: true)
                      .visibility(delay: const Duration(milliseconds: 1000))
                      .shakeY(
                          delay: const Duration(milliseconds: 1000),
                          hz: 3.2,
                          duration: const Duration(seconds: 3))
                ],
              ))));
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return GameEntry(
      MultiProvider(
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
                      color: const Color.fromARGB(255, 56, 61, 74),
                      child: Column(
                        children: <Widget>[
                          FilledButton.tonal(child: const Text("FFF"), onPressed: () {}),
                          ButtonFacetWidget.widget(
                              facet: Button1(),
                              onPressed: () {},
                              child: const Text("Amogus"))
                        ],
                      )),
                  const SizedBox(height: Shared.uiPadding),
                  Container(
                    height: size.height * 0.6 - (Shared.uiPadding * 2),
                    width: 260,
                    color: const Color.fromARGB(255, 56, 61, 74),
                    child: StaticFacetWidget<void>.widget(
                      facet: Facet.M.get<BorderPrototype>(),
                      child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.all(Shared.uiGridParentPadding),
                          itemCount: ItemsRegistry.I.registeredItems(Class.ITEMS) - 1,
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                                      style: const TextStyle(color: DefaultColors.gray1))
                                ]),
                              ),
                              SizedBox.square(
                                  dimension: Shared.kTileSize + Shared.kTileSpacing,
                                  child: SpriteWidget(<SpriteTextureKey>[
                                    const SpriteTextureKey("content",
                                        spriteName: "Selector_Border"),
                                    if (PointerBuffer.of(context).primary != null)
                                      ItemsRegistry.I
                                          .findItemDefinition(
                                              PointerBuffer.of(context).primary!,
                                              Class.ITEMS)
                                          .sprite()
                                    else
                                      const SpriteTextureKey("content",
                                          spriteName: "Null_Item"),
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
    );
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
          onPanUpdate: (DragUpdateDetails details) =>
              _handleHit(details.localPosition, null),
          onPanStart: (_) => panning = true,
          onPanCancel: () => panning = false,
          onPanEnd: (_) => panning = false,
          onTapDown: (TapDownDetails details) {
            _handleHit(details.localPosition, true);
          },
          onSecondaryTapDown: (TapDownDetails details) {
            _handleHit(details.localPosition, false);
          },
          child: CustomPaint(
            painter: CullingReactorGridPainter(hitLocation: hitLocation),
            isComplex: true,
            willChange: true,
          ),
        ),
      );

  void _handleHit(Offset position, bool? mode) {
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
