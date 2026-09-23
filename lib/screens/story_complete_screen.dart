import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/badges_data.dart';
import '../data/stories_data.dart';
import '../models/bible_story.dart';
import '../providers/progress_provider.dart';
import '../widgets/star_rating.dart';
import 'story_intro_screen.dart';

class StoryCompleteScreen extends StatefulWidget {
  const StoryCompleteScreen({
    super.key,
    required this.story,
    required this.stars,
    required this.newBadges,
  });

  final BibleStory story;
  final int stars;
  final List<String> newBadges;

  @override
  State<StoryCompleteScreen> createState() => _StoryCompleteScreenState();
}

class _StoryCompleteScreenState extends State<StoryCompleteScreen> {
  late List<String> _allNewBadges = widget.newBadges;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProgressProvider>();
      await provider.markStoryCompleted(widget.story.id);
      final moreBadges = provider.takeNewlyEarnedBadges();
      if (moreBadges.isNotEmpty && mounted) {
        setState(() => _allNewBadges = [..._allNewBadges, ...moreBadges]);
      }
    });
  }

  void _goToNextStory() {
    final currentIndex = bibleStories.indexWhere((s) => s.id == widget.story.id);
    final next = bibleStories[(currentIndex + 1) % bibleStories.length];
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => StoryIntroScreen(story: next)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('Great Job!'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Text('🎉', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.story.title} 완료!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      StarRating(stars: widget.stars, size: 40),
                      const SizedBox(height: 24),
                      const _ChecklistItem(label: '읽기 완료'),
                      const _ChecklistItem(label: '듣기 완료'),
                      const _ChecklistItem(label: '따라 말하기 완료'),
                      const _ChecklistItem(label: '게임 완료'),
                      const _ChecklistItem(label: '색칠 완료'),
                      if (_allNewBadges.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('New badge unlocked!', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: _allNewBadges.map((id) {
                            final badge = allBadges.firstWhere((b) => b.id == id);
                            return Chip(avatar: Text(badge.emoji), label: Text(badge.title));
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _goToNextStory,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('다음 이야기로'),
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

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
