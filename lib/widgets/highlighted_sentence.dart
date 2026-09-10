import 'package:flutter/material.dart';

import '../models/vocab_word.dart';

const _highlightColors = [
  Color(0xFF1976D2),
  Color(0xFFEF6C00),
  Color(0xFF2E7D32),
  Color(0xFFC2185B),
];

/// Renders [sentence] as rich text, coloring and making tappable any word
/// that also appears in [vocabulary] so kids can tap a highlighted word to
/// hear it spoken on its own.
class HighlightedSentence extends StatelessWidget {
  const HighlightedSentence({
    super.key,
    required this.sentence,
    required this.vocabulary,
    required this.onWordTap,
    this.style,
  });

  final String sentence;
  final List<VocabWord> vocabulary;
  final ValueChanged<String> onWordTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
    final tokens = sentence.split(RegExp(r'(?<=\s)|(?=\s)'));

    final spans = <InlineSpan>[];
    for (final token in tokens) {
      final cleaned = token.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
      final lower = cleaned.toLowerCase();
      final matchIndex = vocabulary.indexWhere((w) {
        final base = w.english.toLowerCase();
        return lower == base || (lower.startsWith(base) && lower.length - base.length <= 3);
      });

      if (matchIndex == -1 || cleaned.isEmpty) {
        spans.add(TextSpan(text: token, style: baseStyle));
      } else {
        final color = _highlightColors[matchIndex % _highlightColors.length];
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => onWordTap(vocabulary[matchIndex].english),
              child: Text(
                token,
                style: baseStyle.copyWith(
                  color: color,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}
