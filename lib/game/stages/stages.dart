import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:provider/provider.dart';

final class Stage2D extends Scene2D with ChangeNotifier {
  static final Stage2D _instance = Stage2D._();

  Stage2D._();

  factory Stage2D() {
    return _instance;
  }

  @override
  int get max {
    throw UnsupportedError("Stage2D does not allow for ordered nodes.");
  }

  @override
  int get min {
    throw UnsupportedError("Stage2D does not allow for ordered nodes");
  }

  @override
  String toString() {
    return super.toString().replaceFirst("DirectedGraph", "Stage2D");
  }

  Widget get currentNode {
    throw UnimplementedError();
  }
}

final class GameStage extends StatefulWidget {
  const GameStage({super.key});

  @override
  State<GameStage> createState() => _GameStageState();
}

class _GameStageState extends State<GameStage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Stage2D>.value(
      value: Stage2D(),
      builder: (BuildContext context, Widget? child) => Stage2D().currentNode,
    );
  }
}
