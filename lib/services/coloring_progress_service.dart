import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One paint-bucket tap: the tapped pixel and the fill color (ARGB).
typedef ColoringFill = ({int x, int y, int color});

/// Saves each coloring page's fills so a child can come back and keep
/// coloring. Only the list of taps is stored, not the painted image: the
/// canvas replays the fills on load, which keeps each page to a few hundred
/// bytes (a full image would quickly blow past web localStorage limits).
class ColoringProgressService {
  static const _keyPrefix = 'coloring_fills_v1:';

  static String _key(String imageAssetPath) => '$_keyPrefix$imageAssetPath';

  Future<List<ColoringFill>> load(String imageAssetPath) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(imageAssetPath));
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .cast<List>()
          .map((f) => (x: f[0] as int, y: f[1] as int, color: f[2] as int))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(String imageAssetPath, List<ColoringFill> fills) async {
    final prefs = await SharedPreferences.getInstance();
    if (fills.isEmpty) {
      await prefs.remove(_key(imageAssetPath));
      return;
    }
    await prefs.setString(
      _key(imageAssetPath),
      jsonEncode([for (final f in fills) [f.x, f.y, f.color]]),
    );
  }

  /// Image asset paths of every page that has saved coloring.
  Future<Set<String>> startedPages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((k) => k.startsWith(_keyPrefix))
        .map((k) => k.substring(_keyPrefix.length))
        .toSet();
  }
}
