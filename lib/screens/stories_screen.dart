import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stories_data.dart';
import '../models/bible_story.dart';
import '../providers/progress_provider.dart';
import 'story_intro_screen.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        title: const Text('성경 이야기'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '구약 이야기'), Tab(text: '신약 이야기')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StoryList(
            stories: storiesByTestament(Testament.oldTestament),
            progress: progress,
          ),
          _StoryList(
            stories: storiesByTestament(Testament.newTestament),
            progress: progress,
          ),
        ],
      ),
    );
  }
}

class _StoryList extends StatelessWidget {
  const _StoryList({required this.stories, required this.progress});

  final List<BibleStory> stories;
  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) {
      return const Center(child: Text('곧 새로운 이야기가 추가돼요!'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return _StoryGridCard(
          story: story,
          completed: progress.isStoryCompleted(story.id),
          stars: progress.starsForStory(story.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => StoryIntroScreen(story: story)),
          ),
        );
      },
    );
  }
}

class _StoryGridCard extends StatelessWidget {
  const _StoryGridCard({
    required this.story,
    required this.completed,
    required this.stars,
    required this.onTap,
  });

  final BibleStory story;
  final bool completed;
  final int? stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(story.coverEmoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(
                story.koreanTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                story.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              if (completed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      i < (stars ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
