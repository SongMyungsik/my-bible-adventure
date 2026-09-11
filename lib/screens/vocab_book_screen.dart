import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stories_data.dart';
import '../models/vocab_word.dart';
import '../providers/progress_provider.dart';
import '../services/narration_service.dart';
import '../widgets/vocab_flashcard.dart';

class VocabBookScreen extends StatelessWidget {
  const VocabBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final words = progress.learnedWordIds
        .map(vocabWordById)
        .whereType<VocabWord>()
        .toList()
      ..sort((a, b) => a.english.compareTo(b.english));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('내 단어장')),
      body: words.isEmpty
          ? const Center(child: Text('아직 배운 단어가 없어요. 이야기를 읽어보세요!'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return _WordCard(word: word);
              },
            ),
    );
  }
}

class _WordCard extends StatelessWidget {
  const _WordCard({required this.word});

  final VocabWord word;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: VocabFlashcard(
            word: word,
            onSpeak: () => NarrationService().speak(
              word.english,
              audioAssetPath: wordAudioPath(word),
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(word.english, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(word.korean, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
