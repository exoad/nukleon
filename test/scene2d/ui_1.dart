import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/components/graphs/graph.dart';

import 'package:nukleon/engine/debug/debug_scene2d.dart';
import 'package:nukleon/engine/engine.dart';

void main() async {
  Public.textureFilter = FilterQuality.none;
  await Engine.initializeEngine();
  DGraph<Widget> testScene = DGraph<Widget>();
  testScene.create(
      0, const ColoredBox(color: Colors.red, child: Center(child: Text("0"))));
  testScene.create(
      1, const ColoredBox(color: Colors.blue, child: Center(child: Text("1"))));
  testScene.create(
      2, const ColoredBox(color: Colors.green, child: Center(child: Text("2"))));
  testScene.create(
      3, const ColoredBox(color: Colors.purple, child: Center(child: Text("3"))));
  testScene.linkSequential(const <DGraphLink>[
    DGraphLink(from: 0, to: 1),
    DGraphLink(from: 1, to: 2),
    DGraphLink(from: 2, to: 3)
  ]);
  Scene2DController scene2dController = Scene2DController(testScene);
  scene2dController.sequence = StaticDGraphSeq(const <int>[0, 1, 2, 3]);
  Engine.bootstrap(Scene2DWidget(
      controller: scene2dController, atopChild: DebugScene2DControls(wrap: true)));
}
