import 'package:flutter/material.dart';

import '../data/coloring_pages_data.dart';
import '../models/bible_story.dart';
import '../models/coloring_page.dart';
import '../widgets/coloring_canvas.dart';
import 'story_complete_screen.dart';

const _palette = [
  Colors.red,
  Colors.orange,
  Colors.amber,
  Colors.green,
  Colors.blue,
  Colors.purple,
  Colors.deepOrange,
  Colors.pink,
  Colors.brown,
  Colors.black,
];

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({
    super.key,
    required this.story,
    required this.stars,
    required this.newBadges,
  });

  final BibleStory story;
  final int stars;
  final List<String> newBadges;

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  late final ColoringPage _page = coloringPageForStory(widget.story);
  final _controller = ColoringCanvasController();
  Color _selectedColor = _palette.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StoryCompleteScreen(
          story: widget.story,
          stars: widget.stars,
          newBadges: widget.newBadges,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('Coloring Time!'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              // The canvas takes all the space that's left over once the
              // (fixed-height) controls below have what they need, so it's
              // as big as the screen allows without needing to rotate.
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: ColoringCanvas(
                      page: _page,
                      selectedColor: _selectedColor,
                      controller: _controller,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: _palette.map((color) {
                  final selected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.grey.shade300,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _controller,
                      builder: (context, _) => OutlinedButton.icon(
                        onPressed: _controller.canUndo ? _controller.undo : null,
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Undo'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _controller.clear,
                      icon: const Icon(Icons.layers_clear_rounded),
                      label: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _finish,
                  child: const Text('완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
