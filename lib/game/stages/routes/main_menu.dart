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
            const Positioned.fill(
                child: ColoredBox(color: Color.fromARGB(255, 26, 25, 20))),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(52),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      const SizedBox(height: 34),
                      ButtonFacetWidget.widget(
                          facet: Facet.M.get<ButtonFacetConcept1>(),
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                            child: Text(
                              "New Game",
                              style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                            ),
                          )),
                      const SizedBox(height: 14),
                      ButtonFacetWidget.widget(
                          facet: Button1(),
                          onPressed: () {},
                          child: const Text(
                            "Settings",
                            style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                          )),
                      const SizedBox(height: 14),
                      ButtonFacetWidget.widget(
                          facet: Button1(),
                          onPressed: () {},
                          child: const Text(
                            "Information",
                            style: TextStyle(fontSize: 22, fontFamily: "PixelPlay"),
                          )),
                    ]),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
