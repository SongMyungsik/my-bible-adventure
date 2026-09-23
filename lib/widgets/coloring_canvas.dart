import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../models/coloring_page.dart';

/// Renders a [ColoringPage] and reports which region was tapped. Purely
/// presentational - the caller owns the region-color state.
class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.page,
    required this.regionColors,
    required this.onRegionTap,
  });

  final ColoringPage page;
  final Map<String, Color> regionColors;
  final ValueChanged<String> onRegionTap;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  late final Map<String, Path> _paths = {
    for (final region in widget.page.regions) region.id: parseSvgPathData(region.svgPath),
  };
  final _boxKey = GlobalKey();

  void _handleTapUp(TapUpDetails details) {
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || box.size.width == 0) return;
    final scale = box.size.width / widget.page.width;
    final point = details.localPosition / scale;

    for (final region in widget.page.regions.reversed) {
      if (_paths[region.id]!.contains(point)) {
        widget.onRegionTap(region.id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.page.width / widget.page.height,
      child: GestureDetector(
        key: _boxKey,
        onTapUp: _handleTapUp,
        child: CustomPaint(
          painter: _ColoringPainter(
            page: widget.page,
            paths: _paths,
            regionColors: widget.regionColors,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ColoringPainter extends CustomPainter {
  _ColoringPainter({
    required this.page,
    required this.paths,
    required this.regionColors,
  });

  final ColoringPage page;
  final Map<String, Path> paths;
  final Map<String, Color> regionColors;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / page.width;
    canvas.save();
    canvas.scale(scale);

    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black87;

    for (final region in page.regions) {
      final path = paths[region.id]!;
      fillPaint.color = regionColors[region.id] ?? region.initialColor;
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    }
    canvas.restore();
  }

  // The color map is mutated by the same reference from the parent's
  // setState, so identity checks here would miss real changes - simplest
  // to just always repaint this small canvas.
  @override
  bool shouldRepaint(covariant _ColoringPainter oldDelegate) => true;
}
