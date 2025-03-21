/// Apollo is the sound part of the Nukleon engine.
///
/// Used for handling audio playback as well as builtin speech synthesis.
library;

import 'package:nukleon/engine/engine.dart';

export "package:flutter_soloud/flutter_soloud.dart";
export "apollo_registry.dart";

class SoundConfig {
  double volume;
  double pan;
  final bool paused;
  final bool loop;

  SoundConfig({this.volume = 1, this.pan = 0, this.paused = false, this.loop = false})
      : assert(volume <= 1 && volume >= 0, "Volume must be in range [0,1]");
}

class Apollo {
  static Future<void> initialize() async {
    await SoLoud.instance.init(automaticCleanup: true);
  }

  static Future<void> quickPlayAsset(String handle, SoundConfig config) async {
    await SoLoud.instance.play(await SoLoud.instance.loadAsset(handle),
        volume: config.volume,
        pan: config.pan,
        paused: config.paused,
        looping: config.loop);
  }

  static Future<Result<SoundHandle, dynamic>> quickPlayRegistry(
      String identifier, SoundConfig config) async {
    return Result<SoundHandle, dynamic>.fromNullable(
        await ApolloRegistry.I.playNow(identifier, config), null);
  }

  static Future<void> stopPlayback(SoundHandle handle) async {
    await SoLoud.instance.stop(handle);
  }

  static Future<void> quickTTS(String text) async {
    SoLoud.instance.filters.robotizeFilter.activate();
    SoLoud.instance.play((await SoLoud.instance.speechText(text)));
    SoLoud.instance.filters.robotizeFilter.deactivate();
  }
}

extension SoundHandleExtension on SoundHandle {
  Future<void> stop() async {
    await Apollo.stopPlayback(this);
  }
}
