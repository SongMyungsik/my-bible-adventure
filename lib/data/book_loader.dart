import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/bible_story.dart';

final _sceneMarker = RegExp(r'^Scene\s*\d+$', caseSensitive: false);

// Some books number their scene titles inline, e.g. "1. Joseph and His
// Family", "1.God Called Jonah", "1A Big Crowd" - stripped since the scene
// viewer already shows "Scene N / total" separately.
final _titleNumberPrefix = RegExp(r'^\d+\.?\s*');

/// Parses a `assets/book/book_XXX.json` file (a flat list of
/// {"영어": ..., "한글": ...} entries) into one [StorySentence] per line
/// (title or body sentence), so the scene viewer can flip through them one
/// at a time. Each "Scene N" marker starts a new scene: all the lines until
/// the next marker share that scene's `assets/images/book_XXX/NN.png`
/// artwork, and the first line after the marker is flagged as the scene's
/// title. Narration files are numbered sequentially across the whole book,
/// e.g. `assets/audio/book_XXX/001.mp3`, `002.mp3`, ... Both asset folders
/// are named after the book file's stem.
Future<List<StorySentence>> loadBookScenes(String assetPath) async {
  final raw = await rootBundle.loadString(assetPath);
  final entries = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  // e.g. "assets/book/book_001.json" -> "book_001", used to locate the
  // matching artwork and narration under assets/images/book_001/ and
  // assets/audio/book_001/.
  final bookStem = assetPath.split('/').last.replaceFirst(RegExp(r'\.json$'), '');
  final imageFolder = 'assets/images/$bookStem';

  final totalScenes = entries
      .where((e) => _sceneMarker.hasMatch((e['영어'] as String).trim()))
      .length;

  final lines = <StorySentence>[];
  var sceneNumber = 0;
  var lineNumber = 0;
  var isFirstLineInScene = false;

  for (final entry in entries) {
    final en = (entry['영어'] as String).trim();
    final ko = (entry['한글'] as String).trim();
    if (_sceneMarker.hasMatch(en)) {
      sceneNumber++;
      isFirstLineInScene = true;
      continue;
    }

    lineNumber++;
    final scenePadded = sceneNumber.toString().padLeft(2, '0');
    final linePadded = lineNumber.toString().padLeft(3, '0');
    final title = isFirstLineInScene ? en.replaceFirst(_titleNumberPrefix, '') : en;
    lines.add(
      StorySentence(
        english: title,
        korean: ko,
        emoji: '📖',
        imagePath: '$imageFolder/$scenePadded.png',
        audioPath: 'assets/audio/$bookStem/$linePadded.mp3',
        isTitle: isFirstLineInScene,
        sceneNumber: sceneNumber,
        totalScenes: totalScenes,
      ),
    );
    isFirstLineInScene = false;
  }

  return lines;
}

/// Resolves the scenes to show for [story]: loaded from its book asset when
/// one is set, otherwise the story's hardcoded [BibleStory.sentences].
Future<List<StorySentence>> resolveStoryScenes(BibleStory story) async {
  final bookPath = story.bookAssetPath;
  if (bookPath == null) return story.sentences;
  return loadBookScenes(bookPath);
}
