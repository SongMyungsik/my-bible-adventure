import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bible_story.dart';
import '../models/game_round.dart';
import '../providers/progress_provider.dart';
import '../services/tts_service.dart';
import 'story_complete_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.story});

  final BibleStory story;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _tts = TtsService();
  late final List<GameRound> _rounds = generateGameRounds(widget.story.vocabulary);
  int _index = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _showFeedback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _speakPrompt() => _tts.speak(_rounds[_index].targetWord.english, rate: 0.6);

  void _selectOption(int optionIndex) {
    if (_showFeedback) return;
    final round = _rounds[_index];
    final isCorrect = optionIndex == round.correctIndex;
    setState(() {
      _selectedIndex = optionIndex;
      _showFeedback = true;
      if (isCorrect) _correctCount++;
    });
  }

  Future<void> _next() async {
    final isLast = _index == _rounds.length - 1;
    if (!isLast) {
      setState(() {
        _index++;
        _selectedIndex = null;
        _showFeedback = false;
      });
      _speakPrompt();
      return;
    }

    final provider = context.read<ProgressProvider>();
    final stars = await provider.recordGameResult(
      storyId: widget.story.id,
      correctCount: _correctCount,
      totalCount: _rounds.length,
    );
    final badges = provider.takeNewlyEarnedBadges();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StoryCompleteScreen(
          story: widget.story,
          stars: stars,
          newBadges: badges,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_index];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('그림 맞추기')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('${_index + 1} / ${_rounds.length}'),
              const SizedBox(height: 16),
              const Text(
                '다음 단어에 맞는 그림을 선택하세요',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _speakPrompt,
                child: Chip(
                  avatar: const Icon(Icons.volume_up_rounded),
                  label: Text(
                    round.targetWord.english,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: round.optionWords.length,
                itemBuilder: (context, i) {
                    final option = round.optionWords[i];
                    Color? borderColor;
                    IconData? badgeIcon;
                    if (_showFeedback) {
                      if (i == round.correctIndex) {
                        borderColor = Colors.green;
                        badgeIcon = Icons.check_circle_rounded;
                      } else if (i == _selectedIndex) {
                        borderColor = Colors.red;
                        badgeIcon = Icons.cancel_rounded;
                      }
                    }
                    return InkWell(
                      onTap: () => _selectOption(i),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: borderColor ?? Colors.grey.shade300,
                            width: borderColor != null ? 3 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(option.emoji, style: const TextStyle(fontSize: 56)),
                            ),
                            if (badgeIcon != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  badgeIcon,
                                  color: borderColor,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              if (_showFeedback)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(_index == _rounds.length - 1 ? 'See Results' : 'Next'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
