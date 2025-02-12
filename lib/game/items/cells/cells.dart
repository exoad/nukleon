import 'package:project_yellow_cake/engine/engine.dart';

export "content/item_power_cell.dart";
export "content/item_empty_cell.dart";

abstract class Cell extends ItemDefinition {
  String get canonicalName;

  String get canonicalLabel;
}