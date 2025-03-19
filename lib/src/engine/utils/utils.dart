/// Useful tools and generialized things for throughout the program.
library;

export "extern.dart";
export "colors.dart";
export "result.dart";
export "lin_trans.dart";
export "strings.dart";

@pragma("vm:prefer-inline")
bool onlyOneNull<A>(A? first, A? second) {
  return (first != null) ^ (second != null);
}
