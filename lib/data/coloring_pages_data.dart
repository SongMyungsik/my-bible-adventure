import '../models/bible_story.dart';
import '../models/coloring_page.dart';

/// A simple placeholder coloring page (a house, a tree, and the sun) used
/// for every story until per-story line art is ready. Swap the lookup in
/// [coloringPageForStory] once real artwork exists per book.
const _sampleColoringPage = ColoringPage(
  width: 320,
  height: 320,
  regions: [
    ColoringRegion(id: 'sun', svgPath: 'M288,60 L280,80 L260,88 L240,80 L232,60 L240,40 L260,32 L280,40 Z'),
    ColoringRegion(id: 'tree_leaves', svgPath: 'M315,200 L306,221 L285,230 L264,221 L255,200 L264,179 L285,170 L306,179 Z'),
    ColoringRegion(id: 'tree_trunk', svgPath: 'M275,230 L295,230 L295,280 L275,280 Z'),
    ColoringRegion(id: 'roof', svgPath: 'M60,160 L160,80 L260,160 Z'),
    ColoringRegion(id: 'body', svgPath: 'M70,160 L250,160 L250,280 L70,280 Z'),
    ColoringRegion(id: 'window_left', svgPath: 'M90,190 L120,190 L120,220 L90,220 Z'),
    ColoringRegion(id: 'window_right', svgPath: 'M200,190 L230,190 L230,220 L200,220 Z'),
    ColoringRegion(id: 'door', svgPath: 'M140,210 L180,210 L180,280 L140,280 Z'),
  ],
);

ColoringPage coloringPageForStory(BibleStory story) => _sampleColoringPage;
