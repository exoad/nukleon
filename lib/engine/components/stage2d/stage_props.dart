import 'dart:async';

import 'package:async/async.dart';
import 'package:nukleon/engine/components/apollo/apollo.dart';
import 'package:nukleon/engine/public.dart';

abstract class StageProp {
  final String identifier;

  StageProp(this.identifier);

  FutureOr<void> stop();

  FutureOr<void> start();
}

/// For long lasting elements that start on a particular scene, but lasts forever. Can be dangerous.
class EphemeralProp extends StageProp {
  final FutureOr<void> Function() onStart;

  EphemeralProp(super.identifier, this.onStart);

  @override
  FutureOr<void> stop() {
    // ignored
  }

  @override
  FutureOr<void> start() async {
    await onStart();
  }
}

class NormalProp extends StageProp {
  late CancelableOperation<void> op;

  NormalProp(super.identifier, Future<void> cb)
      : op = CancelableOperation<void>.fromFuture(cb);

  @override
  FutureOr<void> start() async {
    await op.value; // ignore return
  }

  @override
  FutureOr<void> stop() async {
    await op.cancel(); // ignore return
  }
}

class AudioClipProp extends StageProp {
  final String audioClipIdentifier;
  final SoundConfig soundConfig;
  SoundHandle? soundHandle;

  AudioClipProp(super.identifier,
      {required this.audioClipIdentifier, required this.soundConfig});

  @override
  FutureOr<void> start() async {
    (await Apollo.quickPlayRegistry(audioClipIdentifier, soundConfig))
      ..onBad((_) => logger.severe(
          "Failed to play audio clip prop $audioClipIdentifier :: ${super.identifier}"))
      ..onGood((SoundHandle handle, _) {
        soundHandle = handle;
        logger.finer(
            "Playing [AUDIO_CLIP_PROP] $audioClipIdentifier :: ${super.identifier}");
      });
  }

  @override
  FutureOr<void> stop() async {
    await soundHandle?.stop();
    logger.finer("Stopped [AUDIO_CLIP_PROP] $audioClipIdentifier :: ${super.identifier}");
  }
}
