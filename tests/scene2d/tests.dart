import 'package:flutter_test/flutter_test.dart';
import 'package:nukleon/engine/components/graphs/graph.dart';

import '../test.dart';

void testScene2d() {
  DGraph<String> graph = DGraph<String>();
  graph.create(1, "A");
  graph.create(2, "B");
  graph.create(3, "C");
  graph.link(from: 1, to: 2);
  graph.link(from: 2, to: 3, bidirectional: false);
  print(graph);
  t("Max=2", graph.max, 3);
  t("Min=0", graph.min, 1);
  t("ContainsPathThrows=[1,4]", () => graph.containsPath(from: 1, to: 4),
      throwsException);
  t(
      "ValidSeq=[1,2,3]",
      (DGraphNavigator<String>(graph)..sequence = StaticDGraphSeq(const <int>[1, 2, 3]))
          .isValidSequence,
      true);
  t(
      "AggSeq[1,2,3]=[A,B,C]",
      (DGraphNavigator<String>(graph)..sequence = StaticDGraphSeq(const <int>[1, 2, 3]))
          .aggregateValues(),
      <String>["A", "B", "C"]);
}
