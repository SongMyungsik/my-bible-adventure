import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/stories_data.dart';
import '../models/vocab_word.dart';
import '../providers/progress_provider.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final recentWords = progress.learnedWordIds
        .map(vocabWordById)
        .whereType<VocabWord>()
        .toList()
        .reversed
        .take(8)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('부모님')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Row(
            children: [
              CircleAvatar(radius: 28, child: Text('🧒', style: TextStyle(fontSize: 28))),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('우리 아이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('초등 저학년', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('이번 주 학습 현황', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _StatRow(emoji: '📖', label: '이야기 완료', value: '${progress.storiesCompletedThisWeek}회'),
                        _StatRow(emoji: '📝', label: '읽은 문장', value: '${progress.sentencesReadThisWeek}개'),
                        _StatRow(emoji: '⭐', label: '배운 단어', value: '${progress.wordsLearnedThisWeek}개'),
                        _StatRow(emoji: '🎮', label: '게임 횟수', value: '${progress.gamesPlayedThisWeek}회'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress.weeklyProgressPercent / 100,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        Text('${progress.weeklyProgressPercent}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('이번 주 배운 단어', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (recentWords.isEmpty)
            const Text('아직 이번 주에 배운 단어가 없어요.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentWords
                  .map((w) => Chip(label: Text('${w.english} (${w.korean})')))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.emoji, required this.label, required this.value});

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
