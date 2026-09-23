import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/coloring_pages_data.dart';
import '../data/stories_data.dart';
import '../models/bible_story.dart';
import '../providers/progress_provider.dart';
import '../services/coloring_progress_service.dart';
import 'coloring_screen.dart';

/// 그리기 tab: every story's coloring page in a grid. Pages unlock the same
/// way games do (once the story has been read), so kids still meet the
/// story before coloring it.
class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final _coloringProgress = ColoringProgressService();

  /// Pages with saved coloring, marked so kids can spot what to finish.
  Set<String> _startedPages = {};

  @override
  void initState() {
    super.initState();
    _loadStartedPages();
  }

  Future<void> _loadStartedPages() async {
    final started = await _coloringProgress.startedPages();
    if (mounted) setState(() => _startedPages = started);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    bool isUnlocked(BibleStory s) =>
        progress.isStoryCompleted(s.id) || progress.starsForStory(s.id) != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('그리기')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: bibleStories.length,
        itemBuilder: (context, i) {
          final story = bibleStories[i];
          return _ColoringPageTile(
            story: story,
            unlocked: isUnlocked(story),
            started: _startedPages.contains(coloringPageForStory(story).imageAssetPath),
            onClosed: _loadStartedPages,
          );
        },
      ),
    );
  }
}

class _ColoringPageTile extends StatelessWidget {
  const _ColoringPageTile({
    required this.story,
    required this.unlocked,
    required this.started,
    required this.onClosed,
  });

  final BibleStory story;
  final bool unlocked;
  final bool started;

  /// Called after the coloring screen closes, to refresh [started].
  final VoidCallback onClosed;

  void _open(BuildContext context) {
    if (!unlocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('먼저 이야기 탭에서 "${story.koreanTitle}"를 읽어보세요! 📖')),
        );
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ColoringScreen(story: story)))
        .then((_) => onClosed());
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: unlocked ? 1 : 0.35,
                    child: Image.asset(
                      coloringPageForStory(story).imageAssetPath,
                      fit: BoxFit.contain,
                      // The line art is ~1450px wide; decode a small copy
                      // so the grid doesn't hold 14 full-size images.
                      cacheWidth: 400,
                    ),
                  ),
                  if (!unlocked)
                    const Center(
                      child: Icon(Icons.lock_rounded, size: 40, color: Colors.black45),
                    ),
                  if (unlocked && started)
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: Text('🎨', style: TextStyle(fontSize: 22)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              story.koreanTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked ? null : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
