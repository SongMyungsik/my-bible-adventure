import 'package:flutter/foundation.dart';

import '../data/badges_data.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';

const storyCompleteReward = 10;
const gameCorrectAnswerReward = 5;

const weeklyGoalStories = 3;
const weeklyGoalSentences = 30;
const weeklyGoalWords = 20;
const weeklyGoalGames = 10;

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({ProgressService? service})
      : _service = service ?? ProgressService(),
        _progress = UserProgress() {
    _load();
  }

  final ProgressService _service;
  UserProgress _progress;
  bool _isLoaded = false;
  List<String>? _newlyEarnedBadges;

  bool get isLoaded => _isLoaded;
  int get points => _progress.points;
  Set<String> get completedStoryIds => _progress.completedStoryIds;
  Set<String> get badgeIds => _progress.badgeIds;
  Set<String> get learnedWordIds => _progress.learnedWordIds;

  int get sentencesReadThisWeek => _progress.sentencesReadThisWeek;
  int get wordsLearnedThisWeek => _progress.wordsLearnedThisWeek;
  int get gamesPlayedThisWeek => _progress.gamesPlayedThisWeek;
  int get storiesCompletedThisWeek => _progress.storiesCompletedThisWeek;

  bool isStoryCompleted(String storyId) =>
      _progress.completedStoryIds.contains(storyId);

  int? starsForStory(String storyId) => _progress.gameStars[storyId];

  int get weeklyProgressPercent {
    final ratios = [
      _progress.storiesCompletedThisWeek / weeklyGoalStories,
      _progress.sentencesReadThisWeek / weeklyGoalSentences,
      _progress.wordsLearnedThisWeek / weeklyGoalWords,
      _progress.gamesPlayedThisWeek / weeklyGoalGames,
    ].map((r) => r.clamp(0, 1));
    final average = ratios.reduce((a, b) => a + b) / ratios.length;
    return (average * 100).round();
  }

  Future<void> _load() async {
    _progress = await _service.load();
    _isLoaded = true;
    notifyListeners();
  }

  void _rolloverWeekIfNeeded() {
    final weekStart = DateTime.tryParse(_progress.weekStartIso) ?? DateTime.now();
    if (DateTime.now().difference(weekStart).inDays >= 7) {
      _progress.weekStartIso = DateTime.now().toIso8601String();
      _progress.sentencesReadThisWeek = 0;
      _progress.wordsLearnedThisWeek = 0;
      _progress.gamesPlayedThisWeek = 0;
      _progress.storiesCompletedThisWeek = 0;
    }
  }

  Future<void> recordSentenceRead() async {
    _rolloverWeekIfNeeded();
    _progress.sentencesReadThisWeek++;
    await _service.save(_progress);
    notifyListeners();
  }

  Future<void> markStoryCompleted(String storyId) async {
    _rolloverWeekIfNeeded();
    if (_progress.completedStoryIds.add(storyId)) {
      _progress.points += storyCompleteReward;
      _progress.storiesCompletedThisWeek++;
      _recalculateBadges();
      await _service.save(_progress);
      notifyListeners();
    }
  }

  Future<void> learnWords(Iterable<String> wordIds) async {
    _rolloverWeekIfNeeded();
    var changed = false;
    for (final id in wordIds) {
      if (_progress.learnedWordIds.add(id)) {
        changed = true;
        _progress.wordsLearnedThisWeek++;
      }
    }
    if (changed) {
      _recalculateBadges();
      await _service.save(_progress);
      notifyListeners();
    }
  }

  /// Records a finished picture-match game, awards points per correct
  /// answer, and returns the star rating (1-3) earned for this attempt.
  Future<int> recordGameResult({
    required String storyId,
    required int correctCount,
    required int totalCount,
  }) async {
    _rolloverWeekIfNeeded();
    _progress.points += correctCount * gameCorrectAnswerReward;
    _progress.gamesPlayedThisWeek++;
    final stars = _starsFor(correctCount, totalCount);
    final best = _progress.gameStars[storyId];
    if (best == null || stars > best) {
      _progress.gameStars[storyId] = stars;
    }
    _recalculateBadges();
    await _service.save(_progress);
    notifyListeners();
    return stars;
  }

  int _starsFor(int correct, int total) {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 0.99) return 3;
    if (ratio >= 0.6) return 2;
    if (ratio > 0) return 1;
    return 0;
  }

  /// Badges newly unlocked by the most recent action, consumed once by the
  /// UI to show a celebration, then cleared.
  List<String> takeNewlyEarnedBadges() {
    final badges = _newlyEarnedBadges ?? const [];
    _newlyEarnedBadges = null;
    return badges;
  }

  void _recalculateBadges() {
    final earned = <String>[];
    if (_progress.completedStoryIds.isNotEmpty) {
      earned.add(storyExplorerBadgeId);
    }
    if (_progress.learnedWordIds.length >= wordMasterThreshold) {
      earned.add(wordMasterBadgeId);
    }
    if (_progress.gameStars.values.any((stars) => stars >= 3)) {
      earned.add(gameChampionBadgeId);
    }

    final newlyEarned =
        earned.where((id) => !_progress.badgeIds.contains(id)).toList();
    if (newlyEarned.isNotEmpty) {
      _progress.badgeIds.addAll(newlyEarned);
      _newlyEarnedBadges = [...?_newlyEarnedBadges, ...newlyEarned];
    }
  }
}
