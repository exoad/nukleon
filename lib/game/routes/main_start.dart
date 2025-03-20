import 'package:flutter_animate/flutter_animate.dart';
import 'package:nukleon/engine/components/stage2d/stages.dart';
import 'package:nukleon/engine/utils/geom.dart';
import 'package:nukleon/game/classes/classes.dart';
import 'package:nukleon/game/routes/reactor.dart';
import 'package:nukleon/nukleon.dart';
import "package:nukleon/engine/components/stage2d/scene_elements.dart" as scenes;

List<StageScene> $mainStartStage() => <StageScene>[
      const _MainMenu(),
      const _Greeting1()
          .animate()
          .fadeIn(
              begin: 0,
              curve: Curves.linear,
              duration: const Duration(milliseconds: 500),
              delay: const Duration(milliseconds: 260))
          .toStageScene(),
      const _Greeting2(),
      const _Greetings3(),
      const _Greetings4(),
      const _Greetings5(),
      const ReactorRoute()
    ];

@immutable
class _Greeting1 extends StageScene {
  const _Greeting1();

  @override
  Widget build(BuildContext context) {
    return scenes.ClickToContinue(
        subScene: const scenes.Textual(children: <InlineSpan>[
          TextSpan(
              text: "Summer, June 1, 1987",
              style: TextStyle(fontSize: 32, fontFamily: ffBold)),
        ]),
        buttonText: "Next",
        onPressed: () => Stage2D.I.goto(2));
  }
}

@immutable
class _Greeting2 extends StageScene {
  const _Greeting2();

  @override
  Widget build(BuildContext context) {
    return scenes.Paranoid(
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
    );
  }
}

@immutable
class _Greetings3 extends StageScene {
  const _Greetings3();

  @override
  Widget build(BuildContext context) {
    return scenes.ClickToContinue(
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
            bottom: "You have been selected for mandatory duties."));
  }
}

@immutable
class _Greetings4 extends StageScene {
  const _Greetings4();

  @override
  Widget build(BuildContext context) {
    return scenes.ClickToContinue(
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
                "As a citizen of Province-4, you have been appointed\nthe new Nuclear Directorate of Facility-42."));
  }
}

@immutable
class _Greetings5 extends StageScene {
  const _Greetings5();

  @override
  Widget build(BuildContext context) {
    return scenes.ClickToContinue(
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
            )));
  }
}

@immutable
class _MainMenu extends StageScene {
  const _MainMenu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: ColoredBox(
      color: const Color.fromARGB(255, 26, 25, 20),
      child: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                  Color.fromARGB(255, 39, 39, 39), BlendMode.overlay),
              child: RawImage(
                  fit: BoxFit.cover,
                  filterQuality: Public.textureFilter,
                  image: BitmapRegistry.I.findImage("main_menu_stage_background")),
            )),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(52),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text.rich(
                        TextSpan(
                            text: "Nukleon",
                            style: TextStyle(
                                fontFamily: "Nokia Cellphone FC",
                                fontSize: 64,
                                shadows: <BoxShadow>[
                                  BoxShadow(
                                      color: Color.fromARGB(255, 51, 48, 37),
                                      blurStyle: BlurStyle.solid,
                                      offset: Offset(0, 6))
                                ],
                                color: Color.fromARGB(255, 217, 208, 176)),
                            children: <InlineSpan>[
                              TextSpan(
                                  text:
                                      "\nBuild ${Shared.version}\nEngine: ${Public.version}",
                                  style: TextStyle(
                                      shadows: <BoxShadow>[], // ignore parent paint
                                      fontFamily: "Resource",
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 217, 208, 176)))
                            ]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 34),
                      IntrinsicWidth(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch, // Stretch to match width
                          children: <Widget>[
                            ButtonFacetWidget.widget(
                              facet: Facet.M.get<Button1>(),
                              onPressed: () => Stage2D.I.goto(1),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                child: Text(
                                  "New Game",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ButtonFacetWidget.widget(
                              facet: Facet.M.get<Button1>(),
                              onPressed: () {},
                              child: const Text(
                                "Settings",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ButtonFacetWidget.widget(
                              facet: Facet.M.get<Button1>(),
                              onPressed: () {},
                              child: const Text(
                                "Information",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ],
        ),
      ),
    ))
        .animate(delay: const Duration(milliseconds: 330), autoPlay: true)
        .blur(
            delay: const Duration(milliseconds: 120),
            duration: const Duration(milliseconds: 330),
            begin: const Offset(8, 8),
            end: const Offset(0, 0))
        .scale(
            duration: const Duration(milliseconds: 620),
            begin: const Offset(1, 0.0000000000008),
            curve: Curves.easeOutCubic,
            end: const Offset(1, 1))
        .saturate(
            delay: const Duration(milliseconds: 230),
            duration: const Duration(milliseconds: 660),
            curve: Curves.easeInOutCubicEmphasized,
            begin: 0.1,
            end: 1);
  }
}
