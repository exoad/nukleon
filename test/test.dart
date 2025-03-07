import 'package:flutter_test/flutter_test.dart';

void t(String name, dynamic real, dynamic e) {
  test(name, () => expect(real, e));
}
