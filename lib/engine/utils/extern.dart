extension KnowledgeableList<T> on List<T> {
  /// Checks if [i] is a possible indice
  bool within(int i) {
    return i >= 0 && i < length;
  }
}

extension StringList on Iterable<String> {
  String get longestString {
    return reduce((String a, String b) => a.length > b.length ? a : b);
  }

  String get shortestString {
    return reduce((String a, String b) => a.length > b.length ? b : a);
  }
}
