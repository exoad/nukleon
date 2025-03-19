/// A very generalizable graph data structure that is primarily used for the 'scene2d'
/// of the engine.
library;

import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:nukleon/src/engine/engine.dart';

export "navigator.dart";

class DGraphLink with EquatableMixin {
  final int from;
  final int to;

  const DGraphLink({required this.from, required this.to});

  @override
  List<Object?> get props => <Object?>[from, to];
}

class DGraph<T> {
  final Map<int, Set<int>> _graph; // adjlist and represents a directed graph
  @protected
  final Map<int, T> dict;
  int? _max;
  int? _min;

  DGraph()
      : _graph = <int, Set<int>>{},
        dict = <int, T>{};

  @protected
  void checkNodeId(int id) {
    // if (id < 0) {
    //   panicNow("SceneGraph Node ID must be non-negative.", details: "Got $id");
    // }
  }

  /// Potentially expensive operation to recalculate [max] and [min] directly. Runs in linear time.
  void updateBounds() {
    _max = dict.keys.max;
    _min = dict.keys.min;
  }

  /// Tries to remove the node [id] from the graph. if [tryFix] is set to `true`, this method
  /// will try to repair the graph if removals leaves the graph disconnected. otherwise, this function
  /// will just leave the graph as is if it is disconnected, which is highly unsafe. however, setting it to
  /// `false` will mean that there are no checks in place thus reducing latency if the programmer gurantees this check implicitly.
  void removeNode(int id, [bool tryFix = true]) {
    // TODO: implement
    if (!dict.containsKey(id)) {
      logger.warning(
          "D_GRAPH: The node $id is not defined. Removing can be dangerous without a definition.");
    }
    if (tryFix) {
    } else {}
  }

  /// Searches for an edge node (the node in the adjacency list with the highest ID)
  ///
  /// This saves us time from using a splayed tree.
  int get max {
    if (_max == null) {
      panicNow("D_GRAPH: Graph not populated, unable to fetch 'max' node handle");
    }
    return _max!;
  }

  /// Searches for an edge node with the lowest ID
  int get min {
    if (_min == null) {
      panicNow("D_GRAPH: Graph not populated, unable to fetch 'min' node handle");
    }
    return _min!;
  }

  /// Looks up [i] in the dictionary. Good for finding the value of a node relative to the graph.
  T peekNode(int i) {
    if (!dict.containsKey(i)) {
      panicNow("D_GRAPH: Node $i is not defined.");
    }
    return dict[i]!;
  }

  bool containsNode(int id) {
    return dict.containsKey(id);
  }

  /// Check is a directed edge exists. this doesnt check for bidirectionality, if you want to check for that, swap the parameters and call this again
  bool containsEdge({required int from, required int to}) {
    return _graph.containsKey(from) &&
        _graph.containsKey(to) &&
        _graph[from]!.contains(to);
  }

  /// Checks if a path exists nodes [from] and nodes [to]. Performs BFS.
  bool containsPath({required int from, required int to}) {
    checkNodeId(from);
    checkNodeId(to);
    if (!dict.containsKey(from)) {
      panicNow("D_GRAPH: From node $from (to $to) doesn't have a definition!");
    }
    if (!dict.containsKey(to)) {
      panicNow("D_GRAPH: To node $to (from $from) doesn't have a definition!");
    }
    if (!_graph.containsKey(from)) {
      panicNow(
          "D_GRAPH: From node $from (to $to) doesn't exist in the graph. Maybe you forgot to link it?",
          help: "\nThe current scene:\n${toString()}");
    }
    if (!_graph.containsKey(to)) {
      panicNow(
          "D_GRAPH: To node $to (from $from) doesn't exist in the graph. Maybe you forgot to link it?",
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
    checkNodeId(id);
    if (_max == null && _min == null) {
      _max = id;
      _min = id;
    } else {
      if (id > max) {
        _max = id;
      }
      if (id < min) {
        _min = id;
      }
    }
    dict[id] = node;
  }

  void link({required int from, required int to, bool bidirectional = true}) {
    checkNodeId(from);
    checkNodeId(to);
    if (!dict.containsKey(from)) {
      panicNow("D_GRAPH: Linking from node $from (to $to) doesn't have a definition!");
    }
    if (!dict.containsKey(to)) {
      panicNow("D_GRAPH: Linking to node $to (from $from) doesn't have a definition!");
    }
    _graph.putIfAbsent(from, () => <int>{}).add(to);
    _graph.putIfAbsent(to, () => <int>{});
    if (bidirectional) {
      _graph[to]!.add(from);
    }
  }

  /// Simplification for calling [link] multiple times on a sequential link
  void linkSequential(List<DGraphLink> edges, [List<bool>? bidrectional]) {
    if (bidrectional != null) {
      if (bidrectional.length != edges.length) {
        panicNow(
            "D_GRAPH: If supplying bidrectionality, the length of edges [${edges.length}] must equal the bidrectionality properties [${bidrectional.length}]",
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

  int get vertices => dict.length;

  int get edges {
    Set<DGraphLink> uniqueEdges = <DGraphLink>{};
    for (int from in _graph.keys) {
      for (int to in _graph[from]!) {
        uniqueEdges.add(
            from < to ? DGraphLink(from: from, to: to) : DGraphLink(from: to, to: from));
      }
    }
    return uniqueEdges.length;
  }

  Iterable<MapEntry<int, Iterable<int>>> get nodes {
    return _graph.entries;
  }

  Iterable<MapEntry<int, T>> get definitions {
    return dict.entries;
  }

  @override
  String toString() {
    StringBuffer buffer =
        StringBuffer("DirectedGraph[Vertices=$vertices,Edges=$edges]\n");
    for (MapEntry<int, T> entry in dict.entries) {
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
