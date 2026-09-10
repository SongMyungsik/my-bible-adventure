import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Records the child's voice and plays it back so they can hear themselves.
/// No pronunciation scoring is attempted - this is listen-and-repeat only.
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _lastRecordingPath;

  bool get hasRecording => _lastRecordingPath != null;

  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/speak_practice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      _lastRecordingPath = await _recorder.stop();
    } catch (_) {
      _lastRecordingPath = null;
    }
  }

  Future<void> playback() async {
    final path = _lastRecordingPath;
    if (path == null) return;
    try {
      await _player.play(DeviceFileSource(path));
    } catch (_) {
      // Playback failure is non-fatal; the child can just try recording again.
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
