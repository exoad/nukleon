import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/components/graphs/graph.dart';

import '../test.dart';

void testScene2d() {
  DGraph<String> graph = DGraph<String>();
  graph.create(0, "A");
  graph.create(1, "B");
  graph.create(2, "C");
  graph.link(from: 0, to: 1);
  graph.link(from: 1, to: 2, bidirectional: false);
  print(graph);
  t("Max=2", graph.max, 2);
  t("Min=0", graph.min, 0);
  t("ContainsPathThrows=[1,4]", () => graph.containsPath(from: 1, to: 4),
      throwsException);
  t(
      "ValidSeq=[0,1,2]",
      (DGraphAggregator<String>(graph)..sequence = StaticDGraphSeq(<int>[0, 1, 2]))
          .isValidSequence,
      true);
  t(
      "AggSeq[0,1,2]=[A,B,C]",
      (DGraphAggregator<String>(graph)..sequence = StaticDGraphSeq(<int>[0, 1, 2]))
          .aggregateValues(),
      <String>["A", "B", "C"]);
}
