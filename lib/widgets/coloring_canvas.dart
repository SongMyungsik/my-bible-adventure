import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import '../models/coloring_page.dart';

/// How close a neighboring pixel's color must be to the tapped pixel's
/// color to be considered "the same region" and get filled too. Loose
/// enough to cover anti-aliased pixels near the fill boundary, tight
/// enough not to leak through a solid outline.
const _colorToleranceSquared = 40 * 40;

/// Caps memory use: each undo step holds a full copy of the image.
const _maxHistory = 15;

/// Drives a [ColoringCanvas] from outside it (e.g. Undo/Clear buttons
/// elsewhere on the screen), since the pixel buffer itself has to live
/// inside the canvas's own state.
class ColoringCanvasController extends ChangeNotifier {
  _ColoringCanvasState? _state;

  bool get isReady => _state?._working != null;
  bool get canUndo => _state?._history.isNotEmpty ?? false;

  void undo() => _state?._undo();
  void clear() => _state?._clear();

  void _attach(_ColoringCanvasState state) {
    _state = state;
    notifyListeners();
  }

  void _detach(_ColoringCanvasState state) {
    if (_state == state) _state = null;
  }

  void _refresh() => notifyListeners();
}

/// Renders a [ColoringPage] image and flood-fills the tapped region with
/// [selectedColor] on tap, like a paint-bucket tool.
class ColoringCanvas extends StatefulWidget {
  const ColoringCanvas({
    super.key,
    required this.page,
    required this.selectedColor,
    this.controller,
  });

  final ColoringPage page;
  final Color selectedColor;
  final ColoringCanvasController? controller;

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  img.Image? _original;
  img.Image? _working;
  ui.Image? _displayImage;
  final List<img.Image> _history = [];
  final _boxKey = GlobalKey();
  final _transform = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _transform.addListener(_onTransformChanged);
    _load();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _transform.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _resetZoom() => _transform.value = Matrix4.identity();

  Future<void> _load() async {
    final data = await rootBundle.load(widget.page.imageAssetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final decoded = img.decodePng(bytes)!.convert(numChannels: 4);
    _original = decoded;
    _working = decoded.clone();
    await _refreshDisplayImage();
    if (mounted) setState(() {});
  }

  Future<void> _refreshDisplayImage() async {
    final working = _working;
    if (working == null) return;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      working.getBytes(order: img.ChannelOrder.rgba),
      working.width,
      working.height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    _displayImage = await completer.future;
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _working = _history.removeLast();
    });
    _refreshDisplayImage().then((_) {
      if (mounted) setState(() {});
      widget.controller?._refresh();
    });
  }

  void _clear() {
    final original = _original;
    if (original == null) return;
    _history.clear();
    setState(() => _working = original.clone());
    _refreshDisplayImage().then((_) {
      if (mounted) setState(() {});
      widget.controller?._refresh();
    });
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    final working = _working;
    final box = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (working == null || box == null || box.size.width == 0) return;

    final x = (details.localPosition.dx * working.width / box.size.width).floor();
    final y = (details.localPosition.dy * working.height / box.size.height).floor();
    if (x < 0 || y < 0 || x >= working.width || y >= working.height) return;

    final snapshot = working.clone();
    final filled = _floodFill(working, x, y, widget.selectedColor);
    if (!filled) return;

    _history.add(snapshot);
    while (_history.length > _maxHistory) {
      _history.removeAt(0);
    }
    await _refreshDisplayImage();
    if (mounted) setState(() {});
    widget.controller?._refresh();
  }

  /// Scanline flood fill: fills the run of matching pixels on the tapped
  /// row, then seeds the rows above/below wherever they still match,
  /// instead of queuing every pixel individually.
  bool _floodFill(img.Image image, int startX, int startY, Color fillColor) {
    // image.getPixel() returns a live cursor into the pixel buffer, not a
    // value snapshot - it must be read into plain numbers up front, or its
    // r/g/b would start reflecting the newly-painted color as soon as the
    // fill overwrites the start pixel itself, corrupting every match check
    // after that point.
    final startPixel = image.getPixel(startX, startY);
    final targetR = startPixel.r, targetG = startPixel.g, targetB = startPixel.b;
    final newR = (fillColor.r * 255).round();
    final newG = (fillColor.g * 255).round();
    final newB = (fillColor.b * 255).round();

    bool matches(int x, int y) {
      final p = image.getPixel(x, y);
      final dr = p.r - targetR;
      final dg = p.g - targetG;
      final db = p.b - targetB;
      return dr * dr + dg * dg + db * db <= _colorToleranceSquared;
    }

    if (!matches(startX, startY)) return false;
    // Already (near) this exact color? nothing to do.
    final dr = targetR - newR, dg = targetG - newG, db = targetB - newB;
    if (dr * dr + dg * dg + db * db <= _colorToleranceSquared) return false;

    final width = image.width;
    final height = image.height;
    final stack = <(int, int)>[(startX, startY)];
    var didFill = false;

    while (stack.isNotEmpty) {
      final (sx, sy) = stack.removeLast();
      if (!matches(sx, sy)) continue;

      var left = sx;
      while (left - 1 >= 0 && matches(left - 1, sy)) {
        left--;
      }
      var right = sx;
      while (right + 1 < width && matches(right + 1, sy)) {
        right++;
      }

      for (var x = left; x <= right; x++) {
        image.setPixelRgba(x, sy, newR, newG, newB, 255);
      }
      didFill = true;

      for (final ny in [sy - 1, sy + 1]) {
        if (ny < 0 || ny >= height) continue;
        var x = left;
        while (x <= right) {
          if (matches(x, ny)) {
            stack.add((x, ny));
            while (x <= right && matches(x, ny)) {
              x++;
            }
          } else {
            x++;
          }
        }
      }
    }
    return didFill;
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = _displayImage;
    final working = _working;
    if (displayImage == null || working == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Two-finger pinch zooms in so small regions are easy for little
    // fingers to hit; one finger pans while zoomed. Taps inside the
    // InteractiveViewer child arrive in the child's own (unscaled)
    // coordinates, so the fill math in _handleTapUp needs no changes.
    return AspectRatio(
      aspectRatio: working.width / working.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: 5,
              child: GestureDetector(
                key: _boxKey,
                onTapUp: _handleTapUp,
                child: CustomPaint(
                  painter: _ColoringImagePainter(displayImage),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          if (_isZoomed)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton.filledTonal(
                onPressed: _resetZoom,
                icon: const Icon(Icons.zoom_out_map_rounded),
                tooltip: '원래 크기로',
              ),
            ),
        ],
      ),
    );
  }
}

class _ColoringImagePainter extends CustomPainter {
  _ColoringImagePainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _ColoringImagePainter oldDelegate) => oldDelegate.image != image;
}
