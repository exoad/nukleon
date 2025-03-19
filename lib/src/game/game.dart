/// The core of the Nukleon game and defines all of the game logic as well as the customized game behavior.
library;

import 'package:nukleon/src/engine/engine.dart';
import 'package:nukleon/src/engine/utils/images.dart';
import 'package:nukleon/src/game/classes/character/dresses.dart';
import 'package:nukleon/src/game/classes/items/item_blank.dart';
import 'package:nukleon/src/game/classes/ui/item_border_prototype.dart';
import 'package:nukleon/src/game/controllers/pointer.dart';
import 'package:nukleon/src/game/entities/reactor.dart';
import 'package:nukleon/src/game/classes/classes.dart';
import 'package:nukleon/src/game/shared.dart';

export "shared.dart";

class GameRoot {
  static final GameRoot I = GameRoot._();

  late ValueNotifier<ReactorEntity> _reactorEntity;
  final PointerBuffer _pointerBuffer;
  final CellLocationBuffer _cellLocationBuffer;
  final SoundConfig soundConfig = SoundConfig();

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
    Facet.M.addLazySingleton<ButtonFacetConcept1>(ButtonFacetConcept1.new);
    Facet.M.commit();
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, Facet.M.get<Button1>());
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, Facet.M.get<BorderPrototype>());
    ItemsRegistry.I.addItemDefinition(i++, Class.UI, Facet.M.get<ButtonFacetConcept1>());
    i = 1;
    ItemsRegistry.I.addItemDefinition(i++, Class.CHARACTER, DressesUniform1());
    BitmapRegistry.I.registerEntry(BitmapEntry("main_menu_stage_background",
        await ImagesUtil.readAssetImage("assets/backgrounds/main_menu_stage.png")));
    Shared.logger.info("Loaded builtin items into the engine registry");
  }

  ReactorEntity get reactor => _reactorEntity.value;

  PointerBuffer get pointerBuffer => _pointerBuffer;

  CellLocationBuffer get cellLocationBuffer => _cellLocationBuffer;
}
