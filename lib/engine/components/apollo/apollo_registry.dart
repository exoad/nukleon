import 'package:nukleon/engine/engine.dart';

class ApolloRegistry {
  final Map<String, AudioSource?> _map;

  ApolloRegistry._() : _map = <String, AudioSource?>{};

  static final ApolloRegistry I = ApolloRegistry._();

  bool contains(String identifier) => _map.containsKey(identifier);

  bool isLoaded(String identifier) => contains(identifier) && _map[identifier] != null;

  AudioSource find(String identifier) {
    if (!contains(identifier)) {
      panicNow("Failed to find audio source $identifier",
          help: "Maybe load $identifier first?");
    }
    return _map[identifier]!;
  }

  Future<SoundHandle?> playNow(String identifier, SoundConfig config,
      [bool autodispose = true]) async {
    if (!contains(identifier)) {
      logger.severe("APOLLO: Cannot play $identifier, it does not exist.");
      return null;
    }
    if (!isLoaded(identifier)) {
      logger.severe("APOLLO: Cannot play $identifier, it is not loaded.");
      return null;
    }
    return await SoLoud.instance.play(_map[identifier]!,
        volume: config.volume,
        pan: config.pan,
        looping: config.loop,
        paused: config.paused);
  }

  AudioSource? tryFind(String identifier) {
    return _map[identifier];
  }

  void lazyLoad(String identifier) {
    if (!isLoaded(identifier)) {
      _map[identifier] = null;
      logger.info("APOLLO: L_Loaded $identifier");
    } else {
      logger.severe(
          "APOLLO: Could not lazy load $identifier because it has already been loaded! Maybe remove it first?");
    }
  }

  Future<void> load(String identifier) async {
    if (!isLoaded(identifier)) {
      _map[identifier] = await SoLoud.instance.loadAsset(identifier);
      logger.info("APOLLO: Loaded $identifier");
    } else {
      logger.severe(
          "APOLLO: Could not load $identifier because it has already been loaded! Maybe remove it first?");
    }
  }

  void remove(String identifier) {
    if (contains(identifier)) {
      _map.remove(identifier);
      SoLoud.instance.disposeSource(_map[identifier]!);
      logger.warning("APOLLO: Removed $identifier");
    }
  }

  void unload(String identifier) {
    if (!contains(identifier)) {
      logger.warning("APOLLO: Cannot unload a non-existent $identifier.");
      return;
    }
    if (isLoaded(identifier)) {
      _map[identifier] = null;
      logger.finer("APOLLO: Unloaded $identifier");
    } else {
      logger.warning("APOLLO: $identifier is not loaded, so nothing changed.");
    }
  }
}
