import 'dart:ui';

import '../brushes/brush_settings.dart';
import '../input/input_point.dart';

/// Converts a sequence of raw [InputPoint]s into a renderable stroke.
///
/// This is the heart of "what makes the line feel good." Two responsibilities
/// are deliberately split:
///   1. Geometric smoothing (turning jittery raw points into a smooth curve).
///   2. Brush-specific stamping/texture (turning that curve into pixels).
///
/// Cursor TODO — implementation plan:
/// 1. Smoothing: implement either
///      (a) Catmull-Rom spline interpolation between raw points, or
///      (b) the "Perfect Freehand" algorithm (popular open-source approach:
///          https://github.com/steveruizok/perfect-freehand — re-implement
///          the core algorithm in Dart, don't just port blindly, and respect
///          its license/attribution if porting logic) for variable-width
///          smoothed outlines that already factor in pressure.
///    Apply [BrushSettings.stabilization] as an additional low-pass filter /
///    catch-up-lag on the input position before smoothing (this is the
///    "stabilizer" feature professional apps offer for clean linework).
/// 2. Width profile: at each point along the smoothed curve, compute local
///    width = baseSize * lerp(1 - pressureToSizeCurve, 1, pressure-derived
///    factor), with extra easing at [taperStart]/[taperEnd].
/// 3. Build a single `Path` (or, for textured/grain brushes, a list of
///    stamp transforms — position/rotation/scale — to be drawn with
///    `Canvas.drawAtlas` for performance) representing the final stroke.
/// 4. Incremental re-render: while the stroke is in progress, this should
///    support cheaply appending new points and re-emitting only the
///    incremental Path delta, NOT recomputing the entire stroke from
///    scratch every frame — that's the difference between 60fps and janky
///    drawing on long strokes. Consider keeping a rolling window of the
///    last N raw points for smoothing context, while freezing/baking
///    earlier segments into a static Picture.
/// 5. Output a `Stroke` model (see stroke_model.dart) ready for the
///    CanvasPainter to draw and for persistence to store.
class StrokeBuilder {
  final BrushSettings brush;

  StrokeBuilder({required this.brush});

  /// Raw points collected so far for the in-progress stroke.
  final List<InputPoint> _rawPoints = [];

  void addPoint(InputPoint point) {
    _rawPoints.add(point);
    // Cursor TODO: trigger incremental smoothing + path rebuild here.
  }

  /// Returns the current best-effort renderable Path for the in-progress
  /// stroke (called every frame while drawing).
  Path buildPreviewPath() {
    throw UnimplementedError('Cursor: implement smoothing -> Path construction.');
  }

  /// Finalizes the stroke, returning an immutable result to hand off to the
  /// page's stroke list / undo stack.
  StrokeResult finish() {
    throw UnimplementedError('Cursor: bake final Path + bounding box + brush snapshot.');
  }
}

/// Immutable finalized stroke, ready for storage and rendering.
///
/// Cursor TODO: also store the raw [InputPoint] list (or a compressed form
/// of it) alongside the baked Path, NOT just the Path — so that strokes
/// remain editable later (e.g. a future "adjust pressure curve after the
/// fact" feature) and so vector export (PDF/SVG) stays crisp at any zoom,
/// rather than rasterizing once and losing resolution.
class StrokeResult {
  final Path path;
  final Rect boundingBox;
  final BrushSettings brushSnapshot;
  final Color color;

  const StrokeResult({
    required this.path,
    required this.boundingBox,
    required this.brushSnapshot,
    required this.color,
  });
}
