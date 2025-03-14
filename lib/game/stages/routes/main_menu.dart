import 'package:flutter_animate/flutter_animate.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/classes/classes.dart';
import 'package:nukleon/game/facets/button_facet.dart';
import 'package:nukleon/game/game.dart';

class MainMenuStage extends StatelessWidget {
  const MainMenuStage({super.key});

  static const double shiftAmount = 120; // Adjust this value as needed

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
                  image: BitmapRegistry.I.find("main_menu_stage_background")),
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
                              onPressed: () {},
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
