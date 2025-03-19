import 'package:nukleon/src/engine/components/graphs/graph.dart';
import 'package:nukleon/src/engine/engine.dart';

class DGraphNavigator<T> with DGraphAggregator<T> {
  final DGraph<T> _graph;

  DGraphNavigator(DGraph<T> graph) : _graph = graph;

  @override
  DGraph<T> get graph => _graph;
}

mixin DGraphAggregator<T> {
  StaticDGraphSeq? _sequence;

  set sequence(StaticDGraphSeq seq) => _sequence = seq;

  DGraph<T> get graph;

  void _checkSequenceExistence() {
    panicIf(_sequence == null,
        label: "SCENE2D: Cannot access Scene Sequence because it is not loaded!");
  }

  /// pretty expensive operation. basically traverses to see if the path represented by [_sequence] exists in the graph. (takes a walk of the graph)
  /// This does not validate that there exists another sequence that gets from the first to the end of the [_sequence], it strictly adheres to the sequence.
  bool get isValidSequence {
    if (_sequence != null) {
      for (int i = 1; i < _sequence!.sequence.length; i++) {
        if (!graph.containsPath(
            from: _sequence!.sequence[i - 1], to: _sequence!.sequence[i])) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  StaticDGraphSeq get sequence {
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
        help: "The current scene:\n${graph.toString()}");
    if (reset) {
      _sequence!.resetPointer();
    }
    for (int i = 0; i < _sequence!.sequence.length; i++) {
      listener(_sequence!.location, graph.peekNode(_sequence!.location));
      _sequence!.next();
    }
  }

  /// Similar to [aggregate] but returns a list of all of the values encountered in order of their appearance. If [allowDupes] is set to `true`, the aggregator will return an [Iterable] with potential for non-unique values; otherwise it will return a list of unique values.
  Iterable<T> aggregateValues({bool reset = true, bool allowDupes = true}) {
    panicIf(_sequence == null,
        label:
            "SCENE2D_NAV: The supplied sequence is null. Cannot aggregate on a nonexistent sequence!",
        help: "The current scene:\n${graph.toString()}");
    if (reset) {
      _sequence!.resetPointer();
    }
    if (allowDupes) {
      List<T> values = <T>[];
      for (int i = 0; i < _sequence!.sequence.length; i++) {
        values.add(graph.peekNode(_sequence!.location));
        _sequence!.next();
      }
      return values;
    } else {
      Set<T> values = <T>{};
      for (int i = 0; i < _sequence!.sequence.length; i++) {
        values.add(graph.peekNode(_sequence!.location));
        _sequence!.next();
      }
      return values;
    }
  }

  T get currentNode {
    _checkSequenceExistence();
    return graph.peekNode(location);
  }

  Iterable<int> get peekNeighbors {
    _checkSequenceExistence();
    return graph.neighborsOf(_sequence!._ptr);
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

sealed class DGraphSeq {
  int _ptr;

  DGraphSeq() : _ptr = 0;

  void next([bool wrap = false]);

  void back([bool wrap = false]);

  void reset() => _ptr = 0;

  int get location => _ptr;
}

enum DGraphSeqDirection {
  BACK,
  NEXT;
}

class HotDGraphSeq extends DGraphSeq {
  final int Function(int ptr, DGraphSeqDirection dir, bool wrap) _delegate;

  HotDGraphSeq(int Function(int ptr, DGraphSeqDirection dir, bool wrap) delegate)
      : _delegate = delegate,
        super();

  @override
  void back([bool wrap = false]) {
    _ptr = _delegate(_ptr, DGraphSeqDirection.BACK, wrap);
  }

  @override
  void next([bool wrap = false]) {
    _ptr = _delegate(_ptr, DGraphSeqDirection.NEXT, wrap);
  }
}

mixin DGraphTraverser<T> on DGraph<T> {
  int _ptr = 0;

  void goto(int ptr, [bool panic = true]) {
    if (panic && (ptr > max || ptr < min)) {
      panicNow(
          "D_GRAPH: Cannot move pointer to $ptr. It is out of bounds [${definitions.map((MapEntry<int, T> entry) => entry.key)}]");
    }
    if (ptr == pointer) {
      logger.warning(
          "Trying to go to $ptr from $pointer, these are the same location! Is this a mistake?");
    }
    _ptr = ptr;
  }

  int get pointer => _ptr;

  T peekNodeAtPointer() {
    return peekNode(_ptr);
  }
}

class BoundedDGraphSeq extends DGraphSeq {
  final int max;
  final int min;

  BoundedDGraphSeq({required this.max, required this.min}) : super();

  @override
  void back([bool wrap = false]) {
    if (_ptr - 1 < min) {
      _ptr = wrap ? max : min;
    } else {
      _ptr--;
    }
  }

  @override
  void next([bool wrap = false]) {
    if (_ptr + 1 > max) {
      _ptr = wrap ? min : max;
    } else {
      _ptr++;
    }
  }
}

/// A standalone sequence of positions to walk along a graph. Where the positions in the sequence denote from the ith position to the kth position.
/// `i[0]` -> `i[1]` -> ... -> `i[len - 1]`
class StaticDGraphSeq extends DGraphSeq {
  final List<int> _sequence;

  StaticDGraphSeq(List<int> sequence)
      : assert(sequence.isNotEmpty, "SCENE2D: A sequence cannot be empty!"),
        _sequence = sequence,
        super();
  void resetPointer() {
    _ptr = 0;
  }

  @override
  void back([bool wrap = false]) {
    if (wrap && _sequence.within(_ptr - 1)) {
      _ptr = _sequence.length - 1;
    } else {
      _ptr--;
    }
  }

  @override
  void next([bool wrap = false]) {
    if (wrap && _sequence.within(_ptr + 1)) {
      _ptr = 0;
    } else {
      _ptr++;
    }
  }

  List<int> get sequence => _sequence;

  @override
  int get location => _sequence[_ptr];
}
