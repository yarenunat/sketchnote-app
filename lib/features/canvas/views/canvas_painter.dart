import 'package:flutter/material.dart';

/// Paints the committed-stroke cache plus any in-progress stroke for the
/// current page.
///
/// Cursor TODO:
/// - Take a cached `ui.Picture` (or `ui.Image`) for already-committed
///   strokes and draw it with `canvas.drawPicture`/`drawImage` — cheap,
///   constant cost regardless of stroke count.
/// - Take the current in-progress `Path` (from StrokeBuilder.buildPreviewPath)
///   and draw it fresh each frame on top.
/// - For textured/grain brushes, prefer `canvas.drawAtlas` with a sprite
///   sheet of the brush texture for stamping performance over drawing many
///   individual images.
/// - Override `shouldRepaint` precisely (compare cache generation id + active
///   stroke point count) so Flutter doesn't over-repaint.
class CanvasPainter extends CustomPainter {
  const CanvasPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cursor TODO: draw cached layer, then active stroke preview.
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    // Cursor TODO: real diffing logic.
    return true;
  }
}
