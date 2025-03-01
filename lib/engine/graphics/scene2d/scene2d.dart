import 'package:equatable/equatable.dart';
import 'package:provider/provider.dart';
import 'package:shitter/engine/engine.dart';
import 'package:shitter/engine/graphics/scene2d/stage.dart';

export "stage.dart";

@immutable
class Scene2DController with EquatableMixin {
  final Stage<Widget> _stage;

  const Scene2DController(this._stage);

  Widget get current => _stage.peek;

  void push(Widget value) {
    _stage.push(value);
    logger.finest("SCENE2D_Controller: PUSH $value");
  }

  void down(int index) {
    _stage.down(index);
    logger.finest("SCENE2D_Controller: SIGNAL_DOWN $index");
  }

  void up() {
    _stage.up();
    logger.finest("SCENE2D_Controller: SIGNAL_UP");
  }

  void jumpTo(int id) {
    _stage.jumpTo(id);
    logger.finest("SCENE2D_Controller: JUMP_TO $id");
  }

  void shiftTo(int shift) {
    _stage.shiftTo(shift);
    logger.finest("SCENE2D_Controller: SHIFT_TO $shift");
  }

  @override
  List<Object?> get props => <Object?>[_stage];
}

class Scene2DWidget extends StatelessWidget {
  final StageActor<Widget> root;
  final Widget Function(BuildContext context, Scene2DController controller) builder;

  const Scene2DWidget({
    super.key,
    required this.root,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Stage<Widget>>(
      create: (BuildContext context) => Stage<Widget>.defined(root),
      child: Consumer<Stage<Widget>>(
        builder: (BuildContext context, Stage<Widget> stage, Widget? child) =>
            builder(context, Scene2DController(stage)),
      ),
    );
  }
}
