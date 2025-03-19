extension StringsExtension on String {
  /// Compares with case insensitivity
  bool equalsIgnoreCase(String other) {
    return other.toLowerCase() ==
        toLowerCase(); // might not the most efficient solution, but idt there are any other alternatives ??
  }
}
