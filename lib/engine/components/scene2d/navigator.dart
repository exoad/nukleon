import 'package:nukleon/engine/components/scene2d.dart';
import 'package:nukleon/engine/engine.dart';

class SceneNavigator<T> {
  final SceneGraph<T> _graph;
  SceneSequence? _sequence;

  SceneNavigator(SceneGraph<T> graph) : _graph = graph;

  set sequence(SceneSequence seq) => _sequence = seq;

  SceneGraph<T> get graph => _graph;

  void _checkSequenceExistence() {
    panicIf(_sequence == null,
        label: "SCENE2D: Cannot access Scene Sequence because it is not loaded!");
  }

  /// pretty expensive operation. basically traverses to see if the path represented by [_sequence] exists in the graph. (takes a walk of the graph)
  /// This does not validate that there exists another sequence that gets from the first to the end of the [_sequence], it strictly adheres to the sequence.
  bool get isValidSequence {
    if (_sequence != null) {
      for (int i = 1; i < _sequence!.sequence.length; i++) {
        if (!_graph.containsPath(
            from: _sequence!.sequence[i - 1], to: _sequence!.sequence[i])) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  SceneSequence get sequence {
    _checkSequenceExistence();
    return _sequence!;
  }

  int get location {
    _checkSequenceExistence();
    return _sequence!.location;
  }

  /// Loops through the entire sequence ONCE. It does not wrap and does not perform heavy weight path checking, if a path does not exist, it will fail when it arrives at that point, it does not fail prematurely.
  void aggregate({bool reset = true, required void Function(int, T) listener}) {
    panicIf(_sequence == null,
        label:
            "SCENE2D_NAV: The supplied sequence is null. Cannot aggregate on a nonexistent sequence!",
        help: "The current scene:\n${_graph.toString()}");
    if (reset) {
      _sequence!.resetPointer();
    }
    for (int i = 0; i < _sequence!.sequence.length; i++) {
      listener(_sequence!.location, _graph.peekNode(_sequence!.location));
      _sequence!.next();
    }
  }

  /// Similar to [aggregate] but returns a list of all of the values encountered in order of their appearance. If [allowDupes] is set to `true`, the aggregator will return an [Iterable] with potential for non-unique values; otherwise it will return a list of unique values.
  Iterable<T> aggregateValues({bool reset = true, bool allowDupes = true}) {
    panicIf(_sequence == null,
        label:
            "SCENE2D_NAV: The supplied sequence is null. Cannot aggregate on a nonexistent sequence!",
        help: "The current scene:\n${_graph.toString()}");
    if (reset) {
      _sequence!.resetPointer();
    }
    if (allowDupes) {
      List<T> values = <T>[];
      for (int i = 0; i < _sequence!.sequence.length; i++) {
        values.add(_graph.peekNode(_sequence!.location));
        _sequence!.next();
      }
      return values;
    } else {
      Set<T> values = <T>{};
      for (int i = 0; i < _sequence!.sequence.length; i++) {
        values.add(_graph.peekNode(_sequence!.location));
        _sequence!.next();
      }
      return values;
    }
  }

  T get peekNode {
    _checkSequenceExistence();
    return _graph.peekNode(location);
  }

  Iterable<int> get peekNeighbors {
    _checkSequenceExistence();
    return _graph.neighborsOf(_sequence!._ptr);
  }

  void next([bool wrap = false]) {
    _checkSequenceExistence();
    _sequence!.next(wrap);
  }

  void back([bool wrap = false]) {
    _checkSequenceExistence();
    _sequence!.back(wrap);
  }
}

/// A standalone sequence of positions to walk along a graph. Where the positions in the sequence denote from the ith position to the kth position.
/// `i[0]` -> `i[1]` -> ... -> `i[len - 1]`
class SceneSequence {
  final List<int> sequence;
  int _ptr;

  SceneSequence(this.sequence)
      : assert(sequence.isNotEmpty, "SCENE2D: A sequence cannot be empty!"),
        _ptr = 0;

  void resetPointer() {
    _ptr = 0;
  }

  void next([bool wrap = false]) {
    _ptr == sequence.length - 1 && wrap ? _ptr = 0 : _ptr++;
  }

  void back([bool wrap = false]) {
    _ptr == 0 && wrap ? _ptr = sequence.length - 1 : _ptr--;
  }

  int get location => _ptr;
}
