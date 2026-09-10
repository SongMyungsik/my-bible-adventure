import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 20,
  });

  final int stars;
  final int maxStars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final filled = index < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: filled ? Colors.amber : Colors.grey.shade400,
          size: size,
        );
      }),
    );
  }
}
