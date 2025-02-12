import 'package:project_yellow_cake/engine/engine.dart';

export "items/items.dart";
export "ui/ui.dart";
export "backdrops/backdrops.dart";

abstract class Cell extends ItemDefinition {
  String get canonicalName;

  String get canonicalLabel;
}
