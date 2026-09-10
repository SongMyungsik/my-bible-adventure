import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bible_story.dart';
import '../providers/progress_provider.dart';
import '../services/audio_recording_service.dart';
import '../services/narration_service.dart';
import 'game_screen.dart';

class SpeakPracticeScreen extends StatefulWidget {
  const SpeakPracticeScreen({super.key, required this.story, required this.scenes});

  final BibleStory story;
  final List<StorySentence> scenes;

  @override
  State<SpeakPracticeScreen> createState() => _SpeakPracticeScreenState();
}

class _SpeakPracticeScreenState extends State<SpeakPracticeScreen> {
  final _narration = NarrationService();
  final _recorder = AudioRecordingService();
  int _index = 0;
  bool _isRecording = false;
  bool _hasRecording = false;

  bool get _isLastSentence => _index == widget.scenes.length - 1;

  @override
  void dispose() {
    _narration.stop();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _recorder.stop();
      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });
      return;
    }

    final started = await _recorder.start();
    if (!started) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마이크 권한이 필요해요 🎤')),
      );
      return;
    }
    setState(() {
      _isRecording = true;
      _hasRecording = false;
    });
  }

  void _finish() {
    context.read<ProgressProvider>().recordSpeakPracticeCompleted();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameScreen(story: widget.story)),
    );
  }

  void _next() {
    if (_isLastSentence) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _hasRecording = false;
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentence = widget.scenes[_index];
    final total = widget.scenes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('따라 말하기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('${_index + 1} / $total'),
                      const SizedBox(height: 20),
                      const Text('🧒', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      Text(
                        sentence.english,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sentence.korean,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.replay_rounded,
                          label: '다시 듣기',
                          onPressed: () => _narration.speak(
                            sentence.english,
                            audioAssetPath: sentence.audioPath,
                          ),
                        ),
                        _ActionButton(
                          icon: _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                          label: _isRecording ? '녹음 중지' : '말하기',
                          highlighted: true,
                          onPressed: _toggleRecording,
                        ),
                        _ActionButton(
                          icon: Icons.play_circle_fill_rounded,
                          label: '듣기',
                          onPressed: _hasRecording ? _recorder.playback : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        child: Text(_isLastSentence ? 'Next: Game' : 'Next Sentence'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(
            minimumSize: const Size(64, 64),
            backgroundColor: highlighted ? Colors.deepPurple : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
