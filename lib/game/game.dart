import 'package:flutter/foundation.dart';
import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/entities/reactor.dart';
import 'package:project_yellow_cake/game/items/cells/content/item_empty_cell.dart';
import 'package:project_yellow_cake/game/items/cells/content/item_power_cell.dart';
import 'package:project_yellow_cake/game/shared.dart';

export "shared.dart";

class GameRoot {
  static final GameRoot I = GameRoot._();

  final ValueNotifier<ReactorEntity> _reactorEntity;

  GameRoot._()
      : _reactorEntity = ValueNotifier<ReactorEntity>(ReactorEntity(
          rows: Shared.reactorRows,
          columns: Shared.reactorColumns,
        ));

  Future<void> loadBuiltinItems() async {
    await initializeEngine();
    await Shared.initialize();
    int i = 0;
    ItemsRegistry.I.addItemDefinition(i++, EmptyCell());
    ItemsRegistry.I.addItemDefinition(i++, ReactorCell());
    Shared.logger.info(
        "Loaded $i items into the engine registry");
  }

  ReactorEntity get reactor => _reactorEntity.value;
}
