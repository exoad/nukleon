import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:nukleon/engine/engine.dart';

class SceneLink with EquatableMixin {
  final int from;
  final int to;

  const SceneLink({required this.from, required this.to});

  @override
  List<Object?> get props => <Object?>[from, to];
}

class SceneGraph<T> {
  final Map<int, Set<int>> _graph; // adjlist and represents a directed graph
  final Map<int, T> _dict;

  SceneGraph()
      : _graph = <int, Set<int>>{},
        _dict = <int, T>{};

  void _checkNodeId(int id) {
    // if (id < 0) {
    //   panicNow("SceneGraph Node ID must be non-negative.", details: "Got $id");
    // }
  }

  /// Tries to remove the node [id] from the graph. if [tryFix] is set to `true`, this method
  /// will try to repair the graph if removals leaves the graph disconnected. otherwise, this function
  /// will just leave the graph as is if it is disconnected, which is highly unsafe. however, setting it to
  /// `false` will mean that there are no checks in place thus reducing latency if the programmer gurantees this check implicitly.
  void removeNode(int id, [bool tryFix = true]) {
    // TODO: implement
    if (!_dict.containsKey(id)) {
      logger.warning(
          "SCENE2D: The node $id is not defined. Removing can be dangerous without a definition.");
    }
    if (tryFix) {
    } else {}
  }

  /// Searches for an edge node (the node in the adjacency list with the highest ID)
  ///
  /// This saves us time from using a splayed tree.
  int get max {
    return _graph.keys.max;
  }

  /// Searches for an edge node with the lowest ID
  int get min {
    return _graph.keys.min;
  }

  /// Looks up [i] in the dictionary. Good for finding the value of a node relative to the graph.
  T peekNode(int i) {
    if (!_dict.containsKey(i)) {
      panicNow("SCENE2D: Node $i is not defined.");
    }
    return _dict[i]!;
  }

  bool containsNode(int id) {
    return _dict.containsKey(id);
  }

  /// Check is a directed edge exists. this doesnt check for bidirectionality, if you want to check for that, swap the parameters and call this again
  bool containsEdge({required int from, required int to}) {
    return _graph.containsKey(from) &&
        _graph.containsKey(to) &&
        _graph[from]!.contains(to);
  }

  /// Checks if a path exists nodes [from] and nodes [to]. Performs BFS.
  bool containsPath({required int from, required int to}) {
    _checkNodeId(from);
    _checkNodeId(to);
    if (!_dict.containsKey(from)) {
      logger.warning(
          "SCENE2D: From node $from (to $to) doesn't have a definition! This can be dangerous.");
    }
    if (!_dict.containsKey(to)) {
      logger.warning(
          "SCENE2D: To node $to (from $from) doesn't have a definition! This can be dangerous.");
    }
    if (!_graph.containsKey(from)) {
      panicNow(
          "SCENE2D: From node $from (to $to) doesn't exist in the graph. Maybe you forgot to link it?",
          help: "\nThe current scene:\n${toString()}");
    }
    if (!_graph.containsKey(to)) {
      panicNow(
          "SCENE2D: To node $to (from $from) doesn't exist in the graph. Maybe you forgot to link it?",
          help: "\nThe current scene:\n${toString()}");
    }
    BoolList visited = BoolList(vertices);
    Queue<int> q = Queue<int>();
    visited[from] = true;
    q.addLast(from);
    late Iterator<int> i;
    while (q.isNotEmpty) {
      from = q.removeFirst();
      i = _graph[from]!.iterator;
      while (i.moveNext()) {
        if (i.current == to) {
          return true;
        }
        if (!visited[i.current]) {
          visited[i.current] = true;
          q.addLast(i.current);
        }
      }
    }
    return false;
  }

  Iterable<int> neighborsOf(int id) => _graph[id]!;

  /// Operator wrapper for [neighborsOf]
  Iterable<int> operator [](int id) => neighborsOf(id);

  void create(int id, T node) {
    _checkNodeId(id);
    _dict[id] = node;
  }

  void link({required int from, required int to, bool bidirectional = true}) {
    _checkNodeId(from);
    _checkNodeId(to);
    if (!_dict.containsKey(from)) {
      logger.warning(
          "SCENE2D: Linking from node $from (to $to) doesn't have a definition! This can be dangerous.");
    }
    if (!_dict.containsKey(to)) {
      logger.warning(
          "SCENE2D: Linking to node $to (from $from) doesn't have a definition! This can be dangerous.");
    }
    _graph.putIfAbsent(from, () => <int>{}).add(to);
    _graph.putIfAbsent(to, () => <int>{});
    if (bidirectional) {
      _graph[to]!.add(from);
    }
  }

  /// Simplification for calling [link] multiple times on a sequential link
  void linkSequential(List<SceneLink> edges, [List<bool>? bidrectional]) {
    if (bidrectional != null) {
      if (bidrectional.length != edges.length) {
        panicNow(
            "SCENE2D: If supplying bidrectionality, the length of edges [${edges.length}] must equal the bidrectionality properties [${bidrectional.length}]",
            help: "\nThe current scene:\n${toString()}");
      }
      for (int i = 0; i < edges.length; i++) {
        link(from: edges[i].from, to: edges[i].to, bidirectional: bidrectional[i]);
      }
    } else {
      for (int i = 0; i < edges.length; i++) {
        link(from: edges[i].from, to: edges[i].to);
      }
    }
  }

  int get vertices => _dict.length;

  int get edges {
    Set<SceneLink> uniqueEdges = <SceneLink>{};
    for (int from in _graph.keys) {
      for (int to in _graph[from]!) {
        uniqueEdges.add(
            from < to ? SceneLink(from: from, to: to) : SceneLink(from: to, to: from));
      }
    }
    return uniqueEdges.length;
  }

  Iterable<MapEntry<int, Iterable<int>>> get nodes {
    return _graph.entries;
  }

  Iterable<MapEntry<int, T>> get definitions {
    return _dict.entries;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer("SceneGraph[Vertices=$vertices,Edges=$edges]\n");
    for (MapEntry<int, T> entry in _dict.entries) {
      buffer.write("\t${entry.key} = ${entry.value}\n");
    }
    buffer.write("\t=");
    for (int i = 0; i < 10; i++) {
      buffer.write("=");
    }
    buffer.write("\n");
    for (MapEntry<int, Set<int>> entry in _graph.entries) {
      buffer.write("\t${entry.key} : ");
      if (entry.value.isNotEmpty) {
        for (int i = 0; i < entry.value.length - 1; i++) {
          buffer.write("${entry.value.elementAt(i)},");
        }
        buffer.write("${entry.value.last}");
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
