import 'package:nukleon/engine/components/graphs/graph.dart';
import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/debug/debug_buttons.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/game.dart';
import 'package:provider/provider.dart';

final class Stage2D extends Scene2D with ChangeNotifier, DGraphTraverser<Widget> {
  static final Stage2D I = Stage2D._();

  Stage2D._();

  factory Stage2D() {
    return I;
  }

  @override
  void goto(int ptr, [bool panic = false]) {
    Shared.logger.fine("STAGE2D: Goto $ptr (from $pointer)");
    super.goto(ptr, panic);
    notifyListeners();
  }

  @override
  String toString() {
    return super.toString().replaceFirst("DirectedGraph", "Stage2D");
  }

  Widget get emptyNodePlaceholder {
    return const CustomPaint(
        size: Size.infinite,
        painter: NullPainter(),
        child: Center(
            child: Text(
          "STAGE2D: No Scene!",
          style: TextStyle(fontSize: 22),
        )));
  }

  Widget? tryPeekNode(int i) {
    return dict[i];
  }

  Widget get currentNode {
    return tryPeekNode(pointer) ?? emptyNodePlaceholder;
  }
}

final class GameStage extends StatefulWidget {
  final int? start;
  const GameStage({super.key, this.start});

  @override
  State<GameStage> createState() => _GameStageState();
}

class _GameStageState extends State<GameStage> {
  @override
  void initState() {
    super.initState();
    if (widget.start != null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) => Stage2D.I.goto(widget.start!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Stage2D>.value(
      value: Stage2D.I,
      builder: (BuildContext context, Widget? child) => Public.devMode
          ? Stack(children: <Widget>[
              Positioned.fill(child: Provider.of<Stage2D>(context).currentNode),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: <Widget>[
                        DebugButton(
                            text: "BACK",
                            onPressed: () => Provider.of<Stage2D>(context, listen: false)
                                .goto(Stage2D.I.pointer - 1)),
                        DebugButton(
                            text: "NEXT",
                            onPressed: () => Provider.of<Stage2D>(context, listen: false)
                                .goto(Stage2D.I.pointer + 1)),
                      ]),
                ),
              )
            ])
          : Provider.of<Stage2D>(context).currentNode,
    );
  }
}
