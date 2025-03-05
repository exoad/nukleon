import 'package:nukleon/engine/components/scene2d/widget.dart';
import 'package:nukleon/engine/debug/debug_buttons.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:provider/provider.dart';

class DebugScene2DControls extends StatelessWidget {
  final bool wrap;

  const DebugScene2DControls({super.key, required this.wrap});

  @override
  Widget build(BuildContext context) {
    return Row(spacing: 4, children: <Widget>[
      DebugButton(
          text: "NEXT",
          onPressed: () =>
              Provider.of<Scene2DController>(context, listen: false).next(wrap)),
      DebugButton(
          text: "BACK",
          onPressed: () =>
              Provider.of<Scene2DController>(context, listen: false).back(wrap))
    ]);
  }
}
