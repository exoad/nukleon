import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:provider/provider.dart';

class Scene2DController extends SceneNavigator<Widget> with ChangeNotifier {
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
  set sequence(SceneSequence seq) {
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
              ? SizedBox(child: controller.peekNode)
              : Stack(alignment: Alignment.center, children: <Widget>[
                  Positioned.fill(child: controller.peekNode),
                  widget.atopChild!,
                ]);
        });
  }
}
