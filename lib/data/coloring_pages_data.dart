import '../models/bible_story.dart';
import '../models/coloring_page.dart';

/// A placeholder coloring page used for every story until per-story line
/// art is ready. Swap the lookup in [coloringPageForStory] once real
/// artwork exists per book.
const _samplePage = ColoringPage(imageAssetPath: 'assets/coloring/sample_001.png');

ColoringPage coloringPageForStory(BibleStory story) => _samplePage;
