import "package:nukleon/client/client.dart";
import "package:nukleon/engine/engine.dart";

import "package:nukleon/game/game.dart";
import "package:nukleon/engine/components/stage2d/stages.dart";
import "package:nukleon/game/routes/main_start.dart";

int i = 0;
void main() async {
  Public.textureFilter = FilterQuality.none;
  await Engine.initializeEngine();
  await Apollo.initialize();
  await GameRoot.I.loadBuiltinItems();
  await Client.initialize();
  GameRoot.I.soundConfig.volume = 0.7;
  Engine.bootstrap(const GameStage());
  Stage2D.I.bump($mainStartStage());
}
