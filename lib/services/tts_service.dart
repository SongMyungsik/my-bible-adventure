import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps [FlutterTts] and hides it entirely on platforms where the plugin
/// has no native implementation (Linux desktop), so the UI can simply ask
/// [isSupported] instead of catching platform errors everywhere.
class TtsService {
  TtsService({this.defaultRate = 0.6}) {
    _isSupported = kIsWeb || !Platform.isLinux;
    if (_isSupported) {
      _tts = FlutterTts();
      _tts!.setLanguage('en-US');
      _tts!.setSpeechRate(defaultRate);
      _tts!.setPitch(1.1);
    }
  }

  FlutterTts? _tts;
  late final bool _isSupported;

  /// Speech rate used when [speak] is called without an explicit [rate].
  final double defaultRate;

  bool get isSupported => _isSupported;

  Future<void> speak(String text, {double? rate}) async {
    if (!_isSupported || _tts == null) return;
    await _tts!.stop();
    await _tts!.setSpeechRate(rate ?? defaultRate);
    await _tts!.speak(text);
  }

  Future<void> stop() async {
    if (!_isSupported || _tts == null) return;
    await _tts!.stop();
  }
}
