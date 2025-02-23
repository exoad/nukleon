export "extern.dart";
export "colors.dart";
export "result.dart";
export "lin_trans.dart";

@pragma("vm:prefer-inline")
bool onlyOneNull<A>(A? first, A? second) {
  return (first != null) ^ (second != null);
}
