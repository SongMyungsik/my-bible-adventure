import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stories_data.dart';
import '../providers/progress_provider.dart';
import '../widgets/story_card.dart';
import 'game_screen.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final startedStories = bibleStories
        .where((s) => progress.isStoryCompleted(s.id) || progress.starsForStory(s.id) != null)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('게임')),
      body: startedStories.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '먼저 이야기 탭에서 스토리를 읽어보세요!\n그러면 그림 맞추기 게임을 할 수 있어요 🎮',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: startedStories
                  .map(
                    (story) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StoryCard(
                        story: story,
                        completed: progress.isStoryCompleted(story.id),
                        stars: progress.starsForStory(story.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GameScreen(story: story)),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
