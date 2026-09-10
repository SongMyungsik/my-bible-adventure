import 'package:audioplayers/audioplayers.dart';

import 'tts_service.dart';

/// Plays pre-generated narration audio (e.g. from Azure TTS, see
/// `tool/generate_audio.dart`) when a scene has one, falling back to
/// on-device TTS otherwise or if the asset fails to play.
class NarrationService {
  NarrationService({TtsService? tts}) : _tts = tts ?? TtsService();

  final AudioPlayer _player = AudioPlayer();
  final TtsService _tts;

  Future<void> speak(String text, {String? audioAssetPath}) async {
    if (audioAssetPath != null) {
      try {
        await _player.stop();
        final assetKey = audioAssetPath.replaceFirst(RegExp(r'^assets/'), '');
        await _player.play(AssetSource(assetKey));
        return;
      } catch (_) {
        // No pre-generated file yet (or it failed to load) - fall back below.
      }
    }
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
