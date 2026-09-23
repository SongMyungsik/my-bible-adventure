class BadgeInfo {
  const BadgeInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
}

const storyExplorerBadgeId = 'story_explorer';
const wordMasterBadgeId = 'word_master';
const gameChampionBadgeId = 'game_champion';

const wordMasterThreshold = 20;

const List<BadgeInfo> allBadges = [
  BadgeInfo(
    id: storyExplorerBadgeId,
    title: 'Story Explorer',
    description: 'Finish your first Bible story',
    emoji: '🧭',
  ),
  BadgeInfo(
    id: wordMasterBadgeId,
    title: 'Word Master',
    description: 'Learn $wordMasterThreshold English words',
    emoji: '📚',
  ),
  BadgeInfo(
    id: gameChampionBadgeId,
    title: 'Game Champion',
    description: 'Get a perfect 3-star game score',
    emoji: '🏆',
  ),
];
