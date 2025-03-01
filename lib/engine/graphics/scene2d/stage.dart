import 'package:shitter/engine/engine.dart';

class StageActor<T> {
  final int id;
  final T value;
  final StageActor<T>? parent;
  final List<StageActor<T>> _children;

  // ignore: always_specify_types
  StageActor(this.id, this.value, {this.parent}) : _children = <StageActor<T>>[];

  List<StageActor<T>> get children => _children;

  StageActor<T> pushChild(T value) {
    final StageActor<T> actor = StageActor<T>(_children.length, value, parent: this);
    _children.add(actor);
    return actor;
  }

  void addChild(T value) {
    final StageActor<T> actor = StageActor<T>(_children.length, value, parent: this);
    _children.add(actor);
  }
}

class Stage<T> with ChangeNotifier {
  final StageActor<T> _root;
  StageActor<T> _ptr;
  Stage(int id, T root)
      : _root = StageActor<T>(id, root),
        _ptr = StageActor<T>(id, root);

  Stage.defined(StageActor<T> root)
      : _root = root,
        _ptr = root;

  T get peek => _ptr.value;

  void push(T value) {
    _ptr.addChild(value);
  }

  void down(int index) {
    if (_ptr.children.within(index)) {
      _ptr = _ptr.children[index];
      notifyListeners();
    } else {
      if (Public.preferWarnings) {
        logger.warning(
            "SCENE2D: Stage index $index for $_ptr with ${_ptr.children.length} actors is not possible");
      } else {
        panicNow(
            "SCENE2D: Stage index $index for $_ptr with ${_ptr.children.length} actors is not possible");
      }
    }
  }

  void up() {
    if (_ptr.parent != null) {
      _ptr = _ptr.parent!;
      notifyListeners();
    } else {
      logger.warning("SCENE2D: Tried to find an actor upwards, but got null instead!");
    }
  }

  void jumpTo(int id) {
    final StageActor<T>? temp = find(_root, id);
    if (temp != null) {
      _ptr = temp;
      notifyListeners();
    } else {
      logger.warning(
          "SCENE2D: Could not jump to an actor with $id. Not found in the stage tree!");
    }
  }

  void shiftTo(int shift) {
    final int id = _ptr.id + shift;
    if (_ptr.children.within(id)) {
      _ptr = _ptr.children[id];
      notifyListeners();
    } else {
      if (Public.preferWarnings) {
        logger.warning(
            "SCENE2D: Stage index $id for $_ptr with ${_ptr.children.length} actors is not possible");
      } else {
        panicNow(
            "SCENE2D: Stage index $id for $_ptr with ${_ptr.children.length} actors is not possible");
      }
    }
  }

  StageActor<T>? find(StageActor<T> node, int id) {
    if (node.id == id) {
      return node;
    }
    for (StageActor<T> child in node.children) {
      final StageActor<T>? temp = find(child, id);
      if (temp != null) {
        return temp;
      }
    }
    return null;
  }
}
