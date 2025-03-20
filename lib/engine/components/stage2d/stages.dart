import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/components/graphs/graph.dart';
import 'package:nukleon/engine/debug/debug_buttons.dart';
import 'package:nukleon/engine/engine.dart';
import 'package:nukleon/game/game.dart';
import 'package:nukleon/engine/components/stage2d/scene_elements.dart';
import 'package:provider/provider.dart';

extension WidgetTransmutesStageScene on Widget {
  StageScene toStageScene({void Function()? onEnter, void Function()? onExit}) =>
      BakedStageScene(this, enter: onEnter, exit: onExit);
}

class BakedStageScene extends StageScene {
  final Widget item;
  final void Function()? enter;
  final void Function()? exit;
  const BakedStageScene(this.item, {super.key, this.enter, this.exit});

  @override
  void onExit() {
    exit?.call();
  }

  @override
  void onEnter() {
    enter?.call();
  }

  @override
  Widget build(BuildContext context) {
    return item;
  }
}

@immutable
abstract class StageScene extends StatelessWidget {
  const StageScene({super.key});

  void onExit() {}

  void onEnter() {}
}

typedef StageLinks = List<List<StageLink>>;

@immutable
class StageLink with EquatableMixin {
  final int to;
  final bool bidirectional;

  const StageLink(this.to, [this.bidirectional = true]);

  @override
  List<Object?> get props => <Object?>[to, bidirectional];
}

final class Stage2D extends DGraph<StageScene>
    with ChangeNotifier, DGraphTraverser<StageScene> {
  static final Stage2D I = Stage2D._();

  Stage2D._();

  factory Stage2D() {
    return I;
  }

  @override
  @Deprecated("[NOT_DEPRECATED] Prefer using the 'bump()' function!")
  void create(int id, StageScene node) {
    super.create(id, node);
  }

  /// Removes all of the current scenes and pushes all of the ones in [bundle] by their ordering.
  ///
  /// If [links] is null, then this function generates links such that the following pattern:
  /// `1<->2<->3<->4`.
  void bump(List<StageScene> bundle, [StageLinks? links]) {
    links ??= StageLinks.generate(bundle.length, (int i) {
      if (bundle.within(i + 1)) {
        return <StageLink>[StageLink(i + 1)];
      }
      return List<StageLink>.empty();
    }, growable: false);
    if (links.length != bundle.length) {
      panicNow(
          "STAGE2D: The amount of scenes ${bundle.length} does not equal the amount of links defined ${links.length}");
    }
    dict.clear();
    graph.clear();
    logger.fine("Bumping new stage of ${bundle.length} scenes.");
    int i = 0, j = 0;
    for (; i < bundle.length; i++) {
      create(i, bundle[i]);
    }
    for (i = 0; i < bundle.length; i++) {
      for (j = 0; j < links[i].length; j++) {
        link(from: i, to: links[i][j].to, bidirectional: links[i][j].bidirectional);
      }
    }
    logger.finest("Bumped Stage: ${Stage2D.I}");
    logger.fine("STAGE2D: Bumped $i scenes with $j links");
  }

  @override
  void goto(int ptr, [bool panic = false]) {
    Shared.logger.fine("STAGE2D: Goto $ptr (from $pointer)");
    if (currentNode is Paranoid) {
      (currentNode as Paranoid).onExit?.call();
    }
    super.goto(ptr, panic);
    if (currentNode is Paranoid) {
      (currentNode as Paranoid).onEnter?.call();
    }
    notifyListeners();
  }

  @override
  String toString() {
    return super.toString().replaceFirst("DirectedGraph", "Stage2D");
  }

  /// Returned by default if [currentNode] is called on a nonexistent pointer node.
  StageScene get emptyNodePlaceholder {
    return const BakedStageScene(
      CustomPaint(
          size: Size.infinite,
          painter: NullPainter(),
          child: Center(
              child: Text(
            "STAGE2D: No Scene!",
            style: TextStyle(fontSize: 22),
          ))),
    );
  }

  StageScene? tryPeekNode(int i) {
    return dict[i];
  }

  StageScene get currentNode {
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
