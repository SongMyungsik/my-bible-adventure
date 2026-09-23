import '../models/bible_story.dart';
import '../models/coloring_page.dart';

/// Shared coloring page used for any story that doesn't have its own
/// [BibleStory.coloringImagePath] set yet.
const _sampleAssetPath = 'assets/coloring/sample_001.png';

ColoringPage coloringPageForStory(BibleStory story) =>
    ColoringPage(imageAssetPath: story.coloringImagePath ?? _sampleAssetPath);
