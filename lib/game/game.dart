import 'package:shitter/engine/engine.dart';
import 'package:shitter/game/classes/items/item_blank.dart';
import 'package:shitter/game/classes/ui/item_border_prototype.dart';
import 'package:shitter/game/controllers/pointer.dart';
import 'package:shitter/game/entities/reactor.dart';
import 'package:shitter/game/classes/classes.dart';
import 'package:shitter/game/shared.dart';

export "shared.dart";

class GameRoot {
  static final GameRoot I = GameRoot._();

  late ValueNotifier<ReactorEntity> _reactorEntity;
  final PointerBuffer _pointerBuffer;
  final CellLocationBuffer _cellLocationBuffer;

  GameRoot._()
      : _pointerBuffer = PointerBuffer(),
        _cellLocationBuffer = CellLocationBuffer();

  Future<void> loadBuiltinItems() async {
    await Shared.initialize();
    ItemsRegistry.I.addItemDefinition(0, Class.TILES, BasicTile());
    ItemsRegistry.I.addItemDefinition(0, Class.ITEMS, BlankItem());
    _reactorEntity = ValueNotifier<ReactorEntity>(ReactorEntity(
      rows: Shared.reactorRows,
      columns: Shared.reactorColumns,
    ));
    int i = 1;
    ItemsRegistry.I.addItemDefinition(i++, Class.ITEMS, UraniumCell());
    ItemsRegistry.I.addItemDefinition(i++, Class.ITEMS, UraniumEnhancedCell());
    // ! TEMP
    i = 1;
    Facet.M.addLazySingleton<Button1>(Button1.new);
    Facet.M.addLazySingleton<BorderPrototype>(BorderPrototype.new);
    Facet.M.commit();
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, Facet.M.get<Button1>());
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, Facet.M.get<BorderPrototype>());
    Shared.logger.info("Loaded builtin items into the engine registry");
  }

  ReactorEntity get reactor => _reactorEntity.value;

  PointerBuffer get pointerBuffer => _pointerBuffer;

  CellLocationBuffer get cellLocationBuffer => _cellLocationBuffer;
}
