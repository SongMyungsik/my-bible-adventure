import 'vocab_word.dart';

enum Testament { oldTestament, newTestament }

class StorySentence {
  const StorySentence({
    required this.english,
    required this.korean,
    required this.emoji,
    this.imagePath,
    this.audioPath,
    this.isTitle = false,
    this.sceneNumber,
    this.totalScenes,
  });

  final String english;
  final String korean;
  final String emoji;

  /// Optional illustration asset shown instead of [emoji] in the scene
  /// viewer. Falls back to [emoji] when a story has no artwork yet.
  final String? imagePath;

  /// Optional pre-generated narration (e.g. Azure TTS) for [english].
  /// Falls back to on-device TTS when missing or unplayable.
  final String? audioPath;

  /// Whether this page is a scene's title line (rendered as a heading)
  /// rather than a regular body sentence.
  final bool isTitle;

  /// For book-sourced content: which scene (image) this page belongs to,
  /// and how many scenes the story has in total. Several consecutive pages
  /// can share the same [sceneNumber] (and therefore the same [imagePath]).
  /// Null for hardcoded stories, where each page is its own scene.
  final int? sceneNumber;
  final int? totalScenes;
}

class BibleStory {
  const BibleStory({
    required this.id,
    required this.title,
    required this.koreanTitle,
    required this.description,
    required this.scriptureReference,
    required this.coverEmoji,
    required this.testament,
    required this.sentences,
    required this.vocabulary,
    this.bookAssetPath,
    this.coverImagePath,
    this.coloringImagePath,
  });

  final String id;
  final String title;
  final String koreanTitle;
  final String description;
  final String scriptureReference;
  final String coverEmoji;
  final Testament testament;
  final List<StorySentence> sentences;
  final List<VocabWord> vocabulary;

  /// When set, scenes are loaded at runtime from this JSON asset (see
  /// `lib/data/book_loader.dart`) instead of using [sentences] directly.
  final String? bookAssetPath;

  /// Optional illustration shown on the story intro screen instead of
  /// [coverEmoji].
  final String? coverImagePath;

  /// Optional line-art image used for this story's end-of-story coloring
  /// activity. Falls back to a shared sample page when unset.
  final String? coloringImagePath;
}
