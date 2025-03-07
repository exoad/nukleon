import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/debug/debug_scene2d.dart';
import 'package:nukleon/engine/engine.dart';

void main() async {
  Public.textureFilter = PublicK.TEXTURE_FILTER_NONE;
  await Engine.initializeEngine();
  SceneGraph<Widget> testScene = SceneGraph<Widget>();
  testScene.create(
      0, const ColoredBox(color: Colors.red, child: Center(child: Text("0"))));
  testScene.create(
      1, const ColoredBox(color: Colors.blue, child: Center(child: Text("1"))));
  testScene.create(
      2, const ColoredBox(color: Colors.green, child: Center(child: Text("2"))));
  testScene.create(
      3, const ColoredBox(color: Colors.purple, child: Center(child: Text("3"))));
  testScene.linkSequential(const <SceneLink>[
    SceneLink(from: 0, to: 1),
    SceneLink(from: 1, to: 2),
    SceneLink(from: 2, to: 3)
  ]);
  Scene2DController scene2dController = Scene2DController(testScene);
  scene2dController.sequence = SceneSequence(const <int>[0, 1, 2, 3]);
  Engine.bootstrap(Scene2DWidget(
      controller: scene2dController, atopChild: DebugScene2DControls(wrap: true)));
}
