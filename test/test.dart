import 'package:flutter_test/flutter_test.dart';

void t(String name, dynamic real, dynamic e) {
  test(name, () => expect(real, e));
}

void ta(String name, Future<dynamic> Function() real, dynamic e) {
  test(name, () async => expect(await real(), e));
}

void taa(String name, Future<dynamic> Function() real, Future<dynamic> Function() e) {
  test(name, () async => expect(await real(), await e()));
}
