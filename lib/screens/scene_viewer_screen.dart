import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bible_story.dart';
import '../providers/progress_provider.dart';
import '../services/narration_service.dart';
import '../services/tts_service.dart';
import '../widgets/highlighted_sentence.dart';
import 'speak_practice_screen.dart';

class SceneViewerScreen extends StatefulWidget {
  const SceneViewerScreen({super.key, required this.story, required this.scenes});

  final BibleStory story;
  final List<StorySentence> scenes;

  @override
  State<SceneViewerScreen> createState() => _SceneViewerScreenState();
}

class _SceneViewerScreenState extends State<SceneViewerScreen> {
  late final _tts = TtsService();
  late final _narration = NarrationService(tts: _tts);
  int _index = 0;

  bool get _isLastScene => _index == widget.scenes.length - 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrentNarration());
  }

  @override
  void dispose() {
    _tts.stop();
    _narration.dispose();
    super.dispose();
  }

  void _playCurrentNarration() {
    final scene = widget.scenes[_index];
    _narration.speak(scene.english, audioAssetPath: scene.audioPath);
  }

  void _advance() {
    final progress = context.read<ProgressProvider>();
    progress.recordSentenceRead();
    if (_isLastScene) {
      progress.learnWords(widget.story.vocabulary.map((w) => w.id));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SpeakPracticeScreen(story: widget.story, scenes: widget.scenes),
        ),
      );
    } else {
      setState(() => _index++);
      _playCurrentNarration();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scenes[_index];
    final total = widget.scenes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: Text(widget.story.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text('Scene ${scene.sceneNumber ?? _index + 1} / ${scene.totalScenes ?? total}'),
              const SizedBox(height: 16),
              _SceneIllustration(scene: scene),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (scene.isTitle)
                        Text(
                          scene.english,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        )
                      else
                        HighlightedSentence(
                          sentence: scene.english,
                          vocabulary: widget.story.vocabulary,
                          onWordTap: (word) => _tts.speak(word),
                          style:
                              const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, height: 1.4),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        scene.korean,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      IconButton.filledTonal(
                        onPressed: _playCurrentNarration,
                        icon: const Icon(Icons.volume_up_rounded),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    if (_index > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => _index--);
                            _playCurrentNarration();
                          },
                          child: const Text('Back'),
                        ),
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _advance,
                        child: Text(_isLastScene ? 'Next: Speak' : 'Next'),
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

class _SceneIllustration extends StatelessWidget {
  const _SceneIllustration({required this.scene});

  final StorySentence scene;

  @override
  Widget build(BuildContext context) {
    final imagePath = scene.imagePath;
    if (imagePath == null) {
      return Text(scene.emoji, style: const TextStyle(fontSize: 96));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          // Artwork for this book may not be ready yet - fall back to the
          // emoji instead of showing a broken-image icon.
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(scene.emoji, style: const TextStyle(fontSize: 72)),
          ),
        ),
      ),
    );
  }
}
