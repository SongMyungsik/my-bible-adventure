import 'package:flutter/material.dart';

/// One fillable shape in a coloring page, defined as raw SVG path data
/// (the same syntax as an SVG `<path d="...">` attribute).
class ColoringRegion {
  const ColoringRegion({
    required this.id,
    required this.svgPath,
    this.initialColor = Colors.white,
  });

  final String id;
  final String svgPath;
  final Color initialColor;
}

/// A coloring page: a fixed-size canvas ([width]x[height]) containing a
/// list of regions, painted in order (later regions draw on top of
/// earlier ones, e.g. a door on top of a house body).
class ColoringPage {
  const ColoringPage({
    required this.width,
    required this.height,
    required this.regions,
  });

  final double width;
  final double height;
  final List<ColoringRegion> regions;
}
