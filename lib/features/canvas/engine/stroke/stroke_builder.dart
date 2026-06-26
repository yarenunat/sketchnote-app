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
  final Color color;

  StrokeBuilder({required this.brush, required this.color});

  /// Raw points collected so far for the in-progress stroke.
  final List<InputPoint> _rawPoints = [];
  final List<Offset> _smoothedPoints = [];
  final List<double> _widths = [];
  
  Path? _cachedPath;

  void addPoint(InputPoint point) {
    _rawPoints.add(point);
    
    // Stabilize
    Offset smoothedPos = point.position;
    if (_smoothedPoints.isNotEmpty && brush.stabilization > 0) {
      double st = brush.stabilization.clamp(0.0, 0.99);
      smoothedPos = Offset.lerp(_smoothedPoints.last, point.position, 1.0 - st)!;
    }
    _smoothedPoints.add(smoothedPos);

    // Calculate width
    double pressureFactor = lerpDouble(1.0 - brush.pressureToSizeCurve, 1.0, point.pressure) ?? 1.0;
    double width = brush.baseSize * pressureFactor;
    
    // Start taper
    int taperLength = 10;
    if (_rawPoints.length < taperLength && brush.taperStart > 0) {
      double t = _rawPoints.length / taperLength;
      double taperFactor = lerpDouble(1.0 - brush.taperStart, 1.0, t) ?? 1.0;
      width *= taperFactor;
    }

    _widths.add(width);
    _cachedPath = null;
  }

  /// Returns the current best-effort renderable Path for the in-progress
  /// stroke (called every frame while drawing).
  Path buildPreviewPath() {
    if (_cachedPath != null) return _cachedPath!;
    _cachedPath = _buildVariableWidthPath(_smoothedPoints, _widths);
    return _cachedPath!;
  }

  /// Finalizes the stroke, returning an immutable result to hand off to the
  /// page's stroke list / undo stack.
  StrokeResult finish() {
    if (brush.taperEnd > 0) {
      int taperLength = 10;
      int n = _widths.length;
      for (int i = 0; i < taperLength && i < n; i++) {
        double t = i / taperLength;
        double taperFactor = lerpDouble(1.0 - brush.taperEnd, 1.0, t) ?? 1.0;
        _widths[n - 1 - i] *= taperFactor;
      }
      _cachedPath = null;
    }

    Path finalPath = buildPreviewPath();
    
    return StrokeResult(
      path: finalPath,
      boundingBox: finalPath.getBounds(),
      brushSnapshot: brush,
      color: color,
    );
  }

  Path _buildVariableWidthPath(List<Offset> points, List<double> widths) {
    if (points.isEmpty) return Path();
    if (points.length == 1) {
      return Path()..addOval(Rect.fromCircle(center: points.first, radius: widths.first / 2));
    }

    Path path = Path();
    List<Offset> leftBound = [];
    List<Offset> rightBound = [];

    for (int i = 0; i < points.length; i++) {
      Offset current = points[i];
      Offset next = (i < points.length - 1) ? points[i + 1] : points[i];
      Offset prev = (i > 0) ? points[i - 1] : points[i];

      Offset dir;
      if (i == 0) {
        dir = next - current;
      } else if (i == points.length - 1) {
        dir = current - prev;
      } else {
        dir = next - prev;
      }

      if (dir.distance == 0) {
        dir = const Offset(1, 0);
      } else {
        dir = dir / dir.distance;
      }

      Offset normal = Offset(-dir.dy, dir.dx);
      double radius = widths[i] / 2;

      leftBound.add(current + normal * radius);
      rightBound.add(current - normal * radius);
    }

    path.moveTo(leftBound.first.dx, leftBound.first.dy);
    _addSmoothCurve(path, leftBound);
    
    path.arcToPoint(
      rightBound.last,
      radius: Radius.circular(widths.last / 2),
      clockwise: false,
    );

    _addSmoothCurve(path, rightBound.reversed.toList(), isReversed: true);

    path.arcToPoint(
      leftBound.first,
      radius: Radius.circular(widths.first / 2),
      clockwise: false,
    );

    path.close();
    return path;
  }

  void _addSmoothCurve(Path path, List<Offset> bound, {bool isReversed = false}) {
    if (bound.length < 2) return;
    
    if (isReversed) {
      path.lineTo(bound.first.dx, bound.first.dy);
    }

    for (int i = 0; i < bound.length - 1; i++) {
      Offset p0 = bound[i];
      Offset p1 = bound[i + 1];
      Offset mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      
      if (i == bound.length - 2) {
        path.lineTo(p1.dx, p1.dy);
      } else {
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
    }
  }
}

/// Immutable finalized stroke, ready for storage and rendering.
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
