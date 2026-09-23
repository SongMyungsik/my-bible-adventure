import 'package:flutter/material.dart';

/// Shows [emoji] as a bundled Fluent 3D emoji image, so it looks the same
/// (and friendlier) on every device instead of depending on the system
/// emoji font. Falls back to the plain emoji text if no image is bundled.
///
/// Images live at `assets/emoji/<codepoints>.png`, e.g. 🌤️ -> `1f324.png`
/// (hex code points joined by `-`, with the U+FE0F variation selector
/// dropped).
class EmojiIcon extends StatelessWidget {
  const EmojiIcon(this.emoji, {super.key, required this.size});

  final String emoji;
  final double size;

  static String assetPathFor(String emoji) {
    final codePoints = emoji.runes
        .where((r) => r != 0xFE0F)
        .map((r) => r.toRadixString(16))
        .join('-');
    return 'assets/emoji/$codePoints.png';
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPathFor(emoji),
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => SizedBox(
        width: size,
        height: size,
        child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.8))),
      ),
    );
  }
}
