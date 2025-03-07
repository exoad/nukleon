import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/components/scene2d.dart';

import '../test.dart';

void testScene2d() {
  SceneGraph<String> graph = SceneGraph<String>();
  graph.create(0, "Amogus");
  graph.create(1, "Sus");
  graph.create(2, "WTF");
  graph.link(from: 0, to: 1);
  graph.link(from: 1, to: 2, bidirectional: false);
  print(graph);
  t("Max=2", graph.max, 2);
  t("Min=0", graph.min, 0);
  t("ContainsPathThrows=[1,4]", () => graph.containsPath(from: 1, to: 4),
      throwsException);
  t(
      "ValidSeq=[0,1,2]",
      (SceneNavigator<String>(graph)..sequence = SceneSequence(<int>[0, 1, 2]))
          .isValidSequence,
      true);
  t(
      "AggSeq[0,1,2]=[Amogus,Sus,WTF]",
      (SceneNavigator<String>(graph)..sequence = SceneSequence(<int>[0, 1, 2]))
          .aggregateValues(),
      <String>["Amogus", "Sus", "WTF"]);
}
