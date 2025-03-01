import 'package:shitter/engine/engine.dart';

class BackdropStage extends StatelessWidget {
  const BackdropStage({super.key});

  static const double shiftAmount = 120; // Adjust this value as needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            right: shiftAmount,
            child: Image.asset(
              "assets/backdrops/main_menu_1984.png",
              fit: BoxFit.cover,
              filterQuality: FilterQuality.values[Public.textureFilter],
            ),
          ),
        ],
      ),
    );
  }
}
