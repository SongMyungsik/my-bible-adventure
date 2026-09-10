import 'dart:math';

import 'vocab_word.dart';

class GameRound {
  const GameRound({required this.targetWord, required this.optionWords});

  final VocabWord targetWord;
  final List<VocabWord> optionWords;

  int get correctIndex => optionWords.indexOf(targetWord);
}

const _decoyPool = [
  VocabWord(id: 'decoy_star', english: 'star', korean: '별', emoji: '⭐', exampleSentence: ''),
  VocabWord(id: 'decoy_tree', english: 'tree', korean: '나무', emoji: '🌳', exampleSentence: ''),
  VocabWord(id: 'decoy_sun', english: 'sun', korean: '해', emoji: '☀️', exampleSentence: ''),
  VocabWord(id: 'decoy_moon', english: 'moon', korean: '달', emoji: '🌙', exampleSentence: ''),
  VocabWord(id: 'decoy_house', english: 'house', korean: '집', emoji: '🏠', exampleSentence: ''),
  VocabWord(id: 'decoy_bird', english: 'bird', korean: '새', emoji: '🐦', exampleSentence: ''),
];

List<GameRound> generateGameRounds(
  List<VocabWord> vocabulary, {
  int roundCount = 5,
  int optionCount = 4,
  int? seed,
}) {
  final random = Random(seed);
  final targets = List<VocabWord>.from(vocabulary)..shuffle(random);
  final rounds = <GameRound>[];

  for (final target in targets.take(roundCount)) {
    final distractorPool = [
      ...vocabulary.where((w) => w.id != target.id),
      ..._decoyPool.where((w) => w.emoji != target.emoji),
    ]..shuffle(random);

    final options = [target, ...distractorPool.take(optionCount - 1)]
      ..shuffle(random);
    rounds.add(GameRound(targetWord: target, optionWords: options));
  }

  return rounds;
}
