import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/debug/debug_buttons.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:provider/provider.dart';

class DebugScene2DControls extends StatelessWidget {
  final bool wrap;

  const DebugScene2DControls({super.key, required this.wrap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 4,
            children: <Widget>[
              DebugButton(
                  text: "BACK",
                  onPressed: () =>
                      Provider.of<Scene2DController>(context, listen: false).back(wrap)),
              DebugButton(
                  text: "NEXT",
                  onPressed: () =>
                      Provider.of<Scene2DController>(context, listen: false).next(wrap)),
            ]),
      ),
    );
  }
}
