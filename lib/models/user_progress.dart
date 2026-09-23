class UserProgress {
  UserProgress({
    this.points = 0,
    Set<String>? completedStoryIds,
    Map<String, int>? gameStars,
    Set<String>? badgeIds,
    Set<String>? learnedWordIds,
    String? weekStartIso,
    this.sentencesReadThisWeek = 0,
    this.wordsLearnedThisWeek = 0,
    this.gamesPlayedThisWeek = 0,
    this.storiesCompletedThisWeek = 0,
  })  : completedStoryIds = completedStoryIds ?? <String>{},
        gameStars = gameStars ?? <String, int>{},
        badgeIds = badgeIds ?? <String>{},
        learnedWordIds = learnedWordIds ?? <String>{},
        weekStartIso = weekStartIso ?? DateTime.now().toIso8601String();

  int points;
  final Set<String> completedStoryIds;
  final Map<String, int> gameStars;
  final Set<String> badgeIds;
  final Set<String> learnedWordIds;

  String weekStartIso;
  int sentencesReadThisWeek;
  int wordsLearnedThisWeek;
  int gamesPlayedThisWeek;
  int storiesCompletedThisWeek;

  Map<String, dynamic> toJson() => {
        'points': points,
        'completedStoryIds': completedStoryIds.toList(),
        'gameStars': gameStars,
        'badgeIds': badgeIds.toList(),
        'learnedWordIds': learnedWordIds.toList(),
        'weekStartIso': weekStartIso,
        'sentencesReadThisWeek': sentencesReadThisWeek,
        'wordsLearnedThisWeek': wordsLearnedThisWeek,
        'gamesPlayedThisWeek': gamesPlayedThisWeek,
        'storiesCompletedThisWeek': storiesCompletedThisWeek,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      points: json['points'] as int? ?? 0,
      completedStoryIds:
          (json['completedStoryIds'] as List?)?.cast<String>().toSet(),
      gameStars: (json['gameStars'] as Map?)?.map(
        (key, value) => MapEntry(key as String, value as int),
      ),
      badgeIds: (json['badgeIds'] as List?)?.cast<String>().toSet(),
      learnedWordIds:
          (json['learnedWordIds'] as List?)?.cast<String>().toSet(),
      weekStartIso: json['weekStartIso'] as String?,
      sentencesReadThisWeek: json['sentencesReadThisWeek'] as int? ?? 0,
      wordsLearnedThisWeek: json['wordsLearnedThisWeek'] as int? ?? 0,
      gamesPlayedThisWeek: json['gamesPlayedThisWeek'] as int? ?? 0,
      storiesCompletedThisWeek: json['storiesCompletedThisWeek'] as int? ?? 0,
    );
  }
}
