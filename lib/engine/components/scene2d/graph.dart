import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class _GraphEdge with EquatableMixin {
  final int from;
  final int to;

  const _GraphEdge({required this.from, required this.to});

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
    if (id < 0) {
      throw "SceneGraph Node ID must be non-negative. Got $id";
    }
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

  T peekNode(int i) {
    if (!_dict.containsKey(i)) {
      throw "Node $i is not defined.";
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

  bool containsPath({required int from, required int to}) {
    _checkNodeId(from);
    _checkNodeId(to);
    if (!_dict.containsKey(from)) {
      print("From node $from (to $to) doesn't have a definition! This can be dangerous.");
    }
    if (!_dict.containsKey(to)) {
      print("To node $to (from $from) doesn't have a definition! This can be dangerous.");
    }
    if (!_graph.containsKey(from)) {
      throw "From node $from (to $to) doesn't exist in the graph. Maybe you forgot to link it?";
    }
    if (!_graph.containsKey(to)) {
      throw "To node $to (from $from) doesn't exist in the graph. Maybe you forgot to link it?";
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
      print(
          "Linking from node $from (to $to) doesn't have a definition! This can be dangerous.");
    }
    if (!_dict.containsKey(to)) {
      print(
          "Linking to node $to (from $from) doesn't have a definition! This can be dangerous.");
    }
    _graph.putIfAbsent(from, () => <int>{}).add(to);
    _graph.putIfAbsent(to, () => <int>{});
    if (bidirectional) {
      _graph[to]!.add(from);
    }
  }

  int get vertices => _dict.length;

  int get edges {
    Set<_GraphEdge> uniqueEdges = <_GraphEdge>{};
    for (int from in _graph.keys) {
      for (int to in _graph[from]!) {
        uniqueEdges.add(
            from < to ? _GraphEdge(from: from, to: to) : _GraphEdge(from: to, to: from));
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
