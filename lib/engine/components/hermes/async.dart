class HermesAsync {
  HermesAsync._();

  static Future<T> delayed<T>(T Function() function, Duration duration) {
    return Future<T>.delayed(duration, function);
  }
}
