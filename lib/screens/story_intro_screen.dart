import 'package:flutter/material.dart';

import '../data/book_loader.dart';
import '../models/bible_story.dart';
import 'scene_viewer_screen.dart';

class StoryIntroScreen extends StatelessWidget {
  const StoryIntroScreen({super.key, required this.story});

  final BibleStory story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: Text(story.koreanTitle)),
      body: SafeArea(
        child: FutureBuilder<List<StorySentence>>(
          future: resolveStoryScenes(story),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final scenes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  _StoryCover(story: story),
                  const SizedBox(height: 20),
                  Text(
                    story.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MetaChip(icon: Icons.auto_stories_rounded, label: '${scenes.length} 장면'),
                      const SizedBox(width: 12),
                      _MetaChip(icon: Icons.spellcheck_rounded, label: '단어 ${story.vocabulary.length}개'),
                      const SizedBox(width: 12),
                      const _MetaChip(icon: Icons.videogame_asset_rounded, label: '게임 1개'),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SceneViewerScreen(story: story, scenes: scenes),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text("Let's Begin!"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StoryCover extends StatelessWidget {
  const _StoryCover({required this.story});

  final BibleStory story;

  @override
  Widget build(BuildContext context) {
    final imagePath = story.coverImagePath;
    if (imagePath == null) {
      return Text(story.coverEmoji, style: const TextStyle(fontSize: 96));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) =>
            Text(story.coverEmoji, style: const TextStyle(fontSize: 96)),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.white,
    );
  }
}
