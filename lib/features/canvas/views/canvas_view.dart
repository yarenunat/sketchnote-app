import 'package:flutter/material.dart';

import '../engine/input/stylus_input_handler.dart';
import 'canvas_painter.dart';

/// The actual drawing surface for a single page.
///
/// Cursor TODO — implementation plan:
/// 1. Wrap content in a `Listener` (see [StylusInputHandler] for why not
///    GestureDetector) to capture raw pointer events for drawing.
/// 2. Separately support two-finger pan/zoom of the page canvas — this must
///    NOT conflict with single-finger/stylus drawing. Common approach:
///      - 1 stylus contact => drawing, regardless of any other touches
///        (palm rejection handles ignoring the resting hand).
///      - 2 simultaneous touch contacts (no stylus) => pan/zoom via
///        `InteractiveViewer` or a custom scale gesture recognizer.
///      - 1 touch contact only, no stylus => drawing ONLY if "finger
///        drawing" setting is enabled; otherwise treat as pan (some users
///        like single-finger pan, others want it reserved).
/// 3. Render committed strokes from a baked `Picture`/`Image` cache for
///    performance (don't replay thousands of Path draws every frame); only
///    the active in-progress stroke should be redrawn every frame on top
///    of that cached layer. Re-bake the cache when a stroke is finalized,
///    on undo/redo, or when leaving/entering the page.
/// 4. Wire up undo/redo, zoom level, and current tool state from
///    [CanvasViewModel] (to be created) via Riverpod.
/// 5. Support pressure-sensitive eraser separate from brush erasing
///    (Apple Pencil 2nd-gen double-tap to swap tool; S Pen button presses
///    where available via platform channel — stub this, real button
///    binding is platform-specific and may need a small native plugin).
class CanvasView extends StatefulWidget {
  final String pageId;

  const CanvasView({super.key, required this.pageId});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  // Cursor TODO: instantiate StylusInputHandler, wire callbacks to a
  // CanvasViewModel (Riverpod) that owns the active StrokeBuilder and the
  // committed stroke list for this page.

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        // Cursor TODO: forward to StylusInputHandler.
      },
      onPointerMove: (event) {
        // Cursor TODO: forward to StylusInputHandler.
      },
      onPointerUp: (event) {
        // Cursor TODO: forward to StylusInputHandler.
      },
      onPointerCancel: (event) {
        // Cursor TODO: forward to StylusInputHandler.
      },
      child: CustomPaint(
        painter: CanvasPainter(
          // Cursor TODO: pass real committed-stroke cache + active stroke.
        ),
        size: Size.infinite,
        child: const ColoredBox(color: Colors.white),
      ),
    );
  }
}
