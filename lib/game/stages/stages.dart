import 'package:nukleon/engine/components/graphs/graph.dart';
import 'package:nukleon/engine/engine.dart';

final class GameStage extends StatefulWidget {
  final DGraph<Widget> _stage;

  const GameStage(DGraph<Widget> graph, {super.key}) : _stage = graph;

  @override
  State<GameStage> createState() => _GameStageState();
}

class _GameStageState extends State<GameStage> {
  late final DGraphAggregator<Widget> _aggregator;

  @override
  void initState() {
    super.initState();
    _aggregator = DGraphAggregator<Widget>(widget._stage);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
