// this more of a tree rather a graph, but a tree is a graph >:)
import 'package:nukleon/engine/components/graphs/graph.dart';
import 'package:nukleon/engine/engine.dart';

import 'package:provider/provider.dart';

typedef Scene2D = DGraph<Widget>;
typedef Scene2DNavgiator = DGraphAggregator<Widget>;

class Scene2DController extends DGraphNavigator<Widget> with ChangeNotifier {
  Scene2DController(super.graph);

  @override
  void next([bool wrap = false]) {
    super.next(wrap);
    notifyListeners();
  }

  @override
  void back([bool wrap = false]) {
    super.back(wrap);
    notifyListeners();
  }

  @override
  set sequence(StaticDGraphSeq seq) {
    super.sequence = seq;
    notifyListeners();
  }
}

class Scene2DWidget extends StatefulWidget {
  final Scene2DController controller;
  final Widget? atopChild;

  const Scene2DWidget({super.key, required this.controller, this.atopChild});

  @override
  State<Scene2DWidget> createState() => _Scene2DWidgetState();
}

class _Scene2DWidgetState extends State<Scene2DWidget> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Scene2DController>.value(
        value: widget.controller,
        builder: (BuildContext context, Widget? child) {
          Scene2DController controller = Provider.of<Scene2DController>(context);
          return widget.atopChild == null
              ? SizedBox(child: controller.currentNode)
              : Stack(alignment: Alignment.center, children: <Widget>[
                  Positioned.fill(child: controller.currentNode),
                  Positioned.fill(child: widget.atopChild!),
                ]);
        });
  }
}
