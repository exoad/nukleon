import 'package:flutter/foundation.dart';
import 'package:project_yellow_cake/engine/engine.dart';
import 'package:project_yellow_cake/game/controllers/pointer.dart';
import 'package:project_yellow_cake/game/entities/reactor.dart';
import 'package:project_yellow_cake/game/classes/classes.dart';
import 'package:project_yellow_cake/game/shared.dart';

export "shared.dart";

class GameRoot {
  static final GameRoot I = GameRoot._();

  final ValueNotifier<ReactorEntity> _reactorEntity;
  final PointerBuffer _pointerBuffer;

  GameRoot._()
      : _reactorEntity = ValueNotifier<ReactorEntity>(ReactorEntity(
          rows: Shared.reactorRows,
          columns: Shared.reactorColumns,
        )),
        _pointerBuffer = PointerBuffer(1);

  Future<void> loadBuiltinItems() async {
    await initializeEngine();
    await Shared.initialize();
    ItemsRegistry.I.addItemDefinition(0, Class.BACKDROPS, EmptyCell());
    int i = 1;
    ItemsRegistry.I.addItemDefinition(i++, Class.ITEMS, UraniumCell());
    ItemsRegistry.I.addItemDefinition(i++, Class.ITEMS, UraniumEnhancedCell());
    // ! TEMP
    i = 1;
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, ReactorButton1Normal());
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, ReactorButton1Pressed());
    Shared.logger.info("Loaded builtin items into the engine registry");
  }

  ReactorEntity get reactor => _reactorEntity.value;

  PointerBuffer get pointerBuffer => _pointerBuffer;
}
